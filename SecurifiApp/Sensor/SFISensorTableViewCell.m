//
//  SFISensorTableViewCell.h
//
//  Created by sinclair on 6/25/14.
//
#import "SFISensorTableViewCell.h"
#import "SFIConstants.h"
#import "SFISensorDetailView.h"
#import "UIFont+Securifi.h"
#import "TemperatureView.h"


#define DEF_COULD_NOT_UPDATE_SENSOR @"Could not update sensor\ndata."

@interface SFISensorTableViewCell () <SFISensorDetailViewDelegate>
@property(nonatomic) UIImageView *deviceImageView;
@property(nonatomic) UIImageView *deviceImageViewSecondary;
@property(nonatomic) UILabel *deviceStatusLabel;
@property(nonatomic, readonly) UILabel *deviceNameLabel;

// For thermostat
@property(nonatomic) TemperatureView *deviceTemperatureView;

@property(nonatomic) SFISensorDetailView *detailView;

@property(nonatomic) BOOL dirty;
@property(nonatomic) BOOL updatingState;

@property(nonatomic) NSString *updatingStatusMessage;
@property(nonatomic) NSString *deviceStatusMessage;

@end

@implementation SFISensorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.deviceValue = [SFIDeviceValue new]; // ensure no null pointers; layout code assumes there exists a Device Value that returns answers
    }
    
    return self;
}

- (void)showUpdatingMessage {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.updatingStatusMessage = @"Updating sensor data.\nPlease wait.";
        [self setUpdatingSensorStatus];
    });
}

- (void)markStatusMessage:(NSString *)status {
    self.updatingStatusMessage = status;
}

- (void)markWillReuseCell:(BOOL)updating {
    self.dirty = YES;
    self.updatingState = updating;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.dirty) {
        self.dirty = NO;
        
        [self tearDown];
        [self layoutTileFrame];
        [self layoutDeviceImageCell];
        
        if (self.updatingState) {
            [self setUpdatingSensorStatus];
        }
        else {
            [self layoutDeviceInfo];
        }
        
        SFIDevice *device = self.device;
        if (self.isExpandedView) {
            SFISensorDetailView *detailView = [SFISensorDetailView new];
            detailView.frame = self.frame;
            detailView.tag = self.tag;
            detailView.delegate = self;
            detailView.device = device;
            detailView.deviceValue = self.deviceValue;
            detailView.color = self.cellColor;
            
            [self.contentView addSubview:detailView];
            self.detailView = detailView;
        }
        
        if (self.updatingState) {
            self.deviceStatusLabel.text = self.updatingStatusMessage;
        }
        else {
            self.deviceStatusLabel.text = self.deviceStatusMessage;
        }
    }
}

- (void)setDeviceValue:(SFIDeviceValue *)deviceValue {
    if (!deviceValue) {
        //do not allow null values!
        deviceValue = [SFIDeviceValue new];
    }
    _deviceValue = deviceValue;
}

- (void)tearDown {
    for (UIView *currentView in self.contentView.subviews) {
        [currentView removeFromSuperview];
    }
    self.deviceImageView = nil;
    self.deviceStatusLabel = nil;
    self.deviceTemperatureView = nil;
}

- (void)layoutTileFrame {
    const SFIDevice *currentSensor = self.device;
    const CGRect cell_frame = self.frame;
    const NSInteger row_index = self.tag;
    
    UIColor *const cell_color = self.cellColor;
    UIColor *const clear_color = [UIColor clearColor];
    UIColor *const white_color = [UIColor whiteColor];
    
    UIView *leftBackgroundLabel = [[UIView alloc] initWithFrame:CGRectMake(10, 5, LEFT_LABEL_WIDTH, SENSOR_ROW_HEIGHT - 10)];
    leftBackgroundLabel.tag = 111;
    leftBackgroundLabel.userInteractionEnabled = YES;
    leftBackgroundLabel.backgroundColor = cell_color;
    [self.contentView addSubview:leftBackgroundLabel];
    
    UIButton *deviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deviceButton.tag = row_index;
    deviceButton.frame = leftBackgroundLabel.bounds;
    deviceButton.backgroundColor = clear_color;
    [deviceButton addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftBackgroundLabel addSubview:deviceButton];
    
    UIView *rightBackgroundLabel = [[UIView alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH + 11, 5, cell_frame.size.width - LEFT_LABEL_WIDTH - 25, SENSOR_ROW_HEIGHT - 10)];
    rightBackgroundLabel.backgroundColor = cell_color;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDeviceNameLabelTapped:)];
    [rightBackgroundLabel addGestureRecognizer:recognizer];
    [self.contentView addSubview:rightBackgroundLabel];
    
    UILabel *deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, (cell_frame.size.width - LEFT_LABEL_WIDTH - 40), 30)];
    deviceNameLabel.backgroundColor = clear_color;
    deviceNameLabel.textColor = white_color;
    deviceNameLabel.text = currentSensor.deviceName;
    deviceNameLabel.font = [deviceNameLabel.font fontWithSize:16];
    [rightBackgroundLabel addSubview:deviceNameLabel];
    _deviceNameLabel = deviceNameLabel;
    
    UILabel *deviceStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 180, 60)];
    deviceStatusLabel.backgroundColor = clear_color;
    deviceStatusLabel.textColor = white_color;
    deviceStatusLabel.numberOfLines = 2;
    deviceStatusLabel.font = [UIFont standardUILabelFont];
    [rightBackgroundLabel addSubview:deviceStatusLabel];
    self.deviceStatusLabel = deviceStatusLabel;
    
    //todo seems like the button could take place of image view
    
    UIImageView *settingsImage = [[UIImageView alloc] initWithFrame:CGRectMake(cell_frame.size.width - 50, 37, 23, 23)];
    settingsImage.image = [UIImage imageNamed:@"icon_config.png"];
    settingsImage.alpha = (CGFloat) (self.isExpandedView ? 1.0 : 0.5); // change color of image when expanded
    settingsImage.userInteractionEnabled = YES;
    [self.contentView addSubview:settingsImage];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.tag = row_index;
    settingsButton.frame = settingsImage.bounds;
    settingsButton.backgroundColor = clear_color;
    [settingsButton addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [settingsImage addSubview:settingsButton];
    
    UIButton *settingsButtonCell = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButtonCell.tag = row_index;
    settingsButtonCell.frame = CGRectMake(cell_frame.size.width - 80, 5, 60, 80);
    settingsButtonCell.backgroundColor = clear_color;
    [settingsButtonCell addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:settingsButtonCell];
}

