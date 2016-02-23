//
//  SensorTable.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SensorTable.h"
#import "SensorCell.h"

@interface SensorTable ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong)NSMutableArray *currentDeviceList;
@property (nonatomic,strong)NSDictionary *deviceValueTable;
@end

@implementation SensorTable

- (void)viewDidLoad {
    [super viewDidLoad];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentDeviceList = [NSMutableArray arrayWithArray:[toolkit deviceList:[toolkit currentAlmond].almondplusMAC]];
    [self setDeviceValues:[toolkit deviceValuesList:[toolkit currentAlmond].almondplusMAC]];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    SensorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[SensorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
        //cell = [[SFISensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    SFIDevice *device = [self.currentDeviceList objectAtIndex:indexPath.row];
    NSLog(@"cell frame %f,%f,%f,%f",cell.frame.origin.x,cell.frame.origin.y,cell.frame.size.height,cell.frame.size.width);
    // Configure the cell...
    cell.device = device;
    cell.deviceValue = [self tryCurrentDeviceValues:device.deviceID];
    //[cell cellInfo];
    NSLog(@" cell.device name %@",cell.device.deviceName);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@" heightForRowAtIndexPath ");
    return 90;
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



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
