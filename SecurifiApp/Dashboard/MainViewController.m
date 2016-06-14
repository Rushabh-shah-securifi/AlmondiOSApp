//
//  MainViewController.m
//  Dashbord
//
//  Created by Securifi Support on 03/05/16.
//  Copyright © 2016 Securifi. All rights reserved.
//
#import <MBProgressHUD/MBProgressHUD.h>
#import "SFIAlmondPlus.h"
#import "SWRevealViewController.h"
#import "DeviceListController.h"
#import "DeviceEditViewController.h"
#import "UIFont+Securifi.h"
#import "ClientPropertiesViewController.h"
#import "DeviceHeaderView.h"
#import "DeviceTableViewCell.h"
#import "GenericIndexUtil.h"
#import "DeviceParser.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "PerformanceTest.h"
#import "DevicePayload.h"
#import "ClientPayload.h"
#import "MessageView.h"
#import "SFICloudLinkViewController.h"
#import "SFICloudStatusBarButtonItem.h"
#import "MBProgressHUD.h"
#import "RouterPayload.h"
#import "SFINotificationsViewController.h"
#import "SFINotificationStatusBarButtonItem.h"
#import "AlertView.h"
#import "AlertViewAction.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "SettingsViewController.h"
#import "MainViewController.h"

@interface MainViewController (){
    NSArray *buttons;
    UIBarButtonItem *rightButton, *middleButton;
    SFIAlmondMode mode;
    UIImage *image6;
}
@property(nonatomic) SFICloudStatusBarButtonItem *leftButton;
@property(nonatomic) SecurifiToolkit *toolkit;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic, readonly) BOOL isHudHidden;
@property (nonatomic, strong, nullable) UIRefreshControl *refreshControl NS_AVAILABLE_IOS(6_0) __TVOS_PROHIBITED;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //image6 = [UIImage imageNamed:@"connection_local_success"];
    SecurifiConfigurator *configurator = _toolkit.configuration;
    _enableNotificationsView = configurator.enableNotifications;
    _enableNotificationsHomeAwayMode = configurator.enableNotificationsHomeAwayMode;
    const BOOL enableLocalNetworking = configurator.enableLocalNetworking;

    UIImage *imgNav = [UIImage imageNamed:@"1224"];
    [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setTitle:@"Dashboard"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    rightButton = [[UIBarButtonItem alloc]
                   initWithImage:[UIImage imageNamed:@"setting_icon"]
                   style:UIBarButtonItemStylePlain
                   target:self
                   action:@selector(settingsAction:)];
    rightButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightButton;
    _leftButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onConnectionStatusButtonPressed:) enableLocalNetworking:YES];
    _leftButton.tintColor = [UIColor whiteColor];
    middleButton = [[UIBarButtonItem alloc]
                    initWithImage:[UIImage imageNamed:@"notification_home"]
                    style:UIBarButtonItemStylePlain
                    target:self
                    action:@selector(notificationAction:)];
    middleButton.tintColor = [UIColor whiteColor];
    buttons = @[_leftButton, middleButton];
    self.navigationItem.leftBarButtonItems = buttons;
    _labelAlmond.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goAlmond:)];
    [_labelAlmond addGestureRecognizer:tapGesture];
    [Scroller setScrollEnabled:YES];
    self.toolkit = [SecurifiToolkit sharedInstance];
    [self initializeNotification];
    [self markNetworkStatusIcon];
    if (enableLocalNetworking)
        _leftButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onConnectionStatusButtonPressed:) enableLocalNetworking:YES];
    else
        _leftButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:nil action:nil enableLocalNetworking:NO];
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
}

