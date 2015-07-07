//
//  SFITableViewController.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import <SWRevealViewController/SWRevealViewController.h>
#import "SFITableViewController.h"
#import "SFICloudStatusBarButtonItem.h"
#import "UIFont+Securifi.h"
#import "SFINotificationsViewController.h"
#import "SFINotificationStatusBarButtonItem.h"
#import "UIApplication+SecurifiNotifications.h"
#import "SFIHuePickerView.h"
#import "AlertView.h"

@interface SFITableViewController () <MBProgressHUDDelegate, SWRevealViewControllerDelegate, UIGestureRecognizerDelegate, AlertViewDelegate, UITabBarControllerDelegate>
@property(nonatomic, readonly) SFINotificationStatusBarButtonItem *notificationsStatusButton;
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *connectionStatusBarButton;
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *almondModeBarButton;
@property(nonatomic) UIView *tableScrim;
@end

@implementation SFITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _enableDrawer = YES;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    SecurifiConfigurator *configurator = toolkit.configuration;
    _enableNotificationsView = configurator.enableNotifications;
    _enableNotificationsHomeAwayMode = configurator.enableNotificationsHomeAwayMode;

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;

    SWRevealViewController *revealController = [self revealViewController];

    UIBarButtonItem *revealButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"drawer.png"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButton;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    self.enableDrawer = _enableDrawer; // in case it was set before view loaded

    _connectionStatusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onConnectionStatusButtonPressed:) enableLocalNetworking:configurator.enableLocalNetworking];
    //
    if (self.enableNotificationsView) {
        _notificationsStatusButton = [[SFINotificationStatusBarButtonItem alloc] initWithTarget:self action:@selector(onShowNotifications:)];

        NSInteger count = [toolkit countUnviewedNotifications];
        [self.notificationsStatusButton markNotificationCount:(NSUInteger) count];

        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spacer.width = 5;

        // make the button but do not install; will be installed after connection state is determined
        _almondModeBarButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onAlmondModeButtonPressed:) enableLocalNetworking:configurator.enableLocalNetworking];

        self.navigationItem.rightBarButtonItems = @[spacer, self.notificationsStatusButton, self.connectionStatusBarButton];
    }
    else {
        self.navigationItem.rightBarButtonItem = _connectionStatusBarButton;
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    };

    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(onNetworkDownNotifier:)
                   name:NETWORK_DOWN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkConnectingNotifier:)
                   name:NETWORK_CONNECTING_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkUpNotifier:)
                   name:NETWORK_UP_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onReachabilityDidChange:)
                   name:kSFIReachabilityChangedNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(onNotificationCountChanged:)
                   name:kSFINotificationDidStore
                 object:nil];

    [center addObserver:self
               selector:@selector(onNotificationCountChanged:)
                   name:kSFINotificationBadgeCountDidChange
                 object:nil];

    [center addObserver:self
               selector:@selector(onNotificationCountChanged:)
                   name:kSFINotificationDidMarkViewed
                 object:nil];

    [center addObserver:self
               selector:@selector(onAlmondModeChangeDidComplete:)
                   name:kSFIDidCompleteAlmondModeChangeRequest
                 object:nil];

    [center addObserver:self
               selector:@selector(onAlmondModeDidChange:)
                   name:kSFIAlmondModeDidChange
                 object:nil];

    [center addObserver:self
               selector:@selector(onShowNotifications:)
                   name:kApplicationDidBecomeActiveOnNotificationTap
                 object:nil];

    [center addObserver:self
               selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // make sure status icon is up-to-date
    [self markCloudStatusIcon];
    [self markNotificationStatusIcon];

    // install self as delegate so this controller can enable/disable drawer
    SWRevealViewController *ctrl = [self revealViewController];
    ctrl.delegate = self;
    ctrl.panGestureRecognizer.delegate = self;
}

#pragma Event handling

