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
#import "SFIGenericRouterCommand.h"
#import "SFIParser.h"
#import "MBProgressHUD.h"
#import "Analytics.h"
#import "UIFont+Securifi.h"
#import "SFICardView.h"
#import "SFICardTableViewCell.h"
#import "SFIRouterSettingsTableViewCell.h"
#import "SFIRouterDevicesTableViewCell.h"
#import "SFIRouterRebootTableViewCell.h"
#import "SFIRouterTableViewActions.h"

#define DEF_WIRELESS_SETTINGS_SECTION   0
#define DEF_DEVICES_AND_USERS_SECTION   1
#define DEF_ROUTER_REBOOT_SECTION       3

@interface SFIRouterTableViewController () <SFIRouterTableViewActions>
@property NSTimer *hudTimer;

@property NSString *currentMAC;
@property(nonatomic, strong) SFIRouterSummary *routerSummary;
@property(nonatomic, strong) NSArray *wirelessSettings;
@property(nonatomic, strong) NSArray *connectedDevices;     // SFIConnectedDevice
@property(nonatomic, strong) NSArray *blockedDevices;       // SFIBlockedDevice

@property NSNumber *currentExpandedSection; // nil == none expanded
@property NSUInteger currentExpandedCount; // number of rows in expanded section

@property BOOL isRebooting;
@property BOOL isAlmondUnavailable;
@property BOOL shownHudOnce;
@property BOOL disposed;

@property sfi_id correlationId;

@end

@implementation SFIRouterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Set title
    SFIAlmondPlus *plus = [[SecurifiToolkit sharedInstance] currentAlmond];
    self.currentMAC = plus.almondplusMAC;

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Pull down to refresh device values
    UIRefreshControl *refresh = [UIRefreshControl new];
    NSDictionary *attributes = self.navigationController.navigationBar.titleTextAttributes;
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refresh router data" attributes:attributes];
    [refresh addTarget:self action:@selector(onRefreshRouter:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    [self initializeNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initializeAlmondData];
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

    [center addObserver:self
               selector:@selector(onNetworkChange:)
                   name:NETWORK_DOWN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkChange:)
                   name:NETWORK_UP_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkChange:)
                   name:kSFIReachabilityChangedNotification object:nil];

    [center addObserver:self
               selector:@selector(onGenericResponseCallback:)
                   name:GENERIC_COMMAND_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onGenericNotificationCallback:)
                   name:GENERIC_COMMAND_CLOUD_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];

    [center addObserver:self
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
                 object:nil];
}

- (void)initializeAlmondData {
    self.isRebooting = FALSE;
    self.enableDrawer = YES;

    // init state
    self.routerSummary = nil;
    self.wirelessSettings = nil;
    self.connectedDevices = nil;
    self.blockedDevices = nil;
    self.currentExpandedSection = nil;
    self.currentExpandedCount = 0;

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];

    if (plus == nil) {
        self.navigationItem.title = @"Get Started";
        self.currentMAC = NO_ALMOND;
        [self.tableView reloadData];
    }
    else {
        self.currentMAC = plus.almondplusMAC;
        self.navigationItem.title = plus.almondplusName;
        [self.tableView reloadData];
    }

    if (!self.shownHudOnce) {
        self.shownHudOnce = YES;
        [self showHudWithTimeout];
    }

    [self refreshDataForAlmond];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //DLog(@"Rotation %d", fromInterfaceOrientation);
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%s, Did receive memory warning", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}

#pragma mark - State

- (BOOL)isNoAlmondLoaded {
    return [self.currentMAC isEqualToString:NO_ALMOND];
}

- (BOOL)isCloudOnline {
    return [[SecurifiToolkit sharedInstance] isCloudOnline];
}

#pragma mark - Commands

- (void)sendRebootAlmondCommand {
    if (![self isNoAlmondLoaded]) {
        self.correlationId = [[SecurifiToolkit sharedInstance] asyncRebootAlmond:self.currentMAC];
    }
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
        [self.tableView reloadData];
    });
}

