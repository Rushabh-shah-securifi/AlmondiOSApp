//
//  SFIAppDelegate.m
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import "SFIAppDelegate.h"
#import "Analytics.h"
#import "Crashlytics.h"
#import "UIApplication+SecurifiNotifications.h"
#import <CrashlyticsLumberjack/CrashlyticsLogger.h>

#define DEFAULT_GA_ID @"UA-52832244-2"
#define DEFAULT_CRASHLYTICS_KEY @"d68e94e89ffba7d497c7d8a49f2a58f45877e7c3"
#define DEFAULT_ASSETS_PREFIX_ID @"Almond"

@implementation SFIAppDelegate

#pragma mark - Public methods; subclasses override

- (SecurifiConfigurator *)toolkitConfigurator {
    SecurifiConfigurator *config = [SecurifiConfigurator new];
//    config.enableScoreboard = YES;                  // uncomment for debug builds
//    config.enableNotificationsDebugLogging = YES;   // uncomment to activate; off by default
//    config.enableCertificateChainValidation = NO;   // uncomment for testing only; on by default
//
    config.enableNotifications = YES;               // uncomment to activate; NO by default
//    config.enableRouterWirelessControl = YES;       // YES by default
    return config;
}

- (NSString *)crashReporterApiKey {
    return DEFAULT_CRASHLYTICS_KEY;
}

- (NSString *)analyticsTrackingId {
    return DEFAULT_GA_ID;
}

- (NSString *)assetsPrefixId {
    return DEFAULT_ASSETS_PREFIX_ID;
}


#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"Application did launch");
    [self initializeSystem:application];

    NSDictionary *remote = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remote) {
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        [toolkit tryRefreshNotifications];
        [application securifiApplicationHandleUserDidTapNotification];
    }

    NSDictionary *local = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (local) {
        [application securifiApplicationHandleUserDidTapNotification];
    }

    return YES;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogError(@"Failed to register for push notifications, error:%@", error);
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DLog(@"Registered for push notifications, device token: %@", deviceToken);
    [application securifiApplicationDidRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler {
    NSLog(@"didReceiveRemoteNotification:fetchCompletionHandler");

    [self initializeSystem:application];

    BOOL handled = [application securifiApplicationHandleRemoteNotification:userInfo];
    enum UIBackgroundFetchResult result = handled? UIBackgroundFetchResultNewData : UIBackgroundFetchResultNoData;
    handler(result);
}
*/

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification");
    [application securifiApplicationHandleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    // this is also called immediately after processing the remote notification when the app is also in the foreground.
    [application securifiApplicationHandleUserDidTapNotification];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    [application securifiApplicationHandleUserDidTapNotification];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [application securifiApplicationHandleUserDidTapNotification];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    BOOL online = [toolkit isCloudOnline];
    NSLog(@"Application becomes active: cloud online=%@", online ? @"YES" : @"NO");

    if (online) {
        // Use the badge count set by APN
        NSInteger badgeNumber = application.applicationIconBadgeNumber;
        [toolkit setNotificationsBadgeCount:badgeNumber];

        // and then fetch new notifications, if any
        [toolkit tryRefreshNotifications];
    }
    else {
        [toolkit initToolkit];
    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[SecurifiToolkit sharedInstance] shutdownToolkit];
}

#pragma mark Initialization and Notification handling

- (void)initializeSystem:(UIApplication *)application {
    if ([SecurifiToolkit isInitialized]) {
        return;
    }

    [Crashlytics startWithAPIKey:[self crashReporterApiKey]];

    SecurifiConfigurator *config = [self toolkitConfigurator];
    [SecurifiToolkit initialize:config];
//    [SecurifiToolkit sharedInstance].useProductionCloud = NO; // uncomment for testing; to force dev cloud by default

#ifdef DEBUG
    NSLog(@"DEBUG compile mode set");
#else
    NSLog(@"RELEASE compile mode set");
#endif
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[CrashlyticsLogger sharedInstance]];

    if (config.enableNotificationsDebugLogging) {
        DDFileLogger *logger = [DDFileLogger new];
        logger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        logger.logFileManager.maximumNumberOfLogFiles = 7;

        NSLog(@"Activating file logger, dir:%@", logger.logFileManager.logsDirectory);
        [DDLog addLogger:logger];
    }

    NSString *trackingId = [self analyticsTrackingId];
    [[Analytics sharedInstance] initialize:trackingId];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

    [application securifiApplicationTryEnableRemoteNotifications];
}

- (void)onMemoryWarning:(id)sender {
    [[Analytics sharedInstance] markMemoryWarning];
}


@end
