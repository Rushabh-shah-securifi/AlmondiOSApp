//
//  UIFont+Securifi.h
//  Almond
//
//  Created by Securifi-Mac2 on 16/10/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIFont (Securifi)

+ (UIFont*)securifiFont:(CGFloat)fontSize;
+ (UIFont*)securifiBoldFont:(CGFloat)fontSize;
+ (UIFont*)securifiLightFont:(CGFloat)fontSize;

+ (UIFont*)securifiNormalFont;
+ (UIFont*)securifiBoldFont;
+ (UIFont*)securifiLightFont;

+ (UIFont*)securifiBoldFontLarge;
+ (UIFont*)securifiBoldFontSmall;

+ (UIFont*)standardUILabelFont;
+ (UIFont*)standardUITextFieldFont;
+ (UIFont*)standardUIButtonFont;

+ (UIFont*)standardHeadingFont;
+ (UIFont*)standardHeadingBoldFont;
+ (UIFont*)standardNavigationTitleFont;
@end
