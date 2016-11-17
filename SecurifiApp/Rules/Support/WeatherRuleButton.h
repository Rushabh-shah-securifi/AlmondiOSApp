//
//  WeatherRuleButton.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 14/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchButton.h"
#import "DimmerButton.h"

@interface WeatherRuleButton : UIView
@property SwitchButton *switchButtonLeft;
@property SwitchButton *switchButtonRight;

@property(nonatomic)SFIButtonSubProperties* subProperties;

//- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title displayText:(NSString *)displayText delay:(NSString*)delay isDimmer:(BOOL)isDimButton bottomText:(NSString *)bottomText;
//- (void)changeBGColor:(BOOL)isTrigger clearColor:(BOOL)clearColor;
//- (void)setNewValue:(NSString*)delay;
//- (void)setupValues:(NSString*)text  Title:(NSString*)title displayText:(NSString*)displayText suffix:(NSString*)suffix;
- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title displayText:(NSString *)displayText isDimmer:(BOOL)isDimButton bottomText:(NSString *)bottomText insideText:(NSString *)insideText isHideCross:(BOOL)ishideCorss;
@end
