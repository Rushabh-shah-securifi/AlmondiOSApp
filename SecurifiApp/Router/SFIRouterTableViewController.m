//
//  SFIRouterTopTableViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <SecurifiToolkit/SFIAlmondLocalNetworkSettings.h>
#import "SFIRouterTableViewController.h"
#import "SFIColors.h"
#import "AlmondPlusConstants.h"
#import "MBProgressHUD.h"
#import "Analytics.h"
#import "UIFont+Securifi.h"
#import "SFICardView.h"
#import "SFICardTableViewCell.h"
#import "SFIRouterRebootTableViewCell.h"
#import "SFIRouterSendLogsTableViewCell.h"
#import "SFIRouterTableViewActions.h"
#import "SFICardViewSummaryCell.h"
#import "MessageView.h"
#import "TableHeaderView.h"
#import "SFIRouterVersionTableViewCell.h"
#import "UIViewController+Securifi.h"
#import "SFICloudLinkViewController.h"
#import "UIColor+Securifi.h"
#import "SFIWiFiClientsListViewController.h"
#import "SFIRouterSettingsTableViewController.h"
#import "SFIRouterClientsTableViewController.h"

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

@property NSNumber *currentExpandedSection; // nil == none expanded
@property NSUInteger currentExpandedCount; // number of rows in expanded section
@property BOOL allowCellExpandControl;

@property BOOL isRebooting;
@property BOOL isAlmondUnavailable;
@property BOOL shownHudOnce;
@property BOOL disposed;

@property(nonatomic) BOOL enableRouterWirelessControl;
@property(nonatomic) BOOL enableNetworkingControl;
@property(nonatomic) BOOL enableNewWifiClientsControl;
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
    self.enableNewWifiClientsControl = configurator.enableWifiClients;

    [super viewDidLoad];

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self addRefreshControl];
    [self initializeNotifications];

    [self initializeRouterSummaryAndSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.disposed = NO;
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

    [center addObserver:self selector:@selector(onAlmondRouterCommandResponse:) name:kSFIDidReceiveGenericAlmondRouterResponse object:nil];

    [center addObserver:self selector:@selector(onWiFiClientsListResponseCallback:) name:NOTIFICATION_WIFI_CLIENTS_LIST_RESPONSE object:nil];
}

- (void)initializeRouterSummaryAndSettings {
    self.isRebooting = NO;
    self.enableDrawer = YES;

    // init state
    self.routerSummary = nil;

    self.currentExpandedSection = nil;
    self.currentExpandedCount = 0;
    self.allowCellExpandControl = YES;
}

