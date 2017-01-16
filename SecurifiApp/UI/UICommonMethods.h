//
//  UICommonMethods.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 31/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UICommonMethods : NSObject
+ (CGRect)adjustDeviceNameWidth:(NSString*)name fontSize:(int)fontSize maxLength:(int)maxLength;

+(void)setLableProperties:(UILabel*)label text:(NSString*)text textColor:(UIColor*)textColor fontName:(NSString *)fontName fontSize:(float)size alignment:(NSTextAlignment)alignment;

+(void)setLineSpacing:(UILabel*)label text:(NSString *)text spacing:(int)spacing;

+(void)setButtonProperties:(UIButton*)button title:(NSString *)title titleColor:(UIColor*)titleColor bgColor:(UIColor *)bgColor font:(UIFont *)font;

+(void)addLineSeperator:(UIView*)view yPos:(int)ypos;

+(UIImage *)MultiplyImageByConstantColor:(UIImage*)image andColor:(UIColor *)color;

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

+ (void)setupUpdateAvailableScreen:(UIView *)bgView viewWidth:(CGFloat)viewWidth;

+ (void)clearSubView:(UIView *)view;

+ (void)clearTopScroll:(UIScrollView *)top middleScroll:(UIScrollView*)middle bottomScroll:(UIScrollView*)bottom;

+ (void)clearSubviewsInScrollView:(UIScrollView *)scrollView;
@end