-(void)initializeNotification{
    if (self.toolkit.mode_src == 2) {
        middleButton.image = [UIImage imageNamed:@"notification_home"];
        UIImage *imgNav = [UIImage imageNamed:@"1224"];
        [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
        _labelHomeAway.hidden = YES;
        _labelHome.hidden = NO;
        [self.buttonHome setBackgroundColor:[UIColor colorWithRed:0.012 green:0.663 blue:0.957 alpha:1] ];
        [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
        self.bannerImage.image = [UIImage imageNamed:@"1225"];
    }else if(self.toolkit.mode_src == 3){
        middleButton.image = [UIImage imageNamed:@"notification_away"];
        UIImage *imgNav = [UIImage imageNamed:@"head_away"];
        [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
        _labelHomeAway.hidden = NO;
        _labelHome.hidden = YES;
        [self.buttonHomeAway setBackgroundColor:[UIColor colorWithRed:1 green:0.596 blue:0 alpha:1]];
        [self.buttonHome setBackgroundColor:[UIColor clearColor]];
        self.bannerImage.image = [UIImage imageNamed:@"main"];
    }
}

- (void)onCurrentAlmondChanged:(id)sender {
    [self.toolkit.devices removeAllObjects];
    [self.toolkit.clients removeAllObjects];
    [self initializeAlmondData];
    [self markNetworkStatusIcon];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.dashboardTable reloadData];
    });
}
-(void)initializeAlmondData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self tryInstallRefreshControl];
            [self viewWillAppear:YES];
        });
}

- (BOOL)isDeviceListEmpty {
    // don't show any tiles until there are values for the devices; no values == no way to fetch from almond
    return self.toolkit.devices.count == 0;
}

-(BOOL)isClientListEmpty{
    return self.toolkit.clients.count == 0;
}

- (void)tryInstallRefreshControl {
    if ([self isDeviceListEmpty] && [self isClientListEmpty]) {
        self.refreshControl = nil;
    }
    else {
        UIRefreshControl *refresh = [UIRefreshControl new];
        NSDictionary *attributes = self.navigationController.navigationBar.titleTextAttributes;
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Force device data refresh" attributes:attributes];
        //[refresh addTarget:self action:@selector(onRefreshSensorData:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
    }
}

- (void)showHudWithTimeoutMsg:(NSString*)hudMsg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:5];
    });
}

- (void)showHUD:(NSString *)text {
    _isHudHidden = NO;
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    _isHudHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        [self.HUD removeFromSuperview];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self initializeNotification];
    [super viewWillAppear:YES];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onAlmondModeDidChange:)
                   name:kSFIAlmondModeDidChange
                 object:nil];
    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];
    [center addObserver:self
               selector:@selector(onNetworkUpNotifier:)
                   name:NETWORK_UP_NOTIFIER
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
               selector:@selector(onReachabilityDidChange:)
                   name:kSFIReachabilityChangedNotification
                 object:nil];
    

    [self markNetworkStatusIcon];

    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.dashboardTable reloadData];
        if(self.toolkit.devices.count == 0 ){
            [self showHudWithTimeoutMsg:@"Loading Dashboard Devices"];
            [self viewWillAppear:YES];
            [self.dashboardTable reloadData];
        }
        if(self.toolkit.clients.count == 0 && self.toolkit.devices.count != 0){
            [self showHudWithTimeoutMsg:@"Loading Dashboard Clients"];
            [self viewWillAppear:YES];
            [self.dashboardTable reloadData];
        }

        _labelAlmond.text = self.toolkit.currentAlmond.almondplusName ;
        _smartHomeConnectedDevices.text = [NSString stringWithFormat:@"%lu ",(unsigned long)self.toolkit.devices.count ];
        _networkConnectedDevices.text =[NSString stringWithFormat:@"%lu ",(unsigned long)self.toolkit.clients.count ];
        _totalConnectedDevices.text = [NSString stringWithFormat: @"%ld", [_smartHomeConnectedDevices.text integerValue]+[_networkConnectedDevices.text integerValue]];
        if (self.toolkit.mode_src == 2) {
            middleButton.image = [UIImage imageNamed:@"notification_home"];
            UIImage *imgNav = [UIImage imageNamed:@"1224"];
            [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
            _labelHomeAway.hidden = YES;
            _labelHome.hidden = NO;
            [self.buttonHome setBackgroundColor:[UIColor colorWithRed:0.012 green:0.663 blue:0.957 alpha:1] ];
            [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
            self.bannerImage.image = [UIImage imageNamed:@"1225"];
        }else if(self.toolkit.mode_src == 3){
            middleButton.image = [UIImage imageNamed:@"notification_away"];
            UIImage *imgNav = [UIImage imageNamed:@"head_away"];
            [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
            _labelHomeAway.hidden = NO;
            _labelHome.hidden = YES;
            [self.buttonHomeAway setBackgroundColor:[UIColor colorWithRed:1 green:0.596 blue:0 alpha:1]];
            [self.buttonHome setBackgroundColor:[UIColor clearColor]];
            self.bannerImage.image = [UIImage imageNamed:@"main"];
        }

    });
   }

