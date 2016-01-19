//
//  SFIWiFiClientsListViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 21.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIWiFiClientsListViewController.h"
#import "SFINotificationsViewController.h"
#import "SFIWiFiClientListCell.h"
#import "SFIWiFiDeviceProprtyEditViewController.h"
#import "MBProgressHUD.h"
#import "SKSTableView.h"
#import "SKSTableViewCell.h"
#import "KeyChainWrapper.h"
#import "Analytics.h"
#import "TimeText.h"

#define AVENIR_HEAVY @"Avenir-Heavy"
#define AVENIR_ROMAN @"Avenir-Roman"
#define AVENIR_LIGHT @"Avenir-Light"
#define SEC_SERVICE_NAME    @"securifiy.login_service"
#define SEC_EMAIL           @"com.securifi.email"

@interface SFIWiFiClientsListViewController ()<SFIWiFiDeviceProprtyEditViewDelegate,SKSTableViewDelegate,SFIWiFiClientListCellDelegate>{
    NSInteger randomMobileInternalIndex;
    IBOutlet SKSTableView *tblDevices;
    SFIConnectedDevice * currentDevice;
    NSIndexPath * currentIndexPath;
    NSArray * propertyNames;
    NSString *userID;
    NSMutableArray * clientsPreferences;
    float propertyRowCellHeight;
    float removeRowCellHeight;
    UIFont * cellFont;
}

@property(nonatomic, readonly) MBProgressHUD *HUD;

@end


@implementation SFIWiFiClientsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    propertyRowCellHeight = 44.0f;
    removeRowCellHeight = 90.0f;
    cellFont = [UIFont fontWithName:AVENIR_ROMAN size:17];
    userID = [KeyChainWrapper retrieveEntryForUser:SEC_EMAIL forService:SEC_SERVICE_NAME];
    currentIndexPath = nil;
    randomMobileInternalIndex = arc4random() % 10000;
    tblDevices.SKSTableViewDelegate = self;
    tblDevices.shouldExpandOnlyOneCell = YES;
    propertyNames = @[@"Name",@"Type",@"MAC Address",@"Last Known IP",@"Connection",@"Use as Presence Sensor",@"Notify me",@"Set Inactivity Timeout",@"Last Active Time", @"View Device History",@"Remove"];
    [self initializeNotifications];
    [self getClientsPreferences];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[Analytics sharedInstance] markWifiClientScreen];
}

