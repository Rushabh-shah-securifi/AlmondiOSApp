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
#import "SFILoginViewController.h"


@interface SFIAppDelegate () <SFILoginViewDelegate>

@property BOOL presentingLoginController;

@end

@implementation SFIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SFIReachabilityManager sharedManager];

    [self initializeColors];
    [BugSenseController sharedControllerWithBugSenseAPIKey:@"ccf42e26"];


/*
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(onLoginResponse:)
                   name:LOGIN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onLogoutResponse:)
                   name:LOGOUT_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onLogoutAllResponse:)
                   name:LOGOUT_ALL_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onAlmondListResponse:)
                   name:ALMOND_LIST_NOTIFIER
                 object:nil];
*/

    return YES;
}

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
        [[SecurifiToolkit sharedInstance] initSDK];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Login and Logout handling

- (void)onLogoutResponse:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSNotification *notifier = (NSNotification *) sender;
    if ([notifier userInfo] == nil) {
        [self presentLogonScreen];
        return;
    }

    NSDictionary *data = [notifier userInfo];
    LogoutResponse *obj = (LogoutResponse *) [data valueForKey:@"data"];
    if (obj.isSuccessful) {
        [self presentLogonScreen];
    }
}

- (void)onLogoutAllResponse:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    NSNotification *notifier = (NSNotification *) sender;
    if ([notifier userInfo] == nil) {
        [self presentLogonScreen];
        return;
    }
    
    NSDictionary *data = [notifier userInfo];
    LogoutAllResponse *obj = (LogoutAllResponse *) [data valueForKey:@"data"];
    if (obj.isSuccessful) {
        [self presentLogonScreen];
    }
}

- (void)onLoginResponse:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSNotification *notifier = (NSNotification *) sender;
    if ([notifier userInfo] == nil) {
        [self presentLogonScreen];
        return;
    }

    NSDictionary *data = [notifier userInfo];
    LoginResponse *obj = (LoginResponse *) [data valueForKey:@"data"];

    //Login unsuccessful
    if (!obj.isSuccessful) {
        [self presentLogonScreen];
    }
}

- (void)onAlmondListResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];

        //Write Almond List offline
        [SFIOfflineDataManager writeAlmondList:obj.almondPlusMACList];
    }

    UIViewController *ctrl = self.window.rootViewController;
    if (ctrl.presentedViewController) {
        [ctrl.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self presentMainView];
        }];
    }
    else {
        [self presentMainView];
    }
}

- (void)presentLogonScreen {
    if (self.presentingLoginController) {
        return;
    }
    self.presentingLoginController = YES;
    NSLog(@"%s: Presenting logon controller", __PRETTY_FUNCTION__);

    // Present login screen
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    SFILoginViewController *loginCtrl = [storyboard instantiateViewControllerWithIdentifier:@"SFILoginViewController"];
    loginCtrl.delegate = self;

    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginCtrl];

    UIViewController *ctrl = self.window.rootViewController;
    if (ctrl.presentedViewController) {
        [ctrl.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [ctrl presentViewController:navCtrl animated:YES completion:nil];
        }];
    }
    else {
        [ctrl presentViewController:navCtrl animated:YES completion:nil];
    }
}

- (void)loginControllerDidCompleteLogin:(SFILoginViewController *)loginCtrl {
    UIViewController *ctrl = self.window.rootViewController;
    [ctrl.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [self presentMainView];
        self.presentingLoginController = NO;
    }];
}

- (void)presentMainView {
    NSLog(@"%s: Presenting main view", __PRETTY_FUNCTION__);

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"InitialSlide"];

    UIViewController *ctrl = self.window.rootViewController;
    [ctrl presentViewController:mainView animated:YES completion:nil];
}

#pragma mark - Set up

//todo push this all into SFIColors
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

@end
