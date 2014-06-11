//
//  InitialSlidingViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "InitialSlidingViewController.h"
#import "SNLog.h"
#import "AlmondPlusConstants.h"
#import "SFIReachabilityManager.h"
#import "SFIOfflineDataManager.h"
#import "SFIDatabaseUpdateService.h"
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface InitialSlidingViewController ()
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic, readonly, getter=isCloudConnectionBroken) BOOL cloudConnectionBroken;
@property(nonatomic, readonly) NSInteger state;
@end

@implementation InitialSlidingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];

    UIStoryboard *storyboard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    }

    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabTop"];
}

- (void)viewDidAppear:(BOOL)animated {
    //PY 170913 Add observers
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, self.state];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkDownNotifier:)
                                                 name:NETWORK_DOWN_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkUpNotifier:)
                                                 name:NETWORK_UP_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LogoutAllResponseCallback:)
                                                 name:LOGOUT_ALL_NOTIFIER
                                               object:nil];
    [self markCloudConnectionBroken:FALSE];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LoginResponseCallback:)
                                                 name:LOGIN_NOTIFIER
                                               object:nil];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, self.state];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_UP_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_DOWN_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LOGOUT_ALL_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LOGIN_NOTIFIER
                                                  object:nil];


}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - State management

- (void)markConnectionState {
    _state = [[SecurifiToolkit sharedInstance] getConnectionState];
}

- (void)markCloudConnectionBroken:(BOOL)isBroken {
    _cloudConnectionBroken = isBroken;
}

#pragma mark - Event handlers

- (void)networkUpNotifier:(id)sender {
    [SNLog Log:@"Method Name: %s In networkUP notifier", __PRETTY_FUNCTION__];
    [self markConnectionState];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, self.state];

    if (self.state == SDK_UNINITIALIZED) {
        [[SecurifiToolkit sharedInstance] initSDK];
    }
    else if (self.state == NOT_LOGGED_IN) {
        [SNLog Log:@"Method Name: %s Logout Initialiaze SDK", __PRETTY_FUNCTION__];
        [SNLog Log:@"Method Name: %s Display login screen", __PRETTY_FUNCTION__];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
        [self presentViewController:mainView animated:YES completion:nil];
    }
}


- (void)networkDownNotifier:(id)sender {
    [self markConnectionState];

    [SNLog Log:@"Method Name: %s State : %d ", __PRETTY_FUNCTION__, self.state];

    if (self.state == CLOUD_CONNECTION_BROKEN) {
        //Try to login and check
        NSLog(@"Try to reconnect! Cloud ended connection");
        [self markCloudConnectionBroken:TRUE];
        [[SecurifiToolkit sharedInstance] initSDK];
    }
}


- (void)reachabilityDidChange:(NSNotification *)notification {
    //Reachability *reachability = (Reachability *)[notification object];
    if ([[SFIReachabilityManager sharedManager] isReachable]) {
        NSLog(@"Reachable - SLIDE");
        [[SecurifiToolkit sharedInstance] initSDK];
        self.HUD.labelText = @"Reconnecting...";
        [self.HUD hide:YES afterDelay:1];
    }
    else {
        NSLog(@"Unreachable");
    }
}

- (void)LogoutAllResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

    //todo sinclair - this leaks. fix me.
    [SNLog Log:@"Method Name: %s Logout All successful - All connections closed!", __PRETTY_FUNCTION__];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SFIDatabaseUpdateService stopDatabaseUpdateService];
    });

    //PY 170913 - Use navigation controller
    //[self.navigationController popViewControllerAnimated:YES];
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:EMAIL];
    [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
    [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
    [prefs removeObjectForKey:USERID];
    [prefs removeObjectForKey:PASSWORD];
    [prefs removeObjectForKey:COLORCODE];
    [prefs synchronize];

    //Delete files
    [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
    [SFIOfflineDataManager deleteFile:HASH_FILENAME];
    [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
    [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
    [self presentViewController:mainView animated:YES completion:nil];
}

- (void)LoginResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    //Login failed
    if (self.isCloudConnectionBroken) {
        [SNLog Log:@"In Method Name: %s Cloud broken connection response", __PRETTY_FUNCTION__];

        [self markCloudConnectionBroken:FALSE];

        if ([notifier userInfo] == nil) {
            [SNLog Log:@"In Method Name: %s TEMP Pass failed", __PRETTY_FUNCTION__];
            //Logout
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs removeObjectForKey:EMAIL];
            [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
            [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
            [prefs removeObjectForKey:COLORCODE];
            [prefs synchronize];

            //Delete files
            [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
            [SFIOfflineDataManager deleteFile:HASH_FILENAME];
            [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
            [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [SFIDatabaseUpdateService stopDatabaseUpdateService];
            });

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
            [self presentViewController:mainView animated:YES completion:nil];
        }
        else {
            [SNLog Log:@"In Method Name: %s Received login response", __PRETTY_FUNCTION__];

            LoginResponse *obj = (LoginResponse *) [data valueForKey:@"data"];

            //Login unsuccessful
            if (obj.isSuccessful == 0) {
                [SNLog Log:@"In Method Name: %s Logout because of reason: %@ Reason Code: %d ", __PRETTY_FUNCTION__, obj.reason, obj.reasonCode];
                //Logout
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs removeObjectForKey:EMAIL];
                [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
                [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
                [prefs removeObjectForKey:COLORCODE];
                [prefs synchronize];

                //Delete files
                [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
                [SFIOfflineDataManager deleteFile:HASH_FILENAME];
                [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
                [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];

                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
                [self presentViewController:mainView animated:YES completion:nil];
            }
        }
    }
}

@end
