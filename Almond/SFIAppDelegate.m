//
//  SFIAppDelegate.m
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import "SFIAppDelegate.h"
#import "SNLog.h"
#import "SFIColors.h"
#import "Analytics.h"


@implementation SFIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//#ifdef DEBUG
//    [BugSenseController sharedControllerWithBugSenseAPIKey:@"172e1935"];
//#else
//    [BugSenseController sharedControllerWithBugSenseAPIKey:@"a9525243"];
//#endif

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [[Analytics sharedInstance] initialize];

    [self initializeColors];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

    return YES;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogError(@"Method Name: Registration Error %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

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

#pragma mark - Set up

//todo push this all into SFIColors
- (void)initializeColors {
    NSMutableArray *listAvailableColors = [[NSMutableArray alloc] init];
    SFIColors *colorBlue = [[SFIColors alloc] init];
    colorBlue.hue = 196;
    colorBlue.saturation = 100;
    colorBlue.brightness = 100;
    colorBlue.colorName = @"blue";
    [listAvailableColors addObject:colorBlue];

    SFIColors *colorGreen = [[SFIColors alloc] init];
    colorGreen.hue = 154;
    colorGreen.saturation = 100;
    colorGreen.brightness = 90;
    colorGreen.colorName = @"green";
    [listAvailableColors addObject:colorGreen];

    SFIColors *colorRed = [[SFIColors alloc] init];
    colorRed.hue = 19;
    colorRed.saturation = 100;
    colorRed.brightness = 89;
    colorRed.colorName = @"red";
    [listAvailableColors addObject:colorRed];

    SFIColors *colorPink = [[SFIColors alloc] init];
    colorPink.hue = 340;
    colorPink.saturation = 100;
    colorPink.brightness = 90;
    colorPink.colorName = @"pink";
    [listAvailableColors addObject:colorPink];

    SFIColors *colorPurple = [[SFIColors alloc] init];
    colorPurple.hue = 284;
    colorPurple.saturation = 100;
    colorPurple.brightness = 85;
    colorPurple.colorName = @"purple";
    [listAvailableColors addObject:colorPurple];

    SFIColors *colorLime = [[SFIColors alloc] init];
    colorLime.hue = 69;
    colorLime.saturation = 100;
    colorLime.brightness = 90;
    colorLime.colorName = @"lime";
    [listAvailableColors addObject:colorLime];

    SFIColors *colorYellow = [[SFIColors alloc] init];
    colorYellow.hue = 45;
    colorYellow.saturation = 100;
    colorYellow.brightness = 85;
    colorYellow.colorName = @"yellow";
    [listAvailableColors addObject:colorYellow];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];
    [NSKeyedArchiver archiveRootObject:listAvailableColors toFile:filePath];
}

@end
