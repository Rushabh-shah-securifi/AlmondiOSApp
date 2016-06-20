//
//  MainViewController.m
//  Dashbord
//
//  Created by Securifi Support on 03/05/16.
//  Copyright © 2016 Securifi. All rights reserved.
//
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
#import "SFINotificationTableViewCell.h"
#import "AlertView.h"
#import "AlertViewAction.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "SettingsViewController.h"
#import "MainViewController.h"
#import "NotificationsTestStore.h"
#import "SensorSupport.h"
#import "SFIColors.h"
#import "CircleLabel.h"
#import "Colours.h"
#import "SFINotificationStatusBarButtonItem.h"

#import "CommonMethods.h"
@interface MainViewController ()<MBProgressHUDDelegate>{
    NSArray *buttons;
    UIBarButtonItem *rightButton;
    SFINotificationStatusBarButtonItem *middleButton;
    SFIAlmondMode mode;
}
@property(nonatomic) SFICloudStatusBarButtonItem *leftButton;
@property(nonatomic) SecurifiToolkit *toolkit;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property (nonatomic, strong, nullable) UIRefreshControl *refreshControl NS_AVAILABLE_IOS(6_0) __TVOS_PROHIBITED;

@property(nonatomic) SFINotificationsViewController *notify;
@property(nonatomic) id <SFINotificationStore> store;
@property (nonatomic) NSMutableArray *clientNotificationArr;
@property (nonatomic) NSMutableArray *deviceNotificationArr;


@property(nonatomic, readonly) CircleLabel *countLabel;
@property(nonatomic, readonly) UIButton *countButton;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.clipsToBounds = YES;
    self.toolkit = [SecurifiToolkit sharedInstance];
    [self.toolkit tryRefreshNotifications];
    self.notify = [[SFINotificationsViewController alloc] init];
    //NSLog(@"self.toolkit.currentAlmond.almondplusMAC %@",self.toolkit.currentAlmond.almondplusMAC);
    _store = [self.notify pickNotificationStore];
    self.notify.store = _store;
    [self.notify resetBucketsAndNotifications];
    SecurifiConfigurator *configurator = _toolkit.configuration;
    _enableNotificationsView = configurator.enableNotifications;
    _enableNotificationsHomeAwayMode = configurator.enableNotificationsHomeAwayMode;
    self.clientNotificationArr = [[NSMutableArray alloc]init];
    self.deviceNotificationArr = [[NSMutableArray alloc]init];
    [self getClientNotification];
    [self getDeviceNotification];
    
    UIImage *imgNav = [UIImage imageNamed:@"1224"];
    [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setTitle:@"Dashboard"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    _leftButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onConnectionStatusButtonPressed:) enableLocalNetworking:YES];
    self.leftButton.isDashBoard = YES;
    
    middleButton = [[SFINotificationStatusBarButtonItem alloc]
                    initWithImage:[UIImage imageNamed:@"notification_home"]
                    style:UIBarButtonItemStylePlain
                    target:self
                    action:@selector(notificationAction:)];
    
    middleButton = [[SFINotificationStatusBarButtonItem alloc] initWithTarget:self action:@selector(notificationAction:)];
    NSInteger count = [_toolkit countUnviewedNotifications];
    [middleButton markNotificationCount:(NSUInteger) count];
    
    
    middleButton.tintColor = [UIColor whiteColor];
    middleButton.isDashBoard = YES;
    buttons = @[_leftButton, middleButton];
    self.navigationItem.leftBarButtonItems = buttons;
    
    _labelAlmond.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AlmondSelection:)];
    [_labelAlmond addGestureRecognizer:tapGesture];
    [Scroller setScrollEnabled:YES];
    [self markNetworkStatusIcon];
    [self initializeNotification];
    [self initializeHUD];
    
}

- (CircleLabel *)makeCountLabel {
    
    CGRect frame = CGRectMake(12, 1, 10, 10);
    CircleLabel *label = [[CircleLabel alloc] initWithFrame:frame];
    label.cornerRadius = 12.5;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont standardUILabelFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = /*orange*/[UIColor colorFromHexString:@"ff8500"];
    NSLog(@"Circle Image should come from here");
    NSLog(@"label is ");
    return label;
}

