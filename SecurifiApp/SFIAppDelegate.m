//
//  SFIAppDelegate.m
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import "SFIAppDelegate.h"
#import "Analytics.h"
#import <Fabric/Fabric.h>
#import "Crashlytics.h"
#import "UIApplication+SecurifiNotifications.h"

#define DEFAULT_GA_ID @"UA-52832244-2"
#define DEFAULT_ASSETS_PREFIX_ID @"Almond"

@implementation SFIAppDelegate

#pragma mark - Public methods; subclasses override

- (SecurifiConfigurator *)toolkitConfigurator {
    SecurifiConfigurator *config = [SecurifiConfigurator new];

    // Debug and testing
//    config.enableScoreboard = YES;                  // uncomment for debug builds
//    config.enableNotificationsDebugMode = YES;      // uncomment to activate; off by default
//    config.enableNotificationsDebugLogging = YES;   // uncomment to activate; off by default
//    config.enableCertificateChainValidation = NO;   // Uncomment for testing only; on by default
//    config.enableSensorTileDebugInfo = YES;         // Uncomment for testing only; off by default

    // Features
    config.enableNotifications = YES;               // uncomment to activate; NO by default
    config.enableNotificationsHomeAwayMode = YES;   // NO by default
    config.enableRouterWirelessControl = YES;       // YES by default
    config.enableLocalNetworking = YES;             // NO by default
    config.enableScenes = YES;                      // NO by default
    config.enableWifiClients = YES;                 // NO by default
//    config.enableAlmondVersionRemoteUpdate = YES;           // NO by default
    return config;
}

- (NSString *)analyticsTrackingId {
    return DEFAULT_GA_ID;
}

- (NSString *)assetsPrefixId {
    return DEFAULT_ASSETS_PREFIX_ID;
}

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.backgroundColor = [UIColor whiteColor];

    return YES;
}

- (void)redirectLogToDocuments
{
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
    NSString *pathForLog = [documentsDirectory stringByAppendingPathComponent:@"yourFile.txt"];
    
    freopen([pathForLog cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

-(void) sendHTTPRequestWithDataAndDeleteLogsContent: (NSString*)data logFilePath:(NSString*)pathForLog {
    
    NSData *postData = [data dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString* url = @"https://almondlogs.securifi.com/ios/debug/logs";
    
    [request setURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (error){
            NSLog(@"Error,%@", [error localizedDescription]);
        }
        else{
            NSLog(@"logs successfully uploaded");
            [[NSFileManager defaultManager] createFileAtPath:pathForLog contents:[NSData data] attributes:nil];
            NSLog(@"the files are deleted");
        }
    }];
}

- (void)sendDataFromLogFilesToCloudandClearInLocal {
    NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [allPaths objectAtIndex:0];
    NSString *pathForLog = [documentsDirectory stringByAppendingPathComponent:@"yourFile.txt"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:pathForLog encoding:NSUTF8StringEncoding error:&error];
    
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    
    // maybe for debugging...
    //NSLog(@"contents: %@", fileContents);
    [self sendHTTPRequestWithDataAndDeleteLogsContent: fileContents  logFilePath:(NSString*)pathForLog];
}

-(void)redirectLogsToNetwork{
    [self redirectLogToDocuments];
    [self sendDataFromLogFilesToCloudandClearInLocal];
}

-(void)sendHTTPRequestAnotherMethod:(NSString*)post{
    dispatch_queue_t sendReqQueue = dispatch_queue_create("send_req", DISPATCH_QUEUE_SERIAL);
    dispatch_async(sendReqQueue,^(){
        
        NSLog(@"post req = %@",post);
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        [request setURL:[NSURL URLWithString:@"http://sitemonitoring.securifi.com:8081"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; [request setTimeoutInterval:20.0];
        [request setHTTPBody:postData];
        NSURLResponse *res= Nil;
        //[NSURLConnection connectionWithRequest:request delegate:self];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:nil];
        if(data == nil)
            return ;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSLog(@"%@ time when this method is called",[DateFormatter stringFromDate:[NSDate date]]);
    [self redirectLogsToNetwork];
    NSLog(@"%@ time when this method is called",[DateFormatter stringFromDate:[NSDate date]]);
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

    BOOL online = [toolkit isNetworkOnline];
    NSLog(@"Application becomes active: cloud online=%@", online ? @"YES" : @"NO");

    if (online) {
        // Use the badge count set by APN
        NSInteger badgeNumber = application.applicationIconBadgeNumber;
        [toolkit setNotificationsBadgeCount:badgeNumber];

        // and then fetch new notifications, if any
        [toolkit tryRefreshNotifications];
    }
    else {
        [toolkit asyncInitNetwork];
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
    [Fabric with:@[CrashlyticsKit]];
    SecurifiConfigurator *config = [self toolkitConfigurator];
    [SecurifiToolkit initialize:config];
    [SecurifiToolkit sharedInstance].useProductionCloud = YES; //TESTMD01 uncomment for testing; to force dev cloud by default

#ifdef DEBUG
    NSLog(@"DEBUG compile mode set");
#else
    NSLog(@"RELEASE compile mode set");
#endif
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//    [DDLog addLogger:[CrashlyticsLogger sharedInstance]];

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
