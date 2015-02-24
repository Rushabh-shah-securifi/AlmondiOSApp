//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "ValueFormatter.h"


@implementation ValueFormatter

- (NSString *)formatNotificationValue:(NSString *)sensorValue {
    switch (self.action) {
        case ValueFormatterAction_scale:
            sensorValue = [self scaledValue:sensorValue];
            // pass through
        case ValueFormatterAction_formatString:
            return [self formattedString:sensorValue];
    }
    
    return sensorValue;
}

- (NSString *)scaledValue:(NSString *)value {
    float value_float = value.floatValue;
    float max_value = self.maxValue;
    float scaled_max = self.scaledMaxValue;

    float converted = value_float * (scaled_max / max_value);
    converted = roundf(converted);

    return [NSString stringWithFormat:@"%d", (int) converted];
}

- (NSString *)formattedString:(NSString *)value {
    if (self.notificationText) {
        return [NSString stringWithFormat:@"%@%@.", self.notificationText, value];
    }

    NSString *prefix = self.notificationPrefix;
    if (prefix == nil) {
        return value;
    }

    NSString *suffix = self.suffix;
    if (suffix == nil) {
        suffix = @".";
    }
    else if (![suffix hasSuffix:@"."]) {
        suffix = [suffix stringByAppendingString:@"."];
    }

    return [NSString stringWithFormat:@"%@%@%@", prefix, value, suffix];
}

@end