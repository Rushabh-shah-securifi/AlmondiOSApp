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
#import "MBProgressHUD.h"
#import "Analytics.h"
#import "UIFont+Securifi.h"
#import "SFICardView.h"
#import "SFIRouterRebootTableViewCell.h"
#import "SFIRouterSendLogsTableViewCell.h"
#import "SFIRouterTableViewActions.h"
#import "SFICardViewSummaryCell.h"
#import "MessageView.h"
#import "TableHeaderView.h"
#import "UIViewController+Securifi.h"
#import "SFICloudLinkViewController.h"
#import "UIColor+Securifi.h"
#import "SFIRouterSettingsTableViewController.h"
#import "RouterParser.h"
#import "RouterPayload.h"
#import "SFILogsViewController.h"

#define DEF_NETWORKING_SECTION          0
#define DEF_DEVICES_AND_USERS_SECTION   1
#define DEF_WIRELESS_SETTINGS_SECTION   2
#define DEF_ROUTER_VERSION_SECTION      3
#define DEF_ROUTER_REBOOT_SECTION       4
#define DEF_ROUTER_SEND_LOGS_SECTION    5

#define REBOOT_TAG 1
#define FIRMWARE_UPDATE_TAG 2

static const int networkingHeight = 100;
static const int clientsHeight = 100;
static const int settingsHeight = 100;
static const int versionHeight = 110;
static const int rebootHeight = 110;
static const int logsHeight = 100;

@interface SFIRouterTableViewController () <SFIRouterTableViewActions, MessageViewDelegate, AlmondVersionCheckerDelegate, TableHeaderViewDelegate,UIAlertViewDelegate>{

}

@property SFIAlmondPlus *currentAlmond;
@property BOOL newAlmondFirmwareVersionAvailable;
@property NSString *latestAlmondVersionAvailable;

@property NSTimer *hudTimer;

@property(nonatomic, strong) SFIRouterSummary *routerSummary;

@property BOOL isRebooting;
@property BOOL isAlmondUnavailable;
@property BOOL shownHudOnce;

@property(nonatomic) BOOL enableAlmondVersionRemoteUpdate;
@property(nonatomic) BOOL isSimulator;
@end

@implementation SFIRouterTableViewController
int mii;
- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        NSLog(@"router initWithStyle");
        // need to set initial state before the table view state is set up to ensure the correct view/layout is rendered.
        // the table's initial set up is done even prior to calling viewDidLoad
//        [self checkRouterViewState:RouterViewReloadPolicy_never];
    }
    
    return self;
}

- (void)viewDidLoad {
    NSLog(@"router - viewdidload");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SecurifiConfigurator *configurator = toolkit.configuration;
    self.isSimulator = configurator.isSimulator;
    
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addRefreshControl];
    [self initializeRouterSummaryAndSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewWillAppear");
    [super viewWillAppear:animated];
    mii = arc4random() % 10000;
    [self initializeNotifications];
    [self initializeAlmondData];
//    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"view will disapper");
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    [self.hudTimer invalidate];
    
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onNetworkChange:) name:NETWORK_DOWN_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onNetworkChange:) name:NETWORK_UP_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onNetworkChange:) name:kSFIReachabilityChangedNotification object:nil];
    [center addObserver:self selector:@selector(onConnectionModeDidChange:) name:kSFIDidChangeAlmondConnectionMode object:nil];
    
    [center addObserver:self selector:@selector(onCurrentAlmondChanged:) name:kSFIDidChangeCurrentAlmond object:nil];
    [center addObserver:self selector:@selector(onAlmondListDidChange:) name:kSFIDidUpdateAlmondList object:nil];
  
    [center addObserver:self selector:@selector(onAlmondRouterCommandResponse:) name:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER object:nil];
    
}

- (void)initializeRouterSummaryAndSettings {
    self.isRebooting = NO;
    self.enableDrawer = YES; //to enable navigation top left button
}

