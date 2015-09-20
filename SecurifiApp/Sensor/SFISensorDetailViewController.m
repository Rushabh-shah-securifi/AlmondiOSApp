//
//  SFISensorDetailViewController.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 14.08.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//
#define AVENIR_HEAVY @"Avenir-Heavy"
#define AVENIR_ROMAN @"Avenir-Roman"
#define AVENIR_LIGHT @"Avenir-Light"



#import "SFISensorDetailViewController.h"
#import "SFIWiFiDeviceTypeSelectionCell.h"
#import "SFINotificationsViewController.h"
#import "SFIDeviceProprtyEditViewController.h"
#import "SFIConstants.h"
#import "MBProgressHUD.h"

@interface SFISensorDetailViewController ()<SFIDeviceProprtyEditViewControllerDelegate>{
    IBOutlet UIView *viewTypeSelection;
    
    IBOutlet UIView *mainBGView;
    IBOutlet UIView *viewHeader;
    IBOutlet UILabel *lblDeviceName;
    IBOutlet UILabel *lblStatus;
    
    NSMutableArray * propertiesArray;
    
    NSInteger randomMobileInternalIndex;
    IBOutlet UIImageView *imgIcon;
    IBOutlet UITableView *tblDeviceProperties;
    NSArray * notifyMe_items;
    UIFont *cellFont;
    IBOutlet UILabel *lblThemperatureMain;
    BOOL canCool;
    BOOL canHeat;
    
    NSString *iconImageName;
    NSString *status;
}

@property(nonatomic, readonly) MBProgressHUD *HUD;

@end

