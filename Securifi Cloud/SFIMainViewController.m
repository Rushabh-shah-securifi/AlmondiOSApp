//
//  SFIMainViewController.m
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/30/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIMainViewController.h"
#import "SNLog.h"
#import "AlmondPlusConstants.h"
#import "SFIOfflineDataManager.h"
#import "SFIDatabaseUpdateService.h"
#import "MBProgressHUD.h"

@interface SFIMainViewController ()
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic, readonly) NSTimer *displayNoCloudTimer;
@property(nonatomic, readonly) NSInteger state;
@property(nonatomic, readonly) BOOL isConnectedToCloud;
@end

@implementation SFIMainViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setConnectionState];

    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.dimBackground = YES;

    //self.lblUserEmail.text = @"HELLO!!!";
    //    SNFileLogger *logger = [[SNFileLogger alloc] init];
    //    [[SNLog logManager] addLogStrategy:logger];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, self.state];

    //Set the splash image differently for 3.5 inch and 4 inch screen
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        self.imgSplash.image = [UIImage imageNamed:@"launch-image-640x1136"];
    }
    else {
        // code for 3.5-inch screen
        self.imgSplash.image = [UIImage imageNamed:@"launch-image-640x960"];
    }


    _displayNoCloudTimer = [NSTimer scheduledTimerWithTimeInterval:CLOUD_CONNECTION_TIMEOUT
                                                            target:self
                                                          selector:@selector(displayNoCloudConnectionImage)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponseNotifier:)
                                                 name:LOGIN_NOTIFIER
                                               object:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomesActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AlmondListResponseCallback:)
                                                 name:ALMOND_LIST_NOTIFIER
                                               object:nil];

    //PY 311013 Reconnection Logic
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
                                                 name:kSFIReachabilityChangedNotification object:nil];


    [self setConnectionState];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, self.state];

    if (self.state == NETWORK_DOWN || self.state == SDK_UNINITIALIZED) {
        self.HUD.labelText = @"Connecting. Please wait!";
        [SNLog Log:@"Method Name: %s Initialiaze SDK", __PRETTY_FUNCTION__];
        _state = 5;
        [[SecurifiToolkit sharedInstance] initSDK];

    }
    else if (self.state == LOGGED_IN) {

        //Reload collection view
        [SNLog Log:@"Method Name: %s Display main screen", __PRETTY_FUNCTION__];

    }
    else if (self.state == NOT_LOGGED_IN) {
        [SNLog Log:@"Method Name: %s Logout Initialiaze SDK", __PRETTY_FUNCTION__];
        //Just establish connection


        [[SecurifiToolkit sharedInstance] initSDKCloud];
        [SNLog Log:@"Method Name: %s Display login screen", __PRETTY_FUNCTION__];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, self.state];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LOGIN_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALMOND_LIST_NOTIFIER
                                                  object:nil];

    //PY 311013 Reconnection Logic
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_UP_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_DOWN_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSFIReachabilityChangedNotification
                                                  object:nil];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - State management

- (void)setConnectionState {
    _state = [[SecurifiToolkit sharedInstance] getConnectionState];
}

- (void)markConnectedToCloud:(BOOL)connected {
    _isConnectedToCloud = connected;
}

#pragma mark - Orientation Handling

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Class methods

/*
- (IBAction)LogsButtonHandler:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFILogViewController"];
    [self.navigationController pushViewController:mainView animated:YES];
}
*/

- (void)displayNoCloudConnectionImage {
    if (!self.isConnectedToCloud) {
        //Set the splash image differently for 3.5 inch and 4 inch screen
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            // code for 4-inch screen
            self.imgSplash.image = [UIImage imageNamed:@"no_cloud_640x1136"];
        }
        else {
            // code for 3.5-inch screen
            self.imgSplash.image = [UIImage imageNamed:@"no_cloud_640x960"];
        }
    }
}

#pragma mark - Reconnection

- (void)networkUpNotifier:(id)sender {
    [SNLog Log:@"Method Name: %s MainView controller :In networkUP notifier", __PRETTY_FUNCTION__];
    [self setConnectionState];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, self.state];

    //PY 311013 Reconnection Logic
    if (self.state == SDK_UNINITIALIZED) {
        [[SecurifiToolkit sharedInstance] initSDK];
        [self.HUD hide:YES];
    }
    else if (self.state == NOT_LOGGED_IN) {
        [self markConnectedToCloud:YES];
        [self.displayNoCloudTimer invalidate];
        [SNLog Log:@"Method Name: %s Logout Initialiaze SDK", __PRETTY_FUNCTION__];
        [SNLog Log:@"Method Name: %s Display login screen", __PRETTY_FUNCTION__];
        [self.HUD hide:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
        [self presentViewController:mainView animated:YES completion:nil];
    }
}

void runOnMainQueueWithoutDeadLocking(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void)networkDownNotifier:(id)sender {
    [self setConnectionState];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, self.state];

    if (self.state == SDK_INITIALIZING || self.state == SDK_UNINITIALIZED) {
        [[SecurifiToolkit sharedInstance] initSDK];
    }
    else {
        self.HUD.labelText = @"Network Down";
        [self.HUD hide:YES afterDelay:1];
        [self markConnectedToCloud:NO];
    }
}