- (void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    /*
     1551- Wifi Client Remove All
     */
    [center addObserver:self
               selector:@selector(gotCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onDynamicClientAdded:)
                   name:NOTIFICATION_UPDATE_WIFICLIENT_TABLEVIEW
                 object:nil];
    [center addObserver:self
               selector:@selector(onDynamicClientUpdate:)
                   name:NOTIFICATION_UPDATE_WIFICLIENT_TABLEVIEW
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onDynamicClientUpdate:)
                   name:NOTIFICATION_UPDATE_WIFICLIENT_TABLEVIEW
                 object:nil];
    [center addObserver:self
               selector:@selector(onDynamicClientUpdate:)
                   name:NOTIFICATION_UPDATE_WIFICLIENT_TABLEVIEW
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onDynamicClientRemove:)
                   name:NOTIFICATION_UPDATE_WIFICLIENT_TABLEVIEW
                 object:nil];
    [center addObserver:self
               selector:@selector(onGetClientsPreferences:)
                   name:NOTIFICATION_WIFI_CLIENT_GET_PREFERENCE_REQUEST_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onDynamicClientPreferenceUpdate:)
                   name:NOTIFICATION_WIFI_CLIENT_PREFERENCE_DYNAMIC_UPDATE_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onTabBarDidChange:)
                   name:@"TAB_BAR_CHANGED"
                 object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.connectedDevices count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return propertyNames.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 90.0f;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SFIWiFiClientListCell";
    NSLog(@"cellForRowAtIndexPath");
    SFIWiFiClientListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell){
        cell = [[SFIWiFiClientListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    SFIConnectedDevice *device = self.connectedDevices[indexPath.section];
    NSLog(@"device name: %@", device.name);
    [cell createClientCell:self.connectedDevices[indexPath.section]];
    cell.expandable = YES;
    
    return cell;
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"deviceProperty";
    SFIConnectedDevice * connectedDevice = self.connectedDevices[indexPath.section];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    
    NSInteger subRowIndex = indexPath.subRow-1;
    
    for (UIView *c in cell.subviews) {
        if ([c isKindOfClass:[UILabel class]] || [c isKindOfClass:[UIButton class]]) {
            [c removeFromSuperview];
        }
    }
    
    
    
    [self addCellLabel:cell IndexPath:indexPath];
    
    
    switch (subRowIndex) {
        case nameIndexPathRow://Name
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 220, 0, 180, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = cellFont;
            label.text = connectedDevice.name;
            label.numberOfLines = 1;
            label.tag = 66;
            label.textAlignment = NSTextAlignmentRight;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case typeIndexPathRow://Type
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 200, 0, 170, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = cellFont;
            label.text = [connectedDevice.deviceType capitalizedString];
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentRight;
            label.tag = 66;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case macAddressIndexPathRow://MAC Address
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 215, 0, 200, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
            label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
            label.text = connectedDevice.deviceMAC;
            label.numberOfLines = 1;
            label.tag = 66;
            label.textAlignment = NSTextAlignmentRight;
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell addSubview:label];
            break;
        }
        case iPAddressIndexPathRow://IP Address
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 215, 0, 200, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
            label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
            label.text = connectedDevice.deviceIP;
            label.numberOfLines = 1;
            label.tag = 66;
            label.textAlignment = NSTextAlignmentRight;
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell addSubview:label];
            break;
        }
        case connectionIndexPathRow://Connection
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 220, 0, 180, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];//colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
            label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
            label.text = [connectedDevice.deviceConnection capitalizedString];
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentRight;
            label.tag = 66;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case timeoutIndexPathRow:
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 220, 0, 180, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
            label.text = [NSString stringWithFormat:@"%lu",connectedDevice.timeout];
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentRight;
            label.tag = 66;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case lastActiveTimeIndexPathRow:
        {
            if (!((SFIConnectedDevice*)self.connectedDevices[indexPath.section]).isActive){
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 215, 0, 200, propertyRowCellHeight)];
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor colorWithRed:168/255.0f green:218/255.0f blue:170/255.0f alpha:1];
                label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
                label.text = [TimeText getTime:[connectedDevice.deviceLastActiveTime integerValue]];
                label.numberOfLines = 1;
                label.tag = 66;
                label.textAlignment = NSTextAlignmentRight;
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell addSubview:label];
            }
            break;
        }
        case usePresenceSensorIndexPathRow://Use as presence Sensor
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 220, 0, 180, propertyRowCellHeight)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = cellFont;
            if (connectedDevice.deviceUseAsPresence) {
                label.text = NSLocalizedString(@"Presence sensor Yes",@"Yes");
            }else{
                label.text = NSLocalizedString(@"Presence sensor NO",@"No");
            }
            label.tag = 66;
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentRight;
            [cell addSubview:label];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case notifyMeIndexPathRow://Notify me
        {
            if (((SFIConnectedDevice*)self.connectedDevices[indexPath.section]).deviceUseAsPresence){
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDevices.frame.size.width - 220, 0, 180, propertyRowCellHeight)];
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor whiteColor];
                label.font = [UIFont fontWithName:AVENIR_ROMAN size:15];
                label.text = [connectedDevice getNotificationNameByType:[self getNotificationTypeForDevice:connectedDevice.deviceID]];
                label.numberOfLines = 1;
                label.textAlignment = NSTextAlignmentRight;
                label.tag = 66;
                [cell addSubview:label];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        }
        case removeButtonIndexPathRow://Remove button
        {
            cell = [self createRemoveButtonCell:cell];
            break;
        }
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-  (void)addCellLabel:(UITableViewCell*)cell IndexPath:(NSIndexPath *)indexPath{
    NSInteger subRowIndex = indexPath.subRow-1;
    if (!((SFIConnectedDevice*)self.connectedDevices[indexPath.section]).deviceUseAsPresence && (subRowIndex==notifyMeIndexPathRow || subRowIndex==historyIndexPathRow)) {
        return;
    }
    if (((SFIConnectedDevice*)self.connectedDevices[indexPath.section]).isActive  && subRowIndex==lastActiveTimeIndexPathRow) {
        return;
    }
    UIView * bgView = [[UIView alloc] init];
    if (subRowIndex!=removeButtonIndexPathRow) {
        bgView.frame = CGRectMake(0, 0, tblDevices.frame.size.width, propertyRowCellHeight);
    }else{
        bgView.frame = CGRectMake(0, 0, tblDevices.frame.size.width, removeRowCellHeight-10);
    }
    bgView.backgroundColor = [UIColor colorWithRed:75/255.0f green:174/255.0f blue:79/255.0f alpha:1];
    bgView.tag = 66;
    [cell addSubview:bgView];
    
    
    CGSize textSize = [propertyNames[subRowIndex] sizeWithFont:cellFont constrainedToSize:CGSizeMake(200, 50)];
    
    if (subRowIndex!=removeButtonIndexPathRow) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, textSize.width + 5, propertyRowCellHeight)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = cellFont;
        label.tag = 66;
        
        if (subRowIndex==historyIndexPathRow) {
            NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            label.attributedText = [[NSAttributedString alloc] initWithString:propertyNames[subRowIndex]                                                                  attributes:underlineAttribute];
        }else{
            label.text = propertyNames[subRowIndex];
        }
        label.numberOfLines = 1;
        [cell addSubview:label];
    }
}

