//
//  SFIRulesDimmerButton.h
//  SecurifiApp
//
//  Created by Masood on 12/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SFIButtonSubProperties.h"
#import "SecurifiToolkit/SFIDevice.h"
@interface SFIRulesDimmerButton : UIButton

@property(nonatomic)NSString* prefix;
@property(nonatomic)NSString* dimValue;
@property(nonatomic)SFIButtonSubProperties* subProperties;
@property(nonatomic)SFIDevicePropertyType valueType;
@property(nonatomic) NSInteger minValue;
@property(nonatomic) NSInteger maxValue;
@property(nonatomic) SFIDevice *device;

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)prefix;
- (void)changeStyle;
- (void)setNewValue:(NSString*)text;
- (void)changeBGColor:(UIColor*)color;

@end
