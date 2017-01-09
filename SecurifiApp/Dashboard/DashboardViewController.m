//
//  DashboardViewController.m
//  Dashbord
//
//  Created by Securifi Support on 03/05/16.
//  Copyright © 2016 Securifi. All rights reserved.
//
#import "UIFont+Securifi.h"
#import "SFICloudLinkViewController.h"
#import "SFICloudStatusBarButtonItem.h"
#import "MBProgressHUD.h"
#import "SFINotificationsViewController.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "DashboardViewController.h"
#import "NotificationsTestStore.h"
#import "SensorSupport.h"
#import "SFIColors.h"
#import "CircleLabel.h"
#import "Colours.h"
#import "SFINotificationStatusBarButtonItem.h"
#import "CommonMethods.h"
#import "UIFont+Securifi.h"
#import "SWRevealViewController.h"
#import "HelpScreens.h"
#import "UICommonMethods.h"
#import "AlmondSelectionTableView.h"
#import "ConnectionStatus.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "Client.h"
#import "ConnectionStatus.h"

#import "LocalNetworkManagement.h"
#import "NotificationAccessAndRefreshCommands.h"
#import "NetworkStatusIcon.h"
#import "Network.h"
#import "NetworkState.h"
#import "AlmondManagement.h"
#import "IoTDevicesListViewController.h"
#import "MySubscriptionsViewController.h"
#import "GenericCommand.h"
#import "AlmondPlan.h"
#import "GenericDeviceClass.h"
#import "GenericValue.h"
#import "DeviceIndex.h"



@interface DashboardViewController ()<MBProgressHUDDelegate,RouterNetworkSettingsEditorDelegate, HelpScreensDelegate,AlmondSelectionTableViewDelegate, NetworkStatusIconDelegate>{
    UIButton *button, *btnArrow;
}

@property(nonatomic) SFICloudStatusBarButtonItem *leftButton;
@property(nonatomic) SFINotificationStatusBarButtonItem *notificationButton;
@property(nonatomic) SecurifiToolkit *toolkit;
@property(nonatomic) MBProgressHUD *HUD;
@property(nonatomic) id <SFINotificationStore> store;
@property(nonatomic) NSArray *clientNotificationArr;
@property(nonatomic) NSArray *deviceNotificationArr;
@property(nonatomic) CircleLabel *countLabel;
@property(nonatomic) UIButton *countButton;
@property(nonatomic) UIImageView *navigationImg;
@property(nonatomic) HelpScreens *helpScreensObj;
@property(nonatomic) UIView *maskView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableYconstrain1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableYconstrain2;
@property (weak, nonatomic) IBOutlet UIView *imageIOTSecurity;
@property(nonatomic) UIButton *buttonMaskView;
@property(nonatomic) NetworkStatusIcon *statusIcon;
@property (weak, nonatomic) IBOutlet UILabel *vulnableDevices;
@property (weak, nonatomic) IBOutlet UIButton *iotSecurityButton;
@property (weak, nonatomic) IBOutlet UIImageView *iotSecurityImg;
@property CGFloat constatnt1;
@property CGFloat constatnt2;

@property (weak, nonatomic) IBOutlet UILabel *lastScanIot_label;
@property (weak, nonatomic) IBOutlet UILabel *noIot_label;
@property (weak, nonatomic) IBOutlet UILabel *no_scanObjLabel;
@property (weak, nonatomic) IBOutlet UILabel *scan_In_progress;


@end


