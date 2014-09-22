//
//  SFISensorTableViewCell.h
//
//  Created by sinclair on 6/25/14.
//
#import "SFISensorTableViewCell.h"
#import "SFIConstants.h"
#import "SFIColors.h"
#import "SFISensorDetailView.h"


@interface SFISensorTableViewCell () <SFISensorDetailViewDelegate>
@property(nonatomic) UIImageView *deviceImageView;
@property(nonatomic) UILabel *deviceStatusLabel;
@property(nonatomic) UILabel *deviceValueLabel;

@property(nonatomic) SFISensorDetailView *detailView;

// For thermostat
@property(nonatomic) UILabel *decimalValueLabel;
@property(nonatomic) UILabel *degreeLabel;

@property(nonatomic) BOOL dirty;

@end

@implementation SFISensorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

- (void)markWillReuse {
    self.dirty = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.dirty) {
        self.dirty = NO;

        [self tearDown];
        [self layoutTileFrame];
        [self layoutDeviceImageCell];
        [self layoutDeviceInfo];
    }
}

- (void)tearDown {
    for (UIView *currentView in self.contentView.subviews) {
        [currentView removeFromSuperview];
    }
    self.deviceImageView = nil;
    self.deviceStatusLabel = nil;
    self.deviceValueLabel = nil;
    self.decimalValueLabel = nil;
    self.decimalValueLabel = nil;
}

- (void)layoutTileFrame {
    const SFIDevice *currentSensor = self.device;
    const CGRect cell_frame = self.frame;
    const NSInteger row_index = self.tag;

    UIColor *const cell_color = [self makeCellColor];
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
    [self.contentView addSubview:rightBackgroundLabel];

    UILabel *deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, (cell_frame.size.width - LEFT_LABEL_WIDTH - 90), 30)];
    deviceNameLabel.backgroundColor = clear_color;
    deviceNameLabel.textColor = white_color;
    deviceNameLabel.text = currentSensor.deviceName;
    [rightBackgroundLabel addSubview:deviceNameLabel];

    UILabel *deviceStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, 180, 60)];
    deviceStatusLabel.backgroundColor = clear_color;
    deviceStatusLabel.textColor = white_color;
    deviceStatusLabel.numberOfLines = 2;
    deviceStatusLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    [rightBackgroundLabel addSubview:deviceStatusLabel];
    self.deviceStatusLabel = deviceStatusLabel;

    //todo seems like the button could take place of image view

    UIImageView *settingsImage = [[UIImageView alloc] initWithFrame:CGRectMake(cell_frame.size.width - 60, 37, 23, 23)];
    settingsImage.image = [UIImage imageNamed:@"icon_config.png"];
    settingsImage.alpha = (CGFloat) (self.device.isExpanded ? 1.0 : 0.5); // change color of image when expanded
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
    UIColor *white_color = [UIColor whiteColor];

    UIButton *deviceImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deviceImageButton.tag = self.tag;
    deviceImageButton.backgroundColor = clear_color;
    [deviceImageButton addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];

    if (self.device.deviceType == 7 /*thermostat */) {
        // In case of thermostat show value instead of image
        // For Integer Value
        self.deviceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 5, 12, 60, 70)];
        self.deviceValueLabel.backgroundColor = clear_color;
        self.deviceValueLabel.textColor = white_color;
        self.deviceValueLabel.textAlignment = NSTextAlignmentCenter;
        self.deviceValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:45];
        [self.deviceValueLabel addSubview:deviceImageButton];

        // For Decimal Value
        self.decimalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 10, 40, 20, 30)];
        self.decimalValueLabel.backgroundColor = clear_color;
        self.decimalValueLabel.textColor = white_color;
        self.decimalValueLabel.textAlignment = NSTextAlignmentCenter;
        self.decimalValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];

        // For Degree
        self.degreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 10, 25, 20, 20)];
        self.degreeLabel.backgroundColor = clear_color;
        self.degreeLabel.textColor = white_color;
        self.degreeLabel.textAlignment = NSTextAlignmentCenter;
        self.degreeLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
        self.degreeLabel.text = @"°";

        [self.contentView addSubview:self.deviceValueLabel];
        [self.contentView addSubview:self.decimalValueLabel];
        [self.contentView addSubview:self.degreeLabel];
    }
    else {
        self.deviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 3, 12, 53, 70)];
        self.deviceImageView.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
        self.deviceImageView.userInteractionEnabled = YES;

        [self.deviceImageView addSubview:deviceImageButton];
        deviceImageButton.frame = self.deviceImageView.bounds;

        [self.contentView addSubview:self.deviceImageView];
    }
}

