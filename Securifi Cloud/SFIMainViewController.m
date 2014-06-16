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
#import "SNLog.h"
#import "SFILoginViewController.h"

@interface SFIMainViewController () <SFILoginViewDelegate>
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic, readonly) NSTimer *displayNoCloudTimer;
@property BOOL presentingLoginController;
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

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(networkDownNotifier:)
                   name:NETWORK_DOWN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(networkUpNotifier:)
                   name:NETWORK_UP_NOTIFIER
                 object:nil];

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!self.isCloudOnline) {
        self.HUD.labelText = @"Connecting. Please wait!";
    }
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

#pragma mark - SFILoginViewController delegate methods

- (void)loginControllerDidCompleteLogin:(SFILoginViewController *)loginCtrl {
    [SNLog Log:@"%s", __PRETTY_FUNCTION__];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        [self presentMainView];
        self.presentingLoginController = NO;
    }];
}

#pragma mark - Cloud Command : Sender and Receivers

- (void)loadAlmondList {
    [[SecurifiToolkit sharedInstance] asyncLoadAlmondList];
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

    if ([[SecurifiToolkit sharedInstance] isLoggedIn]) {
        [self loadAlmondList];
    }
    else {
        [self presentLogonScreen];
    }
}

- (void)onAlmondListResponse:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];

        //Write Almond List offline
        [SFIOfflineDataManager writeAlmondList:obj.almondPlusMACList];
    }

    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self presentMainView];
        }];
    }
    else {
        [self presentMainView];
    }
}

- (void)presentLogonScreen {
    NSLog(@"%s", __PRETTY_FUNCTION__);

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
    NSLog(@"%s: Presenting main view", __PRETTY_FUNCTION__);

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"InitialSlide"];

    [self presentViewController:mainView animated:YES completion:nil];
}


@end
