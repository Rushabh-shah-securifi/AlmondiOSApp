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
#import "DevicePayload.h"
#import "GenericIndexUtil.h"
#import "DeviceParser.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "PerformanceTest.h"


#define NO_ALMOND @"NO ALMOND"
#define CELLFRAME CGRectMake(5, 0, self.view.frame.size.width -10, 60)
#define CELL_IDENTIFIER @"device_cell"
#define HEADER_FONT_SIZE 16
#define COUNT_FONT_SIZE 12

@interface DeviceListController ()<UITableViewDataSource,UITableViewDelegate,DeviceHeaderViewDelegate>
@property (nonatomic,strong)NSMutableArray *currentDeviceList;
@property(nonatomic, strong) NSMutableArray *currentClientList;
@property SFIAlmondPlus *currentAlmond;
@property(nonatomic, readonly) SFIColors *almondColor;
@end

@implementation DeviceListController
int randomMobileInternalIndex;

- (void)viewDidLoad {
    NSLog(@"sensor - viewDidLoad");
    [super viewDidLoad];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
//    [PerformanceTest startTest];


    if (self.currentAlmond == nil) {
        [self markTitle: NSLocalizedString(@"scene.title.Get Started", @"Get Started")];
        [self markAlmondMac:NO_ALMOND];
    }
    else {
        [self markAlmondMac:self.currentAlmond.almondplusMAC];
        [self markTitle: self.currentAlmond.almondplusName];
    }
    
    [self initializeColors:[toolkit currentAlmond]];
    }

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"sensor viewWillAppear");
    [super viewWillAppear:YES];
    [self initializeNotifications];
//    DeviceParser *deviceparser = [[DeviceParser alloc]init];
//    [deviceparser parseDeviceListAndDynamicDeviceResponse:nil];
    
    randomMobileInternalIndex = arc4random() % 10000;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentAlmond = [toolkit currentAlmond];
    self.currentDeviceList = toolkit.devices;
    self.currentClientList = toolkit.clients;
    self.enableDrawer = YES; //to enable navigation top left button
    if (self.currentAlmond == nil) {
        [self markAlmondMac:NO_ALMOND];
        [self markTitle:NSLocalizedString(@"router.nav-title.Get Started", @"Get Started")];
    }
    else {
        [self markAlmondMac:self.currentAlmond.almondplusMAC];
        [self markTitle:self.currentAlmond.almondplusName];
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
        
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
               selector:@selector(onDeviceListAndDynamicResponseParsed:)
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onUpdateDeviceIndexResponse:)
                   name:NOTIFICATION_UPDATE_DEVICE_INDEX_NOTIFIER
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    
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
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.commonView.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    GenericParams *genericParams;
    if(indexPath.section == 0){
        Device *device = [self.currentDeviceList objectAtIndex:indexPath.row];
        
        genericParams = [[GenericParams alloc]initWithGenericIndexValue:[GenericIndexUtil getHeaderGenericIndexValueForDevice:device] indexValueList:nil deviceName:device.name color:[self.almondColor makeGradatedColorForPositionIndex:indexPath.row] isSensor:YES];
        
        [cell.commonView initialize:genericParams cellType:SensorTable_Cell];
    }
    else
    {
        Client *client = [self.currentClientList objectAtIndex:indexPath.row];
        UIColor *clientCellColor = [self getClientCellColor:client];
        genericParams = [[GenericParams alloc]initWithGenericIndexValue:[GenericIndexUtil getClientHeaderGenericIndexValueForClient:client] indexValueList:nil deviceName:client.name color:clientCellColor isSensor:NO];
        [cell.commonView initialize:genericParams cellType:ClientTable_Cell];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

#pragma mark - Class Methods
- (void)initializeColors:(SFIAlmondPlus *)almond {
    NSUInteger colorCode = (NSUInteger) almond.colorCodeIndex;
    _almondColor = [SFIColors colorForIndex:colorCode];
}

- (UIColor*) getClientCellColor:(Client*)client{
    if(client.isActive)
        return [SFIColors clientGreenColor];
    else if(!client.isActive)
        return [SFIColors clientInActiveGrayColor];
    else if (client.deviceAllowedType == 1)
        return [SFIColors clientBlockedGrayColor];
    return [SFIColors clientGreenColor];
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
    NSLog(@"delegateSensorTableDeviceButtonClickWithGenericProperies");
    
    GenericCommand *command = [DevicePayload getSensorIndexUpdate:genericIndexValue mii:randomMobileInternalIndex];
    [[SecurifiToolkit sharedInstance] asyncSendCommand:command];
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
    NSLog(@"onDeviceListAndDynamicResponseParsed");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentDeviceList = toolkit.devices;
    self.currentClientList = toolkit.clients;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];

    });
}

-(void)onUpdateDeviceIndexResponse:(id)sender{ //mobile command
    NSLog(@"onUpdateDeviceIndexResponse");

}

#pragma mark cloud callbacks
- (void)onCurrentAlmondChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
//        [self initializeAlmondData];
//        
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (void)onAlmondListDidChange:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        //        [self initializeAlmondData];
        //
        //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (void)onAlmondNameDidChange:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        //        [self initializeAlmondData];
        //
        //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (void)onNotificationPrefDidChange:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        //        [self initializeAlmondData];
        //
        //        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}




@end
