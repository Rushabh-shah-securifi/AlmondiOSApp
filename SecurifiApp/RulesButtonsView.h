//
//  RulesButtonsView.h
//  SecurifiApp
//
//  Created by Masood on 05/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFITriggersActionsSwitchButton.h"

@interface RulesButtonsView : UIView{
    @public SFITriggersActionsSwitchButton *actionbutton;
    @public UIButton *delayButton;
}

@property(nonatomic)SFIButtonSubProperties* subProperties;
@property(nonatomic)SFIDevicePropertyType valueType; //find out why

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title displayText:(NSString *)displayText delay:(NSString*)delay;
- (void)changeBGColor:(UIColor*)color;
- (void)setNewValue:(NSString*)delay;
@end
