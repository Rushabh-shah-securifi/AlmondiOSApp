//
//  CommonMethods.h
//  SecurifiApp
//
//  Created by Masood on 19/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIButtonSubProperties.h"
#import "GenericIndexValue.h"

@interface CommonMethods : NSObject

+ (BOOL) compareEntry:(BOOL)isSlider matchData:(NSString *)matchData eventType:(NSString *)eventType buttonProperties:(SFIButtonSubProperties *)buttonProperties;

+ (NSString*)getDays:(NSArray*)earlierSelection;

+ (NSMutableAttributedString *)getAttributeString:(NSString *)header fontSize:(int)fontsize LightFont:(BOOL)lightFontneed;

+ (NSString *)getColorHex:(NSString*)value;

+ (NSString *)getDimmableHex:(NSString*)value;

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

+ (BOOL)isNumeric:(NSString *)code;

+(BOOL)checkValidation:(NSString*)search date:(NSString *)date monthname:(NSString *)monthName;

+ (BOOL) isAllDigits:(NSString *)string;

+(NSString *)hexToString:(NSString*)mac;

#pragma mark rgb methods
+ (int )getRGBForHex:(NSString*)hueValue sliderValue:(NSString*)slider;

+(void)getHSLFromDecimal:(int)decimal h:(float*)h s:(float*)s l:(float*)l;

+(int)getRGBDecimalFromHSL:(float)h s:(float)s l:(float)l;

+(float )getBrightnessValue:(NSString *)value ;

+(float )getHueValue:(NSString *)value;

+(int)getRGBFromHSB:(int)hue saturation:(int)saturation ;

+(NSString *)getShortAlmondName:(NSString*)almondName;


#pragma mark searchPage methods

+(NSString *)getTitleShortName:(NSString *)name;

+(BOOL)isContainCategory:(NSString*)search;

+(NSDictionary *)createSearchDictObj:(NSArray*)allObj search:(NSString *)search;

+(NSString *)getTodayDate;

+(NSString *) getLastWeekDayDate:(NSString *)weekDay;

+(NSString *)getPresentTime24Format;

+(NSString *)getYestardayDate;

+(NSArray *)domainEpocArr:(NSArray *)arr;

+(NSString *)isVulnerable:(NSString *)caseStr;

+(NSString *)type:(NSString *)type;

+(NSAttributedString *)getAttributedString:(NSString *)text subText:(NSString *)subText fontSize:(int)fontSize;

+(NSAttributedString *)getAttributedStringWithAttribute:(NSAttributedString *)attributedText subText:(NSString *)subText fontSize:(int)fontSize;

+(NSAttributedString *)getAttributedString:(NSString *)text1 subText:(NSString *)subText text:(NSString *)text2 fontSize:(int)fontSize;

+(BOOL)isIoTdevice:(NSString *)clientType;

+ (NSString *)getExplanationText:(NSString *)type;

+(NSString *)colorShadesforValue:(int)defaultcolor byValueOfcolor:(NSString *)value;

+ (NSArray *)readableValueWithBytes:(id)bytes;

+ (int)convertToFarenheit:(int)celsius;

+ (int)convertToCelsius:(int)fahrenheit;

+ (void)converCentigrateValue:(GenericIndexValue *)genericIndexValObj;

@end