@implementation DashboardViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _statusIcon = [NetworkStatusIcon new];
    self.toolkit = [SecurifiToolkit sharedInstance];
    if([self.toolkit isScreenShown:@"dashboard"] == NO)
        [self initializeHelpScreens];
    
    self.navigationController.navigationBar.clipsToBounds = YES;
    [self loadNotification];
    self.clientNotificationArr = [[NSMutableArray alloc]init];
    self.deviceNotificationArr = [[NSMutableArray alloc]init];
    
    
    //add almond button
    [self initializeAddButtonView];
    [self initializeHUD];
    self.constatnt1 =self.tableYconstrain1.constant;
    
    self.constatnt2 =self.tableYconstrain2.constant;

    CGSize scrollableSize = CGSizeMake(Scroller.frame.size.width,Scroller.frame.size.height+ 130);
    [Scroller setContentSize:scrollableSize];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self navigationBarStyle];
     [self sendScanNowReq];
    
    [self iotUIUpdate];
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
               selector:@selector(onAlmondNameDidChange:)
                   name:kSFIDidChangeAlmondName
                 object:nil];
    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onConnectionStatusChanged:)
                   name:CONNECTION_STATUS_CHANGE_NOTIFIER
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
    
    [center addObserver:self
               selector:@selector(iotScanresultsCallBackDashBoard:)
                   name:NOTIFICATION_IOT_SCAN_RESULT_CONTROLLER_NOTIFIER
                 object:nil];
    
    [self getRecentNotification];
    [NotificationAccessAndRefreshCommands tryRefreshNotifications];
    [self initializeUI];
    _statusIcon.networkStatusIconDelegate = self;
    NSLog(@"View will appear is called in DashBoardViewController");
    [_statusIcon markNetworkStatusIcon:self.leftButton isDashBoard:YES];
    [self iotScanresultsCallBackDashBoard:nil];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initializeUI{
    [self updateMode:self.toolkit.mode_src];
    [self updateDeviceClientListCountAndCurrentAlmond];
    [self tryShowLoadingData];
}
-(void)iotUIUpdate{
    SFIAlmondPlus *currentAlmond = [AlmondManagement currentAlmond];
    BOOL hasSubscribe = [AlmondPlan hasSubscription:currentAlmond.almondplusMAC];
    NSLog(@"hasSubscribe %d",hasSubscribe);
    if(hasSubscribe && [currentAlmond siteMapSupportFirmware:currentAlmond.firmware] && [currentAlmond iotSupportFirmwareVersion:currentAlmond.firmware]){
        self.inactiveNetworkDevices.hidden = YES;
        self.no_scanObjLabel.hidden = NO;
        self.iotSecurityImg.hidden = YES;
        self.tableYconstrain1.constant = self.constatnt1+100;
        self.tableYconstrain2.constant = self.constatnt2+100;
        self.iotSecurityButton.hidden = NO;
        self.vulnableDevices.text = @"VULNERABLE DEVICES";
        [self.iotSecurityButton removeTarget:nil
                                      action:NULL
                            forControlEvents:UIControlEventTouchUpInside];
        [self.iotSecurityButton addTarget:self action:@selector(launchIOtDevicelit:) forControlEvents:UIControlEventTouchUpInside];
       
        
    }
    else if(!hasSubscribe && [currentAlmond siteMapSupportFirmware:currentAlmond.firmware] && [currentAlmond iotSupportFirmwareVersion:currentAlmond.firmware]){
        // call my scbscription
        //change icon name
        self.vulnableDevices.text = @"IOT SECURITY DISABLED";
        self.tableYconstrain1.constant = self.constatnt1;
        self.tableYconstrain2.constant = self.constatnt2;
        self.inactiveNetworkDevices.hidden = YES;
        self.no_scanObjLabel.hidden = YES;
        self.iotSecurityImg.hidden = NO;
        self.iotSecurityButton.hidden = NO;
        self.iotSecurityImg.image = [UIImage imageNamed:@"ic_insecure_gray"];
        [self.iotSecurityButton removeTarget:nil
                                      action:NULL
                            forControlEvents:UIControlEventTouchUpInside];
        [self.iotSecurityButton addTarget:self action:@selector(launchMySubscription:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(![currentAlmond siteMapSupportFirmware:currentAlmond.firmware]){
        // call my scbscription
        self.activeNetworkDevices.hidden = NO;
        self.inactiveNetworkDevices.hidden = NO;
        self.no_scanObjLabel.hidden = YES;
        self.iotSecurityImg.hidden = YES;
        self.vulnableDevices.text = @"INACTIVE CLIENTS";
        self.tableYconstrain1.constant = self.constatnt1;
        self.tableYconstrain2.constant = self.constatnt2;
        self.iotSecurityImg.hidden = YES;
        self.iotSecurityButton.hidden = YES;
    }
    [self forLocal];
    
    
}
-(void)forLocal{
    BOOL local = [self.toolkit useLocalNetwork:[AlmondManagement currentAlmond].almondplusMAC];
    if(local){
        self.activeNetworkDevices.hidden = NO;
        self.inactiveNetworkDevices.hidden = NO;
        self.no_scanObjLabel.hidden = YES;
        self.iotSecurityImg.hidden = YES;
        self.vulnableDevices.text = @"INACTIVE CLIENTS";
        self.tableYconstrain1.constant = self.constatnt1;
        self.tableYconstrain2.constant = self.constatnt2;
        self.iotSecurityImg.hidden = YES;
        self.iotSecurityButton.hidden = YES;
    }
}

-(void)tryShowLoadingData{
    if([self isDeviceListEmpty] && [self isClientListEmpty] && [AlmondManagement currentAlmond] != nil && ![self isDisconnected] && [self isFirmwareCompatible]){
        NSLog(@"tryShowLoadingDevice");
        [self showHudWithTimeoutMsg:@"Loading Data..." delay:8];
    }
}

-(BOOL)isFirmwareCompatible{
    return [SFIAlmondPlus checkIfFirmwareIsCompatible:[AlmondManagement currentAlmond]];
}

-(BOOL)isDisconnected{
    return [_toolkit connectionStatusFromNetworkState:[ConnectionStatus getConnectionStatus]] == SFIAlmondConnectionStatus_disconnected;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initializeAddButtonView{
    button = [[UIButton alloc]init];
    btnArrow = [[UIButton alloc]init];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [button addTarget:self action:@selector(AlmondSelection:) forControlEvents:UIControlEventTouchUpInside];
    btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnArrow addTarget:self action:@selector(AlmondSelection:) forControlEvents:UIControlEventTouchUpInside];
    [Scroller addSubview:button];
    [Scroller addSubview:btnArrow];
    
    [self SelectAlmond:NSLocalizedString(@"dashBoard AddAlmond", @"Add Almond")];
}

- (void)SelectAlmond:(NSString *)title{
    CGFloat titleWidth;
    CGSize textSize;
    textSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Medium" size:18]}];
    titleWidth = textSize.width + 10;
    if(titleWidth > 150){
        titleWidth = 150;
    }
    button.frame = CGRectMake(CGRectGetWidth(self.view.frame)/2 - titleWidth/2, 40.0, titleWidth, 30);
    btnArrow.frame = CGRectMake(button.frame.origin.x+titleWidth, CGRectGetMinY(button.frame), 21.0, 30);
    [button setTitle:title forState:UIControlStateNormal];
    [btnArrow setBackgroundImage:[UIImage imageNamed:@"arrow_drop_down_black.pdf"] forState:UIControlStateNormal];
}


#pragma mark Navigation UI
-(void)navigationBarStyle{
    self.navigationImg = [[UIImageView alloc] initWithImage:[CommonMethods imageNamed:@"NavigationBackground" withColor:[SFIColors lightOrangeDashColor]]];
    self.bannerImage.image = [CommonMethods imageNamed:@"MainBackground" withColor:[SFIColors lightOrangeDashColor]];
    self.navigationController.view.backgroundColor = [SFIColors lightOrangeDashColor];
    
    self.navigationImg.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    [self.navigationController.navigationBar addSubview:self.navigationImg];
    
    [self.navigationItem setTitle:@"Dashboard"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self.buttonHomeAway setImage:[CommonMethods imageNamed:@"away_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
    [self.buttonHome setImage:[CommonMethods imageNamed:@"home_icon1_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
    
    
    _leftButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onConnectionStatusButtonPressed:) enableLocalNetworking:YES isDashBoard:YES];
    
    _notificationButton = [[SFINotificationStatusBarButtonItem alloc] initWithTarget:self action:@selector(notificationAction:)];
    
    NSInteger count = [NotificationAccessAndRefreshCommands countUnviewedNotifications];
    [_notificationButton markNotificationCount:(NSUInteger) count];
    _notificationButton.isDashBoard = YES;
    UIBarButtonItem *interSpace = [self getBarButton:20];
    
    self.navigationItem.leftBarButtonItems = @[_leftButton, interSpace,_notificationButton];
}

-(UIBarButtonItem *)getBarButton:(CGFloat)width{
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barButton.width = width;
    return barButton;
}

#pragma mark notification
-(void)loadNotification{
    self.store = [NotificationAccessAndRefreshCommands newNotificationStore];
}

-(void)initializeHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}


-(void)updateMode:(int )mode{
    if (mode == 2) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            _labelHomeAway.hidden = YES;
            _labelHome.hidden = NO;
            self.navigationImg.image = [CommonMethods imageNamed:@"NavigationBackground" withColor:[SFIColors lightBlueColor]];
            self.bannerImage.image = [CommonMethods imageNamed:@"MainBackground" withColor:[SFIColors lightBlueColor]];
            [self.buttonHome setBackgroundColor:[SFIColors lightBlueColor]];
            self.navigationController.view.backgroundColor = [SFIColors lightBlueColor];
            [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
            [self.buttonHomeAway setImage:[CommonMethods imageNamed:@"away_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
            [self.buttonHome setImage:[CommonMethods imageNamed:@"home_icon1_white" withColor:[UIColor clearColor]] forState:UIControlStateNormal];
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^() {
            _labelHomeAway.hidden = NO;
            _labelHome.hidden = YES;
            self.navigationImg.image = [CommonMethods imageNamed:@"NavigationBackground" withColor:[SFIColors lightOrangeDashColor]];
            self.bannerImage.image = [CommonMethods imageNamed:@"MainBackground" withColor:[SFIColors lightOrangeDashColor]];
            [self.buttonHomeAway setBackgroundColor:[SFIColors lightOrangeDashColor]];
            self.navigationController.view.backgroundColor = [SFIColors lightOrangeDashColor];
            [self.buttonHome setBackgroundColor:[UIColor clearColor]];
            [self.buttonHomeAway setImage:[CommonMethods imageNamed:@"away_white" withColor:[UIColor clearColor]] forState:UIControlStateNormal];
            [self.buttonHome setImage:[CommonMethods imageNamed:@"home_icon1_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
        });
    }
}

-(void)updateDeviceClientListCountAndCurrentAlmond{
    NSLog(@"updateDeviceClientListCountAndCurrentAlmond");
    if([AlmondManagement currentAlmond] != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^() {
            //_labelAlmond.text = [AlmondManagement currentAlmond].almondplusName ;
            [self SelectAlmond:[AlmondManagement currentAlmond].almondplusName];
            [self.AddAlmond setTitle:[AlmondManagement currentAlmond].almondplusName forState:UIControlStateNormal];
            self.smartHomeDevices.text = [NSString stringWithFormat:@"%lu ",(unsigned long)self.toolkit.devices.count ];
            self.activeNetworkDevices.text =[NSString stringWithFormat:@"%d ",[Client activeClientCount] ];
            self.inactiveNetworkDevices.text = [NSString stringWithFormat: @"%lu", (unsigned long)[Client inactiveClientCount]];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self SelectAlmond:NSLocalizedString(@"dashBoard AddAlmond", @"AddAlmond")];
            [self.AddAlmond setTitle:NSLocalizedString(@"dashBoard AddAlmond", @"AddAlmond") forState:UIControlStateNormal];
            //_labelAlmond.text = @"AddAlmond";
            _labelHomeAway.hidden = YES;
            _labelHome.hidden = YES;
            [self.buttonHomeAway setImage:[CommonMethods imageNamed:@"away_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
            [self.buttonHome setImage:[CommonMethods imageNamed:@"home_icon1_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
            [self.buttonHome setBackgroundColor:[UIColor clearColor]];
            [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
            self.smartHomeDevices.text = [NSString stringWithFormat:@"%d ",0 ];
            self.activeNetworkDevices.text =[NSString stringWithFormat:@"%d ",0 ];
            self.inactiveNetworkDevices.text = [NSString stringWithFormat: @"%d",0];
        });
    }
}

- (void)onAlmondNameDidChange:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        SFIAlmondPlus *obj = (SFIAlmondPlus *) [data valueForKey:@"data"];
        if ([[AlmondManagement currentAlmond].almondplusMAC isEqualToString:obj.almondplusMAC]) {
            [self updateDeviceClientListCountAndCurrentAlmond];
        }
    });
}

- (void)onCurrentAlmondChanged:(id)sender {
    NSLog(@"on Current almond changed");
    [self initializeUI];
    [_statusIcon markNetworkStatusIcon:self.leftButton isDashBoard:YES];
    // getrecentnotification to instantly show onclick
    [self getRecentNotification];
    [NotificationAccessAndRefreshCommands tryRefreshNotifications];
}

- (void)onAlmondListDidChange:(id)sender {
    [self onCurrentAlmondChanged:nil];
}


- (BOOL)isDeviceListEmpty {
    return self.toolkit.devices.count == 0;
}

-(BOOL)isClientListEmpty{
    return self.toolkit.clients.count == 0;
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

#pragma mark Update
-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"dash onDeviceListAndDynamicResponseParsed");
    [self updateDeviceClientListCountAndCurrentAlmond];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

- (void)onNotificationCountChanged:(id)event {
    [self.notificationButton markNotificationCount:(NSUInteger) [NotificationAccessAndRefreshCommands notificationsBadgeCount]];
}

-(void)onDidReceiveNotifications{
    NSLog(@"onDidReceiveNotifications");
    [self getRecentNotification];
}

-(void)onConnectionStatusChanged:(id)sender {
    NSNumber* status = [sender object];
    int statusIntValue = [status intValue];
    if(statusIntValue == NO_NETWORK_CONNECTION){
        dispatch_async(dispatch_get_main_queue(), ^() {
            [_statusIcon markNetworkStatusIcon:self.leftButton isDashBoard:YES];
            [self.HUD hide:YES]; // make sure it is hidden
        });
    }else if(statusIntValue == IS_CONNECTING_TO_NETWORK){
        dispatch_async(dispatch_get_main_queue(), ^() {
            [_statusIcon markNetworkStatusIcon:self.leftButton isDashBoard:YES];
        });
    }else if(statusIntValue == AUTHENTICATED){
        dispatch_async(dispatch_get_main_queue(), ^() {
            [_statusIcon markNetworkStatusIcon:self.leftButton isDashBoard:YES];
            [self updateMode:self.toolkit.mode_src];
        });
    }
}


- (void)onAlmondModeDidChange:(id)sender {
    NSLog(@"Almond mode is changing %d",self.toolkit.mode_src);
    [_statusIcon markNetworkStatusIcon:self.leftButton isDashBoard:YES];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    BOOL local = [toolkit useLocalNetwork:[AlmondManagement currentAlmond].almondplusMAC];
    NSDictionary *payload;
    if(local)
        payload = [dataInfo valueForKey:@"data"];
    else
        payload = [dataInfo valueForKey:@"data"];
    dispatch_async(dispatch_get_main_queue(), ^() {
        NSString *m = payload[@"Mode"];
        [self updateMode:(unsigned)[m integerValue]];
        [self.HUD hide:YES];
        [self iotUIUpdate];
    });
}

#pragma mark selectAlmond
- (IBAction)AlmondSelection:(UIButton *)sender {
    [self showAlmondSelection];
}

- (CGRect)sourceRectForCenteredAlertController
{
    CGRect sourceRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    sourceRect.origin.x = CGRectGetMidX(self.view.bounds)-self.view.frame.origin.x;
    sourceRect.origin.y = CGRectGetMidY(self.view.bounds)-self.view.frame.origin.y;
    return sourceRect;
}

- (IBAction)homeMode:(id)sender {
    if(self.toolkit.mode_src == SFIAlmondMode_home)
        return;
    if([AlmondManagement currentAlmond] != nil){
        [self showHudWithTimeoutMsg:NSLocalizedString(@"mode_home_progress", @"Setting Almond to home mode.") delay:5];
        [self asyncRequestAlmondModeChange:[AlmondManagement currentAlmond].almondplusMAC mode:SFIAlmondMode_home];
    }
}

- (IBAction)homeawayMode:(id)sender {
    if(self.toolkit.mode_src == SFIAlmondMode_away)
        return;
    if([AlmondManagement currentAlmond] != nil){
        [self showHudWithTimeoutMsg:NSLocalizedString(@"mode_away_progress", @"Setting Almond to away mode.") delay:5];
        [self asyncRequestAlmondModeChange:[AlmondManagement currentAlmond].almondplusMAC mode:SFIAlmondMode_away];
    }
}

- (sfi_id)asyncRequestAlmondModeChange:(NSString *)almondMac mode:(SFIAlmondMode)newMode {
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    if (almondMac == nil) {
        NSLog(@"asyncRequestAlmondModeChange : almond MAC is nil");
        return 0;
    }
    
    NSString *userId = [toolkit loginEmail];
    // A closure that will be invoked whne the command is submitted for processing and that
    // will store the requested almond mode for future reference. When a positive response is
    // received, the new mode will be confirmed and locked in.
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        [aNetwork.networkState markPendingModeForAlmond:almondMac mode:newMode];
        return YES;
    };
    
    GenericCommand *cmd = [GenericCommand changeAlmondMode:newMode userId:userId almondMac:almondMac];
    cmd.networkPrecondition = precondition;
    
    [toolkit asyncSendToNetwork:cmd ];
    
    return cmd.correlationId;
}

- (void)notificationAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.presentedViewController != nil)
            return;
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        ctrl.enableDebugMode = toolkit.configuration.enableNotificationsDebugMode;
        UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        _notificationButton.image = [UIImage imageNamed:@"bell_empty"];
        [self presentViewController:nav_ctrl animated:YES completion:nil];
        [_notificationButton markNotificationCount:0];
    });
}

-(void )getRecentNotification{
    NSLog(@"getDeviceClientNotification");
    self.deviceNotificationArr = [self.store fetchRecentNotifications:[AlmondManagement currentAlmond].almondplusMAC isSensor:YES];
    self.clientNotificationArr = [self.store fetchRecentNotifications:[AlmondManagement currentAlmond].almondplusMAC isSensor:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dashboardTable reloadData];
    });
}

