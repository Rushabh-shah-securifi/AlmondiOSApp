//
//  SFITableViewController.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
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
#import "UIImage+Securifi.h"
#import "SFICloudLinkViewController.h"
#import "ConnectionStatus.h"
#import "LocalNetworkManagement.h"
#import "NotificationAccessAndRefreshCommands.h"
#import "NetworkStatusIcon.h"


@interface SFITableViewController () <MBProgressHUDDelegate, UIGestureRecognizerDelegate, AlertViewDelegate, UITabBarControllerDelegate, HelpScreensDelegate, MessageViewDelegate, NetworkStatusIconDelegate>
@property(nonatomic, readonly) SFINotificationStatusBarButtonItem *notificationsStatusButton;
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *connectionStatusBarButton;

@property(nonatomic) UIView *tableScrim;
// Saved when the keyboard shows and restored when keyboard hides
@property(nonatomic) UIEdgeInsets originalContentInsets;
@property(nonatomic) UIEdgeInsets originalScrollIndicatorInsets;
@property(nonatomic) AlertView *alert;
@property(nonatomic) NetworkStatusIcon* statusIcon;
@end


@implementation SFITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.originalContentInsets = UIEdgeInsetsZero;
        self.originalScrollIndicatorInsets = UIEdgeInsetsZero;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _statusIcon = [NetworkStatusIcon new];
    _statusIcon.networkStatusIconDelegate = self;
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
    
    if (enableLocalNetworking) {
        _connectionStatusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onConnectionStatusButtonPressed:) enableLocalNetworking:YES isDashBoard:NO];
    }
    else {
        _connectionStatusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:nil action:nil enableLocalNetworking:NO isDashBoard:NO];
    }
    
    //
    if (self.enableNotificationsView) {
        
        _notificationsStatusButton = [[SFINotificationStatusBarButtonItem alloc] initWithTarget:self action:@selector(onShowNotifications:)];
        
        NSInteger count = [NotificationAccessAndRefreshCommands countUnviewedNotifications];
        [self.notificationsStatusButton markNotificationCount:(NSUInteger) count];
        
        // make the button but do not install; will be installed after connection state is determined
        NSLog(@"_almondModeBarButton");
        [self setBarButtons];
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
               selector:@selector(onConnectionStatusChanged:)
                   name:CONNECTION_STATUS_CHANGE_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onNetworkConnectingNotifier:)
                   name:kSFIDidChangeAlmondConnectionMode
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
    NSLog(@"View will appear is called in SFITableViewController");
    [self markNotificationStatusIcon];
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

-(void) showNetworkTogglePopUp:(NSString*)title withSubTitle1:(NSString*)subTitle1 withSubTitle2:(NSString*)subTitle2 withMode1:(SFIAlmondConnectionMode)mode1 withMode2:(SFIAlmondConnectionMode)mode2 presentLocalNetworkSettingsEditor:(BOOL)present{
    
    self.alert = [AlertView new];
    _alert.delegate = self;
    _alert.backgroundColor = [UIColor whiteColor];
    NSLog(@"showNetworkTogglePopUp delegate is called");
    _alert.message = title;
    NSLog(@"%@ %@ %@ data to be displayed",title,subTitle1, subTitle2);
    if(subTitle1.length!=0 && subTitle2.length!=0){
        _alert.actions = @[
                           [AlertViewAction actionWithTitle:subTitle1 handler:^(AlertViewAction *action) {
                               if(present)
                                   [self presentLocalNetworkSettingsEditor];
                               else
                                   [self configureNetworkSettings:mode1];
                           }],
                           [AlertViewAction actionWithTitle:subTitle2 handler:^(AlertViewAction *action) {
                               [self configureNetworkSettings:mode2];
                           }],
                           ];
    }
    
    if(subTitle2.length == 0){
        _alert.actions = @[
                           [AlertViewAction actionWithTitle:subTitle1 handler:^(AlertViewAction *action) {
                               [self configureNetworkSettings:mode1];
                           }],
                           ];
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

- (void)onConnectionStatusButtonPressed:(id)sender {
    [_statusIcon onConnectionStatusButtonPressed];
}

- (SFIAlmondConnectionMode)currentConnectionMode {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    return [toolkit currentConnectionMode];
}

- (void)configureNetworkSettings:(enum SFIAlmondConnectionMode)mode {
    NSLog(@"configureNetworkSettings handler method ");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit setConnectionMode:mode];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:@"Connecting..."];
        [self.HUD hide:YES afterDelay:5]; // in case the request times out
        [self.tableView reloadData];
    });
}


- (void)onAlmondModeChangeDidComplete:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [_statusIcon markNetworkStatusIcon:self.connectionStatusBarButton isDashBoard:NO];
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


