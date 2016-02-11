//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "ValueFormatter.h"


@implementation ValueFormatter
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        <#statements#>
//    }
//    return self;
//}

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

- (NSString *)scaledValue:(NSString *)value{
    return [NSString stringWithFormat:@"%d", (int)ceil([value intValue]*self.factor)];
}

- (float )factor {
    if (self.scaledMaxValue==0 || self.maxValue==0) {
        return 1;
    }
    return (float)self.scaledMaxValue/self.maxValue;
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