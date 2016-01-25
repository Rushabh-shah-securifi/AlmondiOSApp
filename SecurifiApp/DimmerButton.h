//
//  DimmerButtonActiopn.h
//  Tableviewcellpratic
//
//  Created by Securifi-Mac2 on 27/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFIButtonSubProperties.h"
#import "RuleButton.h"
#import "CrossButton.h"

@interface DimmerButton : RuleButton

@property(nonatomic)NSString* prefix;
@property(nonatomic)NSString* dimValue;
@property(nonatomic)SFIButtonSubProperties* subProperties;
@property(nonatomic)SFIDevicePropertyType valueType;
@property(nonatomic) NSInteger minValue;
@property(nonatomic) NSInteger maxValue;
@property(nonatomic) int count;
@property(nonatomic) SFIDevice *device;
@property(nonatomic)UILabel *crossButton;

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)prefix;
- (void)setNewValue:(NSString*)text;



- (void)setupValues:(NSString*)text  Title:(NSString*)title displayText:(NSString*)displayText suffix:(NSString*)prefix;
- (void)changeStyle;
- (void)changeBGColor:(UIColor*)color;
- (void)setButtonCross:(BOOL)isHidden;
@end
/*
 @interface SFITriggersActionsDimmerButton : UIButton
 
 @property(nonatomic)NSString* prefix;
 @property(nonatomic)NSString* dimValue;
 @property(nonatomic)SFIButtonSubProperties* subProperties;
 @property(nonatomic)SFIDevicePropertyType valueType;
 @property(nonatomic)NSInteger minValue;
 @property(nonatomic)NSInteger maxValue;
 @property(nonatomic)CrossButton *crossButton;
 
 - (void)setupValues:(NSString*)text  Title:(NSString*)title displayText:(NSString*)displayText suffix:(NSString*)prefix;
 - (void)changeStyle;
 - (void)setNewValue:(NSString*)text;
 - (void)changeBGColor:(UIColor*)color;
 - (void)setButtonCross:(BOOL)isHidden;
 */
