//
//  SFIAppDelegate.m
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import "SFIAppDelegate.h"
#import "SNLog.h"
#import "Analytics.h"
#import "Crashlytics.h"
#import "AlmondPlusConstants.h"

#define DEFAULT_GA_ID @"UA-52832244-2"
#define DEFAULT_CRASHLYTICS_KEY @"d68e94e89ffba7d497c7d8a49f2a58f45877e7c3"

@implementation SFIAppDelegate

#pragma mark - Public methods; subclasses override

- (SecurifiConfigurator *)toolkitConfigurator {
    return [SecurifiConfigurator new];
}

- (NSString *)crashReporterApiKey {
    return DEFAULT_CRASHLYTICS_KEY;
}

- (NSString *)analyticsTrackingId {
    return DEFAULT_GA_ID;
}

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Crashlytics startWithAPIKey:[self crashReporterApiKey]];

    SecurifiConfigurator *config = [self toolkitConfigurator];
    [SecurifiToolkit initialize:config];

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    NSString *trackingId = [self analyticsTrackingId];
    [[Analytics sharedInstance] initialize:trackingId];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

    //TODO: PY121214 - Uncomment later when Push Notification is implemented on cloud
    //Push Notification - START
    /*
    // Let the device know we want to receive push notifications
    //
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];

        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

    NSDictionary *pushDic = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (pushDic != nil) {
        DLog(@"Notification");
    }
    */
    //Push Notification - END

    return YES;
}


//TODO: PY121214 - Uncomment later when Push Notification is implemented on cloud
//Push Notification - START
/*
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogError(@"Method Name: Registration Error %@", error);
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DLog(@"Device token is: %@", deviceToken);
    //PY 181114: Save in preference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:deviceToken forKey:PUSH_NOTIFICATION_TOKEN];
    [defaults setBool:YES forKey:PUSH_NOTIFICATION_STATUS];

}


- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo{
    NSLog(@"didReceiveRemoteNotification");
}
*/
//Push Notification - END

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
    BOOL online = [[SecurifiToolkit sharedInstance] isCloudOnline];

    NSLog(@"Application becomes active: online=%@", online ? @"YES" : @"NO");

    if (!online) {
        [[SecurifiToolkit sharedInstance] initToolkit];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[SecurifiToolkit sharedInstance] shutdownToolkit];
}

- (void)onMemoryWarning:(id)sender {
    [[Analytics sharedInstance] markMemoryWarning];
}

@end
