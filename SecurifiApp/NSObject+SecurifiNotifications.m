//
// Created by Matthew Sinclair-Day on 2/27/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NSObject+SecurifiNotifications.h"
#import "SFIPreferences.h"
#import "NSData+Conversion.h"
#import "SensorSupport.h"


@implementation NSObject (SecurifiNotifications)

- (void)securifiApplicationTryEnableRemoteNotifications:(UIApplication *)application {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    SecurifiConfigurator *config = toolkit.configuration;
    if (!config.enableNotifications) {
        return;
    }

    SFIPreferences *preferences = [SFIPreferences instance];
    if (!preferences.isRegisteredForPushNotification) {
        // register with APN and then on callback we register with cloud
        [self securifiApplicationRegisterForRemoteNotifications:application];
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
- (BOOL)securifiApplication:(UIApplication *)application handleRemoteNotification:(NSDictionary *)userInfo {
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

    [toolkit storePushNotification:notification];
    [[SFIPreferences instance] debugMarkPushNotificationReceived];

    SensorSupport *sensorSupport = [SensorSupport new];
    [sensorSupport resolve:notification.deviceType index:notification.valueType value:notification.value];

    NSString *msg = [NSString stringWithFormat:@"%@: %@", notification.deviceName, sensorSupport.notificationText];

    UILocalNotification *localNotice = [UILocalNotification new];
    localNotice.alertBody = msg;
    localNotice.soundName = UILocalNotificationDefaultSoundName;

    [application presentLocalNotificationNow:localNotice];

    return YES;
}

- (void)securifiApplicationHandleUserDidTapNotification:(UIApplication *)application {
    if (application.applicationState == UIApplicationStateInactive) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"kApplicationDidBecomeActiveOnNotificationTap" object:nil];
    }
}

- (void)securifiApplicationRegisterForRemoteNotifications:(UIApplication *)application {
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        // iOS 8 Notifications
        enum UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:types categories:nil]];
        [application registerForRemoteNotifications];
    }
    else {
        // iOS < 8 Notifications
        enum UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [application registerForRemoteNotificationTypes:types];
    }
}


@end