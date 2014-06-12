//
//  SFIAppDelegate.m
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import "SFIAppDelegate.h"
#import <BugSense-iOS/BugSenseController.h>
#import "SNLog.h"
#import "SFIColors.h"
#import "AlmondPlusConstants.h"


@implementation SFIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //PY 291013 - Reconnection Initialize Reachability
    [SFIReachabilityManager sharedManager];

    [self initializeColors];
    [BugSenseController sharedControllerWithBugSenseAPIKey:@"ccf42e26"];

    return YES;
}


//PY : Initialize the colors to be used in the application
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
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];
    [NSKeyedArchiver archiveRootObject:listAvailableColors toFile:filePath];
}

/*
- (void)networkUP:(id)sender
{
    [SNLog Log:@"Method Name: %s NetworkUP Notification", __PRETTY_FUNCTION__];
}
*/

/*
- (void)connectCloud
{
    id ret=nil;
    unsigned int i=1;

    while (ret == nil && i<10)
    {
        NSLog(@"From Thread");
        [[SecurifiToolkit sharedInstance] initSDK];
*/
/*
        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s SDKInit Error", __PRETTY_FUNCTION__];

        }
*//*

        [SNLog Log:@"Method Name: %s Sleeping for %d seconds", __PRETTY_FUNCTION__,i];
        sleep(i);
        i+=1;
    }
}
*/

/*
- (void)networkDOWN:(id)sender
{
    [SNLog Log:@"Method Name: %s NetworkUP Notification", __PRETTY_FUNCTION__];
    //NSLog(@"Trying to reconnect by spawning thread");
    
    //const char* className = class_getName([self class]);
    //NSLog(@"yourObject is a: %s", className);

    //Should be handled from SDK
    //[NSThread detachNewThreadSelector:@selector(connectCloud) toTarget:self withObject:nil];
}
*/


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [SNLog Log:@"Method Name: %s Registration Error %@", __PRETTY_FUNCTION__, error];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    NSString *deviceId = [NSString stringWithFormat:@"%@",deviceToken];
//   // NSLog(deviceId);
//    //Register Token to cloud
//    
//    NSString *post =[[NSString alloc] initWithFormat:@"token=%@",deviceId];
//    //NSLog(@"PostData: %@",post);
//    
//    NSURL *url=[NSURL URLWithString:@"https://ec2-54-226-236-86.compute-1.amazonaws.com/jijisr343j3994k/token"];
//    
//    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    
//    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
//    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:url];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:postData];
//    
//    [request setTimeoutInterval:5];

    //SFIWebService *request_obj = [[SFIWebService alloc] init];
    //[request_obj initWithURL:request andDelegate:self];

    //Disable Notifiaction

    //Json *myJsonParser = [[Json alloc] init];
    //[myJsonParser startLoadingObjectWithMutableUrl:request andDelegate:self];
}

- (void)didFailWithError:(id)error {
    //Hide Hud and show error message
    //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    //Nirav -- debug
    //NSLog(@" Nirav :Connection failed! Error - %@ %@",
    //           [error localizedDescription],
    //           [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    //[error localizedFailureReason];
    //NSString *errorCode = [NSString stringWithFormat:@"%@:%d",@"Error Code" ,[error code]];
    //[self alertStatus:[error localizedDescription]:errorCode];
}

//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    //UIApplicationState state = [application applicationState];
//    //if (state == UIApplicationStateActive) {
//        NSString *cancelTitle = @"Close";
//      //  NSString *showTitle = @"Show";
//        NSString *message = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Securifi Cloud"
//                                                            message:message
//                                                           delegate:self
//                                                  cancelButtonTitle:cancelTitle
//                                                  otherButtonTitles:nil, nil];
//        [alertView show];
//      //  } else {
//        //Do stuff that you would do if the application was not active
//   // }
//}


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
    NSInteger state = [[SecurifiToolkit sharedInstance] getConnectionState];
    NSLog(@"Application becomes active: state %d", state);

    if (state == NETWORK_DOWN || state == SDK_UNINITIALIZED) {
        [[SecurifiToolkit sharedInstance] initSDK];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