- (void)initializeAlmondData {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    self.currentAlmond = plus;
    if (plus == nil) {
        [self markAlmondMac:NO_ALMOND];
        [self markTitle:NSLocalizedString(@"router.nav-title.Get Started", @"Get Started")];
    }
    else {
        [self markAlmondMac:plus.almondplusMAC];
        [self markTitle:plus.almondplusName];
    }
    
    if (self.currentConnectionMode == SFIAlmondConnectionMode_cloud) {
        if (!self.shownHudOnce) {
            self.shownHudOnce = YES;
            [self showHudWithTimeout:NSLocalizedString(@"mainviewcontroller hud Loading router data", @"Loading router data")];
        }
    }
    
    // Reset New Version checking state and view
    self.newAlmondFirmwareVersionAvailable = NO;
    self.tableView.tableHeaderView = nil;
    
    [RouterPayload routerSummary:mii isSimulator:_isSimulator mac:self.almondMac];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didReceiveMemoryWarning {
    ELog(@"%s, Did receive memory warning", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}

#pragma mark HUD mgt

- (void)showHudWithTimeout:(NSString*)hudMsg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
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
        [self.tableView reloadData];
    });
}

- (void)onConnectionModeDidChange:(id)notice {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
        [RouterPayload routerSummary:mii isSimulator:_isSimulator mac:self.almondMac];
    });
}

- (void)onCurrentAlmondChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.shownHudOnce = NO;
        if (self.isViewLoaded && self.view.window) {
            // View is visible; reload now; otherwise, viewWillAppear will invoke it for us
            [self initializeRouterSummaryAndSettings];
            [self initializeAlmondData];
        }
    });
}

- (void)onEditNetworkSettings:(id)sender {
    [self presentLocalNetworkSettingsEditor];
}

