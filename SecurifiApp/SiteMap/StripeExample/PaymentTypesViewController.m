//
//  PaymentTypesViewController.m
//  SecurifiApp
//
//  Created by Masood on 12/7/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "PaymentTypesViewController.h"

#import <Stripe/Stripe.h>

#import "ViewController.h"
#import "PaymentViewController.h"
#import "Constants.h"
#import "ShippingManager.h"
#import "SFIBackendAPIClient.h"

@interface PaymentTypesViewController () <PaymentViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate>
@property (nonatomic) BOOL applePaySucceeded;
@property (nonatomic) NSError *applePayError;
@property (nonatomic) ShippingManager *shippingManager;
@property (weak, nonatomic) IBOutlet UIButton *applePayButton;

@end

@implementation PaymentTypesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shippingManager = [[ShippingManager alloc] init];
    self.applePayButton.enabled = [self applePayEnabled];
}

- (void)presentError:(NSError *)error {
    NSLog(@"error: %@", error);
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)paymentSucceeded {
    NSLog(@"paymentSucceeded");
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Success" message:@"Payment successfully created!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Apple Pay

- (BOOL)applePayEnabled {
    NSLog(@"applePayEnabled");
    if ([PKPaymentRequest class]) {
        PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:AppleMerchantId];
        paymentRequest.shippingMethods = [self.shippingManager defaultShippingMethods];
        paymentRequest.paymentSummaryItems = [self summaryItemsForShippingMethod:paymentRequest.shippingMethods.firstObject];
        NSLog(@"payment request: %@, appid: %@", paymentRequest, AppleMerchantId);
        return [Stripe canSubmitPaymentRequest:paymentRequest];
    }
    return NO;
}
- (IBAction)onCrossTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingAddress:(ABRecordRef)address completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *> * _Nonnull, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion {
    NSLog(@"didSelectShippingAddress");
    [self.shippingManager fetchShippingCostsForAddress:address
                                            completion:^(NSArray *shippingMethods, NSError *error) {
                                                NSLog(@"fetchShippingCostsForAddress");
                                                if (error) {
                                                    completion(PKPaymentAuthorizationStatusFailure, @[], @[]);
                                                    return;
                                                }
                                                completion(PKPaymentAuthorizationStatusSuccess,
                                                           shippingMethods,
                                                           [self summaryItemsForShippingMethod:shippingMethods.firstObject]);
                                            }];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingMethod:(PKShippingMethod *)shippingMethod completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion {
    NSLog(@"didSelectShippingMethod");
    completion(PKPaymentAuthorizationStatusSuccess, [self summaryItemsForShippingMethod:shippingMethod]);
}

- (NSArray *)summaryItemsForShippingMethod:(PKShippingMethod *)shippingMethod {
    NSLog(@"summaryItemsForShippingMethod");
    PKPaymentSummaryItem *shirtItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Cool Subscription" amount:[NSDecimalNumber decimalNumberWithString:@"10.00"]];
    //    NSDecimalNumber *total = [shirtItem.amount decimalNumberByAdding:shippingMethod.amount];
    PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Stripe Shirt Shop" amount:shirtItem.amount];
    return @[shirtItem, totalItem];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSLog(@"didAuthorizePayment");
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 NSLog(@"create token with paymentk token: %@", token);
                                                 [self createBackendChargeWithToken:token
                                                                         completion:^(STPBackendChargeResult status, NSError *error) {
                                                                             if (status == STPBackendChargeResultSuccess) {
                                                                                 self.applePaySucceeded = YES;
                                                                                 completion(PKPaymentAuthorizationStatusSuccess);
                                                                             } else {
                                                                                 self.applePayError = error;
                                                                                 completion(PKPaymentAuthorizationStatusFailure);
                                                                             }
                                                                         }];
                                             }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    NSLog(@"paymentAuthorizationViewControllerDidFinish");
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.applePaySucceeded) {
            [self paymentSucceeded];
        } else if (self.applePayError) {
            [self presentError:self.applePayError];
        }
        self.applePaySucceeded = NO;
        self.applePayError = nil;
    }];
}

#pragma mark - Custom Credit Card Form

- (IBAction)beginCustomPayment:(id)sender {
    NSLog(@"beginCustomPayment");
    /*[self.payContext presentPaymentMethodsViewController];
     return;*/
    
    
}


- (void)paymentViewController:(PaymentViewController *)controller didFinish:(NSError *)error {
    NSLog(@"payment finished");
    [self dismissViewControllerAnimated:YES completion:^{
        if (error) {
            [self presentError:error];
        } else {
            [self paymentSucceeded];
        }
    }];
}

#pragma mark - STPBackendCharging

- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
    NSLog(@"vc createBackendChargeWithToken");
    if (!BackendChargeURLString) {
        NSError *error = [NSError
                          errorWithDomain:StripeDomain
                          code:STPInvalidRequestError
                          userInfo:@{
                                     NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "
                                                                 @"instructions in the README to set up an example backend, or use this "
                                                                 @"token to manually create charges at dashboard.stripe.com .",
                                                                 token.tokenId]
                                     }];
        completion(STPBackendChargeResultFailure, error);
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSString *urlString = [BackendChargeURLString stringByAppendingPathComponent:@"charge_card"];
    
    
    //    urlString = @"https://status.securifi.com:443/payment";
    NSLog(@"urlstring: %@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *postBody = [NSString stringWithFormat:@"stripe_token=%@&amount=%@", token.tokenId, @1000];
    NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:data
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                                          NSLog(@"status code: %ld", (long)httpResponse.statusCode);
                                                          if (!error && httpResponse.statusCode != 200) {
                                                              error = [NSError errorWithDomain:StripeDomain
                                                                                          code:STPInvalidRequestError
                                                                                      userInfo:@{NSLocalizedDescriptionKey: @"There was an error connecting to your payment backend."}];
                                                          }
                                                          if (error) {
                                                              completion(STPBackendChargeResultFailure, error);
                                                          } else {
                                                              completion(STPBackendChargeResultSuccess, nil);
                                                          }
                                                      }];
    
    [uploadTask resume];
}

#pragma button tap methods
- (IBAction)onCardTap:(id)sender {
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:nil bundle:nil];
    paymentViewController.amount = [NSDecimalNumber decimalNumberWithString:@"20.00"];
    paymentViewController.backendCharger = self;
    paymentViewController.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)onApplePayTap:(id)sender {
    self.applePaySucceeded = NO;
    self.applePayError = nil;
    
    NSString *merchantId = AppleMerchantId;
    
    PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:merchantId];
    [paymentRequest setRequiredShippingAddressFields:PKAddressFieldNone];
    //    [paymentRequest setRequiredBillingAddressFields:PKAddressFieldPostalAddress];
    //    paymentRequest.shippingMethods = [self.shippingManager defaultShippingMethods];
    paymentRequest.paymentSummaryItems = [self summaryItemsForShippingMethod:paymentRequest.shippingMethods.firstObject];
    if ([Stripe canSubmitPaymentRequest:paymentRequest]) {
        PKPaymentAuthorizationViewController *auth = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        auth.delegate = self;
        if (auth) {
            [self presentViewController:auth animated:YES completion:nil];
        } else {
            NSLog(@"Apple Pay returned a nil PKPaymentAuthorizationViewController - make sure you've configured Apple Pay correctly, as outlined at https://stripe.com/docs/mobile/apple-pay");
        }
    }
}

@end
