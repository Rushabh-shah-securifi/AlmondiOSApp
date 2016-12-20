//
//  DeviceListController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

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
#import "MBProgressHUD.h"
#import "UIViewController+Securifi.h"
#import "SFIPreferences.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "CommonMethods.h"
#import "HelpCenter.h"
#import "ParentalControlsViewController.h"
#import "RecentSearchDB.h"
#import "ConnectionStatus.h"
#import "HTTPRequest.h"
#import "AlmondManagement.h"
#import "IoTDeviceViewController.h"

#define NO_ALMOND @"NO ALMOND"
#define CELLFRAME CGRectMake(5, 0, self.view.frame.size.width -10, 60)
#define CELL_IDENTIFIER @"device_cell"
#define HEADER_FONT_SIZE 16
#define COUNT_FONT_SIZE 12

@interface DeviceListController ()<UITableViewDataSource,UITableViewDelegate,DeviceHeaderViewDelegate>

@property(nonatomic, readonly) SFIColors *almondColor;
@property(nonatomic) NSTimer *mobileCommandTimer;
@property(nonatomic) SecurifiToolkit *toolkit;
@property(nonatomic) BOOL isSiteMapSupport;
@property(nonatomic) BOOL isLocal;
@end

@implementation DeviceListController
int mii;

- (void)viewDidLoad {
    NSLog(@"devicelist - viewDidLoad");
    [super viewDidLoad];
    self.toolkit = [SecurifiToolkit sharedInstance];
    if([self.toolkit isScreenShown:@"devices"] == NO)
        [self initializeHelpScreensfirst:@"Devices"];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   /* [RecentSearchDB insertInRecentDB:@"aaa" cmac:@"111" amac:@"222"];
    [RecentSearchDB insertInRecentDB:@"bbb" cmac:@"111" amac:@"222"];
    [RecentSearchDB insertInRecentDB:@"ccc" cmac:@"111" amac:@"222"];
    NSLog(@"recent seaech count = %d",[RecentSearchDB GetHistoryDatabaseCount:@"222" clientMac:@"111"]);
    
    NSLog(@"recent = %@",[RecentSearchDB getAllRecentwithLimit:1 almonsMac:@"222" clientMac:@"111"]);*/
    
    //ensure list is empty initially
    [self initializeAlmondData];
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"devicelist viewWillAppear");
    [super viewWillAppear:YES];
    mii = arc4random() % 10000;
    [self markAlmondTitleAndMac];
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
      self.isLocal = [self.toolkit useLocalNetwork:almond.almondplusMAC];
    
    NSLog(@"View will appear is called in DeviceListController");
    [self initializeNotifications];
    
    
    [self tryShowLoadingDevice];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

-(void)tryShowLoadingDevice{
    if([self isDeviceListEmpty] && [self isClientListEmpty] && ![self isNoAlmondMAC] && ![self isDisconnected] && [self isFirmwareCompatible]){
        NSLog(@"tryShowLoadingDevice");
        [self showHudWithTimeoutMsg:@"Loading Device data..."];
    }
}

-(BOOL)isDisconnected{
    return [_toolkit connectionStatusFromNetworkState:[ConnectionStatus getConnectionStatus]] == SFIAlmondConnectionStatus_disconnected;
}

-(void)markAlmondTitleAndMac{
    NSLog(@"%s, self.toolkit.currentAlmond: %@", __PRETTY_FUNCTION__, [AlmondManagement currentAlmond]);
    _isSiteMapSupport = [[AlmondManagement currentAlmond] siteMapSupportFirmware:[AlmondManagement currentAlmond].firmware] && self.toolkit.configuration.siteMapEnable;
   
    if ([AlmondManagement currentAlmond] == nil) {
        NSLog(@"no almond");
        [self markNewTitle:NSLocalizedString(@"router.nav-title.Get Started", @"Get Started")];
        [self markAlmondMac:NO_ALMOND];
    }
    else {
        NSLog(@"got almond");
        [self markNewTitle:[AlmondManagement currentAlmond].almondplusName];
        [self markAlmondMac:[AlmondManagement currentAlmond].almondplusMAC];
    }
}

