//
//  SFIRouterTopTableViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIRouterTableViewController.h"
#import "SFIColors.h"
#import "AlmondPlusConstants.h"
#import "SFIParser.h"
#import "MBProgressHUD.h"
#import "Analytics.h"
#import "UIFont+Securifi.h"
#import "SFICardView.h"
#import "SFICardTableViewCell.h"
#import "SFIRouterSettingsTableViewCell.h"
#import "SFIRouterDevicesTableViewCell.h"
#import "SFIRouterRebootTableViewCell.h"
#import "SFIRouterSendLogsTableViewCell.h"
#import "SFIRouterTableViewActions.h"
#import "SFICardViewSummaryCell.h"
#import "MessageView.h"
#import "TableHeaderView.h"
#import "SFIRouterVersionTableViewCell.h"
#import "UIViewController+Securifi.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "SFICloudLinkViewController.h"
#import "UIColor+Securifi.h"
#import "SFIWiFiClientsListViewController.h"

#define DEF_NETWORKING_SECTION          0
#define DEF_WIRELESS_SETTINGS_SECTION   1
#define DEF_DEVICES_AND_USERS_SECTION   2
#define DEF_ROUTER_VERSION_SECTION      3
#define DEF_ROUTER_REBOOT_SECTION       4
#define DEF_ROUTER_SEND_LOGS_SECTION    5

typedef NS_ENUM(unsigned int, RouterViewState) {
    RouterViewState_no_almond = 1,
    RouterViewState_almond_unavailable = 2,
    RouterViewState_cloud_offline = 3,
    RouterViewState_cloud_connected = 4,
};

typedef NS_ENUM(unsigned int, RouterViewReloadPolicy) {
    RouterViewReloadPolicy_always = 1,
    RouterViewReloadPolicy_never = 2,
    RouterViewReloadPolicy_on_state_change = 3,
};

typedef NS_ENUM(unsigned int, AlmondSupportsSendLogs) {
    AlmondSupportsSendLogs_unknown = 0,
    AlmondSupportsSendLogs_yes,
    AlmondSupportsSendLogs_no,
};

@interface SFIRouterTableViewController () <SFIRouterTableViewActions, MessageViewDelegate, AlmondVersionCheckerDelegate, TableHeaderViewDelegate>
@property SFIAlmondPlus *currentAlmond;
@property BOOL newAlmondFirmwareVersionAvailable;
@property NSString *latestAlmondVersionAvailable;
@property enum AlmondSupportsSendLogs almondSupportsSendLogs;
@property enum SFIRouterTableViewActionsMode sendLogsEditCellMode; // set during command response callback and reset when almond is changed and view is refreshed

@property NSTimer *hudTimer;
@property enum RouterViewState routerViewState;

@property(nonatomic, strong) SFIRouterSummary *routerSummary;
@property(nonatomic, strong) NSArray *wirelessSettings;
@property(nonatomic, strong) NSArray *connectedDevices;     // SFIConnectedDevice
@property(nonatomic, strong) NSArray *blockedDevices;       // SFIBlockedDevice

@property NSNumber *currentExpandedSection; // nil == none expanded
@property NSUInteger currentExpandedCount; // number of rows in expanded section
@property BOOL allowCellExpandControl;

@property BOOL isRebooting;
@property BOOL isAlmondUnavailable;
@property BOOL shownHudOnce;
@property BOOL disposed;

@property(nonatomic) BOOL enableRouterWirelessControl;
@property(nonatomic) BOOL enableNetworkingControl;
@end

@implementation SFIRouterTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // need to set initial state before the table view state is set up to ensure the correct view/layout is rendered.
        // the table's initial set up is done even prior to calling viewDidLoad
        [self checkRouterViewState:RouterViewReloadPolicy_never];
    }

    return self;
}

- (void)viewDidLoad {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SecurifiConfigurator *configurator = toolkit.configuration;
    self.enableRouterWirelessControl = configurator.enableRouterWirelessControl;
    self.enableNetworkingControl = configurator.enableLocalNetworking;

    [super viewDidLoad];

//    SFIAlmondPlus *plus = [toolkit currentAlmond];
//    [self markAlmondMac:plus.almondplusMAC];

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self addRefreshControl];
    [self initializeNotifications];

    [self initializeRouterSummaryAndSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initializeAlmondData:RouterViewReloadPolicy_on_state_change];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        self.disposed = YES;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];

        [self.hudTimer invalidate];
    }
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self selector:@selector(onNetworkChange:) name:NETWORK_DOWN_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onNetworkChange:) name:NETWORK_UP_NOTIFIER object:nil];

    [center addObserver:self selector:@selector(onNetworkChange:) name:kSFIReachabilityChangedNotification object:nil];
    [center addObserver:self selector:@selector(onConnectionModeDidChange:) name:kSFIDidChangeAlmondConnectionMode object:nil];

    [center addObserver:self selector:@selector(onCurrentAlmondChanged:) name:kSFIDidChangeCurrentAlmond object:nil];
    [center addObserver:self selector:@selector(onAlmondListDidChange:) name:kSFIDidUpdateAlmondList object:nil];

    [center addObserver:self selector:@selector(onGenericResponseCallback:) name:GENERIC_COMMAND_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onGenericNotificationCallback:) name:GENERIC_COMMAND_CLOUD_NOTIFIER object:nil];

    [center addObserver:self selector:@selector(onAlmondRouterCommandResponse:) name:ALMOND_COMMAND_RESPONSE_NOTIFIER object:nil];

	[center addObserver:self selector:@selector(onWiFiClientsListResponseCallback:) name:NOTIFICATION_WIFI_CLIENTS_LIST_RESPONSE object:nil];//md01
}

- (void)initializeRouterSummaryAndSettings {
    self.isRebooting = NO;
    self.enableDrawer = YES;

    // init state
    self.routerSummary = nil;
    self.wirelessSettings = nil;
    self.connectedDevices = nil;
    self.blockedDevices = nil;
    self.currentExpandedSection = nil;
    self.currentExpandedCount = 0;
    self.allowCellExpandControl = YES;
}

- (void)initializeAlmondData:(enum RouterViewReloadPolicy)refreshPolicy {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];

    self.currentAlmond = plus;

    if (plus == nil) {
        self.navigationItem.title = @"Get Started";
        [self markAlmondMac:NO_ALMOND];
    }
    else {
        [self markAlmondMac:plus.almondplusMAC];
        self.navigationItem.title = plus.almondplusName;
    }

    if (!self.shownHudOnce) {
        self.shownHudOnce = YES;
        [self showHudWithTimeout];
    }

    // Reset New Version checking state and view
    self.newAlmondFirmwareVersionAvailable = NO;
    self.almondSupportsSendLogs = AlmondSupportsSendLogs_unknown;
    self.tableView.tableHeaderView = nil;
    self.sendLogsEditCellMode = SFIRouterTableViewActionsMode_unknown;

    [self checkRouterViewState:refreshPolicy];
    
    // refresh data
    [self sendRouterSummaryRequest];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //DLog(@"Rotation %d", fromInterfaceOrientation);
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    ELog(@"%s, Did receive memory warning", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}

