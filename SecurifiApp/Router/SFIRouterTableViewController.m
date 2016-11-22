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
#import "SFIAlmondLocalNetworkSettings.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "AlmondNetworkTableViewCell.h"
#import "MeshSetupViewController.h"
#import "CommonMethods.h"
#import "MeshPayload.h"
#import "AlmondStatus.h"
#import "AdvanceRouterSettingsController.h"
#import "LocalNetworkManagement.h"
#import "ConnectionStatus.h"

#define DEF_NETWORKING_SECTION          0
#define DEF_MESH_SECTION                1
#define DEF_ADVANCED_ROUTER_SECTION     2
#define DEF_WIRELESS_SECTION            3
#define DEF_ROUTER_VERSION_SECTION      4
#define DEF_ROUTER_REBOOT_SECTION       5
#define DEF_ROUTER_SEND_LOGS_SECTION    6

#define REBOOT_TAG 1
#define FIRMWARE_UPDATE_TAG 2

static const int networkingHeight = 110;
static const int almondNtwkHeight = 200;
static const int advanceRtrHeight = 100;
static const int settingsHeight = 70;
static const int versionHeight = 130;
static const int rebootHeight = 110;
static const int logsHeight = 100;

@interface SFIRouterTableViewController () <SFIRouterTableViewActions, AlmondVersionCheckerDelegate, TableHeaderViewDelegate,UIAlertViewDelegate, AlmondNetworkTableViewCellDelegate>{
    
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

@property(nonatomic) BOOL isBUG;
@property(nonatomic) BOOL isAlmDetailView;
@property(nonatomic) BOOL almCount;
@property(nonatomic) BOOL enableAdvRouter;
@property(nonatomic) AlmondStatus *slaveStatus;
@end

@implementation SFIRouterTableViewController
int mii;
- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"router viewDidLoad");
    [self displayWebView:@""];
    if([[SecurifiToolkit sharedInstance] isScreenShown:@"wifi"] == NO)
        [self initializeHelpScreensfirst:@"wifi"];
    
    [self markAlmondTitleAndMac];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self addRefreshControl];
    [self initializeRouterSummaryAndSettings];
    self.enableAdvRouter = YES;
    
}

- (void)displayWebView:(NSString *)strForWebView{
    NSLog(@"display web view main");
    //this might slow down the app, perhaps you can think of better
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        webView.backgroundColor = [UIColor clearColor];
        [webView loadHTMLString:strForWebView baseURL:nil];
        [self.view addSubview:webView];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"router view will appear");
    [super viewWillAppear:animated];
    mii = arc4random() % 10000;
    
    [self initializeNotifications];
    self.routerSummary = nil;
    self.slaveStatus = [AlmondStatus new];
    
    self.isBUG = NO;
    [self initializeAlmondData];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"router view will disappear");
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onCurrentAlmondChanged:) name:kSFIDidChangeCurrentAlmond object:nil];
    
    [center addObserver:self selector:@selector(onAlmondListDidChange:) name:kSFIDidUpdateAlmondList object:nil];
    
    [center addObserver:self selector:@selector(onAlmondRouterCommandResponse:) name:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onClientResponse:) name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onRouterPageCommandResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onRouterPageMeshCommandResponse:) name:NOTIFICATION_COMMAND_TYPE_MESH_RESPONSE object:nil];
    
}

- (void)initializeRouterSummaryAndSettings {
    self.isRebooting = NO;
}

- (void)initializeAlmondData {
    
    [self markAlmondTitleAndMac];
    // Reset New Version checking state and view
    self.newAlmondFirmwareVersionAvailable = NO;
    self.isAlmondUnavailable = NO;
    self.tableView.tableHeaderView = nil;
    
    NSLog(@"almond mac: %@", self.almondMac);
    if([self isNoAlmondLoaded] || ![self isFirmwareCompatible] || [self isDisconnected] || [self currentConnectionMode] == SFIAlmondConnectionMode_local){
        
    }
    else{
        [self showHudWithTimeout:NSLocalizedString(@"Loading router data", @"Loading router data")];
    }
    [RouterPayload routerSummary:mii mac:self.almondMac];
}

