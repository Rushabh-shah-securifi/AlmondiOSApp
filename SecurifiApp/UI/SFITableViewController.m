//
//  SFITableViewController.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import <SWRevealViewController/SWRevealViewController.h>
#import <SecurifiToolkit/SFIAlmondLocalNetworkSettings.h>
#import "SFITableViewController.h"
#import "SFICloudStatusBarButtonItem.h"
#import "UIFont+Securifi.h"
#import "SFINotificationsViewController.h"
#import "SFINotificationStatusBarButtonItem.h"
#import "UIApplication+SecurifiNotifications.h"
#import "SFIHuePickerView.h"
#import "AlertView.h"
#import "MDJSON.h"
#import "AlertViewAction.h"
#import "CommonMethods.h"
#import "SFIColors.h"
#import "UICommonMethods.h"

@interface SFITableViewController () <MBProgressHUDDelegate, SWRevealViewControllerDelegate, UIGestureRecognizerDelegate, AlertViewDelegate, UITabBarControllerDelegate, HelpScreensDelegate>
@property(nonatomic, readonly) SFINotificationStatusBarButtonItem *notificationsStatusButton;
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *connectionStatusBarButton;
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *almondModeBarButton;
@property(nonatomic) UIView *tableScrim;
// Saved when the keyboard shows and restored when keyboard hides
@property(nonatomic) UIEdgeInsets originalContentInsets;
@property(nonatomic) UIEdgeInsets originalScrollIndicatorInsets;
@property(nonatomic) AlertView *alert;

@end

@implementation SFITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _enableDrawer = YES;
        self.originalContentInsets = UIEdgeInsetsZero;
        self.originalScrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];    
    
    SecurifiConfigurator *configurator = toolkit.configuration;
    _enableNotificationsView = configurator.enableNotifications;
    _enableNotificationsHomeAwayMode = configurator.enableNotificationsHomeAwayMode;
    const BOOL enableLocalNetworking = configurator.enableLocalNetworking;
    
    self.navigationController.navigationBar.translucent = NO;
    
    
    if(self.needAddButton){
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_almond_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(onAddBtnTap:)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    else{
        
    }
    
    self.enableDrawer = _enableDrawer; // in case it was set before view loaded
    
    if (enableLocalNetworking) {
        _connectionStatusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onConnectionStatusButtonPressed:) enableLocalNetworking:YES isDashBoard:NO];
    }
    else {
        _connectionStatusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:nil action:nil enableLocalNetworking:NO isDashBoard:NO];
    }
    
    //
    if (self.enableNotificationsView) {
        
        _notificationsStatusButton = [[SFINotificationStatusBarButtonItem alloc] initWithTarget:self action:@selector(onShowNotifications:)];
        
        NSInteger count = [toolkit countUnviewedNotifications];
        [self.notificationsStatusButton markNotificationCount:(NSUInteger) count];
        
        // make the button but do not install; will be installed after connection state is determined
        NSLog(@"_almondModeBarButton");
        _almondModeBarButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onAlmondModeButtonPressed:) enableLocalNetworking:enableLocalNetworking isDashBoard:NO];
        [_almondModeBarButton markState:SFICloudStatusStateAtHome];
        
        [self setBarButtons:NO];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onAlmondModeDidChange:)
                   name:kSFIAlmondModeDidChange
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onNetworkDownNotifier:)
                   name:NETWORK_DOWN_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onNetworkConnectingNotifier:)
                   name:NETWORK_CONNECTING_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onNetworkConnectingNotifier:)
                   name:kSFIDidChangeAlmondConnectionMode
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
    
    //    [center addObserver:self
    //               selector:@selector(onAlmondModeChangeDidComplete:)
    //                   name:kSFIDidChangeCurrentAlmond
    //                 object:nil];
    //
    //    [center addObserver:self
    //               selector:@selector(onAlmondModeChangeDidComplete:)
    //                   name:kSFIDidCompleteAlmondModeChangeRequest
    //                 object:nil];
    
    
    
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
    // make sure status icon is up-to-date
    [self markNetworkStatusIcon];
    [self markNotificationStatusIcon];
    
    // install self as delegate so this controller can enable/disable drawer
    SWRevealViewController *ctrl = [self revealViewController];
    ctrl.delegate = self;
    ctrl.panGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        // make sure HUD is released from nav controller
        [self.HUD removeFromSuperview];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    ELog(@"%s, Did receive memory warning", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}