-(void)initializeHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}

-(void)initializeNotification{
    if(self.toolkit.currentAlmond != nil){
        _labelAlmond.text = self.toolkit.currentAlmond.almondplusName ;
        _smartHomeConnectedDevices.text = [NSString stringWithFormat:@"%lu ",(unsigned long)self.toolkit.devices.count ];
        _networkConnectedDevices.text =[NSString stringWithFormat:@"%lu ",(unsigned long)self.toolkit.clients.count ];
        _totalConnectedDevices.text = [NSString stringWithFormat: @"%ld", [_smartHomeConnectedDevices.text integerValue]+[_networkConnectedDevices.text integerValue]];
        
        NSLog(@"Why almond mode is Not changing ");
        NSLog(@"%d",self.toolkit.mode_src);
        
        if (self.toolkit.mode_src == 2) {
            middleButton.image = [UIImage imageNamed:@"notification_home"];
            UIImage *imgNav = [UIImage imageNamed:@"1224"];
            [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
            _labelHomeAway.hidden = YES;
            _labelHome.hidden = NO;
            [self.buttonHome setImage:[UIImage imageNamed:@"home_icon1"] forState:UIControlStateNormal];
            [self.buttonHomeAway setImage:[CommonMethods imageNamed:@"homeaway_icon1" withColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [self.buttonHome setBackgroundColor:[UIColor colorWithRed:0.012 green:0.663 blue:0.957 alpha:1] ];
            [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
            self.bannerImage.image = [UIImage imageNamed:@"1225"];
        }else if(self.toolkit.mode_src  == 3){
            middleButton.image = [UIImage imageNamed:@"notification_home"];
            UIImage *imgNav = [UIImage imageNamed:@"head_away"];
            [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
            _labelHomeAway.hidden = NO;
            _labelHome.hidden = YES;
            [self.buttonHomeAway setImage:[UIImage imageNamed:@"homeaway_icon1"] forState:UIControlStateNormal];
            [self.buttonHome setImage:[CommonMethods imageNamed:@"home_icon1" withColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [self.buttonHomeAway setBackgroundColor:[UIColor colorWithRed:1 green:0.596 blue:0 alpha:1]];
            [self.buttonHome setBackgroundColor:[UIColor clearColor]];
            self.bannerImage.image = [UIImage imageNamed:@"main"];
        }
    }else{
             _labelAlmond.text = @"AddAlmond";
            _labelHomeAway.hidden = YES;
            _labelHome.hidden = YES;
             [self.buttonHome setBackgroundColor:[UIColor clearColor]];
        
             [self.buttonHomeAway setImage:[UIImage imageNamed:@"homeaway_icon1"] forState:UIControlStateNormal];
             [self.buttonHome setImage:[UIImage imageNamed:@"home_icon1"] forState:UIControlStateNormal];
             [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
            _smartHomeConnectedDevices.text = [NSString stringWithFormat:@"%d ",0 ];
            _networkConnectedDevices.text =[NSString stringWithFormat:@"%d ",0 ];
            _totalConnectedDevices.text = [NSString stringWithFormat: @"%d",0];

    }
}


- (void)onCurrentAlmondChanged:(id)sender {
    NSLog(@"Almond is changing to %@",self.toolkit.currentAlmond.almondplusName);
    NSLog(@"Almond mode is %d",self.toolkit.mode_src);
    [self.toolkit.devices removeAllObjects];
    [self.toolkit.clients removeAllObjects];
    [self initializeAlmondData];
    [self initializeNotification];
    [self markNetworkStatusIcon];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.dashboardTable reloadData];
    });
}
-(void)initializeAlmondData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self tryInstallRefreshControl];
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

#pragma mark HUD
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg delay:(int)delay{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:delay];
    });
}
- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        [self.HUD removeFromSuperview];
    }
}

