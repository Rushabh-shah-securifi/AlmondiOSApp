//
//  SFIDeviceProprtyEditViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 13.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//
typedef NS_ENUM(NSInteger, Properties) {
    nameIndexPathRow,
    locationIndexPathRow,
    humidityIndexPathRow,
    awayModeIndexPathRow,
    coLevelIndexPathRow,
    smokeLevelIndexPathRow,
    modeIndexPathRow,
    targetRangeIndexPathRow,
    fanIndexPathRow,
    notifyMeIndexPathRow,
    deviceHistoryIndexPathRow,
};

#import "SFIDeviceProprtyEditViewController.h"
#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "SFIHorizontalValueSelectorView.h"
#import "UIViewController+Securifi.h"
#import "MBProgressHUD.h"

@interface SFIDeviceProprtyEditViewController ()<SFIWiFiDeviceTypeSelectionCellDelegate,SFIHorizontalValueSelectorViewDataSource,SFIHorizontalValueSelectorViewDelegate>{
    
    IBOutlet UIView *viewTypeSelection;
    
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
    sfi_id dc_id;
    IBOutlet UILabel *lblCooling;
    IBOutlet UILabel *lblHeating;
    IBOutlet UILabel *lblShow;
    IBOutlet UILabel *lblCelsius;
    IBOutlet UILabel *lblFahrenheit;
    IBOutlet UIButton *btnFahrenheit;
    
    NSInteger currentCoolTemp;
    NSInteger currentHeatTemp;
}