#pragma mark - State

// determines the presentation state and optionally reloads the view
- (void)checkRouterViewState:(RouterViewReloadPolicy)reloadTablePolicy {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self syncCheckRouterViewState:reloadTablePolicy];
    });
}

// determines the presentation state and optionally reloads the view
- (void)syncCheckRouterViewState:(RouterViewReloadPolicy)reloadTablePolicy {
    RouterViewState state;
    if ([self isNoAlmondLoaded]) {
        state = RouterViewState_no_almond;
    }
    else if (self.isAlmondUnavailable) {
        state = RouterViewState_almond_unavailable;
    }
    else if (![self isCloudOnline]) {
        state = RouterViewState_cloud_offline;
    }
    else {
        state = RouterViewState_cloud_connected;
    }

    RouterViewState oldState = self.routerViewState;
    self.routerViewState = state;

    switch (reloadTablePolicy) {
        case RouterViewReloadPolicy_always:
            [self.tableView reloadData];
            break;
        case RouterViewReloadPolicy_never:
            // do nothing
            break;
        case RouterViewReloadPolicy_on_state_change:
            if (oldState != state) {
                [self.tableView reloadData];
            }
            break;
    }
}

- (BOOL)isNoAlmondLoaded {
    return [self.almondMac isEqualToString:NO_ALMOND];
}

- (BOOL)isCloudOnline {
    return [[SecurifiToolkit sharedInstance] isCloudOnline];
}

#pragma mark - Commands

- (void)sendRouterSummaryRequest {
    if (self.routerViewState == RouterViewState_no_almond) {
        return;
    }
    [[SecurifiToolkit sharedInstance] asyncAlmondSummaryInfoRequest:self.almondMac];
}

- (void)sendRouterDetailsRequest {
    if (self.routerViewState == RouterViewState_no_almond) {
        return;
    }

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSString *mac = self.almondMac;

    if (!mac) {
        NSLog(@"Router: sendRouterDetailsRequest, mac is null");
    }

    [toolkit asyncAlmondStatusAndSettingsRequest:mac request:SecurifiToolkitAlmondRouterRequest_settings];
    [toolkit asyncAlmondStatusAndSettingsRequest:mac request:SecurifiToolkitAlmondRouterRequest_wifi_clients];
}

- (void)sendUpdateAlmondFirmwareCommand {
    if (self.routerViewState == RouterViewState_no_almond) {
        return;
    }

    [[SecurifiToolkit sharedInstance] asyncUpdateAlmondFirmware:self.almondMac firmwareVersion:self.latestAlmondVersionAvailable];
}

- (void)sendRebootAlmondCommand {
    if (self.routerViewState == RouterViewState_no_almond) {
        return;
    }

    [[SecurifiToolkit sharedInstance] asyncRebootAlmond:self.almondMac];
}

- (void)sendSendLogsCommand:(NSString *)description {
    if (self.routerViewState == RouterViewState_no_almond) {
        return;
    }

    [[SecurifiToolkit sharedInstance] asyncSendAlmondLogs:self.almondMac problemDescription:description];
}

#pragma mark HUD mgt

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showLoadingRouterDataHUD];
        self.hudTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onHudTimeout:) userInfo:nil repeats:NO];
    });
}

- (void)onHudTimeout:(id)sender {
    [self.hudTimer invalidate];
    self.hudTimer = nil;

    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

#pragma mark - Event handlers

- (void)onNetworkChange:(id)notice {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }
        [self syncCheckRouterViewState:RouterViewReloadPolicy_on_state_change];
    });
}

- (void)onConnectionModeDidChange:(id)notice {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }
        [self syncCheckRouterViewState:RouterViewReloadPolicy_always];
    });
}

- (void)onCurrentAlmondChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.shownHudOnce = NO;
        if (self.isViewLoaded && self.view.window) {
            // View is visible; reload now; otherwise, viewWillAppear will invoke it for us
            [self initializeRouterSummaryAndSettings];
            [self initializeAlmondData:RouterViewReloadPolicy_always];
        }
    });
}

- (void)onEditNetworkSettings:(id)sender {
    [self presentLocalNetworkSettingsEditor];
}

- (void)onEditWirelessSettingsCard:(id)sender {
    BOOL expanded = [self isSectionExpanded:DEF_WIRELESS_SETTINGS_SECTION];
    if (!expanded) {
        if (self.wirelessSettings.count == 0) {
            [self showLoadingRouterDataHUD];
            [self sendRouterDetailsRequest];
        }
    }

    [self onExpandCloseSection:self.tableView section:DEF_WIRELESS_SETTINGS_SECTION];
}

- (void)onEditDevicesAndUsersCard:(id)sender {
//    [self onExpandCloseSection:self.tableView section:DEF_DEVICES_AND_USERS_SECTION];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Scenes_Iphone" bundle:nil];
    SFIWiFiClientsListViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiClientsListViewController"];
    viewController.connectedDevices = [self.connectedDevices mutableCopy];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)onEditRouterRebootCard:(id)sender {
    [self onExpandCloseSection:self.tableView section:DEF_ROUTER_REBOOT_SECTION];
}

- (void)onEditRouterSoftwareCard:(id)sender {
    [self onExpandCloseSection:self.tableView section:DEF_ROUTER_VERSION_SECTION];
}

- (void)onEditSendLogsCard:(id)sender {
    [self onExpandCloseSection:self.tableView section:DEF_ROUTER_SEND_LOGS_SECTION];
}

#pragma mark - Refresh control methods