- (void)reachabilityDidChange:(NSNotification *)notification {
    //Reachability *reachability = (Reachability *)[notification object];
    [SNLog Log:@"Method Name: %s Reachability State : %d", __PRETTY_FUNCTION__, self.state];
    if (self.state == NETWORK_DOWN || self.state == SDK_UNINITIALIZED) {
        if ([[SFIReachabilityManager sharedManager] isReachable]) {
            NSLog(@"Reachable - MAIN");
            //        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //        HUD.dimBackground = YES;
            //        HUD.labelText=@"Reconnecting...";
            [[SecurifiToolkit sharedInstance] initSDK];
            //        [HUD hide:YES afterDelay:1];
        }
        else {
            NSLog(@"Network Unreachable");
            [self markConnectedToCloud:NO];
        }
    }
}


- (void)becomesActive:(id)sender {
    [self setConnectionState];
    [SNLog Log:@"Method Name: %s BECOME ACTIVE State : %d", __PRETTY_FUNCTION__, self.state];

    //PY 250214 - To remove multiple connection removed -  state == SDK_INITIALIZING
    if (self.state == NETWORK_DOWN || self.state == SDK_UNINITIALIZED) // || state == SDK_INITIALIZING)
    {
        //Start HUD till networkUP/DOWN or Login response notification comes
        [[SecurifiToolkit sharedInstance] initSDK];
    }
}

#pragma mark - Cloud Command : Sender and Receivers

- (void)loginResponseNotifier:(id)sender {
    [SNLog Log:@"In Method Name: %s ", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    //Always run UI code on main thread from Notification callback

    runOnMainQueueWithoutDeadLocking(^{
        [self setConnectionState];
        [self.HUD hide:YES];

        //HUD.labelText=@"Connected to Server";
        //Disable HUD after successful login
        //[HUD hide:YES afterDelay:1];
    });

    //Login failed
    if ([notifier userInfo] == nil) {
        [SNLog Log:@"In Method Name: %s Temppass not found", __PRETTY_FUNCTION__];
//        //PY081113 - Delete personal data
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        [prefs removeObjectForKey:EMAIL];
//        [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
//        [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
//        [prefs removeObjectForKey:USERID];
//        [prefs removeObjectForKey:PASSWORD];
//        [prefs synchronize];
//        
//        //Delete files
//        [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
//        [SFIOfflineDataManager deleteFile:HASH_FILENAME];
//        [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
//        [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
//        [self presentViewController:mainView animated:YES completion:nil];
        //[HUD hide:YES ];
        /*
         state = NOT_LOGGED_IN;
         
         runOnMainQueueWithoutDeadlocking(^{
         HUD.labelText=@"Temppass not found";
         [HUD hide:YES afterDelay:3];
         HUD = nil;
         });
         */
//        if(state == SDK_UNINITIALIZED || state == NETWORK_DOWN){
//            [[SecurifiToolkit sharedInstance] initSDKCloud];
//        }
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
//        [self presentViewController:mainView animated:YES completion:nil];

    }
    else {
        [SNLog Log:@"In Method Name: %s Received login response", __PRETTY_FUNCTION__];
        LoginResponse *obj = (LoginResponse *) [data valueForKey:@"data"];

        //        NSLog(@"UserID %@",obj.userID);
        //        NSLog(@"TempPass %@",obj.tempPass);
        //        NSLog(@"isSuccessful : %d",obj.isSuccessful);
        //        NSLog(@"Reason : %@",obj.reason);

        [self markConnectedToCloud:YES];
        [self.displayNoCloudTimer invalidate];

        if (obj.isSuccessful == 1) {
            [SNLog Log:@"Method Name: %s Login Successful -- Load different view", __PRETTY_FUNCTION__];

            //Almond List
            self.HUD.labelText = @"Loading your personal data.";

            //Start update service
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [SFIDatabaseUpdateService stopDatabaseUpdateService];
                [SFIDatabaseUpdateService startDatabaseUpdateService];
            });

            //Retrieve Almond List, Device List and Device Value - Before displaying the screen
            [self loadAlmondList];

        }
        else {
            //PY081113 - Delete personal data
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
    }

    //Reload to reflect current view

}

- (void)loadAlmondList {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];

    AlmondListRequest *almondListCommand = [[AlmondListRequest alloc] init];

    cloudCommand.commandType = ALMOND_LIST;
    cloudCommand.command = almondListCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- Almond List Command", __PRETTY_FUNCTION__];

        NSError *error = nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];

        if (ret == nil) {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__, [error localizedDescription]];

        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- Almond List Command", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__, exception.reason];
    }
}

- (void)AlmondListResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %s Received Almond List response", __PRETTY_FUNCTION__];

        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];
        [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__, [obj.almondPlusMACList count]];
        //Write Almond List offline
        [SFIOfflineDataManager writeAlmondList:obj.almondPlusMACList];


    }
    self.HUD.hidden = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"InitialSlide"];
    [self presentViewController:mainView
                       animated:YES
                     completion:nil];
}


@end