- (void)layoutDeviceImageCell {
    UIColor *clear_color = [UIColor clearColor];
    
    UIButton *deviceImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deviceImageButton.tag = self.tag;
    deviceImageButton.backgroundColor = clear_color;
    [deviceImageButton addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self needsTemperatureView]) {
        self.deviceTemperatureView = [[TemperatureView alloc] initWithFrame:CGRectMake(0, 0, LEFT_LABEL_WIDTH, 100)];
        [self.contentView addSubview:self.deviceTemperatureView];
    }
    
    // Set up the sensor icon views
    // There are two views composted on top of each other.
    // The main icon view is on the bottom, and a secondary view is available for
    // overlaying a second icon on top.
    CGRect imageView_frame = CGRectMake(LEFT_LABEL_WIDTH / 3, 12, 53, 70);
    //
    self.deviceImageView = [[UIImageView alloc] initWithFrame:imageView_frame];
    self.deviceImageView.userInteractionEnabled = YES;
    //
    [self.deviceImageView addSubview:deviceImageButton];
    deviceImageButton.frame = self.deviceImageView.bounds;
    [self.contentView addSubview:self.deviceImageView];
    //
    self.deviceImageViewSecondary = [[UIImageView alloc] initWithFrame:imageView_frame];
    [self.contentView addSubview:self.deviceImageViewSecondary];
}

// Controls whether a TemperatureView is needed in the far left cell space.
// Update this list as needed
- (BOOL)needsTemperatureView {
    switch (self.device.deviceType) {
        case SFIDeviceType_Thermostat_7:
        case SFIDeviceType_TemperatureSensor_27:
        case SFIDeviceType_SetPointThermostat_46:
            return YES;
        default:
            return NO;
    }
}

