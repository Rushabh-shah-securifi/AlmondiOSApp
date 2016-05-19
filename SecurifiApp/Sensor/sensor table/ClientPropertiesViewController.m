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

#define CELLFRAME CGRectMake(8, 8, self.view.frame.size.width -16, 70)

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
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end

@implementation ClientPropertiesViewController
int randomMobileInternalIndex;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.clientPropertiesTable.backgroundColor = self.genericParams.color;
    self.resetView.backgroundColor = self.genericParams.color;
    [self.resetButton setTitleColor: self.genericParams.color forState:UIControlStateNormal];
    [self setHeaderCell];
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"client properties - view will appear");
    [super viewWillAppear:YES];
    randomMobileInternalIndex = arc4random() % 10000;
    [self initializeNotifications];
    _toolkit=[SecurifiToolkit sharedInstance];
    self.isLocal = [_toolkit useLocalNetwork:[_toolkit currentAlmond].almondplusMAC];
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

#pragma mark common cell delegate

-(void)delegateClientPropertyEditSettingClick{
    [self.HUD hide:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setHeaderCell{
    self.commonView= [[DeviceHeaderView alloc]initWithFrame:CELLFRAME];
    [self.commonView initialize:self.genericParams cellType:ClientProperty_Cell];
    self.commonView.delegate = self;
    // set up images label and name
    [self.view addSubview:self.commonView];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    self.isLocal = [toolkit useLocalNetwork:[toolkit currentAlmond].almondplusMAC];
    if(self.isLocal){
        return self.genericParams.indexValueList.count -1;
    }
    self.historyButton.hidden = NO;
    return self.genericParams.indexValueList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    NSLog(@"genericValue.displayText %@",genericIndexValue.genericValue.displayText);;
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

- (void)checkButtonTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.clientPropertiesTable];
    NSIndexPath *indexPath = [self.clientPropertiesTable indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil){
        [self tableView: self.clientPropertiesTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath");
    DeviceEditViewController *ctrl = [self.storyboard instantiateViewControllerWithIdentifier:@"DeviceEditViewController"];
    ctrl.genericParams = [[GenericParams alloc]initWithGenericIndexValue:self.genericParams.headerGenericIndexValue
                                                          indexValueList:[NSArray arrayWithObject:[self.genericParams.indexValueList objectAtIndex:indexPath.row]]
                                                              deviceName:self.genericParams.deviceName color:self.genericParams.color isSensor:NO];
    [self.navigationController pushViewController:ctrl animated:YES];
}
- (IBAction)historyButtonTap:(id)sender {
    SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    //        ctrl.enableDebugMode = YES; // can uncomment for development/test
    ctrl.enableDeleteNotification = NO;
    ctrl.markAllViewedOnDismiss = NO;
    ctrl.isForWifiClients = YES;
    ctrl.deviceID = self.genericParams.headerGenericIndexValue.deviceID;
    ctrl.almondMac = _toolkit.currentAlmond.almondplusMAC;
    
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nav_ctrl animated:YES completion:nil];

}

- (IBAction)resetButtontap:(id)sender {
    Client *client = [Client findClientByID:@(self.genericParams.headerGenericIndexValue.deviceID).stringValue];
    client = [client copy];
    NSLog(@"client mac %@, client id %@",client.deviceMAC,client.deviceID);
//    [self]
    [self showHudWithTimeoutMsg:[NSString stringWithFormat:@"reseting %@",client.name]];
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
    NSDictionary *clientPayload = payload[CLIENTS];
    [self.HUD hide:YES];
    if(clientPayload == nil){//to handle removeall
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
    else{
        NSString *clientID = clientPayload.allKeys.firstObject;
        if([clientID intValue] == self.genericParams.headerGenericIndexValue.deviceID){
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    }
    
}


- (void)showHudWithTimeoutMsg:(NSString*)hudMsg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:15];
    });
}
- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

-(void)onCommandResponse:(id)sender{
    NSLog(@"onCommandResponse");
}
@end