- (void)layoutDeviceInfo {
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
            [self configureBinaryStateSensor:DT5_DOOR_LOCK_TRUE imageNameFalse:DT5_DOOR_LOCK_FALSE statusTrue:@"LOCKED" statusFalse:@"UNLOCKED"];
            break;
        }

        case SFIDeviceType_Alarm_6: {
            [self configureBinaryStateSensor:DT6_ALARM_TRUE imageNameFalse:DT6_ALARM_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
            break;
        }

        case SFIDeviceType_Thermostat_7: {
            [self configureThermostat_7];
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
            [self configureKeyFab_19];
            break;
        }

        case SFIDeviceType_Keypad_20: {
            [self configureBinaryStateSensor:DT19_KEYFOB_TRUE imageNameFalse:DT19_KEYFOB_FALSE statusTrue:@"LOCKED" statusFalse:@"UNLOCKED"];
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

        case SFIDeviceType_WindowCovering_26: {
            [self configureBinaryStateSensor:DT26_WINDOW_COVERING_TRUE imageNameFalse:DT26_WINDOW_COVERING_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }

        case SFIDeviceType_TemperatureSensor_27: {
            [self configureTempSensor_27];
            break;
        }

        case SFIDeviceType_Shade_34: {
            [self configureBinaryStateSensor:DT34_SHADE_TRUE imageNameFalse:DT34_SHADE_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }

        case SFIDeviceType_SmokeDetector_36: {
            [self configureBinaryStateSensor:DT39_DOOR_SENSOR_TRUE imageNameFalse:DT39_DOOR_SENSOR_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }

        case SFIDeviceType_FloodSensor_37: {
            [self configureBinaryStateSensor:DT37_FLOOD_TRUE imageNameFalse:DT37_FLOOD_FALSE statusTrue:@"OKAY" statusFalse:@"FLOODED"];
            break;
        }

        case SFIDeviceType_ShockSensor_38: {
            [self configureBinaryStateSensor:DT38_SHOCK_TRUE imageNameFalse:DT38_SHOCK_FALSE statusTrue:@"VIBRATION DETECTED" statusFalse:@"NO VIBRATION"];
            break;
        }

        case SFIDeviceType_DoorSensor_39: {
            [self configureBinaryStateSensor:DT39_DOOR_SENSOR_TRUE imageNameFalse:DT39_DOOR_SENSOR_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }

        case SFIDeviceType_Controller_8:
        case SFIDeviceType_SceneController_9:
        case SFIDeviceType_StandardCIE_10:
        case SFIDeviceType_PersonalEmergencyDevice_16:
        case SFIDeviceType_StandardWarningDevice_21:
        case SFIDeviceType_OccupancySensor_24:
        case SFIDeviceType_LightSensor_25:
        case SFIDeviceType_SimpleMetering_28:
        case SFIDeviceType_ColorControl_29:
        case SFIDeviceType_PressureSensor_30:
        case SFIDeviceType_FlowSensor_31:
        case SFIDeviceType_ColorDimmableLight_32:
        case SFIDeviceType_HAPump_33:
        case SFIDeviceType_MoistureSensor_40:
        case SFIDeviceType_MovementSensor_41:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_MultiSwitch_43:
        case SFIDeviceType_UnknownOnOffModule_44:

        case SFIDeviceType_UnknownDevice_0:
        default: {
            self.deviceImageView.image = [UIImage imageNamed:@"default_device.png"];

        }
    } // for each device

    if (self.device.isExpanded) {
        SFISensorDetailView *detailView = [SFISensorDetailView new];
        detailView.frame = self.frame;
        detailView.tag = self.tag;
        detailView.delegate = self;
        detailView.device = device;
        detailView.deviceValue = self.deviceValue;
        detailView.color = [self makeCellColor];

        [self.contentView addSubview:detailView];
        self.detailView = detailView;
    }

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

#pragma mark - SFISensorDetailViewDelegate methods

- (void)sensorDetailViewDidPressSaveButton:(SFISensorDetailView *)view {
    [self.delegate tableViewCellDidSaveChanges:self];
}

- (void)sensorDetailViewDidPressDismissTamperButton:(SFISensorDetailView *)view {
    [self.delegate tableViewCellDidDismissTamper:self];
}

- (void)sensorDetailViewDidChangeSensorValue:(SFISensorDetailView *)view propertyType:(SFIDevicePropertyType)propertyType newValue:(NSString *)aValue {
    [self.delegate tableViewCellDidChangeValue:self propertyType:propertyType newValue:aValue];
}

#pragma mark - Device layout

- (void)configureMultiLevelSwitch_2 {
    NSString *name = [self.device imageName:DT2_MULTILEVEL_SWITCH_TRUE];
    self.deviceImageView.image = [UIImage imageNamed:name];

    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceValuesIndex:0];
    if (values.isUpdating) {
        [self setUpdatingSensorStatus];
    }
    else {
        //Get Percentage
        SFIDeviceKnownValues *currentLevelKnownValue = [self tryGetCurrentKnownValuesForDeviceValuesIndex:self.device.mostImpValueIndex];
        NSString *currentLevel = currentLevelKnownValue.value;

        self.deviceStatusLabel.text = [currentLevelKnownValue choiceForLevelValueZeroValue:@"OFF"
                                                                              nonZeroValue:[NSString stringWithFormat:@"Dimmable, %@%%", currentLevel]
                                                                                  nilValue:@"Could not update sensor\ndata."];
    }
}

- (void)configureLevelControl_4 {
    NSString *image_name = [self.device imageName:DT4_LEVEL_CONTROL_TRUE];
    self.deviceImageView.image = [UIImage imageNamed:image_name];

    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDevice];
    if (values.isUpdating) {
        [self setUpdatingSensorStatus];
    }
    else {
        //Get Percentage
        SFIDeviceKnownValues *currentLevelKnownValue = [self tryGetCurrentKnownValuesForDeviceValuesIndex:self.device.mostImpValueIndex];
        float intLevel = [currentLevelKnownValue floatValue];
        intLevel = (intLevel / 256) * 100;

        // Set some defaults
        NSString *status_str;

        if (!values.hasValue) {
            status_str = [currentLevelKnownValue choiceForLevelValueZeroValue:@"Dimmable"
                                                                 nonZeroValue:[NSString stringWithFormat:@"Dimmable, %.0f%%", intLevel]
                                                                     nilValue:@"Could not update sensor\ndata."];
        }
        else if (values.boolValue == true) {
            status_str = [currentLevelKnownValue choiceForLevelValueZeroValue:@"ON"
                                                                 nonZeroValue:[NSString stringWithFormat:@"ON, %.0f%%", intLevel]
                                                                     nilValue:@"ON"];
        }
        else {
            status_str = [currentLevelKnownValue choiceForLevelValueZeroValue:@"OFF"
                                                                 nonZeroValue:[NSString stringWithFormat:@"OFF, %.0f%%", intLevel]
                                                                     nilValue:@"OFF"];
        }

        self.deviceStatusLabel.text = status_str;
    }
}

- (void)configureThermostat_7 {
    // Status label
    NSString *strOperatingMode = [self.deviceValue valueForProperty:SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE default:@"Unknown"];
    NSString *coolingSetPoint = [self.deviceValue valueForProperty:SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING default:@"-"];
    NSString *heatingSetPoint = [self.deviceValue valueForProperty:SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING default:@"-"];
    self.deviceStatusLabel.text = [NSString stringWithFormat:@"%@,  LO %@\u00B0,  HI %@\u00B0", strOperatingMode, coolingSetPoint, heatingSetPoint]; // U+00B0 == degree sign

    // Calculate values
    NSString *strValue = [self.deviceValue valueForProperty:SFIDevicePropertyType_SENSOR_MULTILEVEL];
    NSArray *thermostatValues = [strValue componentsSeparatedByString:@"."];

    NSString *const strIntegerValue = thermostatValues[0];
    self.deviceValueLabel.text = strIntegerValue;

    UIFont *heavy_14 = [UIFont fontWithName:@"Avenir-Heavy" size:14];

    if ([thermostatValues count] == 2) {
        NSString *strDecimalValue = thermostatValues[1];
        self.decimalValueLabel.text = [NSString stringWithFormat:@".%@", strDecimalValue];
    }

    if ([strIntegerValue length] == 1) {
        self.decimalValueLabel.frame = CGRectMake((self.frame.size.width / 4) - 25, 40, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 25, 20, 20);
    }
    else if ([strIntegerValue length] == 3) {
        self.deviceValueLabel.font = [heavy_14 fontWithSize:30];
        self.decimalValueLabel.font = heavy_14;
        self.degreeLabel.font = heavy_14;

        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 38, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 30, 20, 20);
    }
    else if ([strIntegerValue length] == 4) {
        UIFont *heavy_10 = [heavy_14 fontWithSize:10];

        self.deviceValueLabel.font = [heavy_14 fontWithSize:22];
        self.decimalValueLabel.font = heavy_10;
        self.degreeLabel.font = heavy_10;

        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 35, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 30, 20, 20);
    }
}

- (void)configureKeyFab_19 {
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDevice];
    if (values.isUpdating) {
        [self setUpdatingSensorStatus];
    }
    else {
        SFIDeviceValue *const deviceValue = self.deviceValue;

        NSString *state = [deviceValue choiceForPropertyValue:SFIDevicePropertyType_ARMMODE choices:@{@"0" : @"ALL DISARMED", @"2":@"PERIMETER ARMED", @"3":@"ALL ARMED"} default:@"Could not update sensor\ndata."];
        if (self.device.isBatteryLow) {
            state = [state stringByAppendingString:@"\nLOW BATTERY"];
            self.deviceStatusLabel.numberOfLines = 2;
        }
        self.deviceStatusLabel.text = state;

        NSString *imageForNoValue = [self imageForNoValue];
        NSString *imageName = [deviceValue choiceForPropertyValue:SFIDevicePropertyType_ARMMODE choices:@{@"0" : DT19_KEYFOB_FALSE, @"2":DT19_KEYFOB_TRUE, @"3":DT19_KEYFOB_TRUE} default:imageForNoValue];
        self.deviceImageView.image = [UIImage imageNamed:imageName];
    }
}