- (void)layoutDeviceInfo {
    // Protect against null values
    if (self.deviceValue == nil) {
        [self configureUnknownDevice];
        return;
    }
    
    SFIDevice *const device = self.device;
    
    switch (device.deviceType) {
        case SFIDeviceType_BinarySwitch_1: {
            [self configureBinaryStateSensor:DT1_BINARY_SWITCH_TRUE imageNameFalse:DT1_BINARY_SWITCH_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
            break;
        }
            
        case SFIDeviceType_MultiLevelSwitch_2: {
            [self configureMultiLevelSwitch_2];
            break;
        }
            
        case SFIDeviceType_BinarySensor_3: {
            [self configureBinaryStateSensor:DT3_BINARY_SENSOR_TRUE imageNameFalse:DT3_BINARY_SENSOR_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }
            
        case SFIDeviceType_MultiLevelOnOff_4: {
            [self configureLevelControl_4];
            break;
        }
            
        case SFIDeviceType_DoorLock_5: {
            [self configureBinaryStateSensorImageNameZeroValue:DT5_DOOR_LOCK_UNLOCKED imageNameNonZeroValue:DT5_DOOR_LOCK_LOCKED statusZeroValue:@"UNLOCKED" statusNonZeroValue:@"LOCKED"];
            break;
        }
            
        case SFIDeviceType_Alarm_6: {
            [self configureBinaryStateSensorImageNameZeroValue:DT6_ALARM_FALSE imageNameNonZeroValue:DT6_ALARM_TRUE statusZeroValue:@"OFF" statusNonZeroValue:@"ON"];
            break;
        }
            
        case SFIDeviceType_Thermostat_7: {
            [self showDeviceTemperatureView:YES];
            [self configureThermostat_7];
            break;
        }
            
        case SFIDeviceType_StandardCIE_10: {
            [self configureBinaryStateSensor:D10_STANDARD_CIE_TRUE imageNameFalse:D10_STANDARD_CIE_FALSE statusTrue:@"ACTIVE" statusFalse:@"INACTIVE"];
            break;
        }
            
        case SFIDeviceType_MotionSensor_11: {
            [self configureBinaryStateSensor:DT11_MOTION_SENSOR_TRUE imageNameFalse:DT11_MOTION_SENSOR_FALSE statusTrue:@"MOTION DETECTED" statusFalse:@"NO MOTION"];
            break;
        }
            
        case SFIDeviceType_ContactSwitch_12: {
            [self configureBinaryStateSensor:DT12_CONTACT_SWITCH_TRUE imageNameFalse:DT12_CONTACT_SWITCH_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }
            
        case SFIDeviceType_FireSensor_13: {
            [self configureBinaryStateSensor:DT13_FIRE_SENSOR_TRUE imageNameFalse:DT13_FIRE_SENSOR_FALSE statusTrue:@"ALARM: FIRE DETECTED" statusFalse:@"OK"];
            break;
        }
            
        case SFIDeviceType_WaterSensor_14: {
            [self configureBinaryStateSensor:DT14_WATER_SENSOR_TRUE imageNameFalse:DT14_WATER_SENSOR_FALSE statusTrue:@"FLOODED" statusFalse:@"OK"];
            break;
        }
            
        case SFIDeviceType_GasSensor_15: {
            [self configureBinaryStateSensor:DT15_GAS_SENSOR_TRUE imageNameFalse:DT15_GAS_SENSOR_FALSE statusTrue:@"ALARM: GAS DETECTED" statusFalse:@"OK"];
            break;
        }
            
        case SFIDeviceType_VibrationOrMovementSensor_17: {
            [self configureBinaryStateSensor:DT17_VIBRATION_SENSOR_TRUE imageNameFalse:DT17_VIBRATION_SENSOR_FALSE statusTrue:@"VIBRATION DETECTED" statusFalse:@"NO VIBRATION"];
            break;
        }
            
        case SFIDeviceType_KeyFob_19: {
            [self configureKeyFob_19];
            break;
        }
            
        case SFIDeviceType_StandardWarningDevice_21: {
            // for this device, we don't actually know what the state is; when the alarm value is > 0, it simply means the alarm will ring for the specified number of seconds
            // but we don't know if it is ringing right now. Therefore, we always show this message.
            NSString *msg = @"State data unknown.\nUse manual controls.";
            
            // also, the same icon is shown for all states
            NSString *no_alarm_icon = DT21_STANDARD_WARNING_DEVICE_FALSE;
            
            [self configureBinaryStateSensorImageNameZeroValue:no_alarm_icon imageNameNonZeroValue:no_alarm_icon statusZeroValue:@"OFF" statusNonZeroValue:msg];
            break;
        }
            
        case SFIDeviceType_SmartACSwitch_22: {
            [self configureBinaryStateSensor:DT22_AC_SWITCH_TRUE imageNameFalse:DT22_AC_SWITCH_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
            break;
        }
            
        case SFIDeviceType_SmartDCSwitch_23: {
            [self configureBinaryStateSensor:DT23_DC_SWITCH_TRUE imageNameFalse:DT23_DC_SWITCH_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
            break;
        }
            
        case SFIDeviceType_OccupancySensor_24: {
            [self configureBinaryStateSensor:DT11_MOTION_SENSOR_TRUE imageNameFalse:DT11_MOTION_SENSOR_FALSE statusTrue:@"PRESENCE DETECTED" statusFalse:@"NO PRESENCE"];
            break;
        };
            
        case SFIDeviceType_LightSensor_25: {
            [self configureLightSensor_25];
            break;
        }
            
        case SFIDeviceType_WindowCovering_26: {
            [self configureBinaryStateSensor:DT26_WINDOW_COVERING_TRUE imageNameFalse:DT26_WINDOW_COVERING_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }
            
        case SFIDeviceType_TemperatureSensor_27: {
            [self showDeviceTemperatureView:YES];
            [self configureTempSensor_27];
            break;
        }
            
        case SFIDeviceType_ZigbeeDoorLock_28: {
            [self configureZigbeeDoorLock_28];
            break;
        }
            
        case SFIDeviceType_ColorDimmableLight_32: {
            [self configureColorDimmableLight_32:DT48_HUE_LAMP_TRUE imageNameFalse:DT48_HUE_LAMP_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
            break;
        }
            
        case SFIDeviceType_Shade_34: {
            [self configureBinaryStateSensor:DT34_SHADE_TRUE imageNameFalse:DT34_SHADE_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }
            
        case SFIDeviceType_SmokeDetector_36: {
            [self configureBinaryStateSensorImageNameZeroValue:DT36_SMOKE_DETECTOR_FALSE imageNameNonZeroValue:DT36_SMOKE_DETECTOR_TRUE statusZeroValue:@"OK" statusNonZeroValue:@"SMOKE DETECTED!"];
            break;
        }
            
        case SFIDeviceType_FloodSensor_37: {
            [self configureBinaryStateSensorImageNameZeroValue:DT37_FLOOD_FALSE imageNameNonZeroValue:DT37_FLOOD_TRUE statusZeroValue:@"OK" statusNonZeroValue:@"FLOODED"];
            break;
        }
            
        case SFIDeviceType_ShockSensor_38: {
            [self configureBinaryStateSensor:DT38_SHOCK_TRUE imageNameFalse:DT38_SHOCK_FALSE statusTrue:@"VIBRATION DETECTED" statusFalse:@"NO VIBRATION"];
            break;
        }
            
        case SFIDeviceType_DoorSensor_39: {
            [self configureBinaryStateSensor:DT39_DOOR_SENSOR_OPEN imageNameFalse:DT39_DOOR_SENSOR_CLOSED statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }
            
        case SFIDeviceType_MoistureSensor_40: {
            [self configureMoistureSensor_40];
            break;
        }
            
        case SFIDeviceType_MovementSensor_41: {
            [self configureBinaryStateSensor:DT41_MOTION_SENSOR_TRUE imageNameFalse:DT41_MOTION_SENSOR_FALSE statusTrue:@"MOTION DETECTED" statusFalse:@"NO MOTION"];
            break;
        }
            
        case SFIDeviceType_Siren_42: {
            [self configureBinaryStateSensor:DT42_ALARM_TRUE imageNameFalse:DT42_ALARM_FALSE statusTrue:@"RINGING" statusFalse:@"OFF"];
            break;
        }
            
        case SFIDeviceType_UnknownOnOffModule_44: {
            [self configureBinaryStateSensor:DT1_BINARY_SWITCH_TRUE imageNameFalse:DT1_BINARY_SWITCH_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
            break;
        }
            
        case SFIDeviceType_BinaryPowerSwitch_45: {
            [self configureBinaryPowerSwitch_45];
            break;
        }
            
        case SFIDeviceType_SetPointThermostat_46: {
            [self configureSetPointThermostat_46];
            break;
        }
            
        case SFIDeviceType_HueLamp_48: {
            [self configureHueLamp_48:DT48_HUE_LAMP_TRUE imageNameFalse:DT48_HUE_LAMP_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
            break;
        }
            
        case SFIDeviceType_SecurifiSmartSwitch_50: {
            [self configureBinaryStateSensor:DT50_SECURIFI_SMART_SWITCH_TRUE imageNameFalse:DT50_SECURIFI_SMART_SWITCH_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
            break;
        }
            
        case SFIDeviceType_GarageDoorOpener_53: {
            [self configureGarageDoorOpener_53];
            break;
        }
        case SFIDeviceType_NestSmokeDetector_58: {
            [self configureNestSmokeDetector_58];//md01
            break;
        }
        case SFIDeviceType_NestThermostat_57: {
            [self configureNestThermostat_57];//md01
            break;
        }
        case SFIDeviceType_UnknownDevice_0:
        case SFIDeviceType_Controller_8:
        case SFIDeviceType_SceneController_9:
        case SFIDeviceType_PersonalEmergencyDevice_16:
        case SFIDeviceType_RemoteControl_18:
        case SFIDeviceType_Keypad_20:
        case SFIDeviceType_ColorControl_29:
        case SFIDeviceType_PressureSensor_30:
        case SFIDeviceType_FlowSensor_31:
        case SFIDeviceType_HAPump_33:
        case SFIDeviceType_MultiSwitch_43:
        case SFIDeviceType_51:
        case SFIDeviceType_RollerShutter_52:
        default: {
            [self configureUnknownDevice];
        }
    }; // for each device
}


- (void)configureUnknownDevice {
    [self configureSensorImageName:DEVICE_UNKNOWN_IMAGE statusMesssage:nil];
}

- (void)configureTemperatureView:(NSString *)temperatureValue description:(NSString *)description unitsSymbol:(NSString *)unitsSymbol {
    TemperatureView *view = self.deviceTemperatureView;
    view.temperature = temperatureValue;
    view.unitsSymbol = unitsSymbol;
    view.label = description;
}

#pragma mark - Changed values

- (NSString *)deviceName {
    return self.detailView.deviceName;
}

- (NSString *)deviceLocation {
    return self.detailView.deviceLocation;
}

#pragma mark - Event handling

- (void)onSettingClicked:(id)sender {
    [self.delegate tableViewCellDidPressSettings:self];
}

- (void)onDeviceClicked:(id)sender {
    [self.delegate tableViewCellDidClickDevice:self];
}

// toggles the label to reveal the underlying device type
- (void)onDeviceNameLabelTapped:(id)sender {
    UILabel *label = self.deviceNameLabel;
    NSString *name = self.device.deviceName;
    
    if ([label.text isEqualToString:name]) {
        label.text = securifi_name_to_device_type(self.device.deviceType);
    }
    else {
        label.text = name;
    }
}

#pragma mark - SFISensorDetailViewDelegate methods

- (BOOL)sensorDetailViewNotificationsEnabled {
    return [self.delegate tableViewCellNotificationsEnabled];
}

- (void)sensorDetailViewWillStartMakingChanges:(SFISensorDetailView *)view {
    [self.delegate tableViewCellWillStartMakingChanges:self];
}

- (void)sensorDetailViewDidCompleteMakingChanges:(SFISensorDetailView *)view {
    [self.delegate tableViewCellDidCompleteMakingChanges:self];
}

- (void)sensorDetailViewDidCancelMakingChanges:(SFISensorDetailView *)view {
    [self.delegate tableViewCellDidCancelMakingChanges:self];
}

- (void)sensorDetailViewDidPressSaveButton:(SFISensorDetailView *)view {
    [self.delegate tableViewCellDidSaveChanges:self];
}

- (void)sensorDetailViewDidPressShowLogsButton:(SFISensorDetailView *)view {
    [self.delegate tableViewCellDidPressShowLogs:self];
}

- (void)sensorDetailViewDidPressDismissTamperButton:(SFISensorDetailView *)view {
    [self.delegate tableViewCellDidDismissTamper:self];
}

- (void)sensorDetailViewDidChangeSensorValue:(SFISensorDetailView *)view propertyType:(SFIDevicePropertyType)propertyType newValue:(NSString *)aValue {
    [self.delegate tableViewCellDidChangeValue:self propertyType:propertyType newValue:aValue];
}

- (void)sensorDetailViewDidChangeSensorValue:(SFISensorDetailView *)view propertyName:(NSString *)propertyName newValue:(NSString *)aValue {
    [self.delegate tableViewCellDidChangeValue:self propertyName:propertyName newValue:aValue];
}

- (void)sensorDetailViewDidRejectSensorValue:(SFISensorDetailView *)view validationToast:(NSString *)aMsg {
    [self.delegate tableViewCellDidDidFailValidation:self validationToast:aMsg];
}

- (void)sensorDetailViewCell:(SFISensorDetailView *)view setValue:(id)value forKey:(NSString *)key {
    [self.delegate tableViewCell:self setValue:value forKey:key];
}

- (id)sensorDetailViewCell:(SFISensorDetailView *)view valueForKey:(NSString *)key {
    return [self.delegate tableViewCell:self valueForKey:key];
}

- (void)sensorDetailViewDidChangeNotificationPref:(SFISensorDetailView *)view newMode:(SFINotificationMode)newMode {
    [self.delegate tableViewCellDidChangeNotificationSetting:self newMode:newMode];
}

- (void)sensorDetailViewDidChangeSensorIconTintValue:(SFISensorDetailView *)view tint:(UIColor *)newColor {
    dispatch_async(dispatch_get_main_queue(), ^() {
        DLog(@"Setting tint color: %@", newColor);
        self.deviceImageViewSecondary.tintColor = newColor;
    });
}

#pragma mark - Device layout

- (void)configureMultiLevelSwitch_2 {
    //Get Percentage
    SFIDeviceKnownValues *currentLevelKnownValue = [self tryGetCurrentKnownValuesForDeviceMutableState];
    NSString *currentLevel = currentLevelKnownValue.value;
    
    NSString *status = [currentLevelKnownValue choiceForLevelValueZeroValue:NSLocalizedString(@"sensor.status-label.OFF", @"OFF")
                                                               nonZeroValue:[NSString stringWithFormat:NSLocalizedString(@"sensor.multilevel-switch.status-label.Dimmable, %@%%", @"Dimmable, %@%%"), currentLevel]
                                                                   nilValue:DEF_COULD_NOT_UPDATE_SENSOR];
    
    NSString *imageName = [currentLevelKnownValue choiceForLevelValueZeroValue:DT2_MULTILEVEL_SWITCH_FALSE
                                                                  nonZeroValue:DT2_MULTILEVEL_SWITCH_TRUE
                                                                      nilValue:DT2_MULTILEVEL_SWITCH_TRUE];
    
    self.deviceStatusMessage = status;
    self.deviceImageView.image = [UIImage imageNamed:imageName];
}

- (void)configureLevelControl_4 {
    //Get Percentage
    SFIDeviceKnownValues *currentLevelKnownValue = [self tryGetCurrentKnownValuesForDeviceMutableState];
    float intLevel = [currentLevelKnownValue floatValue];
    intLevel = (intLevel / 256) * 100;
    
    NSString *status_str;
    NSString *image_name;
    
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceState];
    if (!values.hasValue) {
        NSString *dimmable_str = NSLocalizedString(@"sensor.level-control.status-label.Dimmable", @"Dimmable");
        status_str = [currentLevelKnownValue choiceForLevelValueZeroValue:dimmable_str
                                                             nonZeroValue:[NSString stringWithFormat:@"%@, %.0f%%", dimmable_str, intLevel]
                                                                 nilValue:DEF_COULD_NOT_UPDATE_SENSOR];
        
        image_name = DT4_LEVEL_CONTROL_TRUE;
    }
    else if (values.boolValue == true) {
        NSString *on_str = NSLocalizedString(@"sensor.status-label.ON", @"ON");
        status_str = [currentLevelKnownValue choiceForLevelValueZeroValue:@"ON"
                                                             nonZeroValue:[NSString stringWithFormat:@"%@, %.0f%%", on_str, intLevel]
                                                                 nilValue:on_str];
        
        image_name = DT4_LEVEL_CONTROL_TRUE;
    }
    else {
        NSString *off_str = NSLocalizedString(@"sensor.status-label.OFF", @"OFF");
        status_str = [currentLevelKnownValue choiceForLevelValueZeroValue:off_str
                                                             nonZeroValue:[NSString stringWithFormat:@"%@, %.0f%%", off_str, intLevel]
                                                                 nilValue:off_str];
        
        image_name = DT4_LEVEL_CONTROL_FALSE;
    }
    
    [self setDeviceStatusMessage:status_str];
    self.deviceImageView.image = [UIImage imageNamed:image_name];
}

- (void)configureThermostat_7 {
    SFIDeviceValue *const deviceValue = self.deviceValue;
    
    // Status label
    NSString *operatingMode = [deviceValue valueForProperty:SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE default:@"Unknown"];
    NSString *coolingSetPoint = [deviceValue valueForProperty:SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING default:@"-"];
    NSString *heatingSetPoint = [deviceValue valueForProperty:SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING default:@"-"];
    
    NSString *const degrees_symbol = @"\u00B0";
    
    if ([coolingSetPoint rangeOfString:degrees_symbol].length == 0) {
        // no degrees so add one
        coolingSetPoint = [coolingSetPoint stringByAppendingString:degrees_symbol];
    }
    
    if ([heatingSetPoint rangeOfString:degrees_symbol].length == 0) {
        // no degrees so add one
        heatingSetPoint = [heatingSetPoint stringByAppendingString:degrees_symbol];
    }
    
    NSString *state = [NSString stringWithFormat:@"%@,  LO %@,  HI %@", operatingMode, coolingSetPoint, heatingSetPoint];
    
    NSMutableArray *status = [NSMutableArray array];
    [status addObject:state];
    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
    
    // Calculate values
    NSString *value = [deviceValue valueForProperty:SFIDevicePropertyType_SENSOR_MULTILEVEL];
    [self configureTemperatureView:value description:nil unitsSymbol:nil];
}

- (void)configureKeyFob_19 {
    SFIDeviceValue *const deviceValue = self.deviceValue;
    
    NSDictionary *choices = @{
                              @"0" : NSLocalizedString(@"sensor.keyfob.status-label.ALL DISARMED", @"ALL DISARMED"),
                              @"2" : NSLocalizedString(@"sensor.keyfob.status-label.PERIMETER ARMED", @"PERIMETER ARMED"),
                              @"3" : NSLocalizedString(@"sensor.keyfob.status-label.ALL ARMED", @"ALL ARMED")
                              };
    
    NSMutableArray *status = [NSMutableArray array];
    [status addObject:[deviceValue choiceForPropertyValue:SFIDevicePropertyType_ARMMODE choices:choices default:DEF_COULD_NOT_UPDATE_SENSOR]];
    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
    
    NSString *imageForNoValue = [self imageNameForNoValue];
    NSString *imageName = [deviceValue choiceForPropertyValue:SFIDevicePropertyType_ARMMODE choices:@{@"0" : DT19_KEYFOB_FALSE, @"2" : DT19_KEYFOB_TRUE, @"3" : DT19_KEYFOB_TRUE} default:imageForNoValue];
    self.deviceImageView.image = [UIImage imageNamed:imageName];
}

- (void)configureLightSensor_25 {
    SFIDeviceKnownValues *stateValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_ILLUMINANCE];
    if (!stateValue) {
        [self configureUnknownDevice];
        return;
    }
    
    NSString *value = [stateValue value];
    
    NSMutableArray *status = [NSMutableArray array];
    [status addObject:[NSString stringWithFormat:NSLocalizedString(@"sensor.lightsensor.status-label.Illuminance %@", @"Illuminance %@"), value]];
    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
    
    NSString *imageName;
    if ([value isEqualToString:@"0 lux"]) {
        imageName = DT25_LIGHT_SENSOR_FALSE;
    }
    else {
        imageName = DT25_LIGHT_SENSOR_TRUE;
    }
    self.deviceImageView.image = [UIImage imageNamed:imageName];
}

- (void)configureTempSensor_27 {
    NSString *temp = [self.deviceValue valueForProperty:SFIDevicePropertyType_TEMPERATURE default:@""];
    [self configureTemperatureView:temp description:nil unitsSymbol:nil];
    
    NSMutableArray *status = [NSMutableArray array];
    NSString *humidity = [self.deviceValue valueForProperty:SFIDevicePropertyType_HUMIDITY default:@""];
    if (humidity.length > 0) {
        NSString *label_format = NSLocalizedString(@"sensor.tempsensor.status-label.Humidity %@", @"Humidity %@");
        [status addObject:[NSString stringWithFormat:label_format, humidity]];
    }
    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
}

- (void)configureZigbeeDoorLock_28 {
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceState];
    if (!values) {
        [self configureUnknownDevice];
        return;
    }
    
    NSString *imageName;
    NSString *status;
    
    //todo this indicates insufficient abstraction; we should be able to push this logic direction into SFIDeviceKnownValues and SFIDevice
    
    switch (values.intValue) {
        case 0: // SFIDeviceType_ZigbeeDoorLock_28_LOCKED
            imageName = DT5_DOOR_LOCK_UNLOCKED;
            status = @"UNLOCKED";
            break;
        case 1: // SFIDeviceType_ZigbeeDoorLock_28_LOCKED
            imageName = DT5_DOOR_LOCK_LOCKED;
            status = @"LOCKED";
            break;
        case 2: // SFIDeviceType_ZigbeeDoorLock_28_UNLOCKED
            imageName = DT5_DOOR_LOCK_UNLOCKED;
            status = @"UNLOCKED";
            break;
        default:
            imageName = [self imageNameForNoValue];
            status = DEF_COULD_NOT_UPDATE_SENSOR;
    }
    
    [self configureSensorImageName:imageName statusMesssage:status];
}

- (void)configureMoistureSensor_40 {
    SFIDeviceKnownValues *stateValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_BASIC];
    if (!stateValue) {
        [self configureUnknownDevice];
        return;
    }
    
    NSString *imageForNoValue = [self imageNameForNoValue];
    NSString *imageName = [stateValue choiceForLevelValueZeroValue:DT40_MOISTURE_FALSE nonZeroValue:DT40_MOISTURE_TRUE nilValue:imageForNoValue];
    self.deviceImageView.image = [UIImage imageNamed:imageName];
    
    NSMutableArray *status = [NSMutableArray array];
    [status addObject:[stateValue choiceForLevelValueZeroValue:NSLocalizedString(@"sensor.status-label.OK", @"OK") nonZeroValue:NSLocalizedString(@"sensor.moisturesensor.status.FLOODED", @"FLOODED") nilValue:@""]];
    [self tryAddTemperatureStatus:status];
    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
}

- (void)configureBinaryPowerSwitch_45 {
    SFIDeviceKnownValues *stateValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SWITCH_BINARY];
    if (!stateValue) {
        [self configureUnknownDevice];
        return;
    }
    
    NSMutableArray *status = [NSMutableArray array];
    [status addObject:[stateValue choiceForBoolValueTrueValue:NSLocalizedString(@"sensor.status-label.ON", @"ON") falseValue:NSLocalizedString(@"sensor.status-label.OFF", @"OFF") nilValue:@""]];
    NSString *power = [self.deviceValue valueForProperty:SFIDevicePropertyType_POWER default:@""];
    if (power.length > 0) {
        [status addObject:[NSString stringWithFormat:NSLocalizedString(@"sensor.poweswitch.label.Power %@W", @"Power %@W"), power]];
    }
    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
    
    NSString *imageForNoValue = [self imageNameForNoValue];
    NSString *imageName = [stateValue choiceForBoolValueTrueValue:DT45_BINARY_POWER_TRUE falseValue:DT45_BINARY_POWER_FALSE nilValue:imageForNoValue];
    self.deviceImageView.image = [UIImage imageNamed:imageName];
}

- (void)configureSetPointThermostat_46 {
    SFIDeviceValue *const deviceValue = self.deviceValue;
    
    // Status label
    NSString *setPoint = [deviceValue valueForProperty:SFIDevicePropertyType_THERMOSTAT_SETPOINT default:@"-"];
    NSString *tempUnits = [deviceValue valueForProperty:SFIDevicePropertyType_UNITS default:@""];
    NSString *temperature = [deviceValue valueForProperty:SFIDevicePropertyType_TEMPERATURE default:@""];
    
    NSString *const degrees_symbol = @"\u00B0";
    
    if ([setPoint rangeOfString:degrees_symbol].length == 0) {
        // no degrees so add one
        setPoint = [setPoint stringByAppendingString:degrees_symbol];
    }
    
    NSString *state = [NSString stringWithFormat:@"SET POINT %@%@", setPoint, tempUnits];
    
    NSMutableArray *status = [NSMutableArray array];
    [status addObject:state];
    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
    
    // Calculate values
    [self configureTemperatureView:temperature description:@"Temperature" unitsSymbol:tempUnits];
}

- (void)configureColorDimmableLight_32:(NSString *)imageNameTrue imageNameFalse:(NSString *)imageNameFalse statusTrue:(NSString *)statusTrue statusFalse:(NSString *)statusFalse {
    [self configureBinaryStateSensor:imageNameTrue imageNameFalse:imageNameFalse statusTrue:statusTrue statusFalse:statusFalse];
    
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceState];
    if (!values) {
        self.deviceImageViewSecondary.image = nil;
        return;
    }
    
    SFIDeviceValue *deviceValue = self.deviceValue;
    
    BOOL turned_on = values.boolValue;
    float hue = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_CURRENT_HUE] floatValue];
    float saturation = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_CURRENT_SATURATION] floatValue];
    float brightness = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_SWITCH_MULTILEVEL] floatValue];
    //    float kelvin = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_COLOR_TEMPERATURE] floatValue];
    
    [self configureLampIcon:turned_on hue:hue saturation:saturation brightness:brightness];
}


