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

@property(nonatomic)SFIDevicePropertyType valueType;
@property(nonatomic) unsigned int count;
@property(nonatomic) SFIDevice *device;
@property(nonatomic)SFIDeviceType deviceType;
@property(nonatomic)UILabel *crossButton;
@property bool inScroll;
@property BOOL isTrigger;
@property BOOL showTitle;
@property BOOL isScene;
@property(nonatomic)UIImageView *crossButtonImage;
@property(nonatomic)NSString *dimValue;
@property(nonatomic)NSString *prefix;
@property(nonatomic)BOOL isWeather;

- (void)changeImageColor:(UIColor*)color;
- (void)setupValues:(UIImage*)iconImage topText:(NSString*)topText bottomText:(NSString *)bottomText isTrigger:(BOOL)isTrigger isDimButton:(BOOL)isDimButton insideText:(NSString *)insideText isScene:(BOOL)isScene;
- (void)setButtonCross:(BOOL)isHidden;

- (void)setImage:(UIImage*)iconImage replace:(BOOL)replace;
- (void)addBgView:(int)y widthAndHeight:(int)widthAndHeight;
- (void)mainLabel:(NSString *)suffix text:(NSString *)text size:(CGFloat)size;

@end
