//
//  SFIColors.m
//  ReorderTest
//
//  Created by Priya Yerunkar  on 04/10/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//

#import "SFIColors.h"
#import "Colours.h"

@interface SFIColors ()
@property(nonatomic, readonly) int hue;
@property(nonatomic, readonly) int saturation;
@property(nonatomic, readonly) int brightness;
@property(nonatomic, readonly) NSString *colorName;
@end

@implementation SFIColors

// Returns the standard list of almond colors
+ (NSArray *)colors {
    return @[
            [self blueColor],
            [self greenColor],
            [self redColor],
            [self pinkColor],
            [self purpleColor],
            [self limeColor],
            [self yellowColor],
    ];
}

+ (SFIColors *)colorForIndex:(NSUInteger)colorCode {
    NSArray *colors = [SFIColors colors];

    NSUInteger count = [colors count];
    if (colorCode >= count) {
        colorCode = colorCode % count;
    }

    return colors[colorCode];
}

+ (SFIColors *)blueColor {
    return [[SFIColors alloc] initWithHue:196 saturation:100 brightness:100 colorName:@"blue"];
}

+ (SFIColors *)greenColor {
    return [[SFIColors alloc] initWithHue:154 saturation:100 brightness:90 colorName:@"green"];
}

+ (SFIColors *)redColor {
    return [[SFIColors alloc] initWithHue:19 saturation:100 brightness:89 colorName:@"red"];
}

+ (SFIColors *)pinkColor {
    return [[SFIColors alloc] initWithHue:340 saturation:100 brightness:90 colorName:@"pink"];
}

+ (SFIColors *)purpleColor {
    return [[SFIColors alloc] initWithHue:284 saturation:100 brightness:85 colorName:@"purple"];
}

+ (SFIColors *)limeColor {
    return [[SFIColors alloc] initWithHue:69 saturation:100 brightness:90 colorName:@"lime"];
}

+ (SFIColors *)yellowColor {
    return [[SFIColors alloc] initWithHue:45 saturation:100 brightness:85 colorName:@"yellow"];
}

+ (UIColor*)ruleBlueColor{
    return [UIColor colorFromHexString:@"02a8f3"];
//    return [UIColor colorFromHexString:@"02a8f3"];
}
+ (UIColor *)ruleOrangeColor{
    return  [UIColor colorFromHexString:@"FF9500"];
}
+ (UIColor *)ruleGraycolor{
    return  [UIColor colorFromHexString:@"757575"];
}
+ (UIColor *)ruleLightGrayColor{
    return [UIColor colorFromHexString:@"F7F7F7"];
}

+ (UIColor *)darkGrayColor{
    return [UIColor colorFromHexString:@"212121"];
}

- (instancetype)initWithHue:(int)hue saturation:(int)saturation brightness:(int)brightness colorName:(NSString *)colorName {
    self = [super init];
    if (self) {
        _hue = hue;
        _saturation = saturation;
        _brightness = brightness;
        _colorName = colorName;
    }

    return self;
}

- (UIColor *)makeGradatedColorForPositionIndex:(NSUInteger)index {
    int positionIndex = index % 15;

    int brightness = 0;
    if (positionIndex < 7) {
        brightness = self.brightness - (positionIndex * 10);
    }
    else {
        brightness = (self.brightness - 70) + ((positionIndex - 7) * 10);
    }

    return [self colorWithBrightness:brightness];
}

- (UIColor *)color {
    return [self colorWithBrightness:self.brightness];
}

- (UIColor *)colorWithBrightness:(int)brightness {
    return [UIColor colorWithHue:(CGFloat) (self.hue / 360.0)
                      saturation:(CGFloat) (self.saturation / 100.0)
                      brightness:(CGFloat) (brightness / 100.0)
                           alpha:1];
}

- (id)initWithCoder:(NSCoder *)decoder {
    _hue = [decoder decodeIntForKey:@"HUE"];
    _saturation = [decoder decodeIntForKey:@"SATURATION"];
    _brightness = [decoder decodeIntForKey:@"BRIGHTNESS"];
    _colorName = [decoder decodeObjectForKey:@"NAME"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.hue forKey:@"HUE"];
    [encoder encodeInteger:self.saturation forKey:@"SATURATION"];
    [encoder encodeInteger:self.brightness forKey:@"BRIGHTNESS"];
    [encoder encodeObject:self.colorName forKey:@"NAME"];

}

@end
