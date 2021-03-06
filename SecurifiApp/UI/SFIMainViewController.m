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
#import "SFIAccountsTableViewController.h"
#import "SFIScenesViewController.h"//md01
#import "UIViewController+Securifi.h"
#import "Analytics.h"
#import "ScoreboardViewController.h"
#import "SFIPreferences.h"
#import "UIImage+Securifi.h"
#import "UIApplication+SecurifiNotifications.h"

#define TAB_BAR_SENSORS @"Sensors"
#define TAB_BAR_ROUTER @"Router"
#define TAB_BAR_SCENES @"Scenes"//md01

@interface SFIMainViewController () <SFILoginViewDelegate, SFILogoutAllDelegate, SFIAccountDeleteDelegate, UIGestureRecognizerDelegate, UITabBarControllerDelegate>
@property(nonatomic, readonly) MBProgressHUD *HUD;
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
    [center removeObserver:self name:UI_ON_PRESENT_ACCOUNTS object:nil];
    [center removeObserver:self name:NOTIFICATION_REGISTRATION_NOTIFIER object:nil];
    [center removeObserver:self name:NOTIFICATION_DEREGISTRATION_NOTIFIER object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self displaySplashImage];

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(onReachabilityDidChange:)
                   name:kSFIReachabilityChangedNotification 
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkDownNotifier:)
                   name:NETWORK_DOWN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkUpNotifier:)
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
    
    [center addObserver:self
               selector:@selector(onPresentAccounts)
                   name:UI_ON_PRESENT_ACCOUNTS
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onDidRegisterForNotifications)
                   name:kSFIDidRegisterForNotifications
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onDidFailToRegisterForNotifications)
                   name:kSFIDidFailToRegisterForNotifications
                 object:nil];

    [center addObserver:self
               selector:@selector(onDidDeregisterForNotifications)
                   name:kSFIDidDeregisterForNotifications
                 object:nil];

    [center addObserver:self
               selector:@selector(onDidFailToDeregisterForNotifications)
                   name:kSFIDidFailToDeregisterForNotifications
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

- (void)conditionalTryConnectOrLogon:(BOOL)onViewAppearing {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    if ([toolkit isCloudOnline]) {
        // Already connected. Nothing to do.
        NSLog(@"Cloud is on-line. returning");
        return;
    }

    // Try to connect iff we are the top-level presenting view and network is down
    if (self.presentedViewController != nil) {
        NSLog(@"presented view controller. returning");
        return;
    }

    if (![toolkit isCloudReachable]) {
        // No network route to cloud. Nothing to do.
        if (!onViewAppearing) {
            // only show after first attempt fails
            [self showToast:@"Sorry! Unable to establish Internet route to cloud service."];
        }

        [self scheduleReconnectTimer];
        return;
    }

    if (![toolkit hasLoginCredentials]) {
        // If no logon credentials we just put up the screen and then handle connection from there.
        [self presentLogonScreen];
        return;
    }

    [self displaySplashImage];

    // Else try to connect
    if (onViewAppearing) {
        self.HUD.labelText = @"Connecting. Please wait!";
        [self.HUD show:YES];
    }

    [self scheduleReconnectTimer];
    [toolkit initToolkit];
}

#pragma mark - Class methods

- (void)displaySplashImage {
    dispatch_async(dispatch_get_main_queue(), ^() {
        // Ex: "Almond-splash_image"
        self.imgSplash.image = [UIImage assetImageNamed:@"splash_image"];
    });
}

- (void)displayNoCloudConnectionImage {
    dispatch_async(dispatch_get_main_queue(), ^() {
        // Ex: "Almond-splash_image"
        self.imgSplash.image = [UIImage assetImageNamed:@"no_cloud"];
        [self showToast:@"Sorry! Could not connect to the cloud service."];
    });
}

#pragma mark - Reconnection

- (void)onReachabilityDidChange:(id)sender {
    [self conditionalTryConnectOrLogon:NO];
}

- (void)onNetworkUpNotifier:(id)sender {
    if (self.isCloudOnline) {
        [self.HUD hide:YES];
        [self invalidateTimer];
    }
}

- (void)onNetworkDownNotifier:(id)sender {
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

    if (![[SecurifiToolkit sharedInstance] isCloudLoggedIn]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self presentLogonScreen];
        });
    }
}

- (void)onDidCompleteLogin:(id)sender {
    DLog(@"%s", __PRETTY_FUNCTION__);

    //PY 151014: Activation Header Notification to be set true
    [[SFIPreferences instance] setLogonAccountNeedsActivationNotification];

    if ([[SecurifiToolkit sharedInstance] isCloudLoggedIn]) {
        UIApplication *application = [UIApplication sharedApplication];
        [application securifiApplicationTryEnableRemoteNotifications];
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

- (void)onPresentAccounts {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
                [self presentAccountsView];
            }];
        }
        else {
            [self presentAccountsView];
        }
    });
}

#pragma mark - UIView management

