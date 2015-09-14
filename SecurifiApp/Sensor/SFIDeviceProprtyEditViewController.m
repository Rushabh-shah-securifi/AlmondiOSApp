//
//  SFIDeviceProprtyEditViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 13.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIDeviceProprtyEditViewController.h"
#import "SFISensorDetailViewController.h"
#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "SFIHorizontalValueSelectorView.h"
#import "UIViewController+Securifi.h"
#import "MBProgressHUD.h"

@interface SFIDeviceProprtyEditViewController ()<SFIWiFiDeviceTypeSelectionCellDelegate,SFIHorizontalValueSelectorViewDataSource,SFIHorizontalValueSelectorViewDelegate>{
    
    IBOutlet UIView *viewTypeSelection;
    
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnSave;
    
    
    IBOutlet UIView *viewThemperature;
    IBOutlet UIView *viewEditCheckboxProperty;
    IBOutlet UIView *viewHeader;
    IBOutlet UITableView *tblTypes;
    
    NSMutableArray * propertyTypes;
    NSInteger randomMobileInternalIndex;
    NSString * selectedPropertyValue;
    
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
    
    int currentCoolTemp;
    int currentHeatTemp;
    BOOL canCool;
    BOOL canHeat;
    NSString * thermostatMode;
    
    int maxTempValue;
    int minTempValue;
    int diffTempValue;
    IBOutlet UIButton *btnCheckbox;
    IBOutlet UILabel *lblCheckbox;
    IBOutlet UILabel *lblPropertyName;
    IBOutlet UITextField *txtPropertyValue;
    IBOutlet UIView *viewEditTextProperty;
}

@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic) NSTimer *mobileCommandTimer;

@end

