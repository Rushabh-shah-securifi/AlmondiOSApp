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
#import "AlmondJsonCommandKeyConstants.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"


#define NO_ALMOND @"NO ALMOND"
#define CELLFRAME CGRectMake(5, 0, self.view.frame.size.width -10, 60)
#define CELL_IDENTIFIER @"device_cell"

@interface DeviceListController ()<UITableViewDataSource,UITableViewDelegate,DeviceHeaderViewDelegate>
@property (nonatomic,strong)NSMutableArray *currentDeviceList;
@property(nonatomic, strong) NSMutableArray *currentClientList;
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
    [self initializeNotifications];
    DeviceParser *deviceparser = [[DeviceParser alloc]init];
    [deviceparser parseDeviceListAndDynamicDeviceResponse:nil];
    
    randomMobileInternalIndex = arc4random() % 10000;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentAlmond = [toolkit currentAlmond];
    self.currentDeviceList = toolkit.devices;
    self.currentClientList = [self getSortedDevices];

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
    [center addObserver:self selector:@selector(onClientListAndDynamicResponse:) name:NOTIFICATION_DYNAMIC_CLIENTLIST_ADD_UPDATE_REMOVE_NOTIFIER object:nil];
}

-(NSMutableArray*)getSortedDevices{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"isActive" ascending:NO];
    NSSortDescriptor *secondDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, secondDescriptor, nil];
    return [[toolkit.clients sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
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
        return self.currentClientList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{   NSString *header,*headerVal;
    if(section == 0){
        header = @"Sensors ";
        headerVal = [NSString stringWithFormat:@"(%ld)",(long int)self.currentDeviceList.count];
    }
    else{
        headerVal = [NSString stringWithFormat:@"(%ld)",(long int)self.currentClientList.count];
        header = @"Network Devices ";
    }
    
    UIFont *lightFont = [UIFont securifiLightFont:16];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: lightFont forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString = [[NSMutableAttributedString alloc] initWithString:header attributes: arialDict];
    
    UIFont *securifiFont = [UIFont securifiFont:12];
    NSDictionary *verdanaDict = [NSDictionary dictionaryWithObject:securifiFont forKey:NSFontAttributeName];
    NSMutableAttributedString *vAttrString = [[NSMutableAttributedString alloc]initWithString:headerVal  attributes:verdanaDict];
    [aAttrString appendAttributedString:vAttrString];

//    static NSString *header = @"customHeader";
    static NSString *headerView = @"customHeader";
    UITableViewHeaderFooterView *vHeader;
    vHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerView];
    if (!vHeader) {
        vHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerView];
    }
    vHeader.textLabel.textColor = [UIColor lightGrayColor];
    vHeader.textLabel.attributedText = aAttrString;
    
    return vHeader;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.commonView.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.section == 0){
        Device *device = [self.currentDeviceList objectAtIndex:indexPath.row];
        GenericParams *genericParams;
//        if(cell.commonView.genericParams == nil){
            NSLog(@"genericParams is nil");
            genericParams = [[GenericParams alloc]initWithGenericIndexValue:[GenericIndexUtil getHeaderGenericIndexValueForDevice:device] indexValueList:nil deviceName:device.name color:[UIColor yellowColor]];
//        }else {
//            NSLog(@"genericParams not nil");
//            [genericParams setGenericParamsWithGenericIndexValue:[GenericIndexUtil getHeaderGenericIndexValueForDevice:device] indexValueList:nil deviceName:device.name color:[SFIColors clientGreenColor]];
//        }
        
        [cell.commonView initializeSensorCellWithGenericParams:genericParams cellType:SensorTable_Cell];
        [cell.commonView setUpDeviceCell];
        return cell;
    }
    else
    {
        Client *client = [self.currentClientList objectAtIndex:indexPath.row];
        GenericParams *genericParams;
        genericParams = [[GenericParams alloc]initWithGenericIndexValue:[GenericIndexUtil getClientHeaderGenericIndexValueForClient:client] indexValueList:nil deviceName:client.name color:[SFIColors clientGreenColor]];
        [cell.commonView initializeSensorCellWithGenericParams:genericParams cellType:ClientTable_Cell];
        [cell.commonView setUpDeviceCell];
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

-(void)delegateClientSettingButtonClick:(GenericParams*)genericParams{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SensorStoryBoard" bundle:nil];
    ClientPropertiesViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ClientPropertiesViewController"];
    viewController.genericParams = genericParams;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark command responses
-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"onDeviceListAndDynamicResponseParsed");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.currentDeviceList = toolkit.devices;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];

    });
}
-(void)onClientListAndDynamicResponse:(id)sender{
    self.currentClientList = [self getSortedDevices];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
        
    });
}

-(void)onUpdateDeviceIndexResponse:(id)sender{
    NSLog(@"onUpdateDeviceIndexResponse");
    //update image
}

@end
