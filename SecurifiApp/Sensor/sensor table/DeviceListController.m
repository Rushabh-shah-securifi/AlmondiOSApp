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

#define NO_ALMOND @"NO ALMOND"
#define CELLFRAME CGRectMake(5, 0, self.view.frame.size.width -10, 60)
#define CELL_IDENTIFIER @"device_cell"

@interface DeviceListController ()<UITableViewDataSource,UITableViewDelegate,DeviceHeaderViewDelegate>
@property (nonatomic,strong)NSMutableArray *currentDeviceList;
@property(nonatomic, strong) NSMutableArray *connectedDevices;
@property SFIAlmondPlus *currentAlmond;
@end

@implementation DeviceListController
int randomMobileInternalIndex;

- (void)viewDidLoad {
    NSLog(@"sensor - viewDidLoad");
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];

    if (self.currentAlmond == nil) {
        [self markTitle: NSLocalizedString(@"scene.title.Get Started", @"Get Started")];
        [self markAlmondMac:NO_ALMOND];
    }
    else {
        [self markAlmondMac:self.currentAlmond.almondplusMAC];
        [self markTitle: self.currentAlmond.almondplusName];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"sensor viewWillAppear");
    [super viewWillAppear:YES];
    DeviceParser *deviceparser = [[DeviceParser alloc]init];
    [deviceparser parseDeviceListAndDynamicDeviceResponse:nil];
    
    randomMobileInternalIndex = arc4random() % 10000;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentAlmond = [toolkit currentAlmond];
    self.currentDeviceList = toolkit.devices;
    self.connectedDevices = toolkit.wifiClientParser;
    [self initializeNotifications];
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
    [center addObserver:self selector:@selector(onDeviceListAndDynamicResponseParsed:) name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER object:nil];
    [center addObserver:self selector:@selector(onUpdateDeviceIndexResponse:) name:NOTIFICATION_UPDATE_DEVICE_INDEX_NOTIFIER object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    if(section == 0)
        return self.currentDeviceList.count;
    else
        return 4;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return [NSString stringWithFormat:@"Sensors (%d)",(int)self.currentDeviceList.count];
    else
        return [NSString stringWithFormat:@"Network Devices (%d)",1];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *header = @"customHeader";
    
    UITableViewHeaderFooterView *vHeader;
    
    vHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    
    if (!vHeader) {
        vHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
    }
    vHeader.textLabel.font = [UIFont securifiFont:16];
    vHeader.textLabel.textColor = [UIColor lightGrayColor];
    vHeader.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return vHeader;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        if(self.currentDeviceList == nil || self.currentDeviceList.count == 0)
            return cell;
        Device *device = [self.currentDeviceList objectAtIndex:indexPath.row];
        GenericParams *genericParams;
//        if(cell.commonView.genericParams == nil){
            NSLog(@"genericParams is nil");
            genericParams = [[GenericParams alloc]initWithGenericIndexValue:[GenericIndexUtil getHeaderGenericIndexValueForDevice:device] indexValueList:nil deviceName:device.name color:[UIColor greenColor]];
//        }else {
//            NSLog(@"genericParams not nil");
//            [genericParams setGenericParamsWithGenericIndexValue:[GenericIndexUtil getHeaderGenericIndexValueForDevice:device] indexValueList:nil deviceName:device.name color:[UIColor greenColor]];
//        }
        
        [cell.commonView initializeSensorCellWithGenericParams:genericParams cellType:SensorTable_Cell];
        cell.commonView.delegate = self;
        [cell.commonView setUPSensorCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
        cell.commonView.delegate = self;
        cell.commonView.cellType = ClientTable_Cell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

#pragma mark sensor cell(DeviceHeaderView) delegate
-(void)delegateDeviceSettingButtonClick:(GenericParams*)genericParams{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
        DeviceEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"DeviceEditViewController"];
        viewController.genericParams = genericParams;
        viewController.isSensor = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    });
}

-(void)delegateDeviceButtonClickWithGenericProperies:(GenericIndexValue *)genericIndexValue{
    NSLog(@"delegateSensorTableDeviceButtonClickWithGenericProperies");
    NSDictionary *payload = [DevicePayload getSensorIndexUpdatePayloadForGenericProperty:genericIndexValue mii:randomMobileInternalIndex];
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_DEVICE_INDEX;
    command.command = [payload JSONString];
    
    [self asyncSendCommand:command];
}

- (void)asyncSendCommand:(GenericCommand *)command {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    if(local){
        [[SecurifiToolkit sharedInstance] asyncSendToLocal:command almondMac:almond.almondplusMAC];
    }else{
        [[SecurifiToolkit sharedInstance] asyncSendToCloud:command];
    }
}

#pragma mark clientCell delegate
- (void)btnSettingTapped:(NSDictionary *)connectedDevice index:(NSArray*)indexArray{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
        ClientPropertiesViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ClientPropertiesViewController"];
        viewController.connectedDevice = connectedDevice;
        viewController.indexArray = indexArray;
        [self.navigationController pushViewController:viewController animated:YES];

    });

}
-(void)delegateClientSettingButtonClick{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
    ClientPropertiesViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ClientPropertiesViewController"];
//    viewController.connectedDevice = [self.connectedDevices objectAtIndex:0];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark command responses
-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"onDeviceListAndDynamicResponseParsed");
    dispatch_async(dispatch_get_main_queue(), ^() {
        //    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        [self.tableView reloadData];

    });
}
-(void)onUpdateDeviceIndexResponse:(id)sender{
    NSLog(@"onUpdateDeviceIndexResponse");
    //update image
}

@end