@implementation SFIDeviceProprtyEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateTemperatureLabel];
    
    viewTypeSelection.hidden = YES;
    viewThemperature.hidden = YES;
    viewEditTextProperty.hidden = YES;
    viewEditCheckboxProperty.hidden = YES;
    propertyTypes = [NSMutableArray new];
    
    SFIDeviceKnownValues *homeAwayDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AWAY_MODE];
    
    switch (self.editFieldIndex) {
        case nameIndexPathRow:
        {
            txtPropertyValue.text = self.device.deviceName;
            lblPropertyName.text = @"Name";
        }
            
            break;
        case locationIndexPathRow:
        {
            lblPropertyName.text = @"Location";
            txtPropertyValue.text = self.device.location;
        }
            break;
        case irCodeIndexPathRow:
        {
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_IR_CODE];
            txtPropertyValue.text = currentDeviceValue.value;
            lblPropertyName.text = @"Enter IR Code";
            txtPropertyValue.placeholder = @"Example 444";
        }
            break;
        case stopIndexPathRow:
        {
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_STOP];
            btnCheckbox.selected = YES;
            if ([currentDeviceValue.value isEqualToString:@"false"]) {
                btnCheckbox.selected = NO;
            }
        }
            break;
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
        case swingIndexPathRow:
        {
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_SWING];
            
            NSArray *cnames = @[NSLocalizedString(@"sensor.notificaiton.fanindexpath.On", @"On"),
                                NSLocalizedString(@"sensor.notificaiton.fanindexpath.Off", @"Off")];
            
            selectedPropertyValue = @"";
            if ([currentDeviceValue intValue] == 1) {
                selectedPropertyValue = NSLocalizedString(@"sensor.notificaiton.fanindexpath.On", @"On");
            }else if ([currentDeviceValue intValue] == 0){
                selectedPropertyValue = NSLocalizedString(@"sensor.notificaiton.fanindexpath.Off", @"Off");
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
        }
            break;
        case powerIndexPathRow:
        {
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_POWER];
            
            NSArray *cnames = @[NSLocalizedString(@"sensor.notificaiton.fanindexpath.On", @"On"),
                                NSLocalizedString(@"sensor.notificaiton.fanindexpath.Off", @"Off")];
            
            selectedPropertyValue = @"";
            if ([currentDeviceValue intValue] == 1) {
                selectedPropertyValue = NSLocalizedString(@"sensor.notificaiton.fanindexpath.On", @"On");
            }else if ([currentDeviceValue intValue] == 0){
                selectedPropertyValue = NSLocalizedString(@"sensor.notificaiton.fanindexpath.Off", @"Off");
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
        }
            break;
        case fanIndexPathRow:
        {
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE];
            
            NSArray *cnames = @[NSLocalizedString(@"sensor.notificaiton.fanindexpath.On", @"On"),
                                NSLocalizedString(@"sensor.notificaiton.fanindexpath.Off", @"Off")];
            
            selectedPropertyValue = @"";
            if ([currentDeviceValue.value isEqualToString:@"true"]) {
                selectedPropertyValue = NSLocalizedString(@"sensor.notificaiton.fanindexpath.On", @"On");
            }else if ([currentDeviceValue.value isEqualToString:@"false"]){
                selectedPropertyValue = NSLocalizedString(@"sensor.notificaiton.fanindexpath.Off", @"Off");
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
            if ([[homeAwayDeviceValue.value lowercaseString] isEqualToString:@"away"]) {
                btnSave.hidden = YES;
                btnBack.frame = btnSave.frame;
            }
            break;
        }
        case acFanIndexPathRow:
        {
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_FAN_MODE];
            
            NSArray *cnames = @[NSLocalizedString(@"sensor.notificaiton.fanindexpath.Auto Low", @"Auto Low"),
                                NSLocalizedString(@"sensor.notificaiton.fanindexpath.On High", @"On High"),
                                NSLocalizedString(@"sensor.notificaiton.fanindexpath.On Low", @"On Low"),
                                NSLocalizedString(@"sensor.notificaiton.fanindexpath.Medium", @"Medium")];
            
            selectedPropertyValue = @"";
            if ([currentDeviceValue.value isEqualToString:@"true"]) {
                selectedPropertyValue = NSLocalizedString(@"sensor.notificaiton.fanindexpath.On", @"On");
            }else if ([currentDeviceValue.value isEqualToString:@"false"]){
                selectedPropertyValue = NSLocalizedString(@"sensor.notificaiton.fanindexpath.Off", @"Off");
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
            
            NSArray *nnames = @[NSLocalizedString(@"sensor.awaymode.indexpath Home", @"Home"),NSLocalizedString(@"sensor.awaymode.indexpath Away", @"Away")];
            
            for (NSString * name in nnames) {
                NSMutableDictionary * dict = [NSMutableDictionary new];
                [dict setValue:name forKey:@"name"];
                [dict setValue:@0 forKey:@"selected"];
                if ([[homeAwayDeviceValue.value lowercaseString] isEqualToString:[name lowercaseString]]) {
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
            NSArray *mnames = @[NSLocalizedString(@"sensor.mode indexpath Off", @"Off"),
                                NSLocalizedString(@"sensor.mode indexpath Cool", @"Cool"),
                                NSLocalizedString(@"sensor.mode indexpath Heat", @"Heat"),
                                NSLocalizedString(@"sensor.mode indexpath Heat-Cool", @"Heat-Cool")];
            
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_COOL];
            canCool = [currentDeviceValue boolValue];
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_HEAT];
            canHeat = [currentDeviceValue boolValue];
            
            if (!canCool) {
                mnames = @[NSLocalizedString(@"sensor.mode indexpath Off", @"Off"),NSLocalizedString(@"sensor.mode indexpath Heat", @"Heat")];
            }
            if (!canHeat) {
                mnames = @[NSLocalizedString(@"sensor.mode indexpath Off", @"Off"),NSLocalizedString(@"sensor.mode indexpath Cool", @"Cool")];
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
        case acModeIndexPathRow:
        {
            
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_MODE];
            selectedPropertyValue = currentDeviceValue.value;
            NSArray *mnames = @[NSLocalizedString(@"sensor.mode indexpath Off", @"Off"),
                                NSLocalizedString(@"sensor.mode indexpath Cool", @"Cool"),
                                NSLocalizedString(@"sensor.mode indexpath Heat", @"Heat")];
            
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
            [tblTypes removeFromSuperview];
            
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_THERMOSTAT_RANGE_LOW];
            currentCoolTemp = [currentDeviceValue intValue];
            currentCoolTemp = [[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:currentCoolTemp];
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH];
            currentHeatTemp = [currentDeviceValue intValue];
            currentHeatTemp = [[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:currentHeatTemp];
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_MODE];
            
            thermostatMode = [currentDeviceValue.value lowercaseString];
            
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_COOL];
            canCool = [currentDeviceValue boolValue];
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_HEAT];
            canHeat = [currentDeviceValue boolValue];
            
            if(![thermostatMode isEqualToString:@"heat-cool"] || !(canCool && canHeat)){
                currentDeviceValue= [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_THERMOSTAT_TARGET];
                int targetValue = [currentDeviceValue intValue];
                currentCoolTemp = [[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:targetValue];
                currentHeatTemp = [[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:targetValue];
            }
            
            if ([[homeAwayDeviceValue.value lowercaseString] isEqualToString:@"away"]) {
                btnSave.hidden = YES;
                btnBack.frame = btnSave.frame;
            }
            break;
        }
        case highTemperatureIndexPathRow:
        {
            [tblTypes removeFromSuperview];
            
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_SETPOINT_HEATING];
            currentCoolTemp = [currentDeviceValue intValue];
            currentCoolTemp = [[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:currentCoolTemp];
            break;
        }
        case lowTemperatureIndexPathRow:
        {
            [tblTypes removeFromSuperview];
            
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_SETPOINT_COOLING];
            currentCoolTemp = [currentDeviceValue intValue];
            currentCoolTemp = [[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:currentCoolTemp];
            break;
        }
            
        default:
            break;
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    randomMobileInternalIndex = arc4random() % 10000;
    [viewHeader addSubview:self.headerView];
    UIView *currentView;
    switch (self.editFieldIndex) {
        case nameIndexPathRow:
        case locationIndexPathRow:
        case irCodeIndexPathRow:
        {
            viewEditTextProperty.hidden = NO;
            CGRect fr = viewEditTextProperty.frame;
            fr.origin.x = viewHeader.frame.origin.x;
            fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
            viewEditTextProperty.frame = fr;
            currentView = viewEditTextProperty;
            [txtPropertyValue becomeFirstResponder];
        }
            break;
        case stopIndexPathRow:
        {
            viewEditCheckboxProperty.hidden = NO;
            CGRect fr = viewEditCheckboxProperty.frame;
            fr.origin.x = viewHeader.frame.origin.x;
            fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
            viewEditCheckboxProperty.frame = fr;
            currentView = viewEditCheckboxProperty;
        }
            break;
        case awayModeIndexPathRow:
        case modeIndexPathRow:
        case acModeIndexPathRow:
        case acFanIndexPathRow:
        case fanIndexPathRow:
        case swingIndexPathRow:
        case powerIndexPathRow:
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
            
            [self configureTemperatureSelectors];
            [self configureTemperatureFormatButtons];
            
            if([thermostatMode isEqualToString:@"cool"]){
                heatingTempSelector.hidden = YES;
                lblHeating.hidden = YES;
                lblCooling.text =  NSLocalizedString(@"sensors.cooling.temperature", @"Cooling Temperature");
                
                fr = lblShow.frame;
                fr.origin.y =lblHeating.frame.origin.y;
                lblShow.frame = fr;
                
                fr = lblCelsius.frame;
                fr.origin.y =lblHeating.frame.origin.y+30;
                lblCelsius.frame = fr;
                
                fr = btnShowCelsius.frame;
                fr.origin.y =lblHeating.frame.origin.y+30;
                btnShowCelsius.frame = fr;
                
                fr = lblFahrenheit.frame;
                fr.origin.y =lblCelsius.frame.origin.y+40;
                lblFahrenheit.frame = fr;
                
                fr = btnFahrenheit.frame;
                fr.origin.y =btnShowCelsius.frame.origin.y+40;
                btnFahrenheit.frame = fr;
            }
            if([thermostatMode isEqualToString:@"heat"]){
                fr = lblShow.frame;
                fr.origin.y =lblHeating.frame.origin.y;
                lblShow.frame = fr;
                
                fr = lblCelsius.frame;
                fr.origin.y =lblHeating.frame.origin.y+30;
                lblCelsius.frame = fr;
                
                fr = btnShowCelsius.frame;
                fr.origin.y =lblHeating.frame.origin.y+30;
                btnShowCelsius.frame = fr;
                
                fr = lblFahrenheit.frame;
                fr.origin.y =lblCelsius.frame.origin.y+40;
                lblFahrenheit.frame = fr;
                
                fr = btnFahrenheit.frame;
                fr.origin.y =btnShowCelsius.frame.origin.y+40;
                btnFahrenheit.frame = fr;
                
                coolingTempSelector.hidden = YES;
                lblCooling.hidden = YES;
                heatingTempSelector.frame = coolingTempSelector.frame;
                lblHeating.frame = lblCooling.frame;
                
                lblHeating.text =  NSLocalizedString(@"sensors.heating.temperature", @"Heating Temperature");
            }
            break;
        }
        case highTemperatureIndexPathRow:
        case lowTemperatureIndexPathRow:
        {
            viewThemperature.hidden = NO;
            CGRect fr = viewTypeSelection.frame;
            fr.origin.x = viewHeader.frame.origin.x;
            fr.origin.y = viewHeader.frame.size.height+viewHeader.frame.origin.y;
            viewThemperature.frame = fr;
            
            currentView = viewThemperature;
            
            [self configureTemperatureSelectors];
            [self configureTemperatureFormatButtons];
            
            
            heatingTempSelector.hidden = YES;
            lblHeating.hidden = YES;
            if (self.editFieldIndex==highTemperatureIndexPathRow) {
                lblCooling.text =  NSLocalizedString(@"sensors.high.temperature", @"High Temperature");
            }else{
                lblCooling.text =  NSLocalizedString(@"sensors.low.temperature", @"Low Temperature");
            }
            
            
            fr = lblShow.frame;
            fr.origin.y =lblHeating.frame.origin.y;
            lblShow.frame = fr;
            
            fr = lblCelsius.frame;
            fr.origin.y =lblHeating.frame.origin.y+30;
            lblCelsius.frame = fr;
            
            fr = btnShowCelsius.frame;
            fr.origin.y =lblHeating.frame.origin.y+30;
            btnShowCelsius.frame = fr;
            
            fr = lblFahrenheit.frame;
            fr.origin.y =lblCelsius.frame.origin.y+40;
            lblFahrenheit.frame = fr;
            
            fr = btnFahrenheit.frame;
            fr.origin.y =btnShowCelsius.frame.origin.y+40;
            btnFahrenheit.frame = fr;
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
    currentView.backgroundColor = self.cellColor;
    [btnSave setTitleColor:self.cellColor forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.editFieldIndex==targetRangeIndexPathRow || self.editFieldIndex==lowTemperatureIndexPathRow || self.editFieldIndex==highTemperatureIndexPathRow) {
        [self displayTemperatureValues];
    }
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
    
    [center addObserver:self
               selector:@selector(onTabBarDidChange:)
                   name:@"TAB_BAR_CHANGED"
                 object:nil];
}

- (void)onTabBarDidChange:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (![[data valueForKey:@"title"] isEqualToString:@"Router"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
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
        case nameIndexPathRow:
            [self sendMobileCommandForDevice:self.device name:txtPropertyValue.text location:self.device.location];
            return;
            break;
        case locationIndexPathRow:
            [self sendMobileCommandForDevice:self.device name:self.device.deviceName location:txtPropertyValue.text];
            return;
            
            break;
        case irCodeIndexPathRow:
            propertyType = SFIDevicePropertyType_IR_CODE;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            deviceValues.value = txtPropertyValue.text;
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        case stopIndexPathRow:
        {
            propertyType = SFIDevicePropertyType_STOP;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            if(btnCheckbox.selected){
                deviceValues.value = @"true";
            }else{
                deviceValues.value = @"false";
            }
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
        }
            break;
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
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        }
        case fanIndexPathRow:
            propertyType = SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            if ([selectedPropertyValue isEqualToString:@"On"]) {
                deviceValues.value = NSLocalizedString(@"device-property-fanindexpah true",@"true");
            }else if ([selectedPropertyValue isEqualToString:@"Off"]){
                deviceValues.value = NSLocalizedString(@"device-property-fanindexpah false",@"false");
            }else{
                deviceValues.value = @"";
            }
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        case awayModeIndexPathRow:
            propertyType = SFIDevicePropertyType_AWAY_MODE;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            deviceValues.value = [selectedPropertyValue lowercaseString];
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        case acModeIndexPathRow:
            propertyType = SFIDevicePropertyType_AC_MODE;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            deviceValues.value = [selectedPropertyValue lowercaseString];
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        case acFanIndexPathRow:
            propertyType = SFIDevicePropertyType_AC_FAN_MODE;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            deviceValues.value = selectedPropertyValue;
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        case swingIndexPathRow:
            propertyType = SFIDevicePropertyType_AC_SWING;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            if ([selectedPropertyValue isEqualToString:@"Off"]) {
                deviceValues.value = @"0";
            }else{
                deviceValues.value = @"1";
            }
            
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        case powerIndexPathRow:
            propertyType = SFIDevicePropertyType_BASIC;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            if ([selectedPropertyValue isEqualToString:@"Off"]) {
                deviceValues.value = @"0";
            }else{
                deviceValues.value = @"255";
            }
            
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        case modeIndexPathRow:
            propertyType = SFIDevicePropertyType_NEST_THERMOSTAT_MODE;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            deviceValues.value = [selectedPropertyValue lowercaseString];
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        case targetRangeIndexPathRow:
        {
            NSString * value = @"";
            if (!coolingTempSelector.hidden) {
                propertyType = SFIDevicePropertyType_THERMOSTAT_RANGE_LOW;
                if (heatingTempSelector.hidden) {
                    propertyType = SFIDevicePropertyType_THERMOSTAT_TARGET;
                }
                
                deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
                if (btnFahrenheit.selected) {
                    value = [NSString stringWithFormat:@"%d",currentCoolTemp];
                }else{
                    value = [NSString stringWithFormat:@"%lu",lroundf(currentCoolTemp*1.8+32)];
                }
                deviceValues.value =value;
                self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            }
            
            if (!heatingTempSelector.hidden) {
                propertyType = SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH;
                if (coolingTempSelector.hidden) {
                    propertyType = SFIDevicePropertyType_THERMOSTAT_TARGET;
                }
                
                
                deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
                if (btnFahrenheit.selected) {
                    value = [NSString stringWithFormat:@"%d",currentHeatTemp];
                }else{
                    value = [NSString stringWithFormat:@"%lu",lroundf(currentHeatTemp*1.8+32)];
                }
                deviceValues.value =value;
                self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            }
            break;
        }
        case lowTemperatureIndexPathRow:
        {
            NSString * value = @"";
            propertyType = SFIDevicePropertyType_AC_SETPOINT_COOLING;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            if (btnFahrenheit.selected) {
                value = [NSString stringWithFormat:@"%d",currentCoolTemp];
            }else{
                value = [NSString stringWithFormat:@"%lu",lroundf(currentCoolTemp*1.8+32)];
            }
            deviceValues.value =value;
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        }
        case highTemperatureIndexPathRow:
        {
            NSString * value = @"";
            propertyType = SFIDevicePropertyType_AC_SETPOINT_HEATING;
            deviceValues = [self.deviceValue knownValuesForProperty:propertyType];
            if (btnFahrenheit.selected) {
                value = [NSString stringWithFormat:@"%d",currentCoolTemp];
            }else{
                value = [NSString stringWithFormat:@"%lu",lroundf(currentCoolTemp*1.8+32)];
            }
            deviceValues.value =value;
            self.deviceValue = [self.deviceValue setKnownValues:deviceValues forProperty:propertyType];
            break;
        }
            
        default:
            break;
    }
    
    
    
    // provisionally update; on mobile cmd response, the actual new values will be set
    
    [self sendMobileCommandForDevice:self.device deviceValue:deviceValues];
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
        case acModeIndexPathRow:
        case acFanIndexPathRow:
        case fanIndexPathRow:
        case modeIndexPathRow:
        case swingIndexPathRow:
        case powerIndexPathRow:
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
        case acModeIndexPathRow:
        case acFanIndexPathRow:
        case swingIndexPathRow:
        case powerIndexPathRow:
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
        case swingIndexPathRow:
        case acModeIndexPathRow:
        case powerIndexPathRow:
        case acFanIndexPathRow:
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
    return maxTempValue-minTempValue+1;
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
    //    if (valueSelector == coolingTempSelector) {
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, coolingTempSelector.frame.size.height)];
    label.text = [NSString stringWithFormat:@" %ld°",(long)index+minTempValue];
    //    }
    //    else {
    //        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, heatingTempSelector.frame.size.height)];
    //        label.text = [NSString stringWithFormat:@" %ld°",(long)index+minTempValue];
    //    }
    
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
    return CGRectMake(heatingTempSelector.frame.size.width/2 - 35.0, 0.0, 48.0, 48.0);
}

