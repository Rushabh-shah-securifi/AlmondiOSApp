//
// Created by Matthew Sinclair-Day on 1/14/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIPreferences.h"

#define ACCOUNT_ACTIVATION_NOTIFICATION @"AccountActivicationNotification"
#define PUSH_NOTIFICATION_TOKEN @"PushNotificationToken"
#define PUSH_NOTIFICATION_STATUS @"PushNotificationStatus"
#define DEBUG_PUSH_NOTIFICATION_COUNT @"DEBUGPushNotificationCount"
#define DEBUG_PUSH_NOTIFICATION_DATE @"DEBUGPushNotificationDate"

@implementation SFIPreferences

+ (SFIPreferences *)instance {
    static SFIPreferences *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (void)setLogonAccountNeedsActivationNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:ACCOUNT_ACTIVATION_NOTIFICATION];
}

- (void)dismissLogonAccountActivationNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:ACCOUNT_ACTIVATION_NOTIFICATION];
}

- (BOOL)isLogonAccountAccountNotificationSet {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:ACCOUNT_ACTIVATION_NOTIFICATION];
}


- (void)markPushNotificationRegistration:(NSData *)deviceToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceToken forKey:PUSH_NOTIFICATION_TOKEN];
    [defaults setBool:YES forKey:PUSH_NOTIFICATION_STATUS];
}

- (BOOL)isRegisteredForPushNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:PUSH_NOTIFICATION_STATUS];
}

- (NSData *)pushNotificationDeviceToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_NOTIFICATION_TOKEN];
}

- (void)debugMarkPushNotificationReceived {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger count = [defaults integerForKey:DEBUG_PUSH_NOTIFICATION_COUNT];

    if (count == 0) {
        NSDate *now = [NSDate date];
        [defaults setObject:now forKey:DEBUG_PUSH_NOTIFICATION_DATE];
    }

    [defaults setInteger:(count + 1) forKey:DEBUG_PUSH_NOTIFICATION_COUNT];
}

- (NSInteger)debugPushNotificationReceivedCount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:DEBUG_PUSH_NOTIFICATION_COUNT];
}

- (NSDate *)debugPushNotificationReceivedCountStartDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:DEBUG_PUSH_NOTIFICATION_DATE];
}

- (void)resetDebugPushNotificationReceivedCount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:DEBUG_PUSH_NOTIFICATION_DATE];
    [defaults setInteger:0 forKey:DEBUG_PUSH_NOTIFICATION_COUNT];
}


@end