@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic) NSTimer *mobileCommandTimer;

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
        lblThemperatureMain.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:36.0f];
        lblThemperatureMain.textAlignment = NSTextAlignmentCenter;
        lblThemperatureMain.textColor = [UIColor whiteColor];
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
    viewThemperature.hidden = YES;
    
    propertyTypes = [NSMutableArray new];
    
    switch (self.editFieldIndex) {
        case notifyMeIndexPathRow:
        {
            NSArray *notifyMe_items = @[
                                        NSLocalizedString(@"sensor.notificaiton.segment.Always", @"Always"),
                                        NSLocalizedString(@"sensor.notificaiton.segment.Away", @"Away"),
                                        NSLocalizedString(@"sensor.notificaiton.segment.Off", @"Off"),
                                        ];
            
            switch (self.device.notificationMode) {
                case SFINotificationMode_always:
                    selectedPropertyValue =notifyMe_items[0];
                    break;
                case SFINotificationMode_away:
                    selectedPropertyValue =notifyMe_items[1];
                    break;
                case SFINotificationMode_off:
                    selectedPropertyValue =notifyMe_items[2];
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
                if ([[selectedPropertyValue lowercaseString] isEqualToString:[name lowercaseString]]) {
                    [dict setValue:@1 forKey:@"selected"];
                }
                [propertyTypes addObject:dict];
                ind++;
            }
            break;
        }
        case fanIndexPathRow:
        {
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE];
            
            NSArray *cnames = @[@"On",@"Off"];
            
            
            if ([currentDeviceValue.value isEqualToString:@"true"]) {
                selectedPropertyValue = @"On";
            }else if ([currentDeviceValue.value isEqualToString:@"false"]){
                selectedPropertyValue = @"Off";
            }else{
                selectedPropertyValue = @"";
            }
            for (NSString * name in cnames) {
                NSMutableDictionary * dict = [NSMutableDictionary new];
                [dict setValue:name forKey:@"name"];
                [dict setValue:@0 forKey:@"selected"];
                if ([selectedPropertyValue isEqualToString:name]) {
                    [dict setValue:@1 forKey:@"selected"];
                }
                
                [propertyTypes addObject:dict];
            }
            break;
        }
        case awayModeIndexPathRow:
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
        case modeIndexPathRow:
        {
            
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_MODE];
            selectedPropertyValue = currentDeviceValue.value;
            NSArray *mnames = @[@"Off",@"Cool",@"Heat",@"Heat-Cool"];
            
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_COOL];
            BOOL canCool = [currentDeviceValue boolValue];
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_HEAT];
            BOOL canHeat = [currentDeviceValue boolValue];
            
            if (!canCool) {
                mnames = @[@"Off",@"Heat"];
            }
            if (!canHeat) {
                mnames = @[@"Off",@"Cool"];
            }
            
            
            for (NSString * name in mnames) {
                NSMutableDictionary * dict = [NSMutableDictionary new];
                [dict setValue:name forKey:@"name"];
                [dict setValue:@0 forKey:@"selected"];
                if ([[selectedPropertyValue lowercaseString] isEqualToString:[name lowercaseString]]) {
                    [dict setValue:@1 forKey:@"selected"];
                }
                [propertyTypes addObject:dict];
            }
            
            break;
        }
        case targetRangeIndexPathRow:
        {
            SFIDeviceKnownValues *currentDeviceValue1 = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_THERMOSTAT_RANGE_LOW];
            currentCoolTemp = [currentDeviceValue1 intValue];
            SFIDeviceKnownValues *currentDeviceValue2 = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH];
            currentCoolTemp = [currentDeviceValue2 intValue];
            break;
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
        case awayModeIndexPathRow:
        case modeIndexPathRow:
        case fanIndexPathRow:
        case notifyMeIndexPathRow:
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
        case targetRangeIndexPathRow:
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
            coolingTempSelector.debugEnabled = NO;
            
            heatingTempSelector.dataSource = self;
            heatingTempSelector.delegate = self;
            heatingTempSelector.shouldBeTransparent = YES;
            heatingTempSelector.horizontalScrolling = YES;
            heatingTempSelector.debugEnabled = NO;
            //            [[self selectorHorizontal] setDecelerates:NO];
            
            btnShowCelsius.layer.borderColor = [[UIColor whiteColor] CGColor];
            btnShowCelsius.layer.borderWidth = 2.0f;
            btnShowCelsius.backgroundColor = [UIColor clearColor];
            btnShowCelsius.layer.cornerRadius = btnShowCelsius.frame.size.width/2;
            
            btnFahrenheit.layer.borderColor = [[UIColor whiteColor] CGColor];
            btnFahrenheit.layer.borderWidth = 2.0f;
            btnFahrenheit.backgroundColor = [UIColor clearColor];
            btnFahrenheit.layer.cornerRadius = btnShowCelsius.frame.size.width/2;
            [self configureTemperatureFormatButtons];
            
            
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_MODE];
            
            if([[currentDeviceValue.value lowercaseString] isEqualToString:@"cool"]){
                heatingTempSelector.hidden = YES;
                lblHeating.hidden = YES;
                fr = lblShow.frame;
                fr.origin.y =lblHeating.frame.origin.y;
                lblShow.frame = fr;
                
                fr = lblCelsius.frame;
                fr.origin.y =lblHeating.frame.origin.y+30;
                lblCelsius.frame = fr;
                
                fr = btnShowCelsius.frame;
                fr.origin.y =lblHeating.frame.origin.y+30;
                btnShowCelsius.frame = fr;
            }
            if([[currentDeviceValue.value lowercaseString] isEqualToString:@"heat"]){
                fr = lblShow.frame;
                fr.origin.y =lblHeating.frame.origin.y;
                lblShow.frame = fr;
                
                fr = lblCelsius.frame;
                fr.origin.y =lblHeating.frame.origin.y+30;
                lblCelsius.frame = fr;
                
                fr = btnShowCelsius.frame;
                fr.origin.y =lblHeating.frame.origin.y+30;
                btnShowCelsius.frame = fr;
                
                coolingTempSelector.hidden = YES;
                lblCooling.hidden = YES;
                heatingTempSelector.frame = coolingTempSelector.frame;
                lblHeating.frame = lblCooling.frame;
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
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(onMobileCommandResponseCallback:)
                   name:MOBILE_COMMAND_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onNotificationPrefDidChange:)
                   name:kSFINotificationPreferencesDidChange
                 object:nil];
}

