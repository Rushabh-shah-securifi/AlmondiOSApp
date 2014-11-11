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

#define DEF_WIRELESS_SETTINGS_SECTION 0

@interface SFIRouterTableViewController () <UIActionSheetDelegate>
@property NSTimer *hudTimer;

@property NSString *currentMAC;
@property(nonatomic, strong) SFIRouterSummary *routerSummary;
@property(nonatomic, strong) NSArray *wirelessSettings;

@property NSNumber *currentExpandedSection; // nil == none expanded
@property NSUInteger currentExpandedCount; // number of rows in expanded section

@property BOOL isRebooting;
@property BOOL isAlmondUnavailable;
@property BOOL shownHudOnce;
@property BOOL disposed;

@property unsigned int mobileInternalIndex;
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
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Force router data refresh" attributes:attributes];
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
        [self showHudOnTimeout];
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

- (void)sendAlmondWirelessSummaryCommand {
    if (![self isNoAlmondLoaded]) {
        [self sendGenericCommandRequest:GET_WIRELESS_SUMMARY_COMMAND];
    }
}

- (void)sendRebootAlmondCommand {
    if (![self isNoAlmondLoaded]) {
        [self sendGenericCommandRequest:REBOOT_COMMAND];
    }
}

- (void)sendWirelessSettingsCommand {
    if (![self isNoAlmondLoaded]) {
        [self sendGenericCommandRequest:GET_WIRELESS_SETTINGS_COMMAND];
    }
}

#pragma mark HUD mgt

- (void)showHudOnTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.hudTimer invalidate];
        self.hudTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onHudTimeout:) userInfo:nil repeats:NO];
        [self.HUD show:YES];
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

- (void)onEditCard:(id)onEditCard {

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
    if (self.isRebooting) {
        return 100;
    }
    if (![self isCloudOnline]) {
        return 400;
    }

    if (indexPath.section == 0 /* wireless summary */) {
        if (indexPath.row == 0) {
            return 120;
        }
        return 200;
    }
    else {
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
    if (self.isRebooting) {
        return 100;
    }
    if (![self isCloudOnline]) {
        return 400;
    }

    if (indexPath.section == 0 /* wireless summary */) {
        if (indexPath.row > 0) {
            return 300;
        }
    }

    SFICardTableViewCell *cell = (SFICardTableViewCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell computedLayoutHeight];
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
        case 1:
            return [self createDevicesAndUsersCell:tableView];
        case 2:
            return [self createSoftwareVersionCell:tableView];
        default:
            return [self createAlmondRebootCell:tableView];
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
        lblNoSensor.text = @"Almond is Offline.";
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
        lblAddSensor.text = @"Please check the router.";
        lblAddSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblAddSensor];
    }

    return cell;
}

- (UITableViewCell *)createWirelessSummaryCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"wireless_summary";
    SFICardTableViewCell *cell = [self getCardCell:tableView identifier:CellIdentifier];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors blueColor] color];
    [card addTitle:@"Wireless Settings"];

    NSMutableArray *summary = [NSMutableArray array];
    for (SFIWirelessSummary *sum in self.routerSummary.wirelessSummary) {
        [summary addObject:[NSString stringWithFormat:@"%@ is %@", sum.ssid, sum.enabledStatus]];
    }
    [card addSummary:summary];

    [card addEditIconTarget:self action:@selector(onEditCard:) editing:NO];

    return cell;
}

- (UITableViewCell *)createWirelessSettingCell:(UITableView *)tableView tableRow:(NSInteger)row {
    static NSString *cell_id = @"wireless_settings";

    SFIRouterSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFIRouterSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    [cell markReuse];

    cell.cardView.backgroundColor = [[SFIColors blueColor] color];
    cell.setting = [self tryGetSettingsForTableRow:row];

    return cell;
}

- (SFIWirelessSetting *)tryGetSettingsForTableRow:(NSInteger)row {
    NSArray *settings = self.wirelessSettings;

    row = row - 1;
    if (row < 0) {
        return nil;
    }
    if (row >= settings.count) {
        return nil;
    }

    return settings[(NSUInteger) row];
}

- (UITableViewCell *)createDevicesAndUsersCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"DevicesCell";
    SFICardTableViewCell *cell = [self getCardCell:tableView identifier:CellIdentifier];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors greenColor] color];
    [card addTitle:@"Devices & Users"];

    NSArray *summary = @[
            [NSString stringWithFormat:@"%d connected, %d blocked", self.routerSummary.connectedDeviceCount, self.routerSummary.blockedMACCount],
    ];
    [card addSummary:summary];

    [card addEditIconTarget:self action:@selector(onEditCard:) editing:NO];

    return cell;
}

