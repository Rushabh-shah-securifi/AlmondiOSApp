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

+ (void)setupUpdateAvailableScreen:(UIView *)bgView viewWidth:(CGFloat)viewWidth;

+ (void)clearSubView:(UIView *)view;

+ (void)clearSubviewsInScrollView:(UIScrollView *)scrollView;
@end
