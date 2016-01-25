//
//  RuleButton.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "RuleButton.h"
#import "SFIColors.h"

@implementation RuleButton


UIView * bgView;
UIImageView * imgIcon;
UILabel *lblTitle;
UILabel *lblMain;
UILabel *countLable;
UILabel *lblDeviceName;
UILabel *lblDisplayText;

- (void)changeStylewithColor:(BOOL)isTrigger{
    UIColor *selectedColor= isTrigger?[SFIColors ruleBlueColor]:[SFIColors ruleOrangeColor];
    if (!isTrigger || self.selected) {
        lblTitle.textColor = selectedColor;
        bgView.backgroundColor = selectedColor;
    }else{
        lblTitle.textColor = [SFIColors ruleGraycolor];
        bgView.backgroundColor = [SFIColors ruleGraycolor];
    }
}

- (void)changeBGColor:(BOOL)isTrigger clearColor:(BOOL)clearColor{
    UIColor *color= isTrigger?[SFIColors ruleBlueColor]:[SFIColors ruleOrangeColor];
    color = clearColor?[UIColor clearColor]:color;
    lblDisplayText.textColor = color;
    lblDeviceName.textColor = color;
    lblTitle.textColor = color;
    bgView.backgroundColor = color;
}

@end
