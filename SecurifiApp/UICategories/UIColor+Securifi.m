//
// Created by Matthew Sinclair-Day on 4/20/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Colours/Colours.h>
#import "UIColor+Securifi.h"


// From https://github.com/erica/uicolor-utilities/blob/master/Color/UIColor%2BExpanded.m

@implementation UIColor (Securifi)


static CGFloat cgfmin(CGFloat a, CGFloat b) {
    return (a < b) ? a : b;
}

static CGFloat cgfmax(CGFloat a, CGFloat b) {
    return (a > b) ? a : b;
}

+ (UIColor *)colorWithKelvin:(CGFloat)kelvin {
    if ((kelvin < 1000) || (kelvin > 40000)) {
        NSLog(@"Warning: temperature should range between 1000 and 40000");
    }

    CGFloat temperature = kelvin / 100;

    CGFloat red, green, blue;

    if (temperature <= 66) {
        red = 0xFF;
        green = temperature;
        green = (CGFloat) (99.4708025861 * log(green) - 161.1195681661);
    }
    else {
        red = temperature - 60;
        red = (CGFloat) (329.698727446 * pow(red, -0.1332047592));
        green = temperature - 60;
        green = (CGFloat) (288.1221695283 * pow(green, -0.0755148492));
    }

    if (temperature >= 66) {
        blue = 0xFF;
    }
    else if (temperature <= 19) {
        blue = 0;
    }
    else {
        blue = temperature - 10;
        blue = (CGFloat) (138.5177312231 * log(blue) - 305.0447927307);
    }


    red = cgfmax(red, 0);
    red = cgfmin(red, 0xFF);
    green = cgfmax(green, 0);
    green = cgfmin(green, 0xFF);
    blue = cgfmax(blue, 0);
    blue = cgfmin(blue, 0xFF);

    return [UIColor colorWithRed:red / 255.0f green:green / 255.0f blue:blue / 255.0f alpha:1.0f];
}

+ (UIColor *)securifiRouterTileSlateColor {
    return [UIColor colorFromHexString:@"607d8b"];
}

+ (UIColor *)securifiRouterTileGreenColor {
    return [UIColor colorFromHexString:@"4caf50"];
}

+ (UIColor *)securifiRouterTileBlueColor {
    return [UIColor colorFromHexString:@"2196f3"];
}

+ (UIColor *)securifiRouterTileYellowColor {
    return [UIColor colorFromHexString:@"ff9800"];
}

+ (UIColor *)securifiRouterTileRedColor {
    return [UIColor colorFromHexString:@"f44336"];
}


@end