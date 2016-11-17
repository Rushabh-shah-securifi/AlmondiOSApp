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

@protocol DimmerButtonDelegate
-(void)setSelectedCondition:(SFIButtonSubProperties*)subProperty;
@end

@interface DimmerButton : RuleButton
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
@property (nonatomic)id<DimmerButtonDelegate> delegate;

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)prefix isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene;

- (void)setupValues:(NSString*)text  Title:(NSString*)title displayText:(NSString*)displayText suffix:(NSString*)prefix;
- (void)setButtonCross:(BOOL)isHidden;
-(void)setUpTextField:(NSString*)textFieldText displayText:(NSString*)displayText suffix:(NSString *)suffix isScene:(BOOL)isScene isTrigger:(BOOL)isTrigger;
- (NSString *)scaledValue:(NSString*)text;
@end

