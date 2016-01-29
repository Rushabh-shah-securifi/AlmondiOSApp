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
@property(nonatomic)BOOL pickerVisibility;
@property(nonatomic)NSString* dimValue;
@property(nonatomic)SFIDevicePropertyType valueType;
@property(nonatomic) NSInteger minValue;
@property(nonatomic) NSInteger maxValue;
@property(nonatomic) int count;
@property(nonatomic) SFIDevice *device;
@property(nonatomic)UIImageView *crossButtonImage;
@property BOOL isTrigger;

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)prefix isTrigger:(BOOL)isTrigger;
- (void)setNewValue:(NSString*)text;

- (void)setupValues:(NSString*)text  Title:(NSString*)title displayText:(NSString*)displayText suffix:(NSString*)prefix;
- (void)setButtonCross:(BOOL)isHidden;
@end

