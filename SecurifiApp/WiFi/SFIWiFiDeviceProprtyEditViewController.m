//
//  SFIWiFiDeviceProprtyEditViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 13.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIWiFiDeviceProprtyEditViewController.h"
#import "SFIWiFiClientsListViewController.h"
#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "MBProgressHUD.h"
#import "Analytics.h"
#import "CollectionViewCell.h"
#import "SFIColors.h"

@interface SFIWiFiDeviceProprtyEditViewController ()<SFIWiFiDeviceTypeSelectionCellDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>{
    
    IBOutlet UIView *viewTypeSelection;
    
    IBOutlet UIView *viewCollection;
    IBOutlet UICollectionView *collectionViewAllowOnNetwork;
    IBOutlet UIScrollView *collectionViewScroll;
    
    IBOutlet UITextField *txtProperty;
    IBOutlet UIView *viewEditName;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnSave;
    NSString * clientName;
    NSString * clientTimeout;
    
    IBOutlet UIView *viewUsePresence;
    IBOutlet UIButton *btnUsePresence;
    IBOutlet UIView *viewHeader;
    IBOutlet UILabel *lblDeviceName;
    IBOutlet UILabel *lblStatus;
    IBOutlet UITableView *tblTypes;
    
    NSMutableArray * deviceTypes;
    NSMutableArray * connectionTypes;
    NSMutableArray * notifyTypes;
    NSInteger randomMobileInternalIndex;
    NSString * selectedDeviceType;
    NSString * selectedConnectionType;
    
    NSMutableArray * blockedDaysArray;
    NSMutableString *hexBlockedDays;
    NSString *blockedType;
    
    IBOutlet UIImageView *imgIcon;
    IBOutlet UILabel *lblTextEditTitle;
}

@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic)UICollectionView *collectionView;

@end

@implementation SFIWiFiDeviceProprtyEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"SFIWiFiDeviceProprtyEditViewController ");
    viewTypeSelection.hidden = YES;
    viewEditName.hidden = YES;
    viewUsePresence.hidden = YES;
    viewCollection.hidden = YES;
    
    deviceTypes = [NSMutableArray new];
    connectionTypes = [NSMutableArray new];
    notifyTypes = [NSMutableArray new];
    [self initializeblockedDaysArray];
    
    collectionViewAllowOnNetwork.allowsMultipleSelection = YES;
    NSArray *tnames = @[@"Tablet",@"PC",@"Laptop",@"Smartphone",@"iPhone",@"iPad",@"iPod",@"MAC",@"TV",@"Printer",@"Router_switch",@"Nest",@"Hub",@"Camera",@"Chromecast",@"appleTV",@"android_stick",@"Other"];
    
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
    
    NSArray *nnames = @[@"Always",@"When I'm away",@"Never"];
    //    1=Always, 3= when I'm Away, 0=Never
    
    for (NSString * name in nnames) {
        NSMutableDictionary * dict = [NSMutableDictionary new];
        [dict setValue:name forKey:@"name"];
        [dict setValue:@0 forKey:@"selected"];
        if ([[[self.connectedDevice getNotificationNameByType:self.selectedNotificationType] lowercaseString] isEqualToString:[name lowercaseString]]) {
            [dict setValue:@1 forKey:@"selected"];
        }
        [notifyTypes addObject:dict];
    }
    
    lblDeviceName.text = self.connectedDevice.name;
    if (self.connectedDevice.isActive) {
        lblStatus.text = NSLocalizedString(@"wifi.Active",@"ACTIVE");
    }else{
        lblStatus.text = NSLocalizedString(@"wifi.Inactive",@"INACTIVE");
    }
    UIImage* image = [UIImage imageNamed:[self.connectedDevice iconName]];
    imgIcon.image = image;
    CGRect fr = imgIcon.frame;
    fr.size = image.size;
    fr.origin.x = (90-fr.size.width)/2;
    fr.origin.y = (90-fr.size.height)/2;
    imgIcon.frame = fr;
}

-(void)initializeblockedDaysArray{
    blockedDaysArray = [NSMutableArray new];
    for(int i = 0; i <= 6; i++){
        NSMutableDictionary *blockedHours = [NSMutableDictionary new];
        for(int j = 0; j <= 23; j++){
            [blockedHours setValue:@"0" forKey:@(j).stringValue];
        }
        [blockedDaysArray addObject:blockedHours];
    }
    
    NSArray *strings = [self.connectedDevice.deviceSchedule componentsSeparatedByString:@","];
    int dictCount = 0;
    for(NSString *hex in strings){
        NSUInteger hexAsInt;
        NSMutableDictionary *blockedHours = [blockedDaysArray objectAtIndex:dictCount];
        [[NSScanner scannerWithString:hex] scanHexInt:&hexAsInt];
        NSString *binary = [NSString stringWithFormat:@"%@", [self toBinary:hexAsInt]];
        int len = (int)binary.length;
        for (NSInteger charIdx=len-1; charIdx>=0; charIdx--)
            [blockedHours setValue:[NSString stringWithFormat:@"%c", [binary characterAtIndex:charIdx]] forKey:@(len-1-charIdx).stringValue];
        dictCount++;
    }
}