- (void)onEditWirelessSettingsCard:(id)sender {
    [self showHudWithTimeout:NSLocalizedString(@"mainviewcontroller hud Loading router data", @"Loading router data")];
    [RouterPayload getWirelessSettings:mii isSimulator:_isSimulator mac:self.almondMac];
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
    if ([self isNoAlmondLoaded]) {
        return;
    }
    
    // reset table view state when Refresh is called (and when current Almond is changed)
    [RouterPayload routerSummary:mii isSimulator:_isSimulator mac:self.almondMac];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isNotConnectedToCloud]) {
        NSLog(@"numberOfRowsInSection isNotConnectedToCloud");
        return 1;
    }
    
    SFIAlmondConnectionMode mode = self.currentConnectionMode;
    if (mode == SFIAlmondConnectionMode_local) {
        return 2;
    }else{
        return 6;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    if ([self isNotConnectedToCloud]) {
        return 400;
    }
    switch (indexPath.section) {
        case DEF_NETWORKING_SECTION:
            return networkingHeight;
        case DEF_DEVICES_AND_USERS_SECTION:
            return clientsHeight;
        case DEF_WIRELESS_SETTINGS_SECTION:
            return settingsHeight;
        case DEF_ROUTER_VERSION_SECTION:
            return versionHeight;
        case DEF_ROUTER_REBOOT_SECTION:
            return rebootHeight;
        case DEF_ROUTER_SEND_LOGS_SECTION:
            return logsHeight;
        default: {
            return 100;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isNoAlmondLoaded]){
        tableView.scrollEnabled = NO;
        return [self createNoAlmondCell:tableView];
    }else if(self.isAlmondUnavailable || (![[SecurifiToolkit sharedInstance] isNetworkOnline] && !_isSimulator)){
        tableView.scrollEnabled = NO;
        return [self createAlmondOfflineCell:tableView];
    }else{
        tableView.scrollEnabled = YES;
        NSArray *summaries;
        switch (indexPath.section) {
            case DEF_NETWORKING_SECTION:{
                 summaries = [self getNetworkSummary];
                return [self createSummaryCell:tableView summaries:summaries title:NSLocalizedString(@"router.card-title.Local Almond Link", @"Local Almond Link") selector:@selector(onEditNetworkSettings:) cardColor:[UIColor securifiRouterTileGreenColor]];
            }
            case DEF_WIRELESS_SETTINGS_SECTION:{
                summaries = [self getWirelessSettingsSummary];
                return [self createSummaryCell:tableView summaries:summaries title:NSLocalizedString(@"router.card-title.Wireless Settings", @"Wireless Settings") selector:@selector(onEditWirelessSettingsCard:) cardColor:[UIColor securifiRouterTileSlateColor]];
            }
            case DEF_DEVICES_AND_USERS_SECTION:{
                summaries = [self getDevicesAndUsersSummary];
                return [self createSummaryCell:tableView summaries:summaries title:NSLocalizedString(@"router.card-title.Devices & Users", @"Devices & Users") selector:nil cardColor:[UIColor securifiRouterTileBlueColor]];
            }
            case DEF_ROUTER_VERSION_SECTION:{
                NSString *title = self.newAlmondFirmwareVersionAvailable ? NSLocalizedString(@"router.software-version-new.title.Software Version *", @"Software Version *") : NSLocalizedString(@"router.software-version-new.title.Software Version", @"Software Version");
                summaries = [self getRouterVersionSummary];
                SFICardViewSummaryCell *cell = (SFICardViewSummaryCell *)[self createSummaryCell:tableView summaries:summaries title:title selector:nil cardColor:[UIColor securifiRouterTileYellowColor]];
                if(self.newAlmondFirmwareVersionAvailable)
                    [self addButton:cell buttonLabel:@"UPDATE FIRMWARE" selector:@selector(onFirmwareUpdate:)];
                return cell;
            }
                
            case DEF_ROUTER_REBOOT_SECTION:{
                summaries = [self getRebootSummary];
                SFICardViewSummaryCell *cell = (SFICardViewSummaryCell *)[self createSummaryCell:tableView summaries:summaries title:NSLocalizedString(@"router.card-title.Router Reboot", @"Router Reboot") selector:nil cardColor:[UIColor securifiRouterTileRedColor]];
                [self addButton:cell buttonLabel:@"REBOOT NOW" selector:@selector(onRebootButtonPressed:)];
                return cell;
            }
                
            case DEF_ROUTER_SEND_LOGS_SECTION:
                summaries = [self getLogsSummary];
                return [self createSummaryCell:tableView summaries:summaries title:NSLocalizedString(@"router.card-title.Send Logs", @"Report a Problem") selector:@selector(onLogsCard:) cardColor:[[SFIColors yellowColor] color]];
                
            default:
                return [self createSummaryCell:tableView summaries:nil title:nil selector:nil cardColor:[UIColor whiteColor]];
        }
    }
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
    if([self isNotConnectedToCloud]){
        return 0;
    }else{
        if (section == [tableView numberOfSections] - 1) { // last section gets padding from a footer
            return 20;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if([self isNotConnectedToCloud]){
        return nil;
    }else{
        if (section == [tableView numberOfSections] - 1) { // last section gets padding from a footer
            UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
            view.backgroundColor = [UIColor clearColor];
            return view;
        }
    }
    return nil;
}


-(NSArray*)getNetworkSummary{
    NSLog(@"self.routersummery.url: %@", self.routerSummary.url);
    NSString *host = self.routerSummary.url ? self.routerSummary.url : @"";
    NSString *login = self.routerSummary.login ? self.routerSummary.login : @"";
    return @[
           [NSString stringWithFormat:NSLocalizedString(@"router.summary.IP Address : %@", @"IP Address"), host],
           [NSString stringWithFormat:NSLocalizedString(@"router.summary.Admin Login : %@", @"Admin Login"), login],
           ];

}

-(NSArray*)getWirelessSettingsSummary{
    
    NSMutableArray *summary = [NSMutableArray array];
    if(self.routerSummary){
        for (SFIWirelessSummary *sum in self.routerSummary.wirelessSummaries) {
            NSString *enabled = sum.enabled ? NSLocalizedString(@"router.wireless-status.Enabled", @"enabled") : NSLocalizedString(@"router.wireless-status.Disabled", @"disabled");
            [summary addObject:[NSString stringWithFormat:@"%@ is %@", sum.ssid, enabled]];
        }
    }else{
        return @[@"Settings are not available."];
    }
    
    return summary;
}

-(NSArray*)getDevicesAndUsersSummary{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    int activeClientsCount = 0;
    int inActiveClientsCount = 0;
    for(Client *client in toolkit.clients){
        if (client.isActive) {
            activeClientsCount++;
        }else{
            inActiveClientsCount++;
        }
    }
    return @[
           [NSString stringWithFormat:NSLocalizedString(@"router.devices-summary.%d Active, %d Inactive", @"%d ACTIVE, %d INACTIVE"),
            activeClientsCount,
            inActiveClientsCount],
           ];
}

-(NSArray*)getRouterVersionSummary{
    NSString *version = self.routerSummary.firmwareVersion;
    NSArray *summary;
    if (version) {
        NSString *currentVersion_label = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"router.software-version.Current version", @"Current version"), version];
        if (self.newAlmondFirmwareVersionAvailable) {
            NSString *updateAvailable_label = NSLocalizedString(@"router.software-version.Update Available", @"Update Available");
            summary = @[updateAvailable_label, currentVersion_label];
        }
        else {
            summary = @[currentVersion_label];
        }
        
    }else{
        summary = @[NSLocalizedString(@"router.software-version.Not available", @"Version information is not available.")];
    }
    
    return summary;
}