-(void)markAlmondTitleAndMac{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    self.currentAlmond = plus;
    if (plus == nil) {
        [self markNewTitle:NSLocalizedString(@"Get Started", @"Get Started")];
        [self markAlmondMac:NO_ALMOND];
    }
    else {
        [self markNewTitle:plus.almondplusName];
        [self markAlmondMac:plus.almondplusMAC];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didReceiveMemoryWarning {
    ELog(@"%s, Did receive memory warning", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}

#pragma mark HUD mgt

- (void)showHudWithTimeoutFirmwareMsg:(NSString*)hudMsg {
    //NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:120];
    });
}

- (void)showHudWithTimeout:(NSString*)hudMsg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:10];
    });
}


#pragma mark - External Event handlers

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

- (void)onAlmondListDidChange:(id)sender {
    NSLog(@"on almond list did change router");
    dispatch_async(dispatch_get_main_queue(), ^() {
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        SFIAlmondPlus *plus = [toolkit currentAlmond];
        NSLog(@"plus: %@", plus);
        
        [self markAlmondTitleAndMac];
        
        [self.tableView reloadData];
    });
}

#pragma mark - Refresh control methods

// Pull down to refresh device values
- (void)addRefreshControl {
    UIRefreshControl *refresh = [UIRefreshControl new];
    NSDictionary *attributes = self.navigationController.navigationBar.titleTextAttributes;
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Refresh router data", @"Refresh router data") attributes:attributes];
    [refresh addTarget:self action:@selector(onRefreshRouter:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)onRefreshRouter:(id)sender {
    if ([self isNoAlmondLoaded]) {
        return;
    }
    // reset table view state when Refresh is called (and when current Almond is changed)
    [RouterPayload routerSummary:mii mac:self.almondMac];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isNotConnectedToCloud] || ![self isFirmwareCompatible]) {
        //NSLog(@"numberOfRowsInSection isNotConnectedToCloud");
        return 1;
    }
    
    if (self.currentConnectionMode == SFIAlmondConnectionMode_local) {
        return [self isAL3]? 2: 1;
    }else{
        return 7;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    if ([self isNotConnectedToCloud] || ![self isFirmwareCompatible]) {
        return 400;
    }
    
    switch (indexPath.section) {
        case DEF_NETWORKING_SECTION:
            return networkingHeight;
        case DEF_MESH_SECTION:
            return [self isAL3]?almondNtwkHeight: 0;
        case DEF_ADVANCED_ROUTER_SECTION:
            return _enableAdvRouter? advanceRtrHeight: 0;
        case DEF_WIRELESS_SECTION:
            return  [self getSettingsRowHeight];
        case DEF_ROUTER_VERSION_SECTION:
            return self.newAlmondFirmwareVersionAvailable? versionHeight: versionHeight - 20;
        case DEF_ROUTER_REBOOT_SECTION:
            return rebootHeight;
        case DEF_ROUTER_SEND_LOGS_SECTION:
            return logsHeight;
        default: {
            return 100;
        }
    }
}

-(BOOL)isAL3{
//    possible values of "Router mode " in Router summary
//    master/WirelessSlave/WiredSlave/re/ap/router/wwan
    NSString *mode = _routerSummary.routerMode.lowercaseString;
    BOOL isRouterOrMaster = [mode isEqualToString:@"router" ] || [mode isEqualToString:@"master"];
    return [_routerSummary.firmwareVersion hasPrefix:@"AL3-"] && isRouterOrMaster;
}

-(BOOL)isInREMode{
    NSString *mode = _routerSummary.routerMode.lowercaseString;
    return [mode isEqualToString:@"re"];
}

-(BOOL)isDisconnected{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    ConnectionStatusType connectionStat = [ConnectionStatus getConnectionStatus];
    return [toolkit connectionStatusFromNetworkState:connectionStat] == SFIAlmondConnectionStatus_disconnected;
}

-(int)getSettingsRowHeight{
    NSArray *msgs = [self getWirelessSettingsSummary];
    int lines = (int)[SFICardView getLineCount:msgs];
    NSLog(@"lines: %d", lines);
    return settingsHeight + (lines * 14);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isFirmwareCompatible] == NO){
        tableView.scrollEnabled = NO;
        return [self createAlmondUpdateAvailableCell:tableView];
    }
    
    if([self isNoAlmondLoaded]){
        tableView.scrollEnabled = NO;
        return [self createNoAlmondCell:tableView];
    }else if(self.isAlmondUnavailable || [self isDisconnected]){
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
            case DEF_MESH_SECTION:{
                if([self isAL3])
                    return [self createAlmondNetworkCell:tableView];
                else{
                    return [self createZeroCell:tableView];
                }
                
            }
            case DEF_ADVANCED_ROUTER_SECTION:{
                if(_enableAdvRouter){
                    
                    NSArray *summary = @[NSLocalizedString(@"learn_adv_features", @"")];
                    return [self createSummaryCell:tableView summaries:summary title:NSLocalizedString(@"adv_router_features", @"") selector:@selector(onAdvancdFeatures:) cardColor:[SFIColors ruleBlueColor]];
                }
                else{
                    return [self createZeroCell:tableView];
                }
            }
            case DEF_WIRELESS_SECTION:{
                summaries = [self getWirelessSettingsSummary];
                return [self createSummaryCell:tableView summaries:summaries title:NSLocalizedString(@"router.card-title.Wireless Settings", @"Wireless Settings") selector:@selector(onEditWirelessSettingsCard:) cardColor:[UIColor securifiRouterTileSlateColor]];
            }
            case DEF_ROUTER_VERSION_SECTION:{
                NSString *title = NSLocalizedString(@"router.software-version-new.title.Software Version", @"Software Version");
                
                if(self.newAlmondFirmwareVersionAvailable)
                    [title stringByAppendingString:@" *"];
                summaries = [self getRouterVersionSummary];
                SFICardViewSummaryCell *cell = (SFICardViewSummaryCell *)[self createSummaryCell:tableView summaries:summaries title:title selector:nil cardColor:[UIColor securifiRouterTileYellowColor]];
                if(self.newAlmondFirmwareVersionAvailable)
                    [self addButton:cell buttonLabel:NSLocalizedString(@"UPDATE FIRMWARE", @"UPDATE FIRMWARE") selector:@selector(onFirmwareUpdate:) frameHeight:versionHeight];
                return cell;
            }
                
            case DEF_ROUTER_REBOOT_SECTION:{
                summaries = [self getRebootSummary];
                SFICardViewSummaryCell *cell = (SFICardViewSummaryCell *)[self createSummaryCell:tableView summaries:summaries title:NSLocalizedString(@"reboot router", @"Router Reboot") selector:nil cardColor:[UIColor securifiRouterTileRedColor]];
                [self addButton:cell buttonLabel:NSLocalizedString(@"REBOOT NOW", @"REBOOT NOW") selector:@selector(onRebootButtonPressed:) frameHeight:rebootHeight];
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

- (void)onAdvancdFeatures:(id)sender{
    NSLog(@"onAdvncdFeatures");
    AdvanceRouterSettingsController *ctrl = [[UIStoryboard storyboardWithName:@"Router" bundle:nil] instantiateViewControllerWithIdentifier:@"AdvanceRouterSettingsController"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
}

-(UITableViewCell *)createZeroCell:(UITableView *)tableView{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(UITableViewCell *)createAlmondNetworkCell:(UITableView *)tableView{
    NSLog(@"almond network cell");
    NSString *const cell_id = @"almond_network";
    
    AlmondNetworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[AlmondNetworkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    cell.delegate = self;
    [cell markReuse];
    NSArray *almonds = [self getAlmondTitles];
    [cell setHeading:@"Almond Network" titles:almonds almCount:almonds.count];
    //    [cell setHeading:@"Almond Network" titles:@[@"almond 1"] almCount:1];
    
//    [cell createAlmondNetworkView]; //moved inside layout subviews
    return cell;
}

-(NSArray *)getAlmondTitles{
    NSMutableArray *titles = [NSMutableArray new];
    for(NSDictionary *dict in self.routerSummary.almondsList){
        [titles addObject:dict[NAME]];
    }
    return titles;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([self isNoAlmondLoaded])
        return 0;
    else if(section == DEF_ADVANCED_ROUTER_SECTION && self.enableAdvRouter == NO)
        return 0;
    else if(section == DEF_MESH_SECTION && ![self isAL3])
        return 0;
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

#pragma mark cell data methods
-(NSArray*)getNetworkSummary{
    //NSLog(@"self.routersummery.url: %@", self.routerSummary.url);
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondLocalNetworkSettings *settings = [LocalNetworkManagement localNetworkSettingsForAlmond:toolkit.currentAlmond.almondplusMAC];
    NSString *host;
    NSString *login;
    if(self.currentConnectionMode == SFIAlmondConnectionMode_local){
        host = settings.host? settings.host: @"";
        login = settings.login? settings.login: @"";
    }else{
        host = self.routerSummary.url ? self.routerSummary.url : @"";
        login = self.routerSummary.login ? self.routerSummary.login : @"";
    }
    
    return @[
             [NSString stringWithFormat:NSLocalizedString(@"router.summary.IP Address : %@", @"IP Address"), host],
             [NSString stringWithFormat:NSLocalizedString(@"router.summary.Admin Login : %@", @"Admin Login"), login],
             ];
    
}

-(NSArray*)getWirelessSettingsSummary{
    //NSLog(@"getWirelessSettingsSummary");
    NSMutableArray *summary = [NSMutableArray array];
    
    if(self.routerSummary){
        for (SFIWirelessSummary *sum in self.routerSummary.wirelessSummaries) {
            NSString *enabled = sum.enabled ? NSLocalizedString(@"enabled", @"enabled") : NSLocalizedString(@"disabled", @"disabled");
            [summary addObject:[NSString stringWithFormat:NSLocalizedString(@"ssid_is",@"%@ is %@"), sum.ssid, enabled]];
        }
    }else{
        return @[NSLocalizedString(@"Settings are not available.", @"Settings are not available.")];
    }
    NSLog(@"wireless summary: %@", summary);
    return summary;
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
    return @[[NSString stringWithFormat:NSLocalizedString(@"router.Sends %@'s logs to our server", @"Sends %@'s logs to our server"),[CommonMethods getShortAlmondName: self.currentAlmond.almondplusName]]];
}


-(BOOL)isNotConnectedToCloud{
    if ([self isNoAlmondLoaded] || self.isAlmondUnavailable || [self isDisconnected]) {
        return YES;
    }
    return NO;
}

- (BOOL)isNoAlmondLoaded {
    return [self.almondMac isEqualToString:NO_ALMOND];
}


-(void)addButton:(SFICardViewSummaryCell*)cell buttonLabel:(NSString *)label selector:(SEL)selectorMethod frameHeight:(int)frameHeight{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 160, frameHeight - 25, 140, 20)];
    button.enabled = YES;
    button.titleLabel.font = [UIFont standardUIButtonFont];
    
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor whiteColor],
                             NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:label attributes:attrs];
    [button setAttributedTitle:attrStr forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentRight;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:selectorMethod forControlEvents:UIControlEventTouchUpInside];
    
    [cell.cardView addSubview:button];
}


- (UITableViewCell *)createNoAlmondCell:(UITableView *)tableView {
    NSString *const cell_id = @"NoAlmondCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        MessageView *view = [self addMessagegView];
        
        [cell addSubview:view];
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
    NSLog(@"n/w summary cell reused");
    [cell markReuse];
    
    cell.cardView.rightOffset = SFICardView_right_offset_inset;
    cell.cardView.backgroundColor = color;
    cell.title = title;
    
    cell.summaries = summaries;
    cell.editTarget = self;
    cell.editSelector = selector;
    NSLog(@"before cell return");
    return cell;
}

#pragma mark internal event handlers

- (void)onEditNetworkSettings:(id)sender {
    [self presentLocalNetworkSettingsEditor];
}

- (void)onEditWirelessSettingsCard:(id)sender {
    self.isBUG = YES;
    [self showHudWithTimeout:NSLocalizedString(@"Loading router data", @"Loading router data")];
    [RouterPayload getWirelessSettings:mii mac:self.almondMac];
}

-(void)onFirmwareUpdate:(id)sender{
    [self createAlertViewForTitle:NSLocalizedString(@"router Are you sure, you want to Update Firmware?", @"") otherTitle:NSLocalizedString(@"Update","") tag:FIRMWARE_UPDATE_TAG];
}

-(void)onRebootButtonPressed:(id)sender{
    [self createAlertViewForTitle:NSLocalizedString(@"router Are you sure, you want to Reboot?", @"") otherTitle:NSLocalizedString(@"router Reboot","") tag:REBOOT_TAG];
}

-(void)onLogsCard:(id)sender{
    if (self.navigationController.topViewController == self) {
        SFILogsViewController *ctrl = [SFILogsViewController new];
        ctrl.title = self.navigationItem.title;
        UINavigationController *nctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:nctrl animated:YES completion:nil];
        });
    }
}