- (void)onCurrentAlmondChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.shownHudOnce = NO;
        if (self.isViewLoaded && self.view.window) {
            // View is visible; reload now; otherwise, viewWillAppear will invoke it for us
            [self initializeAlmondData];
        }
    });
}

- (void)onRefreshRouter:(id)sender {
    if ([self isNoAlmondLoaded]) {
        return;
    }

    [self refreshDataForAlmond];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.refreshControl endRefreshing];
    });
}

- (void)onEditWirelessSettingsCard:(id)sender {
    [self onExpandCloseSection:self.tableView section:DEF_WIRELESS_SETTINGS_SECTION];
}

- (void)onEditDevicesAndUsersCard:(id)sender {
    [self onExpandCloseSection:self.tableView section:DEF_DEVICES_AND_USERS_SECTION];
}

- (void)onEditRouterRebootCard:(id)sender {
    [self onExpandCloseSection:self.tableView section:DEF_ROUTER_REBOOT_SECTION];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isNoAlmondLoaded]) {
        return 1;
    }
    if (self.isAlmondUnavailable) {
        return 1;
    }
    if (![self isCloudOnline]) {
        return 1;
    }
    return 4;
}

- (BOOL)isExpandedSection:(NSInteger)section {
    NSNumber *expandedSection = self.currentExpandedSection;
    return expandedSection && (expandedSection.integerValue == section);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self isExpandedSection:section]) {
        return 1;
    }

    switch (section) {
        case DEF_WIRELESS_SETTINGS_SECTION:
            return 1 + self.currentExpandedCount;
        case DEF_DEVICES_AND_USERS_SECTION:
            return 1 + self.currentExpandedCount;
        case DEF_ROUTER_REBOOT_SECTION:
            return 1 + self.currentExpandedCount;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondLoaded]) {
        return 400;
    }
    if (self.isAlmondUnavailable) {
        return 400;
    }
    if (![self isCloudOnline]) {
        return 400;
    }

    switch (indexPath.section) {
        case DEF_WIRELESS_SETTINGS_SECTION:
            if (indexPath.row == 0) {
                return 120;
            }
            return 300;

        case DEF_DEVICES_AND_USERS_SECTION:
            if (indexPath.row > 0) {
                return 85;
            }

        case DEF_ROUTER_REBOOT_SECTION:
            if (indexPath.row > 0) {
                return 95;
            }
        default:
            return 85;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    if ([self isNoAlmondLoaded]) {
        return 400;
    }
    if (self.isAlmondUnavailable) {
        return 400;
    }
    if (![self isCloudOnline]) {
        return 400;
    }

    switch (indexPath.section) {
        case DEF_WIRELESS_SETTINGS_SECTION:
            if (indexPath.row > 0) {
                return 300;
            }

        case DEF_DEVICES_AND_USERS_SECTION:
            if (indexPath.row > 0) {
                return 85;
            }

        case DEF_ROUTER_REBOOT_SECTION:
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
    if ([self isNoAlmondLoaded]) {
        tableView.scrollEnabled = NO;
        return [self createNoAlmondCell:tableView];
    }

    if (self.isAlmondUnavailable) {
        tableView.scrollEnabled = NO;
        return [self createAlmondNoConnectCell:tableView];
    }

    if (![self isCloudOnline]) {
        tableView.scrollEnabled = NO;
        return [self createAlmondNoConnectCell:tableView];
    }

    tableView.scrollEnabled = YES;

    switch (indexPath.section) {
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

        case 2:
            return [self createSoftwareVersionCell:tableView];

        case DEF_ROUTER_REBOOT_SECTION:
            switch (indexPath.row) {
                case 0:
                    return [self createAlmondRebootSummaryCell:tableView];
                default:
                    return [self createAlmondRebootEditCell:tableView];
            }

        default:
            return [self createAlmondRebootSummaryCell:tableView];
    }
}

- (UITableViewCell *)createNoAlmondCell:(UITableView *)tableView {
    static NSString *id = @"NoAlmondCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    //PY 070114
    //START: HACK FOR MEMORY LEAKS
    for (UIView *currentView in cell.contentView.subviews) {
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS

    UIImageView *imgGettingStarted = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 400)];
    imgGettingStarted.userInteractionEnabled = YES;
    imgGettingStarted.image = [UIImage imageNamed:@"getting_started.png"];
    imgGettingStarted.contentMode = UIViewContentModeScaleAspectFit;

    UIButton *btnAddAlmond = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddAlmond.frame = imgGettingStarted.bounds;
    btnAddAlmond.backgroundColor = [UIColor clearColor];
    [btnAddAlmond addTarget:self action:@selector(onAddAlmondAction:) forControlEvents:UIControlEventTouchUpInside];

    [imgGettingStarted addSubview:btnAddAlmond];
    [cell addSubview:imgGettingStarted];

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
        [lblNoSensor setFont:[UIFont securifiLightFont:35]];
        lblNoSensor.text = NSLocalizedString(@"router.offline-msg.label.Almond is Offline.", @"Almond is Offline.");
        lblNoSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblNoSensor];

        UIImageView *imgRouter = [[UIImageView alloc] initWithFrame:CGRectMake(width / 2 - 50, 150, 100, 100)];
        imgRouter.userInteractionEnabled = NO;
        [imgRouter setImage:[UIImage imageNamed:@"offline_150x150.png"]];
        imgRouter.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:imgRouter];

        UILabel *lblAddSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 280, width, 40)];
        lblAddSensor.textAlignment = NSTextAlignmentCenter;
        [lblAddSensor setFont:[UIFont securifiBoldFont:20]];
        lblAddSensor.text = NSLocalizedString(@"router.offline-msg.label.Please check the router.", @"Please check the router.");
        lblAddSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblAddSensor];
    }

    return cell;
}