- (UITableViewCell*)createRemoveButtonCell:(UITableViewCell*)cell{
    UIButton * btnRemove = [[UIButton alloc] init];
    btnRemove.frame = CGRectMake(tblDevices.frame.size.width / 2 - 70, 23, 140, 44);
    btnRemove.backgroundColor = [UIColor whiteColor];
    [btnRemove setTitle:NSLocalizedString(@"wifi.button.deleteClient", @"Remove") forState:UIControlStateNormal];
    [btnRemove setTitleColor:[UIColor colorWithRed:74/255.0f green:175/255.0f blue:79/255.0f alpha:1] forState:UIControlStateNormal];
    [btnRemove.titleLabel setFont:[UIFont fontWithName:AVENIR_ROMAN size:17]];
    [btnRemove addTarget:self action:@selector(btnRemoveTap:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnRemove];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger subrowIndex = indexPath.subRow-1;
    
    if (!((SFIConnectedDevice*)self.connectedDevices[indexPath.section]).deviceUseAsPresence && (subrowIndex==notifyMeIndexPathRow || subrowIndex==historyIndexPathRow)) {
        return 0;//will hide
    }
    if (((SFIConnectedDevice*)self.connectedDevices[indexPath.section]).isActive  && subrowIndex==lastActiveTimeIndexPathRow) {
        return 0;
    }
    if (subrowIndex==removeButtonIndexPathRow) {
        return removeRowCellHeight;
    }
    
    return 44.0f;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath == currentIndexPath) {
        return YES;
    }
    return NO;
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger subRowIndex = indexPath.subRow-1;
    switch (subRowIndex) {
        case nameIndexPathRow://Name
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.editFieldIndex = subRowIndex;
            viewController.delegate = self;
            viewController.connectedDevice = self.connectedDevices[indexPath.section];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case typeIndexPathRow://Type
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.delegate = self;
            viewController.editFieldIndex = subRowIndex;
            viewController.connectedDevice = self.connectedDevices[indexPath.section];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case macAddressIndexPathRow://MAC Address
        {
            
            break;
        }
        case iPAddressIndexPathRow://IP Address
        {
            break;
        }
        case connectionIndexPathRow://Connection
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.delegate = self;
            viewController.editFieldIndex = subRowIndex;
            viewController.connectedDevice = self.connectedDevices[indexPath.section];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case usePresenceSensorIndexPathRow://Use as presence Sensor
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.delegate = self;
            viewController.editFieldIndex = subRowIndex;
            viewController.connectedDevice = self.connectedDevices[indexPath.section];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case timeoutIndexPathRow:
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.delegate = self;
            viewController.editFieldIndex = subRowIndex;
            viewController.connectedDevice = self.connectedDevices[indexPath.section];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case notifyMeIndexPathRow://Notify me
        {
            SFIWiFiDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIWiFiDeviceProprtyEditViewController"];
            viewController.userID = userID;
            viewController.selectedNotificationType = [self getNotificationTypeForDevice:((SFIConnectedDevice*) self.connectedDevices[indexPath.section]).deviceID];
            viewController.delegate = self;
            viewController.editFieldIndex = subRowIndex;
            viewController.connectedDevice = self.connectedDevices[indexPath.section];
            [self.navigationController pushViewController:viewController animated:YES];
            break;
        }
        case historyIndexPathRow:
        {
            [self showSensorLogs:indexPath];
        }
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0000001;
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    currentIndexPath = indexPath;
//    currentDevice = self.connectedDevices[indexPath.section];
//    return;
//}
#pragma mark Cell Delegates
- (void)btnSettingTapped:(SFIWiFiClientListCell *)cell Info:(SFIConnectedDevice *)connectedDevice{
    NSIndexPath * indexPath = [tblDevices indexPathForCell:cell];
    currentIndexPath = indexPath;
    currentDevice = self.connectedDevices[indexPath.section];
    [tblDevices expandCell:tblDevices didSelectRowAtIndexPath:indexPath];
    //    [self tableView:tblDevices didSelectRowAtIndexPath:indexPath];
}

#pragma mark Detail View Delegates
-(IBAction)btnRemoveTap:(id)sender{
    currentIndexPath = nil;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    NSMutableDictionary *commandInfo = [NSMutableDictionary new];
    
    [commandInfo setValue:@"RemoveClient" forKey:@"CommandType"];
    
    NSInteger randomNumber = arc4random() % 10000;
    [commandInfo setValue:@(randomNumber) forKey:@"MobileInternalIndex"];
    
    [commandInfo setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    [commandInfo setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
    
    [commandInfo setValue:@{@"ID":currentDevice.deviceID,@"MAC":currentDevice.deviceMAC} forKey:@"Clients"];
    
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [commandInfo JSONString];
    
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"wifi.hud.removeClient", @"Deleting wifi client...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    [self asyncSendCommand:cloudCommand];
    
}

#pragma mark

#pragma mark - Cloud command senders and handlers
- (void)gotCommandResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    
    if (randomMobileInternalIndex!=[[mainDict valueForKey:@"MobileInternalIndex"] integerValue]) {
        return;
    }
    
    [self.HUD hide:YES];
    NSString * success = [mainDict valueForKey:@"Success"];
    
    if (![success isEqualToString:@"true"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"response.alert-Oops",@"Oops") message:NSLocalizedString(@"response.alert-Sorry, There was some problem with this request, try later!",@"Sorry, There was some problem with this request, try later!")
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"response.alert-OK",@"OK") otherButtonTitles: nil];
        [alert show];
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.connectedDevices removeObject:currentDevice];
            //            [tblDevices reloadData];
            [tblDevices refreshData];
        });
    }
}