- (void)configureHueLamp_48:(NSString *)imageNameTrue imageNameFalse:(NSString *)imageNameFalse statusTrue:(NSString *)statusTrue statusFalse:(NSString *)statusFalse {
    [self configureBinaryStateSensor:imageNameTrue imageNameFalse:imageNameFalse statusTrue:statusTrue statusFalse:statusFalse];
    
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceState];
    if (!values) {
        self.deviceImageViewSecondary.image = nil;
        return;
    }
    
    SFIDeviceValue *value = self.deviceValue;
    
    BOOL turned_on = values.boolValue;
    float hue = [[value knownValuesForProperty:SFIDevicePropertyType_COLOR_HUE] floatValue];
    float saturation = [[value knownValuesForProperty:SFIDevicePropertyType_SATURATION] floatValue];
    float brightness = [[value knownValuesForProperty:SFIDevicePropertyType_SWITCH_MULTILEVEL] floatValue];
    
    [self configureLampIcon:turned_on hue:hue saturation:saturation brightness:brightness];
}

- (void)configureGarageDoorOpener_53 {
    /*
     0	we can set 0 (to close) and 255(to open) only	Closed
     252		closing
     253		Stopped
     254		Opening
     255		Open
     */
    
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceState];
    if (!values) {
        [self configureUnknownDevice];
        return;
    }
    
    NSString *imageName;
    NSString *status;
    
    //todo this indicates insufficient abstraction; we should be able to push this logic direction into SFIDeviceKnownValues and SFIDevice
    
    switch (values.intValue) {
        case 0:
            imageName = DT53_GARAGE_SENSOR_CLOSED;
            status = @"CLOSED";
            break;
        case 252:
            imageName = DT53_GARAGE_SENSOR_DOWN;
            status = @"CLOSING";
            break;
        case 253:
            imageName = DT53_GARAGE_SENSOR_STOPPED;
            status = @"STOPPED";
            break;
        case 254:
            imageName = DT53_GARAGE_SENSOR_UP;
            status = @"OPENING";
            break;
        case 255:
            imageName = DT53_GARAGE_SENSOR_OPEN;
            status = @"OPEN";
            break;
        default:
            imageName = [self imageNameForNoValue];
            status = DEF_COULD_NOT_UPDATE_SENSOR;
    }
    
    [self configureSensorImageName:imageName statusMesssage:status];
}