- (UITableViewCell *)createWirelessSummaryCell:(UITableView *)tableView {
    static NSString *cell_id = @"wireless_summary";
    SFICardTableViewCell *cell = [self getCardCell:tableView identifier:cell_id];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors blueColor] color];
    [card addTitle:NSLocalizedString(@"router.card-title.Wireless Settings", @"Wireless Settings")];

    NSMutableArray *summary = [NSMutableArray array];
    SFIRouterSummary *routerSummary = self.routerSummary;

    if (routerSummary) {
        for (SFIWirelessSummary *sum in routerSummary.wirelessSummaries) {
            NSString *enabled = sum.enabled ? NSLocalizedString(@"router.wireless-status.Enabled", @"enabled") : NSLocalizedString(@"router.wireless-status.Disabled", @"disabled");
            [summary addObject:[NSString stringWithFormat:@"%@ is %@", sum.ssid, enabled]];
        }
    }
    else {
        [summary addObject:NSLocalizedString(@"router.card.Settings are not available.", @"Settings are not available.")];
    }
    [card addSummary:summary];

    int totalCount = (int) self.wirelessSettings.count;
    if (routerSummary && totalCount > 0) {
        BOOL editing = [self isSectionExpanded:DEF_WIRELESS_SETTINGS_SECTION];
        [card addEditIconTarget:self action:@selector(onEditWirelessSettingsCard:) editing:editing];
    }

    return cell;
}

- (BOOL)isSectionExpanded:(NSInteger)sectionNumber {
    NSNumber *number = self.currentExpandedSection;
    return number != nil && [number isEqualToNumber:@(sectionNumber)];
}

