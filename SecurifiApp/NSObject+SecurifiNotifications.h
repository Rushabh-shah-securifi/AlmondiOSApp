//
// Created by Matthew Sinclair-Day on 2/27/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SecurifiNotifications)

- (void)securifiApplicationTryEnableRemoteNotifications:(UIApplication *)application;

- (void)securifiApplicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (BOOL)securifiApplication:(UIApplication *)application handleRemoteNotification:(NSDictionary *)userInfo;

// Called when the user activates the app by tapping on a notification in the device's Notification Center
- (void)securifiApplicationHandleUserDidTapNotification:(UIApplication *)application;

@end