// Pull down to refresh device values
- (void)addRefreshControl {
    UIRefreshControl *refresh = [UIRefreshControl new];
    NSDictionary *attributes = self.navigationController.navigationBar.titleTextAttributes;
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refresh router data" attributes:attributes];
    [refresh addTarget:self action:@selector(onRefreshRouter:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)onRefreshRouter:(id)sender {
    if (self.routerViewState == RouterViewState_no_almond) {
        return;
    }

    // reset table view state when Refresh is called (and when current Almond is changed)
    self.sendLogsEditCellMode = SFIRouterTableViewActionsMode_unknown;
    [self sendRouterSummaryRequest];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.routerViewState) {
        case RouterViewState_no_almond:
            return 1;
        case RouterViewState_almond_unavailable:
            return 1;
        case RouterViewState_cloud_offline:
            return 1;
        case RouterViewState_cloud_connected:
        default:
            return 6;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.routerViewState != RouterViewState_cloud_connected) {
        return 1;
    }

    if (![self isSectionExpanded:section]) {
        return 1;
    }

    switch (section) {
        case DEF_NETWORKING_SECTION:
            return self.enableNetworkingControl ? 1 : 0;
        case DEF_WIRELESS_SETTINGS_SECTION:
            return 1 + self.currentExpandedCount;
        case DEF_DEVICES_AND_USERS_SECTION:
            return 1 + self.currentExpandedCount;
        case DEF_ROUTER_VERSION_SECTION:
            return 1 + self.currentExpandedCount;
        case DEF_ROUTER_REBOOT_SECTION:
            return 1 + self.currentExpandedCount;
        case DEF_ROUTER_SEND_LOGS_SECTION:
            return 1 + self.currentExpandedCount;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.routerViewState != RouterViewState_cloud_connected) {
        return 400;
    }

    switch (indexPath.section) {
        case DEF_NETWORKING_SECTION:
            return self.enableNetworkingControl ? 120 : 0;

        case DEF_WIRELESS_SETTINGS_SECTION:
            if (indexPath.row == 0) {
                return 120;
            }
            return 300;

        case DEF_DEVICES_AND_USERS_SECTION:
            return 85;

        case DEF_ROUTER_REBOOT_SECTION:
            if (indexPath.row > 0) {
                return 95;
            }
        case DEF_ROUTER_SEND_LOGS_SECTION:
            if (indexPath.row > 0) {
                return 95;
            }
        default:
            return 85;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    if (self.routerViewState != RouterViewState_cloud_connected) {
        return 400;
    }

    switch (indexPath.section) {
        case DEF_NETWORKING_SECTION:
            return self.enableNetworkingControl ? 120 : 0;

        case DEF_WIRELESS_SETTINGS_SECTION:
            if (indexPath.row > 0) {
                return 300;
            }

        case DEF_DEVICES_AND_USERS_SECTION:
            if (indexPath.row > 0) {
                return 85;
            }

        case DEF_ROUTER_VERSION_SECTION:
            if (indexPath.row > 0) {
                return 95;
            }

        case DEF_ROUTER_REBOOT_SECTION:
            if (indexPath.row > 0) {
                return 95;
            }

        case DEF_ROUTER_SEND_LOGS_SECTION:
            if (indexPath.row > 0) {
                return 95;
            }

        default: {
            SFICardTableViewCell *cell = (SFICardTableViewCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
            return [cell computedLayoutHeight];
        }
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.routerViewState) {
        case RouterViewState_no_almond: {
            tableView.scrollEnabled = NO;
            return [self createNoAlmondCell:tableView];
        }
        case RouterViewState_almond_unavailable: {
            tableView.scrollEnabled = NO;
            return [self createAlmondNoConnectCell:tableView];
        }
        case RouterViewState_cloud_offline: {
            tableView.scrollEnabled = NO;
            return [self createAlmondNoConnectCell:tableView];
        }
        case RouterViewState_cloud_connected:
        default: {
            tableView.scrollEnabled = YES;
            switch (indexPath.section) {
                case DEF_NETWORKING_SECTION:
                    if (self.enableNetworkingControl) {
                        return [self createNetworkSummaryCell:tableView];
                    }
                    else {
                        return [self createEmptyCell:tableView];
                    }

                case DEF_WIRELESS_SETTINGS_SECTION:
                    switch (indexPath.row) {
                        case 0:
                            return [self createWirelessSummaryCell:tableView];
                        default:
                            return [self createWirelessSettingCell:tableView tableRow:indexPath.row];
                    }

                case DEF_DEVICES_AND_USERS_SECTION:
                    switch (indexPath.row) {
                        case 0:
                            return [self createDevicesAndUsersSummaryCell:tableView];
                        default:
                            return [self createDevicesAndUsersEditCell:tableView tableRow:indexPath.row];
                    }

                case DEF_ROUTER_VERSION_SECTION:
                    switch (indexPath.row) {
                        case 0:
                            return [self createSoftwareVersionCell:tableView];
                        default:
                            return [self createSoftwareVersionEditCell:tableView];
                    }

                case DEF_ROUTER_REBOOT_SECTION:
                    switch (indexPath.row) {
                        case 0:
                            return [self createAlmondRebootSummaryCell:tableView];
                        default:
                            return [self createAlmondRebootEditCell:tableView];
                    }

                case DEF_ROUTER_SEND_LOGS_SECTION:
                    switch (indexPath.row) {
                        case 0:
                            return [self createAlmondSendLogsSummaryCell:tableView];
                        default:
                            return [self createAlmondSendLogsEditCell:tableView];
                    }

                default:
                    return [self createAlmondRebootSummaryCell:tableView];
            }
        };
    }
}

- (UITableViewCell *)createEmptyCell:(const UITableView *)tableView {
    UITableViewCell *empty = [tableView dequeueReusableCellWithIdentifier:@"empty"];
    if (!empty) {
        empty = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"empty"];
    }
    return empty;
}

- (UITableViewCell *)createNoAlmondCell:(UITableView *)tableView {
    NSString *const cell_id = @"NoAlmondCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        MessageView *view = [MessageView linkRouterMessage];
        view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 400);
        view.delegate = self;

        [cell addSubview:view];
    }

    return cell;
}

- (UITableViewCell *)createAlmondNoConnectCell:(UITableView *)tableView {
    static NSString *cell_id = @"NoAlmondConnect";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        CGFloat width = self.tableView.frame.size.width;

        UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, width, 50)];
        lblNoSensor.textAlignment = NSTextAlignmentCenter;
        lblNoSensor.font = [UIFont securifiLightFont:35];
        lblNoSensor.text = NSLocalizedString(@"router.offline-msg.label.Almond is Offline.", @"Almond is Offline.");
        lblNoSensor.adjustsFontSizeToFitWidth = YES;
        lblNoSensor.minimumScaleFactor = 0.50;
        lblNoSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblNoSensor];

        UIImageView *imgRouter = [[UIImageView alloc] initWithFrame:CGRectMake(width / 2 - 50, 150, 100, 100)];
        imgRouter.userInteractionEnabled = NO;
        imgRouter.image = [UIImage imageNamed:@"offline_150x150.png"];
        imgRouter.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:imgRouter];

        UILabel *lblAddSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 280, width, 40)];
        lblAddSensor.textAlignment = NSTextAlignmentCenter;
        lblAddSensor.font = [UIFont securifiBoldFont:20];
        lblAddSensor.text = NSLocalizedString(@"router.offline-msg.label.Please check the router.", @"Please check the router.");
        lblAddSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblAddSensor];
    }

    return cell;
}

- (UITableViewCell *)createEmptyWirelessSummaryCell:(UITableView *)tableView cellId:(NSString *)cell_id cellTitle:(NSString *)cellTitle cellSummary:(NSString *)cellSummary cardColor:(UIColor *)cardColor {
    SFICardViewSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFICardViewSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    [cell markReuse];

    cell.cardView.rightOffset = SFICardView_right_offset_inset;
    cell.cardView.backgroundColor = cardColor;
    cell.title = cellTitle;

    cell.summaries = @[cellSummary];

    return cell;
}

