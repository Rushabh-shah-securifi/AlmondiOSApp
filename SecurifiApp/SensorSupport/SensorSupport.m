//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SensorSupport.h"
#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"


@interface SensorSupport ()
@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic, strong) IndexValueSupport *valueSupport;
@property(nonatomic, copy) NSString *sensorValue;
@end

@implementation SensorSupport

- (void)resolve:(SFIDeviceType)device index:(SFIDevicePropertyType)type value:(NSString *)value {
    self.valueSupport = nil;
    self.sensorValue = nil;

    SensorIndexSupport *index = [SensorIndexSupport new];

    NSArray *indexes = [index resolve:device index:type];
    for (IndexValueSupport *indexValue in indexes) {
        if ([indexValue matchesData:value]) {
            self.valueSupport = indexValue;
            self.sensorValue = value;
            break;
        }
    }
}

- (UIImage *)notificationImage {
    NSString *const defaultIconName = @"n_default_device";

    if (self.valueSupport == nil) {
        return [UIImage imageNamed:defaultIconName];
    }

    NSString *name = self.valueSupport.iconName;
    if (name.length == 0) {
        name = defaultIconName;
    }

    name = [@"n_" stringByAppendingString:name];
    return [UIImage imageNamed:name];
}

- (NSString *)notificationText {
    if (self.valueSupport == nil) {
        return @"a value has changed";
    }

    NSString *text = [self.valueSupport formatNotificationText:self.sensorValue];
    if (text == nil) {
        return @"a value has changed";
    }

    return text;
}


@end