- (void)configureNestSmokeDetector_58 {
    self.deviceImageView.image = [UIImage imageNamed:@"nest_58_icon"];
    NSMutableArray *status = [NSMutableArray array];
   
     SFIDeviceKnownValues *coValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CO_ALARM_STATE];
    SFIDeviceKnownValues *smokeValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SMOKE_ALARM_STATE];
    NSString * coText = @"";
    NSString * smokeText = @"";
    coText = [coValue.value capitalizedString];
    if ([coValue.value isEqualToString:@"true"]) {
        coText = @"Warning";
    }else if ([coValue.value isEqualToString:@"false"]){
        coText = @"Emergency";
    }
    
    smokeText = [smokeValue.value capitalizedString];
    if ([smokeValue.value isEqualToString:@"true"]) {
        smokeText = @"Warning";
    }else if ([smokeValue.value isEqualToString:@"false"]){
        smokeText = @"Emergency";
    }
    [status addObject:[NSString stringWithFormat:@"Smoke :%@ , CO :%@",smokeText,coText]];
//    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
    
}

- (void)configureNestThermostat_57 {
    self.deviceImageView.image = nil;
    self.deviceImageViewSecondary.image = nil;
    
    UILabel * lblThemperatureMain = [[UILabel alloc] initWithFrame:self.deviceImageView.frame];
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_CURRENT_TEMPERATURE];
    lblThemperatureMain.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:29.0f];
    lblThemperatureMain.textAlignment = NSTextAlignmentCenter;
    lblThemperatureMain.textColor = [UIColor whiteColor];
    lblThemperatureMain.text = [NSString stringWithFormat:@"%d°",[[SecurifiToolkit sharedInstance] convertTemperatureToCurrentFormat:[currentDeviceValue intValue]]];
    [self.contentView addSubview:lblThemperatureMain];
    NSMutableArray *status = [NSMutableArray array];
    
    currentDeviceValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_HVAC_STATE];
    [status addObject:[currentDeviceValue.value capitalizedString]];