- (UITableViewCell *)createWirelessSettingCell:(UITableView *)tableView tableRow:(NSInteger)row {
    static NSString *cell_id = @"wireless_settings";

    SFIRouterSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFIRouterSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    [cell markReuse];

    SFIWirelessSetting *setting = [self tryGetWirelessSettingsForTableRow:row];

    cell.cardView.backgroundColor = setting.enabled ? [[SFIColors blueColor] color] : [UIColor lightGrayColor];
    cell.wirelessSetting = setting;
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
    static NSString *cellId = @"DevicesSummary";
    SFICardTableViewCell *cell = [self getCardCell:tableView identifier:cellId];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors greenColor] color];
    [card addTitle:NSLocalizedString(@"router.card-title.Devices & Users", @"Devices & Users")];

    SFIRouterSummary *routerSummary = self.routerSummary;

    NSArray *summary;
    if (routerSummary) {
        summary = @[
                [NSString stringWithFormat:NSLocalizedString(@"router.devices-summary.%d connected, %d blocked", @"%d connected, %d blocked"), routerSummary.connectedDeviceCount, routerSummary.blockedMACCount],
        ];
    }
    else {
        summary = @[NSLocalizedString(@"router.card.Settings are not available.", @"Settings are not available.")];
    }
    [card addSummary:summary];

    int totalCount = routerSummary.connectedDeviceCount + routerSummary.blockedMACCount;
    if (routerSummary && totalCount > 0) {
        BOOL editing = [self isSectionExpanded:DEF_DEVICES_AND_USERS_SECTION];
        [card addEditIconTarget:self action:@selector(onEditDevicesAndUsersCard:) editing:editing];
    }

    return cell;
}

- (UITableViewCell *)createDevicesAndUsersEditCell:(UITableView *)tableView tableRow:(NSInteger)row {
    static NSString *cell_id = @"DevicesEdit";

    SFIRouterDevicesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFIRouterDevicesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    cell.delegate = self;
    [cell markReuse];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors greenColor] color];

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
    static NSString *CellIdentifier = @"SoftwareCell";
    SFICardTableViewCell *cell = [self getCardCell:tableView identifier:CellIdentifier];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors redColor] color];
    [card addTitle:@"Software"];

    NSString *version = self.routerSummary.firmwareVersion;

    NSArray *summary;
    if (version) {
        summary = @[NSLocalizedString(@"router.software-version.Current version", @"Current version"), version];
    }
    else {
        summary = @[NSLocalizedString(@"router.software-version.Not available", @"Version information is not available.")];
    }
    [card addSummary:summary];

    return cell;
}

- (UITableViewCell *)createAlmondRebootSummaryCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"RebootSummary";

    SFICardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SFICardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [cell markReuse];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors pinkColor] color];
    [card addTitle:NSLocalizedString(@"router.card-title.Router Reboot", @"Router Reboot")];

    NSArray *summary;
    if (self.isRebooting) {
        summary = @[
                NSLocalizedString(@"router.reboot-msg.Router is rebooting. It will take at least", @"Router is rebooting. It will take at least"),
                NSLocalizedString(@"router.reboot-msg.2 minutes for the router to boot.", @"2 minutes for the router to boot."),
                NSLocalizedString(@"router.reboot-msg.Please refresh after sometime.", @"Please refresh after sometime.")
        ];
    }
    else if (self.routerSummary == nil) {
        summary = @[NSLocalizedString(@"router.Router status is not available.", @"Router status is not available.")];
    }
    else {
        summary = @[[NSString stringWithFormat:NSLocalizedString(@"router.Last reboot %@ ago", @"Last reboot %@ ago"), self.routerSummary.routerUptime]];
    }
    [card addSummary:summary];

    BOOL editing = [self isSectionExpanded:DEF_ROUTER_REBOOT_SECTION];
    [card addEditIconTarget:self action:@selector(onEditRouterRebootCard:) editing:editing];

    return cell;
}

