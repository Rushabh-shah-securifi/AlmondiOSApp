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
#import "ClientEditViewController.h"
#import "CommonCell.h"
#import "DeviceParser.h"

@interface SensorTable ()<UITableViewDataSource,UITableViewDelegate,SensorCellDelegate,SFIWiFiClientListCellDelegate,CommonCellDelegate>
@property (nonatomic,strong)NSMutableArray *currentDeviceList;
@property (nonatomic,strong)NSDictionary *deviceValueTable;
@property(nonatomic, strong) NSMutableArray *connectedDevices;
@end

@implementation SensorTable

- (void)viewDidLoad {
    [super viewDidLoad];
    [DeviceParser parseDeviceListAndDynamicDeviceResponse:nil];
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentDeviceList = toolkit.devices;
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
        return self.currentDeviceList.count;
    else
    return 4;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 0)
        return [NSString stringWithFormat:@"Sensors (%ld)",self.currentDeviceList.count];
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
        cell.device = [self.currentDeviceList objectAtIndex:indexPath.row];
        [cell setCellInfo];
      cell.delegate  = self;
    

    return cell;
    }
    else
    {
    static NSString *CellIdentifier = @"wifi";
    SFIWiFiClientListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell){
        cell = [[SFIWiFiClientListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
//        CommonCell * commonCell = [[CommonCell alloc]initWithFrame:CGRectMake(5, 5, cell.frame.size.width -10, cell.frame.size.height -10)];
//        commonCell.delegate = self;
//        commonCell.vCTypeEnum = table;
//        [cell addSubview:commonCell];
//    if(self.connectedDevices.count <=indexPath.section)
//        return cell;
    cell.delegate = self;
//    [cell createClientCell:self.connectedDevices[indexPath.section]];
//    [cell drawIndexes];
    cell.expandable = YES;
    return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@" heightForRowAtIndexPath ");
    return 65;
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
-(void)onSettingButtonClicked:(Device*)device genericIndex:(NSMutableArray*)genericIndexArray{
    NSLog(@"onSettingButtonClicked");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
    SensorEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SensorEditViewController"];
    viewController.device = device;
    
    viewController.genericIndexArray = genericIndexArray;
    NSLog(@"genericindexarray: %@", viewController.genericIndexArray);
    [self.navigationController pushViewController:viewController animated:YES];

}

- (void)btnSettingTapped:(NSDictionary *)connectedDevice index:(NSArray*)indexArray{
    NSLog(@"onSettingButtonClicked");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
    ClientEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ClientEditViewController"];
    viewController.connectedDevice = connectedDevice;
    viewController.indexArray = indexArray;
    [self.navigationController pushViewController:viewController animated:YES];


}
-(void)delegateSensorTable{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
    ClientEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ClientEditViewController"];
//    viewController.connectedDevice = [self.connectedDevices objectAtIndex:0];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