//- (void)updateThemperatureDataOnUI{
//    if ([SecurifiToolkit sharedInstance] isFahrenheit) {
//        currentCoolTemp = [currentDeviceValue1 intValue];
//        currentCoolTemp = [currentDeviceValue2 intValue];
//    }
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnBackTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSaveTap:(id)sender {
    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"sensor.hud.UpdatingSensordata", @"Updating Sensor Data...");
    
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    
    
    SFIDevicePropertyType propertyType;
    SFIDeviceKnownValues *deviceValues;
    switch (self.editFieldIndex) {
        case notifyMeIndexPathRow:
        {
            SFINotificationMode mode = SFINotificationMode_always;
            if ([selectedPropertyValue isEqualToString:@"Always"]) {
                mode = SFINotificationMode_always;
            }
            if ([selectedPropertyValue isEqualToString:@"Away"]) {
                mode = SFINotificationMode_away;
            }
            if ([selectedPropertyValue isEqualToString:@"Off"]) {
                mode = SFINotificationMode_off;
            }
            [self sensorDidChangeNotificationSetting:mode];
            break;
        }
        case fanIndexPathRow:
            propertyType = SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            if ([selectedPropertyValue isEqualToString:@"On"]) {
                deviceValues.value = @"true";
            }else if ([selectedPropertyValue isEqualToString:@"Off"]){
                deviceValues.value = @"false";
            }else{
                deviceValues.value = @"";
            }
            
            break;
        case awayModeIndexPathRow:
            propertyType = SFIDevicePropertyType_AWAY_MODE;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            deviceValues.value = [selectedPropertyValue lowercaseString];
            break;
        case modeIndexPathRow:
            propertyType = SFIDevicePropertyType_NEST_THERMOSTAT_MODE;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            deviceValues.value = [selectedPropertyValue lowercaseString];
            break;
        case targetRangeIndexPathRow:
            
            break;
        default:
            break;
    }
    
    
    
    // provisionally update; on mobile cmd response, the actual new values will be set
    self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
    
    //    [self showSavingToast];
    [self sendMobileCommandForDevice:self.device deviceValue:deviceValues];
    
    
    
    //    [self asyncSendCommand:cloudCommand];
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
        case awayModeIndexPathRow:
        case fanIndexPathRow:
        case modeIndexPathRow:
        case notifyMeIndexPathRow:
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
        case awayModeIndexPathRow:
        case fanIndexPathRow:
        case modeIndexPathRow:
        case notifyMeIndexPathRow:
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
        case awayModeIndexPathRow:
        case fanIndexPathRow:
        case modeIndexPathRow:
        case notifyMeIndexPathRow:
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

#pragma mark Temperature Selectoios
#pragma SFIHorizontalValueSelectorView dataSource
- (NSInteger)numberOfRowsInSelector:(SFIHorizontalValueSelectorView *)valueSelector {
    
    if ([valueSelector isEqual:coolingTempSelector]) {
        //50 - (currentHeatTemp-3)
        return (currentHeatTemp-3)-50;
    }
    if ([valueSelector isEqual:heatingTempSelector]) {
        return 90-(currentCoolTemp+3);
    }
    
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
    [[SecurifiToolkit sharedInstance] setCurrentTemperatureFormatFahrenheit:NO];
    [self configureTemperatureFormatButtons];
}

- (IBAction)btnShowFahrenheitTap:(id)sender {
    [[SecurifiToolkit sharedInstance] setCurrentTemperatureFormatFahrenheit:YES];
    [self configureTemperatureFormatButtons];
}

