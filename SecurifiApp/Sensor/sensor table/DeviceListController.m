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
#import "RouterPayload.h"

#define NO_ALMOND @"NO ALMOND"
#define CELLFRAME CGRectMake(5, 0, self.view.frame.size.width -10, 60)
#define CELL_IDENTIFIER @"device_cell"
#define HEADER_FONT_SIZE 16
#define COUNT_FONT_SIZE 12

@interface DeviceListController ()<UITableViewDataSource,UITableViewDelegate,DeviceHeaderViewDelegate,MessageViewDelegate>
@property (nonatomic,strong)NSArray *currentDeviceList;
@property(nonatomic, strong) NSArray *currentClientList;

@property(nonatomic, readonly) SFIColors *almondColor;
@property(nonatomic) NSTimer *mobileCommandTimer;

@property(nonatomic) SecurifiToolkit *toolkit;
@end

@implementation DeviceListController
int mii;

- (void)viewDidLoad {
    NSLog(@"devicelist - viewDidLoad");
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    
    self.toolkit = [SecurifiToolkit sharedInstance];
    //ensure list is empty initially
    self.currentDeviceList = @[];
    self.currentClientList = @[];
    [self initializeAlmondData];
    [self showHudWithTimeoutMsg:@"Loading Device data"];
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"devicelist viewWillAppear");
    
    [super viewWillAppear:YES];
    [self initializeNotifications];
//    DeviceParser *deviceparser = [[DeviceParser alloc]init];
//    [deviceparser parseDeviceListAndDynamicDeviceResponse:nil];
//    [self initializeAlmondData];
//    
    mii = arc4random() % 10000;
    //need to reload tableview, as toolkit could have got updates
    self.currentDeviceList = self.toolkit.devices;
    self.currentClientList = self.toolkit.clients;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

-(void)initializeAlmondData{
    NSLog(@"%s, self.toolkit.currentAlmond: %@", __PRETTY_FUNCTION__, self.toolkit.currentAlmond);
    if (self.toolkit.currentAlmond == nil) {
        [self markTitle:NSLocalizedString(@"router.nav-title.Get Started", @"Get Started")];
        [self markAlmondMac:NO_ALMOND];
        self.currentDeviceList = @[];
        self.currentClientList = @[];
    }
    else {
        [self markTitle:self.toolkit.currentAlmond.almondplusName];
        [self markAlmondMac:self.toolkit.currentAlmond.almondplusMAC];
        self.currentDeviceList = self.toolkit.devices;
        self.currentClientList = self.toolkit.clients;
        
        [self initializeColors:[self.toolkit currentAlmond]];
    }
    self.enableDrawer = YES; //to enable navigation top left button
    [self tryInstallRefreshControl];
//    [RouterPayload routerSummary:mii isSimulator:NO mac:self.toolkit.currentAlmond.almondplusMAC];
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
               selector:@selector(onAlmondNameDidChange:)
                   name:kSFIDidChangeAlmondName
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onNotificationPrefDidChange:)
                   name:kSFINotificationPreferencesDidChange
                 object:nil];
}

#pragma mark - HUD and Toast mgt
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:5];
    });
}

#pragma mark - State
- (BOOL)isDeviceListEmpty {
    // don't show any tiles until there are values for the devices; no values == no way to fetch from almond
    return self.currentDeviceList.count == 0;
}

-(BOOL)isClientListEmpty{
    return self.currentClientList.count == 0;
}

- (BOOL)isNoAlmondMAC {
    return [self.almondMac isEqualToString:NO_ALMOND];
}

- (BOOL)isSameAsCurrentMAC:(NSString *)aMac {
    if (aMac == nil) {
        return NO;
    }
    
    NSString *current = self.almondMac;
    if (current == nil) {
        return NO;
    }
    
    return [current isEqualToString:aMac];
}

#pragma mark refresh control
// controls installation and removal of refresh control
- (void)tryInstallRefreshControl {
    if ([self isDeviceListEmpty] && [self isClientListEmpty]) {
        // Disable refresh when no devices to refresh
        self.refreshControl = nil;
    }
    else {
        // Pull down to refresh device values
        UIRefreshControl *refresh = [UIRefreshControl new];
        NSDictionary *attributes = self.navigationController.navigationBar.titleTextAttributes;
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Force device data refresh" attributes:attributes];
        [refresh addTarget:self action:@selector(onRefreshSensorData:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isNoAlmondMAC]) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isNoAlmondMAC]) {
        return 1;
    }
    return (section == 0) ? self.currentDeviceList.count:self.currentClientList.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (NSMutableAttributedString *)getAttributeString:(NSString *)header fontSize:(int)fontsize
{
    UIFont *lightFont = [UIFont securifiLightFont:fontsize];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: lightFont forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString = [[NSMutableAttributedString alloc] initWithString:header attributes: arialDict];
    return aAttrString;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{   NSString *header,*headerVal;
    if(section == 0){
        header = @"Sensors ";
        headerVal = [NSString stringWithFormat:@"(%ld)",(long int)self.currentDeviceList.count];
    }
    else{
        headerVal = [NSString stringWithFormat:@"(%ld)",(long int)self.currentClientList.count];
        header = @"Network Devices ";
    }
    
    NSMutableAttributedString *aAttrString = [self getAttributeString:header fontSize:HEADER_FONT_SIZE];
    NSMutableAttributedString *vAttrString = [self getAttributeString:headerVal fontSize:COUNT_FONT_SIZE];
    [aAttrString appendAttributedString:vAttrString];
    static NSString *headerView = @"customHeader";
    UITableViewHeaderFooterView *vHeader;
    vHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerView];
    if (!vHeader) {
        vHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerView];
    }
    vHeader.textLabel.textColor = [UIColor lightGrayColor];
    vHeader.textLabel.attributedText = aAttrString;
    
    return vHeader;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC]) {
        tableView.scrollEnabled = NO;
        return [self createNoAlmondCell:tableView];
    }
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.commonView.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    GenericParams *genericParams;
    if(indexPath.section == 0){
        Device *device = [self.currentDeviceList objectAtIndex:indexPath.row];
        
        genericParams = [[GenericParams alloc]initWithGenericIndexValue:[GenericIndexUtil getHeaderGenericIndexValueForDevice:device]
                                                         indexValueList:nil
                                                             deviceName:device.name
                                                                  color:[self.almondColor makeGradatedColorForPositionIndex:indexPath.row]
                                                               isSensor:YES];
        
        [cell.commonView initialize:genericParams cellType:SensorTable_Cell];
    }
    else
    {
        Client *client = [self.currentClientList objectAtIndex:indexPath.row];
        UIColor *clientCellColor = [self getClientCellColor:client];
        genericParams = [[GenericParams alloc]initWithGenericIndexValue:[GenericIndexUtil getClientHeaderGenericIndexValueForClient:client]
                                                         indexValueList:nil
                                                             deviceName:client.name
                                                                  color:clientCellColor
                                                               isSensor:NO];
        [cell.commonView initialize:genericParams cellType:ClientTable_Cell];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isNoAlmondMAC]) {
        return 400;
    }
    return 75;
}


