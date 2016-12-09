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
@property (weak, nonatomic) IBOutlet UIButton *changePlanBtn;
@property (weak, nonatomic) IBOutlet UIButton *renewPlanBtn;

@end

@implementation MySubscriptionsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    [self addEventsToBtn:self.changePlanBtn];
    [self addEventsToBtn:self.renewPlanBtn];
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


- (void)setSubscriptionTitle:(NSString *)title{
    self.title.text = title;
}
- (IBAction)onChangePlanTap:(UIButton *)btn {
    NSLog(@"onChangePlanTap");
    [self.delegate onChangePlanDelegate];
}
- (IBAction)onRenewPlanTap:(UIButton *)btn {
    [self.delegate onRenewPlanDelegate];
}

@end
