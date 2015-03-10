//
// Created by Matthew Sinclair-Day on 2/27/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "UIApplication+SecurifiNotifications.h"
#import "SFIPreferences.h"
#import "NSData+Conversion.h"
#import "SensorSupport.h"

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
    [self updateSecurifiNotificationsCount];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSecurifiNotificationsCount) name:kApplicationDidViewNotifications object:nil];

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
    SFINotification *notification = [SFINotification parsePayload:userInfo];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    BOOL matched = false;
    for (SFIAlmondPlus *almond in toolkit.almondList) {
        if ([almond.almondplusMAC isEqualToString:notification.almondMAC]) {
            matched = true;
            break;
        }
    }

    if (!matched) {
        // drop the notification
        return NO;
    }

    SensorSupport *sensorSupport = [SensorSupport new];
    [sensorSupport resolveNotification:notification.deviceType index:notification.valueType value:notification.value];

    if (sensorSupport.ignoreNotification) {
        // drop the notification
        return NO;
    }

    [toolkit storePushNotification:notification];
    [[SFIPreferences instance] debugMarkPushNotificationReceived];

    NSString *msg = [NSString stringWithFormat:@"%@%@", notification.deviceName, sensorSupport.notificationText];

    UILocalNotification *notice = [UILocalNotification new];
    notice.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.5];
    notice.hasAction = NO;
    notice.alertBody = msg;
    notice.alertAction = nil;//@"View";
    notice.soundName = nil; // remote notification itself will trigger a sound; UILocalNotificationDefaultSoundName;
    notice.applicationIconBadgeNumber = [toolkit countUnviewedNotifications];

    [self scheduleLocalNotification:notice];

    return YES;
}

// post a notification when the user taps on a notification outside of the app
// other parts of the UI can trap this notification and present the Notifications view
- (void)securifiApplicationHandleUserDidTapNotification {
    if (self.applicationState == UIApplicationStateInactive) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:kApplicationDidBecomeActiveOnNotificationTap object:nil];
        [self cancelAllLocalNotifications];
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

    [self setApplicationIconBadgeNumber:0];
}

// set the app's badge icon to the count of 'unviewed' notifications
- (void)updateSecurifiNotificationsCount {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSInteger count = [toolkit countUnviewedNotifications];
    [self setApplicationIconBadgeNumber:count];
}

@end