-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    //NSLog(@"devicelist - onDeviceListAndDynamicResponseParsed");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.dashboardTable reloadData];
        //[self initializeNotification];
        _labelAlmond.text = self.toolkit.currentAlmond.almondplusName ;
        _smartHomeConnectedDevices.text = [NSString stringWithFormat:@"%lu ",(unsigned long)self.toolkit.devices.count ];
        _networkConnectedDevices.text =[NSString stringWithFormat:@"%lu ",(unsigned long)self.toolkit.clients.count ];
        _totalConnectedDevices.text = [NSString stringWithFormat: @"%ld", [_smartHomeConnectedDevices.text integerValue]+[_networkConnectedDevices.text integerValue]];
        [self.HUD hide:YES];
        if(self.refreshControl == nil){
            [self tryInstallRefreshControl];
        }else{
            [self.refreshControl endRefreshing];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onAlmondModeDidChange:)
                   name:kSFIAlmondModeDidChange
                 object:nil];
    [center addObserver:self
               selector:@selector(onDeviceListAndDynamicResponseParsed:) //for both sensors and clients
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER
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
    [center addObserver:self
               selector:@selector(onDidReceiveNotifications)
                   name:kSFINotificationDidStore
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

    // NSLog(@"tryRefreshNotifications");
    [self.toolkit tryRefreshNotifications];
    [self initializeNotification];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.dashboardTable reloadData];
    });
    [self markNetworkStatusIcon];
}

- (void)onNotificationCountChanged:(id)event {
    NSLog(@"Notification count icon");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSInteger badgeCount = [toolkit notificationsBadgeCount];
    NSLog(@"Notifications are : %ld",(long)badgeCount);
    if(badgeCount >0){
        middleButton.image = [UIImage imageNamed:@"bell_icon_tilted"];
        _countLabel = [self makeCountLabel];
        
        [middleButton markNotificationCount:(NSUInteger) badgeCount];
//        [middleButton addSubView:];

    }else{
        if (self.toolkit.mode_src ==2) {
            middleButton.image = [UIImage imageNamed:@"notification_home"];
        }
        if (self.toolkit.mode_src ==3) {
            middleButton.image = [UIImage imageNamed:@"notification_home"];
        }
    }
}

-(void)onDidReceiveNotifications{
    _store = [self.notify pickNotificationStore];
    self.notify.store = _store;
    [self.notify resetBucketsAndNotifications];
    [self getClientNotification];
    [self getDeviceNotification];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dashboardTable reloadData];
    });
}
- (void)onNetworkUpNotifier:(id)sender {
    ////NSLog(@"onNetworkUpNotifier");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
    });
}
- (void)onNetworkDownNotifier:(id)sender {
    // //NSLog(@"onNetworkDownNotifier");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
    });
}

