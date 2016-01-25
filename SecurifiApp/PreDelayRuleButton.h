//
//  RulesButtonsView.h
//  SecurifiApp
//
//  Created by Masood on 05/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SFITriggersActionsSwitchButton.h"
#import "SwitchButton.h"
#import "DimmerButton.h"

@interface PreDelayRuleButton : UIView{
    @public SwitchButton *actionbutton;
    @public UIButton *delayButton;
}

@property(nonatomic)SFIButtonSubProperties* subProperties;
@property(nonatomic)SFIDevicePropertyType valueType; //find out why

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title displayText:(NSString *)displayText delay:(NSString*)delay;
- (void)changeBGColor:(BOOL)isTrigger clearColor:(BOOL)clearColor;
- (void)setNewValue:(NSString*)delay;
@end