- (void)onDynamicClientUpdate:(id)sender {
    NSLog(@"onDynamicClientUpdate table view");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.connectedDevices = toolkit.wifiClientParser;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [tblDevices refreshData];
        //
    });

}

- (void)onDynamicClientAdded:(id)sender {
   NSLog(@"dynamic Added table view");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    self.connectedDevices = toolkit.wifiClientParser;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [tblDevices refreshData];
        //
    });
}

- (void)onDynamicClientRemove:(id)sender {
 
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    self.connectedDevices = toolkit.wifiClientParser;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [tblDevices refreshData];
        //
    });
}

- (void)onGetClientsPreferences:(id)sender {
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    
    if ([[mainDict valueForKey:@"Success"] isEqualToString:@"true"]) {
        clientsPreferences = [[mainDict valueForKey:@"ClientPreferences"] mutableCopy];
    }
}

- (void)onDynamicClientPreferenceUpdate:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    // && [[mainDict valueForKey:@"UserID"] isEqualToString:userID]
    NSString *aMac = [mainDict valueForKey:@"AlmondMAC"];
    
    if (([[mainDict valueForKey:@"CommandType"] isEqualToString:@"UpdatePreference"] || [[mainDict valueForKey:@"commandtype"] isEqualToString:@"UpdatePreference"]) && [aMac isEqualToString:plus.almondplusMAC]) {//TEST
        
        [self updatePreferenceInfo:@{@"ClientID":[mainDict valueForKey:@"ClientID"],@"NotificationType":[mainDict valueForKey:@"NotificationType"]}];
    }
}