- (UITableViewCell *)createNetworkSummaryCell:(UITableView *)tableView {
    NSString *const cell_id = @"network_summary";

    SFICardViewSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFICardViewSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    [cell markReuse];

    cell.cardView.rightOffset = SFICardView_right_offset_inset;
    cell.cardView.backgroundColor = [UIColor securifiRouterTileGreenColor];

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    NSString *almondMac = self.almondMac;

    enum SFIAlmondConnectionMode mode = [toolkit connectionModeForAlmond:almondMac];
    switch (mode) {
        case SFIAlmondConnectionMode_cloud: {
            cell.title = NSLocalizedString(@"router.card-title.Cloud Almond Link", @"Cloud Almond Link");
            cell.summaries = @[
                    NSLocalizedString(@"router.card.Settings are not available.", @"Settings are not available.")
            ];

            cell.editTarget = nil;
            cell.editSelector = nil;

            break;
        }
        case SFIAlmondConnectionMode_local: {
            cell.title = NSLocalizedString(@"router.card-title.Local Almond Link", @"Local Almond Link");

            SFIAlmondLocalNetworkSettings *settings = [toolkit localNetworkSettingsForAlmond:almondMac];
            if (settings) {
                NSString *ssid2 = settings.ssid2 ? settings.ssid2 : @"";
                NSString *ssid5 = settings.ssid5 ? settings.ssid5 : @"";
                NSString *host = settings.host ? settings.host : @"";
                NSString *admin = settings.login ? settings.login : @"";

                cell.summaries = @[
                        [NSString stringWithFormat:@"SSID 2.5Ghz : %@", ssid2],
                        [NSString stringWithFormat:@"SSID 5Ghz : %@", ssid5],
                        [NSString stringWithFormat:@"IP Address : %@", host],
                        [NSString stringWithFormat:@"Admin Login : %@", admin],
                ];

                cell.editTarget = self;
                cell.editSelector = @selector(onEditNetworkSettings:);
            }
            else {
                cell.summaries = @[
                        NSLocalizedString(@"router.card.Settings are not available.", @"Settings are not available.")
                ];

                cell.editTarget = nil;
                cell.editSelector = nil;
            }

            break;
        }
    }

    return cell;
}

- (UITableViewCell *)createWirelessSummaryCell:(UITableView *)tableView {
    SFIRouterSummary *const routerSummary = self.routerSummary;

    if (!routerSummary) {
        return [self createEmptyWirelessSummaryCell:tableView
                                             cellId:@"wireless_summary_no"
                                          cellTitle:NSLocalizedString(@"router.card-title.Wireless Settings", @"Wireless Settings")
                                        cellSummary:NSLocalizedString(@"router.card.Settings are not available.", @"Settings are not available.")
                                          cardColor:[UIColor securifiRouterTileSlateColor]];
    }
    
    NSString *cell_id = @"wireless_summary";

    SFICardViewSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFICardViewSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    [cell markReuse];

    cell.cardView.rightOffset = SFICardView_right_offset_inset;
    cell.cardView.backgroundColor = [UIColor securifiRouterTileSlateColor];
    cell.title = NSLocalizedString(@"router.card-title.Wireless Settings", @"Wireless Settings");

    NSMutableArray *summary = [NSMutableArray array];
    for (SFIWirelessSummary *sum in routerSummary.wirelessSummaries) {
        NSString *enabled = sum.enabled ? NSLocalizedString(@"router.wireless-status.Enabled", @"enabled") : NSLocalizedString(@"router.wireless-status.Disabled", @"disabled");
        [summary addObject:[NSString stringWithFormat:@"%@ is %@", sum.ssid, enabled]];
    }

    cell.summaries = summary;

    int totalCount = (int) routerSummary.wirelessSummaries.count;
    if (totalCount > 0) {
        BOOL editing = [self isSectionExpanded:DEF_WIRELESS_SETTINGS_SECTION];
        cell.expanded = editing;
        cell.editTarget = self;
        cell.editSelector = @selector(onEditWirelessSettingsCard:);
    }

    return cell;
}

- (BOOL)isSectionExpanded:(NSInteger)sectionNumber {
    NSNumber *number = self.currentExpandedSection;
    return number != nil && [number isEqualToNumber:@(sectionNumber)];
}

- (UITableViewCell *)createWirelessSettingCell:(UITableView *)tableView tableRow:(NSInteger)row {
    NSString *const cell_id = @"wireless_settings";

    SFIRouterSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFIRouterSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    [cell markReuse];

    SFIWirelessSetting *setting = [self tryGetWirelessSettingsForTableRow:row];

    cell.cardView.backgroundColor = setting.enabled ? [[SFIColors blueColor] color] : [UIColor lightGrayColor];
    cell.wirelessSetting = setting;
    cell.enableRouterWirelessControl = self.enableRouterWirelessControl;
    cell.delegate = self;

    return cell;
}

- (SFIWirelessSetting *)tryGetWirelessSettingsForTableRow:(NSInteger)row {
    NSArray *settings = self.wirelessSettings;

    // first row is the summary cell; all others are the ones we want; so adjust index accordingly
    row = row - 1;
    if (row < 0) {
        return nil;
    }
    if (row >= settings.count) {
        return nil;
    }

    return settings[(NSUInteger) row];
}

// either an instance of SFIConnectedDevice or SFIBlockedDevice
- (id)tryGetDevicesForTableRow:(NSInteger)row {
    NSArray *connected = self.connectedDevices;
    NSArray *blocked = self.blockedDevices;

    NSUInteger total = connected.count + blocked.count;

    // first row is the summary cell; all others are the ones we want; so adjust index accordingly
    row = row - 1;
    if (row < 0) {
        return nil;
    }
    if (row >= total) {
        return nil;
    }

    if (row >= connected.count) {
        row = row - connected.count;
    }
    else {
        return connected[(NSUInteger) row];
    }

    return blocked[(NSUInteger) row];
}

- (UITableViewCell *)createDevicesAndUsersSummaryCell:(UITableView *)tableView {
    SFIRouterSummary *routerSummary = self.routerSummary;
    if (!routerSummary) {
        return [self createEmptyWirelessSummaryCell:tableView
                                             cellId:@"device_summary_no"
                                          cellTitle:NSLocalizedString(@"router.card-title.Devices & Users", @"Devices & Users")
                                        cellSummary:NSLocalizedString(@"router.card.Settings are not available.", @"Settings are not available.")
                                          cardColor:[UIColor securifiRouterTileBlueColor]];
    }

    NSString *const cell_id = @"device_summary";

    SFICardViewSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFICardViewSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    [cell markReuse];
    cell.cardView.backgroundColor = [UIColor securifiRouterTileBlueColor];
    cell.title = NSLocalizedString(@"router.card-title.Devices & Users", @"Devices & Users");
    cell.summaries = @[
            [NSString stringWithFormat:NSLocalizedString(@"router.devices-summary.%d connected, %d blocked", @"%d connected, %d blocked"), 
                            routerSummary.connectedDeviceCount, 
                            routerSummary.blockedMACCount],
    ];

    int totalCount = routerSummary.connectedDeviceCount + routerSummary.blockedMACCount;
    if (totalCount > 0) {
        BOOL editing = [self isSectionExpanded:DEF_DEVICES_AND_USERS_SECTION];
        cell.editTarget = self;
        cell.editSelector = @selector(onEditDevicesAndUsersCard:);
        cell.expanded = editing;
    }

    return cell;
}