-(void)onConnectionStatusChanged:(id)sender {
    NSNumber* status = [sender object];
    int statusIntValue = [status intValue];
    if(statusIntValue == NO_NETWORK_CONNECTION){
        dispatch_async(dispatch_get_main_queue(), ^() {
            [_statusIcon markNetworkStatusIcon:self.connectionStatusBarButton isDashBoard:NO];
            [self.tableView reloadData];
            [self.HUD hide:YES]; // make sure it is hidden
        });
    }else if(statusIntValue == IS_CONNECTING_TO_NETWORK){
        dispatch_async(dispatch_get_main_queue(), ^() {
            [_statusIcon markNetworkStatusIcon:self.connectionStatusBarButton isDashBoard:NO];
            [self showConnectingHUD];
        });
    }else if(statusIntValue == AUTHENTICATED){
        dispatch_async(dispatch_get_main_queue(), ^() {
        [_statusIcon markNetworkStatusIcon:self.connectionStatusBarButton isDashBoard:NO];
        [self.HUD hide:YES];
         NSLog(@"dashboardconnection status is connecting to network");
        });
    }
}

- (void)onNetworkConnectingNotifier:(id)notification {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [_statusIcon markNetworkStatusIcon:self.connectionStatusBarButton isDashBoard:NO];
    });
}


- (void)onNotificationCountChanged:(id)event {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNotificationStatusIcon];
    });
}

- (void)markNotificationStatusIcon {
    if (self.enableNotificationsView) {
        NSInteger badgeCount = [NotificationAccessAndRefreshCommands notificationsBadgeCount];
        [self.notificationsStatusButton markNotificationCount:(NSUInteger) badgeCount];
    }
}

- (void)setBarButtons{
    UIBarButtonItem *spacer = [self getBarButton:20];
    self.navigationItem.leftBarButtonItems = @[self.connectionStatusBarButton,spacer, self.notificationsStatusButton, spacer];
}

-(UIBarButtonItem *)getBarButton:(CGFloat)width{
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barButton.width = width;
    return barButton;
}

#pragma mark cell methods

-(BOOL)isFirmwareCompatible{
    return [SFIAlmondPlus checkIfFirmwareIsCompatible:[SecurifiToolkit sharedInstance].currentAlmond];
}

- (UITableViewCell *)createAlmondOfflineCell:(UITableView *)tableView {
    static NSString *cell_id = @"NoAlmondConnect";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat width = self.tableView.frame.size.width;
        
        UIImageView *imgRouter = [[UIImageView alloc] initWithFrame:CGRectMake(width / 2 - 50, 150, 100, 100)];
        imgRouter.userInteractionEnabled = NO;
        imgRouter.image = [UIImage imageNamed:@"offline_150x150"];
        imgRouter.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:imgRouter];
        
        CGRect frame = CGRectMake(0, 280, width, 100);
        frame = CGRectInset(frame, 20, 0);
        
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont securifiBoldFont:20];
        //Sorry! Unable to connect to cloud server.
        label.text = NSLocalizedString(@"router Sorry, Your Almond cannot be reached for now.r", @"Sorry, Your Almond cannot be reached for now.");
        label.textColor = [UIColor grayColor];
        [cell addSubview:label];
    }
    
    return cell;
}

- (UITableViewCell *)createAlmondUpdateAvailableCell:(UITableView *)tableView{
    static NSString *update_cell_id = @"AlmondUpdate";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:update_cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:update_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createCellWithMsg:@"The Almond firmware needs to be updated to remain compatible with this version of the app." cell:cell];
    }
    return cell;
}

- (UITableViewCell *)createEmptyCell:(UITableView *)tableView {
    NSLog(@"emptycell");
    static NSString *empty_cell_id = @"EmptyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:empty_cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empty_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createCellWithText:NSLocalizedString(@"noSensors", @"You don't have any sensors yet.") subText:NSLocalizedString(@"router.no-sensors.label.Add a sensor from your Almond.", @"Add a sensor from your Almond.") cell:cell];
        
    }
    
    return cell;
}

- (void)createCellWithMsg:(NSString *)msg cell:(UITableViewCell *)cell{
    const CGFloat table_width = CGRectGetWidth(self.tableView.frame);
    
    UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(5, 100, table_width-10, 90)];
    lblNoSensor.textAlignment = NSTextAlignmentCenter;
    [lblNoSensor setFont:[UIFont securifiFont:20]];
    lblNoSensor.text = msg;
    lblNoSensor.numberOfLines = 0;
    lblNoSensor.textColor = [UIColor blackColor];
    [cell addSubview:lblNoSensor];
}

- (void)createCellWithText:(NSString *)text subText:(NSString *)subText cell:(UITableViewCell *)cell{
    const CGFloat table_width = CGRectGetWidth(self.tableView.frame);
    
    UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, table_width, 30)];
    lblNoSensor.textAlignment = NSTextAlignmentCenter;
    [lblNoSensor setFont:[UIFont securifiFont:20]];
    lblNoSensor.text = text;
    lblNoSensor.numberOfLines = 0;
    lblNoSensor.textColor = [UIColor grayColor];
    [cell addSubview:lblNoSensor];
    
    UILabel *lblAddSensor = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lblNoSensor.frame) + 15 , table_width - 20, 60)];
    lblAddSensor.textAlignment = NSTextAlignmentCenter;
    [lblAddSensor setFont:[UIFont standardHeadingFont]];
    lblAddSensor.text = subText;
    lblAddSensor.textColor = [UIColor grayColor];
    lblAddSensor.numberOfLines = 0;
    [cell addSubview:lblAddSensor];
}
#pragma mark Drawer management

