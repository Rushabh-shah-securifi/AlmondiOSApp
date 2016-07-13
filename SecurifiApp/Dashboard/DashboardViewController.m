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

@interface DashboardViewController ()<MBProgressHUDDelegate,RouterNetworkSettingsEditorDelegate>{
    UIButton *button, *button1;
}

@property(nonatomic) SFICloudStatusBarButtonItem *leftButton;
@property(nonatomic) SFINotificationStatusBarButtonItem *notificationButton;
@property(nonatomic) SecurifiToolkit *toolkit;
@property(nonatomic) MBProgressHUD *HUD;
@property(nonatomic) SFINotificationsViewController *notify;
@property(nonatomic) id <SFINotificationStore> store;
@property(nonatomic) NSMutableArray *clientNotificationArr;
@property(nonatomic) NSMutableArray *deviceNotificationArr;
@property(nonatomic) CircleLabel *countLabel;
@property(nonatomic) UIButton *countButton;
@property(nonatomic) UIImageView *navigationImg;
@property(nonatomic) UIView *bgView;

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolkit = [SecurifiToolkit sharedInstance];
    self.bgView = [[UIView alloc]init];
    
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
    [self SelectAlmond:@"AddAlmond"];
    [self markNetworkStatusIcon];
    [self initializeNotification];
    [self initializeHUD];
}

#pragma mark help screen
-(void)showAlmondUpdateAvailableScreen:(UIView*)view{
    int viewWidth = self.navigationController.view.frame.size.width;
    
    self.bgView.frame = CGRectMake(0, 0, viewWidth, self.navigationController.view.frame.size.height);
    _bgView.backgroundColor = [UIColor whiteColor];
    [view addSubview:self.bgView];
    
    SWRevealViewController *revealController = [self revealViewController];
    UIButton *crossButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, 30, 40)];
    [crossButton setImage:[CommonMethods imageNamed:@"drawer" withColor:[UIColor blackColor]] forState:UIControlStateNormal];
    crossButton.tintColor = [UIColor blackColor];
    [crossButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:crossButton];

    UILabel *hdrTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewWidth, 40)];
    [CommonMethods setLableProperties:hdrTitle text:@"Almond Update Available" textColor:[UIColor blackColor] fontName:@"AvenirLTStd-Heavy" fontSize:20 alignment:NSTextAlignmentCenter];
    hdrTitle.center = CGPointMake(self.view.bounds.size.width/2 + 5, hdrTitle.center.y);
    [self.bgView addSubview:hdrTitle];
    
    [CommonMethods addLineSeperator:self.bgView yPos:65];
    
    //image 200
    UIImageView *routerSettingImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, 200, 180)];
    routerSettingImg.center = CGPointMake(self.view.bounds.size.width/2, routerSettingImg.center.y);
    routerSettingImg.image = [UIImage imageNamed:@"almond_settings"];
    [self.bgView addSubview:routerSettingImg];
    
    //detail view
    UIView *detailView = [[UIView alloc]initWithFrame:CGRectMake(0, 315, viewWidth,250)];
    [self.bgView addSubview:detailView];
    
    UILabel *detailTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 20)];
    [CommonMethods setLableProperties:detailTitle text:@"Your Almond requires an update." textColor:[SFIColors grayShade] fontName:@"AvenirLTStd-Heavy" fontSize:20 alignment:NSTextAlignmentCenter];
    [detailView addSubview:detailTitle];
    
    UILabel *detail = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, viewWidth-15, 220)];
    NSString *text = @"With this update, you will receive a new dashboard in your Almond app as well as improvements for stability under the hood. The Almond firmware needs to be updated to remain compatible with this version of the app. Please tap on \"Settings\" on the Almond LCD and follow the on screen instructions to update your firmware.";
    [CommonMethods setLableProperties:detail text:text textColor:[SFIColors grayShade] fontName:@"AvenirLTStd-Light" fontSize:18 alignment:NSTextAlignmentCenter];
    [CommonMethods setLineSpacing:detail text:text spacing:3];
    [detail sizeToFit];
    [detailView addSubview:detail];

    //button
//    UIButton *gotItButton = [[UIButton alloc]initWithFrame:CGRectMake(10, self.navigationController.view.frame.size.height - 50, viewWidth - 20, 40)];
//    [self setButtonProperties:gotItButton title:@"Ok, got it" selector:@selector(onGotItTap:) titleColor:[UIColor whiteColor]];
//    gotItButton.backgroundColor = [SFIColors helpPurpleColor];
//    [self.bgView addSubview:gotItButton];
}


//-(void)onCrossTap:(UIButton *)tapbutton{
//    NSLog(@"onCrossTap");
//    [self.bgView removeFromSuperview];
//    [self.tabBarController.tabBar setHidden:NO];
//}

