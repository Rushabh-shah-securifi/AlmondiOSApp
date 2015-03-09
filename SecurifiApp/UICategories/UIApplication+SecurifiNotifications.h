//
// Created by Matthew Sinclair-Day on 2/27/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// Notification posted when a user taps on a Notification from the iOS Notification Center
extern NSString *const kApplicationDidBecomeActiveOnNotificationTap;

// Notification that the UI should post on viewing Notifications. This notification is observed
// by this app application.
extern NSString *const kApplicationDidViewNotifications;

// Adds methods for managing registration and handling of push notifications
@interface UIApplication (SecurifiNotifications)

// Called to register for APN and with cloud;
// method will manage process of registering for APN and then registering APN token with the cloud.
// method can be called unconditionally; should be called after a user logs in and at application launch;
- (void)securifiApplicationTryEnableRemoteNotifications;

// Called by the app delegate on notification from iOS that a device token has been registered
- (void)securifiApplicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

// Called by the app delegate when a remote notification is received by the app for processing
- (BOOL)securifiApplicationHandleRemoteNotification:(NSDictionary *)userInfo;

// Called when the user activates the app by tapping on a notification in the device's Notification Center
- (void)securifiApplicationHandleUserDidTapNotification;

@end