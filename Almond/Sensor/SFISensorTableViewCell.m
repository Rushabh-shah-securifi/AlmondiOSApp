//
//  SFISensorTableViewCell.h
//
//  Created by sinclair on 6/25/14.
//
#import "SFISensorTableViewCell.h"
#import "SFIConstants.h"
#import "SFISensorDetailView.h"
#import "UIFont+Securifi.h"


#define DEF_COULD_NOT_UPDATE_SENSOR @"Could not update sensor\ndata."

@interface SFISensorTableViewCell () <SFISensorDetailViewDelegate>
@property(nonatomic) UIImageView *deviceImageView;
@property(nonatomic) UILabel *deviceStatusLabel;
@property(nonatomic) UILabel *deviceValueLabel;
@property(nonatomic, readonly) UILabel *deviceNameLabel;

@property(nonatomic) SFISensorDetailView *detailView;

// For thermostat
@property(nonatomic) UILabel *decimalValueLabel;
@property(nonatomic) UILabel *degreeLabel;

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
    self.deviceValueLabel = nil;
    self.decimalValueLabel = nil;
    self.decimalValueLabel = nil;
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
    UIColor *white_color = [UIColor whiteColor];

    UIButton *deviceImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deviceImageButton.tag = self.tag;
    deviceImageButton.backgroundColor = clear_color;
    [deviceImageButton addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];

    if (self.device.deviceType == SFIDeviceType_Thermostat_7 || self.device.deviceType == SFIDeviceType_TemperatureSensor_27) {
        // In case of thermostat show value instead of image
        // For Integer Value
        self.deviceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 5, 12, 60, 70)];
        self.deviceValueLabel.backgroundColor = clear_color;
        self.deviceValueLabel.textColor = white_color;
        self.deviceValueLabel.textAlignment = NSTextAlignmentCenter;
        self.deviceValueLabel.font = [UIFont securifiBoldFont:45];
        [self.deviceValueLabel addSubview:deviceImageButton];

        // For Decimal Value
        self.decimalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 20, 40, 20, 30)];
        self.decimalValueLabel.backgroundColor = clear_color;
        self.decimalValueLabel.textColor = white_color;
        self.decimalValueLabel.textAlignment = NSTextAlignmentCenter;
        self.decimalValueLabel.adjustsFontSizeToFitWidth = YES;
        self.decimalValueLabel.font = [UIFont securifiBoldFont:18];

        // For Degree
        self.degreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 20, 25, 20, 20)];
        self.degreeLabel.backgroundColor = clear_color;
        self.degreeLabel.textColor = white_color;
        self.degreeLabel.textAlignment = NSTextAlignmentCenter;
        self.degreeLabel.font = [UIFont standardHeadingBoldFont];
        self.degreeLabel.text = @"\u00B0"; // degree sign

        [self.contentView addSubview:self.deviceValueLabel];
        [self.contentView addSubview:self.decimalValueLabel];
        [self.contentView addSubview:self.degreeLabel];
    }

    self.deviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 3, 12, 53, 70)];
    self.deviceImageView.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
    self.deviceImageView.userInteractionEnabled = YES;

    [self.deviceImageView addSubview:deviceImageButton];
    deviceImageButton.frame = self.deviceImageView.bounds;

    [self.contentView addSubview:self.deviceImageView];
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
            [self configureBinaryStateSensor:DT5_DOOR_LOCK_TRUE imageNameFalse:DT5_DOOR_LOCK_FALSE statusNonZeroValue:@"UNLOCKED" statusZeroValue:@"LOCKED"];
            break;
        }

        case SFIDeviceType_Alarm_6: {
            [self configureBinaryStateSensor:DT6_ALARM_TRUE imageNameFalse:DT6_ALARM_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
            break;
        }

        case SFIDeviceType_Thermostat_7: {
            [self showDeviceValueLabels:YES];
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
            [self configureBinaryStateSensor:DT21_STANDARD_WARNING_DEVICE_TRUE imageNameFalse:DT21_STANDARD_WARNING_DEVICE_FALSE statusTrue:@"RINGING" statusFalse:@"OFF"];
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

        case SFIDeviceType_LightSensor_25: {
            [self configureLightSensor_25];
            break;
        }

        case SFIDeviceType_WindowCovering_26: {
            [self configureBinaryStateSensor:DT26_WINDOW_COVERING_TRUE imageNameFalse:DT26_WINDOW_COVERING_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }

        case SFIDeviceType_TemperatureSensor_27: {
            [self showDeviceValueLabels:YES];
            [self configureTempSensor_27];
            break;
        }

        case SFIDeviceType_Shade_34: {
            [self configureBinaryStateSensor:DT34_SHADE_TRUE imageNameFalse:DT34_SHADE_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
            break;
        }

        case SFIDeviceType_SmokeDetector_36: {
            [self configureBinaryStateSensor:DT36_SMOKE_DETECTOR_TRUE imageNameFalse:DT36_SMOKE_DETECTOR_FALSE statusNonZeroValue:@"OK" statusZeroValue:@"SMOKE DETECTED!"];
            break;
        }

        case SFIDeviceType_FloodSensor_37: {
            [self configureBinaryStateSensor:DT37_FLOOD_TRUE imageNameFalse:DT37_FLOOD_FALSE statusNonZeroValue:@"OK" statusZeroValue:@"FLOODED"];
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

            //PY 051114 - Phillips Hue
        case SFIDeviceType_HueLamp_48: {
            [self configureHueLamp_48:DT48_HUE_LAMP_TRUE imageNameFalse:DT48_HUE_LAMP_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
            break;
        }

        case SFIDeviceType_UnknownDevice_0:
        case SFIDeviceType_Controller_8:
        case SFIDeviceType_SceneController_9:
        case SFIDeviceType_PersonalEmergencyDevice_16:
        case SFIDeviceType_RemoteControl_18:
        case SFIDeviceType_Keypad_20:
        case SFIDeviceType_OccupancySensor_24:
        case SFIDeviceType_SimpleMetering_28:
        case SFIDeviceType_ColorControl_29:
        case SFIDeviceType_PressureSensor_30:
        case SFIDeviceType_FlowSensor_31:
        case SFIDeviceType_ColorDimmableLight_32:
        case SFIDeviceType_HAPump_33:
        case SFIDeviceType_MultiSwitch_43:
        default: {
            [self configureUnknownDevice];
        }
    } // for each device
}

- (void)configureUnknownDevice {
//    [self configureBinaryStateSensor:DT1_BINARY_SWITCH_TRUE imageNameFalse:DT1_BINARY_SWITCH_FALSE statusTrue:@"TRUE" statusFalse:@"FALSE"];
    [self configureSensorImageName:DEVICE_UNKNOWN_IMAGE statusMesssage:nil];
}

- (void)setTemperatureValue:(NSString *)value {
    NSArray *tempValues = [value componentsSeparatedByString:@"."];
    switch ([tempValues count]) {
        case 0: {
            [self setTemperatureIntegerValue:nil decimalValue:nil degreesValue:nil];
            break;
        }
        case 1: {
            [self setTemperatureIntegerValue:tempValues[0] decimalValue:nil degreesValue:nil];
            break;
        }
        default: {
            NSString *decimal = tempValues[1];
            NSString *degrees = nil;

            // check for embedded degrees marker
            NSRange range = [decimal rangeOfString:@"\u00B0"];
            if (range.length > 0) {
                degrees = [decimal substringFromIndex:range.location];
                decimal = [decimal substringToIndex:range.location];
            }

            [self setTemperatureIntegerValue:tempValues[0] decimalValue:decimal degreesValue:degrees];
            break;
        }
    }
}

- (void)setTemperatureIntegerValue:(NSString *)integerValue decimalValue:(NSString *)decimalValue degreesValue:(NSString *)degreesValue {
    UIFont *heavy_14 = [UIFont securifiBoldFontLarge];

    self.deviceValueLabel.text = integerValue;

    if (decimalValue.length > 0) {
        self.decimalValueLabel.text = [NSString stringWithFormat:@".%@", decimalValue];
    }
    else {
        self.decimalValueLabel.text = nil;
    }

    if (degreesValue.length > 0) {
        self.degreeLabel.text = degreesValue;
    }
    else {
        self.degreeLabel.text = @"\u00B0";
    }

    NSUInteger integerValue_length = [integerValue length];
    if (integerValue_length == 1) {
        self.decimalValueLabel.frame = CGRectMake((self.frame.size.width / 4) - 25, 40, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 25, 20, 20);
    }
    else if (integerValue_length == 3) {
        self.deviceValueLabel.font = [heavy_14 fontWithSize:30];
        self.decimalValueLabel.font = heavy_14;
        self.degreeLabel.font = heavy_14;

        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 38, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 30, 20, 20);
    }
    else if (integerValue_length == 4) {
        UIFont *heavy_10 = [heavy_14 fontWithSize:10];

        self.deviceValueLabel.font = [heavy_14 fontWithSize:22];
        self.decimalValueLabel.font = heavy_10;
        self.degreeLabel.font = heavy_10;

        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 35, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 30, 20, 20);
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

// toggles the label to reveal the underlying device type
- (void)onDeviceNameLabelTapped:(id)sender {
    UILabel *label = self.deviceNameLabel;
    NSString *name = self.device.deviceName;

    if ([label.text isEqualToString:name]) {
        label.text = [SFIDevice nameForType:self.device.deviceType];
    }
    else {
        label.text = name;
    }
}

#pragma mark - SFISensorDetailViewDelegate methods

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

- (void)sensorDetailViewDidChangeNotificationPref:(SFISensorDetailView *)view notificationSettingEnabled:(BOOL)enabled {
    [self.delegate tableViewCellDidChangeNotificationSetting:self notificationSettingEnabled:enabled];
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
    [self setTemperatureValue:value];
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
    [self setTemperatureValue:temp];

    NSMutableArray *status = [NSMutableArray array];
    NSString *humidity = [self.deviceValue valueForProperty:SFIDevicePropertyType_HUMIDITY default:@""];
    if (humidity.length > 0) {
        NSString *label_format = NSLocalizedString(@"sensor.tempsensor.status-label.Humidity %@", @"Humidity %@");
        [status addObject:[NSString stringWithFormat:label_format, humidity]];
    }
    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
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
    NSString *temp = [self.deviceValue valueForProperty:SFIDevicePropertyType_TEMPERATURE default:@""];
    if (temp.length > 0) {
        [status addObject:[NSString stringWithFormat:NSLocalizedString(@"sensor.moisturesensor.status.Temp %@", @"Temp %@"), temp]];
    }
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


//PY 051114 - Add Philips Hue
- (void)configureHueLamp_48:(NSString *)imageNameTrue imageNameFalse:(NSString *)imageNameFalse statusTrue:(NSString *)statusTrue statusFalse:(NSString *)statusFalse {
    SFIDeviceKnownValues *stateValue = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_STATE];
    if (!stateValue) {
        [self configureUnknownDevice];
        return;
    }
    
    NSString *imageForNoValue = [self imageNameForNoValue];
    NSString *imageName = [stateValue choiceForBoolValueTrueValue:DT48_HUE_LAMP_TRUE falseValue:DT48_HUE_LAMP_FALSE nilValue:imageForNoValue];
    // imgBulb.image = [[UIImage imageNamed:@"philips_hue_bulb.png"]  imageTintedWithColor:colorPicked];
    
    float hue = [[self.deviceValue knownValuesForProperty:SFIDevicePropertyType_COLOR_HUE] floatValue];
    float saturation = [[self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SATURATION] floatValue];
    float brightness = [[self.deviceValue knownValuesForProperty:SFIDevicePropertyType_BRIGHTNESS] floatValue];
    
    NSLog(@"%f %f %f", hue, saturation, brightness);
    
    //TODO: Set color
    
//    //UIColor *currentColor = [UIColor colorWithHue:(hue/182.0)/360.0 saturation:(saturation/255.0)/100.0 brightness:(brightness/255.0)/100.0 alpha:1];
//    //self.deviceImageView.image = [[UIImage imageNamed:imageName] imageTintedWithColor:[UIColor redColor]];
//    //self.deviceImageView.image = [self.deviceImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    // [self.deviceImageView setTintColor:[UIColor redColor]];
//    self.deviceImageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    self.deviceImageView.tintColor = [UIColor colorWithRed:0.98 green:0.47 blue:0 alpha:1];
    
    NSString *status = [stateValue choiceForBoolValueTrueValue:statusTrue falseValue:statusFalse nilValue:DEF_COULD_NOT_UPDATE_SENSOR];
    [self configureSensorImageName:imageName statusMesssage:status];
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

- (void)configureBinaryStateSensor:(NSString *)imageNameTrue imageNameFalse:(NSString *)imageNameFalse statusNonZeroValue:(NSString *)statusTrue statusZeroValue:(NSString *)statusFalse {
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceState];
    if (!values) {
        [self configureUnknownDevice];
        return;
    }

    NSString *noImage = [self imageNameForNoValue];
    NSString *imageName = [values choiceForLevelValueZeroValue:imageNameFalse nonZeroValue:imageNameTrue nilValue:noImage];

    NSString *status = [values choiceForLevelValueZeroValue:statusTrue nonZeroValue:statusFalse nilValue:DEF_COULD_NOT_UPDATE_SENSOR];
    [self configureSensorImageName:imageName statusMesssage:status];
}

- (void)configureSensorImageName:(NSString *)imageName statusMesssage:(NSString *)message {
    self.deviceImageView.image = [UIImage imageNamed:imageName];

    NSMutableArray *status = [NSMutableArray array];
    if (message) {
        [status addObject:message];
    }
    [self tryAddBatteryStatusMessage:status];
    [self setDeviceStatusMessages:status];
}

- (NSString *)imageNameForNoValue {
    return DEVICE_RELOAD_IMAGE;
}

- (void)setUpdatingSensorStatus {
    [self showDeviceValueLabels:NO];
    self.deviceImageView.image = [UIImage imageNamed:DEVICE_UPDATING_IMAGE];
    self.deviceStatusLabel.text = self.updatingStatusMessage;
}

- (void)showDeviceValueLabels:(BOOL)show {
    self.deviceValueLabel.hidden = !show;
    self.decimalValueLabel.hidden = !show;
    self.degreeLabel.hidden = !show;
}

- (void)setDeviceStatusMessages:(NSArray *)statusMsgs {
    self.deviceStatusLabel.numberOfLines = (statusMsgs.count > 1) ? 0 : 1;
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
    