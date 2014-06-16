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
@end

@implementation SFIMainViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.dimBackground = YES;

    [self displaySplashImage];

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
                                             selector:@selector(almondListResponseCallback:)
                                                 name:ALMOND_LIST_NOTIFIER
                                               object:nil];

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
                                                 name:kSFIReachabilityChangedNotification
                                               object:nil];

    if (!self.isCloudOnline) {
        self.HUD.labelText = @"Connecting. Please wait!";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LOGIN_NOTIFIER
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


#pragma mark - State management

- (BOOL)isCloudOnline {
    return [[SecurifiToolkit sharedInstance] isCloudOnline];
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

- (void)displaySplashImage {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        self.imgSplash.image = [UIImage imageNamed:@"launch-image-640x1136"];
    }
    else {
        // code for 3.5-inch screen
        self.imgSplash.image = [UIImage imageNamed:@"launch-image-640x960"];
    }
}

- (void)displayNoCloudConnectionImage {
    if (!self.isCloudOnline) {
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
    if (self.isCloudOnline) {
        [self.HUD hide:YES];
        [self.displayNoCloudTimer invalidate];
    }
}

- (void)networkDownNotifier:(id)sender {
    if (!self.isCloudOnline) {
        self.HUD.labelText = @"Network Down";
        [self.HUD hide:YES afterDelay:1];
    }
}

- (void)reachabilityDidChange:(NSNotification *)notification {
}

#pragma mark - Cloud Command : Sender and Receivers

- (void)loginResponseNotifier:(id)sender {
    [SNLog Log:@"In Method Name: %s ", __PRETTY_FUNCTION__];

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    //Always run UI code on main thread from Notification callback

    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });

    //Login failed
    if ([notifier userInfo] == nil) {
        [SNLog Log:@"In Method Name: %s Temppass not found", __PRETTY_FUNCTION__];
    }
    else {
        [SNLog Log:@"In Method Name: %s Received login response", __PRETTY_FUNCTION__];
        LoginResponse *obj = (LoginResponse *) [data valueForKey:@"data"];

        [self.displayNoCloudTimer invalidate];

        if (obj.isSuccessful) {
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
    }
}

- (void)loadAlmondList {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

    AlmondListRequest *almondListCommand = [[AlmondListRequest alloc] init];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = ALMOND_LIST;
    cloudCommand.command = almondListCommand;

    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

- (void)almondListResponseCallback:(id)sender {
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