#pragma Event handling
- (void)onAddBtnTap:(id)sender{
    NSLog(@"on add btn tap");
}

- (void)onConnectionStatusButtonPressed:(id)sender {
    self.alert = [AlertView new];
    _alert.delegate = self;
    _alert.backgroundColor = [UIColor whiteColor];
    
    SFICloudStatusState statusState = self.connectionStatusBarButton.state;
    NSLog(@"statusState cloud status %lu",(unsigned long)statusState);
    switch (statusState) {
        case SFICloudStatusStateConnecting: {
            _alert.message = NSLocalizedString(@"In process of connecting. Change connection method.", @"In process of connecting. Change connection method.");
            _alert.actions = @[
                               [AlertViewAction actionWithTitle:NSLocalizedString(@"connection status Cloud Connection", @"Cloud Connection") handler:^(AlertViewAction *action) {
                                   [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                               }],
                               [AlertViewAction actionWithTitle:NSLocalizedString(@"connection status Local Connection", "Connection") handler:^(AlertViewAction *action) {
                                   [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                               }]
                               ];
            break;
        };
            
        case SFICloudStatusStateConnected: {
            SFIAlmondLocalNetworkSettings *settings = [[SecurifiToolkit sharedInstance] localNetworkSettingsForAlmond:self.almondMac];
            if (settings) {
                _alert.message = NSLocalizedString(@"alert.message-Connected to your Almond via cloud.", @"Connected to your Almond via cloud.");
                _alert.actions = @[
                                   [AlertViewAction actionWithTitle:NSLocalizedString(@"alert.title-Switch to Local Connection", @"Switch to Local Connection") handler:^(AlertViewAction *action) {
                                       [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                                   }],
                                   ];
            }
            else {
                _alert.message = NSLocalizedString(@"alertview-Connected to your Almond via cloud.", @"Connected to your Almond via cloud.");
                _alert.actions = @[
                                   [AlertViewAction actionWithTitle:NSLocalizedString(@"Add Local Connection Settings", @"Add Local Connection Settings") handler:^(AlertViewAction *action) {
                                       [self presentLocalNetworkSettingsEditor];
                                   }],
                                   ];
            }
            
            break;
        };
            
        case SFICloudStatusStateDisconnected:
        case SFICloudStatusStateAlmondOffline: {
            _alert.message = NSLocalizedString(@"Alert view fail-Cloud connection to your Almond failed. Tap retry or switch to local connection.", @"Cloud connection to your Almond failed. Tap retry or switch to local connection.");
            _alert.actions = @[
                               [AlertViewAction actionWithTitle:NSLocalizedString(@"Alert view title-Retry Cloud Connection", "Retry Cloud Connection") handler:^(AlertViewAction *action) {
                                   [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                               }],
                               [AlertViewAction actionWithTitle:NSLocalizedString(@"alert.title-Switch to Local Connection", @"Switch to Local Connection") handler:^(AlertViewAction *action) {
                                   [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                               }],
                               ];
            break;
        };
            
        case SFICloudStatusStateAway:
        case SFICloudStatusStateAtHome:
            // should not be possible state for this button
            return;
            
        case SFICloudStatusStateConnectionError: {
            _alert.message = NSLocalizedString(@"Can't connect to your Almond. Please select a connection method.", @"Can't connect to your Almond. Please select a connection method.");
            _alert.actions = @[
                               [AlertViewAction actionWithTitle:NSLocalizedString(@"alert view error_Cloud Connection", @"Cloud Connection") handler:^(AlertViewAction *action) {
                                   [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                               }],
                               [AlertViewAction actionWithTitle:NSLocalizedString(@"alert view error_Local Connection", @"Local Connection") handler:^(AlertViewAction *action) {
                                   [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                               }]
                               ];
            break;
        };
        case SFICloudStatusStateLocalConnection: {
            SFIAlmondLocalNetworkSettings *settings = [[SecurifiToolkit sharedInstance] localNetworkSettingsForAlmond:self.almondMac];
            if (settings) {
                _alert.message = NSLocalizedString(@"Connected to your Almond locally.", @"Connected to your Almond locally.");
                _alert.actions = @[
                                   [AlertViewAction actionWithTitle:NSLocalizedString(@"alertview localconnection_Switch to Cloud Connection", @"Switch to Cloud Connection")
                                                            handler:^(AlertViewAction *action) {
                                                                [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                                                            }]
                                   ];
            }
            else {
                _alert.message = NSLocalizedString(@"alert msg offline Local connection not supported.", @"Local connection settings are missing.");
                _alert.actions = @[
                                   [AlertViewAction actionWithTitle:NSLocalizedString(@"Add Local Connection Settings", @"Add Local Connection Settings") handler:^(AlertViewAction *action) {
                                       [self presentLocalNetworkSettingsEditor];
                                   }]
                                   ];
            }
            
            break;
        };
            
        case SFICloudStatusStateLocalConnectionOffline: {
            _alert.message = NSLocalizedString(@"local_conn_failed_retry", "Local connection to your Almond failed. Tap retry or switch to cloud connection.");
            _alert.actions = @[
                               [AlertViewAction actionWithTitle:NSLocalizedString(@"alert title offline Local Retry Local Connection", @"Retry Local Connection") handler:^(AlertViewAction *action) {
                                   [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                               }],
                               [AlertViewAction actionWithTitle:NSLocalizedString(@"alertview localconnection_Switch to Cloud Connection", @"Switch to Cloud Connection") handler:^(AlertViewAction *action) {
                                   [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                               }],
                               ];
            break;
        };
            
        case SFICloudStatusStateCloudConnectionNotSupported: {
            _alert.message = NSLocalizedString(@"cloud_conn_not_supported", "Your Almond is not affiliated with the cloud. Only local connection to your Almond is supported.");
            _alert.actions = @[
                               [AlertViewAction actionWithTitle:NSLocalizedString(@"alert.title-Switch to Local Connection", @"Switch to Local Connection") handler:^(AlertViewAction *action) {
                                   [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                               }],
                               ];
            break;
        }
            
        case SFICloudStatusStateLocalConnectionNotSupported: {
            _alert.message = NSLocalizedString(@"alert msg offline Local connection not supported.", "Can't connect to your Almond because local connection settings are missing. Tap edit to add settings.");
            _alert.actions = @[
                               [AlertViewAction actionWithTitle:NSLocalizedString(@"alertview localconnection_Switch to Cloud Connection", @"Switch to Cloud Connection") handler:^(AlertViewAction *action) {
                                   [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                               }],
                               ];
            break;
        }
            
        default:
            return;
    }
    
    [self onLockTable];
    
    CGRect rect = self.navigationController.navigationBar.frame;
    CGFloat height = 180;
    if (_alert.actions.count > 2) {
        height = height + ((_alert.actions.count - 2) * 50);
    }
    
    CGRect frame = CGRectMake(0, rect.size.height + 20, rect.size.width, height);
    _alert.frame = frame;
    
    _alert.alpha = 0.0;
    [self.navigationController.view addSubview:_alert];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         _alert.alpha = 0.9;
                     }
                     completion:nil
     ];
}

- (SFIAlmondConnectionMode)currentConnectionMode {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    return [toolkit connectionModeForAlmond:self.almondMac];
}

- (void)configureNetworkSettings:(enum SFIAlmondConnectionMode)mode {
    NSLog(@"configureNetworkSettings handler method ");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit setConnectionMode:mode forAlmond:self.almondMac];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:@"Connecting..."];
        [self.HUD hide:YES afterDelay:5]; // in case the request times out
        
        [toolkit.devices removeAllObjects];
        [toolkit.clients removeAllObjects];
        [toolkit.scenesArray removeAllObjects];
        [toolkit.ruleList removeAllObjects];
        
        [self.tableView reloadData];
    });
    
}

- (void)onAlmondModeButtonPressed:(id)sender {
    //    if (!self.enableNotificationsView) {
    //        return;
    //    }
    
    SFICloudStatusBarButtonItem *button = self.almondModeBarButton;
    SFICloudStatusState state = button.state;
    NSLog(@"onAlmondModeButtonPressed mode stat %lu",(unsigned long)state);
    enum SFIAlmondMode newMode;
    NSString *msg;
    
    if (state == SFICloudStatusStateAtHome) {
        newMode = SFIAlmondMode_away;
        msg = NSLocalizedString(@"hud message-Setting Almond to Away Mode", "Setting Almond to Away Mode");
    }
    else if (state == SFICloudStatusStateAway) {
        newMode = SFIAlmondMode_home;
        msg = NSLocalizedString(@"hud message-Setting Almond to Home Mode", "Setting Almond to Home Mode");
    }
    else {
        return;
    }
    
    // if the hud is already being shown then ignore the button press
    //    if (!self.isHudHidden) {
    //        return;
    //    }
    NSLog(@"showHUD ");
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self showHUD:msg];
        [self.HUD hide:YES afterDelay:10]; // in case the request times out
    });
    
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit asyncRequestAlmondModeChange:self.almondMac mode:newMode];
}

- (void)onAlmondModeChangeDidComplete:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
        [self.HUD hide:YES];
    });
}