-(void)initializeAlmondData{
    NSLog(@"initialize almond data");
    [self markAlmondTitleAndMac];
    [self initializeColors:[AlmondManagement currentAlmond]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self tryInstallRefreshControl];
        if([self isDeviceListEmpty] && [self isClientListEmpty] && ![self isNoAlmondMAC] && ![self isDisconnected]){
            NSLog(@"device and client current list is empty");
            [self showHudWithTimeoutMsg:@"Loading Device data..."];
        }
    });
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializeNotifications{
    NSLog(@"initialize notifications sensor table");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onDeviceListAndDynamicResponseParsed:) //for both sensors and clients
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onUpdateDeviceIndexResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER // for toggle
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
               selector:@selector(validateResponseCallback:)
                   name:VALIDATE_RESPONSE_NOTIFIER
                 object:nil];
}

#pragma mark - HUD and Toast mgt
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg {
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:10];
    });
}

#pragma mark - State
- (BOOL)isDeviceListEmpty {
    // don't show any tiles until there are values for the devices; no values == no way to fetch from almond
    return self.toolkit.devices.count == 0;
}

-(BOOL)isClientListEmpty{
    return self.toolkit.clients.count == 0;
}

- (BOOL)isNoAlmondMAC {
    return [self.almondMac isEqualToString:NO_ALMOND];
}

#pragma mark refresh control
// controls installation and removal of refresh control
- (void)tryInstallRefreshControl {
    NSLog(@"tryInstallRefreshControl");
    if ([self isDeviceListEmpty] && [self isClientListEmpty]) {
        // Disable refresh when no devices to refresh
        self.refreshControl = nil;
    }
    else {
        // Pull down to refresh device values
        UIRefreshControl *refresh = [UIRefreshControl new];
        NSDictionary *attributes = self.navigationController.navigationBar.titleTextAttributes;
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"deviceList Force device data refresh", @"Force device data refresh") attributes:attributes];
        [refresh addTarget:self action:@selector(onRefreshSensorData:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    self.isLocal = [self.toolkit useLocalNetwork:almond.almondplusMAC];
    if ([self isNoAlmondMAC] || ![self isFirmwareCompatible] || [self isDisconnected])
        return 1;
    
    if([self isDeviceListEmpty] && [self isClientListEmpty])
        return 1;
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isNoAlmondMAC] || ([self isDeviceListEmpty] && [self isClientListEmpty]) || ![self isFirmwareCompatible] || [self isDisconnected])
        return 1;
    
    NSLog(@"devices count %ld, client count: %ld",(unsigned long)self.toolkit.devices.count, (unsigned long)self.toolkit.clients.count);
    return (section == 0) ? self.toolkit.devices.count: self.toolkit.clients.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isNoAlmondMAC] || ([self isDeviceListEmpty] && [self isClientListEmpty]) || ![self isFirmwareCompatible] || [self isDisconnected]) {
        return 400;
    }
    return 85;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self showNeedsActivationHeader] && section == 0) {
        return 100;
    }
    if ([self isNoAlmondMAC] || [self isDisconnected])
        return 0;
    
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([self showNeedsActivationHeader] && section == 0) {
        return [self createActivationNotificationHeader];
    }
    else if ([self isNoAlmondMAC] || ([self isDeviceListEmpty] && [self isClientListEmpty]) || ![self isFirmwareCompatible] || [self isDisconnected])
        return [UIView new];
    
    return [self deviceHeader:section tableView:tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"Did Scroll");
    if([self.toolkit isScreenShown:@"wifitrigger"] == NO)
        [self initializeWiFiPresence];
    
}

