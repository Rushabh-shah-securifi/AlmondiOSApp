//
//  MySubscriptionsTableViewCell.m
//  SecurifiApp
//
//  Created by Masood on 12/5/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MySubscriptionsTableViewCell.h"
#import "SFIColors.h"

@interface MySubscriptionsTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImgView;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIView *rightBtnView;
@property (weak, nonatomic) IBOutlet UILabel *leftLbl;
@property (weak, nonatomic) IBOutlet UILabel *rightLbl;

@end

@implementation MySubscriptionsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    [self addEventsToBtn:self.leftBtn];
    [self addEventsToBtn:self.rightBtn];
    // Initialization code
}

- (void)addEventsToBtn:(UIButton *)btn{
    [btn addTarget:self action:@selector(changeButtonBackGroundColor:) forControlEvents:UIControlEventTouchDown];
    [btn addTarget:self action:@selector(resetButtonBackGroundColor:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
}

- (void)changeButtonBackGroundColor:(UIButton *)btn{
    NSLog(@"changeButtonBackGroundColor");
    [UIView animateKeyframesWithDuration:0.1 delay:0.0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        [btn setTitleColor:[SFIColors paymentColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor whiteColor]];

    } completion:nil];
    
}

- (void)resetButtonBackGroundColor:(UIButton *)btn{
    NSLog(@"resetButtonBackGroundColor");
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[SFIColors paymentColor]];
    } completion:nil];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"layoutSubviews");
}


- (void)setSubscriptionTitle:(NSString *)title isExpanded:(BOOL)isExpanded{
    self.title.text = title;
    if(isExpanded){
        self.arrowImgView.image = [UIImage imageNamed:@"up_arrow"];
        self.arrowImgView.alpha = 1;
    }else{
        self.arrowImgView.image = [UIImage imageNamed:@"down_arrow"];
        self.arrowImgView.alpha = 0.4;
    }
}

-(void)setUpCell:(NSDictionary *)featureDict almondPlan:(AlmondPlan *)plan{
    /******** top cell *******/
    self.title.text = featureDict[TITLE];
    self.subTitle.text = [self getSubTitleText:plan];
    if([featureDict[IS_EXPANDED] boolValue]){
        self.arrowImgView.image = [UIImage imageNamed:@"up_arrow"];
        self.arrowImgView.alpha = 1;
    }else{
        self.arrowImgView.image = [UIImage imageNamed:@"down_arrow"];
        self.arrowImgView.alpha = 0.4;
    }
    
    /******* bottom cell ******/
    //label
    if(plan.planType == PlanTypeNone){
        [self setLabel:@"" label2:@"" hidden1:YES hidden2:YES];
    }else if(plan.planType == PlanTypeFreeExpired){
        [self setLabel:@"" label2:@"" hidden1:YES hidden2:YES];
    }else{
        [self setLabel:@"Current Plan" label2:[AlmondPlan getPlanString:plan.planType] hidden1:NO hidden2:NO];
    }
    
    //button
    if(plan.planType == PlanTypeNone){
        [self setButtonTitle:CHOOSE_PLAN title2:FREE_TRAIL hidded:NO];
    }else if(plan.planType == PlanTypeFreeExpired){
        [self setButtonTitle:CHOOSE_PLAN title2:@"" hidded:YES];
    }else{
        [self setButtonTitle:CHANGE_PLAN title2:CANCEL_SUBSCRIPTION hidded:NO];
    }
}

- (NSString *)getSubTitleText:(AlmondPlan *)plan{
    if(plan.planType == PlanTypeNone){
        return @"FREE TRAIL AVAILABLE";
    }else if(plan.planType == PlanTypeFreeExpired){
        return @"SUBSCRIBE TO PLAN";
    }else if(plan.planType == PlanTypeFree){
        return [NSString stringWithFormat:@"Free Trail Expires On %@", plan.renewalDate];
    }else{
        return [NSString stringWithFormat:@"Next Auto Renewal On %@", plan.renewalDate];
    }
}

- (void)setButtonTitle:(NSString *)title1 title2:(NSString *)title2 hidded:(BOOL)isHidden{
    [_leftBtn setTitle:title1 forState:UIControlStateNormal];
    [_rightBtn setTitle:title2 forState:UIControlStateNormal];
    _rightBtnView.hidden = isHidden;
}

- (void)setLabel:(NSString *)text1 label2:(NSString *)text2 hidden1:(BOOL)hidden1 hidden2:(BOOL)hidden2{
    _leftLbl.text = text1;
    _leftLbl.hidden = hidden1;
    _rightLbl.text = text2;
    _rightLbl.hidden = hidden2;
}

- (IBAction)onLeftBtnTap:(UIButton *)btn {
    NSLog(@"onChangePlanTap");
    [self.delegate onLeftBtnTapDelegate:btn.titleLabel.text];
}
- (IBAction)onRightBtnTap:(UIButton *)btn {
    [self.delegate onRightBtnTapDelegate:btn.titleLabel.text];
}

@end
