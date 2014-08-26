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

    UIView *leftBackgroundLabel = [[UIView alloc] initWithFrame:CGRectMake(10, 5, LEFT_LABEL_WIDTH, SENSOR_ROW_HEIGHT - 10)];
    leftBackgroundLabel.tag = 111;
    leftBackgroundLabel.userInteractionEnabled = YES;
    leftBackgroundLabel.backgroundColor = [self makeCellColor];
    [self.contentView addSubview:leftBackgroundLabel];

    UIButton *deviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deviceButton.tag = row_index;
    deviceButton.frame = leftBackgroundLabel.bounds;
    deviceButton.backgroundColor = [UIColor clearColor];
    [deviceButton addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftBackgroundLabel addSubview:deviceButton];

    UIView *rightBackgroundLabel = [[UIView alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH + 11, 5, cell_frame.size.width - LEFT_LABEL_WIDTH - 25, SENSOR_ROW_HEIGHT - 10)];
    rightBackgroundLabel.backgroundColor = [self makeCellColor];
    [self.contentView addSubview:rightBackgroundLabel];

    UILabel *deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, (cell_frame.size.width - LEFT_LABEL_WIDTH - 90), 30)];
    deviceNameLabel.backgroundColor = [UIColor clearColor];
    deviceNameLabel.textColor = [UIColor whiteColor];
    deviceNameLabel.text = currentSensor.deviceName;
    [rightBackgroundLabel addSubview:deviceNameLabel];

    UILabel *deviceStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, 180, 60)];
    deviceStatusLabel.backgroundColor = [UIColor clearColor];
    deviceStatusLabel.textColor = [UIColor whiteColor];
    deviceStatusLabel.numberOfLines = 2;
    deviceStatusLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    [rightBackgroundLabel addSubview:deviceStatusLabel];
    self.deviceStatusLabel = deviceStatusLabel;

    //todo seems like the button could take place of image view

    UIImageView *imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(cell_frame.size.width - 60, 37, 23, 23)];
    imgSettings.image = [UIImage imageNamed:@"icon_config.png"];
    imgSettings.alpha = 0.5;
    imgSettings.userInteractionEnabled = YES;
    [self.contentView addSubview:imgSettings];

    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.tag = row_index;
    settingsButton.frame = imgSettings.bounds;
    settingsButton.backgroundColor = [UIColor clearColor];
    [settingsButton addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgSettings addSubview:settingsButton];

    UIButton *settingsButtonCell = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButtonCell.tag = row_index;
    settingsButtonCell.frame = CGRectMake(cell_frame.size.width - 80, 5, 60, 80);
    settingsButtonCell.backgroundColor = [UIColor clearColor];
    [settingsButtonCell addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:settingsButtonCell];
}