- (void)onConnectionStatusButtonPressed:(id)sender {
    AlertView *alert = [AlertView new];
    alert.delegate = self;
    alert.backgroundColor = [UIColor whiteColor];
    alert.alpha = 0.95;

    CGRect rect = self.navigationController.navigationBar.frame;
    CGRect frame = CGRectMake(0, rect.size.height + 20, rect.size.width, 220);
    alert.frame = frame;

    SFICloudStatusState statusState = self.connectionStatusBarButton.state;
    switch (statusState) {
        case SFICloudStatusStateConnecting: {
            // ignore this
            return;
        };

        case SFICloudStatusStateConnected: {
            alert.message = @"Connected to your Almond via cloud.";
            alert.options = @[
                    @"Switch to Local Connection"
            ];
            break;
        };

        case SFICloudStatusStateDisconnected:
        case SFICloudStatusStateAlmondOffline: {
            alert.message = @"Cloud connection to your Almond failed. Tap retry or switch to local connection.";
            alert.options = @[
                    @"Retry Cloud Connection",
                    @"Switch to Local Connection"
            ];
            break;
        };

        case SFICloudStatusStateAway:
        case SFICloudStatusStateAtHome:
            // should not be possible state for this button
            return;

        case SFICloudStatusStateConnectionError: {
            alert.message = @"Can't connect to your Almond. Please select a connection method.";
            alert.options = @[
                    @"Cloud Connection",
                    @"Local Connection"
            ];
            break;
        };
        case SFICloudStatusStateLocalConnection: {
            alert.message = @"Connected to your Almond locally.";
            alert.options = @[
                    @"Switch to Cloud Connection"
            ];
            break;
        };

        case SFICloudStatusStateLocalConnectionOffline: {
            alert.message = @"Local connection to your Almond failed. Tap retry or switch to cloud connection.";
            alert.options = @[
                    @"Retry Local Connection",
                    @"Switch to Cloud Connection"
            ];
            break;
        };

        default:
            return;
    }

    [self onLockTable];
    [self.navigationController.view addSubview:alert];
}

- (void)onAlmondModeButtonPressed:(id)sender {
    if (!self.enableNotificationsView) {
        return;
    }

    SFICloudStatusBarButtonItem *button = self.almondModeBarButton;
    SFICloudStatusState state = button.state;

    enum SFIAlmondMode newMode;
    NSString *msg;

    if (state == SFICloudStatusStateAtHome) {
        newMode = SFIAlmondMode_away;
        msg = @"Setting Almond to Away Mode";
    }
    else if (state == SFICloudStatusStateAway) {
        newMode = SFIAlmondMode_home;
        msg = @"Setting Almond to Home Mode";
    }
    else {
        return;
    }

    // if the hud is already being shown then ignore the button press
    if (!self.isHudHidden) {
        return;
    }

    [self showHUD:msg];
    [self.HUD hide:YES afterDelay:10]; // in case the request times out

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit asyncRequestAlmondModeChange:self.almondMac mode:newMode];
}

- (void)onAlmondModeChangeDidComplete:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markCloudStatusIcon];
        [self.HUD hide:YES];
    });
}

- (void)onAlmondModeDidChange:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.presentedViewController != nil) {
            return;
        }

        [self markCloudStatusIcon];
    });
}

- (void)onShowNotifications:(id)onShowNotifications {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.presentedViewController != nil) {
            return;
        }

        SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
//        ctrl.enableDebugMode = YES; // can uncomment for development/test

        UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        [self presentViewController:nav_ctrl animated:YES completion:nil];
    });
}

- (void)onNetworkUpNotifier:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markCloudStatusIcon];
        [self.tableView reloadData];
        [self.HUD hide:NO]; // make sure it is hidden
    });
}

- (void)onNetworkDownNotifier:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markCloudStatusIcon];
        [self.tableView reloadData];
        [self.HUD hide:NO]; // make sure it is hidden
    });
}

- (void)onNetworkConnectingNotifier:(id)notification {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markCloudStatusIcon];
    });
}

- (void)onReachabilityDidChange:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markCloudStatusIcon];
        [self.tableView reloadData];
        [self.HUD hide:NO]; // make sure it is hidden
    });
}

- (void)onNotificationCountChanged:(id)event {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNotificationStatusIcon];
    });
}

- (void)markNotificationStatusIcon {
    if (self.enableNotificationsView) {
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        NSInteger badgeCount = [toolkit notificationsBadgeCount];
        [self.notificationsStatusButton markNotificationCount:(NSUInteger) badgeCount];
    }
}

- (void)markCloudStatusIcon {
    NSString *const almondMac = self.almondMac;

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    enum SFIAlmondConnectionMode connectionMode = [toolkit connectionModeForAlmond:almondMac];
    enum SFIAlmondConnectionStatus status = [toolkit connectionStatusForAlmond:almondMac];

    switch (status) {
        case SFIAlmondConnectionStatus_disconnected: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateDisconnected : SFICloudStatusStateLocalConnectionOffline;
            [self.connectionStatusBarButton markState:state];
            [self hideAlmondModeButton]; // when disconnected, can't show mode
            break;
        };
        case SFIAlmondConnectionStatus_connecting:
            [self.connectionStatusBarButton markState:SFICloudStatusStateConnecting];
            break;
        case SFIAlmondConnectionStatus_connected: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateConnected : SFICloudStatusStateLocalConnection;
            [self.connectionStatusBarButton markState:state];

            if (self.enableNotificationsHomeAwayMode) {
                SFIAlmondMode mode = [toolkit modeForAlmond:almondMac];
                state = [self stateForAlmondMode:mode];
                [self.almondModeBarButton markState:state];

                [self showAlmondModeButton];
            }
            break;
        };
        case SFIAlmondConnectionStatus_error:
            break;
    }
}