// mainly, we need to manage logon and logout all, and setting up the main screen on logon.

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
    icon = [UIImage imageNamed:@"icon_sensor"];
    sensorNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_SENSORS image:icon selectedImage:icon];
    //
    SFIRouterTableViewController *routerCtrl = [SFIRouterTableViewController new];
    //
    UINavigationController *routerNav = [[UINavigationController alloc] initWithRootViewController:routerCtrl];
    icon = [UIImage imageNamed:@"icon_router"];
    routerNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_ROUTER image:icon selectedImage:icon];

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SecurifiConfigurator *configurator = toolkit.configuration;

    // Build up tab bar
    //
    NSArray *tabs = @[sensorNav];
    //
    if (configurator.enableScenes) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Scenes_Iphone" bundle:nil];

        SFIScenesViewController *scenesCtrl = [storyboard instantiateViewControllerWithIdentifier:@"SFIScenesViewController"];

        UINavigationController *scenesNav = [[UINavigationController alloc] initWithRootViewController:scenesCtrl];
        icon = [UIImage imageNamed:@"icon_scenes"];
        scenesNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:TAB_BAR_SCENES image:icon selectedImage:icon];

        tabs = [tabs arrayByAddingObject:scenesNav];
    }
    //
    tabs = [tabs arrayByAddingObject:routerNav];
    //
    if (configurator.enableScoreboard) {
        ScoreboardViewController *scoreCtrl = [ScoreboardViewController new];

        UINavigationController *scoreNav = [[UINavigationController alloc] initWithRootViewController:scoreCtrl];
        icon = [UIImage imageNamed:@"878-binoculars"];
        scoreNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Debug" image:icon selectedImage:icon];

        tabs = [tabs arrayByAddingObject:scoreNav];
    }

    UITabBarController *tabCtrl = [UITabBarController new];
    tabCtrl.tabBar.translucent = NO;
    tabCtrl.tabBar.tintColor = [UIColor blackColor];
    tabCtrl.viewControllers = tabs;
    tabCtrl.delegate = self;

    DrawerViewController *drawer = [DrawerViewController new];

    SWRevealViewController *ctrl = [[SWRevealViewController alloc] initWithRearViewController:drawer frontViewController:tabCtrl];
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

- (void)presentAccountsView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AccountsStoryboard_iPhone" bundle:nil];
    SFIAccountsTableViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"SFIAccountsTableViewController"];
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
            if ([[SecurifiToolkit sharedInstance] isCloudLoggedIn]) {
                [self presentMainView];
            }
            else {
                [self presentLogonScreen];
            }
        }];
    });
}

- (void)userAccountDidDelete:(SFIAccountsTableViewController *)ctrl {
    DLog(@"%s: Presenting login view", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self presentLogonScreen];
    });
}

- (void)userAccountDidDone:(SFIAccountsTableViewController *)ctrl{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            if ([[SecurifiToolkit sharedInstance] isCloudLoggedIn]) {
                [self presentMainView];
            }
            else {
                [self presentLogonScreen];
            }
        }];
    });
}

#pragma mark - Timers

- (void)invalidateTimer {
    [self.cloudReconnectTimer invalidate];
    _cloudReconnectTimer = nil;
}

- (void)scheduleReconnectTimer {
    [self invalidateTimer];
    _cloudReconnectTimer = [NSTimer scheduledTimerWithTimeInterval:CLOUD_CONNECTION_RETRY
                                                            target:self
                                                          selector:@selector(onNoCloudConnectionRetry)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (void)onNoCloudConnectionRetry {
    [self.HUD hide:YES];

    if ([self isCloudOnline]) {
        [self displaySplashImage];
    }
    else {
        [self displayNoCloudConnectionImage];
        [self conditionalTryConnectOrLogon:NO];
    }
}


#pragma mark - Notification Registration

- (void)onDidRegisterForNotifications {
    // do nothing
}

- (void)onDidFailToRegisterForNotifications {
    ELog(@"Failed to register push notification token with cloud");
    [self showToast:@"Sorry! Push Notification was not registered."];
}

- (void)onDidDeregisterForNotifications {
//    [self showToast:@"Push Notification was successfully deregistered."];
}

- (void)onDidFailToDeregisterForNotifications {
    ELog(@"Failed to remove push notification token registration with cloud");
    [self showToast:@"Sorry! Push Notification was not deregistered."];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *view = touch.view;
    // prevent recognizing touches on the slider
    return ![view isKindOfClass:[UISlider class]];
}

#pragma mark - UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)ctrl {
    NSString *title = ctrl.tabBarItem.title;
    
    if ([title isEqualToString:TAB_BAR_SENSORS]) {
        [[Analytics sharedInstance] markSensorScreen];
    }
    else if ([title isEqualToString:TAB_BAR_ROUTER]) {
        [[Analytics sharedInstance] markRouterScreen];
    }
    
  //md01
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"TAB_BAR_CHANGED"
     object:self userInfo:@{@"title":title}];
}

@end