- (void)onAlmondModeDidChange:(id)sender {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSLog(@"payload mode %@",dataInfo);
    BOOL local = [toolkit useLocalNetwork:toolkit.currentAlmond.almondplusMAC];
    NSDictionary *payload;
    
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        NSLog(@"cloud data");
        payload = [dataInfo valueForKey:@"data"];
    }
    //    [self.HUD hide:YES];
    dispatch_async(dispatch_get_main_queue(), ^() {
        //        if (self.presentedViewController != nil) {
        //            return;
        //        }
        NSLog(@"payload mode %@",payload);
        if([payload[@"CommandType"] isEqualToString:@"DynamicAlmondModeUpdated"]){
            [self.HUD hide:YES];
        }
        NSString *m = payload[@"Mode"];
        NSLog(@"m = %@",m);
        NSLog(@"mode m= %ld",(long)[m integerValue]);
        SFIAlmondMode mode = (unsigned)[m integerValue];
        NSLog(@"almond mode change");
        
        NSString *name = [m isEqualToString:@"2"]?@"almond_mode_home":@"almond_mode_away";
        
        UIImage *image = [UIImage imageNamed:name];
//        UIColor *color = [UIColor blackColor];
//        [self.almondModeBarButton modeUpdate:image color:color mode:m];
//        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        spacer.width = 25;
        
//        self.navigationItem.rightBarButtonItems = @[self.connectionStatusBarButton, spacer, self.almondModeBarButton, spacer, self.notificationsStatusButton];
        
        
        
        //        [self markNetworkStatusIcon];
    });
}

