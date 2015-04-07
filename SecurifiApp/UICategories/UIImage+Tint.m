//
//  UIImage+Tint.m
//  ILColorPickerExample
//
//  Created by Securifi-Mac2 on 30/09/14.
//  Copyright (c) 2014 Interfacelab LLC. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor {
    // It's important to pass in 0.0f to this function to draw the image to the scale of the screen
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

- (UIImage *)imageTintedWithColor:(UIColor *)color {
    if (color) {
        // Construct new image the same size as this one.
        UIImage *image;
        UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
        CGRect rect = CGRectZero;
        rect.size = [self size];

        // tint the image
        [self drawInRect:rect];
        [color set];
        UIRectFillUsingBlendMode(rect, kCGBlendModeScreen);

        // restore alpha channel
        [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0f];

        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return image;
    }

    return self;
}

@end
