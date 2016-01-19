//
//  DimmerButtonActiopn.h
//  Tableviewcellpratic
//
//  Created by Securifi-Mac2 on 27/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFIButtonSubProperties.h"

@interface SFIDimmerButtonAction : UIButton

@property(nonatomic)NSString* prefix;
@property(nonatomic)NSString* dimValue;
@property(nonatomic)SFIButtonSubProperties* subProperties;
@property(nonatomic)SFIDevicePropertyType valueType;
@property(nonatomic) NSInteger minValue;
@property(nonatomic) NSInteger maxValue;
@property(nonatomic) int count;
@property(nonatomic) SFIDevice *device;

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)prefix;
- (void)changeStylewithColor:(UIColor*)color;
- (void)setNewValue:(NSString*)text;
- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden;

@end