#pragma mark tableviewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger deviceRowCount = [self isSensorNotificationEmpty]? 1: self.deviceNotificationArr.count;
    NSInteger clientRowCount = [self isClientNotificationEmpty]? 1: self.clientNotificationArr.count;
//    if(section == 0)
//        return 2;
     if(section == 0)
        return deviceRowCount;
    else
        return clientRowCount;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0 && [self isSensorNotificationEmpty]){
        return [self createEmptyCell:tableView isSensor:YES];
    }else if(indexPath.section == 1 && [self isClientNotificationEmpty]){
        return [self createEmptyCell:tableView isSensor:NO];
    }
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier ];
    }
//    if (indexPath.section == 0) {
//        cell.textLabel.numberOfLines = 2;
//        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        cell.textLabel.text = @"Suspicious activity on amazon echo";
//        NSString *iconName = @"default_device";
//        cell.imageView.image = [CommonMethods imageNamed:iconName withColor:[UIColor redColor]];
//        cell.detailTextLabel.text = @"5 min ago";
//    }
     if (indexPath.section == 0) {
        if(indexPath.row > (int)self.deviceNotificationArr.count-1)
            return cell;
        //        NSLog(@"indexpathrow: %ld, arraycount: %d", (long)indexPath.row, self.deviceNotificationArr.count-1);
        SFINotification *notification = [self.deviceNotificationArr objectAtIndex:indexPath.row];
        NSString *indexID = [self getgenericIndexfor:notification.deviceType andIndex:@(notification.valueIndex).stringValue];
        GenericValue *gval;
        gval = [self getMatchingGenericValueForGenericIndexID:indexID forValue:notification.value];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.attributedText = [self prepareNotificationText:gval andNotification:notification];
        NSString *iconName = @"default_device";
        if(gval.icon != nil)
            iconName = gval.icon;
        cell.imageView.image = [CommonMethods imageNamed:iconName withColor:[SFIColors ruleBlueColor]];
        cell.detailTextLabel.attributedText = [self setDateLabelText:notification];
    }
    else if(indexPath.section == 1){
        if(indexPath.row > (int)self.clientNotificationArr.count-1)
            return cell;
        
        SFINotification *notification = [self.clientNotificationArr objectAtIndex:indexPath.row];
        
        if ([notification.deviceName rangeOfString:@"joined" options:NSCaseInsensitiveSearch].location != NSNotFound){
            cell.imageView.image = [UIImage imageNamed:@"online"];
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.attributedText = [self forClientNotification:notification];
            cell.detailTextLabel.attributedText = [self setDateLabelText:notification];
        }
        else{
            cell.imageView.image = [UIImage imageNamed:@"offline"];
            cell.textLabel.attributedText = [self forClientNotification:notification];
            cell.detailTextLabel.attributedText = [self forClientNotification:notification];
        }
    }
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = [SFIColors ruleGraycolor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    CGSize itemSize = CGSizeMake(30,30);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0,0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSLog(@"view for header: %ld", (long)section);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    if (section >0) {
        UITableViewHeaderFooterView *foot = (UITableViewHeaderFooterView *)view;
        CGRect sepFrame = CGRectMake(0, 0, 415, 1);
        UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame];
        seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:1.0];
        [foot addSubview:seperatorView];
    }
    NSString *string;
    switch (section) {
//        case 0:
//            string = @"INTERNET SECURITY";
//            break;
//            
        case 0:
            string = NSLocalizedString(@"smart_device_noti_title", @"");
            break;
        case 1:
            string = NSLocalizedString(@"client_noti_title", @"");
            break;
    }
    label.text = string;
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    return view;
}