- (void)onNetworkConnectingNotifier:(id)notification {
    ////NSLog(@"onNetworkConnectingNotifier");
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
    NSLog(@"Almond mode is changing %d",self.toolkit.mode_src);
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
            [self.buttonHome setImage:[UIImage imageNamed:@"home_icon1"] forState:UIControlStateNormal];
            [self.buttonHomeAway setImage:[CommonMethods imageNamed:@"homeaway_icon1" withColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [self.buttonHome setBackgroundColor:[UIColor colorWithRed:0.012 green:0.663 blue:0.957 alpha:1] ];
            [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
            self.bannerImage.image = [UIImage imageNamed:@"1225"];
        }else if(mode == 3){
            middleButton.image = [UIImage imageNamed:@"notification_home"];
            UIImage *imgNav = [UIImage imageNamed:@"head_away"];
            [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
            _labelHomeAway.hidden = NO;
            _labelHome.hidden = YES;
            [self.buttonHomeAway setImage:[UIImage imageNamed:@"homeaway_icon1"] forState:UIControlStateNormal];
            [self.buttonHome setImage:[CommonMethods imageNamed:@"home_icon1" withColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [self.buttonHomeAway setBackgroundColor:[UIColor colorWithRed:1 green:0.596 blue:0 alpha:1]];
            [self.buttonHome setBackgroundColor:[UIColor clearColor]];
            self.bannerImage.image = [UIImage imageNamed:@"main"];
        }
        [self.HUD hide:YES];
    });
}

- (IBAction)AlmondSelection:(UIButton *)sender {
    enum SFIAlmondConnectionMode modeValue = [self.toolkit currentConnectionMode];
    NSArray *almondList = [self buildAlmondList:modeValue];
    UIAlertController *viewC;
    UIImage *image = [UIImage imageNamed:@"home_icon1"];
    viewC = [UIAlertController alertControllerWithTitle:@"Select Almond" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for(SFIAlmondPlus *name in almondList){
        if ([name.almondplusName isEqualToString:_labelAlmond.text]) {
            viewC.view.tintColor = [UIColor blackColor];
        }
            UIAlertAction *Aname = [UIAlertAction
                                actionWithTitle:name.almondplusName
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action){
                                    SFIAlmondPlus *currentAlmond = name;
                                    [[SecurifiToolkit sharedInstance] setCurrentAlmond:currentAlmond];
                                    _labelAlmond.text = name.almondplusName;
                                    _labelAlmondStatus.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:14];
                                    _labelAlmond.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:18];
                                }];
        [Aname setValue:image forKey:@"image"];
        
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
     if(self.toolkit.currentAlmond != nil){
        [self showHudWithTimeoutMsg:@"Setting Almond to home mode." delay:5];
        mode = SFIAlmondMode_home;
        [_toolkit asyncRequestAlmondModeChange:self.toolkit.currentAlmond.almondplusMAC mode:mode];
     }
}

- (IBAction)homeawayMode:(id)sender {
     if(self.toolkit.currentAlmond != nil){
        [self showHudWithTimeoutMsg:@"Setting Almond to away mode." delay:5];
        mode = SFIAlmondMode_away;
        [_toolkit asyncRequestAlmondModeChange:self.toolkit.currentAlmond.almondplusMAC mode:mode];
     }
}

- (void)notificationAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.presentedViewController != nil) {
            return;
        }
        
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        
        SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        ctrl.enableDebugMode = toolkit.configuration.enableNotificationsDebugMode;
        
        UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        middleButton.image = [UIImage imageNamed:@"notification_home"];
        
        [self presentViewController:nav_ctrl animated:YES completion:nil];
        [middleButton markNotificationCount:0];
    });
}

-(void )getDeviceNotification{
    [self.deviceNotificationArr removeAllObjects];
    if(self.toolkit.currentAlmond != nil){
        
        for(int j = 0; j<10;j++){// for 10 days
            for (int i =0; i<100; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:j];
                SFINotification *notification = [self.notify notificationForIndexPath:indexPath];
                if(notification.deviceType != SFIDeviceType_WIFIClient && notification!=Nil){
                    [self.deviceNotificationArr addObject:notification];
                    //NSLog(@"getDeviceNotification");
                    if(self.deviceNotificationArr.count > 2)
                        return ;
                }
            }
        }
    }
    
}
-(void )getClientNotification{
    [self.clientNotificationArr removeAllObjects];
    if(self.toolkit.currentAlmond != nil){
        for(int j = 0; j<10;j++){// for 10 days
            for (int i =0; i<100; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:j];
                SFINotification *notification = [self.notify notificationForIndexPath:indexPath];
                if(notification.deviceType == SFIDeviceType_WIFIClient && notification!=Nil){
                    [self.clientNotificationArr addObject:notification];
                    if(self.clientNotificationArr.count > 1)
                        return ;
                }
            }
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0 )
        return self.deviceNotificationArr.count;
    else if (section == 1 )
        return self.clientNotificationArr.count;
    else
        return 0;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SensorSupport *sensorSupport = [SensorSupport new];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier ];
    }
    
    if (indexPath.section == 0 && self.deviceNotificationArr.count > indexPath.row) {
        SFINotification *notification = [self.deviceNotificationArr objectAtIndex:indexPath.row];
        [sensorSupport resolveNotification:notification.deviceType index:notification.valueType value:notification.value];
        if ([notification.deviceName isEqualToString:@"nil"]) {
            cell.imageView.image = [CommonMethods imageNamed:@"default_device" withColor:[SFIColors ruleBlueColor]];
            cell.textLabel.text = @"No notifications";
        }else{
            //NSLog(@"icon name :: %@",sensorSupport.valueSupport.iconName);
            cell.textLabel.attributedText = [self setMessageLabelText:notification sensorSupport:sensorSupport];
            cell.imageView.image = [CommonMethods imageNamed:sensorSupport.valueSupport.iconName withColor:[SFIColors ruleBlueColor]];
            cell.detailTextLabel.attributedText = [self setDateLabelText:notification];
        }
    }
    else if(indexPath.section == 1 && self.clientNotificationArr.count > indexPath.row){
        SFINotification *notification = [self.clientNotificationArr objectAtIndex:indexPath.row];
        [sensorSupport resolveNotification:notification.deviceType index:notification.valueType value:notification.value];
        //NSLog(@"devicename --%@",notification.deviceName);
        if ([notification.deviceName rangeOfString:@"joined" options:NSCaseInsensitiveSearch].location != NSNotFound){
            cell.imageView.image = [UIImage imageNamed:@"online"];
            cell.textLabel.attributedText = [self setMessageLabelText:notification sensorSupport:sensorSupport];
            cell.detailTextLabel.attributedText = [self setDateLabelText:notification];
        }
        else{
            cell.imageView.image = [UIImage imageNamed:@"offline"];
            cell.textLabel.attributedText = [self setMessageLabelText:notification sensorSupport:sensorSupport];
            cell.detailTextLabel.attributedText = [self setDateLabelText:notification];
        }
        // cell.textLabel.text = notification.deviceName;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = [SFIColors ruleGraycolor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    CGSize itemSize = CGSizeMake(30,30);
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
    
    
    SFICloudStatusState statusState = self.leftButton.state;
    // //NSLog(@"statusState cloud status at dashboard %lu",(unsigned long)statusState);
    
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
    UIAlertAction *Close = [UIAlertAction
                            actionWithTitle:@"Close"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [alert1 dismissViewControllerAnimated:YES completion:nil];
                            }];
    [alert1 addAction:Close];
    
}

