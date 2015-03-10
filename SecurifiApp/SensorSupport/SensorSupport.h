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

// Encapsulates the rules for formatting notification messages for each device/index combination
@interface SensorSupport : NSObject

// Matches the notification data with the underlying index rules
// This method is called first, and then the methods below can be called
- (void)resolveNotification:(SFIDeviceType)device index:(SFIDevicePropertyType)type value:(NSString *)value;

// When YES, the resolved notification should be dropped
- (BOOL)ignoreNotification;

// The image to be shown for the Notification
- (UIImage *)notificationImage;

// The notification alert message
- (NSString *)notificationText;

@end