-(UITableViewCell*)createEmptyCell:(UITableView *)tableView isSensor:(BOOL)isSensor{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell" ];
    }
    cell.imageView.image = [UIImage imageNamed:@"default_device"];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.text = isSensor? NSLocalizedString(@"no_recent_smarthome_notification", @"No Recent SmartHome Activity"): NSLocalizedString(@"no_netwrok_notifications", @"No Recent Network Activity");
    cell.detailTextLabel.text = @"";
    
    return cell;
}

-(BOOL)isSensorNotificationEmpty{
    return self.deviceNotificationArr.count == 0;
}

-(BOOL)isClientNotificationEmpty{
    return self.clientNotificationArr.count == 0;
}

#pragma mark onConnectionStatus

- (void) showNetworkTogglePopUp:(NSString*)title withSubTitle1:(NSString*)subTitle1 withSubTitle2:(NSString*)subTitle2 withMode1:(SFIAlmondConnectionMode)mode1 withMode2:(SFIAlmondConnectionMode)mode2 presentLocalNetworkSettingsEditor:(BOOL)present {
    if(![UIAlertController class]){ // to not support ios 7 or before
        return;
    }
    
    UIAlertController *almondSelect = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"almond_connection", @"Almond Connection") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if([subTitle1 length] != 0){
        almondSelect.title = title;
        UIAlertAction *Check1 = [UIAlertAction
                                 actionWithTitle:subTitle1
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     if(present)
                                         [self presentLocalNetworkSettingsEditor];
                                     else
                                         [self configureNetworkSettings:mode1];
                                 }];
        [almondSelect addAction:Check1];
    }
    
    if([subTitle2 length]!=0){
        UIAlertAction *Check2 = [UIAlertAction
                                 actionWithTitle:subTitle2
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self configureNetworkSettings:mode2];
                                 }];
        [almondSelect addAction:Check2];
    }
    
    UIAlertAction *Close = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"close", @"Close")
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [almondSelect dismissViewControllerAnimated:YES completion:nil];
                            }];
    [almondSelect addAction:Close];
    
    almondSelect.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
    almondSelect.popoverPresentationController.sourceView = self.view;
    almondSelect.popoverPresentationController.permittedArrowDirections = 0;
    if(almondSelect == nil)
        return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:almondSelect animated:YES completion:nil];
    });
}