@implementation SFISensorDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    lblDeviceName.text = self.device.deviceName;
    cellFont = [UIFont fontWithName:AVENIR_ROMAN size:17];
    
    
    
    mainBGView.backgroundColor = self.cellColor;
    notifyMe_items = @[
                       NSLocalizedString(@"sensor.notificaiton.segment.Always", @"Always"),
                       NSLocalizedString(@"sensor.notificaiton.segment.Away", @"Away"),
                       NSLocalizedString(@"sensor.notificaiton.segment.Off", @"Off"),
                       ];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    randomMobileInternalIndex = arc4random() % 10000;
    
    NSArray *propertyNames = @[@"Name",@"Location",@"Actions",@"Stop",@"Battery",@"Switch 1",@"Switch 2",@"Temperature",@"AC Mode",@"High Temperature",@"Low Temperature",@"Swing",@"Power",@"IR Code",@"Configuration",@"Humidity",@"Away Mode",@"CO Level",@"Smoke Level",@"Mode",@"Target Range",@"Fan Mode",@"Fan",@"Notify me",@""];
    propertiesArray = [NSMutableArray new];
    for (int i=0; i<propertyNames.count; i++) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:@{@"name": propertyNames[i],@"hidden":@YES}];
        [propertiesArray addObject:dict];
    }
    [self configHeaderInfo];
    [self showPropertyRows];
    
    [tblDeviceProperties reloadData];
    [self initializeNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[propertiesArray[indexPath.row] valueForKey:@"hidden"] boolValue]) {
        return 0;
    }
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return propertiesArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    float propertyRowCellHeight = 44.0f;
    static NSString *MyIdentifier = @"deviceProperty";
    
    
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    
    for (UIView *c in cell.subviews) {
        if ([c isKindOfClass:[UILabel class]] || [c isKindOfClass:[UIButton class]]) {
            if (c.tag==66) {
                [c removeFromSuperview];
            }
        }
    }
    
    if (![[propertiesArray[indexPath.row] valueForKey:@"hidden"] boolValue]) {
        
        
        UIView * bgView = [[UIView alloc] init];
        
        
        bgView.frame = CGRectMake(0, 0, tblDeviceProperties.frame.size.width, propertyRowCellHeight);
        bgView.backgroundColor = self.cellColor;
        bgView.tag = 66;
        [cell addSubview:bgView];
        
        bgView.frame = CGRectMake(0, 0, tblDeviceProperties.frame.size.width, propertyRowCellHeight);
        
        
        CGSize textSize = [[propertiesArray[indexPath.row] valueForKey:@"name"] sizeWithFont:cellFont constrainedToSize:CGSizeMake(200, 50)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, textSize.width + 5, propertyRowCellHeight)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = cellFont;
        label.tag = 66;
        label.text = [propertiesArray[indexPath.row] valueForKey:@"name"];
        label.numberOfLines = 1;
        [cell addSubview:label];
        //        cell.textLabel.text = [propertiesArray[indexPath.row] valueForKey:@"name"];
        //        cell.textLabel.textColor = [UIColor whiteColor];
        //        cell.textLabel.font = cellFont;
        
        
        switch (indexPath.row) {
            case multiSensorTempIndexPathRow:
                [self configuremultiSensorTempCell:cell];
                break;
            case actionsIndexPathRow:
                [self configureActionsCell:cell];
                break;
            case stopIndexPathRow:
                [self configureStopCell:cell];
                break;
            case switch1IndexPathRow:
                [self configureSwitch1Cell:cell];
                break;
            case switch2IndexPathRow:
                [self configureSwitch2Cell:cell];
                break;
            case batteryIndexPathRow:
                [self configureBatteryCell:cell];
                break;
            case swingIndexPathRow:
                [self configureSwingCell:cell];
                break;
            case powerIndexPathRow:
                [self configurePowerCell:cell];
                break;
            case irCodeIndexPathRow:
                [self configureIRCodeCell:cell];
                break;
            case configIndexPathRow:
                [self configureConfigCell:cell];
                break;
            case highTemperatureIndexPathRow:
                [self configureHighTempCell:cell];
                break;
            case lowTemperatureIndexPathRow:
                [self configureLowTempCell:cell];
                break;
            case acModeIndexPathRow:
                [self configureACModeCell:cell];
                break;
            case nameIndexPathRow://Name
                [self configureNameCell:cell];
                break;
            case locationIndexPathRow:
                [self configureLocationCell:cell];
                break;
            case humidityIndexPathRow:
                [self configureHumidityCell:cell];
                break;
            case awayModeIndexPathRow:
                [self configureAwayModeCell:cell];
                break;
            case coLevelIndexPathRow:
                [self configureCOLevelCell:cell];
                break;
            case smokeLevelIndexPathRow:
                [self configureSmokeLevelCell:cell];
                break;
            case modeIndexPathRow:
                [self configureModeCell:cell];
                break;
            case fanIndexPathRow:
                [self configureFanCell:cell];
                break;
            case acFanIndexPathRow:
                [self configureACFanModeCell:cell];
                break;
            case targetRangeIndexPathRow:
                [self configureTargetRangeCell:cell];
                break;
            case notifyMeIndexPathRow:
                [self configureNotifyMeCell:cell];
                break;
            case deviceHistoryIndexPathRow:
                [self configureDeviceHistoryCell:cell];
                break;
            default:
                break;
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case nameIndexPathRow:
        case locationIndexPathRow:
        case acModeIndexPathRow:
        case acFanIndexPathRow:
        case awayModeIndexPathRow:
        case modeIndexPathRow:
        case targetRangeIndexPathRow:
        case fanIndexPathRow:
        case notifyMeIndexPathRow:
        case swingIndexPathRow:
        case powerIndexPathRow:
        case irCodeIndexPathRow:
        case stopIndexPathRow:
        case actionsIndexPathRow:
        case highTemperatureIndexPathRow:
        case lowTemperatureIndexPathRow:
        case configIndexPathRow:
        case switch2IndexPathRow:
        case switch1IndexPathRow:
            [self editProperty:indexPath.row];
            break;
        case deviceHistoryIndexPathRow:
            [self showSensorLogs];
            break;
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

#pragma mark delegates

- (void)updateDeviceInfo:(SFIDevice *)device :(SFIDeviceValue*)deviceValue{
    self.device = device;
    self.deviceValue = deviceValue;
    [tblDeviceProperties reloadData];
}

#pragma mark Cofigure Cells
- (void)configureHumidityCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 190, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_HUMIDITY];
    label.text = [currentDeviceValue.value stringByAppendingString:@"%"];
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureAwayModeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AWAY_MODE];
    label.text = [currentDeviceValue.value capitalizedString];
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureCOLevelCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 190, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CO_ALARM_STATE];
    label.text = [currentDeviceValue.value capitalizedString];
    if ([currentDeviceValue.value isEqualToString:@"true"]) {
        label.text = NSLocalizedString(@"smoke-detector-Warning",@"Warning");
    }else if ([currentDeviceValue.value isEqualToString:@"false"]){
        label.text = NSLocalizedString(@"smoke-detector-Emergency",@"Emergency");
    }
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureSmokeLevelCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 190, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SMOKE_ALARM_STATE];
    label.text = [currentDeviceValue.value capitalizedString];
    if ([currentDeviceValue.value isEqualToString:@"true"]) {
        label.text = NSLocalizedString(@"smoke-detector-Warning",@"Warning");
    }else if ([currentDeviceValue.value isEqualToString:@"false"]){
        label.text = NSLocalizedString(@"smoke-detector-Emergency",@"Emergency");
    }
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureBatteryCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 190, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_BATTERY];
    label.text = currentDeviceValue.value;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureActionsCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_UP_DOWN];
    if ([currentDeviceValue intValue]==99) {
        label.text =   NSLocalizedString(@"device-property-fanindexpah up",@"Up");
    }else{
        label.text =   NSLocalizedString(@"device-property-fanindexpah down",@"Down");
    }
    
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureStopCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_STOP];
    label.text = currentDeviceValue.value;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureSwitch1Cell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    NSArray *arrValue = [self.deviceValue knownDevicesValues];
    for (SFIDeviceKnownValues *currentDeviceValue in arrValue) {
        if (currentDeviceValue.index==1) {
            label.text = currentDeviceValue.value;
        }
    }
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureSwitch2Cell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    NSArray *arrValue = [self.deviceValue knownDevicesValues];
    for (SFIDeviceKnownValues *currentDeviceValue in arrValue) {
        if (currentDeviceValue.index==2) {
            label.text = currentDeviceValue.value;
        }
    }

    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configuremultiSensorTempCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 190, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_TEMPERATURE];
    label.text = currentDeviceValue.value;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureNameCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    label.text = self.device.deviceName;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureFanCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE];
    
    if ([currentDeviceValue.value boolValue]) {
        label.text = NSLocalizedString(@"sensor-detail-Fan cell On",@"On");
    }else{
        label.text = NSLocalizedString(@"sensor-detail-Fan cell Off",@"Off");
    }
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AWAY_MODE];
    if ([[currentDeviceValue.value lowercaseString] isEqualToString:@"home"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (void)configureACModeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_MODE];
    label.text = [currentDeviceValue.value capitalizedString];
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureSwingCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_SWING];
    if ([currentDeviceValue intValue]==0) {
        label.text = @"OFF";
    }else{
        label.text = @"ON";
    }
    
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configurePowerCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_BASIC];
    if ([currentDeviceValue intValue]==0) {
        label.text = @"OFF";
    }else{
        label.text = @"ON";
    }
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureACFanModeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_FAN_MODE];
    label.text = [currentDeviceValue.value capitalizedString];
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureConfigCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CONFIGURATION];
    label.text = [currentDeviceValue.value capitalizedString];
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureIRCodeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_IR_CODE];
    label.text = currentDeviceValue.value;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureHighTempCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_SETPOINT_HEATING];
    
    int targetValue = [currentDeviceValue intValue];
    label.text = [[SecurifiToolkit sharedInstance] getTemperatureWithCurrentFormat:targetValue];
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureLowTempCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_SETPOINT_COOLING];
    
    int targetValue = [currentDeviceValue intValue];
    label.text = [[SecurifiToolkit sharedInstance] getTemperatureWithCurrentFormat:targetValue];
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureModeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_MODE];
    label.text = [currentDeviceValue.value capitalizedString];
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AWAY_MODE];
    if ([[currentDeviceValue.value lowercaseString] isEqualToString:@"home"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (void)configureLocationCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    label.text = self.device.location;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)configureTargetRangeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_THERMOSTAT_RANGE_LOW];
    int lowValue = [currentDeviceValue intValue];
    
    currentDeviceValue= [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH];
    int highValue = [currentDeviceValue intValue];
    
    currentDeviceValue= [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_THERMOSTAT_TARGET];
    int targetValue = [currentDeviceValue intValue];
    
    currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_MODE];
    NSString *mode = [currentDeviceValue.value lowercaseString];
    NSString * prefix = @"F";
    
    if (![[SecurifiToolkit sharedInstance] isCurrentTemperatureFormatFahrenheit]) {
        prefix = @"C";
    }
    
    if ([mode isEqualToString:@"cool"] || !canHeat) {
        label.text = [[SecurifiToolkit sharedInstance] getTemperatureWithCurrentFormat:targetValue];
        for (UILabel *c in cell.subviews) {
            if ([c isKindOfClass:[UILabel class]]) {
                if (c.tag==66) {
                    c.text = NSLocalizedString(@"sensor-detail-Target Temp",@"Target Temp");
                }
            }
        }
    }else if ([mode isEqualToString:@"heat"] || !canCool){
        label.text = [[SecurifiToolkit sharedInstance] getTemperatureWithCurrentFormat:targetValue];
        for (UILabel *c in cell.subviews) {
            if ([c isKindOfClass:[UILabel class]]) {
                if (c.tag==66) {
                    c.text =  NSLocalizedString(@"sensor-detail- Target Temp",@"Target Temp");
                }
            }
        }
    }else{
        label.text = [NSString stringWithFormat:@"%d - %d° %@",[[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:lowValue],[[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:highValue],prefix];
    }
    
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AWAY_MODE];
    if ([[currentDeviceValue.value lowercaseString] isEqualToString:@"home"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)configureDeviceHistoryCell:(UITableViewCell*)cell{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 190, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    label.attributedText = [[NSAttributedString alloc] initWithString:@"View Device History"
                                                           attributes:underlineAttribute];
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureNotifyMeCell:(UITableViewCell*)cell{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tblDeviceProperties.frame.size.width - 220, 0, 180, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = cellFont;
    switch (self.device.notificationMode) {
        case SFINotificationMode_always:
            label.text =notifyMe_items[0];
            break;
        case SFINotificationMode_away:
            label.text =notifyMe_items[1];
            break;
        case SFINotificationMode_off:
            label.text =notifyMe_items[2];
            break;
        default:
            break;
    }
    
    label.numberOfLines = 1;
    label.tag = 66;
    label.textAlignment = NSTextAlignmentRight;
    [cell addSubview:label];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)showSensorLogs{
    SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    ctrl.enableDeleteNotification = NO;
    ctrl.markAllViewedOnDismiss = NO;
    ctrl.deviceID = self.device.deviceID;
    ctrl.almondMac = self.device.almondMAC;
    
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    [self presentViewController:nav_ctrl animated:YES completion:nil];
}

- (void)editProperty:(NSInteger)propertyNumber{
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AWAY_MODE];
    if (![[currentDeviceValue.value lowercaseString] isEqualToString:@"home"]) {
        switch (propertyNumber) {
            case modeIndexPathRow:
            case targetRangeIndexPathRow:
            case fanIndexPathRow:
                return;
                break;
                
            default:
                break;
        }
    }
    
    SFIDeviceProprtyEditViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceProprtyEditViewController"];
    viewController.delegate = self;
    viewController.editFieldIndex = propertyNumber;
    viewController.device = self.device;
    viewController.status = status;
    viewController.imgIconName = iconImageName;
    viewController.deviceValue = self.deviceValue;
    viewController.cellColor = self.cellColor;
    [self.navigationController pushViewController:viewController animated:YES];
}



- (void)showPropertyRows{
    switch (self.device.deviceType) {
        case SFIDeviceType_MultiSwitch_43:
        {
            [propertiesArray[nameIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[locationIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[notifyMeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[deviceHistoryIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[switch1IndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[switch2IndexPathRow] setValue:@NO forKey:@"hidden"];
        }
            break;
        case SFIDeviceType_RollerShutter_52:
        {
            [propertiesArray[nameIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[locationIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[notifyMeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[deviceHistoryIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[stopIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[actionsIndexPathRow] setValue:@NO forKey:@"hidden"];
        }
            break;
        case SFIDeviceType_ZWtoACIRExtender_54:
        {
            [propertiesArray[nameIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[locationIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[notifyMeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[deviceHistoryIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[batteryIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[acFanIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[acModeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[swingIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[highTemperatureIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[lowTemperatureIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[powerIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[irCodeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[configIndexPathRow] setValue:@NO forKey:@"hidden"];
        }
            break;
        case SFIDeviceType_MultiSoundSiren_55:
        {
            [propertiesArray[nameIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[locationIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[notifyMeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[deviceHistoryIndexPathRow] setValue:@NO forKey:@"hidden"];
        }
            break;
        case SFIDeviceType_MultiSensor_49:
        {
            [propertiesArray[batteryIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[multiSensorTempIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[nameIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[locationIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[notifyMeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[deviceHistoryIndexPathRow] setValue:@NO forKey:@"hidden"];
        }
            break;
        case SFIDeviceType_EnergyReader_56:
        {
            [propertiesArray[batteryIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[nameIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[locationIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[notifyMeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[deviceHistoryIndexPathRow] setValue:@NO forKey:@"hidden"];
        }
            break;
        case SFIDeviceType_NestThermostat_57:
        {
            [propertiesArray[nameIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[locationIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[notifyMeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[deviceHistoryIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[fanIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[targetRangeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[humidityIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[modeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[awayModeIndexPathRow] setValue:@NO forKey:@"hidden"];
            
            
            SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_HVAC_STATE];
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_COOL];
            canCool = [currentDeviceValue boolValue];
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_HEAT];
            canHeat = [currentDeviceValue boolValue];
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_NEST_THERMOSTAT_MODE];
            if ([[currentDeviceValue.value lowercaseString] isEqualToString:@"off"] || (!canHeat && !canCool)) {
                [propertiesArray[targetRangeIndexPathRow] setValue:@YES forKey:@"hidden"];
            }
            
            currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_HAS_FAN];
            BOOL hasFan = [currentDeviceValue boolValue];
            if (!hasFan) {
                [propertiesArray[fanIndexPathRow] setValue:@YES forKey:@"hidden"];
            }
            
        }
            break;
        case SFIDeviceType_NestSmokeDetector_58:
        {
            [propertiesArray[smokeLevelIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[nameIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[locationIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[notifyMeIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[deviceHistoryIndexPathRow] setValue:@NO forKey:@"hidden"];
            [propertiesArray[coLevelIndexPathRow] setValue:@NO forKey:@"hidden"];
        }
            break;
        default:
            break;
    }
}

- (void)configHeaderInfo{
    if (self.device.deviceType==SFIDeviceType_RollerShutter_52) {
        SFIDeviceKnownValues *values = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SWITCH_MULTILEVEL];
        

        switch (values.intValue) {
            case 0:
                iconImageName = DT53_GARAGE_SENSOR_CLOSED;
                status = @"CLOSED";
                break;
            case 252:
                iconImageName = DT53_GARAGE_SENSOR_DOWN;
                status = @"CLOSING";
                break;
            case 253:
                iconImageName = DT53_GARAGE_SENSOR_STOPPED;
                status = @"STOPPED";
                break;
            case 254:
                iconImageName = DT53_GARAGE_SENSOR_UP;
                status = @"OPENING";
                break;
            case 255:
                iconImageName = DT53_GARAGE_SENSOR_OPEN;
                status = @"OPEN";
                break;
            default:
                break;
        }
        [self configureSensorImageName:iconImageName statusMesssage:status];
    }
    
    if (self.device.deviceType==SFIDeviceType_MultiSoundSiren_55) {

        iconImageName = @"55_multisoundsiren_icon";
        status = @"";
      
        [self configureSensorImageName:iconImageName statusMesssage:status];
    }
    if (self.device.deviceType==SFIDeviceType_ZWtoACIRExtender_54) {
        SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_MODE];
        status = [currentDeviceValue.value capitalizedString];
        
        [self configTemperatureLable];
        currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SENSOR_MULTILEVEL];
        lblThemperatureMain.text = [NSString stringWithFormat:@"%d°",[[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:[currentDeviceValue intValue]]];
        return;
    }
    
    if (self.device.deviceType==SFIDeviceType_NestThermostat_57) {
        SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_HVAC_STATE];
        status = [currentDeviceValue.value capitalizedString];
        [self configTemperatureLable];
        currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CURRENT_TEMPERATURE];
        lblThemperatureMain.text = [NSString stringWithFormat:@"%d°",[[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:[currentDeviceValue intValue]]];
    }
    if (self.device.deviceType==SFIDeviceType_NestSmokeDetector_58) {
        SFIDeviceKnownValues *coValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CO_ALARM_STATE];
        
        SFIDeviceKnownValues *smokeValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SMOKE_ALARM_STATE];
        NSString * coText = @"";
        NSString * smokeText = @"";
        coText = [coValue.value capitalizedString];
        if ([coValue.value isEqualToString:@"true"]) {
            coText = NSLocalizedString(@"smoke-detector-Warning",@"Warning");
        }else if ([coValue.value isEqualToString:@"false"]){
            coText =NSLocalizedString(@"smoke-detector-Emergency",@"Emergency");
        }
        
        smokeText = [smokeValue.value capitalizedString];
        if ([smokeValue.value isEqualToString:@"true"]) {
            smokeText =  NSLocalizedString(@"smoke-detector-Warning",@"Warning");
            
        }else if ([smokeValue.value isEqualToString:@"false"]){
            smokeText = NSLocalizedString(@"smoke-detector-Emergency",@"Emergency");
        }
        status = [NSString stringWithFormat:@"Smoke :%@ , CO :%@",smokeText,coText];;
        iconImageName = @"nest_58_icon";
        UIImage* image = [UIImage imageNamed:iconImageName];
        imgIcon.image = image;
        CGRect fr = imgIcon.frame;
        fr.size = image.size;
        fr.origin.x = (90-fr.size.width)/2;
        fr.origin.y = (90-fr.size.height)/2;
        imgIcon.frame = fr;
    }
    lblStatus.text = status;
}

- (void)configTemperatureLable{
    
    imgIcon.image = nil;
    
    CGRect fr = lblThemperatureMain.frame;
    fr.size = CGSizeMake(90, 90);
    fr.origin.x = 0;
    fr.origin.y = 0;
    lblThemperatureMain.frame = fr;
    lblThemperatureMain.tag = 3;
    lblThemperatureMain.textAlignment = NSTextAlignmentCenter;
    lblThemperatureMain.textColor = [UIColor whiteColor];
    
    
    lblThemperatureMain.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:36.0f];
    lblThemperatureMain.textAlignment = NSTextAlignmentCenter;
    lblThemperatureMain.textColor = [UIColor whiteColor];
}

- (void)configureSensorImageName:(NSString *)imageName statusMesssage:(NSString *)message {
    UIImage* image = [UIImage imageNamed:imageName];
    imgIcon.image = image;
    CGRect fr = imgIcon.frame;
    CGSize imgSize = image.size;
    if (imgSize.height>=60) {
        float k = imgSize.height/imgSize.width;
        imgSize = CGSizeMake(70/k, 70);
    }
    if (imgSize.width>=60) {
        float k = imgSize.width/imgSize.height;
        imgSize = CGSizeMake(70, 70/k);
    }

    fr.size = imgSize;
    fr.origin.x = (80-fr.size.width)/2;
    fr.origin.y = (80-fr.size.height)/2;
    imgIcon.frame = fr;
    lblStatus.text = message;
}
@end
