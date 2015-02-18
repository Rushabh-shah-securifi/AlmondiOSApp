//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SensorSupport.h"
#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"


@interface SensorSupport ()
@property(nonatomic) SFIDeviceType deviceType;
@property(nonatomic, strong) IndexValueSupport *indexValue;
@property(nonatomic, copy) NSString *value;
@end

@implementation SensorSupport

- (void)resolve:(SFIDeviceType)device index:(SFIDevicePropertyType)type value:(NSString *)value {
    self.indexValue = nil;
    self.value = nil;

    SensorIndexSupport *index = [SensorIndexSupport new];

    NSArray *indexes = [index resolve:device index:type];
    for (IndexValueSupport *indexValue in indexes) {
        if ([indexValue matchesData:value]) {
            self.indexValue = indexValue;
            self.value = value;
            break;
        }
    }
}

- (UIImage *)notificationImage {
    if (self.indexValue == nil) {
        return [UIImage imageNamed:@"n_default_device"];
    }

    NSString *name = [@"n_" stringByAppendingString:self.indexValue.iconName];
    return [UIImage imageNamed:name];
}

- (NSString *)notificationText {
    if (self.indexValue == nil) {
        return @"Unknown value";
    }
    return [self.indexValue formatValue:self.value];
}


@end