- (void)presentLocalNetworkSettingsEditor {
    RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
    editor.delegate = self;
    editor.makeLinkedAlmondCurrentOne = YES;
    UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:ctrl animated:YES completion:nil];
}


- (void)onConnectionStatusButtonPressed:(id)sender {
    [_statusIcon onConnectionStatusButtonPressed];
}

- (void)configureNetworkSettings:(enum SFIAlmondConnectionMode)mode {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit setConnectionMode:mode];
    [self showHudWithTimeoutMsg:NSLocalizedString(@"connecting", @"Connecting...") delay:1];
}


-(void)changeColorOfNavigationItam {
    NSLog(@"change color of navigation itam is called");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationImg.image = [CommonMethods imageNamed:@"NavigationBackground" withColor:[SFIColors lightGrayColor]];
        self.bannerImage.image = [CommonMethods imageNamed:@"MainBackground" withColor:[SFIColors lightGrayColor]];
        self.navigationController.view.backgroundColor = [SFIColors lightGrayColor];
        if (self.toolkit.mode_src ==2) {
            [self.buttonHome setBackgroundColor:[SFIColors lightGrayColor] ];
            [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
        }
        else{
            [self.buttonHomeAway setBackgroundColor:[SFIColors lightGrayColor] ];
            [self.buttonHome setBackgroundColor:[UIColor clearColor]];
        }
        [self iotUIUpdate];
    });
}

- (NSAttributedString *)setMessageLabelText:(SFINotification *)notification sensorSupport:(SensorSupport*)sensorSupport {
    if (notification == nil) {
        return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];
    }
    
    NSDictionary *attr;
    UIFont *bold_font = [UIFont securifiBoldFont];
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor blackColor],
             };
    
    NSString *deviceName = notification.deviceName;
    if (notification.deviceType==SFIDeviceType_WIFIClient) {
        NSArray * properties = [notification.deviceName componentsSeparatedByString:@"|"];
        NSString *name = properties[3];
        //        NSLog(@" name notification Name == %@",name);
        if([name rangeOfString:@"An unknown device" options:NSCaseInsensitiveSearch].location != NSNotFound){
            NSArray *nameArr = [name componentsSeparatedByString:@"An unknown device"];
            deviceName = nameArr[1];
        }
        else
            deviceName = name;
    }
    
    if(deviceName == nil || deviceName.length == 0)
        deviceName = @"unknown device";
    
    NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:deviceName attributes:attr];
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor lightGrayColor],
             };
    NSString *message;
    message = sensorSupport.notificationText;
    
    message = message == nil? @"": message;
    NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:message attributes:attr];
    
    NSMutableAttributedString *container = [NSMutableAttributedString new];
    [container appendAttributedString:nameStr];
    [container appendAttributedString:eventStr];
    return  container;
}