//-(void)onGotItTap:(UIButton *)button{
//    NSLog(@"onGotItTap");
//    [self.bgView removeFromSuperview];
//    [self.tabBarController.tabBar setHidden:NO];
//}


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

    [self.toolkit tryRefreshNotifications];
    [self initializeNotification];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.dashboardTable reloadData];
    });
    [self getDeviceClientNotification];
    [self markNetworkStatusIcon];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)initializeNotification{
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
    strikeWidth = textSize.width;
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
    
    [self.buttonHomeAway setImage:[CommonMethods imageNamed:@"homeaway_icon1_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
    [self.buttonHome setImage:[CommonMethods imageNamed:@"home_icon1_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
    
    _leftButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:self action:@selector(onConnectionStatusButtonPressed:) enableLocalNetworking:YES];
    self.leftButton.isDashBoard = YES;
    
    _notificationButton = [[SFINotificationStatusBarButtonItem alloc] initWithTarget:self action:@selector(notificationAction:)];
    
    NSInteger count = [_toolkit countUnviewedNotifications];
    [_notificationButton markNotificationCount:(NSUInteger) count];
    _notificationButton.isDashBoard = YES;
    self.navigationItem.leftBarButtonItems = @[_leftButton, _notificationButton];
}

#pragma mark notification
-(void)loadNotification{
    self.notify = [[SFINotificationsViewController alloc] init];
    _store = [self.notify pickNotificationStore];
    self.notify.store = _store;
    [self.notify resetBucketsAndNotifications];
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
            [self.buttonHomeAway setImage:[CommonMethods imageNamed:@"homeaway_icon1_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
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
            [self.buttonHomeAway setImage:[CommonMethods imageNamed:@"homeaway_icon1_white" withColor:[UIColor clearColor]] forState:UIControlStateNormal];
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
            _smartHomeConnectedDevices.text = [NSString stringWithFormat:@"%lu ",(unsigned long)self.toolkit.devices.count ];
            _networkConnectedDevices.text =[NSString stringWithFormat:@"%d ",[Client activeClientCount] ];
            _totalConnectedDevices.text = [NSString stringWithFormat: @"%lu", (unsigned long)(self.toolkit.devices.count + self.toolkit.clients.count)];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self SelectAlmond:@"AddAlmond"];
            [self.AddAlmond setTitle:@"AddAlmond" forState:UIControlStateNormal];
            //_labelAlmond.text = @"AddAlmond";
            _labelHomeAway.hidden = YES;
            _labelHome.hidden = YES;
            [self.buttonHomeAway setImage:[CommonMethods imageNamed:@"homeaway_icon1_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
            [self.buttonHome setImage:[CommonMethods imageNamed:@"home_icon1_white" withColor:[UIColor grayColor]] forState:UIControlStateNormal];
            [self.buttonHome setBackgroundColor:[UIColor clearColor]];
            [self.buttonHomeAway setBackgroundColor:[UIColor clearColor]];
            _smartHomeConnectedDevices.text = [NSString stringWithFormat:@"%d ",0 ];
            _networkConnectedDevices.text =[NSString stringWithFormat:@"%d ",0 ];
            _totalConnectedDevices.text = [NSString stringWithFormat: @"%d",0];
        });
    }
}

- (void)onCurrentAlmondChanged:(id)sender {
    NSLog(@"on Current almond changed");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self checkToShowUpdateScreen];
    });
    
    [self.toolkit.devices removeAllObjects];
    [self.toolkit.clients removeAllObjects];
    [self initializeNotification];
    [self markNetworkStatusIcon];
    [self.toolkit tryRefreshNotifications];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.dashboardTable reloadData];
    });
}

- (void)onAlmondListDidChange:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self checkToShowUpdateScreen];
    });
}


-(void)checkToShowUpdateScreen{
    SFIAlmondPlus *currentAlmond = self.toolkit.currentAlmond;
    NSLog(@"current almond dash: %@", currentAlmond);
    if(currentAlmond.firmware == nil)
        return;
    NSLog(@"passed");
    BOOL isNewVersion = [currentAlmond supportsGenericIndexes:currentAlmond.firmware];
    if(!isNewVersion){
        [self.tabBarController.tabBar setHidden:YES];
        [self showAlmondUpdateAvailableScreen:self.navigationController.view];
    }else{
        [self.tabBarController.tabBar setHidden:NO];
        [self.bgView removeFromSuperview];
    }
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
        [self.dashboardTable reloadData];
        [self.HUD hide:YES];
    });
}

- (void)onNotificationCountChanged:(id)event {
    [self.notificationButton markNotificationCount:(NSUInteger) [self.toolkit notificationsBadgeCount]];
}

