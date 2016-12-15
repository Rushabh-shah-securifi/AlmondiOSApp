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
#import "AlmondManagement.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "PaymentCompleteViewController.h"

typedef void (^STPPaymentAuthorizationStatusCallback)(PKPaymentAuthorizationStatus status);

@interface PaymentTypesViewController () <PaymentViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate>
@property (nonatomic) BOOL applePaySucceeded;
@property (nonatomic) NSError *applePayError;
@property (nonatomic) ShippingManager *shippingManager;
@property (weak, nonatomic) IBOutlet UIButton *applePayButton;
@property (nonatomic) BOOL isCancel;

@property (nonatomic)STPPaymentAuthorizationStatusCallback completionCB;
@end



@implementation PaymentTypesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shippingManager = [[ShippingManager alloc] init];
    self.applePayButton.enabled = [self applePayEnabled];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.isCancel = YES;
    [self initializeNotification];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onSubscribeMeCommandResponse:) name:SUBSCRIBE_ME_NOTIFIER object:nil];
}

- (IBAction)onCrossTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
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

- (IBAction)onApplePayTap:(id)sender {
    NSLog(@"onApplePayTap");
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
/*
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
*/

- (NSArray *)summaryItemsForShippingMethod:(PKShippingMethod *)shippingMethod {
    NSLog(@"summaryItemsForShippingMethod");
    //PKPaymentSummaryItem *shirtItem = [PKPaymentSummaryItem summaryItemWithLabel:@"Cool Subscription" amount:[NSDecimalNumber decimalNumberWithString:@"10.00"]]; //shirtItem.amount
    //    NSDecimalNumber *total = [shirtItem.amount decimalNumberByAdding:shippingMethod.amount];
    NSNumber *number = [NSNumber numberWithInt:(int)[AlmondPlan getPlanAmount:self.selectedPlan]];
    NSDecimalNumber *totAmt = [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    PKPaymentSummaryItem *totalItem = [PKPaymentSummaryItem summaryItemWithLabel:@"" amount:totAmt];
    return @[totalItem];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(STPPaymentAuthorizationStatusCallback)completion {
    
    
    NSLog(@"didAuthorizePayment");
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 NSLog(@"create token with paymentk token: %@, tokenid: %@", token, token.tokenId);
                                                 if (token) {
                                                     [self sendSubscribeMeCommand:token.tokenId];
                                                     self.completionCB = completion;
                                                 }else{
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                 }
                                             }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    NSLog(@"paymentAuthorizationViewControllerDidFinish");
    //the reason i've used thsi delegate block to push controllers is that, after execution of self.completionDB this methods is called with minor delay, which is enought to show tick of apple ui
    if(self.isCancel){
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.applePaySucceeded) {
            [self pushPaymentCompleteController:SubscriptionResponse_Success];
        } else{
            [self pushPaymentCompleteController:SubscriptionResponse_Failed];
        }
        self.applePaySucceeded = NO;
        self.applePayError = nil;
    }];
}

#pragma mark - Custom Credit Card Form
- (IBAction)onCardTap:(id)sender {
    PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:nil bundle:nil];
    NSString *amountStr = [NSString stringWithFormat:@"%zd", [AlmondPlan getPlanAmount:self.selectedPlan]];
    paymentViewController.amount = [NSDecimalNumber decimalNumberWithString:amountStr];
    paymentViewController.backendCharger = self;
    paymentViewController.delegate = self;
    paymentViewController.selectedPlan = self.selectedPlan;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark subscription payload
- (void)sendSubscribeMeCommand:(NSString *)tokenID{
    NSLog(@"sendSubscribeMeCommand");
    NSString *almondMac = [AlmondManagement currentAlmond].almondplusMAC;
    
    NSDictionary *payload = @{
                        @"CommandType": @"SubscribeMe",
                        @"PlanID": [AlmondPlan getPlanID:self.selectedPlan],
                        @"StripeToken": tokenID?:@"",
                        @"Time": @"36",
                        @"AlmondMAC": almondMac?: @""
                        };

    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_SUBSCRIBE_ME];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
}

-(void)onSubscribeMeCommandResponse:(id)sender{
    NSLog(@"onSubscribeMeCommandResponse");
    self.isCancel = NO;
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    BOOL local = [toolkit useLocalNetwork:[AlmondManagement currentAlmond].almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"meshcontroller mesh payload: %@", payload);
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    NSString *cmdType = payload[COMMAND_TYPE];
    //[self hideHUDDelegate];
    
    if(isSuccessful){
        [AlmondPlan updateAlmondPlan:self.selectedPlan epoch:payload[RENEWAL_EPOCH]];
        self.applePaySucceeded = YES;
        self.completionCB(PKPaymentAuthorizationStatusSuccess);
    }else{
        self.completionCB(PKPaymentAuthorizationStatusFailure);
    }
}

- (void)pushPaymentCompleteController:(SubscriptionResponse)type{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
        PaymentCompleteViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PaymentCompleteViewController"];
        viewController.type = type;
        viewController.selectedPlanType = self.selectedPlan;
        //self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    });
}

@end