- (NSAttributedString *)setDateLabelText:(SFINotification *)notification {
    if (notification == nil) {
        return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];
    }
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:notification.time];
    
    if(date == nil)
        return [[NSAttributedString alloc] initWithString:@"" attributes:@{}];
    
    NSDictionary *attr;
    NSString *str;
    attr = @{
             NSFontAttributeName : [UIFont securifiBoldFontLarge],
             NSForegroundColorAttributeName : [UIColor grayColor],
             };
    formatter.dateFormat = @"dd/MM - hh:mm";
    str = [formatter stringFromDate:date];
    str = (str == nil)? @"": str;
    
    NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:str attributes:attr];
    attr = @{
             NSFontAttributeName : [UIFont securifiBoldFontLarge],
             NSForegroundColorAttributeName : [UIColor lightGrayColor],
             };
    formatter.dateFormat = @"a";
    str = [formatter stringFromDate:date];
    str = (str == nil)? @"": str;
    
    NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:str attributes:attr];
    NSMutableAttributedString *container = [NSMutableAttributedString new];
    [container appendAttributedString:nameStr];
    [container appendAttributedString:eventStr];
    return container;
}


#pragma mark - RouterNetworkSettingsEditorDelegate methods

- (void)networkSettingsEditorDidLinkAlmond:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    
}

- (void)networkSettingsEditorDidChangeSettings:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    [LocalNetworkManagement storeLocalNetworkSettings:newSettings];
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
    [LocalNetworkManagement removeLocalNetworkSettingsForAlmond:almondMac];
    [editor dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark almond selection view
- (void)showAlmondSelection{
    self.buttonMaskView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height)];
    self.buttonMaskView.backgroundColor = [SFIColors maskColor];
    [self.buttonMaskView addTarget:self action:@selector(onBtnMskTap:) forControlEvents:UIControlEventTouchUpInside];
    
    AlmondSelectionTableView *view = [AlmondSelectionTableView new];
    view.methodsDelegate = self;
    view.needsAddAlmond = YES;
    view.currentMAC = [AlmondManagement currentAlmond].almondplusMAC;
    [view initializeView:self.buttonMaskView.frame];
    [self.buttonMaskView addSubview:view];
    
    [self slideAnimation];
}

-(void)slideAnimation{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionReveal;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.buttonMaskView.layer addAnimation:transition forKey:nil];
    [self.tabBarController.view addSubview:self.buttonMaskView];
}

- (void)onCloseBtnTapDelegate{
    [self removeAlmondSelectionView];
}

-(void)onBtnMskTap:(id)sender{
    [self removeAlmondSelectionView];
}

- (void)onAddAlmondTapDelegate{
    NSLog(@"on add almond tap");
    [self removeAlmondSelectionView];
    NSLog(@"i am called");
    switch ([[SecurifiToolkit sharedInstance] currentConnectionMode]) {
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

-(void)onAlmondSelectedDelegate:(SFIAlmondPlus *)selectedAlmond{
    [self removeAlmondSelectionView];
    NSLog(@"i am called");
    
    _toolkit.lastScanTime = 0;
    [AlmondManagement setCurrentAlmond:selectedAlmond];
    [self sendScanNowReq];
    [self iotUIUpdate];
}
-(void)sendScanNowReq{
    SFIAlmondPlus *alm = [AlmondManagement currentAlmond];
    GenericCommand *cmd  = [GenericCommand requestScanNow:alm.almondplusMAC];
    NSLog(@"cmd === %@",cmd);
    [self.toolkit asyncSendToNetwork:cmd];
}

-(void)removeAlmondSelectionView{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.buttonMaskView.alpha = 0;
                     }completion:^(BOOL finished){
                         [self.buttonMaskView removeFromSuperview];
                     }];
    self.buttonMaskView = nil;
}

#pragma mark help screens
-(void)initializeHelpScreens{
    NSLog(@"nav view heigt: %f, view ht: %f", self.navigationController.view.frame.size.height, self.view.frame.size.height);
    [self.toolkit setScreenDefault:@"dashboard"];
    
    NSDictionary *startScreen = [CommonMethods getDict:@"Quick_Tips" itemName:@"Welcome"];
    
    self.helpScreensObj = [HelpScreens initializeHelpScreen:self.navigationController.view isOnMainScreen:YES startScreen:startScreen];
    self.helpScreensObj.delegate = self;
    
    [self.tabBarController.view addSubview:self.helpScreensObj];
    //    [self.tabBarController.tabBar setHidden:YES];
}

#pragma mark helpscreen delegate methods
- (void)resetViewDelegate{
    NSLog(@"dashboard reset view");
    [self.helpScreensObj removeFromSuperview];
    [self.maskView removeFromSuperview];
    //    [self.tabBarController.tabBar setHidden:NO];
    
}

- (void)onSkipTapDelegate{
    NSLog(@"dashboard skip delegate");
    //    [self.tabBarController.tabBar setHidden:YES];
    [self showOkGotItView];
}


- (void)showOkGotItView{
    NSLog(@"showokgotit");
    self.maskView = [[UIView alloc]init];
    self.maskView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height);
    [self.maskView setBackgroundColor:[SFIColors maskColor]];
    [self.tabBarController.view addSubview:self.maskView];
    
    [HelpScreens initializeGotItView:self.helpScreensObj navView:self.navigationController.view];
    
    [self.maskView addSubview:self.helpScreensObj];
}
- (void)launchIOtDevicelit:(id)sender {
    IoTDevicesListViewController *newWindow = [self.storyboard   instantiateViewControllerWithIdentifier:@"IoTDevicesListViewController"];
    NSLog(@"IoTDevicesListViewController IF");
    [self.navigationController pushViewController:newWindow animated:YES];
    //        }
}
-(void)launchMySubscription:(id)sender{
    MySubscriptionsViewController *ctrl = [self getStoryBoardController:@"SiteMapStoryBoard" ctrlID:@"MySubscriptionsViewController"];
    [self pushViewController:ctrl];
}
-(id)getStoryBoardController:(NSString *)storyBoardName ctrlID:(NSString*)ctrlID{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    id controller = [storyboard instantiateViewControllerWithIdentifier:ctrlID];
    return controller;
}


#pragma mark notification methods

