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
+ (UIColor *)testGrayColor{
    return [UIColor colorFromHexString:@"7E7E7E"];
}

+ (UIColor *)test1GrayColor{
    return [UIColor colorFromHexString:@"979797"];
}
+ (UIColor *)lightGreenColor{
    return [UIColor colorFromHexString:@"a5d7a7"];
}
+ (UIColor *)ruleLightOrangeColor{
    return [UIColor colorFromHexString:@"ffcb7f"];
}

+ (UIColor *)clientInActiveGrayColor{
    return [UIColor lightGrayColor];
}
+ (UIColor *)clientBlockedGrayColor{
    return [UIColor colorFromHexString:@"757575"];
}
+ (UIColor *)clientGreenColor{
    return [UIColor colorFromHexString:@"4caf50"];
}

+ (UIColor *)gridBlockColor{
    return [UIColor colorFromHexString:@"dadadc"];
}

+ (UIColor *)lightBlueColor{
    return [UIColor colorFromHexString:@"03a9f4"];
}

+ (UIColor *)lightOrangeDashColor{
    return [UIColor colorFromHexString:@"ff9800"];
}

+ (UIColor *)lightGrayColor{
    return [UIColor colorFromHexString:@"898C90"];
}

+ (UIColor *)disableGreenColor{
    return [UIColor colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
}

+ (UIColor *)maskColor{
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
}

+ (UIColor *)helpYellowColor{
    return [UIColor colorFromHexString:@"fcd142"];
}

+ (UIColor *)helpOrangeColor{
    return [UIColor colorFromHexString:@"ff9800"];
}

+ (UIColor *)helpGreenColor{
    return [UIColor colorFromHexString:@"Bff2c6"];
}

+ (UIColor *)helpBlueColor{
    return [UIColor colorFromHexString:@"86DAFF"];
}

+ (UIColor *)helpTextDescription{
    return [UIColor colorFromHexString:@"444444"];
}

+ (UIColor *)helpPurpleColor{
    return [UIColor colorFromHexString:@"7b1fa2"];
}

+ (UIColor *)grayShade{
    return [UIColor colorFromHexString:@"444444"];
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
//    int positionIndex = index % 15; //need to remove for 0, 1, 7
//
//    int brightness = 0;
//    if (positionIndex < 7) {
//        brightness = self.brightness - (positionIndex * 10);
//    }
//    else {
//        brightness = (self.brightness - 70) + ((positionIndex - 7) * 10);
//    }
//    NSLog(@"brightnes: %d", brightness);
    
    //
    int positionIndex = index % 10;
    
    int brightness = 0;
    if (positionIndex < 5) {
        brightness = (self.brightness - 20) - (positionIndex * 10);
    }
    else {
        brightness = (self.brightness - 60) + ((positionIndex - 5) * 10);
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

+ (UIColor *)lighterColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                               green:MIN(g + 0.2, 1.0)
                                blue:MIN(b + 0.2, 1.0)
                               alpha:a];
    return nil;
    
}

+ (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}
@end