- (UITableViewCell *)createNoAlmondCell:(UITableView *)tableView {
    static NSString *no_almond_cell_id = @"NoAlmondCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:no_almond_cell_id];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:no_almond_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        MessageView *view = [MessageView linkRouterMessage];
        view.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 400);
        view.delegate = self;
        
        [cell addSubview:view];
    }
    
    return cell;
}

#pragma mark - Class Methods
- (void)initializeColors:(SFIAlmondPlus *)almond {
    NSUInteger colorCode = (NSUInteger) almond.colorCodeIndex;
    _almondColor = [SFIColors colorForIndex:colorCode];
}

- (UIColor*) getClientCellColor:(Client*)client{
    if (client.deviceAllowedType == 1)
        return [SFIColors clientBlockedGrayColor];
    else if(client.isActive)
        return [SFIColors clientGreenColor];
    else if(!client.isActive)
        return [SFIColors clientInActiveGrayColor];

    return [SFIColors clientGreenColor];
}

#pragma mark messageViewDelegate

- (void)messageViewDidPressButton:(MessageView *)msgView {
    UIViewController *ctrl = [SFICloudLinkViewController cloudLinkController];
    [self presentViewController:ctrl animated:YES completion:nil];
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
//        [self.HUD hide:YES];
    });
}
#pragma mark clientCell delegate

-(void)delegateClientSettingButtonClick:(GenericParams*)genericParams{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
    ClientPropertiesViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ClientPropertiesViewController"];
    viewController.genericParams = genericParams;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark command responses
-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"devicelist - onDeviceListAndDynamicResponseParsed");
    self.currentDeviceList = self.toolkit.devices;
    self.currentClientList = self.toolkit.clients;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
        [self.HUD hide:YES];
        [self.refreshControl endRefreshing];
    });
}

-(void)onUpdateDeviceIndexResponse:(id)sender{ //mobile command
    NSLog(@"onUpdateDeviceIndexResponse");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    SFIAlmondPlus *almond = [self.toolkit currentAlmond];
    BOOL local = [self.toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        NSLog(@"cloud data");
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    
    //    payload = [self parseJson:@"DeviceListResponse"];
    NSLog(@"devicelistcontroller - mobile - payload: %@", payload);

}

#pragma mark cloud callbacks
- (void)onCurrentAlmondChanged:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if(self.toolkit.devices.count > 0)
        [self.toolkit.devices removeAllObjects];
    else if(self.toolkit.clients.count > 0)
        [self.toolkit.clients removeAllObjects];
        
    [self initializeAlmondData];
    [DevicePayload deviceListCommand];
    [ClientPayload clientListCommand];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHudWithTimeoutMsg:@"Loading Device data"];
        [self.tableView reloadData];
    });
}

- (void)onAlmondListDidChange:(id)sender {
    NSLog(@"%s 1", __PRETTY_FUNCTION__);
    if (!self) {
        return;
    }
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    SFIAlmondPlus *plus = [data valueForKey:@"data"];
    if (plus != nil && [self isSameAsCurrentMAC:plus.almondplusMAC]) {
        // No reason to alert user
        return;
    }
    NSLog(@"%s 2", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self || !self.isViewLoaded) {
            return;
        }
        NSLog(@"%s 3", __PRETTY_FUNCTION__);
        [self.HUD show:YES];
        [self initializeAlmondData];
        [self.tableView reloadData];
        [self.HUD hide:YES afterDelay:1.5];
    });
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
        if ([self isSameAsCurrentMAC:obj.almondplusMAC]) {
            self.navigationItem.title = obj.almondplusName;
        }
    });
}


- (void)onNotificationPrefDidChange:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^() {
        
    });
}

- (void)onRefreshSensorData:(id)sender {
    if (!self || [self isNoAlmondMAC]) {
        return;
    }
    [DevicePayload deviceListCommand];
    [ClientPayload clientListCommand];
    //request client list
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.refreshControl endRefreshing];
    });
}

@end
