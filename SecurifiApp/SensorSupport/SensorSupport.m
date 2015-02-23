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
    if (self.valueSupport == nil) {
        return [UIImage imageNamed:@"n_default_device"];
    }

    NSString *name = [@"n_" stringByAppendingString:self.valueSupport.iconName];
    return [UIImage imageNamed:name];
}

- (NSString *)notificationText {
    if (self.valueSupport == nil) {
        return @"a value has changed";
    }
    return [self.valueSupport formatNotificationText:self.sensorValue];
}


@end