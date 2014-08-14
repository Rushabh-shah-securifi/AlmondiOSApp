//
//  SFISensorTableViewCell.h
//
//  Created by sinclair on 6/25/14.
//
#import "SFISensorTableViewCell.h"
#import "SFIConstants.h"


@interface SFISensorTableViewCell ()
@property UIImageView *deviceImage;
@property UILabel *deviceStatusLabel;
@property UILabel *deviceValueLabel;

// For thermostat
@property UILabel *decimalValueLabel;
@property UILabel *degreeLabel;

@end

@implementation SFISensorTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];

    self.deviceImage.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

    UIButton *deviceImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deviceImageButton.backgroundColor = [UIColor clearColor];
    [deviceImageButton addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];

    if (self.sensor.deviceType == 7 /*thermostat */) {
        //In case of thermostat show value instead of image
        //For Integer Value
        self.deviceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 5, 12, 60, 70)];
        self.deviceValueLabel.backgroundColor = [UIColor clearColor];
        self.deviceValueLabel.textColor = [UIColor whiteColor];
        self.deviceValueLabel.textAlignment = NSTextAlignmentCenter;
        self.deviceValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:45];
        [self.deviceValueLabel addSubview:deviceImageButton];

        //For Decimal Value
        self.decimalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 10, 40, 20, 30)];
        self.decimalValueLabel.backgroundColor = [UIColor clearColor];
        self.decimalValueLabel.textColor = [UIColor whiteColor];
        self.decimalValueLabel.textAlignment = NSTextAlignmentCenter;
        self.decimalValueLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];

        //For Degree
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
        self.deviceImage = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 3, 12, 53, 70)];
        self.deviceImage.userInteractionEnabled = YES;

        [self.deviceImage addSubview:deviceImageButton];
        deviceImageButton.frame = self.deviceImage.bounds;

        [self.contentView addSubview:self.deviceImage];
    }
}


- (void)configureSwitch_1 {
    self.deviceImage.image = [UIImage imageNamed:self.sensor.imageName];

    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceValuesIndex:0];
    NSString *currentValue = values.value;

    NSString *status;
    if (values.isUpdating) {
        status = @"Updating sensor data.\nPlease wait.";
    }
    else if (currentValue == nil) {
        status = @"Could not update sensor\ndata.";
    }
    else {
        status = [values choiceForBoolValueTrueValue:@"ON" falseValue:@"OFF" nilValue:currentValue];
    }

    self.deviceValueLabel.text = status;
}

- (void)configureMultiLevelSwitch_2 {
    NSString *name = [self.sensor imageName:DT2_MULTILEVEL_SWITCH_TRUE];
    self.deviceImage.image = [UIImage imageNamed:name];

    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDeviceValuesIndex:0];
    if (values.isUpdating) {
        self.deviceStatusLabel.text = @"Updating sensor data.\nPlease wait.";
    }
    else {
        //Get Percentage
        SFIDeviceKnownValues *currentLevelKnownValue = [self tryGetCurrentKnownValuesForDeviceValuesIndex:self.sensor.mostImpValueIndex];
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
    NSString *image_name = [self.sensor imageName:DT4_LEVEL_CONTROL_TRUE];
    self.deviceImage.image = [UIImage imageNamed:image_name];

    SFIDeviceKnownValues *values = [self tryGetCurrentKnownValuesForDevice];
    if (values.isUpdating) {
        self.deviceStatusLabel.text = @"Updating sensor data.\nPlease wait.";
    }
    else {
        //Get Percentage
        SFIDeviceKnownValues *currentLevelKnownValue = [self tryGetCurrentKnownValuesForDeviceValuesIndex:self.sensor.mostImpValueIndex];
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
    self.deviceImage.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.25), 12, 53, 70); //todo why different?
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

    NSString *imageName = [values choiceForBoolValueTrueValue:imageNameTrue falseValue:imageNameFalse nilValue:self.sensor.imageName];
    self.deviceImage.image = [UIImage imageNamed:imageName];

    NSString *status = [values choiceForBoolValueTrueValue:statusTrue falseValue:statusFalse nilValue:@"Could not update sensor\ndata."];
    if (self.sensor.isBatteryLow) {
        status = [status stringByAppendingString:@"\nLOW BATTERY"];
        self.deviceStatusLabel.numberOfLines = 2;
    }
    self.deviceStatusLabel.text = status;
}

