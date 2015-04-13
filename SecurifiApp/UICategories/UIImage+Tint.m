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
        CGSize size = [self size];
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0); // 0.0 for scale means "scale for device's main screen".

        CGRect rect = CGRectZero;
        rect.size = size;

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

- (UIImage *)replaceColorWith:(UIColor *)color {
    CIImage *ci = [CIImage imageWithCGImage:self.CGImage];

    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"
                                  keysAndValues:kCIInputImageKey, ci, @"inputIntensity", @0.8, nil];

    UIImage *newImage = [UIImage imageWithCIImage:filter.outputImage];

    return newImage;
}

+ (UIImage *)replaceColor:(UIColor *)color inImage:(UIImage *)image withTolerance:(float)tolerance {
    CGImageRef imageRef = [image CGImage];

    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bitmapByteCount = bytesPerRow * height;

    unsigned char *rawData = (unsigned char *) calloc(bitmapByteCount, sizeof(unsigned char));

    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
            bitsPerComponent, bytesPerRow, colorSpace,
            kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);

    CGColorRef cgColor = [color CGColor];
    const CGFloat *components = CGColorGetComponents(cgColor);
    float r = components[0];
    float g = components[1];
    float b = components[2];
    //float a = components[3]; // not needed

    r = r * 255.0;
    g = g * 255.0;
    b = b * 255.0;

    const float redRange[2] = {
            MAX(r - (tolerance / 2.0), 0.0),
            MIN(r + (tolerance / 2.0), 255.0)
    };

    const float greenRange[2] = {
            MAX(g - (tolerance / 2.0), 0.0),
            MIN(g + (tolerance / 2.0), 255.0)
    };

    const float blueRange[2] = {
            MAX(b - (tolerance / 2.0), 0.0),
            MIN(b + (tolerance / 2.0), 255.0)
    };

    int byteIndex = 0;

    while (byteIndex < bitmapByteCount) {
        unsigned char red = rawData[byteIndex];
        unsigned char green = rawData[byteIndex + 1];
        unsigned char blue = rawData[byteIndex + 2];

        if (((red >= redRange[0]) && (red <= redRange[1])) &&
                ((green >= greenRange[0]) && (green <= greenRange[1])) &&
                ((blue >= blueRange[0]) && (blue <= blueRange[1]))) {
            // make the pixel transparent
            //
            rawData[byteIndex] = 0;
            rawData[byteIndex + 1] = 0;
            rawData[byteIndex + 2] = 0;
            rawData[byteIndex + 3] = 0;
        }

        byteIndex += 4;
    }

    UIImage *result = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];

    CGContextRelease(context);
    free(rawData);

    return result;
}

#define COLOR_PART_RED(color)    (((color) >> 16) & 0xff)
#define COLOR_PART_GREEN(color)  (((color) >>  8) & 0xff)
#define COLOR_PART_BLUE(color)   ( (color)        & 0xff)


- (UIImage *)imageByReplacingColor:(uint)color withColor:(uint)newColor {
    return [self imageByReplacingColorsWithMinColor:color maxColor:color withColor:newColor];
}

- (UIImage *)imageByReplacingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor withColor:(uint)newColor {
    return [self imageByReplacingColorsWithMinColor:minColor maxColor:maxColor withColor:newColor andAlpha:1.0f];
}

- (UIImage *)imageByReplacingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor withColor:(uint)newColor andAlpha:(float)alpha {
    CGImageRef imageRef = self.CGImage;
    float width = CGImageGetWidth(imageRef);
    float height = CGImageGetHeight(imageRef);
    CGRect bounds = CGRectMake(0, 0, width, height);
    uint minRed = COLOR_PART_RED(minColor);
    uint minGreen = COLOR_PART_GREEN(minColor);
    uint minBlue = COLOR_PART_BLUE(minColor);
    uint maxRed = COLOR_PART_RED(maxColor);
    uint maxGreen = COLOR_PART_GREEN(maxColor);
    uint maxBlue = COLOR_PART_BLUE(maxColor);
    float newRed = COLOR_PART_RED(newColor) / 255.0f;
    float newGreen = COLOR_PART_GREEN(newColor) / 255.0f;
    float newBlue = COLOR_PART_BLUE(newColor) / 255.0f;

    CGContextRef context = nil;

    if (alpha) {
        context = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
        CGContextSetRGBFillColor(context, newRed, newGreen, newBlue, alpha);
        CGContextFillRect(context, bounds);
    }
    CGFloat maskingColors[6] = {minRed, maxRed, minGreen, maxGreen, minBlue, maxBlue};
    CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(imageRef, maskingColors);
    if (!maskedImageRef) return nil;
    if (alpha) CGContextDrawImage(context, bounds, maskedImageRef);
    CGImageRef newImageRef = (alpha) ? CGBitmapContextCreateImage(context) : maskedImageRef;
    if (context) CGContextRelease(context);
    if (newImageRef != maskedImageRef) CGImageRelease(maskedImageRef);

    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

@end
