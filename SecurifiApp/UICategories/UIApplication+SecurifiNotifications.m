//
// Created by Matthew Sinclair-Day on 2/27/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "UIApplication+SecurifiNotifications.h"
#import "SFIPreferences.h"
#import "NSData+Conversion.h"
#import "DebugLogger.h"

NSString *const kApplicationDidBecomeActiveOnNotificationTap = @"kApplicationDidBecomeActiveOnNotificationTap";
NSString *const kApplicationDidViewNotifications = @"kApplicationDidViewNotifications";

@implementation UIApplication (SecurifiNotifications)

- (void)securifiApplicationTryEnableRemoteNotifications {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    SecurifiConfigurator *config = toolkit.configuration;
    if (!config.enableNotifications) {
        return;
    }

    // update app badge icon and set up event handling to keep the badge updated as user views notifications
    [self securifiApplicationUpdateBadgeCount];
    //
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onSecurifiApplicationDidViewNotifications) name:kApplicationDidViewNotifications object:nil];
    [center addObserver:self selector:@selector(onSecurifiApplicationNotificationCountChanged:) name:kSFINotificationBadgeCountDidChange object:nil];

    SFIPreferences *preferences = [SFIPreferences instance];
    if (!preferences.isRegisteredForPushNotification) {
        // register with APN and then on callback we register with cloud
        [self securifiApplicationRegisterForNotifications];
        return;
    }

    // register the token with the cloud, if needed. this process will fail fast and silently
    // if the token is already registered
    if (toolkit.isLoggedIn) {
        NSData *deviceToken = [preferences pushNotificationDeviceToken];
        if (deviceToken != nil) {
            NSString *str = deviceToken.hexadecimalString;
            [toolkit asyncRequestRegisterForNotification:str];
        }
    }
}

- (void)securifiApplicationDidRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DLog(@"Registered for push notifications, device token: %@", deviceToken);
    [[SFIPreferences instance] markPushNotificationRegistration:deviceToken];

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    if (toolkit.isLoggedIn) {
        NSString *token_str = deviceToken.hexadecimalString;
        [toolkit asyncRequestRegisterForNotification:token_str];
    }
}

// returns YES if notification can be handled (matches an almond)
// else returns NO
- (BOOL)securifiApplicationHandleRemoteNotification:(NSDictionary *)userInfo {
    DLog(@"notification: %@", userInfo);

    // First, go retrieve new ones
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    NSDictionary *apps_dict = userInfo[@"aps"];
    if (apps_dict) {
        NSNumber *badge = apps_dict[@"badge"];
        if (badge) {
            [toolkit setNotificationsBadgeCount:badge.integerValue];
        }
    }

    [toolkit tryRefreshNotifications];

    const BOOL debugLogging = toolkit.configuration.enableNotificationsDebugLogging;
    if (debugLogging) {
        SFINotification *notification = [SFINotification parseNotificationPayload:userInfo];
        [self securifiDebugLog:notification action:@"apn"];
    }

    return YES;
}

// post a notification when the user taps on a notification outside of the app
// other parts of the UI can trap this notification and present the Notifications view
- (void)securifiApplicationHandleUserDidTapNotification {
    if (self.applicationState == UIApplicationStateInactive) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:kApplicationDidBecomeActiveOnNotificationTap object:nil];
    }
}

// register for local and remote notifications with iOS
- (void)securifiApplicationRegisterForNotifications {
    if ([self respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS 8 Notifications
        enum UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [self registerUserNotificationSettings:settings];
        [self registerForRemoteNotifications];
    }
    else {
        // iOS < 8 Notifications
        enum UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [self registerForRemoteNotificationTypes:types];
    }

    self.applicationIconBadgeNumber = 0;
}

// update badge count and clear out notifications
- (void)onSecurifiApplicationDidViewNotifications {
    [self securifiApplicationUpdateBadgeCount];
}

- (void)onSecurifiApplicationNotificationCountChanged:(id)notification {
    [self securifiApplicationUpdateBadgeCount];
}

// set the app's badge icon to the count of 'not viewed' notifications
- (void)securifiApplicationUpdateBadgeCount {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSInteger count = [toolkit countUnviewedNotifications];
    self.applicationIconBadgeNumber = count;
}

- (void)securifiDebugLog:(SFINotification *)notification action:(NSString *)action {
    DebugLogger *logger = [DebugLogger sharedInstance];
    [logger logNotification:notification action:action];
}

@end