-(NSAttributedString *)prepareNotificationText:(GenericValue*)gval andNotification:(SFINotification *)not{
    NSString *notificationString = [NSString stringWithFormat:@"%@",gval.value];
    NSLog(@"outer notificaation obj.value %@",notificationString);
    
        NSDictionary *notificationDict = @{
                                           @"devicename":not.deviceName?not.deviceName:@"",
                                           @"notificationText":gval.notificationText?gval.notificationText:@"",
                                           @"prefix":gval.notificationPrefix?gval.notificationPrefix:@"",
                                           @"value":gval.value,
                                           @"unit":gval.unit?gval.unit:@""
                                           
                                           };
        NSLog(@"outer notificaation obj dict  %@",notificationDict);
        return [self setNotificationLabel:notificationDict];

}
-(NSAttributedString *)setNotificationLabel:(NSDictionary *)notification{
        if (notification == nil) {
            //self.messageTextField.attributedText = [[NSAttributedString alloc] initWithString:@""];
            return [[NSAttributedString alloc] initWithString:@""];
        }
        UIFont *bold_font = [UIFont securifiBoldFont];
        UIFont *normal_font = [UIFont securifiNormalFont];
        NSDictionary *attr;
        attr = @{
                 NSFontAttributeName : bold_font,
                 NSForegroundColorAttributeName : [UIColor blackColor],
                 };
        NSString *deviceName = notification[@"devicename"];
        NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:deviceName attributes:attr];
        
        attr = @{
                 NSFontAttributeName : bold_font,
                 NSForegroundColorAttributeName : [UIColor lightGrayColor],
                 };
        
        NSString *message;
        
        NSMutableAttributedString *mutableAttributedString = nil;
        message = notification[@"notificationText"];
        if (message == nil) {
            message = @"";
        }
        if(![message isEqualToString:@""]){
            NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:message attributes:attr];
            NSMutableAttributedString *container = [NSMutableAttributedString new];
            [container appendAttributedString:nameStr];
            [container appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:nil]];
            [container appendAttributedString:eventStr];
            
            //        self.messageTextField.text = [NSString stringWithFormat:@"%@ %@",deviceName,message];
            return container;
        }
        else{
            NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ %@%@",notification[@"prefix"],message,notification[@"value"],notification[@"unit"]] attributes:attr];
            NSMutableAttributedString *container = [NSMutableAttributedString new];
            [container appendAttributedString:nameStr];
            [container appendAttributedString:eventStr];
            
           return container;
            // self.messageTextField.text = [NSString stringWithFormat:@"%@ %@ %@ %@%@",deviceName,notification[@"prefix"],message,notification[@"value"],notification[@"unit"]];
        }
    
        
}
-(NSString *)getgenericIndexfor:(int)devicetype andIndex:(NSString *)indexId{
    NSString *deviceTypeString = @(devicetype).stringValue;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericDeviceClass *genericDevice = toolkit.genericDevices[deviceTypeString];
    NSDictionary *deviceIndexes = genericDevice.Indexes;
    NSLog(@"deviceIndexes %@",deviceIndexes);
    NSLog(@"deviceIndexArr all keys id %@",indexId);
    BOOL match = NO;
    
    //    for(NSString *key in deviceIndexArr){
    //        DeviceIndex *index = deviceIndexes[key];
    //        [genericIndexes addObject:index.genericIndex];
    for (NSString * ID in deviceIndexes.allKeys) {
        DeviceIndex *index = deviceIndexes[indexId];
        if(index){
            return index.genericIndex;
        }
    }
    return @"0";
}
- (GenericValue*)getMatchingGenericValueForGenericIndexID:(NSString*)genericIndexID forValue:(NSString*)value{
    //NSLog(@"value: %@", value);
    //    if(value.length == 0 || value == nil)
    //        value = @"NaN";
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericIndexClass *genericIndexObject = toolkit.genericIndexes[genericIndexID];
    NSLog(@"genericIndex obj %@",genericIndexObject.layoutType);
    if(genericIndexObject == nil || value == nil)
        return nil;
    if([genericIndexObject.ID isEqualToString:@"30"]){
        NSString *colorShade = [CommonMethods colorShadesforValue:65535 byValueOfcolor:value];
        GenericValue *genericValue1 = [[GenericValue alloc]initWithDisplayTextNotification:genericIndexObject.icon value:colorShade prefix:genericIndexObject.formatter.prefix];
    }
    else if([genericIndexObject.ID isEqualToString:@"31"]){
        NSString *colorShade = [CommonMethods colorShadesforValue:255 byValueOfcolor:value];
        GenericValue *genericValue1 = [[GenericValue alloc]initWithDisplayTextNotification:genericIndexObject.icon value:colorShade prefix:genericIndexObject.formatter.prefix];
    }
    else if(genericIndexObject.values != nil){
        GenericValue *gval = genericIndexObject.values[value];
        NSString *notificationString = [NSString stringWithFormat:@"%@,%@,%@,%@",gval.notificationText,gval.notificationPrefix,value,gval.icon];
        NSLog(@"notificaation obj %@",notificationString);
        
        return genericIndexObject.values[value]? genericIndexObject.values[value]: [[GenericValue alloc]initWithDisplayText:value icon:genericIndexObject.icon toggleValue:nil value:value excludeFrom:nil eventType:nil notificationText:gval.notificationText];
    }
    else if(genericIndexObject.formatter != nil && ([genericIndexObject.layoutType isEqualToString:@"HUE_ONLY"])){
        if([genericIndexObject.ID isEqualToString:@"99"]){
            int brightnessValue = (int)roundf([CommonMethods getBrightnessValue:value]);
            NSString *str = @(brightnessValue).stringValue;
            NSLog(@"slider icon1 - display text: %@, value: %@ units : %@", [genericIndexObject.formatter transform:value genericId:genericIndexID], value,genericIndexObject.formatter.units);
            
            GenericValue *genericValue1 = [[GenericValue alloc]initWithDisplayTextNotification:genericIndexObject.icon value:str prefix:genericIndexObject.formatter.prefix andUnit:genericIndexObject.formatter.units];
            return genericValue1;
        }
        
    }
    else if(genericIndexObject.formatter != nil && ![genericIndexObject.layoutType isEqualToString:@"SLIDER_ICON"] && ![genericIndexObject.layoutType isEqualToString:@"TEXT_VIEW_ONLY"] && ![genericIndexObject.layoutType isEqualToString:@"HUE_ONLY"]){
        NSString *formattedValue=[genericIndexObject.formatter transform:value genericId:genericIndexID];
        NSLog(@"slider icon2 - display text: %@, value: %@ units : %@ ,formattedValue = %@", [genericIndexObject.formatter transform:value genericId:genericIndexID], value,genericIndexObject.formatter.units,formattedValue);
        //NSString *formattedValue = [NSString stringWithFormat:@"",[value floatValue] * genericIndexObject.formatter.factor];
        GenericValue *genericValue1 = [[GenericValue alloc]initWithDisplayTextNotification:genericIndexObject.icon value:formattedValue prefix:genericIndexObject.formatter.prefix andUnit:@""];
        
        //        GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:formattedValue
        //                                                                     iconText:formattedValue
        //                                                                        value:value
        //                                                                  excludeFrom:genericIndexObject.excludeFrom
        //                                                             transformedValue:[genericIndexObject.formatter transformValue:value] prefix:genericIndexObject.formatter.prefix];
        
        return genericValue1;
    }
    else if(genericIndexObject.formatter != nil && ([genericIndexObject.layoutType isEqualToString:@"SLIDER_ICON"] || [genericIndexObject.layoutType isEqualToString:@"TEXT_VIEW_ONLY"])){
        NSLog(@"slider icon - display text: %@, value: %@", [genericIndexObject.formatter transform:value genericId:genericIndexID], value);
        int brightnessValue;
        if([genericIndexObject.ID isEqualToString:@"100"])
            brightnessValue = (int)roundf([CommonMethods getBrightnessValue:value]);
        NSString *value = @(brightnessValue).stringValue;
        NSLog(@"slider icon3 - display text: %@, value: %@ units : %@", [genericIndexObject.formatter transform:value genericId:genericIndexID], value,genericIndexObject.formatter.units);
        NSString *formattedValue = [NSString stringWithFormat:@"",[value floatValue] * genericIndexObject.formatter.factor];
        return [[GenericValue alloc]initWithDisplayText:[genericIndexObject.formatter transform:value genericId:genericIndexID]
                                                   icon:genericIndexObject.icon
                                            toggleValue:nil
                                                  value:formattedValue
                                            excludeFrom:nil
                                              eventType:nil
                                       transformedValue:[genericIndexObject.formatter transformValue:value] prefix:genericIndexObject.formatter.prefix andUnits:genericIndexObject.formatter.units]; //need icon aswell as transformedValue
        
    }
    
    return [[GenericValue alloc]initWithDisplayText:value icon:genericIndexObject.icon toggleValue:value value:value excludeFrom:genericIndexObject.excludeFrom eventType:nil notificationText:@""];
}
-(NSAttributedString *)forClientNotification:(SFINotification *)notification{
   
        NSString *deviceName;
        UIFont *bold_font = [UIFont securifiBoldFont];
        UIFont *normal_font = [UIFont securifiNormalFont];
        NSMutableAttributedString *mutableAttributedString = nil;
        NSDictionary *attr;
        
        attr = @{
                 NSFontAttributeName : bold_font,
                 NSForegroundColorAttributeName : [UIColor blackColor],
                 };

        NSArray * properties = [notification.deviceName componentsSeparatedByString:@"|"];
        NSString *name = properties[3];
        //        NSLog(@" name notification Name == %@",name);
        if([name rangeOfString:@"An unknown device" options:NSCaseInsensitiveSearch].location != NSNotFound){
            NSArray *nameArr = [name componentsSeparatedByString:@"An unknown device"];
            deviceName = nameArr[1];
        }
        else
            deviceName = name;
        
        NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:deviceName attributes:attr];
        //NSLog(@"notification msg: %@", message);
        
         return nameStr;
        
}
   