- (void)configureNetworkSettings:(enum SFIAlmondConnectionMode)mode1 {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit setConnectionMode:mode1 forAlmond:self.toolkit.currentAlmond.almondplusMAC];
    [self showHudWithTimeoutMsg:@"Connecting..." delay:2];
    [toolkit.devices removeAllObjects];
    [toolkit.clients removeAllObjects];
    [toolkit.scenesArray removeAllObjects];
    [toolkit.ruleList removeAllObjects];
    
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
    NSLog(@"markNetworkStatusIcon");
    enum SFIAlmondConnectionMode connectionMode = [_toolkit connectionModeForAlmond:almondMac];
    enum SFIAlmondConnectionStatus status = [_toolkit connectionStatusForAlmond:almondMac];
    enum SFICloudStatusState state;
    switch (status) {
        case SFIAlmondConnectionStatus_disconnected: {
            state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateDisconnected : SFICloudStatusStateLocalConnectionOffline;
            [self.leftButton markState:state];
            [self changeColorOfNavigationItam:@"header_Gray" andbannerImage:@"home_Gray"];
            break;
        };
        case SFIAlmondConnectionStatus_connecting: {
            [self.leftButton markState:SFICloudStatusStateConnecting];
            [self changeColorOfNavigationItam:@"header_Gray" andbannerImage:@"home_Gray"];
            break;
        };
        case SFIAlmondConnectionStatus_connected: {
            state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateConnected : SFICloudStatusStateLocalConnection;
            [self.leftButton markState:state];
            if(self.toolkit.mode_src==2){
                [self changeColorOfNavigationItam:@"1224" andbannerImage:@"1225"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.buttonHome setBackgroundColor:[UIColor colorWithRed:0.012 green:0.663 blue:0.957 alpha:1] ];
                    [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
                });
            }
            else{
                [self changeColorOfNavigationItam:@"head_away" andbannerImage:@"main"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.buttonHomeAway setBackgroundColor:[UIColor colorWithRed:1 green:0.596 blue:0 alpha:1] ];
                    [self.buttonHome setBackgroundColor:[UIColor clearColor]];
                    });
            }
            break;
        };
        case SFIAlmondConnectionStatus_error: {
            [self changeColorOfNavigationItam:@"header_Gray" andbannerImage:@"home_Gray"];
            break;
        };
        case SFIAlmondConnectionStatus_error_mode: {
            state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateCloudConnectionNotSupported : SFICloudStatusStateLocalConnectionNotSupported;
            [self.leftButton markState:state];
            [self changeColorOfNavigationItam:@"header_Gray" andbannerImage:@"home_Gray"];
            break;
        }
    }
    self.leftButton.image = [self imageForState:state localNetworkingMode:connectionMode];
}
-(void)changeColorOfNavigationItam:(NSString *)img1 andbannerImage:(NSString*)img2 {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *imgNav = [UIImage imageNamed:img1];
        [self.navigationController.navigationBar setBackgroundImage:imgNav forBarMetrics:UIBarMetricsDefault];
        
        self.bannerImage.image = [UIImage imageNamed:img2];
        if (self.toolkit.mode_src ==2) {
            [self.buttonHome setBackgroundColor:[UIColor colorWithRed:0.537 green:0.549 blue:0.565 alpha:1] ];
            [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
        }
        else{
            [self.buttonHomeAway setBackgroundColor:[UIColor colorWithRed:0.537 green:0.549 blue:0.565 alpha:1] ];
            [self.buttonHome setBackgroundColor:[UIColor clearColor]];
        }
    });
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
            name = @"cloud_icon";
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
    //NSLog(@"Name of Image is : %@",name);
    //enum SFICloudStatusState initialState = SFICloudStatusStateConnected;
    UIImage *image = [UIImage imageNamed:name];
    return [image imageWithRenderingMode:vers];
}