- (void)onNetworkUpNotifier:(id)sender {
    NSLog(@"onNetworkUpNotifier");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
    });
}
- (void)onNetworkDownNotifier:(id)sender {
    NSLog(@"onNetworkDownNotifier");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
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
    });
}

- (void)onAlmondModeDidChange:(id)sender {
    [self markNetworkStatusIcon];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    BOOL local = [toolkit useLocalNetwork:toolkit.currentAlmond.almondplusMAC];
    NSDictionary *payload;
    if(local)
        payload = [dataInfo valueForKey:@"data"];
    else
        payload = [dataInfo valueForKey:@"data"];
    dispatch_async(dispatch_get_main_queue(), ^() {
        NSString *m = payload[@"Mode"];
        mode = (unsigned)[m integerValue];
        if (mode == 2) {
            middleButton.image = [UIImage imageNamed:@"notification_home"];
            UIImage *imgNav = [UIImage imageNamed:@"1224"];
            [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
            _labelHomeAway.hidden = YES;
            _labelHome.hidden = NO;
            [self.buttonHome setBackgroundColor:[UIColor colorWithRed:0.012 green:0.663 blue:0.957 alpha:1] ];
            [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
            self.bannerImage.image = [UIImage imageNamed:@"1225"];
        }else if(mode == 3){
            middleButton.image = [UIImage imageNamed:@"notification_away"];
            UIImage *imgNav = [UIImage imageNamed:@"head_away"];
            [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
            _labelHomeAway.hidden = NO;
            _labelHome.hidden = YES;
            [self.buttonHomeAway setBackgroundColor:[UIColor colorWithRed:1 green:0.596 blue:0 alpha:1]];
            [self.buttonHome setBackgroundColor:[UIColor clearColor]];
            self.bannerImage.image = [UIImage imageNamed:@"main"];
        }
    });
}

-(void)goAlmond:(id)sender {
    enum SFIAlmondConnectionMode modeValue = [self.toolkit currentConnectionMode];
    NSArray *almondList = [self buildAlmondList:modeValue];
    
    UIAlertController *viewC;
    UIImage *image = [UIImage imageNamed:@"home_icon1"];
    viewC = [UIAlertController alertControllerWithTitle:@"selectAlmond" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    viewC.view.tintColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
    
    for(SFIAlmondPlus *name in almondList){
        UIAlertAction *Aname = [UIAlertAction
                                actionWithTitle:name.almondplusName
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action){
                                    //For selecting almond from list
                                    SFIAlmondPlus *currentAlmond = name;
                                    [[SecurifiToolkit sharedInstance] setCurrentAlmond:currentAlmond];
                                    
                                    _labelAlmond.text = name.almondplusName;
                                    //_labelAlmondStatus.text = @"MASTER";
                                    _labelAlmondStatus.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:14];
                                    _labelAlmond.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:18];
                                }];[Aname setValue:image forKey:@"image"];
        [viewC addAction:Aname];
    }
    UIAlertAction *AddNew = [UIAlertAction
                             actionWithTitle:@"+"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action){
                                 UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
                                 [self presentViewController:ctrl animated:YES completion:nil];
                             }];
    UIAlertAction *Check = [UIAlertAction
                            actionWithTitle:@"Close"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [viewC dismissViewControllerAnimated:YES completion:nil];
                            }];
    [viewC addAction:AddNew];
    [viewC addAction:Check];
    [self initializeNotification];
    [self presentViewController:viewC animated:YES completion:nil];
}
- (NSArray *)buildAlmondList:(enum SFIAlmondConnectionMode)mode5 {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    switch (mode5) {
        case SFIAlmondConnectionMode_cloud: {
            NSArray *cloud = [toolkit almondList];
            if (!cloud) {
                cloud = @[];
            }
            return cloud;
        }
        case SFIAlmondConnectionMode_local: {
            NSArray *local = [toolkit localLinkedAlmondList];
            if (!local) {
                local = @[];
            }
            return local;
        }
        default:
            return @[];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)homeMode:(id)sender {
    middleButton.image = [UIImage imageNamed:@"notification_home"];
    UIImage *imgNav = [UIImage imageNamed:@"1224"];
    [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
    _labelHomeAway.hidden = YES;
    _labelHome.hidden = NO;
    [self.buttonHome setBackgroundColor:[UIColor colorWithRed:0.012 green:0.663 blue:0.957 alpha:1] ];
    [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
    self.bannerImage.image = [UIImage imageNamed:@"1225"];
    mode = SFIAlmondMode_home;
    [_toolkit asyncRequestAlmondModeChange:self.toolkit.currentAlmond.almondplusMAC mode:mode];
}

- (IBAction)homeawayMode:(id)sender {
    middleButton.image = [UIImage imageNamed:@"notification_away"];
    
    UIImage *imgNav = [UIImage imageNamed:@"head_away"];
    [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
    _labelHomeAway.hidden = NO;
    _labelHome.hidden = YES;
    [self.buttonHomeAway setBackgroundColor:[UIColor colorWithRed:1 green:0.596 blue:0 alpha:1]];
    [self.buttonHome setBackgroundColor:[UIColor clearColor]];
    self.bannerImage.image = [UIImage imageNamed:@"main"];
    mode = SFIAlmondMode_away;
    [_toolkit asyncRequestAlmondModeChange:self.toolkit.currentAlmond.almondplusMAC mode:mode];
}

- (void)notificationAction:(id)sender {
    SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nav_ctrl animated:YES completion:nil];
}

- (void)settingsAction:(id)sender {
    SettingsViewController *root = [[UIStoryboard storyboardWithName:@"MainDashboard" bundle:nil]
                                    instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self presentViewController:root animated:YES completion:nil];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 && _toolkit.devices.count > 0){
        if (_toolkit.devices.count==1) {
            return 1;
        }
        if (_toolkit.devices.count==2) {
            return 2;
        }
        else{
            return 3;
        }
    }
    if (section == 1 && _toolkit.clients.count > 0){
        if (_toolkit.clients.count==1) {
            return 1;
        }
        if (_toolkit.clients.count==2) {
            return 2;
        }
        else{
            return 2;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.font = [UIFont fontWithName:@"AvenirLTStd-heavy" size:16];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier ];
    }
    if (indexPath.section == 0) {
        Device *device = [_toolkit.devices objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",device.name];
    }
    if(indexPath.section == 1){
        Client *client = [_toolkit.clients objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",client.name];
    }
    CGSize itemSize = CGSizeMake(25,25);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0,0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    if (section >0) {
        UITableViewHeaderFooterView *foot = (UITableViewHeaderFooterView *)view;
        CGRect sepFrame = CGRectMake(0, 0, 415, 1);
        UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame];
        seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:1.0];
        [foot addSubview:seperatorView];
    }
    NSString *string;
    switch (section) {
        case 0:
            string = @"SMART HOME ACTIVITY";
            break;
        case 1:
            string = @"NETWORK ACTIVITY";
            break;
    }
    label.text = string;
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    return view;
}

- (void)onConnectionStatusButtonPressed:(id)sender {
    UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"Almond Connection" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *Close = [UIAlertAction
                            actionWithTitle:@"Close"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [alert1 dismissViewControllerAnimated:YES completion:nil];
                            }];
    [alert1 addAction:Close];
    //_leftButton.image = image6;
    
    SFICloudStatusState statusState = self.leftButton.state;
    NSLog(@"statusState cloud status at dashboard %lu",(unsigned long)statusState);
    
    switch (statusState) {
        case SFICloudStatusStateConnecting: {
            alert1.title = NSLocalizedString(@"In process of connecting. Change connection method.", @"In process of connecting. Change connection method.");
            UIAlertAction *Check = [UIAlertAction
                                    actionWithTitle:@"Cloud Connection"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                                    }];
            [alert1 addAction:Check];
            UIAlertAction *Check1 = [UIAlertAction
                                    actionWithTitle:@"Local Connection"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                                    }];
            [alert1 addAction:Check1];
            [self presentViewController:alert1 animated:YES completion:nil];
            
        
            break;
        };
            
        case SFICloudStatusStateConnected: {
            SFIAlmondLocalNetworkSettings *settings = [[SecurifiToolkit sharedInstance] localNetworkSettingsForAlmond:self.toolkit.currentAlmond.almondplusMAC];
            if (settings) {
                alert1.title = NSLocalizedString(@"alert.message-Connected to your Almond via cloud.", @"Connected to your Almond via cloud.");
                UIAlertAction *Check = [UIAlertAction
                                        actionWithTitle:@"Switch to Local Connection"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                                        }];
                [alert1 addAction:Check];
                [self presentViewController:alert1 animated:YES completion:nil];
            }
            else{
                alert1.title = NSLocalizedString(@"alertview -Connected to your Almond via cloud.", @"Connected to your Almond via cloud.");
                UIAlertAction *Check = [UIAlertAction
                                        actionWithTitle:@"Add Local Connection Settings"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action)
                                        {
                                            [self presentLocalNetworkSettingsEditor];
                                        }];
                [alert1 addAction:Check];
                [self presentViewController:alert1 animated:YES completion:nil];
            }
                        break;
        };
        case SFICloudStatusStateDisconnected:
        case SFICloudStatusStateAlmondOffline: {
            alert1.title = NSLocalizedString(@"Alert view fail-Cloud connection to your Almond failed. Tap retry or switch to local connection.", @"Cloud connection to your Almond failed. Tap retry or switch to local connection.");
            UIAlertAction *Check = [UIAlertAction
                                    actionWithTitle:@"Switch to Local Connection"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                                    }];
            [alert1 addAction:Check];
            UIAlertAction *Check1 = [UIAlertAction
                                    actionWithTitle:@"Switch to Cloud Connection"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                                    }];
            [alert1 addAction:Check1];
            [self presentViewController:alert1 animated:YES completion:nil];
            
            break;
        };
        case SFICloudStatusStateAway:
        case SFICloudStatusStateAtHome:
            return;
            
        case SFICloudStatusStateConnectionError: {
            alert1.title = NSLocalizedString(@"alertview Can't connect to your Almond. Please select a connection method.", @"Can't connect to your Almond. Please select a connection method.");
            UIAlertAction *Check = [UIAlertAction
                                    actionWithTitle:@"Switch to Cloud Connection"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                                    }];
            [alert1 addAction:Check];
            UIAlertAction *Check1 = [UIAlertAction
                                     actionWithTitle:@"Switch to Local Connection"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                                     }];
            [alert1 addAction:Check1];

            [self presentViewController:alert1 animated:YES completion:nil];
                        break;
        };
        case SFICloudStatusStateLocalConnection: {
            SFIAlmondLocalNetworkSettings *settings = [[SecurifiToolkit sharedInstance] localNetworkSettingsForAlmond:self.toolkit.currentAlmond.almondplusMAC];
            if(settings){
                alert1.title = NSLocalizedString(@"alertview localconnection_Connected to your Almond locally.", @"Connected to your Almond locally.");
                UIAlertAction *Check = [UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"alertview localconnection_Switch to Cloud Connection", @"Switch to Cloud Connection")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                                        {
                                            [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                                        }
                                        ];
                [alert1 addAction:Check];
                [self presentViewController:alert1 animated:YES completion:nil];
                
                break;
            }
            else{
                alert1.title = NSLocalizedString(@"alertview Local connection settings are missing.", @"Local connection settings are missing.");
                UIAlertAction *Check = [UIAlertAction
                                        actionWithTitle:NSLocalizedString(@"alertview title Add Local Connection Settings", @"Add Local Connection Settings")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action)
                                        {
                                            [self presentLocalNetworkSettingsEditor];
                                        }
                                        ];
                [alert1 addAction:Check];
                [self presentViewController:alert1 animated:YES completion:nil];
                
                break;
            }
        };
        case SFICloudStatusStateLocalConnectionOffline: {
            alert1.title = NSLocalizedString(@"alert msg offline Local connection to your Almond failed. Tap retry or switch to cloud connection.", "Local connection to your Almond failed. Tap retry or switch to cloud connection.");
            UIAlertAction *Check = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"alert title offline Local Retry Local Connection", @"Retry Local Connection")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                                    }
                                    ];
            UIAlertAction *Check1 = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"alert title offline Local Switch to Cloud Connection", @"Switch to Cloud Connection")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                                     }
                                     ];
            [alert1 addAction:Check];
            [alert1 addAction:Check1];
            [self presentViewController:alert1 animated:YES completion:nil];
            
            break;
            
        };
        case SFICloudStatusStateCloudConnectionNotSupported: {
            alert1.title = NSLocalizedString(@"alert msg offline Cloud connection not supported.", "Your Almond is not affiliated with the cloud. Only local connection to your Almond is supported.");
            UIAlertAction *Check = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Alert view title-Switch to Local Connection", @"Switch to Local Connection")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        [self configureNetworkSettings:SFIAlmondConnectionMode_local];
                                    }
                                    ];
            [alert1 addAction:Check];
            [self presentViewController:alert1 animated:YES completion:nil];
            
            break;
        }
        case SFICloudStatusStateLocalConnectionNotSupported: {
            alert1.title = NSLocalizedString(@"alert msg offline Local connection not supported.", "Can't connect to your Almond because local connection settings are missing. Tap edit to add settings.");
            UIAlertAction *Check = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"alert title offline Local Switch to Cloud Connection", @"Switch to Cloud Connection")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action)
                                    {
                                        [self configureNetworkSettings:SFIAlmondConnectionMode_cloud];
                                    }
                                    ];
            [alert1 addAction:Check];
            [self presentViewController:alert1 animated:YES completion:nil];
           
            break;
        }
        default:
            return;
    }
    
}