- (UITableViewCell *)createAlmondRebootEditCell:(UITableView *)tableView {
    static NSString *cell_id = @"RebootEdit";

    SFIRouterRebootTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFIRouterRebootTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    cell.delegate = self;
    [cell markReuse];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors pinkColor] color];

    return cell;
}

- (SFICardTableViewCell *)getCardCell:(UITableView *)tableView identifier:(NSString *)cellId {
    SFICardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[SFICardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    [cell markReuse];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return section == DEF_ROUTER_REBOOT_SECTION ? 20 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section != DEF_ROUTER_REBOOT_SECTION) {
        return nil;
    }

    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)onExpandCloseSection:(UITableView *)tableView section:(NSInteger)section {
    [tableView beginUpdates];

    NSInteger currentExpanded = -1;

    // remove rows if needed
    if (self.currentExpandedSection) {
        currentExpanded = self.currentExpandedSection.unsignedIntegerValue;

        self.currentExpandedSection = nil;
        self.currentExpandedCount = 0;

        [tableView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger) currentExpanded] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

    // add rows if needed
    if (currentExpanded != section) {
        if (section == DEF_WIRELESS_SETTINGS_SECTION) {
            self.currentExpandedSection = @(DEF_WIRELESS_SETTINGS_SECTION);
            self.currentExpandedCount = self.wirelessSettings.count;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:DEF_WIRELESS_SETTINGS_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (section == DEF_DEVICES_AND_USERS_SECTION) {
            self.currentExpandedSection = @(DEF_DEVICES_AND_USERS_SECTION);
            self.currentExpandedCount = self.connectedDevices.count + self.blockedDevices.count;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:DEF_DEVICES_AND_USERS_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (section == DEF_ROUTER_REBOOT_SECTION) {
            self.currentExpandedSection = @(DEF_ROUTER_REBOOT_SECTION);
            self.currentExpandedCount = 1;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:DEF_ROUTER_REBOOT_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }

    [tableView endUpdates];
}

#pragma mark - Class Methods

- (void)refreshDataForAlmond {
    if ([self isNoAlmondLoaded]) {
        return;
    }

    [self sendGenericCommandRequest:GET_WIRELESS_SUMMARY_COMMAND];
    [self sendGenericCommandRequest:GET_WIRELESS_SETTINGS_COMMAND];
    [self sendGenericCommandRequest:GET_CONNECTED_DEVICE_COMMAND];
    [self sendGenericCommandRequest:GET_BLOCKED_DEVICE_COMMAND];
}

- (void)onAddAlmondAction:(id)sender {
    if (self.disposed) {
        return;
    }
    if ([self isNoAlmondLoaded]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"AffiliationNavigationTop"];
        [self presentViewController:mainView animated:YES completion:nil];
    }
    else {
        //Get wireless settings
        [self refreshDataForAlmond];
    }
}

#pragma mark - Cloud command senders and handlers

- (void)sendGenericCommandRequest:(NSString *)data {
    GenericCommandRequest *request = [GenericCommandRequest new];
    request.almondMAC = self.currentMAC;
    request.applicationID = APPLICATION_ID;
    request.data = data;

    self.correlationId = request.correlationId;

    GenericCommand *cmd = [[GenericCommand alloc] init];
    cmd.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cmd.command = request;

    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cmd];
}

- (void)onGenericResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    GenericCommandResponse *response = (GenericCommandResponse *) [data valueForKey:@"data"];
    if (!response.isSuccessful) {
        DLog(@"Unsuccessful response, reason:%@", response.reason);

        dispatch_async(dispatch_get_main_queue(), ^() {
            if (!self) {
                return;
            }
            if (self.disposed) {
                return;
            }
            if (![response.almondMAC isEqualToString:self.currentMAC]) {
                return;
            }
            self.isAlmondUnavailable = YES;
            [self.tableView reloadData];
            [self.HUD hide:YES];
            [self.refreshControl endRefreshing];
        });

        return;
    }
    self.isAlmondUnavailable = NO;

    SFIGenericRouterCommand *genericRouterCommand = [SFIParser parseRouterResponse:response];
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }

        if (self.disposed) {
            return;
        }

        if (![response.almondMAC isEqualToString:self.currentMAC]) {
            return;
        }

        switch (genericRouterCommand.commandType) {
            case SFIGenericRouterCommandType_CONNECTED_DEVICES: {
                SFIDevicesList *ls = genericRouterCommand.command;
                self.connectedDevices = ls.deviceList;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:DEF_DEVICES_AND_USERS_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }

            case SFIGenericRouterCommandType_BLOCKED_MACS: {
                SFIDevicesList *ls = genericRouterCommand.command;
                self.blockedDevices = ls.deviceList;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:DEF_DEVICES_AND_USERS_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }

            case SFIGenericRouterCommandType_WIRELESS_SETTINGS: {
                SFIDevicesList *ls = genericRouterCommand.command;
                self.wirelessSettings = ls.deviceList;
                [self.routerSummary updateWirelessSummaryWithSettings:self.wirelessSettings];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:DEF_WIRELESS_SETTINGS_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }

            case SFIGenericRouterCommandType_WIRELESS_SUMMARY: {
                self.routerSummary = (SFIRouterSummary *) genericRouterCommand.command;
                [self.tableView reloadData];
                break;
            }

            case SFIGenericRouterCommandType_REBOOT:
            case SFIGenericRouterCommandType_BLOCKED_CONTENT:
            default:
                break;
        }

        [self.HUD hide:YES];
        [self.refreshControl endRefreshing];
    });
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
            [self.tableView reloadData];
        });

        return;
    }
    self.isAlmondUnavailable = NO;

    //todo push all of this parsing and manipulation into the parser or SFIGenericRouterCommand!

    NSMutableData *genericData = [[NSMutableData alloc] init];

    //Display proper message
    DLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.correlationId, obj.mobileInternalIndex);
    DLog(@"Response Data: %@", obj.genericData);
    DLog(@"Decoded Data: %@", obj.decodedData);

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
    SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:decodedString];
    DLog(@"Command Type %d", genericRouterCommand.commandType);

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        switch (genericRouterCommand.commandType) {
            case SFIGenericRouterCommandType_REBOOT: {
                self.isRebooting = FALSE;
                [self refreshDataForAlmond];

                //todo handle failure case
                [self showHUD:NSLocalizedString(@"router.hud.Router is now online.", @"Router is now online.")];
                [self.HUD hide:YES afterDelay:1];
                break;
            }
            case SFIGenericRouterCommandType_WIRELESS_SETTINGS: {
            }

            default:
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
            self.currentMAC = NO_ALMOND;
            self.navigationItem.title = NSLocalizedString(@"router.no-almonds.nav-title.Get Started", @"Get Started");
        }
        else {
            self.currentMAC = plus.almondplusMAC;
            self.navigationItem.title = plus.almondplusName;
            [self refreshDataForAlmond];
        }

        [self.tableView reloadData];
    });
}

#pragma mark - SFIRouterTableViewActions protocol methods

- (void)routerTableCellWillBeginEditingValue {
    self.enableDrawer = NO;
}

- (void)routerTableCellDidEndEditingValue {
    self.enableDrawer = YES;
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

        [[SecurifiToolkit sharedInstance] asyncSetAlmondWirelessUsersSettings:self.currentMAC blockedDeviceMacs:blockedMacs.allObjects];

        [self.HUD hide:YES afterDelay:2];
    });
}

- (void)onUpdateWirelessSettings:(SFIWirelessSetting *)copy {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        [self showUpdatingSettingsHUD];
        [[SecurifiToolkit sharedInstance] asyncUpdateAlmondWirelessSettings:self.currentMAC wirelessSettings:copy];
        [self.HUD hide:YES afterDelay:2];
    });
}

@end