- (UITableViewCell *)createSoftwareVersionCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"SoftwareCell";
    SFICardTableViewCell *cell = [self getCardCell:tableView identifier:CellIdentifier];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors redColor] color];
    [card addTitle:@"Software"];

    NSString *version = self.routerSummary.firmwareVersion;
    if (version) {
        NSArray *summary = @[@"Current version", version];
        [card addSummary:summary];
    }
    else {
        [card addSummary:@[@"Version information is not available"]];
    }

    return cell;
}

- (UITableViewCell *)createAlmondRebootCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"AlmondCell";

    SFICardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SFICardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [cell markReuse];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [[SFIColors pinkColor] color];
    [card addTitle:@"Router Reboot"];

    NSArray *summary;
    if (self.routerSummary == nil) {
        summary = @[@"Router status is not available."];
    }
    else if (self.isRebooting) {
        summary = @[@"Router is rebooting. It will take at least", @"2 minutes for the router to boot.", @"Please refresh after sometime."];
    }
    else {
        summary = @[[NSString stringWithFormat:@"Last reboot %@ ago", self.routerSummary.routerUptime]];
    }
    [card addSummary:summary];

    [card addEditIconTarget:self action:@selector(onEditCard:) editing:NO];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self isNoAlmondLoaded]) {
//        return;
//    }
//
//    if (self.isAlmondUnavailable) {
//        return;
//    }
//
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//            initWithTitle:@"Reboot the router?"
//                 delegate:self
//        cancelButtonTitle:@"No"
//   destructiveButtonTitle:@"Yes"
//        otherButtonTitles:nil];
//
//    [actionSheet showFromTabBar:self.tabBarController.tabBar];

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
    if (currentExpanded != indexPath.section) {
        if (indexPath.section == DEF_WIRELESS_SETTINGS_SECTION) {
            self.currentExpandedSection = @(DEF_WIRELESS_SETTINGS_SECTION);
            self.currentExpandedCount = self.wirelessSettings.count;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:DEF_WIRELESS_SETTINGS_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }

    [tableView endUpdates];

//    SFIWirelessTableViewController *ctrl = [SFIWirelessTableViewController new];
//    ctrl.currentSetting = self.wirelessSettings[0];
//    [self.navigationController pushViewController:ctrl animated:YES];


//    SFIRouterDevicesListViewController *viewController = [[SFIRouterDevicesListViewController alloc] init];
//    viewController.deviceList = self.wirelessSettings.deviceList;
//    viewController.deviceListType = SFIGenericRouterCommandType_WIRELESS_SETTINGS;
//
//    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Class Methods

- (void)refreshDataForAlmond {
    [self sendAlmondWirelessSummaryCommand];
    [self sendWirelessSettingsCommand];
}

//- (IBAction)onRebootButtonAction:(id)sender {
//    //Send Generic Command
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//            initWithTitle:@"Reboot the router?"
//                 delegate:self
//        cancelButtonTitle:@"No"
//   destructiveButtonTitle:@"Yes"
//        otherButtonTitles:nil];
//
//    [actionSheet showInView:self.view];
//}

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

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            DLog(@"Clicked on yes");

            dispatch_async(dispatch_get_main_queue(), ^() {
                if (self.disposed) {
                    return;
                }
                self.HUD.labelText = @"Router is rebooting.";
                [self.HUD hide:YES afterDelay:1];

                self.isRebooting = TRUE;
                [self sendRebootAlmondCommand];
                [self.tableView reloadData];

                [[Analytics sharedInstance] markRouterReboot];
            });

            break;
        }

        case 1: {
            DLog(@"Clicked on no");
            break;
        }

        default: {
            break;
        }
    }
}

#pragma mark - Cloud command senders and handlers

- (void)sendGenericCommandRequest:(NSString *)data {
    GenericCommandRequest *request = [GenericCommandRequest new];
    request.almondMAC = self.currentMAC;
    request.applicationID = APPLICATION_ID;
    request.data = data;

    self.mobileInternalIndex = request.correlationId;

    GenericCommand *cmd = [[GenericCommand alloc] init];
    cmd.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cmd.command = request;

    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cmd];
}

