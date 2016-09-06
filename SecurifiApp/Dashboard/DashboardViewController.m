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
#import "UILabel+ActionSheet.h"
#import "UIFont+Securifi.h"
#import "SWRevealViewController.h"
#import "HelpScreens.h"
#import "UICommonMethods.h"
#import "AlmondSelectionTableView.h"

@interface DashboardViewController ()<MBProgressHUDDelegate,RouterNetworkSettingsEditorDelegate, HelpScreensDelegate>{
    UIButton *button, *button1;
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
@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolkit = [SecurifiToolkit sharedInstance];
    if([self.toolkit isScreenShown:@"dashboard"] == NO)
        [self initializeHelpScreens];

    self.navigationController.navigationBar.clipsToBounds = YES;
    [self loadNotification];
    self.clientNotificationArr = [[NSMutableArray alloc]init];
    self.deviceNotificationArr = [[NSMutableArray alloc]init];
    [self navigationBarStyle];
    
    
    button = [[UIButton alloc]init];
    button1 = [[UIButton alloc]init];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [button addTarget:self action:@selector(AlmondSelection:) forControlEvents:UIControlEventTouchUpInside];
    button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button1 addTarget:self action:@selector(AlmondSelection:) forControlEvents:UIControlEventTouchUpInside];
    [Scroller addSubview:button];
    [Scroller addSubview:button1];
    [self SelectAlmond:NSLocalizedString(@"dashBoard AddAlmond", @"Add Almond")];
    [self markNetworkStatusIcon];
    [self initializeHUD];
//    AlmondSelectionTableView *view = [AlmondSelectionTableView new];
//    view.frame = CGRectMake(20, self.view.frame.size.height - 300, self.view.frame.size.width-40, 300);
//    [view initializeView];
//    [self.tabBarController.view addSubview:view];
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
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
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
    
    [self getRecentNotification];
    [self.toolkit tryRefreshNotifications];
    [self initializeUI];

    [self markNetworkStatusIcon];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)initializeUI{
    [self updateMode:self.toolkit.mode_src];
    [self updateDeviceClientListCount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)SelectAlmond : (NSString *)title{
    CGFloat strikeWidth;
    CGSize textSize;
    textSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Medium" size:18]}];
    strikeWidth = textSize.width + 10;
    if(strikeWidth > 150){
        strikeWidth = 150;
    }
    button.frame = CGRectMake(self.view.frame.size.width/2 - strikeWidth/2, 40.0,strikeWidth, 21.0);
    button1.frame = CGRectMake(button.frame.origin.x+strikeWidth, button.frame.origin.y, 21.0, 21.0);
    [button setTitle:title forState:UIControlStateNormal];
    [button1 setBackgroundImage:[UIImage imageNamed:@"arrow_drop_down_black.pdf"] forState:UIControlStateNormal];
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
    
    NSInteger count = [_toolkit countUnviewedNotifications];
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
    self.store = [[SecurifiToolkit sharedInstance] newNotificationStore];
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

-(void)updateDeviceClientListCount{
    if(self.toolkit.currentAlmond != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^() {
            //_labelAlmond.text = self.toolkit.currentAlmond.almondplusName ;
            [self SelectAlmond:self.toolkit.currentAlmond.almondplusName];
            [self.AddAlmond setTitle:self.toolkit.currentAlmond.almondplusName forState:UIControlStateNormal];
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

- (void)onCurrentAlmondChanged:(id)sender {
    NSLog(@"on Current almond changed");

    
    [self.toolkit.devices removeAllObjects];
    [self.toolkit.clients removeAllObjects];
    [self initializeUI];
    [self markNetworkStatusIcon];
    // getrecentnotification to instantly show onclick
    [self getRecentNotification];
    [self.toolkit tryRefreshNotifications];
}

- (void)onAlmondListDidChange:(id)sender {

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
    [self updateDeviceClientListCount];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

- (void)onNotificationCountChanged:(id)event {
    [self.notificationButton markNotificationCount:(NSUInteger) [self.toolkit notificationsBadgeCount]];
}

-(void)onDidReceiveNotifications{
    NSLog(@"onDidReceiveNotifications");
    [self getRecentNotification];
}

- (void)onNetworkUpNotifier:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
    });
}

- (void)onNetworkDownNotifier:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markNetworkStatusIcon];
    });
}

