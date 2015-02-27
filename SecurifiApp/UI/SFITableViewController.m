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

@interface SFITableViewController () <MBProgressHUDDelegate>
@property(nonatomic, readonly) BOOL isHudHidden;
@property(nonatomic, readonly) SFINotificationStatusBarButtonItem *notificationsStatusButton;
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *statusBarButton;
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

    _statusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onCloudStatusButtonPressed:)];
    //
    if (self.enableNotificationsView) {
        _notificationsStatusButton = [[SFINotificationStatusBarButtonItem alloc] initWithTarget:self action:@selector(onShowNotifications:)];

        NSInteger count = [[SecurifiToolkit sharedInstance] countUnviewedNotifications];
        [self.notificationsStatusButton markNotificationCount:(NSUInteger) count];

        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spacer.width = 25;

        self.navigationItem.rightBarButtonItems = @[self.statusBarButton, spacer, self.notificationsStatusButton];
    }
    else {
        self.navigationItem.rightBarButtonItem = _statusBarButton;
    };
    //
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];

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
                   name:kSFIReachabilityChangedNotification object:nil];

    [center addObserver:self
               selector:@selector(onNotificationCountChanged:)
                   name:kSFINotificationDidStore object:nil];

    [center addObserver:self
               selector:@selector(onNotificationCountChanged:)
                   name:kSFINotificationDidMarkViewed object:nil];

    [center addObserver:self
               selector:@selector(onAlmondModeChangeDidComplete:)
                   name:kSFIDidCompleteAlmondModeChangeRequest object:nil];

    [center addObserver:self
               selector:@selector(onAlmondModeDidChange:)
                   name:kSFIAlmondModeDidChange object:nil];

    [center addObserver:self
               selector:@selector(onShowNotifications:)
                   name:kApplicationDidBecomeActiveOnNotificationTap object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // make sure status icon is up-to-date
    [self markCloudStatusIcon];
    [self markNotificationStatusIcon];
}

#pragma Event handling

- (void)onCloudStatusButtonPressed:(id)sender {
    if (!self.enableNotificationsView) {
        return;
    }

    SFICloudStatusBarButtonItem *button = self.statusBarButton;
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
        NSInteger count = [[SecurifiToolkit sharedInstance] countUnviewedNotifications];
        [self.notificationsStatusButton markNotificationCount:(NSUInteger) count];
    }
}

- (void)markCloudStatusIcon {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    if ([toolkit isCloudConnecting]) {
        [self.statusBarButton markState:SFICloudStatusStateConnecting];
    }
    else if ([toolkit isCloudOnline]) {
        if (self.enableNotificationsView) {
            SFIAlmondMode mode = [toolkit modeForAlmond:self.almondMac];
            enum SFICloudStatusState state = [self stateForAlmondMode:mode];
            [self.statusBarButton markState:state];
        }
        else {
            [self.statusBarButton markState:SFICloudStatusStateConnected];
        }
    }
    else {
        [self.statusBarButton markState:SFICloudStatusStateAlmondOffline];
    }
}

- (enum SFICloudStatusState)stateForAlmondMode:(SFIAlmondMode)mode {
    switch (mode) {
        case SFIAlmondMode_home:
            return SFICloudStatusStateAtHome;
        case SFIAlmondMode_away:
            return SFICloudStatusStateAway;
        default:
            // should never happen
            return SFICloudStatusStateAtHome;
    }
}

#pragma mark Drawer management

- (void)markAlmondMac:(NSString *)almondMac {
    _almondMac = [almondMac copy];
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

@end
