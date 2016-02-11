//
//  RulesButtonsView.m
//  SecurifiApp
//
//  Created by Masood on 05/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "PreDelayRuleButton.h"

#import "RulesConstants.h"
#import "Colours.h"
#import "SFIColors.h"

@implementation PreDelayRuleButton{
    //delay button
    UILabel *waitText;
    UILabel *noOfSec;
    UILabel *secText;

    UILabel *lblDisplayText;
    UILabel *lblDeviceName;
}

- (id) initWithFrame:(CGRect)frame{
    frame.size.width = rulesButtonsViewWidth;
    frame.size.height = rulesButtonsViewHeight;
    return [super initWithFrame:frame];
}




- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title displayText:(NSString *)displayText delay:(NSString*)delay isDimmer:(BOOL)isDimButton bottomText:(NSString *)bottomText{
    //device name title
    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
    lblDeviceName.text = title;
    lblDeviceName.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:10];
    lblDeviceName.numberOfLines=0;
    lblDeviceName.textAlignment = NSTextAlignmentCenter;
    lblDeviceName.textColor = [SFIColors darkGrayColor];
    [self addSubview:lblDeviceName];
    
    //delaybutton
    delayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, lblDeviceName.frame.size.height, triggerActionBtnWidth,triggerActionBtnWidth)];
    delayButton.backgroundColor = [UIColor colorFromHexString:@"FF9500"];
    [self addSubview:delayButton];
    
    waitText = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.5, triggerActionBtnWidth,10)];
    waitText.text = @"WAIT";
    waitText.textAlignment = NSTextAlignmentCenter;
    [waitText setFont: [lblDeviceName.font fontWithSize: 8]];
    waitText.textColor = [UIColor whiteColor];
    [delayButton addSubview:waitText];
    
    noOfSec = [[UILabel alloc] initWithFrame:CGRectMake(0, 12.5, triggerActionBtnWidth,20)];
    noOfSec.text = delay;
    [noOfSec setFont: [lblDeviceName.font fontWithSize: 18]];
    noOfSec.textAlignment = NSTextAlignmentCenter;
    noOfSec.textColor = [UIColor whiteColor];
    noOfSec.shadowColor = [UIColor whiteColor];
    [delayButton addSubview:noOfSec];
    
    secText = [[UILabel alloc] initWithFrame:CGRectMake(0, 32.5, triggerActionBtnWidth,10)];
    secText.text = @"SEC";
    secText.textAlignment = NSTextAlignmentCenter;
    [secText setFont: [lblDeviceName.font fontWithSize: 8]];
    secText.textColor = [UIColor whiteColor];
    [delayButton addSubview:secText];
    
    actionbutton = [[SwitchButton alloc] initWithFrame:CGRectMake(46, 0, triggerActionBtnWidth,triggerActionBtnWidth)];
    
    [actionbutton setupValues:iconImage topText:@"" bottomText:bottomText isTrigger:NO isDimButton:isDimButton insideText:displayText];
    [self addSubview:actionbutton];
    
    
    //displaytext
    lblDisplayText = [[UILabel alloc] initWithFrame:CGRectMake(0, triggerActionBtnWidth + textHeight + textPadding, self.frame.size.width,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
    lblDisplayText.text = bottomText;
     lblDisplayText.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:fontSize];
    lblDisplayText.numberOfLines=0;
    lblDisplayText.textAlignment = NSTextAlignmentCenter;
    lblDisplayText.textColor = [SFIColors ruleGraycolor];
    [self addSubview:lblDisplayText];
}

- (void)setNewValue:(NSString*)delay{
    noOfSec.text = delay;
}




@end