- (UITableViewCell *)createDevicesAndUsersEditCell:(UITableView *)tableView tableRow:(NSInteger)row {
    NSString *const cell_id = @"device_edit";

    SFIRouterDevicesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFIRouterDevicesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    cell.delegate = self;
    [cell markReuse];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [UIColor securifiRouterTileBlueColor];

    // This is ugly but required unless we collapse SFIConnectedDevice and SFIBlockedDevice
    id obj = [self tryGetDevicesForTableRow:row];
    if (obj != nil) {
        if ([obj isKindOfClass:[SFIConnectedDevice class]]) {
            SFIConnectedDevice *device = obj;
            cell.allowedDevice = YES;
            cell.deviceIP = device.deviceIP;
            cell.deviceMAC = device.deviceMAC;
            cell.name = device.name;
        }
        else if ([obj isKindOfClass:[SFIBlockedDevice class]]) {
            SFIBlockedDevice *device = obj;
            cell.allowedDevice = NO;
            cell.deviceMAC = device.deviceMAC;
        }
    }

    return cell;
}

- (UITableViewCell *)createSoftwareVersionCell:(UITableView *)tableView {
    NSString *version = self.routerSummary.firmwareVersion;

    if (!version) {
        return [self createEmptyWirelessSummaryCell:tableView
                                             cellId:@"software_summary_no"
                                          cellTitle:@"Software Version"
                                        cellSummary:NSLocalizedString(@"router.software-version.Not available", @"Version information is not available.")
                                          cardColor:[UIColor securifiRouterTileYellowColor]];
    }

    NSString *const cell_id = @"software_summary";
    SFICardViewSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFICardViewSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    [cell markReuse];
    cell.cardView.backgroundColor = [UIColor securifiRouterTileYellowColor];

    const BOOL newVersionAvailable = self.newAlmondFirmwareVersionAvailable;
    cell.title = newVersionAvailable ? @"Software Version *" : @"Software Version";

    NSString *currentVersion_label = NSLocalizedString(@"router.software-version.Current version", @"Current version");

    if (newVersionAvailable) {
        NSString *updateAvailable_label = NSLocalizedString(@"router.software-version.Update Available", @"Update Available");
        cell.summaries = @[updateAvailable_label, currentVersion_label, version];
    }
    else {
        cell.summaries = @[currentVersion_label, version];
    }

    if (newVersionAvailable) {
        cell.editTarget = self;
        cell.editSelector = @selector(onEditRouterSoftwareCard:);
    }
    else {
        cell.editTarget = nil;
        cell.editSelector = nil;
    }

    return cell;
}

- (UITableViewCell *)createSoftwareVersionEditCell:(UITableView *)tableView {
    NSString *const cell_id = @"software_edit";

    SFIRouterVersionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFIRouterVersionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.delegate = self;
    }
    [cell markReuse];

    cell.cardView.backgroundColor = [UIColor securifiRouterTileRedColor];

    return cell;
}

- (UITableViewCell *)createAlmondRebootSummaryCell:(UITableView *)tableView {
    if (!self.routerSummary) {
        return [self createEmptyWirelessSummaryCell:tableView
                                             cellId:@"reboot_summary_no"
                                          cellTitle:NSLocalizedString(@"router.card-title.Router Reboot", @"Router Reboot")
                                        cellSummary:NSLocalizedString(@"router.Router status is not available.", @"Router status is not available.")
                                          cardColor:[UIColor securifiRouterTileRedColor]];
    }

    NSString *const cell_id = @"reboot_summary";

    SFICardViewSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFICardViewSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    [cell markReuse];

    cell.title = NSLocalizedString(@"router.card-title.Router Reboot", @"Router Reboot");

    NSArray *summary;
    if (self.isRebooting) {
        summary = @[
                NSLocalizedString(@"router.reboot-msg.Router is rebooting. It will take at least", @"Router is rebooting. It will take at least"),
                NSLocalizedString(@"router.reboot-msg.2 minutes for the router to boot.", @"2 minutes for the router to boot."),
                NSLocalizedString(@"router.reboot-msg.Please refresh after sometime.", @"Please refresh after sometime.")
        ];
    }
    else {
        summary = @[[NSString stringWithFormat:NSLocalizedString(@"router.Last reboot %@ ago", @"Last reboot %@ ago"), self.routerSummary.routerUptime]];
    }
    cell.summaries = summary;

    cell.expanded = [self isSectionExpanded:DEF_ROUTER_REBOOT_SECTION];
    cell.editTarget = self;
    cell.editSelector = @selector(onEditRouterRebootCard:);

    SFICardView *card = cell.cardView;
    card.backgroundColor = [UIColor securifiRouterTileRedColor];

    return cell;
}

- (UITableViewCell *)createAlmondRebootEditCell:(UITableView *)tableView {
    NSString *const cell_id = @"reboot_edit";

    SFIRouterRebootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFIRouterRebootTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    cell.delegate = self;
    [cell markReuse];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [UIColor securifiRouterTileRedColor];

    return cell;
}

- (UITableViewCell *)createAlmondSendLogsSummaryCell:(UITableView *)tableView {
    NSString *const cell_id = @"sendlogs_summary";

    SFICardViewSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFICardViewSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    [cell markReuse];

    cell.cardView.backgroundColor = [[SFIColors yellowColor] color];

    cell.title = NSLocalizedString(@"router.card-title.Send Logs", @"Send Logs");
    if (self.almondSupportsSendLogs == AlmondSupportsSendLogs_no) {
        cell.title = [NSString stringWithFormat:@"%@ *", cell.title];
    }

    NSArray *summary = @[[NSString stringWithFormat:NSLocalizedString(@"router.Sends %@'s logs to our server", @"Sends %@'s logs to our server"), self.currentAlmond.almondplusName]];
    cell.summaries = summary;

    cell.expanded = [self isSectionExpanded:DEF_ROUTER_SEND_LOGS_SECTION];
    cell.editTarget = self;
    cell.editSelector = @selector(onEditSendLogsCard:);

    return cell;
}

- (UITableViewCell *)createAlmondSendLogsEditCell:(UITableView *)tableView {
    NSString *const cell_id = @"sendlogs_edit";

    SFIRouterSendLogsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFIRouterSendLogsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.delegate = self;
    }
    [cell markReuse];

    if (self.almondSupportsSendLogs == AlmondSupportsSendLogs_no) {
        cell.mode = SFIRouterTableViewActionsMode_firmwareNotSupported;
    }
    else {
        cell.mode = self.sendLogsEditCellMode;
    }

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors yellowColor] color];

    return cell;
}

