//
//  TriDimBtn.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/05/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RuleButton.h"

@interface TriDimBtn : RuleButton
@property(nonatomic)NSString* prefix;
@property(nonatomic)BOOL pickerVisibility;
@property(nonatomic)NSString* dimValue;
@property(nonatomic)SFIDevicePropertyType valueType;
@property(nonatomic) NSInteger minValue;
@property(nonatomic) NSInteger maxValue;
@property(nonatomic) float factor;
@property(nonatomic) int count;
@property(nonatomic) SFIDevice *device;
@property(nonatomic)UIImageView *crossButtonImage;
@property BOOL isTrigger;
@property BOOL isScene;

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)prefix isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene;

- (void)setupValues:(NSString*)text  Title:(NSString*)title displayText:(NSString*)displayText suffix:(NSString*)prefix;
- (void)setButtonCross:(BOOL)isHidden;
- (NSString *)scaledValue:(NSString*)text;
@end