//    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
}






// draws a hue lamp icon and tinted inset representing the currently configured color
- (void)configureLampIcon:(BOOL)turned_on hue:(float)hue saturation:(float)saturation brightness:(float)brightness {
    hue = hue / 65535;
    saturation = saturation / 255;
    brightness = brightness / 255;
    
    // put a floor underneath the brightness to prevent it from showing up as black
    if (brightness < 0.50) {
        brightness = 0.50;
    }
    
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    UIImage *image = turned_on ? [UIImage imageNamed:@"48_hue_on_center"] : [UIImage imageNamed:@"48_hue_off_center"];
    // work around problem on some older iOS machines causing icon template settings in assets catalog to be ignored
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    // work around problem on some older iOS machines causing icon template settings in assets catalog to be ignored
    self.deviceImageView.image = [self.deviceImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.deviceImageView.tintColor = [UIColor whiteColor];
    
    self.deviceImageViewSecondary.image = image;
    self.deviceImageViewSecondary.tintColor = color;
}

- (void)configureBinaryStateSensor:(NSString *)imageNameTrue imageNameFalse:(NSString *)imageNameFalse statusTrue:(NSString *)statusTrue statusFalse:(NSString *)statusFalse {
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceState];
    if (!values) {
        [self configureUnknownDevice];
        return;
    }
    
    NSString *noImage = [self imageNameForNoValue];
    NSString *imageName = [values choiceForBoolValueTrueValue:imageNameTrue falseValue:imageNameFalse nilValue:noImage];
    
    NSString *status = [values choiceForBoolValueTrueValue:statusTrue falseValue:statusFalse nilValue:DEF_COULD_NOT_UPDATE_SENSOR];
    [self configureSensorImageName:imageName statusMesssage:status];
}

