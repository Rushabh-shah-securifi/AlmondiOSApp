//
//  ClientPropertiesViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ClientPropertiesViewController.h"
#import "UIFont+Securifi.h"
#import "SFIColors.h"
#import "ClientPropertiesCell.h"
#import "UIFont+Securifi.h"
#import "Colours.h"
#import "DeviceHeaderView.h"
#import "DeviceEditViewController.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "ClientPayload.h"
#import "UIViewController+Securifi.h"
#import "SFINotificationsViewController.h"
#import "MBProgressHUD.h"
#import "GenericIndexUtil.h"
#import "BrowsingHistoryViewController.h"
#import "BrowsingHistory.h"
#import "NSDate+Convenience.h"
#import "DataBaseManager.h"
#import "BrowsingHistoryDataBase.h"
#import "ParentalControlsViewController.h"
#import "AlmondManagement.h"
#import "IoTDeviceViewController.h"


#define CELLFRAME CGRectMake(8, 8, self.view.frame.size.width -16, 85)

@interface ClientPropertiesViewController ()<UITableViewDelegate,MBProgressHUDDelegate,UITableViewDataSource,DeviceHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *clientPropertiesTable;
@property (nonatomic)NSMutableArray *orderedArray ;
@property (nonatomic)NSDictionary *ClientDict;
@property (weak, nonatomic) IBOutlet UIView *resetView;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (nonatomic) BOOL isLocal;
@property (nonatomic) DeviceHeaderView *commonView;
@property (nonatomic)SecurifiToolkit *toolkit;
@property (nonatomic, readonly) MBProgressHUD *HUD;
@end

@implementation ClientPropertiesViewController
int randomMobileInternalIndex;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.clientPropertiesTable.backgroundColor = self.genericParams.color;
    [self setButtonColors];
    [self setHeaderCell];
    [self setUpHUD];
}

- (void)setButtonColors{
    self.resetView.backgroundColor = self.genericParams.color;
    [self.resetButton setTitleColor: self.genericParams.color forState:UIControlStateNormal];
    [self.historyButton setTitleColor: self.genericParams.color forState:UIControlStateNormal];
}

-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"client properties - view will appear");
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.tintColor = [SFIColors ruleBlueColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    randomMobileInternalIndex = arc4random() % 10000;
    [self initializeNotifications];
    _toolkit=[SecurifiToolkit sharedInstance];
    self.isLocal = [_toolkit useLocalNetwork:[AlmondManagement currentAlmond].almondplusMAC];
    
    if(!_isInitialized){ //to avoid call it first time
        NSLog(@"isInitialized");
        self.genericParams.indexValueList = [GenericIndexUtil getClientDetailGenericIndexValuesListForClientID:@(self.genericParams.headerGenericIndexValue.deviceID).stringValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self repaintHeader:self.genericParams.headerGenericIndexValue];
            [self setButtonColors];
            [self.clientPropertiesTable reloadData];
        });
    }
}


-(void)initializeNotifications{
    NSLog(@"initialize notifications sensor table");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onDeviceListAndDynamicResponseParsed:)
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil]; //indexupdate
    
}

-(void)viewWillDisappear{
    [self viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark table delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    self.isLocal = [toolkit useLocalNetwork:[AlmondManagement currentAlmond].almondplusMAC];
    if(self.isLocal){
        return self.genericParams.indexValueList.count -2;
    }
    self.historyButton.hidden = NO;
    return self.genericParams.indexValueList.count-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"client properties cell for row");
    ClientPropertiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SKSTableViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ClientPropertiesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SKSTableViewCell"];
    }
    
    GenericIndexValue *genericIndexValue = [self.genericParams.indexValueList objectAtIndex:indexPath.row];
    cell.displayLabel.text = genericIndexValue.genericIndex.groupLabel;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if(genericIndexValue.genericIndex.readOnly == NO){
        cell.vsluesLabel.alpha = 1;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
    }else{
        cell.vsluesLabel.alpha = 0.75;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
    }
    NSLog(@"genericValue.displayText %@ and value = %@ type = %@ , %@",genericIndexValue.genericValue.displayText,genericIndexValue.genericValue.value,genericIndexValue.genericIndex.ID,genericIndexValue.genericIndex.groupLabel);
    cell.vsluesLabel.text = genericIndexValue.genericValue.displayText;
    cell.backgroundColor = self.genericParams.color;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    //[self performSegueWithIdentifier:@"modaltodetails" sender:[self.eventsTable cellForRowAtIndexPath:indexPath]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{//
    NSLog(@"didSelectRowAtIndexPath");
    GenericIndexValue *gIval = [self.genericParams.indexValueList objectAtIndex:indexPath.row];
    if([gIval.genericIndex.ID isEqualToString:@"-23"]){
        UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:[NSBundle mainBundle]];
        ParentalControlsViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"ParentalControlsViewController"];
        ctrl.genericParams = self.genericParams;
        dispatch_async(dispatch_get_main_queue(), ^() {
            
            [self.navigationController pushViewController:ctrl animated:YES];
        });
        
        
    }
   else if([gIval.genericIndex.ID isEqualToString:@"-27"]){
       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainDashboard" bundle:nil];
       IoTDeviceViewController *newWindow = [storyboard   instantiateViewControllerWithIdentifier:@"IoTDeviceViewController"];
       NSString *deviceID = @(self.genericParams.headerGenericIndexValue. deviceID).stringValue;
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
    else
    {
        DeviceEditViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:@"DeviceEditViewController"];
        self.isInitialized = NO;
        ctrl.genericParams = [[GenericParams alloc]initWithGenericIndexValue:self.genericParams.headerGenericIndexValue
                                                              indexValueList:[NSArray arrayWithObject:[self.genericParams.indexValueList objectAtIndex:indexPath.row]]
                                                                  deviceName:self.genericParams.deviceName color:self.genericParams.color isSensor:NO];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

#pragma mark common cell delegate

-(void)delegateClientPropertyEditSettingClick{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.HUD hide:YES];
    });
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark setups
-(void)setHeaderCell{
    self.commonView= [[DeviceHeaderView alloc]initWithFrame:CELLFRAME];
    [self.commonView initialize:self.genericParams cellType:ClientProperty_Cell isSiteMap:NO];
    self.commonView.delegate = self;
    // set up images label and name
    [self.view addSubview:self.commonView];
}