- (void)tryReloadSendLogsEditTile:(enum SFIRouterTableViewActionsMode)mode {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (![self isSectionExpanded:DEF_ROUTER_SEND_LOGS_SECTION]) {
            return;
        }

        self.sendLogsEditCellMode = mode;

        NSIndexPath *editRow = [NSIndexPath indexPathForItem:1 inSection:DEF_ROUTER_SEND_LOGS_SECTION];
        [self.tableView reloadRowsAtIndexPaths:@[editRow] withRowAnimation:UITableViewRowAnimationFade];
    });
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    switch (self.routerViewState) {
        case RouterViewState_cloud_connected: {
            if (section == [tableView numberOfSections] - 1) { // last section gets padding from a footer
                return 20;
            }
            // pass through
        }

        case RouterViewState_no_almond:
        case RouterViewState_almond_unavailable:
        case RouterViewState_cloud_offline:
        default:
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    switch (self.routerViewState) {
        case RouterViewState_cloud_connected: {
            if (section == [tableView numberOfSections] - 1) { // last section gets padding from a footer
                UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
                view.backgroundColor = [UIColor clearColor];
                return view;
            }
            // pass through
        }

        case RouterViewState_no_almond:
        case RouterViewState_almond_unavailable:
        case RouterViewState_cloud_offline:
        default:
            return nil;
    }
}

- (void)onExpandCloseSection:(UITableView *)tableView section:(NSInteger)section {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self.isHudHidden) {
            // do not update while HUD is showing
            return;
        }
        if (!self.allowCellExpandControl) {
            // do not update while a cell is being edited
            return;
        }

        NSInteger currentExpandedSection = -1;

        // remove rows if needed
        NSNumber *section_number = self.currentExpandedSection;
        if (section_number) {
            currentExpandedSection = section_number.integerValue;

            self.currentExpandedSection = nil;
            self.currentExpandedCount = 0;

            [tableView beginUpdates];
            [self tryReloadSection:(NSUInteger) currentExpandedSection];
            [tableView endUpdates];
        }

        [tableView beginUpdates];

        // add rows if needed
        if (currentExpandedSection != section) {
            if (section == DEF_WIRELESS_SETTINGS_SECTION) {
                self.currentExpandedSection = @(DEF_WIRELESS_SETTINGS_SECTION);
                self.currentExpandedCount = self.wirelessSettings.count;
                [self tryReloadSection:DEF_WIRELESS_SETTINGS_SECTION];
            }
            else if (section == DEF_DEVICES_AND_USERS_SECTION) {
                self.currentExpandedSection = @(DEF_DEVICES_AND_USERS_SECTION);
                self.currentExpandedCount = self.connectedDevices.count + self.blockedDevices.count;
                [self tryReloadSection:DEF_DEVICES_AND_USERS_SECTION];
            }
            else if (section == DEF_ROUTER_VERSION_SECTION) {
                self.currentExpandedSection = @(DEF_ROUTER_VERSION_SECTION);
                self.currentExpandedCount = 1;
                [self tryReloadSection:DEF_ROUTER_VERSION_SECTION];
            }
            else if (section == DEF_ROUTER_REBOOT_SECTION) {
                self.currentExpandedSection = @(DEF_ROUTER_REBOOT_SECTION);
                self.currentExpandedCount = 1;
                [self tryReloadSection:DEF_ROUTER_REBOOT_SECTION];
            }
            else if (section == DEF_ROUTER_SEND_LOGS_SECTION) {
                self.currentExpandedSection = @(DEF_ROUTER_SEND_LOGS_SECTION);
                self.currentExpandedCount = 1;
                [self tryReloadSection:DEF_ROUTER_SEND_LOGS_SECTION];
            }
        }

        [tableView endUpdates];

        // reload the table:
        // this is a work around for a rendering/animation problem that will cause the section headers
        // to be left behind, causing too much space around the tile below the one being closed.
        [tableView reloadData];
    });
}

#pragma mark - Cloud command senders and handlers

- (void)onWiFiClientsListResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSDictionary *mainDict = [[data valueForKey:@"data"] objectFromJSONData];

    NSLog(@"onWiFiClientsListResponseCallback: %@", mainDict);


    if (![[mainDict valueForKey:@"Success"] isEqualToString:@"true"]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (!self) {
                return;
            }
            if (self.disposed) {
                return;
            }

            //            NSString *responseAlmondMac = response.almondMAC;
            //            if (responseAlmondMac.length > 0 && ![responseAlmondMac isEqualToString:self.almondMac]) {
            //                // response almond mac value is likely to be null, but when specified we make sure it matches
            //                // the current almond being shown.
            //                return;
            //            }
            //
            //            self.isAlmondUnavailable = [response.reason.lowercaseString hasSuffix:@" is offline"]; // almond is offline, homescreen is offline
            [self syncCheckRouterViewState:RouterViewReloadPolicy_on_state_change];
            [self.HUD hide:YES];
            [self.refreshControl endRefreshing];
        });

        return;
    }
    self.isAlmondUnavailable = NO;

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }

        if (self.disposed) {
            return;
        }

        if ([[mainDict valueForKey:@"Clients"] isKindOfClass:[NSArray class]]) {
            NSArray *dDictArray = [mainDict valueForKey:@"Clients"];
            NSMutableArray *dArray = [NSMutableArray new];
            for (NSDictionary *dict in dDictArray) {
                SFIConnectedDevice *device = [SFIConnectedDevice new];
                device.deviceID = [dict valueForKey:@"ID"];
                device.name = [dict valueForKey:@"Name"];
                device.deviceMAC = [dict valueForKey:@"MAC"];
                device.deviceIP = [dict valueForKey:@"LastKnownIP"];
                device.deviceConnection = [dict valueForKey:@"Connection"];
                device.name = [dict valueForKey:@"Name"];
                device.deviceLastActiveTime = [dict valueForKey:@"LastActiveTime"];
                device.deviceType = [dict valueForKey:@"Type"];
                device.deviceUseAsPresence = [[dict valueForKey:@"UseAsPresence"] boolValue];
                device.isActive = [[dict valueForKey:@"Active"] boolValue];

                [dArray addObject:device];
            }

            self.connectedDevices = dArray;
            [self syncCheckRouterViewState:RouterViewReloadPolicy_always];
        }


        [self.HUD hide:YES];
        [self.refreshControl endRefreshing];
    });
}