#pragma SFIHorizontalValueSelectorView delegate
- (void)selector:(SFIHorizontalValueSelectorView *)valueSelector didSelectRowAtIndex:(NSInteger)index {
    NSLog(@"Selected index %ld",(long)index);
    if ([valueSelector isEqual:coolingTempSelector]) {
        currentCoolTemp = (int)index+minTempValue;
        if (currentHeatTemp<(currentCoolTemp+diffTempValue) && !heatingTempSelector.hidden) {
            currentHeatTemp = currentCoolTemp+diffTempValue;
            if (currentHeatTemp>maxTempValue) {
                currentCoolTemp = maxTempValue-diffTempValue;
                currentHeatTemp = maxTempValue;
            }
            [self displayTemperatureValues];
        }
    }
    if ([valueSelector isEqual:heatingTempSelector]) {
        currentHeatTemp = (int)index+minTempValue;
        if (currentCoolTemp>(currentHeatTemp-diffTempValue) && !coolingTempSelector.hidden) {
            currentCoolTemp = currentHeatTemp-diffTempValue;
            if (currentCoolTemp<minTempValue) {
                currentCoolTemp = minTempValue;
                currentHeatTemp = minTempValue+diffTempValue;
            }
            [self displayTemperatureValues];
        }
    }
}

