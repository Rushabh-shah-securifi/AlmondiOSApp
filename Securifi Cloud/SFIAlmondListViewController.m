//
//  SFIAlmondListViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 16/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIAlmondListViewController.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "AlmondPlusConstants.h"
#import "SFIDeviceListViewController.h"
#import "SFIOfflineDataManager.h"
#import "SNLog.h"

@interface SFIAlmondListViewController ()

@end

@implementation SFIAlmondListViewController
@synthesize tvAlmondList;
@synthesize almondList;
@synthesize deviceList;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    SNFileLogger *logger = [[SNFileLogger alloc] init];
//    [[SNLog logManager] addLogStrategy:logger];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.dimBackground = YES;
    HUD.labelText=@"Refreshing Almond List";

    //Upload old list and start refreshing
    self.almondList = [SFIOfflineDataManager readAlmondList];
    
    [self loadAlmondList];

}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AlmondListResponseCallback:)
                                                 name:ALMOND_LIST_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(HashResponseCallback:)
                                                 name:HASH_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DeviceListResponseCallback:)
                                                 name:DEVICE_DATA_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DeviceValueListResponseCallback:)
                                                 name:DEVICE_VALUE_NOTIFIER
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:ALMOND_LIST_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:HASH_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:DEVICE_DATA_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:DEVICE_VALUE_NOTIFIER
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Cloud Command : Sender and Receivers

-(void)loadAlmondList{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    AlmondListRequest *almondListCommand = [[AlmondListRequest alloc] init];
    
    cloudCommand.commandType=ALMOND_LIST;
    cloudCommand.command=almondListCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- Almond List Command", __PRETTY_FUNCTION__];
        
        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance]sendtoCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];

        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- Almond List Command", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    cloudCommand=nil;
    almondListCommand=nil;

}

-(void)AlmondListResponseCallback:(id)sender
{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received Almond List response", __PRETTY_FUNCTION__];
        
        AlmondListResponse *obj = [[AlmondListResponse alloc] init];
        obj = (AlmondListResponse *)[data valueForKey:@"data"];
        
        self.almondList = [[NSMutableArray alloc]init];
        [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__,[obj.almondPlusMACList count]];

        self.almondList = obj.almondPlusMACList;
        //Write Almond List offline
        [SFIOfflineDataManager writeAlmondList:self.almondList];
        
        [tvAlmondList reloadData];
        [HUD hide:YES];
        
    }
    
    
}


-(void)getDeviceHash{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    DeviceDataHashRequest *deviceHashCommand = [[DeviceDataHashRequest alloc] init];
    deviceHashCommand.almondMAC = self.currentMAC;
    
    cloudCommand.commandType=DEVICEDATA_HASH;
    cloudCommand.command=deviceHashCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- DeviceHash Command", __PRETTY_FUNCTION__];
        
        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance]sendtoCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- DeviceHash Command", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    cloudCommand=nil;
    deviceHashCommand=nil;
    
}

-(void)HashResponseCallback:(id)sender
{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received Device Hash response", __PRETTY_FUNCTION__];

        NSString *currentHash;
        
        DeviceDataHashResponse *obj = [[DeviceDataHashResponse alloc] init];
        obj = (DeviceDataHashResponse *)[data valueForKey:@"data"];
        
        if(obj.isSuccessful){
            //Hash Present
            currentHash = obj.almondHash;
            [SNLog Log:@"Method Name: %s Current Hash ==> @%@ Offline Hash ==> @%@",__PRETTY_FUNCTION__,currentHash, self.offlineHash];
            if(![currentHash isEqualToString:@""] && currentHash!=nil){
                if(![currentHash isEqualToString:@"null"]){
                    if([currentHash isEqualToString:self.offlineHash]){
                        [SNLog Log:@"Method Name: %s Hash Match: Get Device Values", __PRETTY_FUNCTION__];
                        
                        //For testing
                        //Get Device List
                        //[self loadDeviceList];
                        
                        //Get Device Values
                        [self loadDeviceValue];
                        
                        
                    }else{
                        [SNLog Log:@"Method Name: %s Hash MisMatch: Get Device Values", __PRETTY_FUNCTION__];
           
                        //Save hash in file for each almond
                        //Write the device hash for AlmondMAC
//                        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//                        [prefs setObject:currentHash  forKey:CURRENT_HASH];
//                        [prefs synchronize];
                        [SFIOfflineDataManager writeHashList:currentHash currentMAC:self.currentMAC];
                        
                        //Get Device List
                        [self loadDeviceList];
                        
                    }
                }
                else{
                    //Hash sent by cloud as null - No Device
                    //TODO: Open next activity with blank view
                    [HUD hide:YES];
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                    SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*) [storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceListViewController"];
                    //TODO: Remove later - when stored in file
                    // SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*)mainView;
//                    deviceListView.deviceList = self.deviceList;
//                    deviceListView.deviceValueList = self.deviceValueList;
                    [self.navigationController pushViewController:deviceListView animated:YES];
                }
            }
            else{
                //No Hash from cloud
                //TODO: Open next activity with blank view
                [HUD hide:YES];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*) [storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceListViewController"];
                //TODO: Remove later - when stored in file
                // SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*)mainView;
//                deviceListView.deviceList = self.deviceList;
//                deviceListView.deviceValueList = self.deviceValueList;
                [self.navigationController pushViewController:deviceListView animated:YES];
            }
        }else{
            //success = false
            NSString *reason = obj.reason;
            [SNLog Log:@"Method Name: %s Hash Not Found Reason: @%@", __PRETTY_FUNCTION__,reason];
        }
        
    }
}

