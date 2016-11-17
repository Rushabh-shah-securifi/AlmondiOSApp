//
//  WeatherRuleButton.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 14/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "WeatherRuleButton.h"
#import "RulesConstants.h"
#import "Colours.h"
#import "SFIColors.h"
#import "SwitchButton.h"

@implementation WeatherRuleButton
UILabel *lblDisplayText;
UILabel *lblDeviceName;

- (id) initWithFrame:(CGRect)frame{
    frame.size.width = rulesButtonsViewWidth;
    frame.size.height = rulesButtonsViewHeight;
    return [super initWithFrame:frame];
}

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title displayText:(NSString *)displayText isDimmer:(BOOL)isDimButton bottomText:(NSString *)bottomText insideText:(NSString *)insideText isHideCross:(BOOL)ishideCorss
{
    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
    lblDeviceName.text = title;
    lblDeviceName.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:topFontSize];
    lblDeviceName.numberOfLines=0;
    lblDeviceName.textAlignment = NSTextAlignmentCenter;
    lblDeviceName.textColor = [UIColor blackColor];
    [self addSubview:lblDeviceName];

    self.switchButtonLeft = [[SwitchButton alloc] initWithFrame:CGRectMake(0, 0, entryBtnWidth,entryBtnWidth)];
    self.switchButtonLeft.isWeather = YES;
    [self.switchButtonLeft setupValues:iconImage topText:@"" bottomText:bottomText isTrigger:NO isDimButton:NO insideText:displayText isScene:NO];
    
//    [self.switchButtonLeft addBgView:0 widthAndHeight:self.frame.size.width];
    [self addSubview:self.switchButtonLeft];
    
    self.switchButtonRight = [[SwitchButton alloc] initWithFrame:CGRectMake(53, 0, entryBtnWidth,entryBtnWidth)];
    self.switchButtonRight.isWeather = YES;
    [self.switchButtonRight setupValues:iconImage topText:@"" bottomText:bottomText isTrigger:NO isDimButton:YES insideText:insideText isScene:NO];
    [self.switchButtonRight setButtonCross:ishideCorss];
//    [self.switchButtonRight addBgView:0 widthAndHeight:self.frame.size.width];
    [self addSubview:self.switchButtonRight];
    
    //displaytext
    lblDisplayText = [[UILabel alloc] initWithFrame:CGRectMake(0, entryBtnWidth + textHeight + textPadding, self.frame.size.width,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
    lblDisplayText.text = bottomText;
    lblDisplayText.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:fontSize];
    lblDisplayText.numberOfLines=0;
    lblDisplayText.textAlignment = NSTextAlignmentCenter;
    lblDisplayText.textColor = [SFIColors ruleGraycolor];
    [self addSubview:lblDisplayText];

    
    
}
@end