- (void)onGenericResponseCallback:(id)sender {
    if (!self) {
        return;
    }

    if (self.disposed) {
        return;
    }

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    GenericCommandResponse *obj = (GenericCommandResponse *) [data valueForKey:@"data"];

    BOOL isSuccessful = obj.isSuccessful;
    if (!isSuccessful) {
        DLog(@"Reason: %@", obj.reason);

        dispatch_async(dispatch_get_main_queue(), ^() {
            if (self.disposed) {
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

    //Display proper message
    DLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
    DLog(@"Response Data: %@", obj.genericData);
    DLog(@"Decoded Data: %@", obj.decodedData);

    NSData *decoded_data = [obj.decodedData copy];
    DLog(@"Data: %@", decoded_data);

    NSMutableData *genericData = [[NSMutableData alloc] init];
    [genericData appendData:decoded_data];

    unsigned int expectedDataLength;
    unsigned int commandData;

    [genericData getBytes:&expectedDataLength range:NSMakeRange(0, 4)];
    [genericData getBytes:&commandData range:NSMakeRange(4, 4)];

    //Remove 8 bytes from received command
    [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

    NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
    SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:decodedString];
    DLog(@"Command Type %d", genericRouterCommand.commandType);

    switch (genericRouterCommand.commandType) {
        case SFIGenericRouterCommandType_REBOOT: {
            //Reboot
            SFIRouterReboot *routerReboot = (SFIRouterReboot *) genericRouterCommand.command;
            NSLog(@"Reboot Reply: %d", routerReboot.reboot);
            break;
        }
//                case 2:
//                {
//                    //Get Connected Device List
//                    SFIDevicesList *routerConnectedDevices = (SFIDevicesList*)genericRouterCommand.command;
//                    DLog(@"Connected Devices Reply: %d", [routerConnectedDevices.deviceList count]);
//                    //Display list
//                    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//                    viewController.deviceList = routerConnectedDevices.deviceList;
//                    viewController.deviceListType = genericRouterCommand.commandType;
//                    [self.navigationController pushViewController:viewController animated:YES];
//                }
//                    break;
//                case 3:
//                {
//                    //Get Blocked Device List
//                    SFIDevicesList *routerBlockedDevices = (SFIDevicesList*)genericRouterCommand.command;
//                    DLog(@"Blocked Devices Reply: %d", [routerBlockedDevices.deviceList count]);
//                    //Display list
//                    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//                    viewController.deviceList = routerBlockedDevices.deviceList;
//                    viewController.deviceListType = genericRouterCommand.commandType;
//                    [self.navigationController pushViewController:viewController animated:YES];
//
//                }
//                    break;
//                    //TODO: Case 4: Set blocked device
//                case 5:
//                {
//                    //Get Blocked Device Content
//                    SFIDevicesList *routerBlockedContent = (SFIDevicesList*)genericRouterCommand.command;
//                    DLog(@"Blocked content Reply: %d", [routerBlockedContent.deviceList count]);
//                    //Display list
//                    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//                    viewController.deviceList = routerBlockedContent.deviceList;
//                    viewController.deviceListType = genericRouterCommand.commandType;
//                    [self.navigationController pushViewController:viewController animated:YES];
//               }
//                    break;
        case SFIGenericRouterCommandType_WIRELESS_SETTINGS: {
            //Get Wireless Settings
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (self.disposed) {
                    return;
                }

                SFIDevicesList *ls = genericRouterCommand.command;
                self.wirelessSettings = ls.deviceList;
            });
            break;
        }
        case SFIGenericRouterCommandType_WIRELESS_SUMMARY: {
            // Get Wireless Summary
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (self.disposed) {
                    return;
                }

                self.routerSummary = (SFIRouterSummary *) genericRouterCommand.command;
                [self.tableView reloadData];
            });

            break;
        }

        default:
            break;
    } // end switch

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
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

    NSMutableData *genericData = [[NSMutableData alloc] init];

    //Display proper message
    DLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
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

//                SFIRouterReboot *routerReboot = (SFIRouterReboot *) genericRouterCommand.command;
//                NSLog(@"Reboot Reply: %d", routerReboot.reboot);

                //todo handle failure case
                self.HUD.labelText = @"Router is now online.";
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
            self.navigationItem.title = @"Get Started";
        }
        else {
            self.currentMAC = plus.almondplusMAC;
            self.navigationItem.title = plus.almondplusName;
            [self refreshDataForAlmond];
        }

        [self.tableView reloadData];
    });
}

@end
