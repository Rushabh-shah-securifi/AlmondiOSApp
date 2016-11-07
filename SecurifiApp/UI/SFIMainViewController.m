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
#import "DrawerViewController.h"
#import "SFIAccountsTableViewController.h"
#import "UIViewController+Securifi.h"
#import "Analytics.h"
#import "SFIPreferences.h"
#import "UIApplication+SecurifiNotifications.h"
#import "SFITabBarController.h"
#import "KeyChainAccess.h"
#import "ConnectionStatus.h"
#import "NetworkStatusIcon.h"

#define TAB_BAR_SENSORS @"Sensors"
#define TAB_BAR_ROUTER @"Router"
#define TAB_BAR_SCENES @"Scenes"

@interface SFIMainViewController () <SFILoginViewDelegate, SFILogoutAllDelegate, SFIAccountDeleteDelegate, UIGestureRecognizerDelegate, UITabBarControllerDelegate>
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property BOOL presentingLoginController;
@end

@implementation SFIMainViewController
NetworkStatusIcon *statusIcon;
#pragma mark - View Lifecycle

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}


- (void)displayWebView:(NSString *)strForWebView{
    NSLog(@"display web view main");
    //this might slow down the app, perhaps you can think of better
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        webView.backgroundColor = [UIColor clearColor];
        [webView loadHTMLString:strForWebView baseURL:nil];
        [self.view addSubview:webView];
    });
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    [self displaySplashImage];
    
    //    [self.imgSplash removeFromSuperview];
    //    self.imgSplash = nil;
    
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];
    
    SFITabBarController *tabCtrl = [SFITabBarController new];
    tabCtrl.tabBar.translucent = NO;
    tabCtrl.tabBar.tintColor = [UIColor blackColor];
    tabCtrl.delegate = self;
    
    //    DrawerViewController *drawer = [DrawerViewController new];
    
    //    SWRevealViewController *ctrl = [[SWRevealViewController alloc] initWithRearViewController:drawer frontViewController:tabCtrl];
    //    ctrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //
    [tabCtrl willMoveToParentViewController:self];
    [self addChildViewController:tabCtrl];
    [self.view addSubview:tabCtrl.view];
    //    [self.view bringSubviewToFront:ctrl.view];
    [tabCtrl didMoveToParentViewController:self];
    
    // Activate gestures in Reveal; must be done after it has been set up
    //    [ctrl panGestureRecognizer];
    //    [ctrl tapGestureRecognizer];
    //
    //    ctrl.panGestureRecognizer.delegate = self;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onConnectionStatusChanged:) name:CONNECTION_STATUS_CHANGE_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onDidCompleteLogin:) name:kSFIDidCompleteLoginNotification object:nil];
    [center addObserver:self selector:@selector(onLogoutResponse:) name:kSFIDidLogoutNotification object:nil];
    [center addObserver:self selector:@selector(onLogoutAllResponse:) name:kSFIDidLogoutAllNotification object:nil];
    [center addObserver:self selector:@selector(onConnectionModeChange:) name:kSFIDidChangeAlmondConnectionMode object:nil];
    [center addObserver:self selector:@selector(onPresentLogoutAll) name:UI_ON_PRESENT_LOGOUT_ALL object:nil];
    [center addObserver:self selector:@selector(onPresentAccounts) name:UI_ON_PRESENT_ACCOUNTS object:nil];
    [center addObserver:self selector:@selector(onDidFailToRegisterForNotifications) name:kSFIDidFailToRegisterForNotifications object:nil];
    [center addObserver:self selector:@selector(onDidFailToDeregisterForNotifications) name:kSFIDidFailToDeregisterForNotifications object:nil];
    
    // At app startup, be sure to show logon when the app is in Cloud connection mode and has no logon credentials
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    if (![KeyChainAccess hasLoginCredentials]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self tryPresentLogonScreen];
        });
    }
    //adding this so that loading webviews for help screens does not cause any problem.
    [self displayWebView:@""];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self conditionalTryConnectOrLogon:YES];
}

#pragma mark - Connection Management

- (void)conditionalTryConnectOrLogon:(BOOL)onViewAppearing {
    NSLog(@"conditionalTryConnectOrLogon");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    NSLog(@"i am called");
    // for apps not using local connection support: we preserve the old behavior of showing a splash screen until the
    // cloud connection is established.
    const BOOL supportsLocalConnections = toolkit.configuration.enableLocalNetworking;
    
    if (!supportsLocalConnections && [toolkit isNetworkOnline]) {
        // Already connected. Nothing to do.
        NSLog(@"Cloud is on-line. returning");
        return;
    }
    
    // Try to connect iff we are the top-level presenting view and network is down
    if (self.presentedViewController != nil) {
        NSLog(@"presented view controller. returning");
        return;
    }
    
    if (!supportsLocalConnections && ![toolkit isCloudReachable]) {
        // No network route to cloud. Nothing to do.
        if (!onViewAppearing) {
            // only show after first attempt fails
            [self showToast:NSLocalizedString(@"Sorry! Unable to establish Internet route to cloud service.", @"Sorry! Unable to establish Internet route to cloud service.")];
        }
        
        return;
    }
    
    if (toolkit.currentAlmond==nil && ![KeyChainAccess hasLoginCredentials]) {
        // If no logon credentials we just put up the screen and then handle connection from there.
        [self tryPresentLogonScreen];
        return;
    }
    
    [self displaySplashImage];
    
    // Else try to connect
    if (onViewAppearing) {
        self.HUD.labelText = NSLocalizedString(@"mainviewcontroller_Connecting. Please wait!", @"Connecting. Please wait!");
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.HUD show:YES];
        });
    }
    
    [toolkit asyncInitNetwork];
}

