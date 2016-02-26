//
//  SensorTable.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SensorTable.h"
#import "SensorCell.h"
#import "SensorEditViewController.h"
#import "SFIWiFiClientListCell.h"
#import "UIFont+Securifi.h"

@interface SensorTable ()<UITableViewDataSource,UITableViewDelegate,SensorCellDelegate,SFIWiFiClientListCellDelegate>
@property (nonatomic,strong)NSMutableArray *currentDeviceList;
@property (nonatomic,strong)NSDictionary *deviceValueTable;
@property(nonatomic, strong) NSMutableArray *connectedDevices;
@end

@implementation SensorTable

- (void)viewDidLoad {
    [super viewDidLoad];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentDeviceList = [NSMutableArray arrayWithArray:[toolkit deviceList:[toolkit currentAlmond].almondplusMAC]];
    [self setDeviceValues:[toolkit deviceValuesList:[toolkit currentAlmond].almondplusMAC]];
    self.connectedDevices = toolkit.wifiClientParser;
   // [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 3;
    else
    return 4;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return [NSString stringWithFormat:@"Sensors (%d)",1];
    else
        return [NSString stringWithFormat:@"Network devices (%d)",1];
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
    NSLog(@"cellForRowAtIndexPath");
    if(indexPath.section == 0){
    SensorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[SensorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
        //cell = [[SFISensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    SFIDevice *device = [[SFIDevice alloc]init];
    NSLog(@"cell frame %f,%f,%f,%f",cell.frame.origin.x,cell.frame.origin.y,cell.frame.size.height,cell.frame.size.width);
    // Configure the cell...
    cell.delegate  = self;
   cell.device = device;
    cell.deviceValue = [self tryCurrentDeviceValues:device.deviceID];
    //[cell cellInfo];
    NSLog(@" cell.device name %@",cell.device.deviceName);
    return cell;
    }
    else
    {
    static NSString *CellIdentifier = @"wifi";
    SFIWiFiClientListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell){
        cell = [[SFIWiFiClientListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(self.connectedDevices.count <=indexPath.section)
        return cell;
    cell.delegate = self;
    [cell createClientCell:self.connectedDevices[indexPath.section]];
    cell.expandable = YES;
    return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@" heightForRowAtIndexPath ");
    return 63;
}
- (void)setDeviceValues:(NSArray *)values {
    NSMutableDictionary *table = [NSMutableDictionary dictionary];
    for (SFIDeviceValue *value in values) {
        NSNumber *key = @(value.deviceID);
        table[key] = value;
    }
    _deviceValueTable = [NSDictionary dictionaryWithDictionary:table];
    NSLog(@"_deviceValueTable  %@ ",_deviceValueTable);
}
- (SFIDeviceValue *)tryCurrentDeviceValues:(int)deviceId {
    return self.deviceValueTable[@(deviceId)];
}
-(void)onSettingButtonClicked:(Device*)device genericIndex:(NSArray*)genericIndexArray{
    NSLog(@"onSettingButtonClicked");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
    SensorEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SensorEditViewController"];
    viewController.device = device;
    viewController.genericIndexs = genericIndexArray;
    [self.navigationController pushViewController:viewController animated:YES];

}
-(void)settingTapped:(SFIWiFiClientListCell*)cell Info:(SFIConnectedDevice*)connectedDevice{
    NSLog(@"btnSettingTap");
    NSIndexPath * indexPath = [self.tblView indexPathForCell:cell];
    //    currentIndexPath = indexPath;
    //    currentDevice = self.connectedDevices[indexPath.section];
    [self.tblView expandCell:self.tblView didSelectRowAtIndexPath:indexPath];
}
- (void)btnSettingTapped:(SFIWiFiClientListCell *)cell Info:(SFIConnectedDevice *)connectedDevice{
    NSIndexPath * indexPath = [self.tblView indexPathForCell:cell];
//    currentIndexPath = indexPath;
//    currentDevice = self.connectedDevices[indexPath.section];
    [self.tblView expandCell:self.tblView didSelectRowAtIndexPath:indexPath];
//        [self tableView:tblDevices didSelectRowAtIndexPath:indexPath];
}
@end