-(UIView*)deviceHeader:(NSInteger)section tableView:(UITableView*)tableView{
    NSString *header,*headerVal;
    if(section == 0){
        header = NSLocalizedString(@"Smart Devices", @"Smart Devices");
        headerVal = [NSString stringWithFormat:@"(%ld)",(long int)self.toolkit.devices.count];
    }
    else{
        //headerVal = [NSString stringWithFormat:@"(%ld )",(long int)self.toolkit.clients.count];
         headerVal = [NSString stringWithFormat:@"(%d Active)",[Client activeClientCount]];
        header =  NSLocalizedString(@"deviceList Network Devices", @"Network Devices");
    }
    
    NSMutableAttributedString *aAttrString = [CommonMethods getAttributeString:header fontSize:HEADER_FONT_SIZE LightFont:NO];
    NSMutableAttributedString *vAttrString = [CommonMethods getAttributeString:headerVal fontSize:COUNT_FONT_SIZE LightFont:NO];
    [aAttrString appendAttributedString:vAttrString];
    static NSString *headerView = @"customHeader";
    UITableViewHeaderFooterView *vHeader;
    //    vHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerView];
    //    if (!vHeader) {
    vHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerView];
    //    }
    vHeader.textLabel.textColor = [UIColor lightGrayColor];
    vHeader.textLabel.attributedText = aAttrString;
    
    return vHeader;
}



- (BOOL)showNeedsActivationHeader {
    BOOL isAccountActivated = [[SecurifiToolkit sharedInstance] isAccountActivated];
    if (!isAccountActivated) {
        BOOL notificationSet = [[SFIPreferences instance] isLogonAccountAccountNotificationSet];
        if (notificationSet) {
            return YES;
        }
    }
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"self.almond mac: %@", self.almondMac);
    if([self isFirmwareCompatible] == NO){
        tableView.scrollEnabled = NO;
        return [self createAlmondUpdateAvailableCell:tableView];
    }
    if ([self isNoAlmondMAC]) {
        tableView.scrollEnabled = NO;
        return [self createNoAlmondCell:tableView];
    }
    if([self isDisconnected]){
        tableView.scrollEnabled = NO;
        return [self createAlmondOfflineCell:tableView];
    }
    
    if ([self isDeviceListEmpty] && [self isClientListEmpty]) {
        tableView.scrollEnabled = NO;
        return [self createEmptyCell:tableView];
    }
    
    tableView.scrollEnabled = YES;
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.commonView.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    GenericParams *genericParams;
    
    if(indexPath.section == 0){
        if(indexPath.row  > (int)self.toolkit.devices.count - 1){
            NSLog(@"device removed");
            return cell;
        }
        Device *device = [self.toolkit.devices objectAtIndex:indexPath.row];
        
        genericParams = [[GenericParams alloc]initWithGenericIndexValue:[GenericIndexUtil getHeaderGenericIndexValueForDevice:device]
                                                         indexValueList:nil
                                                             deviceName:device.name
                                                                  color:[self.almondColor makeGradatedColorForPositionIndex:indexPath.row]
                                                               isSensor:YES];
        
        [cell.commonView initialize:genericParams cellType:SensorTable_Cell isSiteMap:self.isSiteMapSupport];
    }
    else
    {
        if(indexPath.row  > (int)self.toolkit.clients.count - 1){
            NSLog(@"client removed");
            return cell;
        }
        Client *client = [self.toolkit.clients objectAtIndex:indexPath.row];
        
        UIColor *clientCellColor = [SFIColors getClientCellColor:client];
        genericParams = [[GenericParams alloc]initWithGenericIndexValue:[GenericIndexUtil getClientHeaderGenericIndexValueForClient:client]
                                                         indexValueList:nil
                                                             deviceName:client.name
                                                                  color:clientCellColor
                                                               isSensor:NO];
       
        [cell.commonView initialize:genericParams cellType:ClientTable_Cell isSiteMap:self.isSiteMapSupport];
    }
    return cell;
}


- (UITableViewCell *)createNoAlmondCell:(UITableView *)tableView {
    NSLog(@"No almond cell");
    static NSString *no_almond_cell_id = @"NoAlmondCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:no_almond_cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:no_almond_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        MessageView *view = [self addMessagegView];
        
        [cell addSubview:view];
    }
    
    return cell;
}


