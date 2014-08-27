//
//  SFIMainViewController.m
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/30/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIMainViewController.h"
#import "AlmondPlusConstants.h"
#import "MBProgressHUD.h"
#import "SFILoginViewController.h"
#import "SFILogoutAllViewController.h"
#import "SWRevealViewController.h"
#import "SFIRouterTableViewController.h"
#import "SFISensorsViewController.h"
#import "DrawerViewController.h"

@interface SFIMainViewController () <SFILoginViewDelegate, SFILogoutAllDelegate, UIGestureRecognizerDelegate>
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic, readonly) NSTimer *displayNoCloudTimer;
@property(nonatomic, readonly) NSTimer *cloudReconnectTimer;
@property BOOL presentingLoginController;
@end

@implementation SFIMainViewController

#pragma mark - View Lifecycle

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kSFIReachabilityChangedNotification object:nil];
    [center removeObserver:self name:NETWORK_DOWN_NOTIFIER object:nil];
    [center removeObserver:self name:NETWORK_UP_NOTIFIER object:nil];
    [center removeObserver:self name:kSFIDidCompleteLoginNotification object:nil];
    [center removeObserver:self name:kSFIDidLogoutNotification object:nil];
    [center removeObserver:self name:kSFIDidLogoutAllNotification object:nil];
    [center removeObserver:self name:UI_ON_PRESENT_LOGOUT_ALL object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self displaySplashImage];

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];

    [self scheduleDisplayNoCloudTimer];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self 
               selector:@selector(onReachabilityDidChange:) 
                   name:kSFIReachabilityChangedNotification 
                 object:nil];

    [center addObserver:self
               selector:@selector(networkDownNotifier:)
                   name:NETWORK_DOWN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(networkUpNotifier:)
                   name:NETWORK_UP_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onDidCompleteLogin:)
                   name:kSFIDidCompleteLoginNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(onLogoutResponse:)
                   name:kSFIDidLogoutNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(onLogoutAllResponse:)
                   name:kSFIDidLogoutAllNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(onPresentLogoutAll)
                   name:UI_ON_PRESENT_LOGOUT_ALL
                 object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self conditionalTryConnectOrLogon:YES];
}

#pragma mark - Connection Management

- (BOOL)isCloudOnline {
    return [[SecurifiToolkit sharedInstance] isCloudOnline];
}

- (void)conditionalTryConnectOrLogon:(BOOL)showHud {
    if ([self isCloudOnline]) {
        // Already connected. Nothing to do.
        return;
    }

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    if (![toolkit isReachable]) {
        // No network route to cloud. Nothing to do.
        return;
    }

    // Try to connect iff we are the top-level presenting view and network is down
    if (self.presentedViewController != nil) {
        return;
    }

    if (![toolkit hasLoginCredentials]) {
        // If no logon credentials we just put up the screen and then handle connection from there.
        [self presentLogonScreen];
        return;
    }

    // Else try to connect
    if (showHud) {
        self.HUD.labelText = @"Connecting. Please wait!";
        [self.HUD show:YES];
    }

    [self scheduleDisplayNoCloudTimer];

    [toolkit initSDK];
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

- (void)onReachabilityDidChange:(id)sender {
    [self conditionalTryConnectOrLogon:NO];
}

- (void)networkUpNotifier:(id)sender {
    if (self.isCloudOnline) {
        [self.HUD hide:YES];
        [self invalidateTimers];
    }
}

- (void)networkDownNotifier:(id)sender {
    [self conditionalTryConnectOrLogon:NO];
}

#pragma mark - SFILoginViewController delegate methods

- (void)loginControllerDidCompleteLogin:(SFILoginViewController *)loginCtrl {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            self.presentingLoginController = NO;
            [self presentMainView];
        }];
    });
}

#pragma mark - Login and Logout handling

- (void)onLogoutResponse:(id)sender {
    DLog(@"%s", __PRETTY_FUNCTION__);

    NSNotification *notifier = (NSNotification *) sender;
    if ([notifier userInfo] == nil) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self presentLogonScreen];
        });
        return;
    }

    NSDictionary *data = [notifier userInfo];
    LogoutResponse *obj = (LogoutResponse *) [data valueForKey:@"data"];
    if (obj.isSuccessful) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self presentLogonScreen];
        });
    }
}

- (void)onLogoutAllResponse:(id)sender {
    DLog(@"%s", __PRETTY_FUNCTION__);

    if (![[SecurifiToolkit sharedInstance] isLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self presentLogonScreen];
        });
    }
}

- (void)onDidCompleteLogin:(id)sender {
    DLog(@"%s", __PRETTY_FUNCTION__);

    if ([[SecurifiToolkit sharedInstance] isLoggedIn]) {
        [self presentMainView];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self presentLogonScreen];
        });
    }
}