- (void)configureTempSensor_27 {
    NSString *str = [self.deviceValue valueForProperty:SFIDevicePropertyType_TOLERANCE default:@""];
    self.deviceStatusLabel.text = [NSString stringWithFormat:@"Tolerance: %@", str];

    //Calculate values
    NSString *strValue = [self.deviceValue valueForProperty:SFIDevicePropertyType_MEASURED_VALUE default:@""];
    NSArray *temperatureValues = [strValue componentsSeparatedByString:@"."];

    NSString *strIntegerValue = @"";
    if ([temperatureValues count] > 0) {
        strIntegerValue = temperatureValues[0];
    }

    if ([temperatureValues count] == 2) {
        NSString *strDecimalValue = temperatureValues[1];
        self.decimalValueLabel.text = [NSString stringWithFormat:@".%@", strDecimalValue];
    }

    self.deviceValueLabel.text = strIntegerValue;

    NSUInteger str_length = [strIntegerValue length];
    if (str_length == 1) {
        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 40, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 25, 20, 20);
    }
    else if (str_length == 3) {
        UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];

        self.deviceValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:30];
        self.decimalValueLabel.font = heavy_font;
        self.degreeLabel.font = heavy_font;
        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 38, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 30, 20, 20);
    }
    else if (str_length == 4) {
        self.deviceValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:22];
        self.decimalValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:10];
        self.degreeLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:10];
        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 35, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 30, 20, 20);
    }
}