-(void)createAlertViewForTitle:(NSString*)title otherTitle:(NSString*)otherTitle tag:(int)tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"cancel","Cancel")
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
            [self showHudWithTimeoutFirmwareMsg: NSLocalizedString(@"Firmware update is in progress, it may take a while. Meanwhile, please don't turn off your Almond",@"")];
            [RouterPayload updateFirmware:mii version:self.latestAlmondVersionAvailable mac:self.almondMac];
        }else if(alertView.tag == REBOOT_TAG){
            [self showHUD:NSLocalizedString(@"router.hud.Router is rebooting.", @"Router is rebooting.")];
            self.isRebooting = TRUE;
            [RouterPayload routerReboot:mii mac:self.almondMac];
        }
    }
}

#pragma mark - Cloud command response handlers
- (void)onAlmondRouterCommandResponse:(id)sender {
    NSLog(@"Router - onAlmondRouterCommandResponse");
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
            //NSLog(@"self.isalmondunavailable: %d", self.isAlmondUnavailable);
            if(genericRouterCommand.commandType == SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE){
                [self showToast:NSLocalizedString(@"Router Sorry!, Unable to update.", @" Sorry!, Unable to update.")];
            }
            [self.HUD hide:YES];
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
            return;
        }
        //NSLog(@"genericcommdntype: %d", genericRouterCommand.commandType);
        switch (genericRouterCommand.commandType) {
            case SFIGenericRouterCommandType_WIRELESS_SUMMARY: {
                //NSLog(@"SFIGenericRouterCommandType_WIRELESS_SUMMARY - router summary");
                self.routerSummary = (SFIRouterSummary *)genericRouterCommand.command;
                //NSLog(@"routersummary: %@", self.routerSummary);
                
                if(self.currentConnectionMode == SFIAlmondConnectionMode_cloud){ //Do only in Cloud
                    NSLog(@"updating local network settings");
                    [LocalNetworkManagement tryUpdateLocalNetworkSettingsForAlmond:toolkit.currentAlmond.almondplusMAC withRouterSummary:self.routerSummary];
                    NSString *currentVersion = self.routerSummary.firmwareVersion;
                    [self tryCheckAlmondVersion:currentVersion];
                }
                
                break;
            }
            case SFIGenericRouterCommandType_WIRELESS_SETTINGS: {
                NSArray *settings = genericRouterCommand.command;
                if (self.currentConnectionMode == SFIAlmondConnectionMode_local) {
                    // protect against race condition: mode changed before this callback was received
                    // do not show settings UI when the connection mode is local;
                    break;
                }
                
                
                if (self.navigationController.topViewController == self  && self.isBUG) {
                    NSLog(@"cloud settings: %@", settings);
                    SFIRouterSettingsTableViewController *ctrl = [SFIRouterSettingsTableViewController new];
                    //                    ctrl.title = self.navigationItem.title;
                    ctrl.wirelessSettings = settings;
                    ctrl.almondMac = self.almondMac;
                    BOOL enableSwitch = YES;
                    if([self isAL3]){
                        if(self.routerSummary.almondsList.count > 1)//has slaves
                            enableSwitch = NO;
                    }
                    ctrl.enableRouterWirelessControl = enableSwitch;
                    ctrl.isREMode = [self isInREMode];
                    ctrl.hidesBottomBarWhenPushed = YES;
                    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                                   initWithTitle:NSLocalizedString(@"Router Back", @"Back")
                                                   style:UIBarButtonItemStylePlain
                                                   target:nil
                                                   action:nil];
                    self.navigationItem.backBarButtonItem = backButton;
                    [self.navigationController pushViewController:ctrl animated:YES];
                }
                break;
            }
            case SFIGenericRouterCommandType_UPDATE_FIRMWARE_RESPONSE: {
                //NSLog(@"firmware update response");
                
                //                unsigned int percentage = genericRouterCommand.completionPercentage;
                //                if (percentage > 0) {
                //                    NSString *msg = NSLocalizedString(@"router.hud.Updating router firmware.", @"Updating router firmware.");
                //                    msg = [msg stringByAppendingFormat:@" (%i%%)", percentage];
                //
                //                    [self showToast:msg];
                //                }
                return; // to by-pass hud hide.
                
                break;
            };
                
            case SFIGenericRouterCommandType_REBOOT: {
                BOOL wasRebooting = self.isRebooting;
                self.isRebooting = NO;
                // protect against the cloud sending the same response more than once
                if (wasRebooting) {
                    [RouterPayload routerSummary:mii mac:self.almondMac];
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
    //NSLog(@"current version: %@, latest version: %@", currentVersion, latestAlmondVersion);
    
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

#pragma mark - TableHeaderViewDelegate methods

- (void)dismissHeaderView:(TableHeaderView *)view {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [UIView animateWithDuration:0.75 animations:^() {
            self.tableView.tableHeaderView = nil;
        }];
    });
}