#pragma mark
- (IBAction)btnShowCelsiusTap:(id)sender {
    if (btnShowCelsius.selected) {
        return;
    }
    [[SecurifiToolkit sharedInstance] setCurrentTemperatureFormatFahrenheit:NO];
    currentHeatTemp = (int)lround((currentHeatTemp-32)/1.8);
    currentCoolTemp = (int)lround((currentCoolTemp-32)/1.8);
    
    [self configureTemperatureFormatButtons];
}

- (IBAction)btnShowFahrenheitTap:(id)sender {
    if (btnFahrenheit.selected) {
        return;
    }
    [[SecurifiToolkit sharedInstance] setCurrentTemperatureFormatFahrenheit:YES];
    currentHeatTemp = (int)lround(currentHeatTemp*1.8+32);
    currentCoolTemp = (int)lround(currentCoolTemp*1.8+32);
    
    [self configureTemperatureFormatButtons];
}

- (void)configureTemperatureFormatButtons{
    if ([[SecurifiToolkit sharedInstance] isCurrentTemperatureFormatFahrenheit]) {
        btnFahrenheit.backgroundColor = [UIColor whiteColor];
        btnShowCelsius.backgroundColor = [UIColor clearColor];
        btnFahrenheit.selected = YES;
        btnShowCelsius.selected = NO;
        maxTempValue = 90;
        minTempValue = 50;
        diffTempValue = 3;
    }else{
        btnFahrenheit.backgroundColor = [UIColor clearColor];
        btnShowCelsius.backgroundColor = [UIColor whiteColor];
        btnShowCelsius.selected = YES;
        btnFahrenheit.selected = NO;
        maxTempValue = 32;
        minTempValue = 10;
        diffTempValue = 2;
    }
    if(![thermostatMode isEqualToString:@"heat-cool"] || !(canCool && canHeat)){
        diffTempValue = 0;
    }
    
    [coolingTempSelector reloadData];
    [heatingTempSelector reloadData];
    [self displayTemperatureValues];
    [self updateTemperatureLabel];
}

