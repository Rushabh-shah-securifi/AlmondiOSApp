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
#import "URIData.h"
#import "BrowsingHistory.h"
#import "NSDate+Convenience.h"
#import "DataBaseManager.h"


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
@property (nonatomic, readonly) MBProgressHUD *HUD;
@property (nonatomic) NSMutableArray *browsingHistoryDayWise;
@property (nonatomic) dispatch_queue_t imageDownloadQueue;
@property (nonatomic) NSMutableDictionary *urlToImageDict;
@end

@implementation ClientPropertiesViewController
int randomMobileInternalIndex;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.clientPropertiesTable.backgroundColor = self.genericParams.color;
    self.resetView.backgroundColor = self.genericParams.color;
    [self.resetButton setTitleColor: self.genericParams.color forState:UIControlStateNormal];
    [self.historyButton setTitleColor: self.genericParams.color forState:UIControlStateNormal];
    
    [self setHeaderCell];
    [self setUpHUD];
    self.imageDownloadQueue = dispatch_queue_create("img_download", DISPATCH_QUEUE_SERIAL);
//    dispatch_async(self.imageDownloadQueue, ^{
        [self getBrowserHistoryImages];
//    });
    
    
}

-(void)getBrowserHistoryImages{
    NSLog(@"getBrowserHistoryImages");
    self.urlToImageDict = [NSMutableDictionary new];
    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:[NSURL URLWithString:@"https://push-data-mehnaazm.c9users.io/history"]];
//    [request setHTTPMethod:@"POST"];
//
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        dispatch_async(self.imageDownloadQueue, ^{
            NSDictionary *historyData;
//            historyData = [data objectFromJSONData];
            historyData = [DataBaseManager getHistoryData];
//            historyData = [self parseJson:@"temp_copy"];
            NSLog(@"historyData: %@", historyData);
            
            self.browsingHistoryDayWise = [NSMutableArray new];
            NSArray *history = historyData[@"Data"];
    for(NSString *Day in [historyData allKeys]){
        BrowsingHistory *browsingHist = [BrowsingHistory new];
        browsingHist.date = [NSDate convertStirngToDate:Day];
        NSDictionary *dayDict = historyData[Day];
         NSMutableArray *urisArray = [NSMutableArray new];
        for (NSString *time in [dayDict allKeys]) {
            NSDictionary *uriDict = dayDict[time];
            URIData *uri = [URIData new];
            uri.hostName = uriDict[@"Hostname"];
            uri.image = [self getImage:uriDict[@"Hostname"]];
            uri.lastActiveTime = [NSDate getDateFromEpoch:uriDict[@"Epoch"]];
            uri.count = [uriDict[@"Count"] intValue];
            [urisArray addObject:uri];
        }
        browsingHist.URIs = urisArray;
        [self.browsingHistoryDayWise addObject:browsingHist];[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE_FETCH object:nil];
    }
 
//            for(NSDictionary *hisDict in history){
//                BrowsingHistory *browsingHist = [BrowsingHistory new];
//                browsingHist.date = [NSDate convertStirngToDate:hisDict[@"Date"]];
//                
//                NSLog(@"browsing history date: %@", browsingHist.date);
//                NSArray *URIs = hisDict[@"URIs"];
//                NSMutableArray *urisArray = [NSMutableArray new];
//                for(NSDictionary *uriDict in URIs){
//                    URIData *uri = [URIData new];
//                    uri.hostName = uriDict[@"Hostname"];
//                    uri.image = [self getImage:uriDict[@"Hostname"]];
//                    uri.lastActiveTime = [NSDate getDateFromEpoch:uriDict[@"Epoch"]];
//                    uri.count = [uriDict[@"Count"] intValue];
//                    NSLog(@"host: %@, image: %@, lasttime: %@, count: %d", uri.hostName, uri.image, uri.lastActiveTime, uri.count);
//                    [urisArray addObject:uri];
//                }
//                
//                browsingHist.URIs = urisArray;
//                [self.browsingHistoryDayWise addObject:browsingHist];
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IMAGE_FETCH object:nil];
//            }
//        });
//    }] resume];
    NSDictionary *d = @{
                        @"1":@{@"date1":@"data1",
                                @"date2":@"data2"
                                },
                        @"2":@{@"date21":@"data21",
                               @"date22":@"data22"
                               }
                };
    [DataBaseManager InsertRecords:historyData];
    
    
}

-(UIImage*)getImage:(NSString*)hostName{
    NSLog(@"getImage");
    UIImage *img;
    if(self.urlToImageDict[hostName]){
        NSLog(@"one");
        return self.urlToImageDict[hostName]; //todo: fetch locally upto 100 images.
    }else{
        
//        img = [UIImage imageNamed:@"Mail_icon"];
        /*
        NSLog(@"two");
        NSString *iconUrl = [NSString stringWithFormat:@"http://%@/favicon.ico", hostName];
        img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
        //        if(!img){
        //            NSLog(@"three");
        //            iconUrl = [NSString stringWithFormat:@"https://%@/favicon.ico", hostName];
        //            img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
        //        }
        if(!img){
            NSLog(@"four");
            img = [UIImage imageNamed:@"Mail_icon"];
        }
        NSLog(@"five");
        self.urlToImageDict[hostName] = img;
         */
        return img;
    }
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
    self.isLocal = [_toolkit useLocalNetwork:[_toolkit currentAlmond].almondplusMAC];
    
    if(!_isInitialized){ //to avoid call it first time
        NSLog(@"isInitialized");
        self.genericParams.indexValueList = [GenericIndexUtil getClientDetailGenericIndexValuesListForClientID:@(self.genericParams.headerGenericIndexValue.deviceID).stringValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self repaintHeader:self.genericParams.headerGenericIndexValue];
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


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
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
    self.isLocal = [toolkit useLocalNetwork:[toolkit currentAlmond].almondplusMAC];
    if(self.isLocal){
        return self.genericParams.indexValueList.count -1;
    }
    self.historyButton.hidden = NO;
    return self.genericParams.indexValueList.count;
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
        cell.vsluesLabel.alpha = 0.85;
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSLog(@"didSelectRowAtIndexPath");
    GenericIndexValue *gIval = [self.genericParams.indexValueList objectAtIndex:indexPath.row];
    if([gIval.genericIndex.groupLabel isEqualToString:@"Browsing History"]){
       UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:[NSBundle mainBundle]];
        BrowsingHistoryViewController *ctrl = [storyboard instantiateViewControllerWithIdentifier:@"BrowsingHistoryViewController"];
        ctrl.browsingHistoryDayWise = self.browsingHistoryDayWise;
        [self.navigationController pushViewController:ctrl animated:YES];
        
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
    [self.HUD hide:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark setups
-(void)setHeaderCell{
    self.commonView= [[DeviceHeaderView alloc]initWithFrame:CELLFRAME];
    [self.commonView initialize:self.genericParams cellType:ClientProperty_Cell];
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
    [self.commonView initialize:self.genericParams cellType:ClientProperty_Cell];
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
    ctrl.almondMac = _toolkit.currentAlmond.almondplusMAC;
    
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nav_ctrl animated:YES completion:nil];

}

- (IBAction)resetButtontap:(id)sender {
    Client *client = [Client findClientByID:@(self.genericParams.headerGenericIndexValue.deviceID).stringValue];
    client = [client copy];
    NSLog(@"client mac %@, client id %@",client.deviceMAC,client.deviceID);
//    [self]
    [self showHudWithTimeoutMsg:[NSString stringWithFormat:@"Resetting %@",client.name]];
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
    [self.HUD hide:YES];
    
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