-(void )onClientResponse:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil || [data valueForKey:@"data"]==nil ) {
        return;
    }
    
    NSDictionary *mainDict = [data valueForKey:@"data"];
    
    if([[mainDict valueForKey:COMMAND_TYPE] isEqualToString:CLIENTLIST])
        dispatch_async(dispatch_get_main_queue(), ^() {
            NSLog(@"onClientResponse");
            [self.tableView reloadData];
        });
}

#pragma mark mesh command resposne
 - (void)onRouterPageCommandResponse:(id)sender{
     NSLog(@"onRouterPageCommandResponse");
     NSDictionary *payload = [self getPayload:sender];
     if(payload == nil) return;
     
     NSLog(@"router mesh payload: %@", payload);
     if(![payload[COMMAND_MODE] isEqualToString:@"Reply"])
         return;
     
     BOOL isSuccessful = [payload[SUCCESS] boolValue];
     NSString *commandType = payload[COMMAND_TYPE];
     if(isSuccessful){
         if([commandType  isEqualToString:@"SlaveDetailsMobile"]){
             MeshSetupViewController *ctrl = [self getMeshController:@"MeshSetupViewController" isStatView:YES];
             [AlmondStatus updateSlaveStatus:payload routerSummary:self.routerSummary slaveStat:self.slaveStatus];
             if([AlmondStatus hasCompleteDetails:self.slaveStatus] == NO){
                 return;
             }
             NSLog(@"hasCompleteDetails");
             [self presentController:self.slaveStatus ctrl:ctrl];
         }
         else if([commandType  isEqualToString:@"Rai2UpMobile"]){
             if(self.isAlmDetailView){
                 NSDictionary *slaveDict = self.routerSummary.almondsList[_almCount];
                 [MeshPayload requestSlaveDetails:mii
                                  slaveUniqueName:slaveDict[SLAVE_UNIQUE_NAME]
                                        almondMac:[[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC];

             }else{
                 MeshSetupViewController *ctrl = [self getMeshController:@"MeshSetupAdding" isStatView:NO];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self presentViewController:ctrl animated:YES completion:nil];
                 });
             }
         }
     }
     else{
         [self showToast:@"Sorry! Please try after sometime."];
     }
     dispatch_async(dispatch_get_main_queue(), ^{
         [self.HUD hide:YES];
     });
 }

