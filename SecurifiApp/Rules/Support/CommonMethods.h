//
//  CommonMethods.h
//  SecurifiApp
//
//  Created by Masood on 19/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIButtonSubProperties.h"
#import "URIData.h"

@interface CommonMethods : NSObject
+ (BOOL) compareEntry:(BOOL)isSlider matchData:(NSString *)matchData eventType:(NSString *)eventType buttonProperties:(SFIButtonSubProperties *)buttonProperties;

+ (NSString*)getDays:(NSArray*)earlierSelection;

+ (void)clearTopScroll:(UIScrollView *)top middleScroll:(UIScrollView*)middle bottomScroll:(UIScrollView*)bottom;

+ (NSMutableAttributedString *)getAttributeString:(NSString *)header fontSize:(int)fontsize LightFont:(BOOL)lightFontneed;

+ (NSString *)getColorHex:(NSString*)value;

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

+(UIImage *)MultiplyImageByConstantColor:(UIImage*)image andColor:(UIColor *)color;

+ (NSString *)getDimmableHex:(NSString*)value;

+(void)setLableProperties:(UILabel*)label text:(NSString*)text textColor:(UIColor*)textColor fontName:(NSString *)fontName fontSize:(float)size alignment:(NSTextAlignment)alignment;

+(void)setLineSpacing:(UILabel*)label text:(NSString *)text spacing:(int)spacing;

+(void)setButtonProperties:(UIButton*)tapbutton title:(NSString *)title selector:(SEL)selector titleColor:(UIColor*)titleColor;

+(void)addLineSeperator:(UIView*)view yPos:(int)ypos;

+ (UIColor *)colorWithHexString:(NSString *)str_HEX  alpha:(CGFloat)alpha_range;

+ (NSString *) UIColorToHexString:(UIColor *)uiColor;

+ (int )getRGBValueForBlink:(NSString*)hexColor;

#pragma mark help screen methods
+ (NSDictionary*)parseJson:(NSString*)fileNam;

+ (NSDictionary *)getDict:(NSString*)helpItem itemName:(NSString*)itemName;

+ (NSDictionary *)getMeshDict:(NSString *)itemName;
#pragma mark site monitoring methods
+ (NSString *)stringFromWeekday:(NSInteger)weekday;

+(BOOL)isContainWeeKday:(NSString*)search;

+(BOOL)isContainMonth:(NSString*)search;

+(NSArray*)searchLastWeek:(NSArray *)URIs;

+ (BOOL)isNumeric:(NSString *)code;

+(BOOL)checkValidation:(NSString*)search date:(NSString *)date monthname:(NSString *)monthName;

+ (BOOL) isAllDigits:(NSString *)string;

+(NSArray *)searchDate:(NSString*)search fromArr:(NSArray *)URIs;

+(NSArray *)searchToday:(NSArray *)URIs;

+(NSArray *)searchLastHour:(NSArray *)URIs;

+(NSArray *)searchByWeekDay:(NSString*)search fromArr:(NSArray *)URIs;

+(NSArray *)searchByRecent:(NSString*)search fromArr:(NSArray *)URIs;

#pragma mark rgb methods
+ (int )getRGBForHex:(NSString*)hueValue sliderValue:(NSString*)slider;

+(float )getSatValue:(NSString *)value ;

+(float )getHueValue:(NSString *)value;

+(int)getRGBFromHSB:(int)hue saturation:(int)saturation ;

+(NSString *)getShortAlmondName:(NSString*)almondName;

@end