- (UIView *)createActivationNotificationHeader {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(5, 0, self.tableView.frame.size.width, 100)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, self.tableView.frame.size.width - 35, 1)];
    imgLine1.image = [UIImage imageNamed:@"grey_line"];
    
    UIImageView *imgCross = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 28, 12, 18, 18)];
    imgCross.image = [UIImage imageNamed:@"cross_icon"];
    
    [view addSubview:imgCross];
    
    UIButton *btnCloseNotification = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCloseNotification.frame = CGRectMake(self.tableView.frame.size.width - 50, 10, 50, 50);
    btnCloseNotification.backgroundColor = [UIColor clearColor];
    [btnCloseNotification addTarget:self action:@selector(onCloseNotificationClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnCloseNotification];
    
    UILabel *lblConfirm = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, self.tableView.frame.size.width - 15, 20)];
    lblConfirm.font = [UIFont securifiBoldFont:13];
    lblConfirm.textColor = [UIColor colorWithRed:(CGFloat) (119 / 255.0) green:(CGFloat) (119 / 255.0) blue:(CGFloat) (119 / 255.0) alpha:1.0];
    lblConfirm.textAlignment = NSTextAlignmentCenter;
    
    int minsRemainingForUnactivatedAccount = [[SecurifiToolkit sharedInstance] minsRemainingForUnactivatedAccount];
    
    if (minsRemainingForUnactivatedAccount <= 1440) {
        lblConfirm.text = NSLocalizedString(@"sensors.account-confirm.label.Please confirm your account (less than a day left).", @"Please confirm your account (less than a day left).");
    }
    else {
        int daysRemaining = minsRemainingForUnactivatedAccount / 1440;
        lblConfirm.text = [NSString stringWithFormat:NSLocalizedString(@"sensors.account-confirm.label.Please confirm your account (%d days left).", @"Please confirm your account (%d days left)."), daysRemaining];
    }
    
    UILabel *lblInstructions = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, self.tableView.frame.size.width - 20, 20)];
    lblInstructions.font = [UIFont securifiBoldFont:13];
    lblInstructions.textColor = [UIColor colorWithRed:(CGFloat) (119 / 255.0) green:(CGFloat) (119 / 255.0) blue:(CGFloat) (119 / 255.0) alpha:1.0];
    lblInstructions.textAlignment = NSTextAlignmentCenter;
    lblInstructions.text = NSLocalizedString(@"sensors.account-confirm.label.Check activation email for instructions.", @"Check activation email for instructions.");
    
    UIImageView *imgMail = [[UIImageView alloc] initWithFrame:CGRectMake(80, 75, 22, 16)];
    imgMail.image = [UIImage imageNamed:@"Mail_icon.png"];
    [view addSubview:imgMail];
    
    UIButton *btnResendActivationMail = [UIButton buttonWithType:UIButtonTypeCustom];
    btnResendActivationMail.frame = CGRectMake(50, 55, self.tableView.frame.size.width - 90, 40);
    btnResendActivationMail.backgroundColor = [UIColor clearColor];
    [btnResendActivationMail addTarget:self action:@selector(onResendActivationClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnResendActivationMail];
    
    UILabel *lblResend = [[UILabel alloc] initWithFrame:CGRectMake(32, 75, self.tableView.frame.size.width - 20, 20)];
    lblResend.font = [UIFont securifiBoldFont:13];
    lblResend.textColor = [UIColor colorWithRed:(CGFloat) (0 / 255.0) green:(CGFloat) (173 / 255.0) blue:(CGFloat) (226 / 255.0) alpha:1.0];
    lblResend.textAlignment = NSTextAlignmentCenter;
    lblResend.text = NSLocalizedString(@"sensors.account-confirm.label.Resend activation email", @"Resend activation email");
    
    UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 95, self.tableView.frame.size.width - 35, 1)];
    imgLine2.image = [UIImage imageNamed:@"grey_line.png"];
    
    [view addSubview:imgLine1];
    [view addSubview:lblConfirm];
    [view addSubview:lblInstructions];
    [view addSubview:lblResend];
    [view addSubview:imgLine2];
    
    return view;
}