- (void)onRouterPageMeshCommandResponse:(id)sender{
    NSLog(@"onRouterPageMeshCommandResponse");
    [self onRouterPageCommandResponse:sender];
}

- (NSDictionary *)getPayload:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    if (data == nil || [data valueForKey:@"data"]==nil ) {
        return nil;
    }
    NSDictionary *payload;
    if([[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_local){
        payload = data[@"data"];
    }else{
        payload = [data[@"data"] objectFromJSONData];
    }
    return payload;
}

#pragma mark almondnetworkcelldelegate methods
 -(void)onAlmondTapDelegate:(int)almondCount{
     NSLog(@"onAlmondTapDelegate");
     //master - straight forward assemble data and send
     if(almondCount == 0){
         MeshSetupViewController *ctrl = [self getMeshController:@"MeshSetupViewController" isStatView:YES];
         [self presentController:[AlmondStatus getMasterAlmondStatus:self.routerSummary] ctrl:ctrl];
     }else{
         self.isAlmDetailView = YES;
         self.almCount = almondCount;
         
         
         if([[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_local)
             [[SecurifiToolkit sharedInstance] connectMesh];
         else{
             NSDictionary *slaveDict = self.routerSummary.almondsList[almondCount];
             [MeshPayload requestSlaveDetails:mii
                              slaveUniqueName:slaveDict[SLAVE_UNIQUE_NAME]
                                    almondMac:[[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC];
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [self showHudWithTimeout:@"Requesting...Please Wait!"];
         });
     }
 }

-(MeshSetupViewController *)getMeshController:(NSString *)identifier isStatView:(BOOL)isStatView{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mesh" bundle:nil];
    MeshSetupViewController *meshController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    meshController.isStatusView = isStatView;
    return meshController;
}

-(void)presentController:(AlmondStatus *)statObj ctrl:(MeshSetupViewController *)ctrl{
    ctrl.almondStatObj = statObj;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:ctrl animated:YES completion:nil];
    });
}

-(void)onAddAlmondTapDelegate{
    NSLog(@"on add almond tap delegate");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showHudWithTimeout:@"Please Wait!"];
        self.isAlmDetailView = NO;
    });
    if([[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_local)
        [[SecurifiToolkit sharedInstance] connectMesh]; //this will at end point on connection estb. sends rai2up
    else
        [[SecurifiToolkit sharedInstance] asyncSendToNetwork:[GenericCommand requestRai2UpMobile:[SecurifiToolkit sharedInstance].currentAlmond.almondplusMAC]];
    
}

@end
