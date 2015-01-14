//
// Created by Matthew Sinclair-Day on 1/14/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIPreferences.h"

#define ACCOUNT_ACTIVATION_NOTIFICATION @"AccountActivicationNotification"
#define PUSH_NOTIFICATION_TOKEN @"PushNotificationToken"
#define PUSH_NOTIFICATION_STATUS @"PushNotificationStatus"

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

- (void)removePushNotificationRegistration {

}

- (BOOL)isRegisteredForPushNotification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:PUSH_NOTIFICATION_STATUS];
}

- (NSData *)pushNotificationDeviceToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PUSH_NOTIFICATION_TOKEN];
}


@end