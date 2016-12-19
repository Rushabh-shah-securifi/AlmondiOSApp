//
//  SelectedPlanViewController.m
//  SecurifiApp
//
//  Created by Masood on 12/5/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SelectedPlanViewController.h"
#import "PaymentCompleteViewController.h"
#import "PaymentTypesViewController.h"
#import "AlmondPlan.h"
#import "AlmondManagement.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "UIViewController+Securifi.h"

@interface SelectedPlanViewController ()
@property (weak, nonatomic) IBOutlet UILabel *topPlanLbl;
@property (weak, nonatomic) IBOutlet UILabel *selectedPlanAmtLbl;
@property (weak, nonatomic) IBOutlet UITextField *couponTxtFld;
@property (weak, nonatomic) IBOutlet UILabel *discountAmtLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalAmtLbl;
@property (weak, nonatomic) IBOutlet UIButton *paymentBtn;

@end

@implementation SelectedPlanViewController
int mii;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSLog(@"selected plan selectedvc: %d, %@", self.selectedPlan, [AlmondPlan getPlanID:self.selectedPlan]);
    [self initializeUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    mii = arc4random() % 10000;
    [self initializeNotification];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onSubscribeMeCommandResponse:) name:SUBSCRIBE_ME_NOTIFIER object:nil];
}
#pragma mark ui methods
- (void)initializeUI{
    self.topPlanLbl.text = [AlmondPlan getPlanString:self.selectedPlan];
    self.selectedPlanAmtLbl.text = [NSString stringWithFormat:@"$%zd.00", [AlmondPlan getPlanAmount:self.selectedPlan]];
    self.totalAmtLbl.text = [NSString stringWithFormat:@"$%zd.00", [AlmondPlan getPlanAmount:self.selectedPlan]];
    
    if(self.selectedPlan == PlanTypeFree){
        [self.paymentBtn setTitle:@"Start My Trial" forState:UIControlStateNormal];
    }else if([AlmondPlan hasPaidSubscription]){
        [self.paymentBtn setTitle:[NSString stringWithFormat:@"Pay $%zd", [AlmondPlan getPlanAmount:self.selectedPlan]] forState:UIControlStateNormal];
    }
}

#pragma mark button tap methods
- (IBAction)onBackArrowTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (IBAction)onProceedToPaymentTap:(id)sender {
    if([AlmondPlan hasPaidSubscription] || self.selectedPlan == PlanTypeFree){
        //will have to pay from this controller it self
        [self sendSubscribeMeCommand];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PaymentTypesViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"PaymentTypesViewController"];
            NSLog(@"self.seletedplan %d", self.selectedPlan);
            viewController.selectedPlan = self.selectedPlan;
            [self.navigationController pushViewController:viewController animated:YES];
        });
    }
}

- (IBAction)onRedeemTap:(id)sender {
}

#pragma mark commands
- (void)sendSubscribeMeCommand{
    NSLog(@"sendSubscribeMeCommand");
    NSString *almondMac = [AlmondManagement currentAlmond].almondplusMAC;
    NSDictionary *payload;
    if(self.selectedPlan == PlanTypeFree){
        payload = @{
                    @"CommandType": @"SubscribeMe",
                    @"PlanID": @"Free",
                    @"Time": @"30(days)",
                    @"AlmondMAC": almondMac?: @""
                    };
    }
    else{
        payload = @{
                    @"CommandType": @"SubscribeMe",
                    @"PlanID": [AlmondPlan getPlanID:self.selectedPlan],
                    @"AlmondMAC": almondMac?: @""
                    };
    }
    
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
    NSLog(@"subscribe me payload: %@", payload);
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    NSString *cmdType = payload[COMMAND_TYPE];
    //[self hideHUDDelegate];
    
    if(isSuccessful){
        [self showToast:@"Payment Successful!"];
        
        [AlmondPlan updateAlmondPlan:self.selectedPlan epoch:payload[RENEWAL_EPOCH]];
        [self pushPaymentCompleteController:SubscriptionResponse_Success];
    }else{
        [self showToast:@"Sorry! proceedings failed."];
        [self pushPaymentCompleteController:SubscriptionResponse_Failed];
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