- (void)layoutDeviceImageCell {
    UIButton *deviceImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deviceImageButton.tag = self.tag;
    deviceImageButton.backgroundColor = [UIColor clearColor];
    [deviceImageButton addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];

    if (self.device.deviceType == 7 /*thermostat */) {
        // In case of thermostat show value instead of image
        // For Integer Value
        self.deviceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 5, 12, 60, 70)];
        self.deviceValueLabel.backgroundColor = [UIColor clearColor];
        self.deviceValueLabel.textColor = [UIColor whiteColor];
        self.deviceValueLabel.textAlignment = NSTextAlignmentCenter;
        self.deviceValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:45];
        [self.deviceValueLabel addSubview:deviceImageButton];

        // For Decimal Value
        self.decimalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 10, 40, 20, 30)];
        self.decimalValueLabel.backgroundColor = [UIColor clearColor];
        self.decimalValueLabel.textColor = [UIColor whiteColor];
        self.decimalValueLabel.textAlignment = NSTextAlignmentCenter;
        self.decimalValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];

        // For Degree
        self.degreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 10, 25, 20, 20)];
        self.degreeLabel.backgroundColor = [UIColor clearColor];
        self.degreeLabel.textColor = [UIColor whiteColor];
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
    const SFIDevice *currentSensor = self.device;

    switch (currentSensor.deviceType) {
        case 1: {
            [self configureSwitch_1];
            break;
        }
        case 2: {
            [self configureMultiLevelSwitch_2];
            break;
        }
        case 3: {
            [self configureBinarySensor_3];
            break;
        }
        case 4: {
            [self configureLevelControl_4];
            break;
        }
        case 5: {
            [self configureDoorLocked_5];
            break;
        }
        case 6: {
            [self configureAlarm_6];
            break;
        }
        case 7: {
            [self configureThermostat_7];
            break;
        }
        case 11: {
            [self configureMotionSensor_11];
            break;
        }
        case 12: {
            [self configureContactSwitch_12];
            break;
        }
        case 13: {
            [self configureFireSensor_13];
            break;
        }
        case 14: {
            [self configureWaterSensor_14];
            break;
        }
        case 15: {
            [self configureGasSensor_15];
            break;
        }
        case 17: {
            [self configureGasSensor_17];
            break;
        }
        case 19: {
            [self configureKeyFob_19];
            break;
        }
        case 22: {
            [self configureElectricMeasurementSwitch_22];
            break;
        }
        case 23: {
            [self configureElectricMeasurementSwitch_23];
            break;
        }
        case 27: {
            [self configureTempSensor_27];
            break;
        }
        case 34: {
            [self configureShadeSensor_34];
            break;
        }
        default: {
            self.deviceImageView.image = [UIImage imageNamed:currentSensor.imageName];
            break;
        }
    } // for each device

    if (self.device.isExpanded) {
        SFISensorDetailView *detailView = [SFISensorDetailView new];
        detailView.frame = self.frame;
        detailView.tag = self.tag;
        detailView.device = self.device;
        detailView.deviceValue = self.deviceValue;
        detailView.currentColor = self.deviceColor;

        [self.contentView addSubview:detailView];
        self.detailView = detailView;
        self.detailView.delegate = self;
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

- (void)sensorDetailViewDidChangeSensorValue:(SFISensorDetailView *)view valueName:(NSString *)valueName newValue:(NSString *)aValue {
    [self.delegate tableViewCellDidChangeValue:self valueName:valueName newValue:aValue];
}

#pragma mark - Device layout

- (void)configureSwitch_1 {
    [self configureBinaryStateSensor:DT1_BINARY_SWITCH_TRUE imageNameFalse:DT1_BINARY_SWITCH_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
}

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

- (void)configureBinarySensor_3 {
    [self configureBinaryStateSensor:DT3_BINARY_SENSOR_TRUE imageNameFalse:DT3_BINARY_SENSOR_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
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

- (void)configureDoorLocked_5 {
    [self configureBinaryStateSensor:DT5_DOOR_LOCK_TRUE imageNameFalse:DT5_DOOR_LOCK_FALSE statusTrue:@"LOCKED" statusFalse:@"UNLOCKED"];
}

- (void)configureAlarm_6 {
    [self configureBinaryStateSensor:DT6_ALARM_TRUE imageNameFalse:DT6_ALARM_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
}

- (void)configureThermostat_7 {
    NSString *strValue = @"";
    NSString *strOperatingMode;
    NSString *heatingSetPoint;
    NSString *coolingSetPoint;

    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentKnownValue in currentKnownValues) {
        if ([currentKnownValue.valueName isEqualToString:@"SENSOR MULTILEVEL"]) {
            strValue = currentKnownValue.value;
            //lblDeviceValue.text = [NSString stringWithFormat:@"%@°",currentKnownValue.value] ;
        }
        else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT SETPOINT HEATING"]) {
            heatingSetPoint = [NSString stringWithFormat:@" HI %@°", currentKnownValue.value];
        }
        else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT SETPOINT COOLING"]) {
            coolingSetPoint = [NSString stringWithFormat:@" LO %@°", currentKnownValue.value];
        }
        else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT OPERATING STATE"]) {
            strOperatingMode = currentKnownValue.value;
        }
    }

    NSString *strStatus = [NSString stringWithFormat:@"%@, %@, %@", strOperatingMode, coolingSetPoint, heatingSetPoint];
    self.deviceStatusLabel.text = strStatus;

    //Calculate values
    NSArray *thermostatValues = [strValue componentsSeparatedByString:@"."];

    NSString *const strIntegerValue = thermostatValues[0];
    self.deviceValueLabel.text = strIntegerValue;


    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];

    if ([thermostatValues count] == 2) {
        NSString *strDecimalValue = thermostatValues[1];
        self.decimalValueLabel.text = [NSString stringWithFormat:@".%@", strDecimalValue];
    }

    if ([strIntegerValue length] == 1) {
        self.decimalValueLabel.frame = CGRectMake((self.frame.size.width / 4) - 25, 40, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 25, 20, 20);
    }
    else if ([strIntegerValue length] == 3) {
        self.deviceValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:30];
        self.decimalValueLabel.font = heavy_font;
        self.degreeLabel.font = heavy_font;

        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 38, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 30, 20, 20);
    }
    else if ([strIntegerValue length] == 4) {
        self.deviceValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:22];
        self.decimalValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:10];
        self.degreeLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:10];

        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 35, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 30, 20, 20);
    }
}

- (void)configureMotionSensor_11 {
    self.deviceImageView.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.25), 12, 53, 70); //todo why different?
    [self configureBinaryStateSensor:DT11_MOTION_SENSOR_TRUE imageNameFalse:DT11_MOTION_SENSOR_FALSE statusTrue:@"MOTION DETECTED" statusFalse:@"NO MOTION"];
}

