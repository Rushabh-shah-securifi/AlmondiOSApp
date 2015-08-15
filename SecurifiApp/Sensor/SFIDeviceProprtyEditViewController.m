//
//  SFIDeviceProprtyEditViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 13.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIDeviceProprtyEditViewController.h"
#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "SFIHorizontalValueSelectorView.h"
#import "MBProgressHUD.h"

@interface SFIDeviceProprtyEditViewController ()<SFIWiFiDeviceTypeSelectionCellDelegate,SFIHorizontalValueSelectorViewDataSource,SFIHorizontalValueSelectorViewDelegate>{
    
    IBOutlet UIView *viewTypeSelection;
    
    IBOutlet UITextField *txtName;
    IBOutlet UIView *viewEditName;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnSave;
    
    
    IBOutlet UIView *viewThemperature;
    IBOutlet UIView *viewHeader;
    IBOutlet UILabel *lblDeviceName;
    IBOutlet UILabel *lblStatus;
    IBOutlet UITableView *tblTypes;
    
    NSMutableArray * propertyTypes;
    NSInteger randomMobileInternalIndex;
    NSString * selectedPropertyValue;
    IBOutlet UIImageView *imgIcon;
    IBOutlet UILabel *lblThemperatureMain;
    IBOutlet SFIHorizontalValueSelectorView *coolingTempSelector;
    IBOutlet SFIHorizontalValueSelectorView *heatingTempSelector;
    IBOutlet UIButton *btnShowCelsius;
}

@property(nonatomic, readonly) MBProgressHUD *HUD;

@end

