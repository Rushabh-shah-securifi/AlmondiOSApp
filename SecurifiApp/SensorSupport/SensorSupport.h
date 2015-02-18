//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*

SensorSupport = {
    1..n SensorIndexSupport = {
        1..n IndexValueSupport = {
            0..1 ValueFormatter
        }
    }
}
 */
@interface SensorSupport : NSObject

- (void)resolve:(SFIDeviceType)device index:(SFIDevicePropertyType)type value:(NSString *)value;

- (UIImage *)notificationImage;

- (NSString *)notificationText;

@end