-(void)repaintHeader:(GenericIndexValue*)genIndexVal{
    NSLog(@"repaintHeader");
    Client *client = [Client findClientByID:@(genIndexVal.deviceID).stringValue];
    GenericIndexValue *headerGenIndexVal = [GenericIndexUtil getClientHeaderGenericIndexValueForClient:client];
    self.genericParams.headerGenericIndexValue = headerGenIndexVal;
    self.genericParams.deviceName = client.name;
    self.genericParams.color = [SFIColors getClientCellColor:client];
    [self.commonView initialize:self.genericParams cellType:ClientProperty_Cell isSiteMap:NO];
}


#pragma mark button taps

- (void)checkButtonTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.clientPropertiesTable];
    NSIndexPath *indexPath = [self.clientPropertiesTable indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil){
        [self tableView: self.clientPropertiesTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (IBAction)historyButtonTap:(id)sender {
    SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //        ctrl.enableDebugMode = YES; // can uncomment for development/test
    ctrl.enableDeleteNotification = NO;
    ctrl.markAllViewedOnDismiss = NO;
    ctrl.isForWifiClients = YES;
    ctrl.deviceID = self.genericParams.headerGenericIndexValue.deviceID;
    ctrl.almondMac = [AlmondManagement currentAlmond].almondplusMAC;
    
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nav_ctrl animated:YES completion:nil];
    
}

- (IBAction)resetButtontap:(id)sender {
    Client *client = [Client findClientByID:@(self.genericParams.headerGenericIndexValue.deviceID).stringValue];
    client = [client copy];
    NSLog(@"client mac %@, client id %@",client.deviceMAC,client.deviceID);
    [self showHudWithTimeoutMsg:[NSString stringWithFormat:NSLocalizedString(@"ClientpropertyViewController Resetting %@", @"Resetting %@"),client.name]];
    if(client.deviceID.length!=0  && client.deviceMAC.length!= 0)
        [ClientPayload resetClientCommand:client.deviceMAC clientID:client.deviceID mii:randomMobileInternalIndex];
}

#pragma mark command resposne
-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"client properties - onDeviceListAndDynamicResponseParsed");
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    NSDictionary *payload = dataInfo[@"data"];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.HUD hide:YES];
    });
    
    NSString *commandType = payload[COMMAND_TYPE];
    if([commandType isEqualToString:@"DynamicAllClientsRemoved"] || [commandType isEqualToString:@"DynamicClientRemoved"]){
        NSDictionary *clientPayload = payload[CLIENTS];
        NSString *clientID = clientPayload.allKeys.firstObject;
        NSLog(@"response client id: %@, present client id: %d", clientID, self.genericParams.headerGenericIndexValue.deviceID);
        if([clientID intValue] == self.genericParams.headerGenericIndexValue.deviceID){
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    }
    //    else{
    //        NSDictionary *clientPayload = payload[CLIENTS];
    //        NSString *clientID = clientPayload.allKeys.firstObject;
    //        if([clientID intValue] == self.genericParams.headerGenericIndexValue.deviceID){
    //            dispatch_async(dispatch_get_main_queue(), ^(){
    //                [self.navigationController popToRootViewControllerAnimated:YES];
    //            });
    //        }
    //    }
    
}

-(void)onCommandResponse:(id)sender{
    NSLog(@"onCommandResponse");
}

#pragma HUD methods
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:10];
    });
}
- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

- (NSDictionary*)parseJson:(NSString*)fileName{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName
                                                         ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:dataFromFile
                                                         options:kNilOptions
                                                           error:&error];
    
    if (error != nil) {
        NSLog(@"Error: was not able to load json file: %@.",fileName);
    }
    return data;
}

@end