- (void)configureContactSwitch_12 {
    [self configureBinaryStateSensor:DT12_CONTACT_SWITCH_TRUE imageNameFalse:DT12_CONTACT_SWITCH_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
}

- (void)configureFireSensor_13 {
    [self configureBinaryStateSensor:DT13_FIRE_SENSOR_TRUE imageNameFalse:DT13_FIRE_SENSOR_FALSE statusTrue:@"ALARM: FIRE DETECTED" statusFalse:@"OK"];
}

- (void)configureWaterSensor_14 {
    [self configureBinaryStateSensor:DT14_WATER_SENSOR_TRUE imageNameFalse:DT14_WATER_SENSOR_FALSE statusTrue:@"FLOODED" statusFalse:@"OK"];
}

- (void)configureGasSensor_15 {
    [self configureBinaryStateSensor:DT15_GAS_SENSOR_TRUE imageNameFalse:DT15_GAS_SENSOR_FALSE statusTrue:@"ALARM: GAS DETECTED" statusFalse:@"OK"];
}

- (void)configureGasSensor_17 {
    [self configureBinaryStateSensor:DT17_VIBRATION_SENSOR_TRUE imageNameFalse:DT17_VIBRATION_SENSOR_FALSE statusTrue:@"VIBRATION DETECTED" statusFalse:@"NO VIBRATION"];
}

- (void)configureKeyFob_19 {
    [self configureBinaryStateSensor:DT19_KEYFOB_TRUE imageNameFalse:DT19_KEYFOB_FALSE statusTrue:@"LOCKED" statusFalse:@"UNLOCKED"];
}

- (void)configureElectricMeasurementSwitch_22 {
    [self configureBinaryStateSensor:DT22_AC_SWITCH_TRUE imageNameFalse:DT22_AC_SWITCH_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
}

- (void)configureElectricMeasurementSwitch_23 {
    [self configureBinaryStateSensor:DT23_DC_SWITCH_TRUE imageNameFalse:DT23_DC_SWITCH_FALSE statusTrue:@"ON" statusFalse:@"OFF"];
}

- (void)configureTempSensor_27 {
    NSString *strValue = @"";

    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentKnownValue in currentKnownValues) {
        if ([currentKnownValue.valueName isEqualToString:@"MEASURED_VALUE"]) {
            strValue = currentKnownValue.value;
        }
        else if ([currentKnownValue.valueName isEqualToString:@"TOLERANCE"]) {
            self.deviceStatusLabel.text = [NSString stringWithFormat:@"Tolerance: %@", currentKnownValue.value];
        }
    }

    //Calculate values
    NSArray *temperatureValues = [strValue componentsSeparatedByString:@"."];


    NSString *strIntegerValue = temperatureValues[0];

    if ([temperatureValues count] == 2) {
        NSString *strDecimalValue = temperatureValues[1];
        self.decimalValueLabel.text = [NSString stringWithFormat:@".%@", strDecimalValue];
    }

    self.deviceValueLabel.text = strIntegerValue;
    if ([strIntegerValue length] == 1) {
        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 40, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 25, 20, 20);
    }
    else if ([strIntegerValue length] == 3) {
        UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];

        self.deviceValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:30];
        self.decimalValueLabel.font = heavy_font;
        self.degreeLabel.font = heavy_font;
        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 38, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 30, 20, 20);
    }
    else if ([strIntegerValue length] == 4) {
        self.deviceValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:22];
        self.decimalValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:10];
        self.degreeLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:10];
        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 35, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 30, 20, 20);
    }
}

- (void)configureShadeSensor_34 {
    [self configureBinaryStateSensor:DT34_SHADE_TRUE imageNameFalse:DT34_SHADE_FALSE statusTrue:@"OPEN" statusFalse:@"CLOSED"];
}

- (void)configureBinaryStateSensor:(NSString *)imageNameTrue imageNameFalse:(NSString *)imageNameFalse statusTrue:(NSString *)statusTrue statusFalse:(NSString *)statusFalse {
    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDevice];

    if (values.isUpdating) {
        [self setUpdatingSensorStatus];
    }
    else {
        NSString *imageName = [values choiceForBoolValueTrueValue:imageNameTrue falseValue:imageNameFalse nilValue:self.device.imageName];
        self.deviceImageView.image = [UIImage imageNamed:imageName];

        NSString *status = [values choiceForBoolValueTrueValue:statusTrue falseValue:statusFalse nilValue:@"Could not update sensor\ndata."];
        if (self.device.isBatteryLow) {
            status = [status stringByAppendingString:@"\nLOW BATTERY"];
            self.deviceStatusLabel.numberOfLines = 2;
        }
        self.deviceStatusLabel.text = status;
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
    return self.deviceValue.knownValues;
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
    