- (void)configureNetworkSettings:(enum SFIAlmondConnectionMode)mode1 {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit setConnectionMode:mode1 forAlmond:self.toolkit.currentAlmond.almondplusMAC];
    [toolkit.clients removeAllObjects];
    [toolkit.devices removeAllObjects ];
}

- (void)presentLocalNetworkSettingsEditor {
    
    NSString *mac = self.toolkit.currentAlmond.almondplusMAC;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondLocalNetworkSettings *settings = [toolkit localNetworkSettingsForAlmond:mac];
    if (!settings) {
        settings = [SFIAlmondLocalNetworkSettings new];
        settings.almondplusMAC = mac;
    }
    RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
    editor.settings = settings;
    editor.enableUnlinkActionButton = ![toolkit almondExists:mac]; // only allowed to unlink local almonds that are not affiliated with the cloud
    UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:ctrl animated:YES completion:nil];
    
}


- (void)markNetworkStatusIcon {
    NSString *const almondMac = self.toolkit.currentAlmond.almondplusMAC;
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    enum SFIAlmondConnectionMode connectionMode = [toolkit connectionModeForAlmond:almondMac];
    enum SFIAlmondConnectionStatus status = [toolkit connectionStatusForAlmond:almondMac];
    enum SFICloudStatusState state;
    switch (status) {
        case SFIAlmondConnectionStatus_disconnected: {
             state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateDisconnected : SFICloudStatusStateLocalConnectionOffline;
            [self.leftButton markState:state];
            break;
        };
        case SFIAlmondConnectionStatus_connecting: {
            [self.leftButton markState:SFICloudStatusStateConnecting];
           break;
        };
        case SFIAlmondConnectionStatus_connected: {
            state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateConnected : SFICloudStatusStateLocalConnection;
            [self.leftButton markState:state];
            
            break;
        };
        case SFIAlmondConnectionStatus_error: {
            break;
        };
        case SFIAlmondConnectionStatus_error_mode: {
            state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateCloudConnectionNotSupported : SFICloudStatusStateLocalConnectionNotSupported;
            [self.leftButton markState:state];
            break;
        }
    }
    image6 = [self imageForState:state localNetworkingMode:connectionMode];
    NSLog(@"self.leftButton.image");
    self.leftButton.image = image6;
}


