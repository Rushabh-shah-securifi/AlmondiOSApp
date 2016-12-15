//
//  PaymentViewController.m
//
//  Created by Alex MacCaw on 2/14/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import <Stripe/Stripe.h>
#import "ViewController.h"
#import "SFIColors.h"
#import "PaymentViewController.h"
#import "CommonMethods.h"
#import "UIFont+Securifi.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "PaymentCompleteViewController.h"
#import "AlmondManagement.h"

@interface PaymentViewController () <STPPaymentCardTextFieldDelegate>
@property (weak, nonatomic) STPPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) UIButton *payBtn;
@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Payment";
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Setup save button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    // Setup payment view
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    paymentTextField.cursorColor = [UIColor purpleColor];
    self.paymentTextField = paymentTextField;
    [self.view addSubview:paymentTextField];
    
    //add pay button
    NSString *title = [NSString stringWithFormat:@"Pay $%@", self.amount];
    UIButton *payBtn = [UIButton new];
    payBtn.enabled = NO;
    payBtn.alpha = 0.5;
    [CommonMethods setButtonProperties:payBtn title:title titleColor:[UIColor whiteColor] bgColor:[SFIColors paymentColor] font:[UIFont securifiFont:18]];
    [payBtn addTarget:self action:@selector(onPayBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    self.payBtn = payBtn;
    [self.view addSubview:self.payBtn];
    
    // Setup Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator setContentMode:UIViewContentModeCenter];
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat padding = 15;
    CGFloat width = CGRectGetWidth(self.view.frame) - (padding * 2);
    self.paymentTextField.frame = CGRectMake(padding, padding, width, 44);
    
    self.activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y-50);
    
    self.payBtn.frame = CGRectMake(0, CGRectGetMaxY(_paymentTextField.frame) + 20, 120, 40);
    self.payBtn.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, self.payBtn.center.y);
    self.payBtn.layer.cornerRadius = 20;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
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

- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    NSLog(@"paymentCardTextFieldDidChange");
    //self.navigationItem.rightBarButtonItem.enabled = textField.isValid;
    if(textField.isValid){
        _payBtn.enabled = YES;
        _payBtn.alpha = 1.0;
    }else{
        _payBtn.enabled = NO;
        _payBtn.alpha = 0.5;
    }
}

- (void)onPayBtnTap:(UIButton *)btn{
    NSLog(@"on pay btn tap");
    if (![self.paymentTextField isValid]) {
        return;
    }
    
    if (![Stripe defaultPublishableKey]) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Please specify a Stripe Publishable Key in Constants.m"
                                                    }];
        [self.delegate paymentViewController:self didFinish:error];
        return;
    }
    [self.activityIndicator startAnimating];
    
    
    [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.cardParams
                                          completion:^(STPToken *token, NSError *error) {
                                              NSLog(@"inside call back token: %@", token);
                                              if (error) {
                                                  [self pushPaymentCompleteController:SubscriptionResponse_Failed];
                                              }else{
                                                  [self sendSubscribeMeCommand:token.tokenId];
                                              }
                                              
                                          }];
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
        [self pushPaymentCompleteController:SubscriptionResponse_Success];
    }else{
        [self pushPaymentCompleteController:SubscriptionResponse_Failed];
    }
}

- (void)pushPaymentCompleteController:(SubscriptionResponse)type{
    [self.activityIndicator stopAnimating];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
        PaymentCompleteViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PaymentCompleteViewController"];
        viewController.type = type;
        viewController.selectedPlanType = self.selectedPlan;
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    });
}
@end