- (enum SFICloudStatusState)stateForAlmondMode:(SFIAlmondMode)mode {
    switch (mode) {
        case SFIAlmondMode_home:
            return SFICloudStatusStateAtHome;
        case SFIAlmondMode_away:
            return SFICloudStatusStateAway;

        case SFIAlmondMode_unknown:
        default:
            // can happen when the cloud connection comes up but before almond mode has been determined
            return SFICloudStatusStateConnected;
    }
}

- (void)hideAlmondModeButton {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self.enableNotificationsHomeAwayMode) {
            return;
        }

        NSArray *items = self.navigationItem.rightBarButtonItems;
        if (items.count != 4) {
            return;
        }
        self.navigationItem.rightBarButtonItems = [items subarrayWithRange:NSMakeRange(0, 3)];
    });
}

- (void)showAlmondModeButton {
    dispatch_async(dispatch_get_main_queue(), ^() {
        NSArray *items = self.navigationItem.rightBarButtonItems;
        if (items.count == 4) {
            return;
        }
        self.navigationItem.rightBarButtonItems = [items arrayByAddingObject:self.almondModeBarButton];
    });
}

#pragma mark Drawer management

- (void)markAlmondMac:(NSString *)almondMac {
    _almondMac = [almondMac copy];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markCloudStatusIcon];
    });
}

- (void)showHUD:(NSString *)text {
    _isHudHidden = NO;
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

- (void)showLoadingRouterDataHUD {
    [self showHUD:@"Loading router data"];
}

- (void)showLoadingSensorDataHUD {
    [self showHUD:@"Loading sensor data"];
}

- (void)showUpdatingSettingsHUD {
    [self showHUD:NSLocalizedString(@"hud.Updating settings...", @"Updating settings...")];
}

- (void)setEnableDrawer:(BOOL)enableDrawer {
    _enableDrawer = enableDrawer;
    self.navigationItem.leftBarButtonItem.enabled = enableDrawer;
}

#pragma mark HUD management

- (void)hudWasHidden:(MBProgressHUD *)hud {
    _isHudHidden = YES;
}

#pragma mark - SWRevealViewControllerDelegate methods

- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController {
    return self.enableDrawer;
}

- (BOOL)revealControllerTapGestureShouldBegin:(SWRevealViewController *)revealController {
    return self.enableDrawer;
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *view = touch.view;
    // prevent recognizing touches on the slider
    return self.enableDrawer && ![view isKindOfClass:[UISlider class]] && ![view isKindOfClass:[SFIHuePickerView class]];
}

#pragma mark - Keyboard events

// resize table offsets so text fields and other controls are not obscured by the keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    id userInfo = notification.userInfo[UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [userInfo CGRectValue].size;

    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    }
    else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width), 0.0);
    }

    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

// restore original table offsets
- (void)keyboardWillHide:(NSNotification *)notification {
    NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:rate.floatValue animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    }];
}

#pragma mark - AlertViewDelegate methods

- (void)alertView:(AlertView *)view didSelectOption:(NSInteger)index {
    [view removeFromSuperview];
    [self onUnlockTable];
}

- (void)alertViewDidCancel:(AlertView *)view {
    [view removeFromSuperview];
    [self onUnlockTable];
}

#pragma mark - Scrim and Table locking management

- (void)onLockTable {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.tabBarController.delegate = self; // stop user from switching tabs while table is locked
        self.tableView.scrollEnabled = NO;
        self.enableDrawer = NO;
        self.notificationsStatusButton.enabled = NO;
        self.almondModeBarButton.enabled = NO;
        self.connectionStatusBarButton.enabled = NO;
        [self installScrimView];
    });
}

- (void)onUnlockTable {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.tabBarController.delegate = nil; // uninstall delegate so tabs can be selected
        self.tableView.scrollEnabled = YES;
        self.enableDrawer = YES;
        self.notificationsStatusButton.enabled = YES;
        self.almondModeBarButton.enabled = YES;
        self.connectionStatusBarButton.enabled = YES;
        [self removeScrimView];
    });
}

- (void)installScrimView {
    if (!self.tableScrim) {
        UIView *scrim = [[UIView alloc] initWithFrame:self.tableView.frame];
        scrim.backgroundColor = [UIColor clearColor];
        self.tableScrim = scrim;
        [self.tableView addSubview:self.tableScrim];
    }
}

- (void)removeScrimView {
    [self.tableScrim removeFromSuperview];
    self.tableScrim = nil;
}

#pragma mark - UITabBarControllerDelegate methods

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    // installed when table is locked: prevent user from switching tabs when Alert view is showing
    return NO;
}

@end
