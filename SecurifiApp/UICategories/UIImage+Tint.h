//
//  UIImage+Tint.h
//  ILColorPickerExample
//
//  Created by Securifi-Mac2 on 30/09/14.
//  Copyright (c) 2014 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Tint)

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;

- (UIImage *)imageTintedWithColor:(UIColor *)color;

- (UIImage *)replaceColorWith:(UIColor *)color;

- (UIImage *)imageByReplacingColor:(uint)color withColor:(uint)newColor;

@end