- (void)onShowNotifications:(id)onShowNotifications {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.presentedViewController != nil) {
            return;
        }
        
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        
        SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        ctrl.enableDebugMode = toolkit.configuration.enableNotificationsDebugMode;
        
        UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        [self presentViewController:nav_ctrl animated:YES completion:nil];
    });
}

- (void)onNetworkUpNotifier:(id)sender {
    NSLog(@"onNetworkUpNotifier");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
        //        [self.tableView reloadData];
        //        [self.HUD hide:YES]; // make sure it is hidden
    });
}

- (void)onNetworkDownNotifier:(id)sender {
    NSLog(@"onNetworkDownNotifier");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
        [self.tableView reloadData];
        [self.HUD hide:YES]; // make sure it is hidden
    });
}

- (void)onNetworkConnectingNotifier:(id)notification {
    NSLog(@"onNetworkConnectingNotifier");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
    });
}

- (void)onReachabilityDidChange:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
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

- (void)markNetworkStatusIcon {
    NSString *const almondMac = self.almondMac;
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    enum SFIAlmondConnectionMode connectionMode = [toolkit connectionModeForAlmond:almondMac];
    enum SFIAlmondConnectionStatus status = [toolkit connectionStatusForAlmond:almondMac];
    
    switch (status) {
        case SFIAlmondConnectionStatus_disconnected: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateDisconnected : SFICloudStatusStateLocalConnectionOffline;
            [self.connectionStatusBarButton markState:state];
            [self hideAlmondModeButton]; // when disconnected, not relevant to show mode or allow it to be changed
            break;
        };
        case SFIAlmondConnectionStatus_connecting: {
            [self.connectionStatusBarButton markState:SFICloudStatusStateConnecting];
            [self hideAlmondModeButton]; // when connecting, true almond state is unknown
            break;
        };
        case SFIAlmondConnectionStatus_connected: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateConnected : SFICloudStatusStateLocalConnection;
            [self.connectionStatusBarButton markState:state];
            
            if (self.enableNotificationsHomeAwayMode) {
                SFIAlmondMode mode = [toolkit modeForAlmond:almondMac];
                
                if (mode == SFIAlmondMode_unknown) {
                    [self hideAlmondModeButton]; // don't show button unless one is known
                }
                else {
                    state = [self stateForAlmondMode:mode];
                    [self.almondModeBarButton markState:state];
                    [self showAlmondModeButton];
                }
            }
            break;
        };
        case SFIAlmondConnectionStatus_error: {
            [self hideAlmondModeButton]; // when connection error, true almond state is unknown
            break;
        };
        case SFIAlmondConnectionStatus_error_mode: {
            enum SFICloudStatusState state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateCloudConnectionNotSupported : SFICloudStatusStateLocalConnectionNotSupported;
            [self.connectionStatusBarButton markState:state];
            [self hideAlmondModeButton]; // when disconnected, not relevant to show mode or allow it to be changed
            break;
        }
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

