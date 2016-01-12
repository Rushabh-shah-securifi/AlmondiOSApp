//
//  SFISwitchButton.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 09.06.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SFIGenericButton.h"
#import "SFIButtonSubProperties.h"
#import "SecurifiToolkit/SFIDevice.h"
@interface SFIRulesSwitchButton : UIButton


@property(nonatomic)SFIButtonSubProperties* subProperties;
@property(nonatomic)SFIDevicePropertyType valueType;
@property(nonatomic)int count;
@property(nonatomic)id generic;
@property(nonatomic)SFIDevice *device;

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title;
- (void)changeStyle;
- (void)changeBGColor:(UIColor*)color;
- (void)changeImageColor:(UIColor*)color;
@end

