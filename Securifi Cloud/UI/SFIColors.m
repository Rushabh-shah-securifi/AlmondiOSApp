//
//  SFIColors.m
//  ReorderTest
//
//  Created by Priya Yerunkar  on 04/10/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//

#import "SFIColors.h"

@implementation SFIColors
@synthesize hue, saturation, brightness;
@synthesize colorName;

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:hue forKey:@"HUE"];
    [encoder encodeInteger:saturation forKey:@"SATURATION"];
    [encoder encodeInteger:brightness forKey:@"BRIGHTNESS"];
    [encoder encodeObject:colorName forKey:@"NAME"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self.hue = [decoder decodeIntegerForKey:@"HUE"];
    self.saturation = [decoder decodeIntegerForKey:@"SATURATION"];
    self.brightness = [decoder decodeIntegerForKey:@"BRIGHTNESS"];
    self.colorName = [decoder decodeObjectForKey:@"NAME"];

    return self;
}

@end