- (void)configureFloodSensor_37 {

}

- (void)configureBinaryStateSensor:(NSString *)imageNameTrue imageNameFalse:(NSString *)imageNameFalse statusTrue:(NSString *)statusTrue statusFalse:(NSString *)statusFalse {
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDevice];

    if (values.isUpdating) {
        [self setUpdatingSensorStatus];
    }
    else {
        NSString *imageForNoValue = [self imageForNoValue];
        NSString *imageName = [values choiceForBoolValueTrueValue:imageNameTrue falseValue:imageNameFalse nilValue:imageForNoValue];
        self.deviceImageView.image = [UIImage imageNamed:imageName];

        NSString *status = [values choiceForBoolValueTrueValue:statusTrue falseValue:statusFalse nilValue:@"Could not update sensor\ndata."];
        if (self.device.isBatteryLow) {
            status = [status stringByAppendingString:@"\nLOW BATTERY"];
            self.deviceStatusLabel.numberOfLines = 2;
        }
        self.deviceStatusLabel.text = status;
    }
}

- (NSString *)imageForNoValue {
    if (self.deviceValue.valueCount == 0) {
        return @"Reload_icon.png";
    }

    switch (self.device.deviceType) {
        case SFIDeviceType_UnknownDevice_0:
        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_MultiLevelSwitch_2:
        case SFIDeviceType_BinarySensor_3:
        case SFIDeviceType_MultiLevelOnOff_4:
        case SFIDeviceType_DoorLock_5:
        case SFIDeviceType_Alarm_6:
        case SFIDeviceType_Thermostat_7:
        case SFIDeviceType_Controller_8:
        case SFIDeviceType_SceneController_9:
        case SFIDeviceType_StandardCIE_10:
        case SFIDeviceType_MotionSensor_11:
        case SFIDeviceType_ContactSwitch_12:
        case SFIDeviceType_FireSensor_13:
        case SFIDeviceType_WaterSensor_14:
        case SFIDeviceType_GasSensor_15:
        case SFIDeviceType_PersonalEmergencyDevice_16:
        case SFIDeviceType_VibrationOrMovementSensor_17:
        case SFIDeviceType_RemoteControl_18:
        case SFIDeviceType_KeyFob_19:
        case SFIDeviceType_Keypad_20:
        case SFIDeviceType_StandardWarningDevice_21:
        case SFIDeviceType_SmartACSwitch_22:
        case SFIDeviceType_SmartDCSwitch_23:
        case SFIDeviceType_OccupancySensor_24:
        case SFIDeviceType_LightSensor_25:
        case SFIDeviceType_WindowCovering_26:
        case SFIDeviceType_TemperatureSensor_27:
        case SFIDeviceType_SimpleMetering_28:
        case SFIDeviceType_ColorControl_29:
        case SFIDeviceType_PressureSensor_30:
        case SFIDeviceType_FlowSensor_31:
        case SFIDeviceType_ColorDimmableLight_32:
        case SFIDeviceType_HAPump_33:
        case SFIDeviceType_Shade_34:
        case SFIDeviceType_SmokeDetector_36:
        case SFIDeviceType_FloodSensor_37:
        case SFIDeviceType_ShockSensor_38:
        case SFIDeviceType_DoorSensor_39:
        case SFIDeviceType_MoistureSensor_40:
        case SFIDeviceType_MovementSensor_41:
        case SFIDeviceType_Siren_42:
        case SFIDeviceType_MultiSwitch_43:
        case SFIDeviceType_UnknownOnOffModule_44:
        default: {
            return @"default_device.png";
            
        }
    }
}