- (void)initialize:(UITableView *)tableView listRow:(int)indexPathRow device:(SFIDevice *)currentSensor {
    int currentDeviceType = currentSensor.deviceType;

    UITableViewCell *cell = self;

    UIImageView *deviceImage;
    UILabel *deviceNameLabel;
    UILabel *deviceStatusLabel;

    UIImageView *imgSettings;
    UIButton *btnDevice;
    UIButton *btnDeviceImg;
    UIButton *btnSettings;
    UILabel *leftBackgroundLabel;
    UILabel *rightBackgroundLabel;
    UIButton *btnSettingsCell;

//    UIColor *standard_blue = [self makeStandardBlue];

    const CGRect cell_frame = self.frame;


    //Left Square - Creation
    leftBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, LEFT_LABEL_WIDTH, SENSOR_ROW_HEIGHT - 10)];
    leftBackgroundLabel.tag = 111;
    leftBackgroundLabel.userInteractionEnabled = YES;
    leftBackgroundLabel.backgroundColor = [self makeStandardBlue];
    [cell.contentView addSubview:leftBackgroundLabel];

    btnDeviceImg = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDeviceImg.backgroundColor = [UIColor clearColor];
    [btnDeviceImg addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];

    btnDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDevice.frame = leftBackgroundLabel.bounds;
    btnDevice.backgroundColor = [UIColor clearColor];
    [btnDevice addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftBackgroundLabel addSubview:btnDevice];

    //Right Rectangle - Creation
    rightBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH + 11, 5, cell_frame.size.width - LEFT_LABEL_WIDTH - 25, SENSOR_ROW_HEIGHT - 10)];
    rightBackgroundLabel.backgroundColor = [self makeStandardBlue];
    [cell.contentView addSubview:rightBackgroundLabel];

    deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, (cell_frame.size.width - LEFT_LABEL_WIDTH - 90), 30)];
    deviceNameLabel.backgroundColor = [UIColor clearColor];
    deviceNameLabel.textColor = [UIColor whiteColor];
    deviceStatusLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:16];
    [rightBackgroundLabel addSubview:deviceNameLabel];

    deviceStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, 180, 60)];
    deviceStatusLabel.backgroundColor = [UIColor clearColor];
    deviceStatusLabel.textColor = [UIColor whiteColor];
    deviceStatusLabel.numberOfLines = 2;
    deviceStatusLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    [rightBackgroundLabel addSubview:deviceStatusLabel];

    imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(cell_frame.size.width - 60, 37, 23, 23)];
    imgSettings.image = [UIImage imageNamed:@"icon_config.png"];
    imgSettings.alpha = 0.5;
    imgSettings.userInteractionEnabled = YES;

    btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.frame = imgSettings.bounds;
    btnSettings.backgroundColor = [UIColor clearColor];
    [btnSettings addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgSettings addSubview:btnSettings];

    btnSettingsCell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettingsCell.frame = CGRectMake(cell_frame.size.width - 80, 5, 60, 80);
    btnSettingsCell.backgroundColor = [UIColor clearColor];
    [btnSettingsCell addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnSettingsCell];

    //Fill values
    deviceNameLabel.text = currentSensor.deviceName;

    switch (currentDeviceType) {
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
            deviceImage.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
            deviceImage.image = [UIImage imageNamed:currentSensor.imageName];
            break;
        }
    }

    btnDevice.tag = indexPathRow;
    btnDeviceImg.tag = indexPathRow;
    btnSettings.tag = indexPathRow;
    btnSettingsCell.tag = indexPathRow;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:imgSettings];
}

- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDevice {
    return [self tryGetCurrentKnownValuesForDeviceValuesIndex:self.sensor.stateIndex];
}

- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDeviceValuesIndex:(int)stateIndex {
    NSArray *values = [self currentKnownValuesForDevice];
    if (stateIndex < values.count) {
        return values[(NSUInteger) index];
    }
    return nil;
}

- (NSArray *)currentKnownValuesForDevice {
    return self.deviceValues.knownValues;
}

- (UIColor *)makeStandardBlue {
    return [UIColor colorWithHue:(CGFloat) (self.changeHue / 360.0) saturation:(CGFloat) (self.changeSaturation / 100.0) brightness:(CGFloat) (self.changeBrightness / 100.0) alpha:1];
}

- (void)onSettingClicked:(id)onSettingClicked {

}

- (void)onDeviceClicked:(id)onDeviceClicked {

}

@end
    