@implementation SFIDeviceProprtyEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    lblDeviceName.text = self.device.deviceName;
    lblStatus.text = @"ok";
    
    if (self.device.deviceType==SFIDeviceType_NestThermostat_57) {
        imgIcon.image = nil;
        
        CGRect fr = lblThemperatureMain.frame;
        fr.size = CGSizeMake(90, 90);
        fr.origin.x = 0;
        fr.origin.y = 0;
        lblThemperatureMain.frame = fr;
        
        lblThemperatureMain.textAlignment = NSTextAlignmentCenter;
        lblThemperatureMain.textColor = [UIColor whiteColor];
        
        SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CURRENT_TEMPERATURE];
        NSString * curTemp = currentDeviceValue.value;
        
        NSString *strTopTitleLabelText = [curTemp stringByAppendingString:@"°"];
        
        NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
        
        [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:36.0f]} range:NSMakeRange(0,curTemp.length)];
        [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:27.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(curTemp.length,@"°".length)];
        
        [lblThemperatureMain setAttributedText:strTemp];
    }
    if (self.device.deviceType==SFIDeviceType_NestSmokeDetector_58) {
        lblThemperatureMain.hidden = YES;
        
        UIImage* image = [UIImage imageNamed:@"nest_58_icon"];
        imgIcon.image = image;
        CGRect fr = imgIcon.frame;
        fr.size = image.size;
        fr.origin.x = (90-fr.size.width)/2;
        fr.origin.y = (90-fr.size.height)/2;
        imgIcon.frame = fr;
    }
    
    viewTypeSelection.hidden = YES;
    viewEditName.hidden = YES;
    viewThemperature.hidden = YES;
    
    propertyTypes = [NSMutableArray new];
    switch (self.editFieldIndex) {
        case 1:
        {
            NSArray *notifyMe_items = @[
                                        NSLocalizedString(@"sensor.notificaiton.segment.Always", @"Always"),
                                        NSLocalizedString(@"sensor.notificaiton.segment.Away", @"Away"),
                                        NSLocalizedString(@"sensor.notificaiton.segment.Off", @"Off"),
                                        ];
            
            switch (self.device.notificationMode) {
                case SFINotificationMode_always:
                    self.selectedNotificationType =notifyMe_items[0];
                    break;
                case SFINotificationMode_away:
                    self.selectedNotificationType =notifyMe_items[1];
                    break;
                case SFINotificationMode_off:
                    self.selectedNotificationType =notifyMe_items[2];
                    break;
                default:
                    break;
            }
            
            //    1=Always, 3= when I'm Away, 0=Never
            int ind = 0;
            for (NSString * name in notifyMe_items) {
                NSMutableDictionary * dict = [NSMutableDictionary new];
                [dict setValue:notifyMe_items[ind] forKey:@"name"];
                [dict setValue:@0 forKey:@"selected"];
                if ([[self.selectedNotificationType lowercaseString] isEqualToString:[name lowercaseString]]) {
                    [dict setValue:@1 forKey:@"selected"];
                }
                [propertyTypes addObject:dict];
                ind++;
            }
            break;
        }
        case 2:
        {
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE];
            
            NSArray *cnames = @[@"On",@"Off"];
            for (NSString * name in cnames) {
                NSMutableDictionary * dict = [NSMutableDictionary new];
                [dict setValue:name forKey:@"name"];
                [dict setValue:@0 forKey:@"selected"];
                if ([[currentDeviceValue.value lowercaseString] isEqualToString:[name lowercaseString]]) {
                    [dict setValue:@1 forKey:@"selected"];
                }
                
                [propertyTypes addObject:dict];
            }
            break;
        }
        case 3:
        {
            SFIDeviceKnownValues *currentDeviceValue1 = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AWAY_MODE];
            NSArray *nnames = @[@"Home",@"Away"];
            
            for (NSString * name in nnames) {
                NSMutableDictionary * dict = [NSMutableDictionary new];
                [dict setValue:name forKey:@"name"];
                [dict setValue:@0 forKey:@"selected"];
                if ([[currentDeviceValue1.value lowercaseString] isEqualToString:[name lowercaseString]]) {
                    [dict setValue:@1 forKey:@"selected"];
                }
                [propertyTypes addObject:dict];
            }
            
            
            break;
        }
        case 4:
        {
            SFIDeviceKnownValues *currentDeviceValue2 = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_MODE];
            NSArray *mnames = @[@"Off",@"Cool",@"Heat",@"Heat-Cool"];
            for (NSString * name in mnames) {
                NSMutableDictionary * dict = [NSMutableDictionary new];
                [dict setValue:name forKey:@"name"];
                [dict setValue:@0 forKey:@"selected"];
                if ([[currentDeviceValue2.value lowercaseString] isEqualToString:[name lowercaseString]]) {
                    [dict setValue:@1 forKey:@"selected"];
                }
                [propertyTypes addObject:dict];
            }
            
            break;
        }
        case 5:
        {
            
        }
        default:
            break;
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    randomMobileInternalIndex = arc4random() % 10000;
    
    UIView *currentView;
    switch (self.editFieldIndex) {
        case 2:
            
            
        case 1:
        case 3:
        case 4:
        {
            viewTypeSelection.hidden = NO;
            CGRect fr = viewTypeSelection.frame;
            fr.origin.x = viewHeader.frame.origin.x;
            fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
            fr.size.height = propertyTypes.count*50+btnSave.frame.size.height+50;
            viewTypeSelection.frame = fr;
            [tblTypes reloadData];
            currentView = viewTypeSelection;
            break;
        }
        case 5:
        {
            viewThemperature.hidden = NO;
            CGRect fr = viewTypeSelection.frame;
            fr.origin.x = viewHeader.frame.origin.x;
            fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
            viewThemperature.frame = fr;
            
            currentView = viewThemperature;
            
            
            coolingTempSelector.dataSource = self;
            coolingTempSelector.delegate = self;
            coolingTempSelector.shouldBeTransparent = YES;
            coolingTempSelector.horizontalScrolling = YES;
            
            heatingTempSelector.dataSource = self;
            heatingTempSelector.delegate = self;
            heatingTempSelector.shouldBeTransparent = YES;
            heatingTempSelector.horizontalScrolling = YES;
            coolingTempSelector.debugEnabled = NO;
            heatingTempSelector.debugEnabled = NO;
            //            [[self selectorHorizontal] setDecelerates:NO];
            
            btnShowCelsius.layer.borderColor = [[UIColor whiteColor] CGColor];
            btnShowCelsius.layer.borderWidth = 2.0f;
            btnShowCelsius.backgroundColor = [UIColor clearColor];
            btnShowCelsius.layer.cornerRadius = btnShowCelsius.frame.size.width/2;
            
            if (btnShowCelsius.selected) {
                btnShowCelsius.backgroundColor = [UIColor whiteColor];
            }else{
                btnShowCelsius.backgroundColor = [UIColor clearColor];
            }
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
    
    viewHeader.backgroundColor = self.cellColor;
    viewTypeSelection.backgroundColor = self.cellColor;
    viewThemperature.backgroundColor = self.cellColor;
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
    
    [center addObserver:self
               selector:@selector(onClientPreferenceUpdateResponse:)
                   name:NOTIFICATION_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST_NOTIFIER
                 object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnBackTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSaveTap:(id)sender {
    if ([txtName isFirstResponder]) {
        [txtName resignFirstResponder];
    }
    
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    randomMobileInternalIndex = arc4random() % 10000;
    NSMutableDictionary * updateClientInfo = [NSMutableDictionary new];
    
    //    if (self.editFieldIndex==6) {
    //        [updateClientInfo setValue:@"UpdatePreference" forKey:@"CommandType"];
    //        [updateClientInfo setValue:self.connectedDevice.deviceID forKey:@"ClientID"];
    //        [updateClientInfo setValue:self.selectedNotificationType forKey:@"NotificationType"];
    //        [updateClientInfo setValue:self.userID forKey:@"UserID"];
    //        cloudCommand.commandType = CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST;
    //
    //    }else{
    //        [updateClientInfo setValue:@"UpdateClient" forKey:@"CommandType"];
    //        NSArray * clients = @[@{@"ID":self.connectedDevice.deviceID,@"Name":txtName.text,@"Connection":selectedConnectionType,@"MAC":self.connectedDevice.deviceMAC,@"Type":[selectedDeviceType lowercaseString],@"LastKnownIP":self.connectedDevice.deviceIP,@"Active":self.connectedDevice.isActive?@"true":@"false",@"UseAsPresence":btnUsePresence.selected?@"true":@"false"}];
    //
    //        [updateClientInfo setValue:clients forKey:@"Clients"];
    //        cloudCommand.commandType = CommandType_UPDATE_REQUEST;
    //    }
    //    [updateClientInfo setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    //    [updateClientInfo setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
    
    
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
    switch (self.editFieldIndex) {
        case 1:
        case 2:
        case 3:
        case 4:
            return propertyTypes.count;
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
        case 1:
        case 2:
        case 3:
        case 4:
            [cell createPropertyCell:propertyTypes[indexPath.row]];
            cell.textLabel.text = [propertyTypes[indexPath.row] valueForKey:@"name"];
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
        case 1:
        case 2:
        case 3:
        case 4:
            for (NSMutableDictionary * dict in propertyTypes) {
                [dict setValue:@0 forKey:@"selected"];
            }
            [cellInfo setValue:@1 forKey:@"selected"];
            [tblTypes reloadData];
            selectedPropertyValue = [cellInfo valueForKey:@"name"];
            
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
        //        self.connectedDevice.deviceType = selectedDeviceType;
        //        self.connectedDevice.deviceUseAsPresence = btnUsePresence.selected;
        //        self.connectedDevice.name = txtName.text;
        //        self.connectedDevice.deviceConnection = selectedConnectionType;
        //        [self.delegate updateDeviceInfo:self.connectedDevice];
        
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
}

#pragma SFIHorizontalValueSelectorView dataSource
- (NSInteger)numberOfRowsInSelector:(SFIHorizontalValueSelectorView *)valueSelector {
    return 13;
}



//ONLY ONE OF THESE WILL GET CALLED (DEPENDING ON the horizontalScrolling property Value)
- (CGFloat)rowHeightInSelector:(SFIHorizontalValueSelectorView *)valueSelector {
    return 48.0;
}

- (CGFloat)rowWidthInSelector:(SFIHorizontalValueSelectorView *)valueSelector {
    return 48.0;
}

- (UIView *)selector:(SFIHorizontalValueSelectorView *)valueSelector viewForRowAtIndex:(NSInteger)index
{
    return [self selector:valueSelector viewForRowAtIndex:index selected:NO];
}

- (UIView *)selector:(SFIHorizontalValueSelectorView *)valueSelector viewForRowAtIndex:(NSInteger)index selected:(BOOL)selected {
    UILabel * label = nil;
    if (valueSelector == coolingTempSelector) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, coolingTempSelector.frame.size.height)];
        label.text = [NSString stringWithFormat:@" %ld°",(long)index+10];
    }
    else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, heatingTempSelector.frame.size.height)];
        label.text = [NSString stringWithFormat:@" %ld°",(long)index+20];
    }
    
    label.textAlignment =  NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    if (selected) {
        label.textColor = [UIColor redColor];
    } else {
        label.textColor = [UIColor blackColor];
    }
    return label;
}

- (CGRect)rectForSelectionInSelector:(SFIHorizontalValueSelectorView *)valueSelector {
    
    if (valueSelector == coolingTempSelector) {
        return CGRectMake(coolingTempSelector.frame.size.width/2 - 35.0, 0.0, 48.0, 48.0);
    }
    else {
        return CGRectMake(heatingTempSelector.frame.size.width/2 - 35.0, 0.0, 48.0, 48.0);
    }
    
}

#pragma SFIHorizontalValueSelectorView delegate
- (void)selector:(SFIHorizontalValueSelectorView *)valueSelector didSelectRowAtIndex:(NSInteger)index {
    NSLog(@"Selected index %ld",(long)index);
}
- (IBAction)btnShowCelsiusTap:(id)sender {
    btnShowCelsius.selected = !btnShowCelsius.selected;
    if (btnShowCelsius.selected) {
        btnShowCelsius.backgroundColor = [UIColor whiteColor];
    }else{
        btnShowCelsius.backgroundColor = [UIColor clearColor];
    }
}
@end