- (void)setBarButtons:(BOOL)showAlmondHome {
    UIBarButtonItem *spacer = [self getBarButton:25];
    UIBarButtonItem *interSpace = [self getBarButton:10];
    self.navigationItem.leftBarButtonItems = @[self.connectionStatusBarButton,interSpace, self.notificationsStatusButton, spacer];
}

-(UIBarButtonItem *)getBarButton:(CGFloat)width{
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barButton.width = width;
    return barButton;
}

- (void)hideAlmondModeButton {
    if (!self.enableNotificationsHomeAwayMode) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self setBarButtons:NO];
    });
}

- (void)showAlmondModeButton {
    //    if (!self.enableNotificationsHomeAwayMode) {
    //        return;
    //    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self setBarButtons:YES];
    });
    //    [self setBarButtons:NO];
}

#pragma mark Drawer management

- (void)markAlmondMac:(NSString *)almondMac {
    _almondMac = [almondMac copy];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
    });
}

- (void)markTitle:(NSString *)title {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if(titleView == nil)
        return;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
    
    // Set the width of the views according to the text size
    CGSize bar_size = self.navigationController.navigationBar.frame.size;
    CGRect frame;
    
    frame = titleLabel.frame;
    frame.size = bar_size;
    titleLabel.frame = frame;
    
    frame = titleView.frame;
    frame.size = bar_size;
    titleView.frame = frame;
    // Ensure text is on one line, centered and truncates if the bounds are restricted
    titleLabel.numberOfLines = 1;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    // Use autoresizing to restrict the bounds to the area that the titleview allows
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleView.autoresizesSubviews = YES;
    titleLabel.autoresizingMask = titleView.autoresizingMask;
    
    // Set the text
    if (!title) {
        title = @"";
    }
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
                                 NSFontAttributeName : [UIFont standardNavigationTitleFont]
                                 };
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    titleLabel.attributedText = str;
    
    [titleView addSubview:titleLabel];
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.navigationItem.titleView = titleView;
    });
    
}