- (void)markAlmondMac:(NSString *)almondMac {
    _almondMac = [almondMac copy];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [_statusIcon markNetworkStatusIcon:self.connectionStatusBarButton isDashBoard:NO];
    });
}



//previous mark title has issues
-(void)markNewTitle:(NSString *)title{
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
                                 NSFontAttributeName : [UIFont standardNavigationTitleFont]
                                 };
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.navigationItem.title = title;
    });
}

- (void)showHUD:(NSString *)text {
    _isHudHidden = NO;
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

- (void)showConnectingHUD {
    [self showHUD:@"Connecting, Please wait..."];
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

- (void)presentLocalNetworkSettings{
    RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
    editor.delegate = self;
    editor.makeLinkedAlmondCurrentOne = YES;
    
    UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:editor];
    
    [self presentViewController:ctrl animated:YES completion:nil];
}

- (void)presentLocalNetworkSettingsEditor {
    NSLog(@"almond mac: %@", self.almondMac);
    NSString *mac = self.almondMac;
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondLocalNetworkSettings *settings = [LocalNetworkManagement localNetworkSettingsForAlmond:mac];
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

#pragma mark - UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    UIView *view = touch.view;
    // prevent recognizing touches on the slider
    return ![view isKindOfClass:[UISlider class]] && ![view isKindOfClass:[SFIHuePickerView class]];
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
        self.notificationsStatusButton.enabled = NO;
        self.connectionStatusBarButton.enabled = NO;
        [self installScrimView];
    });
}

- (void)onUnlockTable {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.tabBarController.delegate = nil; // uninstall delegate so tabs can be selected
        self.tableView.scrollEnabled = YES;
        self.notificationsStatusButton.enabled = YES;
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
    NSLog(@"Link 1");
}

- (void)networkSettingsEditorDidChangeSettings:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    NSLog(@"Link 2");

    [LocalNetworkManagement storeLocalNetworkSettings:newSettings];
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidCancel:(RouterNetworkSettingsEditor *)editor {
    NSLog(@"Link 3");
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidComplete:(RouterNetworkSettingsEditor *)editor {
    NSLog(@"Link 4");
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidUnlinkAlmond:(RouterNetworkSettingsEditor *)editor {
    NSLog(@"Link 5");
    NSString *almondMac = editor.settings.almondplusMAC;
    
    [LocalNetworkManagement removeLocalNetworkSettingsForAlmond:almondMac];
    
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
    else if([itemName isEqualToString:@"wifi"])
        [[SecurifiToolkit sharedInstance] setScreenDefault:@"wifi"];
    
    
    self.maskView = [[UIView alloc]init];
    self.helpScreensObj = [HelpScreens initializeHelpScreen:self.navigationController.view isOnMainScreen:YES startScreen:[CommonMethods getDict:@"Quick_Tips" itemName:itemName]];
    self.helpScreensObj.delegate = self;
    
    [self.tabBarController.view addSubview:self.helpScreensObj];
    //    [self.tabBarController.tabBar setHidden:YES];
}


- (void)showOkGotItView{
    self.maskView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height);
    [self.maskView setBackgroundColor:[SFIColors maskColor]];
    [self.tabBarController.view addSubview:self.maskView];
    
    [HelpScreens initializeGotItView:self.helpScreensObj navView:self.navigationController.view];
    [self.maskView addSubview:self.helpScreensObj];
}

#pragma mark helpscreens delegate methods

- (void)resetViewDelegate{
    NSLog(@"table view");
    [self.maskView removeFromSuperview];
    [self.helpScreensObj removeFromSuperview]; //perhaps you should also remove subviews
    //    [self.tabBarController.tabBar setHidden:NO];
}

- (void)onSkipTapDelegate{
    //    [self.tabBarController.tabBar setHidden:YES];
    [self showOkGotItView];
}



#pragma mark - messageview methods
- (MessageView *)addMessagegView{
    MessageView *view = [MessageView linkRouterMessage];
    view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 400);
    view.delegate = self;
    return view;
}

#pragma mark - MessageViewDelegate methods
- (void)messageViewDidPressButton:(MessageView *)msgView {
    NSLog(@"i am called");
    enum SFIAlmondConnectionMode mode = [[SecurifiToolkit sharedInstance] currentConnectionMode];
    
    switch (mode) {
        case SFIAlmondConnectionMode_cloud: {
            UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
            [self presentViewController:ctrl animated:YES completion:nil];
            break;
        }
        case SFIAlmondConnectionMode_local: {
            RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
            editor.delegate = self;
            editor.makeLinkedAlmondCurrentOne = YES;
            
            UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:editor];
            
            [self presentViewController:ctrl animated:YES completion:nil];
            break;
        }
    }
}


@end