-(void)onDidReceiveNotifications{
    _store = [self.notify pickNotificationStore];
    self.notify.store = _store;
    [self.notify resetBucketsAndNotifications];
    [self getDeviceClientNotification];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.dashboardTable reloadData];
    });
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
    enum SFIAlmondConnectionMode modeValue = [self.toolkit currentConnectionMode];
    NSArray *almondList = [self buildAlmondList:modeValue];
    UIAlertController *viewC;
    viewC = [UIAlertController alertControllerWithTitle:@"Select Almond" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
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
        if ([name.almondplusMAC isEqualToString:self.toolkit.currentAlmond.almondplusMAC]) {
            UIColor *color = [SFIColors ruleBlueColor];
            [Aname setValue:color forKey:@"titleTextColor"];
        }
        
        [Aname setValue:[UIImage imageNamed:@"icon_dashboard"] forKey:@"image"];
        
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
        [self showHudWithTimeoutMsg:@"Setting Almond to home mode." delay:5];
        [_toolkit asyncRequestAlmondModeChange:self.toolkit.currentAlmond.almondplusMAC mode:SFIAlmondMode_home];
    }
}

- (IBAction)homeawayMode:(id)sender {
    if(self.toolkit.currentAlmond != nil){
        [self showHudWithTimeoutMsg:@"Setting Almond to away mode." delay:5];
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

-(void )getDeviceClientNotification{
    [self.deviceNotificationArr removeAllObjects];
    [self.clientNotificationArr removeAllObjects];
    if(self.toolkit.currentAlmond != nil){
        for(int j = 0; j<10;j++){// for 10 days
            for (int i =0; i<150; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:j];
                SFINotification *notification = [self.notify notificationForIndexPath:indexPath];
                
                if(notification.deviceType != SFIDeviceType_WIFIClient && notification!=Nil && [notification.almondMAC isEqualToString: self.toolkit.currentAlmond.almondplusMAC]){
                    if(self.deviceNotificationArr.count < 3)
                        [self.deviceNotificationArr addObject:notification];
                    else if (self.deviceNotificationArr.count > 3 && self.clientNotificationArr.count > 2)
                        return;
                }
                else if(notification!=Nil && [notification.almondMAC isEqualToString: self.toolkit.currentAlmond.almondplusMAC]){
                    if(self.clientNotificationArr.count < 2)
                        [self.clientNotificationArr addObject:notification];
                    else if (self.deviceNotificationArr.count > 3 && self.clientNotificationArr.count > 2)
                        return;
                }
            }
        }
    }
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

-(UITableViewCell*)createEmptyCell:(UITableView *)tableView isSensor:(BOOL)isSensor{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell" ];
    }
    cell.imageView.image = [UIImage imageNamed:@"default_device"];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.text = isSensor? @"No Recent SmartHome Activity": @"No Recent Network Activity";
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
    UIAlertController *almondSelect = [UIAlertController alertControllerWithTitle:@"Almond Connection" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
                            actionWithTitle:@"Close"
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
    UIAlertController *almondSelect = [UIAlertController alertControllerWithTitle:@"Almond Connection" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
                            actionWithTitle:@"Close"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                                [almondSelect dismissViewControllerAnimated:YES completion:nil];
                            }];
    [almondSelect addAction:Close];
    almondSelect.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0);
    almondSelect.popoverPresentationController.sourceView = self.view;
    almondSelect.popoverPresentationController.permittedArrowDirections = 0;
    almondSelect.popoverPresentationController.permittedArrowDirections = 0;
    [self presentViewController:almondSelect animated:YES completion:nil];
}