-(void)loadDeviceList{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    DeviceListRequest *deviceListCommand = [[DeviceListRequest alloc] init];
    deviceListCommand.almondMAC = self.currentMAC;
    
    cloudCommand.commandType=DEVICEDATA;
    cloudCommand.command=deviceListCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- Device List Command", __PRETTY_FUNCTION__];
        
        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance]sendtoCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
        }
        
        [SNLog Log:@"Method Name: %s After Writing to socket -- Device List Command", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    cloudCommand=nil;
    deviceListCommand=nil;
    
}

-(void)DeviceListResponseCallback:(id)sender
{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received Device List response", __PRETTY_FUNCTION__];
        
        DeviceListResponse *obj = [[DeviceListResponse alloc] init];
        obj = (DeviceListResponse *)[data valueForKey:@"data"];
        
        self.deviceList= [[NSMutableArray alloc]init];
        [SNLog Log:@"Method Name: %s List size : %d",__PRETTY_FUNCTION__,[obj.deviceList count]];
        self.deviceList = obj.deviceList;
        
        //Write offline
        [SFIOfflineDataManager writeDeviceList:self.deviceList currentMAC:self.currentMAC];
        //TODO: If count of devicelist is < 0, display a message
        //Get Device Value
        [self loadDeviceValue];
    }
    
}

-(void)loadDeviceValue{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    DeviceValueRequest *deviceValueListCommand = [[DeviceValueRequest alloc] init];
    deviceValueListCommand.almondMAC = self.currentMAC;
    
    cloudCommand.commandType=DEVICE_VALUE;
    cloudCommand.command=deviceValueListCommand;
    @try {

        [SNLog Log:@"Method Name: %s Before Writing to socket -- Device Value Command", __PRETTY_FUNCTION__];
        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance]sendtoCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
        }
        
        [SNLog Log:@"Method Name: %s After Writing to socket -- Device Value Command", __PRETTY_FUNCTION__];
    }
    @catch (NSException *exception) {
       [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    cloudCommand=nil;
    deviceValueListCommand=nil;
    
}

-(void)DeviceValueListResponseCallback:(id)sender
{
   [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received Device Value List response", __PRETTY_FUNCTION__];
        
        DeviceValueResponse *obj = [[DeviceValueResponse alloc] init];
        obj = (DeviceValueResponse *)[data valueForKey:@"data"];
        
        self.deviceValueList= [[NSMutableArray alloc]init];
        [SNLog Log:@"Method Name: %s List size : %d",__PRETTY_FUNCTION__,[obj.deviceValueList count]];
        self.deviceValueList = obj.deviceValueList;
        
        //Write offline
        [SFIOfflineDataManager writeDeviceValueList:self.deviceValueList currentMAC:self.currentMAC];
        //TODO: If count of devicevaluelist is < 0, display a message

        //Display next screen
        [HUD hide:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*) [storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceListViewController"];
        [self.navigationController pushViewController:deviceListView animated:YES];
    }
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.almondList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.almondList objectAtIndex:indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentMAC = [self.almondList objectAtIndex:indexPath.row];
    [SNLog Log:@"Method Name: %s Selected MAC is @%@", __PRETTY_FUNCTION__,self.currentMAC];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.currentMAC  forKey:CURRENT_ALMOND_MAC];
    [prefs synchronize];
    
    //Read from file
    //self.offlineHash  = [prefs objectForKey:CURRENT_HASH];
    self.offlineHash = [SFIOfflineDataManager readHashList:self.currentMAC];
    //Call command : Get HASH - Command 74
    [self getDeviceHash];
    
    //Display progress bar
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.dimBackground = YES;
    HUD.labelText=@"Refreshing Device List";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