- (void)configureBinaryStateSensorImageNameZeroValue:(NSString *)imageNameZeroValue imageNameNonZeroValue:(NSString *)imageNameNonZeroValue statusZeroValue:(NSString *)statusZeroValue statusNonZeroValue:(NSString *)statusNonZeroValue {
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceState];
    if (!values) {
        [self configureUnknownDevice];
        return;
    }
    
    NSString *noImage = [self imageNameForNoValue];
    NSString *imageName = [values choiceForLevelValueZeroValue:imageNameZeroValue nonZeroValue:imageNameNonZeroValue nilValue:noImage];
    
    NSString *status = [values choiceForLevelValueZeroValue:statusZeroValue nonZeroValue:statusNonZeroValue nilValue:DEF_COULD_NOT_UPDATE_SENSOR];
    [self configureSensorImageName:imageName statusMesssage:status];
}

- (void)configureSensorImageName:(NSString *)imageName statusMesssage:(NSString *)message {
    self.deviceImageView.image = [UIImage imageNamed:imageName];
    
    NSMutableArray *status = [NSMutableArray array];
    if (message) {
        [status addObject:message];
    }
    [self tryAddTemperatureStatus:status];
    [self tryAddBatteryStatusMessage:status];

    [self setDeviceStatusMessages:status];
}