#pragma mark - Class Methods
- (void)initializeColors:(SFIAlmondPlus *)almond {
    NSUInteger colorCode = (NSUInteger) almond.colorCodeIndex;
    _almondColor = [SFIColors colorForIndex:colorCode];
}

#pragma mark sensor cell(DeviceHeaderView) delegate
-(void)delegateDeviceSettingButtonClick:(GenericParams*)genericParams{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
        DeviceEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DeviceEditViewController"];
        viewController.genericParams = genericParams;
        [self.navigationController pushViewController:viewController animated:YES];
    });
}

-(void)toggle:(GenericIndexValue *)genericIndexValue{
    dispatch_async(dispatch_get_main_queue(), ^() {
        //todo decide what to do about this
        [self.mobileCommandTimer invalidate];
        
        self.mobileCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                   target:self
                                                                 selector:@selector(onToggleTimeout:)
                                                                 userInfo:nil
                                                                  repeats:NO];
    });
    [DevicePayload getSensorIndexUpdate:genericIndexValue mii:mii];
}



- (void)onToggleTimeout:(id)sender {
    [self.mobileCommandTimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
        //[self.HUD hide:YES];
    });
}

#pragma mark clientCell delegate

-(void)delegateClientSettingButtonClick:(GenericParams*)genericParams{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
    ClientPropertiesViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ClientPropertiesViewController"];
    viewController.genericParams = genericParams;
    viewController.isInitialized = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark command responses
-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"devicelist - onDeviceListAndDynamicResponseParsed");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
        [self.HUD hide:YES];
        if(self.refreshControl == nil){
            [self tryInstallRefreshControl];
        }else{
            [self.refreshControl endRefreshing];
        }
    });
}

-(void)onUpdateDeviceIndexResponse:(id)sender{ //mobile command
    NSLog(@"onUpdateDeviceIndexResponse");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    BOOL local = [self.toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"devicelistcontroller - mobile - payload: %@", payload);
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    if(isSuccessful == NO){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self showToast:NSLocalizedString(@"DeviceList Sorry, Could not update!", @"Sorry, Could not update!")];
        });
    }else{
        [self showToast:NSLocalizedString(@"successfully_updated", @"")];
    }
}

#pragma mark cloud callbacks
- (void)onCurrentAlmondChanged:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
//    if(self.toolkit.devices!=nil)
//        [self.toolkit.devices removeAllObjects];
//    if(self.toolkit.clients!=nil)
//        [self.toolkit.clients removeAllObjects];
    [self initializeAlmondData];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
    //you dont have to send request, toolkit is sending it already
}

- (void)onAlmondListDidChange:(id)sender {
    NSLog(@"%s 1", __PRETTY_FUNCTION__);
    if (!self) {
        return;
    }
    NSLog(@"%s 2", __PRETTY_FUNCTION__);
    [self initializeAlmondData];
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self || !self.isViewLoaded) {
            return;
        }
        NSLog(@"%s 3", __PRETTY_FUNCTION__);
        
        [self.tableView reloadData];
    });
}

- (void)onRefreshSensorData:(id)sender {
    if (!self || [self isNoAlmondMAC]) {
        return;
    }
    
    //request client list
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.refreshControl endRefreshing];
    });
    [DevicePayload deviceListCommand];
    [ClientPayload clientListCommand];
}

#pragma mark - Activation Notification Header

- (void)onCloseNotificationClicked:(id)sender {
    DLog(@"onCloseNotificationClicked");
    [[SFIPreferences instance] dismissLogonAccountActivationNotification];
    [self.tableView reloadData];
}

- (void)onResendActivationClicked:(id)sender {
    //Send activation email command
    DLog(@"onResendActivationClicked");
    [self sendReactivationRequest];
}

- (void)sendReactivationRequest {
    NSString *email = [[SecurifiToolkit sharedInstance] loginEmail];
    if (email.length == 0) {
        return;
    }
    
    HTTPRequest *request = [HTTPRequest new];
    [request sendAsyncHTTPRequestResendActivationLink:email];
}

