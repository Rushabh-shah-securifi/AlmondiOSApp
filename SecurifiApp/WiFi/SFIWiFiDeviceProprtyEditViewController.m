//
//  SFIWiFiDeviceProprtyEditViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 13.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIWiFiDeviceProprtyEditViewController.h"
#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "AlmondPlusConstants.h"
#import "MDJSON.h"
#import "MBProgressHUD.h"

@interface SFIWiFiDeviceProprtyEditViewController ()<SFIWiFiDeviceTypeSelectionCellDelegate>{
    
    IBOutlet UIView *viewTypeSelection;
    
    IBOutlet UITextField *txtName;
    IBOutlet UIView *viewEditName;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnSave;
    
    
    IBOutlet UIView *viewUsePresence;
    IBOutlet UIButton *btnUsePresence;
    IBOutlet UIView *viewHeader;
    IBOutlet UILabel *lblDeviceName;
    IBOutlet UILabel *lblStatus;
    IBOutlet UITableView *tblTypes;
    
    NSMutableArray * deviceTypes;
    NSMutableArray * connectionTypes;
    NSInteger randomMobileInternalIndex;
    NSString * selectedDeviceType;
    NSString * selectedConnectionType;
    IBOutlet UIImageView *imgIcon;
}

@property(nonatomic, readonly) MBProgressHUD *HUD;

@end

@implementation SFIWiFiDeviceProprtyEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    viewTypeSelection.hidden = YES;
    viewEditName.hidden = YES;
    viewUsePresence.hidden = YES;
    
    deviceTypes = [NSMutableArray new];
    connectionTypes = [NSMutableArray new];
    
    NSArray *tnames = @[@"Tablet",@"PC",@"Laptop",@"Smartphone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"Printer",@"Router_switch",@"Nest",@"Hub",@"Chromecast",@"appleTV",@"Android Stick",@"Other"];
    
    for (NSString * name in tnames) {
        NSMutableDictionary * dict = [NSMutableDictionary new];
        [dict setValue:name forKey:@"name"];
        [dict setValue:@0 forKey:@"selected"];
        if ([[self.connectedDevice.deviceType lowercaseString] isEqualToString:[name lowercaseString]]) {
            [dict setValue:@1 forKey:@"selected"];
        }
        
        [deviceTypes addObject:dict];
    }
    
    NSArray *cnames = @[@"Wired",@"Wireless"];
    for (NSString * name in cnames) {
        NSMutableDictionary * dict = [NSMutableDictionary new];
        [dict setValue:name forKey:@"name"];
        [dict setValue:@0 forKey:@"selected"];
        if ([[self.connectedDevice.deviceConnection lowercaseString] isEqualToString:[name lowercaseString]]) {
            [dict setValue:@1 forKey:@"selected"];
        }
        
        [connectionTypes addObject:dict];
    }
    
    
    lblDeviceName.text = self.connectedDevice.name;
    if (self.connectedDevice.isActive) {
        lblStatus.text = @"CONNECTED";
    }else{
        lblStatus.text = @"NOT CONNECTED";
    }
    UIImage* image = [UIImage imageNamed:[self.connectedDevice iconName]];
    imgIcon.image = image;
    CGRect fr = imgIcon.frame;
    fr.size = image.size;
    fr.origin.x = (90-fr.size.width)/2;
    fr.origin.y = (90-fr.size.height)/2;
    imgIcon.frame = fr;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    randomMobileInternalIndex = arc4random() % 10000;
    txtName.text = self.connectedDevice.name;
    btnUsePresence.selected = self.connectedDevice.deviceUseAsPresence;
    selectedDeviceType = self.connectedDevice.deviceType;
    selectedConnectionType = self.connectedDevice.deviceConnection;
    UIView *currentView;
    switch (self.editFieldIndex) {
        case 0:
        {
            viewEditName.hidden = NO;
            CGRect fr = viewEditName.frame;
            fr.origin.x = viewHeader.frame.origin.x;
            fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
            viewEditName.frame = fr;
            currentView = viewEditName;
            break;
        }
        case 1://Type
        {
            viewTypeSelection.hidden = NO;
            CGRect fr = viewTypeSelection.frame;
            fr.origin.x = viewHeader.frame.origin.x;
            fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
            viewTypeSelection.frame = fr;
            [tblTypes reloadData];
            currentView = viewTypeSelection;
            break;
        }
        case 4://Connection
        {
            viewTypeSelection.hidden = NO;
            CGRect fr = viewTypeSelection.frame;
            fr.origin.x = viewHeader.frame.origin.x;
            fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
            viewTypeSelection.frame = fr;
            [tblTypes reloadData];
            currentView = viewTypeSelection;
            break;
        }
        case 5:
        {
            viewUsePresence.hidden = NO;
            
            CGRect fr = viewUsePresence.frame;
            fr.origin.x = viewHeader.frame.origin.x;
            fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
            viewUsePresence.frame = fr;
            
            btnUsePresence.layer.borderColor = [[UIColor whiteColor] CGColor];
            btnUsePresence.layer.borderWidth = 2.0f;
            btnUsePresence.backgroundColor = [UIColor clearColor];
            
            if (btnUsePresence.selected) {
                btnUsePresence.backgroundColor = [UIColor whiteColor];
            }else{
                btnUsePresence.backgroundColor = [UIColor clearColor];
            }
            currentView = viewUsePresence;
            break;
        }
        default:
            break;
    }
    
    CGRect fr = btnSave.frame;
    fr.origin.y = currentView.frame.origin.y + currentView.frame.size.height-50;
    btnSave.frame = fr;
    
    fr = btnBack.frame;
    fr.origin.y = currentView.frame.origin.y + currentView.frame.size.height-50;
    btnBack.frame = fr;
    [self initializeNotifications];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([txtName isFirstResponder]) {
        [txtName resignFirstResponder];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onWiFiClientsUpdateResponseCallback:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];//md01
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnUsePresenceTap:(id)sender {
    btnUsePresence.selected = !btnUsePresence.selected;
    if (btnUsePresence.selected) {
        btnUsePresence.backgroundColor = [UIColor whiteColor];
    }else{
        btnUsePresence.backgroundColor = [UIColor clearColor];
    }
}

- (IBAction)btnBackTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSaveTap:(id)sender {
    if ([txtName isFirstResponder]) {
        [txtName resignFirstResponder];
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    randomMobileInternalIndex = arc4random() % 10000;
    NSMutableDictionary * updateClientInfo = [NSMutableDictionary new];
    [updateClientInfo setValue:@"UpdateClient" forKey:@"CommandType"];
    [updateClientInfo setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    [updateClientInfo setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
    
    
    NSArray * clients = @[@{@"ID":self.connectedDevice.deviceID,@"Name":txtName.text,@"Connection":selectedConnectionType,@"MAC":self.connectedDevice.deviceMAC,@"Type":[selectedDeviceType lowercaseString],@"LastKnownIP":self.connectedDevice.deviceIP,@"Active":self.connectedDevice.isActive?@"true":@"false",@"UseAsPresence":btnUsePresence.selected?@"true":@"false"}];
    
    [updateClientInfo setValue:clients forKey:@"Clients"];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    cloudCommand.command = [updateClientInfo JSONString];
    
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"wifi.hud.UpdatingWifiClient", @"Updating Wifi Client...");
    
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    [self asyncSendCommand:cloudCommand];
}



#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.editFieldIndex==4) {
        return connectionTypes.count;
    }
    return deviceTypes.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    SFIWiFiDeviceTypeSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFIWiFiDeviceTypeSelectionCell"];
    
    cell.delegate = self;
    if (self.editFieldIndex==4) {
        [cell createPropertyCell:connectionTypes[indexPath.row]];
        cell.textLabel.text = [connectionTypes[indexPath.row] valueForKey:@"name"];
    }else{
        [cell createPropertyCell:deviceTypes[indexPath.row]];
        cell.textLabel.text = [deviceTypes[indexPath.row] valueForKey:@"name"];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Roman" size:17];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
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

#pragma mark tableview cell delegates
- (IBAction)btnSelectTypeTapped:(SFIWiFiDeviceTypeSelectionCell *)cell Info:(NSDictionary *)cellInfo {
    if (self.editFieldIndex==4) {
        for (NSMutableDictionary * dict in connectionTypes) {
            [dict setValue:@0 forKey:@"selected"];
        }
        [cellInfo setValue:@1 forKey:@"selected"];
        [tblTypes reloadData];
        selectedConnectionType = [cellInfo valueForKey:@"name"];
        
    }else{
        for (NSMutableDictionary * dict in deviceTypes) {
            [dict setValue:@0 forKey:@"selected"];
        }
        [cellInfo setValue:@1 forKey:@"selected"];
        [tblTypes reloadData];
        selectedDeviceType = [cellInfo valueForKey:@"name"];
        
    }
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

#pragma mark - Cloud command senders and handlers

- (void)onWiFiClientsUpdateResponseCallback:(id)sender {
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    NSDictionary * mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    
    NSLog(@"%@",mainDict);
    
    if ([[mainDict valueForKey:@"MobileInternalIndex"] integerValue]!=randomMobileInternalIndex) {
        return;
    }
    if ([[mainDict valueForKey:@"Success"] isEqualToString:@"true"]) {
        self.connectedDevice.deviceType = selectedDeviceType;
        self.connectedDevice.deviceUseAsPresence = btnUsePresence.selected;
        self.connectedDevice.name = txtName.text;
        self.connectedDevice.deviceConnection = selectedConnectionType;
        [self.delegate updateDeviceInfo:self.connectedDevice];
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (!self) {
                return;
            }
            
            
            [self.HUD hide:YES];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        return;
    }
}

#pragma mark TextField delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