- (NSString *)imageNameForNoValue {
    return DEVICE_RELOAD_IMAGE;
}

- (void)setUpdatingSensorStatus {
    [self showDeviceTemperatureView:NO];
    self.deviceImageView.image = [UIImage imageNamed:DEVICE_UPDATING_IMAGE];
    self.deviceImageViewSecondary.image = nil;
    self.deviceStatusLabel.text = self.updatingStatusMessage;
}

- (void)showDeviceTemperatureView:(BOOL)show {
    self.deviceTemperatureView.hidden = !show;
}

- (void)setDeviceStatusMessages:(NSArray *)statusMsgs {
    self.deviceStatusLabel.numberOfLines = 0;
    self.deviceStatusMessage = [statusMsgs componentsJoinedByString:@"\n"];
}

- (void)tryAddBatteryStatusMessage:(NSMutableArray *)status {
    if ([self.device isBatteryLow:self.deviceValue]) {
        [status addObject:NSLocalizedString(@"sensor.device-status.label.LOW BATTERY", @"LOW BATTERY")];
    }
    else {
        NSString *battery = [self.deviceValue valueForProperty:SFIDevicePropertyType_BATTERY default:@""];
        if (battery.length > 0) {
            [status addObject:[NSString stringWithFormat:NSLocalizedString(@"sensor.device-status.label.Battery %", @"Battery %@%%"), battery]];
        }
    }
}

- (void)tryAddTemperatureStatus:(const NSMutableArray *)status {
    NSString *temp = [self.deviceValue valueForProperty:SFIDevicePropertyType_TEMPERATURE default:@""];
    if (temp.length > 0) {
        [status addObject:[NSString stringWithFormat:NSLocalizedString(@"sensor.moisturesensor.status.Temp %@", @"TEMP %@"), temp]];
    }
}

#pragma mark - Device Values

//todo deprecate and get rid of;
- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDeviceState {
    return [self.deviceValue knownValuesForProperty:self.device.statePropertyType];
}

//todo deprecate and get rid of;
- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDeviceMutableState {
    return [self.deviceValue knownValuesForProperty:self.device.mutableStatePropertyType];
}

@end
