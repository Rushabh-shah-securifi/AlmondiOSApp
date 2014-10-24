//
//  SFIColors.m
//  ReorderTest
//
//  Created by Priya Yerunkar  on 04/10/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//

#import "SFIColors.h"

@implementation SFIColors

+ (NSArray *)colors {
    return @[
            [[SFIColors alloc] initWithHue:196 saturation:100 brightness:100 colorName:@"blue"],
            [[SFIColors alloc] initWithHue:154 saturation:100 brightness:90 colorName:@"green"],
            [[SFIColors alloc] initWithHue:19 saturation:100 brightness:89 colorName:@"red"],
            [[SFIColors alloc] initWithHue:340 saturation:100 brightness:90 colorName:@"pink"],
            [[SFIColors alloc] initWithHue:284 saturation:100 brightness:85 colorName:@"purple"],
            [[SFIColors alloc] initWithHue:69 saturation:100 brightness:90 colorName:@"lime"],
            [[SFIColors alloc] initWithHue:45 saturation:100 brightness:85 colorName:@"yellow"],
    ];
}

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.hue forKey:@"HUE"];
    [encoder encodeInteger:self.saturation forKey:@"SATURATION"];
    [encoder encodeInteger:self.brightness forKey:@"BRIGHTNESS"];
    [encoder encodeObject:self.colorName forKey:@"NAME"];
    
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


- (id)initWithCoder:(NSCoder *)decoder {
    _hue = [decoder decodeIntForKey:@"HUE"];
    _saturation = [decoder decodeIntForKey:@"SATURATION"];
    _brightness = [decoder decodeIntForKey:@"BRIGHTNESS"];
    _colorName = [decoder decodeObjectForKey:@"NAME"];

    return self;
}

@end