- (void)onGenericResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    GenericCommandResponse *response = (GenericCommandResponse *) [data valueForKey:@"data"];
    if (!response.isSuccessful) {
        DLog(@"Unsuccessful response, almond:%@, reason:%@", response.almondMAC, response.reason);

        dispatch_async(dispatch_get_main_queue(), ^() {
            if (!self) {
                return;
            }
            if (self.disposed) {
                return;
            }

            NSString *responseAlmondMac = response.almondMAC;
            if (responseAlmondMac.length > 0 && ![responseAlmondMac isEqualToString:self.almondMac]) {
                // response almond mac value is likely to be null, but when specified we make sure it matches
                // the current almond being shown.
                return;
            }

            self.isAlmondUnavailable = [response.reason.lowercaseString hasSuffix:@" is offline"]; // almond is offline, homescreen is offline
            [self syncCheckRouterViewState:RouterViewReloadPolicy_on_state_change];
            [self.HUD hide:YES];
            [self.refreshControl endRefreshing];
        });

        return;
    }
    self.isAlmondUnavailable = NO;

    SFIGenericRouterCommand *genericRouterCommand = [SFIParser parseRouterResponse:response];
    genericRouterCommand.almondMAC = response.almondMAC;

    [self processRouterCommandResponse:genericRouterCommand];
}

- (void)onAlmondRouterCommandResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    SFIGenericRouterCommand *response = (SFIGenericRouterCommand *) [data valueForKey:@"data"];
    [self processRouterCommandResponse:response];
}

- (void)processRouterCommandResponse:(SFIGenericRouterCommand *)genericRouterCommand {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }

        if (self.disposed) {
            return;
        }

        if (![genericRouterCommand.almondMAC isEqualToString:self.almondMac]) {
            return;
        }

        switch (genericRouterCommand.commandType) {
            case SFIGenericRouterCommandType_CONNECTED_DEVICES: {
                SFIDevicesList *ls = genericRouterCommand.command;
                self.connectedDevices = ls.deviceList;
                [self syncCheckRouterViewState:RouterViewReloadPolicy_always];
                break;
            }

            case SFIGenericRouterCommandType_BLOCKED_MACS: {
                SFIDevicesList *ls = genericRouterCommand.command;
                self.blockedDevices = ls.deviceList;
                [self syncCheckRouterViewState:RouterViewReloadPolicy_always];
                break;
            }

            case SFIGenericRouterCommandType_WIRELESS_SETTINGS: {
                NSArray *oldSettings = self.wirelessSettings;

                SFIDevicesList *ls = genericRouterCommand.command;
                self.wirelessSettings = ls.deviceList;

                if (!oldSettings) {
                    // settings was null, reload in case they are late arriving and the view is waiting for them
                    [self syncCheckRouterViewState:RouterViewReloadPolicy_always];
                }
//
//                SFIRouterSummary *summary = self.routerSummary;
//                if (summary) {
//                    [summary updateWirelessSummaryWithSettings:self.wirelessSettings];
//                    [self syncCheckRouterViewState:RouterViewReloadPolicy_always];
//                }
//                else {
//                    NSLog(@"Wireless Settings arrived before summary");
//                }
//
                break;
            }

            case SFIGenericRouterCommandType_WIRELESS_SUMMARY: {
                SFIRouterSummary *summary = (SFIRouterSummary *) genericRouterCommand.command;

                NSArray *settings = self.wirelessSettings;
//                if (settings) {
//                    DLog(@"Updating wireless settings on arrival of summary");
//                    [summary updateWirelessSummaryWithSettings:settings];
//                }

                self.routerSummary = summary;

                NSString *currentVersion = summary.firmwareVersion;
                [self tryCheckAlmondVersion:currentVersion];
                [self tryCheckSendLogsSupport:currentVersion];

                [self syncCheckRouterViewState:RouterViewReloadPolicy_always];

                [self sendRouterDetailsRequest];
                // after receiving summary, wait until detailed settings have been returned
                // before updating the table.
                break;
            }

            case SFIGenericRouterCommandType_SEND_LOGS_RESPONSE: {
                enum SFIRouterTableViewActionsMode mode = genericRouterCommand.commandSuccess ? SFIRouterTableViewActionsMode_commandSuccess : SFIRouterTableViewActionsMode_commandError;
                [self tryReloadSendLogsEditTile:mode];
                break;
            };

            case SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE: {
                if (!genericRouterCommand.commandSuccess) {
                    break;
                }

                unsigned int percentage = genericRouterCommand.completionPercentage;

                if (percentage > 0) {
                    NSString *msg = NSLocalizedString(@"router.hud.Updating router firmware.", @"Updating router firmware.");
                    msg = [msg stringByAppendingFormat:@" (%i%%)", percentage];
                    [self showToast:msg];
                }

                break;
            };

            case SFIGenericRouterCommandType_REBOOT:
            case SFIGenericRouterCommandType_BLOCKED_CONTENT:
            default:
                break;
        }

        [self.HUD hide:YES];
        [self.refreshControl endRefreshing];
    });
}

// take into account table might be displaying static images and therefore reloading a specific section would not be appropriate
- (void)tryReloadSection:(NSUInteger)section {
    UITableView *tableView = self.tableView;
    NSInteger numberOfSections = [tableView numberOfSections];

    if (numberOfSections == 0) {
        return; // no op
    }

    if (numberOfSections <= 1) {
        [tableView reloadData];
    }
    else {
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)onGenericNotificationCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    GenericCommandResponse *obj = (GenericCommandResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {
        DLog(@"Reason: %@", obj.reason);

        dispatch_async(dispatch_get_main_queue(), ^() {
            if (self.disposed) {
                return;
            }

            self.isAlmondUnavailable = YES;
            [self syncCheckRouterViewState:RouterViewReloadPolicy_on_state_change];
        });

        return;
    }
    self.isAlmondUnavailable = NO;

    //todo push all of this parsing and manipulation into the parser or SFIGenericRouterCommand!

    NSMutableData *genericData = [[NSMutableData alloc] init];

    //Display proper message
//    DLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.correlationId, obj.mobileInternalIndex);
//    DLog(@"Response Data: %@", obj.genericData);
//    DLog(@"Decoded Data: %@", obj.decodedData);

    NSData *data_decoded = [obj.decodedData mutableCopy];
    DLog(@"Data: %@", data_decoded);

    [genericData appendData:data_decoded];

    unsigned int expectedDataLength;
    unsigned int commandData;

    [genericData getBytes:&expectedDataLength range:NSMakeRange(0, 4)];
    [genericData getBytes:&commandData range:NSMakeRange(4, 4)];

    //Remove 8 bytes from received command
    [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

    NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
    SFIGenericRouterCommand *command = [[SFIParser alloc] loadDataFromString:decodedString];
    DLog(@"Command Type %d", command.commandType);

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        switch (command.commandType) {
            case SFIGenericRouterCommandType_REBOOT: {
                BOOL wasRebooting = self.isRebooting;
                self.isRebooting = NO;

                // protect against the cloud sending the same response more than once
                if (wasRebooting) {
                    [self sendRouterSummaryRequest];

                    //todo handle failure case
                    [self showHUD:NSLocalizedString(@"router.hud.Router is now online.", @"Router is now online.")];
                }

                [self.HUD hide:YES afterDelay:1];
                break;
            }

            case SFIGenericRouterCommandType_WIRELESS_SETTINGS: {
                [self.HUD hide:YES afterDelay:1];
                break;
            }

            default:
                [self.HUD hide:YES afterDelay:1];
                break;
        }
    });
}