- (void)initializeAlmondData:(enum RouterViewReloadPolicy)refreshPolicy {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];

    self.currentAlmond = plus;

    if (plus == nil) {
        self.navigationItem.title = NSLocalizedString(@"router.nav-title.Get Started", @"Get Started");
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
    else if (![self isNetworkOnline]) {
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

- (BOOL)isNetworkOnline {
    return [[SecurifiToolkit sharedInstance] isNetworkOnline];
}

#pragma mark - Commands

- (void)sendRouterSummaryRequest {
    if (self.routerViewState == RouterViewState_no_almond) {
        return;
    }
    [[SecurifiToolkit sharedInstance] asyncAlmondSummaryInfoRequest:self.almondMac];
}

- (void)sendRouterSettingsRequest:(enum SecurifiToolkitAlmondRouterRequest)requestType {
    if (self.routerViewState == RouterViewState_no_almond) {
        return;
    }

    [self showLoadingRouterDataHUD];

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSString *mac = self.almondMac;

    if (!mac) {
        NSLog(@"Router: sendRouterDetailsRequest, mac is null");
    }

    [toolkit asyncAlmondStatusAndSettingsRequest:mac request:requestType];
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
        [self sendRouterSummaryRequest];
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
    [self sendRouterSettingsRequest:SecurifiToolkitAlmondRouterRequest_settings];
}

- (void)onEditDevicesAndUsersCard:(id)sender {
    if (self.enableNewWifiClientsControl) {
        [self sendRouterSettingsRequest:SecurifiToolkitAlmondRouterRequest_wifi_clients];
    }
    else {
        [self sendRouterSettingsRequest:SecurifiToolkitAlmondRouterRequest_connected_device];
    }
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
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"router.refresh-title.Refresh router data", @"Refresh router data") attributes:attributes];
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
    SFIAlmondConnectionMode mode = self.currentConnectionMode;
    if (mode == SFIAlmondConnectionMode_local) {
        return 1;
    }

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
            return 1;
        case DEF_DEVICES_AND_USERS_SECTION:
            return 1;
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
            return 120;

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
                    return [self createWirelessSummaryCell:tableView];

                case DEF_DEVICES_AND_USERS_SECTION:
                    return [self createDevicesAndUsersSummaryCell:tableView];

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
    cell.title = NSLocalizedString(@"router.card-title.Local Almond Link", @"Local Almond Link");

//    SFIRouterSummary *summary = self.routerSummary;

//    if (summary) {
//        host = summary.url;
//        if (!host) {
//            host = @"";
//        }
//
//        login = summary.login;
//        if (!login) {
//            login = @"";
//        }
//    }
//    else {
//    }

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    NSString *almondMac = self.almondMac;
    SFIAlmondLocalNetworkSettings *settings = [toolkit localNetworkSettingsForAlmond:almondMac];

    NSString *host = settings.host ? settings.host : @"";
    NSString *login = settings.login ? settings.login : @"";

    cell.summaries = @[
            [NSString stringWithFormat:NSLocalizedString(@"router.summary.IP Address : %@", @"IP Address"), host],
            [NSString stringWithFormat:NSLocalizedString(@"router.summary.Admin Login : %@", @"Admin Login"), login],
    ];

    cell.editTarget = self;
    cell.editSelector = @selector(onEditNetworkSettings:);

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

- (UITableViewCell *)createDevicesAndUsersSummaryCell:(UITableView *)tableView {
    SFIRouterSummary *routerSummary = self.routerSummary;
    //commented to allow to open clients list even if there is no connected or blocked clients
//    if (!routerSummary) {
//        return [self createEmptyWirelessSummaryCell:tableView
//                                             cellId:@"device_summary_no"
//                                          cellTitle:NSLocalizedString(@"router.card-title.Devices & Users", @"Devices & Users")
//                                        cellSummary:NSLocalizedString(@"router.card.Settings are not available.", @"Settings are not available.")
//                                          cardColor:[UIColor securifiRouterTileBlueColor]];
//    }

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

    cell.editTarget = self;
    cell.editSelector = @selector(onEditDevicesAndUsersCard:);
    cell.expanded = NO;

    return cell;
}

- (UITableViewCell *)createSoftwareVersionCell:(UITableView *)tableView {
    NSString *version = self.routerSummary.firmwareVersion;

    if (!version) {
        return [self createEmptyWirelessSummaryCell:tableView
                                             cellId:@"software_summary_no"
                                          cellTitle:NSLocalizedString(@"router.software-version.title.Software Version", @"Software Version")
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
    cell.title = newVersionAvailable ? NSLocalizedString(@"router.software-version-new.title.Software Version *", @"Software Version *") : NSLocalizedString(@"router.software-version-new.title.Software Version", @"Software Version");

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
            if (section == DEF_ROUTER_VERSION_SECTION) {
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


    self.isAlmondUnavailable = NO;

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }

        if (self.disposed) {
            return;
        }

        //todo there is a race condition that has to be handled: current Almond selection may have been changed before this callback is received and processed.

        if (self.navigationController.topViewController == self) {
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
                    device.timeout = [[dict valueForKey:@"Wait"] integerValue];
                    [dArray addObject:device];
                }

                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Scenes_Iphone" bundle:nil];
                SFIWiFiClientsListViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiClientsListViewController"];
                
                NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isActive" ascending:NO];
                NSSortDescriptor *secondDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
                
                NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, secondDescriptor, nil];
                
                dArray = [[dArray sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
                viewController.connectedDevices = dArray;
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }

        [self.HUD hide:YES];
        [self.refreshControl endRefreshing];
    });
}


- (void)onAlmondRouterCommandResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    SFIGenericRouterCommand *genericRouterCommand = (SFIGenericRouterCommand *) [data valueForKey:@"data"];
    [self processRouterCommandResponse:genericRouterCommand];
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

        if (!genericRouterCommand.commandSuccess) {
            //todo push this string comparison logic into the generic router command
            self.isAlmondUnavailable = [genericRouterCommand.responseMessage.lowercaseString hasSuffix:NSLocalizedString(@"router.offline-msg. is offline", @" is offline")]; // almond is offline, homescreen is offline
            [self syncCheckRouterViewState:RouterViewReloadPolicy_on_state_change];
            [self.HUD hide:YES];
            [self.refreshControl endRefreshing];
            return;
        }

        switch (genericRouterCommand.commandType) {
            case SFIGenericRouterCommandType_CONNECTED_DEVICES: {
                if (self.navigationController.topViewController == self) {
                    SFIDevicesList *ls = genericRouterCommand.command;

                    SFIRouterClientsTableViewController *ctrl = [SFIRouterClientsTableViewController new];
                    ctrl.title = self.navigationItem.title;
                    ctrl.connectedClients = ls.deviceList;
                    ctrl.almondMac = self.almondMac;

                    UINavigationController *nctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
                    [self presentViewController:nctrl animated:YES completion:nil];
                }

                [self syncCheckRouterViewState:RouterViewReloadPolicy_always];
                break;
            }

            case SFIGenericRouterCommandType_BLOCKED_MACS: {
                // not handled
                break;
            }

            case SFIGenericRouterCommandType_WIRELESS_SETTINGS: {
                SFIDevicesList *ls = genericRouterCommand.command;
                NSArray *settings = ls.deviceList;

                if (self.currentConnectionMode == SFIAlmondConnectionMode_local) {
                    // protect against race condition: mode changed before this callback was received
                    // do not show settings UI when the connection mode is local;
                    break;
                }

                if (self.routerSummary) {
                    // keep the summary information up to date as settings are changed in the settings controller
                    [self.routerSummary updateWirelessSummaryWithSettings:settings];
                }

                if (self.navigationController.topViewController == self) {
                    SFIRouterSettingsTableViewController *ctrl = [SFIRouterSettingsTableViewController new];
                    ctrl.title = self.navigationItem.title;
                    ctrl.wirelessSettings = settings;
                    ctrl.almondMac = self.almondMac;
                    ctrl.enableRouterWirelessControl = self.enableRouterWirelessControl;

                    UINavigationController *nctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
                    [self presentViewController:nctrl animated:YES completion:nil];
                }

                // even when in background, ensure summary view is updated to latest & greatest info
                [self syncCheckRouterViewState:RouterViewReloadPolicy_always];

                break;
            }

            case SFIGenericRouterCommandType_WIRELESS_SUMMARY: {
                SFIRouterSummary *summary = (SFIRouterSummary *) genericRouterCommand.command;

                self.routerSummary = summary;

                NSString *currentVersion = summary.firmwareVersion;
                [self tryCheckAlmondVersion:currentVersion];
                [self tryCheckSendLogsSupport:currentVersion];

                [self syncCheckRouterViewState:RouterViewReloadPolicy_always];

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

            case SFIGenericRouterCommandType_REBOOT: {
                BOOL wasRebooting = self.isRebooting;
                self.isRebooting = NO;

                // protect against the cloud sending the same response more than once
                if (wasRebooting) {
                    [self sendRouterSummaryRequest];

                    //todo handle failure case
                    [self showHUD:NSLocalizedString(@"router.hud.Router is now online.", @"Router is now online.")];
                }

                break;
            }

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
    // not impl here
}

- (void)onChangeDeviceSSID:(SFIWirelessSetting *)setting newSSID:(NSString *)ssid {
    // not impl here
}

- (void)onEnableWirelessAccessForDevice:(NSString *)deviceMAC allow:(BOOL)isAllowed {

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