- (void)onNetworkConnectingNotifier:(id)notification {
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
    //    NSLog(@"Almond mode is changing %d",self.toolkit.mode_src);
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
        [self updateMode:(unsigned)[m integerValue]];
        [self.HUD hide:YES];
    });
}

#pragma mark selectAlmond
- (IBAction)AlmondSelection:(UIButton *)sender {
    if(![UIAlertController class]){ // to not support ios 7 or before
        return;
    }
    
    enum SFIAlmondConnectionMode modeValue = [self.toolkit currentConnectionMode];
    NSArray *almondList = [self buildAlmondList:modeValue];
    UIAlertController *viewC;
    viewC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"select_almond", @"Select Almond") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UILabel * appearanceLabel = [UILabel appearanceWhenContainedIn:UIAlertController.class, nil];
    [appearanceLabel setAppearanceFont:[UIFont securifiLightFont:14]];
    
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
                                    [self SelectAlmond:name.almondplusName];
                                    [self.AddAlmond setTitle:name.almondplusName forState:UIControlStateNormal];
                                    //_labelAlmond.text = name.almondplusName;
                                    _labelAlmondStatus.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:14];
                                    _labelAlmond.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:18];
                                }];
        //accessing private properties will cause app to be rejected potentially. (need to develop new view)
//        if ([name.almondplusMAC isEqualToString:self.toolkit.currentAlmond.almondplusMAC]) {
//            UIColor *color = [SFIColors ruleBlueColor];
//            [Aname setValue:color forKey:@"titleTextColor"];
//            
//        }
        
        [Aname setValue:[UIImage imageNamed:@"icon_dashboard"] forKey:@"image"];
        
        [viewC addAction:Aname];
    }
    UIAlertAction *AddNew = [UIAlertAction
                             actionWithTitle:@"+"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action){
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
                                 
                                 
                                 
                                 //                                 UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
                                 
                                 //                                 [self presentViewController:ctrl animated:YES completion:nil];
                                 
                             }];
    UIAlertAction *Check = [UIAlertAction
                            actionWithTitle:NSLocalizedString(@"close", @"Close")
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [viewC dismissViewControllerAnimated:YES completion:nil];
                            }];
    [viewC addAction:AddNew];
    [viewC addAction:Check];
    viewC.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
    viewC.popoverPresentationController.sourceView = self.view;
    viewC.popoverPresentationController.permittedArrowDirections = 0;
    [self presentViewController:viewC animated:YES completion:nil];
    
    
}
- (CGRect)sourceRectForCenteredAlertController
{
    CGRect sourceRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    sourceRect.origin.x = CGRectGetMidX(self.view.bounds)-self.view.frame.origin.x;
    sourceRect.origin.y = CGRectGetMidY(self.view.bounds)-self.view.frame.origin.y;
    return sourceRect;
}
- (NSArray *)buildAlmondList:(enum SFIAlmondConnectionMode)mode5 {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    switch (mode5) {
        case SFIAlmondConnectionMode_cloud: {
            NSArray *cloud = [toolkit almondList];
            if (!cloud)
                cloud = @[];
            return cloud;
        }
        case SFIAlmondConnectionMode_local: {
            NSArray *local = [toolkit localLinkedAlmondList];
            if (!local)
                local = @[];
            return local;
        }
        default:
            return @[];
    }
}



- (IBAction)homeMode:(id)sender {
    if(self.toolkit.currentAlmond != nil){
        [self showHudWithTimeoutMsg:NSLocalizedString(@"mode_home_progress", @"Setting Almond to home mode.") delay:5];
        [_toolkit asyncRequestAlmondModeChange:self.toolkit.currentAlmond.almondplusMAC mode:SFIAlmondMode_home];
    }
}

