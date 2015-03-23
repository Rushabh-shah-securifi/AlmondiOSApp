//
// Created by Matthew Sinclair-Day on 2/27/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "UIApplication+SecurifiNotifications.h"
#import "SFIPreferences.h"
#import "NSData+Conversion.h"
#import "SensorSupport.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSecurifiApplicationDidViewNotifications) name:kApplicationDidViewNotifications object:nil];

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

    SFINotification *notification = [SFINotification parsePayload:userInfo];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    const BOOL debugLogging = toolkit.configuration.enableNotificationsDebugLogging;

    // Check whether the notification matches an almond attached to the account
    //
    NSArray *almonds = toolkit.almondList;

    BOOL matched = false;
    for (SFIAlmondPlus *almond in almonds) {
        if ([almond.almondplusMAC isEqualToString:notification.almondMAC]) {
            matched = true;
            break;
        }
    }

    if (!matched) {
        // drop the notification
        DLog(@"dropping notification: did not match almond:%@, almonds:%@", notification.almondMAC, almonds);
        if (debugLogging) {
            [self securifiDebugLog:notification action:@"almond-nomatch"];
        }
        return NO;
    }

    SensorSupport *sensorSupport = [SensorSupport new];
    [sensorSupport resolveNotification:notification.deviceType index:notification.valueType value:notification.value];

    // Check whether the notification pertains to an index/sensor configured to be ignored
    //
    if (sensorSupport.ignoreNotification) {
        DLog(@"dropping notification: ignore notification is true");
        if (debugLogging) {
            [self securifiDebugLog:notification action:@"ignore-index"];
        }
        return NO;
    }

    if (debugLogging) {
        [notification setDebugDeviceName];
    }

    // Keep track of total received that we will process
    [[SFIPreferences instance] debugMarkPushNotificationReceived];

    // By this point, the notification has been vetted. Now store it and then post a local alert
    //
    BOOL stored = [toolkit storePushNotification:notification];
    if (!stored) {
        ELog(@"dropping notification: failed to store in database");
        if (debugLogging) {
            [self securifiDebugLog:notification action:@"fail-store"];
        }
        return NO;
    }

    // There is an iOS limit on the number of active local notifications. So, we prune the list of notifications
    // to ensure there is room for this new one.

    NSArray *notifications = self.scheduledLocalNotifications;
    DLog(@"scheduled notifications count: %lu", (unsigned long)notifications.count);

    NSString *msg = [NSString stringWithFormat:@"%@%@", notification.deviceName, sensorSupport.notificationText];

    UILocalNotification *notice = [UILocalNotification new];
    notice.hasAction = NO;
    notice.alertBody = msg;
    notice.alertAction = nil;//@"View";

    // remote notification itself will trigger a sound; UILocalNotificationDefaultSoundName;
    // when app is in foreground, the sound will not be heard; to change behavior, set sound conditionally based on applicationState
    //
    // when the app is active, we suppress the sound; when in the background, we add a sound iff one was not specified in
    // the original remote notification (otherwise, two sounds will be played).
    NSString *soundName = nil;
    if (self.applicationState != UIApplicationStateActive) {
        NSDictionary *apps_dict = userInfo[@"aps"];
        soundName = apps_dict[@"sound"];
        if (soundName == nil) {
            soundName = UILocalNotificationDefaultSoundName;
        }
        else {
            // remote notification already will play sound; n.b. remote notification should NOT specify sound, but
            // in case it does (like it is now in our beta testing), we handle it correctly by not adding one to the
            // local notification.
            soundName = nil;
        }
    }
    notice.soundName = soundName;

    NSInteger count = [toolkit countUnviewedNotifications];
    notice.applicationIconBadgeNumber = count;

    DLog(@"notification: posting local notification, count:%li", (long)count);
    [self presentLocalNotificationNow:notice];

    if (debugLogging) {
        [self securifiDebugLog:notification action:@"posted"];
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

    [self setApplicationIconBadgeNumber:0];
}

// update badge count and clear out notifications
- (void)onSecurifiApplicationDidViewNotifications {
    [self securifiApplicationUpdateBadgeCount];
    [self cancelAllLocalNotifications];
}

// set the app's badge icon to the count of 'not viewed' notifications
- (void)securifiApplicationUpdateBadgeCount {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSInteger count = [toolkit countUnviewedNotifications];
    [self setApplicationIconBadgeNumber:count];
}

- (void)securifiDebugLog:(SFINotification *)notification action:(NSString *)action {
    DebugLogger *logger = [DebugLogger sharedInstance];
    [logger logNotification:notification action:action];
}

@end