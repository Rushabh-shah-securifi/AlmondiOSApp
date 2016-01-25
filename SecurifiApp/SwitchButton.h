//
//  SFIRulesActionButton.h
//  Tableviewcellpratic
//
//  Created by Securifi-Mac2 on 24/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFIButtonSubProperties.h"
#import "RuleButton.h"
#import "CrossButton.h"

@interface SwitchButton : RuleButton

@property(nonatomic)SFIButtonSubProperties* subProperties;
@property(nonatomic)SFIDevicePropertyType valueType;
@property(nonatomic) unsigned int count;
@property(nonatomic) SFIDevice *device;
@property(nonatomic)SFIDeviceType deviceType;
@property(nonatomic)UILabel *crossButton;
@property bool inScroll;
@property BOOL isTrigger;

- (void)changeImageColor:(UIColor*)color;
- (void)setupValues:(UIImage*)iconImage topText:(NSString*)topText bottomText:(NSString *)bottomText inUpperScroll:(BOOL)inUpperScroll;
- (void)setButtonCross:(BOOL)isHidden;

@end