- (void)onPresentLogoutAll {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
                [self presentLogoutAllView];
            }];
        }
        else {
            [self presentLogoutAllView];
        }
    });
}

#pragma mark - UIView management; mainly, we need to manage logon and logout all, and setting up the main screen on logon.

- (void)presentLogonScreen {
    DLog(@"%s", __PRETTY_FUNCTION__);

    if (self.presentingLoginController) {
        return;
    }
    self.presentingLoginController = YES;
    DLog(@"%s: Presenting logon controller", __PRETTY_FUNCTION__);

    // Present login screen
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    SFILoginViewController *loginCtrl = [storyboard instantiateViewControllerWithIdentifier:@"SFILoginViewController"];
    loginCtrl.delegate = self;

    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginCtrl];

    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:navCtrl animated:YES completion:nil];
        }];
    }
    else {
        [self presentViewController:navCtrl animated:YES completion:nil];
    }
}

- (void)presentMainView {
    DLog(@"%s: Presenting main view", __PRETTY_FUNCTION__);

    // Set up the front view controller based on a Tab Bar controller
    UIImage *icon;
    //
    SFISensorsViewController *sensorCtrl = [SFISensorsViewController new];
    //
    UINavigationController *sensorNav = [[UINavigationController alloc] initWithRootViewController:sensorCtrl];
    icon = [UIImage imageNamed:@"icon_sensor.png"];
    sensorNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Sensors" image:icon selectedImage:icon];
    //
    SFIRouterTableViewController *routerCtrl = [SFIRouterTableViewController new];
    //
    UINavigationController *routerNav = [[UINavigationController alloc] initWithRootViewController:routerCtrl];
    icon = [UIImage imageNamed:@"icon_router.png"];
    routerNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Router" image:icon selectedImage:icon];
    //
    UITabBarController *front = [UITabBarController new];
    front.tabBar.tintColor = [UIColor blackColor];
    front.viewControllers = @[sensorNav, routerNav];

    // The rear one is the drawer selector
    DrawerViewController *rear = [DrawerViewController new];

    SWRevealViewController *ctrl;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        ctrl = [[SWRevealViewController alloc] initWithRearViewController:rear frontViewController:front];
    }
    else {
        ctrl = [[SWRevealViewController alloc] initWithRearViewController:rear frontViewController:front];
    }

    [self presentViewController:ctrl animated:YES completion:nil];

    // Activate gestures in Reveal; must be done after it has been set up
    [ctrl panGestureRecognizer];
    [ctrl tapGestureRecognizer];

    ctrl.panGestureRecognizer.delegate = self;
}

- (void)presentLogoutAllView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    SFILogoutAllViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"SFILogoutAllViewController"];
    ctrl.delegate = self;

    UINavigationController *nctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nctrl animated:YES completion:nil];
}

#pragma mark - SFILogoutAllDelegate methods

- (void)logoutAllControllerDidLogoutAll:(SFILogoutAllViewController *)ctrl {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self presentLogonScreen];
    });
}

- (void)logoutAllControllerDidCancel:(SFILogoutAllViewController *)ctrl {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            if ([[SecurifiToolkit sharedInstance] isLoggedIn]) {
                [self presentMainView];
            }
            else {
                [self presentLogonScreen];
            }
        }];
    });
}

#pragma mark - Timers

- (void)invalidateTimers {
    [self.displayNoCloudTimer invalidate];
    _displayNoCloudTimer = nil;

    [self.cloudReconnectTimer invalidate];
    _cloudReconnectTimer = nil;
}

- (void)scheduleDisplayNoCloudTimer {
    _displayNoCloudTimer = [NSTimer scheduledTimerWithTimeInterval:CLOUD_CONNECTION_TIMEOUT
                                                            target:self
                                                          selector:@selector(onNoCloudConnectionTimeout)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (void)scheduleReconnectTimer {
    _cloudReconnectTimer = [NSTimer scheduledTimerWithTimeInterval:CLOUD_CONNECTION_RETRY
                                                            target:self
                                                          selector:@selector(onNoCloudConnectionRetry)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (void)onNoCloudConnectionTimeout {
    _displayNoCloudTimer = nil;

    [self.HUD hide:YES];

    if ([self isCloudOnline]) {
        [self displaySplashImage];
    }
    else {
        [self displayNoCloudConnectionImage];
        [self scheduleReconnectTimer];
    }
}

- (void)onNoCloudConnectionRetry {
    _cloudReconnectTimer = nil;

    if ([self isCloudOnline]) {
        [self displaySplashImage];
    }
    else {
        [self conditionalTryConnectOrLogon:NO];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *view = touch.view;

    if ([view isKindOfClass:[UISlider class]]) {
        // prevent recognizing touches on the slider
        return NO;
    }

    return YES;
}

@end