//
//  SFITriggersActionsSwitchButton.h
//  Tableviewcellpratic
//
//  Created by Masood on 27/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SFIGenericButton.h"
#import "SFIButtonSubProperties.h"
#import "CrossButton.h"

@interface SFITriggersActionsSwitchButton : UIButton


@property(nonatomic)SFIButtonSubProperties* subProperties;
@property(nonatomic)SFIDevicePropertyType valueType;
@property(nonatomic)CrossButton *crossButton;
@property(nonatomic)int count;

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title displayText:(NSString*)displayText;
- (void)changeStyle;
- (void)changeBGColor:(UIColor*)color;
- (void)changeImageColor:(UIColor*)color;
- (void)setButtonCross:(BOOL)isHidden;

@end