- (void)showHUD:(NSString *)text {
    _isHudHidden = NO;
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

- (void)showLoadingRouterDataHUD {
    [self showHUD:NSLocalizedString(@"mainviewcontroller hud Loading router data", @"Loading router data")];
}

- (void)showLoadingSensorDataHUD {
    [self showHUD:NSLocalizedString(@"mainviewcontroller hud Loading sensor data", @"Loading sensor data")];
}

- (void)showUpdatingSettingsHUD {
    [self showHUD:NSLocalizedString(@"mainviewcontroller hud hud.Updating settings...", @"Updating settings...")];
}

- (void)setEnableDrawer:(BOOL)enableDrawer {
    _enableDrawer = enableDrawer;
    self.navigationItem.leftBarButtonItem.enabled = enableDrawer;
}

- (void)presentLocalNetworkSettingsEditor {
    NSString *mac = self.almondMac;
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondLocalNetworkSettings *settings = [toolkit localNetworkSettingsForAlmond:mac];
    NSLog(@"sfitableview - presentlocalnetwork - mac: %@, settings: %@", mac, settings);
    if (!settings) {
        settings = [SFIAlmondLocalNetworkSettings new];
        settings.almondplusMAC = mac;
    }
    
    RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
    editor.delegate = self;
    editor.settings = settings;
    editor.enableUnlinkActionButton = ![toolkit almondExists:mac]; // only allowed to unlink local almonds that are not affiliated with the cloud
    
    UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:ctrl animated:YES completion:nil];
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
    dispatch_async(dispatch_get_main_queue(), ^() {
        // once we have copied insets, do not overwrite
        if (UIEdgeInsetsEqualToEdgeInsets(self.originalContentInsets, UIEdgeInsetsZero)) {
            self.originalContentInsets = self.tableView.contentInset;
        }
        if (UIEdgeInsetsEqualToEdgeInsets(self.originalScrollIndicatorInsets, UIEdgeInsetsZero)) {
            self.originalScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        }
        
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
    });
}

// restore original table offsets
- (void)keyboardWillHide:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^() {
        NSNumber *rate = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        [UIView animateWithDuration:rate.floatValue animations:^{
            self.tableView.contentInset = self.originalContentInsets;
            self.tableView.scrollIndicatorInsets = self.originalScrollIndicatorInsets;
        }];
    });
}

#pragma mark - AlertViewDelegate methods
-(void)removeAlert{
    [self alertViewDidCancel:_alert];
}

- (void)alertView:(AlertView *)view didSelectAction:(AlertViewAction *)action {
    [view removeFromSuperview];
    [self onUnlockTable];
    [action invoke];
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

#pragma mark - RouterNetworkSettingsEditorDelegate methods

- (void)networkSettingsEditorDidLinkAlmond:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    
}

- (void)networkSettingsEditorDidChangeSettings:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit setLocalNetworkSettings:newSettings];
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidCancel:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidComplete:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidUnlinkAlmond:(RouterNetworkSettingsEditor *)editor {
    NSString *almondMac = editor.settings.almondplusMAC;
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit removeLocalNetworkSettingsForAlmond:almondMac];
    
    [self.tableView reloadData];
    [editor dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark helpscreens
-(void)initializeHelpScreensfirst:(NSString *)itemName{
    NSLog(@"nav view heigt: %f, view ht: %f", self.navigationController.view.frame.size.height, self.view.frame.size.height);
    //dont localize any thing here
    if([itemName isEqualToString:@"Devices"])
        [[SecurifiToolkit sharedInstance] setScreenDefault:@"devices"];
    else if([itemName isEqualToString:@"Scenes"])
        [[SecurifiToolkit sharedInstance] setScreenDefault:@"scenes"];
    else if([itemName isEqualToString:@"rules"])
        [[SecurifiToolkit sharedInstance] setScreenDefault:@"rules"];
    else if([itemName isEqualToString:@"wifi"])
        [[SecurifiToolkit sharedInstance] setScreenDefault:@"wifi"];
    
    
    self.maskView = [[UIView alloc]init];
    self.helpScreensObj = [HelpScreens initializeHelpScreen:self.navigationController.view isOnMainScreen:YES startScreen:[CommonMethods getDict:@"Quick_Tips" itemName:itemName]];
    self.helpScreensObj.delegate = self;
    
    [self.navigationController.view addSubview:self.helpScreensObj];
    [self.tabBarController.tabBar setHidden:YES];
}


- (void)showOkGotItView{
    self.maskView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height);
    [self.maskView setBackgroundColor:[SFIColors maskColor]];
    [self.navigationController.view addSubview:self.maskView];

    [HelpScreens initializeGotItView:self.helpScreensObj navView:self.navigationController.view];
    [self.maskView addSubview:self.helpScreensObj];
}

#pragma mark helpscreens delegate methods

- (void)resetViewDelegate{
    NSLog(@"table view");
    [self.maskView removeFromSuperview];
    [self.helpScreensObj removeFromSuperview]; //perhaps you should also remove subviews
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)onSkipTapDelegate{
    [self.tabBarController.tabBar setHidden:YES];
    [self showOkGotItView];
}


@end
