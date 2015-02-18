//
// Created by Matthew Sinclair-Day on 1/14/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


// Keeps track of information and state needed by the user interface
@interface SFIPreferences : NSObject

+ (SFIPreferences *)instance;

- (void)setLogonAccountNeedsActivationNotification;

- (void)dismissLogonAccountActivationNotification;

- (BOOL)isLogonAccountAccountNotificationSet;

- (void)markPushNotificationRegistration:(NSData *)deviceToken;

- (BOOL)isRegisteredForPushNotification;

- (NSData *)pushNotificationDeviceToken;

- (void)debugMarkPushNotificationReceived;

- (NSInteger)debugPushNotificationReceivedCount;

- (NSDate *)debugPushNotificationReceivedCountStartDate;

- (void)resetDebugPushNotificationReceivedCount;

@end