-(NSArray*)getRebootSummary{
    NSArray *summary;
    if (self.routerSummary) {
        
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
    }else{
        summary =  @[NSLocalizedString(@"router.Router status is not available.", @"Router status is not available.")];
    }
    return  summary;
}

-(NSArray*)getLogsSummary{
    return @[[NSString stringWithFormat:NSLocalizedString(@"router.Sends %@'s logs to our server", @"Sends %@'s logs to our server"), self.currentAlmond.almondplusName]];
}

-(BOOL)isNotConnectedToCloud{
    if ([self isNoAlmondLoaded] || self.isAlmondUnavailable || (![[SecurifiToolkit sharedInstance] isNetworkOnline] && !_isSimulator)) {
        return YES;
    }
    return NO;
}

- (BOOL)isNoAlmondLoaded {
    return [self.almondMac isEqualToString:NO_ALMOND];
}


-(void)addButton:(SFICardViewSummaryCell*)cell buttonLabel:(NSString *)label selector:(SEL)selectorMethod{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 160, rebootHeight - 25, 140, 20)];
    button.enabled = YES;
    button.titleLabel.font = [UIFont standardUIButtonFont];
    
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                             NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:label attributes:attrs];
    //use the setAttributedTitle method
    
    [button setAttributedTitle:attrStr forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentRight;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [button setTitleColor:[SFIColors darkerColorForColor:[UIColor whiteColor]] forState:UIControlStateSelected];
    [button addTarget:self action:selectorMethod forControlEvents:UIControlEventTouchUpInside];
    
    [cell.cardView addSubview:button];
}

-(void)onRebootButtonPressed:(id)sender{
    NSLog(@"onRebootButtonPressed");
    [self createAlertViewForTitle:@"Are you sure, you want to Reboot?" otherTitle:@"Reboot" tag:REBOOT_TAG];
}

-(void)onFirmwareUpdate:(id)sender{
    NSLog(@"onFirmwareUpdate");
    [self createAlertViewForTitle:@"Are you sure, you want to Update Firmware?" otherTitle:@"Update" tag:FIRMWARE_UPDATE_TAG];
}

-(void)createAlertViewForTitle:(NSString*)title otherTitle:(NSString*)otherTitle tag:(int)tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:otherTitle, nil];
    alert.tag = tag;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });

}

#pragma mark alert view delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //nothing
    }else{
        if(alertView.tag == FIRMWARE_UPDATE_TAG){
            [self showHUD:NSLocalizedString(@"router.hud.Updating router firmware.", @"Updating router firmware.")];
            [RouterPayload updateFirmware:mii version:self.latestAlmondVersionAvailable isSimulator:_isSimulator mac:self.almondMac];
        }else if(alertView.tag == REBOOT_TAG){
            [self showHUD:NSLocalizedString(@"router.hud.Router is rebooting.", @"Router is rebooting.")];
            self.isRebooting = TRUE;
            [RouterPayload routerReboot:mii isSimulator:_isSimulator mac:self.almondMac];
        }
    }
}

-(void)onLogsCard:(id)sender{
    if (self.navigationController.topViewController == self) {
        SFILogsViewController *ctrl = [SFILogsViewController new];
        ctrl.title = self.navigationItem.title;
        UINavigationController *nctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        [self presentViewController:nctrl animated:YES completion:nil];
    }
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
        label.text = @"Sorry, Your Almond cannot be reached for now.";
        label.textColor = [UIColor grayColor];
        [cell addSubview:label];
    }
    
    return cell;
}


