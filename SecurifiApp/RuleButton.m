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




- (void)changeBGColor:(BOOL)isTrigger clearColor:(BOOL)selected showTitle:(BOOL)showTitle{
    UIColor *color= isTrigger?[SFIColors ruleBlueColor]:[SFIColors ruleOrangeColor];
    color = !selected?[SFIColors ruleGraycolor]:color;
    
    UIColor *titleColor=showTitle?[SFIColors darkGrayColor]:color;
    UIColor *bottomTextColor=  showTitle?[SFIColors ruleGraycolor]:color;
    
    NSLog(@"changeBG color RuleButtonView isTrigger %d,showTitle:%d,selected %d",isTrigger,showTitle,selected);
    self.topLabel.textColor = titleColor;
    self.bottomLabel.textColor = bottomTextColor;
    self.bgView.backgroundColor = color;
    NSLog(@"bgView.back coolor %@:%@ and bgView %@",self.bgView.backgroundColor,color,self.bgView);
}

@end