- (IBAction)homeawayMode:(id)sender {
    if(self.toolkit.currentAlmond != nil){
        [self showHudWithTimeoutMsg:NSLocalizedString(@"mode_away_progress", @"Setting Almond to away mode.") delay:5];
        [_toolkit asyncRequestAlmondModeChange:self.toolkit.currentAlmond.almondplusMAC mode:SFIAlmondMode_away];
    }
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
    self.deviceNotificationArr = [self.store fetchRecentNotifications:self.toolkit.currentAlmond.almondplusMAC isSensor:YES];
    self.clientNotificationArr = [self.store fetchRecentNotifications:self.toolkit.currentAlmond.almondplusMAC isSensor:NO];
    
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
    
    return (section ==0)? deviceRowCount: clientRowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && [self isSensorNotificationEmpty]){
        return [self createEmptyCell:tableView isSensor:YES];
    }else if(indexPath.section == 1 && [self isClientNotificationEmpty]){
        return [self createEmptyCell:tableView isSensor:NO];
    }
    
    SensorSupport *sensorSupport = [SensorSupport new];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier ];
    }
    if (indexPath.section == 0) {
        if(indexPath.row > (int)self.deviceNotificationArr.count-1)
            return cell;
        //        NSLog(@"indexpathrow: %ld, arraycount: %d", (long)indexPath.row, self.deviceNotificationArr.count-1);
        SFINotification *notification = [self.deviceNotificationArr objectAtIndex:indexPath.row];
        [sensorSupport resolveNotification:notification.deviceType index:notification.valueType value:notification.value];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.attributedText = [self setMessageLabelText:notification sensorSupport:sensorSupport];
        NSString *iconName = @"default_device";
        if(sensorSupport.valueSupport != nil)
            iconName = sensorSupport.valueSupport.iconName;
        cell.imageView.image = [CommonMethods imageNamed:iconName withColor:[SFIColors ruleBlueColor]];
        cell.detailTextLabel.attributedText = [self setDateLabelText:notification];
    }
    else{
        if(indexPath.row > (int)self.clientNotificationArr.count-1)
            return cell;
        
        SFINotification *notification = [self.clientNotificationArr objectAtIndex:indexPath.row];
        [sensorSupport resolveNotification:notification.deviceType index:notification.valueType value:notification.value];
        if ([notification.deviceName rangeOfString:@"joined" options:NSCaseInsensitiveSearch].location != NSNotFound){
            cell.imageView.image = [UIImage imageNamed:@"online"];
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.attributedText = [self setMessageLabelText:notification sensorSupport:sensorSupport];
            cell.detailTextLabel.attributedText = [self setDateLabelText:notification];
        }
        else{
            cell.imageView.image = [UIImage imageNamed:@"offline"];
            cell.textLabel.attributedText = [self setMessageLabelText:notification sensorSupport:sensorSupport];
            cell.detailTextLabel.attributedText = [self setDateLabelText:notification];
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
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
-(void)onConnection:(NSString *)Title subTitle:(NSString *)subTitle stmt:(enum SFIAlmondConnectionMode)mode{
    if(![UIAlertController class]){ // to not support ios 7 or before
        return;
    }
    
    UIAlertController *almondSelect = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"almond_connection", @"Almond Connection") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    almondSelect.title = Title;
    UIAlertAction *Check = [UIAlertAction
                            actionWithTitle:subTitle
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [self configureNetworkSettings:mode];
                            }];
    [almondSelect addAction:Check];
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
    [self presentViewController:almondSelect animated:YES completion:nil];
}

-(void)onConnection2:(NSString *)Title subTitle1:(NSString *)subTitle1 subTitle2:(NSString *)subTitle2 stmt1:(enum SFIAlmondConnectionMode)mode1 stmt2:(enum SFIAlmondConnectionMode)mode2{
    UIAlertController *almondSelect = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"almond_connection", @"Almond Connection") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    almondSelect.title = Title;
    UIAlertAction *Check1 = [UIAlertAction
                             actionWithTitle:subTitle1
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self configureNetworkSettings:mode1];
                             }];
    [almondSelect addAction:Check1];
    UIAlertAction *Check2 = [UIAlertAction
                             actionWithTitle:subTitle2
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self configureNetworkSettings:mode2];
                             }];
    [almondSelect addAction:Check2];
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

