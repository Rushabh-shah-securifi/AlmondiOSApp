//
//  RulesButtonsView.m
//  SecurifiApp
//
//  Created by Masood on 05/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "RulesButtonsView.h"

#import "RulesConstants.h"
#import "Colours.h"
#import "SFIColors.h"

@implementation RulesButtonsView{
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

- (void)changeBGColor:(UIColor*)color{
    delayButton.backgroundColor = [UIColor colorFromHexString:@"ffcb7f"]; //ffcb7f
    [actionbutton changeBGColor:color];
    lblDisplayText.textColor = color;
    lblDeviceName.textColor = color;
}

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title displayText:(NSString *)displayText delay:(NSString*)delay{
    //device name title
    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
    lblDeviceName.text = title;
    [lblDeviceName setFont: [lblDeviceName.font fontWithSize: fontSize]];
    lblDeviceName.numberOfLines=0;
    lblDeviceName.textAlignment = NSTextAlignmentCenter;
    lblDeviceName.textColor = [UIColor colorFromHexString:@"757575"];
    [self addSubview:lblDeviceName];
    
    //delaybutton
    delayButton = [[UIButton alloc] initWithFrame:CGRectMake(0, lblDeviceName.frame.size.height, triggerActionBtnWidth,triggerActionBtnWidth)];
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
    
    actionbutton = [[SFITriggersActionsSwitchButton alloc] initWithFrame:CGRectMake(46, 0, triggerActionBtnWidth,triggerActionBtnWidth)];
    NSLog(@"iconimage: %@", iconImage);
    [actionbutton setupValues:iconImage Title:@"" displayText:@""];
//    [actionbutton setButtonCross:NO];
    [self addSubview:actionbutton];
    
    //displaytext
    lblDisplayText = [[UILabel alloc] initWithFrame:CGRectMake(0, triggerActionBtnWidth + textHeight, self.frame.size.width,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
    lblDisplayText.text = displayText;
    [lblDisplayText setFont: [lblDisplayText.font fontWithSize: fontSize]];
    lblDisplayText.numberOfLines=0;
    lblDisplayText.textAlignment = NSTextAlignmentCenter;
    lblDisplayText.textColor = [UIColor colorFromHexString:@"757575"];
    [self addSubview:lblDisplayText];
}

- (void)setNewValue:(NSString*)delay{
    noOfSec.text = delay;
}



@end