- (void)onAlmondListDidChange:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        SFIAlmondPlus *plus = [toolkit currentAlmond];

        if (plus == nil) {
            [self markAlmondMac:NO_ALMOND];
            self.navigationItem.title = NSLocalizedString(@"router.no-almonds.nav-title.Get Started", @"Get Started");
        }
        else {
            [self markAlmondMac:plus.almondplusMAC];
            self.navigationItem.title = plus.almondplusName;
            [self sendRouterSummaryRequest];
        }

        [self.tableView reloadData];
    });
}

#pragma mark - SFIRouterTableViewActions protocol methods

// coordinate changes in a cell with the overall state of the control to ensure we do not crash.
// specifically, we do not want to expand/collapse a section while a text field is the first responder.
- (void)routerTableCellWillBeginEditingValue {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.allowCellExpandControl = NO;
        self.enableDrawer = NO;
        [self.refreshControl endRefreshing];
        self.refreshControl = nil;
    });
}

- (void)routerTableCellDidEndEditingValue {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.allowCellExpandControl = YES;
        self.enableDrawer = YES;
        if (self.refreshControl == nil) {
            [self addRefreshControl];
        }
    });
}

- (void)onRebootRouterActionCalled {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        [self showHUD:NSLocalizedString(@"router.hud.Router is rebooting.", @"Router is rebooting.")];

        self.isRebooting = TRUE;
        [self sendRebootAlmondCommand];
        [self onExpandCloseSection:self.tableView section:DEF_ROUTER_REBOOT_SECTION];

        [[Analytics sharedInstance] markRouterReboot];
    });
}

- (void)onUpdateRouterFirmwareActionCalled {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        [self showHUD:NSLocalizedString(@"router.hud.Updating router firmware.", @"Updating router firmware.")];

        [self sendUpdateAlmondFirmwareCommand];
        [self onExpandCloseSection:self.tableView section:DEF_ROUTER_VERSION_SECTION];

        [[Analytics sharedInstance] markRouterUpdateFirmware];
    });
}

- (void)onSendLogsActionCalled:(NSString *)problemDescription {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        [self showHUD:NSLocalizedString(@"router.hud.Sending Logs.", @"Instructing router to send logs.")];

        [self sendSendLogsCommand:problemDescription];
        [self onExpandCloseSection:self.tableView section:DEF_ROUTER_SEND_LOGS_SECTION];

        [[Analytics sharedInstance] markSendRouterLogs];
    });
}

- (void)onEnableDevice:(SFIWirelessSetting *)setting enabled:(BOOL)isEnabled {
    SFIWirelessSetting *copy = [setting copy];
    copy.enabled = isEnabled;
    [self onUpdateWirelessSettings:copy];
}

- (void)onChangeDeviceSSID:(SFIWirelessSetting *)setting newSSID:(NSString *)ssid {
    SFIWirelessSetting *copy = [setting copy];
    copy.ssid = ssid;
    [self onUpdateWirelessSettings:copy];
}

- (void)onEnableWirelessAccessForDevice:(NSString *)deviceMAC allow:(BOOL)isAllowed {
    if (deviceMAC.length == 0) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        [self showHUD:NSLocalizedString(@"hud.Updating settings...", @"Updating settings...")];

        NSMutableSet *blockedMacs = [NSMutableSet set];
        for (SFIBlockedDevice *device in self.blockedDevices) {
            [blockedMacs addObject:device.deviceMAC];
        }

        if (isAllowed) {
            [blockedMacs removeObject:deviceMAC];
        }
        else {
            [blockedMacs addObject:deviceMAC];
        }

        [[SecurifiToolkit sharedInstance] asyncSetAlmondWirelessUsersSettings:self.almondMac blockedDeviceMacs:blockedMacs.allObjects];

        [self.HUD hide:YES afterDelay:2];
    });
}

- (void)onUpdateWirelessSettings:(SFIWirelessSetting *)copy {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        [self showUpdatingSettingsHUD];
        [[SecurifiToolkit sharedInstance] asyncUpdateAlmondWirelessSettings:self.almondMac wirelessSettings:copy];
        [self.HUD hide:YES afterDelay:2];
    });
}

#pragma mark - MessageViewDelegate methods

- (void)messageViewDidPressButton:(MessageView *)msgView {
    if (self.disposed) {
        return;
    }
    if (self.routerViewState == RouterViewState_no_almond) {
        UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
        [self presentViewController:ctrl animated:YES completion:nil];
    }
    else {
        //Get wireless settings
        [self sendRouterSummaryRequest];
    }
}

#pragma mark - AlmondVersionChecker methods

- (void)tryCheckSendLogsSupport:(NSString *)currentVersion {
    SFIAlmondPlus *almond = self.currentAlmond;
    if (!almond) {
        return;
    }

    self.almondSupportsSendLogs = [almond supportsSendLogs:currentVersion] ? AlmondSupportsSendLogs_yes : AlmondSupportsSendLogs_no;
//    [self tryReloadSection:DEF_ROUTER_SEND_LOGS_SECTION];
}

- (void)tryCheckAlmondVersion:(NSString *)currentVersion {
    SFIAlmondPlus *almond = self.currentAlmond;
    if (!almond) {
        return;
    }

    AlmondVersionChecker *checker = [AlmondVersionChecker new];
    checker.delegate = self;

    [checker asyncCheckLatestVersion:almond currentVersion:currentVersion];
}

- (void)versionCheckerDidQueryVersion:(SFIAlmondPlus *)checkedAlmond result:(enum AlmondVersionCheckerResult)result currentVersion:(NSString *)currentVersion latestVersion:(NSString *)latestAlmondVersion {
    BOOL newVersionAvailable = (result == AlmondVersionCheckerResult_currentOlderThanLatest);

    dispatch_async(dispatch_get_main_queue(), ^() {
        SFIAlmondPlus *currentAlmond = self.currentAlmond;
        if (!currentAlmond || !checkedAlmond) {
            // bad data!
            return;
        }

        if (![checkedAlmond isEqualAlmondPlus:currentAlmond]) {
            return;
        }

        self.newAlmondFirmwareVersionAvailable = newVersionAvailable;
        self.latestAlmondVersionAvailable = latestAlmondVersion;

        if (newVersionAvailable) {
            TableHeaderView *view = [TableHeaderView newAlmondVersionMessage];
            view.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 100);
            view.backgroundColor = [UIColor whiteColor];
            view.delegate = self;

            [UIView animateWithDuration:0.50 animations:^() {
                self.tableView.tableHeaderView = view;
            }];

            [self tryReloadSection:DEF_ROUTER_VERSION_SECTION];
        }
    });
}

#pragma mark - TableHeaderViewDelegate methods

- (void)tableHeaderViewDidTapButton:(TableHeaderView *)view {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [UIView animateWithDuration:0.75 animations:^() {
            self.tableView.tableHeaderView = nil;
        }];
    });
}

@end