-(NSString *)toBinary:(NSUInteger)input
{
    if (input == 1 || input == 0)
        return [NSString stringWithFormat:@"%lu", (unsigned long)input];
    return [NSString stringWithFormat:@"%@%lu", [self toBinary:input / 2], input % 2];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initializeNotifications];
    //  [collectionViewAllowOnNetwork registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    randomMobileInternalIndex = arc4random() % 10000;
    btnUsePresence.selected = self.connectedDevice.deviceUseAsPresence;
    selectedDeviceType = self.connectedDevice.deviceType;
    selectedConnectionType = self.connectedDevice.deviceConnection;
    UIView *currentView;
    switch (self.editFieldIndex) {
        case nameIndexPathRow:
        {
            lblTextEditTitle.text = NSLocalizedString(@"wifi.textEdit.Name", @"Name");
            txtProperty.placeholder = @"Device Name";
            txtProperty.text = self.connectedDevice.name;
            txtProperty.keyboardType = UIKeyboardTypeDefault;
            
            currentView = viewEditName;
            break;
        }
        case timeoutIndexPathRow:
        {
            
            lblTextEditTitle.text = NSLocalizedString(@"wifi.textEdit.Minutes", @"Minutes");
            txtProperty.placeholder = @"Set Inactivity Timeout";
            txtProperty.text = [NSString stringWithFormat:@"%lu",self.connectedDevice.timeout];
            txtProperty.keyboardType = UIKeyboardTypeNumberPad;
            
            currentView = viewEditName;
            break;
        }
        case typeIndexPathRow://Type
        {
            [tblTypes reloadData];
            currentView = viewTypeSelection;
            break;
        }
        case connectionIndexPathRow://Connection
        {
            [tblTypes reloadData];
            currentView = viewTypeSelection;
            break;
        }
        case allowOnNetworkIndexPathRow:{
            currentView = viewCollection;
            break;
        }
        case usePresenceSensorIndexPathRow:
        {
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
        case notifyMeIndexPathRow://notify me
        {
            [tblTypes reloadData];
            currentView = viewTypeSelection;
            break;
        }
            
        default:
            break;
    }
    
    currentView.hidden = NO;
    CGRect fr = currentView.frame;
    fr.origin.x = viewHeader.frame.origin.x;
    fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
    currentView.frame = fr;
    
    
    fr = btnSave.frame;
    fr.origin.y = currentView.frame.origin.y + currentView.frame.size.height-50;
    btnSave.frame = fr;
    
    fr = btnBack.frame;
    fr.origin.y = currentView.frame.origin.y + currentView.frame.size.height-50;
    btnBack.frame = fr;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([txtProperty isFirstResponder]) {
        [txtProperty resignFirstResponder];
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
    
    [center addObserver:self
               selector:@selector(onClientPreferenceUpdateResponse:)
                   name:NOTIFICATION_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST_NOTIFIER
                 object:nil];
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
    if ([txtProperty isFirstResponder]) {
        [txtProperty resignFirstResponder];
    }
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    randomMobileInternalIndex = arc4random() % 10000;
    NSMutableDictionary * updateClientInfo = [NSMutableDictionary new];
    
    [self convertDaysDictToHex];
    
    
    if (self.editFieldIndex==notifyMeIndexPathRow) {
        [updateClientInfo setValue:@"UpdatePreference" forKey:@"CommandType"];
        [updateClientInfo setValue:self.connectedDevice.deviceID forKey:@"ClientID"];
        [updateClientInfo setValue:self.selectedNotificationType forKey:@"NotificationType"];
        [updateClientInfo setValue:self.userID forKey:@"UserID"];
        cloudCommand.commandType = CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST;
        
    }else{
        [updateClientInfo setValue:@"UpdateClient" forKey:@"CommandType"];
        clientName = self.connectedDevice.name;
        clientTimeout = [NSString stringWithFormat:@"%lu",self.connectedDevice.timeout];
        switch (self.editFieldIndex) {
            case nameIndexPathRow:
                clientName = txtProperty.text;
                break;
            case timeoutIndexPathRow:
                [self checkForValidTimeoutNumber];
                clientTimeout = txtProperty.text;
                break;
                
            default:
                break;
        }
        NSDictionary * clients = @{@"ID":self.connectedDevice.deviceID,@"Name":clientName,@"Connection":[selectedConnectionType lowercaseString],@"MAC":self.connectedDevice.deviceMAC,@"Type":[selectedDeviceType lowercaseString],@"LastKnownIP":self.connectedDevice.deviceIP,@"Active":self.connectedDevice.isActive?@"true":@"false",@"UseAsPresence":btnUsePresence.selected?@"true":@"false",@"Wait":clientTimeout,@"Block":blockedType,@"Schedule":hexBlockedDays};
        
        [updateClientInfo setValue:clients forKey:@"Clients"];
        cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    }
    [updateClientInfo setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    [updateClientInfo setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
    
    
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

-(BOOL)checkIfStringPresent:(NSString*)str {
    BOOL isPresent = NO;
    for(int i = 0; i <=6; i++){
        NSMutableDictionary *blockedHours = [blockedDaysArray objectAtIndex:i];
        for(int j = 23; j >= 0; j--){
            if(![[blockedHours valueForKey:@(j).stringValue] isEqualToString:str]){
                isPresent = YES;
                break;
            }
        }
    }
    return isPresent;
}

-(void)setBlockedType{
    BOOL isZeroPresent = NO;
    BOOL isOnePresent = NO;
    isOnePresent = [self checkIfStringPresent:@"0"];
    isZeroPresent = [self checkIfStringPresent:@"1"];
    
    if(isZeroPresent && isOnePresent){
        blockedType = @(DeviceAllowed_OnSchedule).stringValue;
    }else if(isZeroPresent && !isOnePresent){
        blockedType = @(DeviceAllowed_Always).stringValue;
    }else{
        blockedType = @(DeviceAllowed_Blocked).stringValue;
    }
}

-(void)convertDaysDictToHex{
    hexBlockedDays = [NSMutableString new];
    for(int i = 0; i <= 6; i++){
        NSMutableDictionary *blockedHours = [blockedDaysArray objectAtIndex:i];
        NSMutableString *boolStr = [NSMutableString new];
        for(int j = 23; j >= 0; j--){
            [boolStr appendString:[blockedHours valueForKey:@(j).stringValue]];
        }
        
        NSMutableString *hexStr = [self boolStringToHex:[NSString stringWithString:boolStr]];
        while(6-[hexStr length]){
            [hexStr insertString:@"0" atIndex:0];
        }
        if(i == 0)
            [hexBlockedDays appendString:hexStr];
        else
            [hexBlockedDays appendString:[NSString stringWithFormat:@",%@", hexStr]];
    }
    [self setBlockedType];
    NSLog(@"final hex str: %@", hexBlockedDays);
}

-(NSMutableString*)boolStringToHex:(NSString*)str{
    char* cstr = [str cStringUsingEncoding: NSASCIIStringEncoding];
    NSUInteger len = strlen(cstr);
    char* lastChar = cstr + len - 1;
    NSUInteger curVal = 1;
    NSUInteger result = 0;
    while (lastChar >= cstr) {
        if (*lastChar == '1')
        {
            result += curVal;
        }
        lastChar--;
        curVal <<= 1;
    }
    NSString *resultStr = [NSString stringWithFormat: @"%lx", (unsigned long)result];
    NSLog(@"Result: %@", resultStr);
    return [resultStr mutableCopy];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.editFieldIndex) {
        case typeIndexPathRow:
            return deviceTypes.count;
            break;
        case connectionIndexPathRow:
            return connectionTypes.count;
            break;
        case notifyMeIndexPathRow:
            return notifyTypes.count;
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SFIWiFiDeviceTypeSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SFIWiFiDeviceTypeSelectionCell"];
    
    cell.delegate = self;
    switch (self.editFieldIndex) {
        case typeIndexPathRow:
            [cell createPropertyCell:deviceTypes[indexPath.row]];
            cell.textLabel.text = [deviceTypes[indexPath.row] valueForKey:@"name"];
            break;
        case connectionIndexPathRow:
            [cell createPropertyCell:connectionTypes[indexPath.row]];
            cell.textLabel.text = [connectionTypes[indexPath.row] valueForKey:@"name"];            break;
        case notifyMeIndexPathRow:
            [cell createPropertyCell:notifyTypes[indexPath.row]];
            cell.textLabel.text = [notifyTypes[indexPath.row] valueForKey:@"name"];
            break;
            
        default:
            break;
    }
    
    cell.backgroundColor = [UIColor clearColor];
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
    switch (self.editFieldIndex) {
        case typeIndexPathRow:
            for (NSMutableDictionary * dict in deviceTypes) {
                [dict setValue:@0 forKey:@"selected"];
            }
            [cellInfo setValue:@1 forKey:@"selected"];
            [tblTypes reloadData];
            selectedDeviceType = [cellInfo valueForKey:@"name"];
            
            break;
        case connectionIndexPathRow:
            for (NSMutableDictionary * dict in connectionTypes) {
                [dict setValue:@0 forKey:@"selected"];
            }
            [cellInfo setValue:@1 forKey:@"selected"];
            [tblTypes reloadData];
            selectedConnectionType = [cellInfo valueForKey:@"name"];
            break;
        case notifyMeIndexPathRow:
            for (NSMutableDictionary * dict in notifyTypes) {
                [dict setValue:@0 forKey:@"selected"];
            }
            [cellInfo setValue:@1 forKey:@"selected"];
            [tblTypes reloadData];
            self.selectedNotificationType = [self.connectedDevice getNotificationTypeByName:[cellInfo valueForKey:@"name"]];
            break;
            
        default:
            break;
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
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:plus.almondplusMAC];
    if(local)
        [[SecurifiToolkit sharedInstance] asyncSendToLocal:cloudCommand almondMac:plus.almondplusMAC];
    else{
        [[SecurifiToolkit sharedInstance]asyncSendToCloud:cloudCommand];
    }
}

#pragma mark - Cloud command senders and handlers

- (void)onWiFiClientsUpdateResponseCallback:(id)sender {
    NSLog(@"wifi detail view - onWiFiClientsUpdateResponseCallback");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    NSDictionary *mainDict;
    if(local){
        mainDict = [data valueForKey:@"data"];
    }else{
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }
    
    NSLog(@"%@",mainDict);
    
    if ([[mainDict valueForKey:@"MobileInternalIndex"] integerValue]!=randomMobileInternalIndex) {
        return;
    }
    if ([[mainDict valueForKey:@"Success"] isEqualToString:@"true"]) {
        self.connectedDevice.deviceType = selectedDeviceType;
        self.connectedDevice.deviceUseAsPresence = btnUsePresence.selected;
        self.connectedDevice.name = clientName;
        self.connectedDevice.timeout = [clientTimeout integerValue];
        self.connectedDevice.deviceConnection = selectedConnectionType;
        self.connectedDevice.deviceAllowedType = blockedType.intValue;
        self.connectedDevice.deviceSchedule = hexBlockedDays;
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

- (void)onClientPreferenceUpdateResponse:(id)sender {
    
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
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (!self) {
                return;
            }
            
            
            [self.HUD hide:YES];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
        return;
    }
    
    [[Analytics sharedInstance] markWifiClientUpdate];
}

#pragma mark TextField delegates
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)checkForValidTimeoutNumber{
    if (self.editFieldIndex == timeoutIndexPathRow) {
        NSInteger t = [txtProperty.text integerValue];
        if (t<1) {
            t = 1;
        }
        if (t>60) {
            t = 60;
        }
        txtProperty.text = [NSString stringWithFormat:@"%lu",t];
    }
}
#pragma mark collectionView delegate methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 26;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSLog(@"numberOfItemsInSection");
    return  9;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //You may want to create a divider to scale the size by the way..
    float itemSize = collectionViewAllowOnNetwork.bounds.size.width/10;
    collectionViewScroll.contentSize = CGSizeMake(collectionViewScroll.frame.size.width, 26*itemSize + 26 * ITEM_SPACING + 10);
    return CGSizeMake(itemSize, itemSize);
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2.0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return ITEM_SPACING;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    NSLog(@"minimumInteritemSpacingForSectionAtIndex");
    return ITEM_SPACING;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForItemAtIndexPath: %@", indexPath);
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];
    if(indexPath.row != 0 && indexPath.row != 8 && indexPath.section != 0 && indexPath.section != 25){
        NSMutableDictionary *blockedHours = [blockedDaysArray objectAtIndex:indexPath.row-1];
        NSString *blockedVal = [blockedHours valueForKey:@(indexPath.section-1).stringValue];
        [cell setBlockedVal:(NSString*)blockedVal];
    }
    [cell addDayTimeLable:indexPath];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didSelectItemAtIndexPath: %@ ", indexPath);
    NSMutableDictionary *blockedHours = [blockedDaysArray objectAtIndex:indexPath.row-1];
    [blockedHours setValue:@"1" forKey:@(indexPath.section-1).stringValue];
}
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didDeselectItemAtIndexPath %@", indexPath);
    NSMutableDictionary *blockedHours = [blockedDaysArray objectAtIndex:indexPath.row-1];
    [blockedHours setValue:@"0" forKey:@(indexPath.section-1).stringValue];
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didHighlightItemAtIndexPath: %@", indexPath);
}
-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"didUnhighlightItemAtIndexPath %@", indexPath);
    
}

-(BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(nonnull SEL)action forItemAtIndexPath:(nonnull NSIndexPath *)indexPath withSender:(nullable id)sender{
    return NO;
}


@end