- (void)validateResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    NSString *failureReason;
    NSLog(@"validate payload: %@", data);
    BOOL isSuccessful = [data[@"success"] boolValue];
    if (isSuccessful == NO) {
        failureReason = NSLocalizedString(@"Sorry! Cannot send reactivation link", @"Sorry! The reactivation link cannot be \nsent at the moment. Try again later.");
        [self showToast:failureReason];
    }
    else {
        [self showToast:NSLocalizedString(@"activation.toast.Reactivation link sent to your registerd email ID.", @"Reactivation link sent to your registerd email ID.")];
    }
    
//    ValidateAccountResponse *obj = (ValidateAccountResponse *) [data valueForKey:@"data"];
//    
//    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
//    DLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);
//    
//    if (obj.isSuccessful) {
//        [self showToast:NSLocalizedString(@"activation.toast.Reactivation link sent to your registerd email ID.", @"Reactivation link sent to your registerd email ID.")];
//    }
//    else {
//        //Reason Code
//        NSString *failureReason;
//        switch (obj.reasonCode) {
//            case 1:
//                failureReason = NSLocalizedString(@"no_username_found", @"The username was not found");
//                break;
//            case 2:
//                failureReason = NSLocalizedString(@"The account is already validated", @"The account is already validated");
//                break;
//            case 4:
//                failureReason = NSLocalizedString(@"The email ID is invalid.", @"The email ID is invalid.");
//                break;
//            case 3:
//            case 5:
//            default:
//                failureReason = NSLocalizedString(@"Sorry! Cannot send reactivation link", @"Sorry! Cannot send reactivation link");
//                break;
//        }
//        
//        [self showToast:failureReason];
//    }
}

#pragma mark help screens

-(void)initializeWiFiPresence{
    [self resetViewDelegate];
    [[SecurifiToolkit sharedInstance] setScreenDefault:@"wifitrigger"];
    
    [HelpScreens initializeWifiPresence:self.helpScreensObj view:self.view tabHt:self.tabBarController.tabBar.frame.size.height];
    
    [self.navigationController.view addSubview:self.helpScreensObj];
}

#pragma mark helpscreen delegate methods
- (void)onShowMeTapDelegate{
    NSLog(@"onShowMeTapDelegate");
    self.maskView.frame = CGRectMake(0, 0, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height);
    [self.maskView setBackgroundColor:[SFIColors maskColor]];
    [self.tabBarController.view addSubview:self.maskView];
    
    [HelpScreens addTriggerHelpPage:self.helpScreensObj startScreen:[CommonMethods getDict:@"Quick_Tips" itemName:@"Wi_Fi_Triggers"] navView:self.navigationController.view]; //dont localize
    
    [self.maskView addSubview:self.helpScreensObj];
//    [self.tabBarController.tabBar setHidden:YES];
}

- (void)onGoToHelpCenterTapDelegate{
    [self resetViewDelegate];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HelpScreenStoryboard" bundle:nil];
    HelpCenter *helpCenter = [storyboard instantiateViewControllerWithIdentifier:@"HelpCenter"];
    
    [self.navigationController pushViewController:helpCenter animated:YES];
}

 /**/
-(void)patenalControlClickDelegate:(GenericParams *)genericParams{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
    ParentalControlsViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ParentalControlsViewController"];
    viewController.genericParams = genericParams;
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)onIoTControllClickedDelegate:(GenericParams *)genericParams{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainDashboard" bundle:nil];
    IoTDeviceViewController *newWindow = [storyboard   instantiateViewControllerWithIdentifier:@"IoTDeviceViewController"];
    NSString *deviceID = @(genericParams.headerGenericIndexValue. deviceID).stringValue;
    NSString *mac ;
    for(Client *client in self.toolkit.clients){
        if([deviceID isEqualToString:client.deviceID]){
            mac = client.deviceMAC;
        }
    }
    NSDictionary *iotDevice = @{@"MAC" :mac};
    newWindow.iotDevice = iotDevice;
    newWindow.hideTable = YES;
    newWindow.hideMiddleView = NO;
    
    NSLog(@"IoTDevicesListViewController IF");
    [self.navigationController pushViewController:newWindow animated:YES];
}
@end