-(void)onConnection3:(NSString *)Title subTitle:(NSString *)subTitle{
    UIAlertController *almondSelect = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"almond_connection", @"Almond Connection") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    almondSelect.title = Title;
    UIAlertAction *Check = [UIAlertAction
                            actionWithTitle:subTitle
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [self presentLocalNetworkSettingsEditor];
                            }];
    [almondSelect addAction:Check];
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
    [self presentViewController:almondSelect animated:YES completion:nil];
    
}
- (void)presentLocalNetworkSettingsEditor {
    NSString *mac = self.toolkit.currentAlmond.almondplusMAC;
    
    _toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondLocalNetworkSettings *settings = [_toolkit localNetworkSettingsForAlmond:mac];
    NSLog(@"sfitableview - presentlocalnetwork - mac: %@, settings: %@", mac, settings);
    if (!settings) {
        settings = [SFIAlmondLocalNetworkSettings new];
        settings.almondplusMAC = mac;
    }
    
    RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
    editor.delegate = self;
    editor.settings = settings;
    editor.enableUnlinkActionButton = ![_toolkit almondExists:mac]; // only allowed to unlink local almonds that are not affiliated with the cloud
    
    UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:ctrl animated:YES completion:nil];
}

- (void)onConnectionStatusButtonPressed:(id)sender {
    NSString *Title;
    NSString *subTitle1, *subTitle2;
    SFICloudStatusState statusState = self.leftButton.state;
    switch (statusState) {
        case SFICloudStatusStateCloudConnectionNotSupported: {
            Title =NSLocalizedString(@"cloud_conn_not_supported", "Your Almond is not affiliated with the cloud. Only local connection to your Almond is supported.");
            subTitle1 = NSLocalizedString(@"switch_local", @"Switch to Local Connection");
            [self onConnection:Title subTitle: subTitle1 stmt: SFIAlmondConnectionMode_local ];
            break;
        }
        case SFICloudStatusStateLocalConnectionNotSupported: {
            Title = NSLocalizedString(@"alert msg offline Local connection not supported.", "Can't connect to your Almond because local connection settings are missing. Tap edit to add settings.");
            subTitle1 =NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection") ;
            [self onConnection:Title subTitle:subTitle1 stmt: SFIAlmondConnectionMode_cloud ];
            break;
        }
        case SFICloudStatusStateConnecting: {
            Title = NSLocalizedString(@"In process of connecting. Change connection method.", @"In process of connecting. Change connection method.");
            subTitle1 = NSLocalizedString(@"cloud_connection", @"Cloud Connection");
            subTitle2 = NSLocalizedString(@"local_connection", @"Local Connection");
            [self onConnection2:Title subTitle1:subTitle1 subTitle2:subTitle2 stmt1:SFIAlmondConnectionMode_cloud stmt2:SFIAlmondConnectionMode_local];
            break;
        };
        case SFICloudStatusStateDisconnected:
        case SFICloudStatusStateAlmondOffline: {
            Title = NSLocalizedString(@"Alert view fail-Cloud connection to your Almond failed. Tap retry or switch to local connection.", @"Cloud connection to your Almond failed. Tap retry or switch to local connection.");
            subTitle1 = NSLocalizedString(@"switch_local", @"Switch to Local Connection");
            subTitle2 = NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection");
            [self onConnection2:Title subTitle1:subTitle1 subTitle2:subTitle2 stmt1:SFIAlmondConnectionMode_local stmt2:SFIAlmondConnectionMode_cloud];
            break;
        };
        case SFICloudStatusStateConnectionError: {
            Title = NSLocalizedString(@"Can't connect to your Almond. Please select a connection method.", @"Can't connect to your Almond. Please select a connection method.");
            subTitle1 =  NSLocalizedString(@"cloud_connection", @"Cloud Connection");
            subTitle2 = NSLocalizedString(@"local_connection", @"Local Connection");
            [self onConnection2:Title subTitle1:subTitle1 subTitle2:subTitle2 stmt1:SFIAlmondConnectionMode_cloud stmt2:SFIAlmondConnectionMode_local];
            break;
        };
        case SFICloudStatusStateLocalConnectionOffline: {
            Title = NSLocalizedString(@"local_conn_failed_retry", "Local connection to your Almond failed. Tap retry or switch to cloud connection.");
            subTitle1 = NSLocalizedString(@"alert title offline Local Retry Local Connection", @"Retry Local Connection");
            subTitle2 = NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection");
            [self onConnection2:Title subTitle1:subTitle1 subTitle2:subTitle2 stmt1:SFIAlmondConnectionMode_local stmt2:SFIAlmondConnectionMode_cloud];
            break;
        };
        case SFICloudStatusStateConnected: {
            SFIAlmondLocalNetworkSettings *settings = [[SecurifiToolkit sharedInstance] localNetworkSettingsForAlmond:self.toolkit.currentAlmond.almondplusMAC];
            if (settings) {
                Title = NSLocalizedString(@"alert.message-Connected to your Almond via cloud.", @"Connected to your Almond via cloud.");
                subTitle1 = NSLocalizedString(@"switch_local", @"Switch to Local Connection");
                [self onConnection:Title subTitle:subTitle1 stmt:SFIAlmondConnectionMode_local];
            }
            else{
                Title = NSLocalizedString(@"alert.message-Connected to your Almond via cloud.", @"Connected to your Almond via cloud.");
                subTitle1 = NSLocalizedString(@"Add Local Connection Settings", @"Add Local Connection Settings");
                [self onConnection3:Title subTitle:subTitle1];
            }
            break;
        };
        case SFICloudStatusStateLocalConnection: {
            SFIAlmondLocalNetworkSettings *settings = [[SecurifiToolkit sharedInstance] localNetworkSettingsForAlmond:self.toolkit.currentAlmond.almondplusMAC];
            if(settings){
                Title = NSLocalizedString(@"Connected to your Almond locally.", @"Connected to your Almond locally.");
                subTitle1 = NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection");
                [self onConnection:Title subTitle:subTitle1 stmt:SFIAlmondConnectionMode_cloud];
                break;
            }
            else{
                Title = NSLocalizedString(@"alert msg offline Local connection not supported.", @"Local connection settings are missing.");
                subTitle1 = NSLocalizedString(@"Add Local Connection Settings", @"Add Local Connection Settings");
                [self onConnection3:Title subTitle:subTitle1];
                break;
            }
        };
        case SFICloudStatusStateAway:
        case SFICloudStatusStateAtHome:
            return;
        default:
            return;
    }
}