- (void)configureTemperatureFormatButtons{
    if ([[SecurifiToolkit sharedInstance] isCurrentTemperatureFormatFahrenheit]) {
        btnFahrenheit.backgroundColor = [UIColor whiteColor];
        btnShowCelsius.backgroundColor = [UIColor clearColor];
        btnFahrenheit.selected = YES;
        btnShowCelsius.selected = NO;
    }else{
        btnFahrenheit.backgroundColor = [UIColor clearColor];
        btnShowCelsius.backgroundColor = [UIColor whiteColor];
        btnShowCelsius.selected = YES;
        btnFahrenheit.selected = NO;
    }
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CURRENT_TEMPERATURE];
    lblThemperatureMain.text = [NSString stringWithFormat:@"%d°",[[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:[currentDeviceValue intValue]]];
}
#pragma mark - Cloud command senders and handlers



- (void)sendMobileCommandForDevice:(SFIDevice *)device deviceValue:(SFIDeviceKnownValues *)deviceValues {
    if (device == nil) {
        return;
    }
    if (deviceValues == nil) {
        return;
    }
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    // Tell the cell to show 'updating' type message to user
    //    [cell showUpdatingMessage];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        //todo decide what to do about this
        [self.mobileCommandTimer invalidate];
        
        self.mobileCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                   target:self
                                                                 selector:@selector(onSendMobileCommandTimeout:)
                                                                 userInfo:nil
                                                                  repeats:NO];
        
        // dispatch request and keep track of its correlation ID so we can process the response
        //todo for future: note potential race condition: if we do not process command response on main queue it's possible response is processed before we have completed marking updating state.
        dc_id = [[SecurifiToolkit sharedInstance] asyncChangeAlmond:plus device:device value:deviceValues];
        //        [self markDeviceUpdatingState:device correlationId:c_id statusMessage:nil];
    });
}

- (void)onSendMobileCommandTimeout:(id)sender {
    
    
    [self.mobileCommandTimer invalidate];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        //Cancel the mobile event - Revert back
        [self.HUD hide:YES];
    });
}

- (void)onMobileCommandResponseCallback:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        
        if (self.isViewLoaded) {
            [self.HUD hide:YES];
        }
        
        // Timeout the commander timer
        [self.mobileCommandTimer invalidate];
        
        NSNotification *notifier = (NSNotification *) sender;
        NSDictionary *data = [notifier userInfo];
        if (data == nil) {
            return;
        }
        
        MobileCommandResponse *res = data[@"data"];
        sfi_id c_id = res.mobileInternalIndex;
        
        if (res.isSuccessful && c_id == dc_id) {
            // command succeeded; clear "status" state; new device values should be transmitted
            // via different callback and handled there.
            [self.delegate updateDeviceInfo:self.device :self.deviceValue];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            NSString *status = res.reason;
            if (status.length > 0) {
                //                [self markDeviceUpdatingState:device correlationId:c_id statusMessage:status];
                [self showToast:status];
            }
            else {
                // it failed but we did not receive a reason; clear the updating state and pretend nothing happened.
                [self showToast:@"Unable to update sensor"];
            }
            
            //            [self reloadDeviceTableCellForDevice:device];
        }
    });
}

- (void)onNotificationPrefDidChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }
    if (self.isViewLoaded) {
        [self.HUD hide:YES];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        
        [self.delegate updateDeviceInfo:self.device :self.deviceValue];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark

- (void)sensorDidChangeNotificationSetting:(SFINotificationMode)newMode {
    //Send command to set notification
    
    NSArray *notificationDeviceSettings = [self.device updateNotificationMode:newMode deviceValue:self.deviceValue];
    
    
    NSString *action = (newMode == SFINotificationMode_off) ? kSFINotificationPreferenceChangeActionDelete : kSFINotificationPreferenceChangeActionAdd;
    
    //    [self showSavingToast];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    [[SecurifiToolkit sharedInstance] asyncRequestNotificationPreferenceChange:plus.almondplusMAC deviceList:notificationDeviceSettings forAction:action];
}
@end