- (NSAttributedString *)setMessageLabelText:(SFINotification *)notification sensorSupport:(SensorSupport*)sensorSupport {
    ////NSLog(@"Notification: %@", notification);
    NSDictionary *attr;
    UIFont *bold_font = [UIFont securifiBoldFont];
    UIFont *normal_font = [UIFont securifiNormalFont];
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor blackColor],
             };
    if (notification == nil) {
        return [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    }
    
    NSString *deviceName = notification.deviceName;
    
    if (notification.deviceType==SFIDeviceType_WIFIClient) {
        //NSLog(@"client device name: %@",notification.deviceName);
        NSArray * properties = [notification.deviceName componentsSeparatedByString:@"|"];
        NSString *name = properties[3];
        if([name rangeOfString:@"An unknown device" options:NSCaseInsensitiveSearch].location != NSNotFound){
            NSArray *nameArr = [name componentsSeparatedByString:@"An unknown device"];
            deviceName = nameArr[1];
        }else
            deviceName = name;
        
    }
    //NSLog(@"notification value %@",notification.value);
    
    NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:deviceName attributes:attr];
    
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor lightGrayColor],
             };
    
    NSString *message;
    message = sensorSupport.notificationText;
    NSMutableAttributedString *mutableAttributedString = nil;
    if (message == nil) {
        message = @"";
    }
    if (!mutableAttributedString) {
        NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:message attributes:attr];
        NSMutableAttributedString *container = [NSMutableAttributedString new];
        [container appendAttributedString:nameStr];
        [container appendAttributedString:eventStr];
        
        return  container;
    }else{
        return  mutableAttributedString;
    }
}
- (NSAttributedString *)setDateLabelText:(SFINotification *)notification {
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:notification.time];
    
    NSDictionary *attr;
    NSString *str;
    
    attr = @{
             NSFontAttributeName : [UIFont securifiBoldFontLarge],
             NSForegroundColorAttributeName : [UIColor grayColor],
             };
    if (notification == nil) {
        return [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    }
    
    formatter.dateFormat = @"dd/MM - hh:mm";
    str = [formatter stringFromDate:date];
    NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:str attributes:attr];
    
    attr = @{
             NSFontAttributeName : [UIFont securifiBoldFontLarge],
             NSForegroundColorAttributeName : [UIColor lightGrayColor],
             };
    formatter.dateFormat = @"a";
    str = [formatter stringFromDate:date];
    NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:str attributes:attr];
    
    NSMutableAttributedString *container = [NSMutableAttributedString new];
    [container appendAttributedString:nameStr];
    [container appendAttributedString:eventStr];
    
    return container;
    //    self.dateLabel.textAlignment = NSTextAlignmentRight;
}


@end
/*
 
 UILabel *label = ...
 label.userInteractionEnabled = YES;
 UITapGestureRecognizer *tapGesture =
 [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];
 [label addGestureRecognizer:tapGesture];
 
 
 */