- (void)setUpdatingSensorStatus {
    self.deviceImageView.image = [UIImage imageNamed:@"Wait_Icon.png"];
    self.deviceStatusLabel.text = @"Updating sensor data.\nPlease wait.";
}

#pragma mark - Device Values

- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDevice {
    return [self tryGetCurrentKnownValuesForDeviceValuesIndex:self.device.stateIndex];
}

- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDeviceValuesIndex:(int)stateIndex {
    NSArray *values = [self currentKnownValuesForDevice];
    if (values.count > 0 && stateIndex < values.count) {
        return values[(NSUInteger) stateIndex];
    }
    return nil;
}

- (NSArray *)currentKnownValuesForDevice {
    return self.deviceValue.knownDevicesValues;
}

- (UIColor *)makeCellColor {
    SFIColors *color = self.deviceColor;

    int positionIndex = self.tag % 15;

    int brightness = 0;
    if (positionIndex < 7) {
        brightness = color.brightness - (positionIndex * 10);
    }
    else {
        brightness = (color.brightness - 70) + ((positionIndex - 7) * 10);
    }

    return [UIColor colorWithHue:(CGFloat) (color.hue / 360.0)
                      saturation:(CGFloat) (color.saturation / 100.0)
                      brightness:(CGFloat) (brightness / 100.0)
                           alpha:1];
}

@end
    