-(void)onConnection3:(NSString *)Title subTitle:(NSString *)subTitle{
    UIAlertController *almondSelect = [UIAlertController alertControllerWithTitle:@"Almond Connection" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
                            actionWithTitle:@"Close"
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
            Title =NSLocalizedString(@"alert msg offline Cloud connection not supported.", "Your Almond is not affiliated with the cloud. Only local connection to your Almond is supported.");
            subTitle1 = NSLocalizedString(@"Alert view title-Switch to Local Connection", @"Switch to Local Connection");
            [self onConnection:Title subTitle: subTitle1 stmt: SFIAlmondConnectionMode_local ];
            break;
        }
        case SFICloudStatusStateLocalConnectionNotSupported: {
            Title = NSLocalizedString(@"alert msg offline Local connection not supported.", "Can't connect to your Almond because local connection settings are missing. Tap edit to add settings.");
            subTitle1 =NSLocalizedString(@"alert title offline Local Switch to Cloud Connection", @"Switch to Cloud Connection") ;
            [self onConnection:Title subTitle:subTitle1 stmt: SFIAlmondConnectionMode_cloud ];
            break;
        }
        case SFICloudStatusStateConnecting: {
            Title = NSLocalizedString(@"In process of connecting. Change connection method.", @"In process of connecting. Change connection method.");
            subTitle1 = @"Cloud Connection";
            subTitle2 = @"Local Connection";
            [self onConnection2:Title subTitle1:subTitle1 subTitle2:subTitle2 stmt1:SFIAlmondConnectionMode_cloud stmt2:SFIAlmondConnectionMode_local];
            break;
        };
        case SFICloudStatusStateDisconnected:
        case SFICloudStatusStateAlmondOffline: {
            Title = NSLocalizedString(@"Alert view fail-Cloud connection to your Almond failed. Tap retry or switch to local connection.", @"Cloud connection to your Almond failed. Tap retry or switch to local connection.");
            subTitle1 = @"Switch to Local Connection";
            subTitle2 = @"Switch to Cloud Connection";
            [self onConnection2:Title subTitle1:subTitle1 subTitle2:subTitle2 stmt1:SFIAlmondConnectionMode_local stmt2:SFIAlmondConnectionMode_cloud];
            break;
        };
        case SFICloudStatusStateConnectionError: {
            Title = NSLocalizedString(@"alertview Can't connect to your Almond. Please select a connection method.", @"Can't connect to your Almond. Please select a connection method.");
            subTitle1 = @"Cloud Connection";
            subTitle2 = @"Local Connection";
            [self onConnection2:Title subTitle1:subTitle1 subTitle2:subTitle2 stmt1:SFIAlmondConnectionMode_cloud stmt2:SFIAlmondConnectionMode_local];
            break;
        };
        case SFICloudStatusStateLocalConnectionOffline: {
            Title = NSLocalizedString(@"alert msg offline Local connection to your Almond failed. Tap retry or switch to cloud connection.", "Local connection to your Almond failed. Tap retry or switch to cloud connection.");
            subTitle1 = NSLocalizedString(@"alert title offline Local Retry Local Connection", @"Retry Local Connection");
            subTitle2 = NSLocalizedString(@"alert title offline Local Switch to Cloud Connection", @"Switch to Cloud Connection");
            [self onConnection2:Title subTitle1:subTitle1 subTitle2:subTitle2 stmt1:SFIAlmondConnectionMode_local stmt2:SFIAlmondConnectionMode_cloud];
            break;
        };
        case SFICloudStatusStateConnected: {
            SFIAlmondLocalNetworkSettings *settings = [[SecurifiToolkit sharedInstance] localNetworkSettingsForAlmond:self.toolkit.currentAlmond.almondplusMAC];
            if (settings) {
                Title = NSLocalizedString(@"alert.message-Connected to your Almond via cloud.", @"Connected to your Almond via cloud.");
                subTitle1 = @"Switch to Local Connection";
                [self onConnection:Title subTitle:subTitle1 stmt:SFIAlmondConnectionMode_local];
            }
            else{
                Title = NSLocalizedString(@"alertview -Connected to your Almond via cloud.", @"Connected to your Almond via cloud.");
                subTitle1 = @"Add Local Connection Settings";
                [self onConnection3:Title subTitle:subTitle1];
            }
            break;
        };
        case SFICloudStatusStateLocalConnection: {
            SFIAlmondLocalNetworkSettings *settings = [[SecurifiToolkit sharedInstance] localNetworkSettingsForAlmond:self.toolkit.currentAlmond.almondplusMAC];
            if(settings){
                Title = NSLocalizedString(@"alertview localconnection_Connected to your Almond locally.", @"Connected to your Almond locally.");
                subTitle1 = NSLocalizedString(@"alertview localconnection_Switch to Cloud Connection", @"Switch to Cloud Connection");
                [self onConnection:Title subTitle:subTitle1 stmt:SFIAlmondConnectionMode_cloud];
                break;
            }
            else{
                Title = NSLocalizedString(@"alertview Local connection settings are missing.", @"Local connection settings are missing.");
                subTitle1 = NSLocalizedString(@"alertview title Add Local Connection Settings", @"Add Local Connection Settings");
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
    [self showHudWithTimeoutMsg:@"Connecting..." delay:1];
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
            [self getDeviceClientNotification];
            [self updateMode:self.toolkit.mode_src];
            dispatch_async(dispatch_get_main_queue(), ^() {
                [self.dashboardTable reloadData];
            });
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
    NSDictionary *attr;
    UIFont *bold_font = [UIFont securifiBoldFont];
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor blackColor],
             };
    if (notification == nil) {
        return [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    }
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
    if (notification == nil)
        return [[NSAttributedString alloc] initWithString:@"" attributes:attr];
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
@end