- (void)configureNetworkSettings:(enum SFIAlmondConnectionMode)mode {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit setConnectionMode:mode forAlmond:self.toolkit.currentAlmond.almondplusMAC];
    [self showHudWithTimeoutMsg:NSLocalizedString(@"connecting", @"Connecting...") delay:1];
    [toolkit.devices removeAllObjects];
    [toolkit.clients removeAllObjects];
    [toolkit.scenesArray removeAllObjects];
    [toolkit.ruleList removeAllObjects];
}

- (void)markNetworkStatusIcon {
    NSString *const almondMac = self.toolkit.currentAlmond.almondplusMAC;
    //    NSLog(@"markNetworkStatusIcon");
    enum SFIAlmondConnectionMode connectionMode = [_toolkit connectionModeForAlmond:almondMac];
    enum SFIAlmondConnectionStatus status = [_toolkit connectionStatusForAlmond:almondMac];
    enum SFICloudStatusState state;
    switch (status) {
        case SFIAlmondConnectionStatus_disconnected: {
            state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateDisconnected : SFICloudStatusStateLocalConnectionOffline;
            [self.leftButton markState:state];
            [self changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_connecting: {
            [self.leftButton markState:SFICloudStatusStateConnecting];
            [self changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_connected: {
            state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateConnected : SFICloudStatusStateLocalConnection;
            [self.leftButton markState:state];
            [self updateMode:self.toolkit.mode_src];
            break;
        };
        case SFIAlmondConnectionStatus_error: {
            [self changeColorOfNavigationItam];
            break;
        };
        case SFIAlmondConnectionStatus_error_mode: {
            state = (connectionMode == SFIAlmondConnectionMode_cloud) ? SFICloudStatusStateCloudConnectionNotSupported : SFICloudStatusStateLocalConnectionNotSupported;
            [self.leftButton markState:state];
            [self changeColorOfNavigationItam];
            break;
        }
    }
}

-(void)changeColorOfNavigationItam {
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
    [editor dismissViewControllerAnimated:YES completion:nil];
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


@end