- (void)updatePreferenceInfo:(NSDictionary *)preferenceInfo{
    
    BOOL found = NO;
    for (int i=0; i<clientsPreferences.count; i++) {
        NSDictionary * dict = clientsPreferences[i];
        if ([[dict valueForKey:@"ClientID"] intValue] ==[[preferenceInfo valueForKey:@"ClientID"] intValue]) {
            [clientsPreferences replaceObjectAtIndex:i withObject:preferenceInfo];
            found = YES;
            break;
        }
    }
    if (!found) {
        [clientsPreferences addObject:preferenceInfo];
    }
    int index = 0;
    
    for (SFIConnectedDevice * device in self.connectedDevices) {
        if ([device.deviceID intValue]==[[preferenceInfo valueForKey:@"ClientID"] intValue]) {
            dispatch_async(dispatch_get_main_queue(), ^() {
                [tblDevices refreshData];
                //                [tblDevices reloadSections:[NSIndexSet indexSetWithIndex:index]  withRowAnimation:UITableViewRowAnimationNone];
            });
            
            break;
        }
        index++;
    }
}

#pragma mark
- (void)getClientsPreferences{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    NSMutableDictionary *commandInfo = [NSMutableDictionary new];
    
    [commandInfo setValue:@"GetClientPreferences" forKey:@"CommandType"];
    [commandInfo setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    [commandInfo setValue:userID forKey:@"UserID"];
    
    
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST;
    cloudCommand.command = [commandInfo JSONString];
    
    [self asyncSendCommand:cloudCommand];
    
}

- (NSString*)getNotificationTypeForDevice:(NSString*)clientID{
    for (NSDictionary * dict in clientsPreferences) {
        if ([[dict valueForKey:@"ClientID"] intValue]==[clientID intValue]) {
            return [dict valueForKey:@"NotificationType"];
        }
    }
    
    return @"";
}

- (void)onTabBarDidChange:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (![[data valueForKey:@"title"] isEqualToString:@"Router"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
#pragma mark
- (void)showSensorLogs:(NSIndexPath*)indexPath{
    SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    ctrl.enableDeleteNotification = NO;
    ctrl.markAllViewedOnDismiss = NO;
    ctrl.isForWifiClients = YES;
    SFIConnectedDevice * connectedDevice = self.connectedDevices[indexPath.section];
    ctrl.deviceID = (unsigned int)[connectedDevice.deviceID integerValue];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    ctrl.almondMac = plus.almondplusMAC;
    
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nav_ctrl animated:YES completion:nil];
}

#pragma mark - HUD mgt

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}
- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}
#pragma mark Edit View delegates
- (void)updateDeviceInfo:(SFIConnectedDevice *)deviceInfo{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [tblDevices refreshDataWithScrollingToIndexPath:currentIndexPath];
    });
}
@end