#pragma mark - Class methods

-(void)onConnectionStatusChanged:(id)sender {
    NSNumber* status = [sender object];
    int statusIntValue = [status intValue];
    if(statusIntValue == AUTHENTICATED){
        if ([[SecurifiToolkit sharedInstance] isNetworkOnline]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.HUD hide:YES];
            });
        }
    }
}

- (void)displaySplashImage {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.imgSplash.image = nil;//[UIImage assetImageNamed:@"splash_image"];
    });
}


#pragma mark - SFILoginViewController delegate methods

- (void)loginControllerDidCompleteLogin:(SFILoginViewController *)loginCtrl {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            self.presentingLoginController = NO;
        }];
    });
}

#pragma mark - Login and Logout handling

- (void)onLogoutResponse:(id)sender {
    DLog(@"%s", __PRETTY_FUNCTION__);
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    if (data == nil) {
        [self tryPresentLogonScreen];
        return;
    }
    
    LogoutResponse *obj = (LogoutResponse *) [data valueForKey:@"data"];
    if (obj.isSuccessful) {
        [self tryPresentLogonScreen];
    }
}

- (void)onLogoutAllResponse:(id)sender {
    DLog(@"%s", __PRETTY_FUNCTION__);
    
    if (![[SecurifiToolkit sharedInstance] isNetworkOnline]) {
        [self tryPresentLogonScreen];
    }
}

- (void)onDidCompleteLogin:(id)sender {
    DLog(@"%s", __PRETTY_FUNCTION__);
    
    //PY 151014: Activation Header Notification to be set true
    [[SFIPreferences instance] setLogonAccountNeedsActivationNotification];
    
    if ([[SecurifiToolkit sharedInstance] isNetworkOnline]) {
        UIApplication *application = [UIApplication sharedApplication];
        [application securifiApplicationTryEnableRemoteNotifications];
    }
    else {
        [self tryPresentLogonScreen];
    }
}

// when switching to cloud connection, if no credentials stored, then present login panel
- (void)onConnectionModeChange:(id)sender {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    if (![KeyChainAccess hasLoginCredentials]) {
        [self tryPresentLogonScreen];
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

- (void)tryPresentLogonScreen {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    const BOOL supportsLocalConnections = toolkit.configuration.enableLocalNetworking;
    if (supportsLocalConnections) {
        NSLog(@"i am called");
        if (toolkit.currentConnectionMode == SFIAlmondConnectionMode_local && toolkit.currentAlmond!=nil) {
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self presentLogonScreen];
    });
}

- (void)presentLogonScreen {
    DLog(@"%s", __PRETTY_FUNCTION__);
    
    if (self.presentingLoginController) {
        return;
    }
    self.presentingLoginController = YES;
    DLog(@"%s: Presenting logon controller", __PRETTY_FUNCTION__);
    
    // Present login screen
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login_iPhone" bundle:nil];
    SFILoginViewController *ctrl = (SFILoginViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SFILoginViewController"];
    ctrl.delegate = self;
    ctrl.mode = [SecurifiToolkit sharedInstance].localLinkedAlmondList.count == 0 ? SFILoginViewControllerMode_localLinkOption : SFILoginViewControllerMode_switchToLocalConnection;
    
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:ctrl animated:YES completion:nil];
        }];
    }
    else {
        [self presentViewController:ctrl animated:YES completion:nil];
    }
}

- (void)presentLogoutAllView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    SFILogoutAllViewController *ctrl = (SFILogoutAllViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SFILogoutAllViewController"];
    ctrl.delegate = self;
    
    UINavigationController *nctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nctrl animated:YES completion:nil];
}

- (void)presentAccountsView {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AccountsStoryboard_iPhone" bundle:nil];
    SFIAccountsTableViewController *ctrl = (SFIAccountsTableViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SFIAccountsTableViewController"];
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
            if (![[SecurifiToolkit sharedInstance] isNetworkOnline]) {
                NSLog(@"logoutAllControllerDidCancel");
                //                [self tryPresentLogonScreen]; //need to look at this logic
            }
        }];
    });
}

- (void)userAccountDidDelete:(SFIAccountsTableViewController *)ctrl {
    DLog(@"%s: Presenting login view", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self tryPresentLogonScreen];
    });
}

- (void)userAccountDidDone:(SFIAccountsTableViewController *)ctrl {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            if (![[SecurifiToolkit sharedInstance] isNetworkOnline]) {
                //[self tryPresentLogonScreen];
            }
        }];
    });
}

#pragma mark - Notification Registration

- (void)onDidFailToRegisterForNotifications {
    ELog(@"Failed to register push notification token with cloud");
    [self showToast:NSLocalizedString(@"main view controller Sorry! Push Notification was not registered.", @"Sorry! Push Notification was not registered.")];
}

- (void)onDidFailToDeregisterForNotifications {
    ELog(@"Failed to remove push notification token registration with cloud");
    [self showToast:NSLocalizedString(@"main view controller Sorry! Push Notification was not deregistered.", @"Sorry! Push Notification was not deregistered.")];
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
    
    if (tabBarController.moreNavigationController == ctrl) {
        title = ctrl.title;
        [[Analytics sharedInstance] markMoreScreen];
    }
    
    if ([title isEqualToString:TAB_BAR_SENSORS]) {
        [[Analytics sharedInstance] markDevicesScreen];
    }
    else if ([title isEqualToString:TAB_BAR_ROUTER]) {
        [[Analytics sharedInstance] markRouterScreen];
    }
    else if([title isEqualToString:TAB_BAR_SCENES]){
        [[Analytics sharedInstance] markSceneScreen];
    }
    
    //md01
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TAB_BAR_CHANGED" object:self userInfo:@{@"title" : title}];
}

@end