- (UITableViewCell *)createSummaryCell:(UITableView *)tableView summaries:(NSArray*)summaries title:(NSString*)title selector:(SEL)selector cardColor:color{
    NSLog(@"createNetworkSummaryCell");
    NSString *const cell_id = @"network_summary";
    
    SFICardViewSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFICardViewSummaryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    
    [cell markReuse];
    
    cell.cardView.rightOffset = SFICardView_right_offset_inset;
    cell.cardView.backgroundColor = color;
    cell.title = title;
    
    cell.summaries = summaries;
    cell.editTarget = self;
    cell.editSelector = selector;
    return cell;
}


#pragma mark - Cloud command response handlers
- (void)onAlmondRouterCommandResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    
    SFIGenericRouterCommand *genericRouterCommand = (SFIGenericRouterCommand *) [data valueForKey:@"data"];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        if (!genericRouterCommand.commandSuccess) {
            //todo push this string comparison logic into the generic router command
            self.isAlmondUnavailable = [genericRouterCommand.responseMessage.lowercaseString hasSuffix:NSLocalizedString(@"router.offline-msg. is offline", @" is offline")]; // almond is offline, homescreen is offline
            [self.HUD hide:YES];
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
            return;
        }
        NSLog(@"genericcommdntype: %d", genericRouterCommand.commandType);
        switch (genericRouterCommand.commandType) {
            case SFIGenericRouterCommandType_WIRELESS_SUMMARY: {
                NSLog(@"SFIGenericRouterCommandType_WIRELESS_SUMMARY - router summary");
                self.routerSummary = (SFIRouterSummary *)genericRouterCommand.command;
                [toolkit tryUpdateLocalNetworkSettingsForAlmond:toolkit.currentAlmond.almondplusMAC withRouterSummary:self.routerSummary];
                NSString *currentVersion = self.routerSummary.firmwareVersion;
                [self tryCheckAlmondVersion:currentVersion];
                break;
            }
            case SFIGenericRouterCommandType_WIRELESS_SETTINGS: {
                NSArray *settings = genericRouterCommand.command;
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
                    NSLog(@"cloud settings: %@", settings);
                    SFIRouterSettingsTableViewController *ctrl = [SFIRouterSettingsTableViewController new];
                    ctrl.title = self.navigationItem.title;
                    ctrl.wirelessSettings = settings;
                    ctrl.almondMac = self.almondMac;
                    ctrl.enableRouterWirelessControl = YES;
                    UINavigationController *nctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
                    [self presentViewController:nctrl animated:YES completion:nil];
                }
                break;
            }
            case SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE: {
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
                    [RouterPayload routerSummary:mii isSimulator:_isSimulator mac:self.almondMac];
                    //todo handle failure case
                    [self showHudWithTimeout:NSLocalizedString(@"router.hud.Router is now online.", @"Router is now online.")];
                }
                break;
            }
            default:
                break;
        }
        
        [self.HUD hide:YES];
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
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
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        SFIAlmondPlus *plus = [toolkit currentAlmond];
        
        if (plus == nil) {
            [self markAlmondMac:NO_ALMOND];
            self.navigationItem.title = NSLocalizedString(@"router.no-almonds.nav-title.Get Started", @"Get Started");
        }
        else {
            [self markAlmondMac:plus.almondplusMAC];
            self.navigationItem.title = plus.almondplusName;
           [RouterPayload routerSummary:mii isSimulator:_isSimulator mac:self.almondMac];
        }
        
        [self.tableView reloadData];
    });
}

#pragma mark - MessageViewDelegate methods
//on no almond view
- (void)messageViewDidPressButton:(MessageView *)msgView {
    if ([self isNoAlmondLoaded]) {
        UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
        [self presentViewController:ctrl animated:YES completion:nil];
    }
    else {
        //Get wireless settings
        [RouterPayload routerSummary:mii isSimulator:_isSimulator mac:self.almondMac];
    }
}

#pragma mark - AlmondVersionChecker methods

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

- (void)dismissHeaderView:(TableHeaderView *)view {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [UIView animateWithDuration:0.75 animations:^() {
            self.tableView.tableHeaderView = nil;
        }];
    });
}

@end
