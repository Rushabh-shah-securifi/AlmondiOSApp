//
//  SensorTable.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SensorTable.h"
#import "SensorEditViewController.h"
#import "UIFont+Securifi.h"
#import "ClientEditViewController.h"
#import "CommonCell.h"
#import "DeviceParser.h"
#import "DeviceTableViewCell.h"
#define NO_ALMOND @"NO ALMOND"
#define CELLFRAME CGRectMake(5, 0, self.view.frame.size.width -10, 60)
#define CELL_IDENTIFIER @"device_cell"

@interface SensorTable ()<UITableViewDataSource,UITableViewDelegate,CommonCellDelegate>
@property (nonatomic,strong)NSMutableArray *currentDeviceList;
@property (nonatomic,strong)NSDictionary *deviceValueTable;
@property(nonatomic, strong) NSMutableArray *connectedDevices;
@property SFIAlmondPlus *currentAlmond;
@end

@implementation SensorTable

- (void)viewDidLoad {
    [super viewDidLoad];
    [DeviceParser parseDeviceListAndDynamicDeviceResponse:nil];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentDeviceList = toolkit.devices;
    [self setDeviceValues:[toolkit deviceValuesList:[toolkit currentAlmond].almondplusMAC]];
    self.connectedDevices = toolkit.wifiClientParser;
    self.currentAlmond = [toolkit currentAlmond];
    if (self.currentAlmond == nil) {
        [self markTitle: NSLocalizedString(@"scene.title.Get Started", @"Get Started")];
        [self markAlmondMac:NO_ALMOND];
    }
    else {
        [self markAlmondMac:self.currentAlmond.almondplusMAC];
        [self markTitle: self.currentAlmond.almondplusName];
    }

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
    if(indexPath.section == 0){
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        //cell.commonView.frame = CGRectMake(cell.commonView.frame.origin.x, cell.commonView.frame.origin.y, cell.commonView.frame.size.width, 80);
        cell.commonView.cellType = SensorTable_Cell;
        cell.commonView.delegate = self;
        cell.commonView.device = [self.currentDeviceList objectAtIndex:indexPath.row];
        NSLog(@"device id, name: %d, %@", cell.commonView.device.ID, cell.commonView.device.name);
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
- (void)setDeviceValues:(NSArray *)values {
    NSMutableDictionary *table = [NSMutableDictionary dictionary];
    for (SFIDeviceValue *value in values) {
        NSNumber *key = @(value.deviceID);
        table[key] = value;
    }
    _deviceValueTable = [NSDictionary dictionaryWithDictionary:table];
}
- (SFIDeviceValue *)tryCurrentDeviceValues:(int)deviceId {
    return self.deviceValueTable[@(deviceId)];
}
-(void)delegateSensorTable:(Device*)device withGenericIndexValues:(NSArray *)genericIndexValues{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
        SensorEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SensorEditViewController"];
        viewController.device = device;
        viewController.isSensor = YES;
        viewController.genericIndexValues = genericIndexValues;
        [self.navigationController pushViewController:viewController animated:YES];
    });
  

}
#pragma mark clientCell delegate
- (void)btnSettingTapped:(NSDictionary *)connectedDevice index:(NSArray*)indexArray{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
        ClientEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ClientEditViewController"];
        viewController.connectedDevice = connectedDevice;
        viewController.indexArray = indexArray;
        [self.navigationController pushViewController:viewController animated:YES];

    });

}
-(void)delegateSensorTable{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
    ClientEditViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ClientEditViewController"];
//    viewController.connectedDevice = [self.connectedDevices objectAtIndex:0];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