- (UIImage *)imageForState:(SFICloudStatusState)state localNetworkingMode:(BOOL)localNetworkingMode {
    enum UIImageRenderingMode vers = UIImageRenderingModeAlwaysTemplate;
    NSString *name;
    
    switch (state) {
        case SFICloudStatusStateDisconnected:
            name = @"connection_cloud_error";
            vers = UIImageRenderingModeAlwaysOriginal;
            break;
        case SFICloudStatusStateConnecting:
            name = @"connection_status_02";
            break;
        case SFICloudStatusStateConnected:
            name = @"connection_cloud_success";
            vers = UIImageRenderingModeAlwaysOriginal;
            break;
        case SFICloudStatusStateAlmondOffline:
            name = @"connection_status_04";
            break;
        case SFICloudStatusStateAtHome:
            name = @"almond_mode_home";
            break;
        case SFICloudStatusStateAway:
            name = @"almond_mode_away";
            break;
        case SFICloudStatusStateConnectionError:
            name = @"connection_error_icon";
            if (localNetworkingMode) vers = UIImageRenderingModeAlwaysOriginal;
            break;
        case SFICloudStatusStateLocalConnection:
            name = @"connection_local_success";
            vers = UIImageRenderingModeAlwaysOriginal;
            break;
        case SFICloudStatusStateLocalConnectionOffline:
            name = @"connection_local_error";
            vers = UIImageRenderingModeAlwaysOriginal;
            break;
        case SFICloudStatusStateCloudConnectionNotSupported:
            name = @"connection_error_icon";
            if (localNetworkingMode) vers = UIImageRenderingModeAlwaysOriginal;
            break;
        case SFICloudStatusStateLocalConnectionNotSupported:
            name = @"connection_local_error";
            vers = UIImageRenderingModeAlwaysOriginal;
            break;
        default:
            return nil;
    }
    NSLog(@"Name of Image is : %@",name);
    self.leftButton.image = [UIImage imageNamed:name];
    UIImage *image = [UIImage imageNamed:name];
    return [image imageWithRenderingMode:vers];
}





@end
/*

 UILabel *label = ...
 label.userInteractionEnabled = YES;
 UITapGestureRecognizer *tapGesture =
 [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];
 [label addGestureRecognizer:tapGesture];
 
 
*/