-(void)pushViewController:(UIViewController *)viewCtrl{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:viewCtrl animated:YES];
    });
}
#pragma mark IOtScan
-(void)iotScanresultsCallBackDashBoard:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        
        if(toolkit.iotScanResults[@"scanDevice"] == Nil){
            NSLog(@"toolkit.iotScanResults = %@",toolkit.iotScanResults);
            self.noIot_label.hidden = NO;
            self.scan_In_progress.hidden = YES;
            self.noIot_label.text = @"No Device scanned";
            self.lastScanIot_label.hidden = YES;
            self.no_scanObjLabel.text = @"0";
            [self checkForLastScanTime];
            self.lastScanIot_label.hidden = YES;
             return ;
        }
        
        
    NSArray *scannedDeviceList = toolkit.iotScanResults[@"scanDevice"];
    NSArray *excludedDevices = toolkit.iotScanResults[@"scanExclude"];
    NSDate *dat = [NSDate dateWithTimeIntervalSince1970:[toolkit.iotScanResults[@"scanTime"] intValue]];
    NSString *lastScanYtime = [dat stringFromDateAMPM];
    NSString *noSiotScanned = [NSString stringWithFormat:@"%ld",scannedDeviceList.count];
        NSLog(@"lastScanYtime == %@",lastScanYtime);
        self.noIot_label.text = [NSString stringWithFormat:@"%@ Devices scanned",toolkit.iotScanResults[@"scanCount"]?toolkit.iotScanResults[@"scanCount"]:@"0"];
        self.lastScanIot_label.text = [NSString stringWithFormat:@"Last scanned at %@",lastScanYtime];
        self.noIot_label.hidden = NO;
        self.scan_In_progress.hidden = YES;
        
//        toolkit.iotScanResults[@"scanCount"]?toolkit.iotScanResults[@"scanCount"]:@"0"
        self.no_scanObjLabel.text = [NSString stringWithFormat:@"%ld",scannedDeviceList.count];
        
        self.lastScanIot_label.hidden = NO;
        if([toolkit.iotScanResults[@"scanCount"] isEqualToString:@"0"]){
            self.noIot_label.text = @"No Device scanned";
            self.lastScanIot_label.hidden = YES;
            self.noIot_label.hidden = NO;
            self.scan_In_progress.hidden = YES;
        }
        [self checkForLastScanTime];
    });

   
}

-(void)checkForLastScanTime{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSLog(@"toolkit.lastScanTime = %ld, toolkit.iotScanResults %lld",toolkit.lastScanTime,[toolkit.iotScanResults[@"scanTime"] longLongValue]);
    NSInteger lastScan =  [toolkit.iotScanResults[@"scanTime"] longLongValue];
    if(lastScan>=toolkit.lastScanTime){
        self.lastScanIot_label.hidden = NO;
        
    }
    else {
        self.lastScanIot_label.hidden = YES;
        self.noIot_label.hidden = YES;
        self.scan_In_progress.hidden = NO;
        self.scan_In_progress.text = @"Scan in progress";
        self.scan_In_progress.alpha = 0;
        [UIView animateWithDuration:1.0 delay:0.2 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            self.scan_In_progress.alpha = 1;
        } completion:nil];
        }
}

@end
