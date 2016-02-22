////
////  SensorTableViewController.h
////  SecurifiApp
////
////  Created by Securifi-Mac2 on 19/02/16.
////  Copyright © 2016 Securifi Ltd. All rights reserved.
////
//
//#import "SFITableViewController.h"
//
//@interface SensorTableViewController : SFITableViewController
//
//
//@end
/*
 
 //
 //  SensorTableViewController.m
 //  SecurifiApp
 //
 //  Created by Securifi-Mac2 on 19/02/16.
 //  Copyright © 2016 Securifi Ltd. All rights reserved.
 //
 
 #import "SensorTableViewController.h"
 #import "SensorTableViewCell.h"
 #import "SFIColors.h"
 
 @interface SensorTableViewController ()<UITableViewDelegate,UITableViewDataSource>
 @property(nonatomic,strong) NSMutableArray *currentDeviceList;
 @property(nonatomic, readonly) SFIAlmondPlus *almond;
 @property(nonatomic, readonly) SFIColors *almondColor;
 @property(nonatomic, readonly) NSDictionary *deviceValueTable;
 @end
 
 @implementation SensorTableViewController
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 
 //Cancel the mobile event - Revert back
 SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
 self.currentDeviceList = [NSMutableArray arrayWithArray:[toolkit deviceList:[toolkit currentAlmond].almondplusMAC]];
 //        [self setDeviceValues:[toolkit deviceValuesList:self.almond]];
 
 
 
 // Do any additional setup after loading the view.
 }
 
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.
 }
 
 /*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cell created");
    SFIDevice *device = [self tryGetDevice:indexPath.row];
    
    SFIDeviceType currentDeviceType = device.deviceType;
    SFIDeviceValue *deviceValue = [self tryCurrentDeviceValues:device.deviceID];
    SensorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SensorTableViewCell"];
    if (cell == nil) {
        cell = [[SensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SensorTableViewCell"];
        
    }
    //cell.backgroundColor = [UIColor lightGrayColor];
    
    cell.tag = indexPath.row;
    cell.device = device;
    NSLog(@" cell.devicename %f,%f",cell.frame.size.width,cell.frame.size.height);
    cell.deviceValue = deviceValue;
    NSLog(@" deviceImagebutton %@",cell.deviceImageButton.titleLabel.text);
    cell.cellColor = [self.almondColor makeGradatedColorForPositionIndex:indexPath.row];
    [cell layoutDeviceTileFrame];
    //[cell layoutTileFrame];
    //    cell.delegate = self;
    //    cell.expandedView = expanded;
    //    cell.enableSensorTileDebugInfo = self.enableSensorTileDebugInfo;
    //
    //    cell.deviceValue = deviceValue;
    //
    
    return  cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;    //count number of row from counting array hear cataGorry is An Array
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@" heightForRowAtIndexPath ");
    return 90;
}
- (SFIDevice *)tryGetDevice:(NSInteger)index {
    NSUInteger uIndex = (NSUInteger) index;
    
    NSArray *list = self.currentDeviceList;
    if (uIndex < list.count) {
        return list[uIndex];
    }
    return nil;
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

@end

 
 */