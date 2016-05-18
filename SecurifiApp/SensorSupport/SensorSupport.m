//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SensorSupport.h"
#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface SensorSupport ()
@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic, strong) IndexValueSupport *valueSupport;
@property(nonatomic, copy) NSString *sensorValue;
@end

@implementation SensorSupport

- (void)resolveNotification:(SFIDeviceType)device index:(SFIDevicePropertyType)type value:(NSString *)value {
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

- (BOOL)ignoreNotification {
    return self.valueSupport.notificationIgnoreIndex;
}

- (UIImage *)notificationImage {
    NSString *const defaultIconName = @"n_default_device";

    if (self.valueSupport == nil) {
        return [self imageNamed:defaultIconName];
    }

    NSString *name = self.valueSupport.iconName;
    if (name.length == 0) {
        name = defaultIconName;
    }

//    name = [@"n_" stringByAppendingString:name];
    NSLog(@"image name: %@", name);
    return [self imageNamed:name];
}

- (NSString *)notificationText {
    if (self.valueSupport == nil) {
        return NSLocalizedString(@"sensor support- a value has changed",@" a value has changed");
    }

    NSString *text = [self.valueSupport formatNotificationText:self.sensorValue];
    if (text == nil) {
        return NSLocalizedString(@"sensor support- a value has changed",@" a value has changed");
    }

    return text;
}

- (UIImage *)imageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];

    if (![SensorSupport systemVersionAtLeast8]) {
        // on ios 7.1 the template configuration mode set for each icon in xcode is not honored
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }

    return image;
}

+ (BOOL)systemVersionAtLeast8 {
    static BOOL _systemVersionChecked = NO;
    static BOOL _systemVersionAtLeast8;

    if (!_systemVersionChecked) {
        _systemVersionAtLeast8 = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0");
        _systemVersionChecked = YES;
    }

    return _systemVersionAtLeast8;
}


@end