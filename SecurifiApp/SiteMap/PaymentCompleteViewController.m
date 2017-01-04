//
//  PaymentCompleteViewController.m
//  SecurifiApp
//
//  Created by Masood on 12/5/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "PaymentCompleteViewController.h"
#import "AlmondManagement.h"

@interface PaymentCompleteViewController ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLbl;
@property (weak, nonatomic) IBOutlet UIButton *topBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;

@end

@implementation PaymentCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ui methods
- (void)setupUI{
    NSString *desc;
    NSString *almondName = [AlmondManagement cloudAlmond:self.currentMAC].almondplusName;
    if(self.type == SubscriptionResponse_Success){
        desc = [NSString stringWithFormat:@"You now have access to Internet Security on %@ for %zd month/months", almondName, [AlmondPlan getPlanMonths:self.selectedPlanType]];
        [self setImage:[UIImage imageNamed:@"payment_check_circle"] title:@"Hooray!" desc:desc topHidden:YES btmHidden:NO topTitle:@"" btmTitle:@"Done"];
    }else if(self.type == SubscriptionResponse_Failed){
        desc = [NSString stringWithFormat:@"We were unable to process your payment for IoT Security for %zd Month/Months $%@ Plan.", [AlmondPlan getPlanMonths:self.selectedPlanType], [AlmondPlan getPlanAmount:self.selectedPlanType]];
        [self setImage:[UIImage imageNamed:@"ic_error_outline"] title:@"Payment Error" desc:desc topHidden:NO btmHidden:NO topTitle:@"Try Again" btmTitle:@"Nevermind"];
    }else if(self.type == SubscriptionResponse_Cancelled){
        desc = [NSString stringWithFormat:@"You no longer have access to the IoT Security on %@.", almondName];
        [self setImage:[UIImage imageNamed:@"ic_error_outline"] title:@"Subscription Cancelled" desc:desc topHidden:NO btmHidden:YES topTitle:@"Done" btmTitle:@""];
    }
}

- (void)setImage:(UIImage *)image  title:(NSString *)title desc:(NSString *)desc topHidden:(BOOL)topHide btmHidden:(BOOL)btmHide topTitle:(NSString *)topTitle  btmTitle:(NSString *)btmTitle{
    self.imgView.image = image;
    self.titleLbl.text = title;
    self.descriptionLbl.text = desc;
    self.topBtn.hidden = topHide;
    self.bottomBtn.hidden = btmHide;
    [self.topBtn setTitle:topTitle forState:UIControlStateNormal];
    [self.bottomBtn setTitle:btmTitle forState:UIControlStateNormal];
}

#pragma mark button tap
- (IBAction)onTopButtonTap:(id)sender {
    if(self.type == SubscriptionResponse_Success){
        
    }else if(self.type == SubscriptionResponse_Failed){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if(self.type == SubscriptionResponse_Cancelled){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onButtonTap:(id)sender {
    if(self.type == SubscriptionResponse_Success){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(self.type == SubscriptionResponse_Failed){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(self.type == SubscriptionResponse_Cancelled){
        
    }
}




@end