- (void)configureTemperatureSelectors{
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
    
    btnShowCelsius.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnShowCelsius.layer.borderWidth = 2.0f;
    btnShowCelsius.backgroundColor = [UIColor clearColor];
    btnShowCelsius.layer.cornerRadius = btnShowCelsius.frame.size.width/2;
    
    btnFahrenheit.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnFahrenheit.layer.borderWidth = 2.0f;
    btnFahrenheit.backgroundColor = [UIColor clearColor];
    btnFahrenheit.layer.cornerRadius = btnShowCelsius.frame.size.width/2;
}

- (void)updateTemperatureLabel{
    SFIDeviceKnownValues *currentDeviceValue;
    
    if (self.device.deviceType==SFIDeviceType_ZWtoACIRExtender_54) {
        currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SENSOR_MULTILEVEL];
    }else if (self.device.deviceType==SFIDeviceType_NestThermostat_57){
        currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CURRENT_TEMPERATURE];
    }
    
    for (UILabel *lbl in self.headerView.subviews) {
        if (lbl.tag==3) {
            lbl.text = [NSString stringWithFormat:@"%d°",[[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:[currentDeviceValue intValue]]];
        }
    }
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

- (void)sendMobileCommandForDevice:(SFIDevice *)device name:(NSString*)deviceName location:(NSString*)deviceLocation {
    if (device == nil) {
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
        dc_id = [[SecurifiToolkit sharedInstance] asyncChangeAlmond:plus device:device name:deviceName location:deviceLocation];
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
                [self showToast:NSLocalizedString(@"device property on mobile hud Unable to update sensor",@"Unable to update sensor")];
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

- (void)displayTemperatureValues{
    int selIndex = currentCoolTemp;
    if ([[SecurifiToolkit sharedInstance] isCurrentTemperatureFormatFahrenheit]) {
        selIndex = selIndex-50;
    }else{
        selIndex = selIndex-10;
    }
    [coolingTempSelector selectRowAtIndex:selIndex];
    
    selIndex = currentHeatTemp;
    if ([[SecurifiToolkit sharedInstance] isCurrentTemperatureFormatFahrenheit]) {
        selIndex = selIndex-50;
    }else{
        selIndex = selIndex-10;
    }
    [heatingTempSelector selectRowAtIndex:selIndex];
}
- (IBAction)btnCheckboxTap:(id)sender {
    btnCheckbox.selected = !btnCheckbox.selected;
}
@end
