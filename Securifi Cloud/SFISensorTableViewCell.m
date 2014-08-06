//
//  SFISensorTableViewCell.h
//
//  Created by sinclair on 6/25/14.
//
#import "SFISensorTableViewCell.h"
#import "SFIConstants.h"


@interface SFISensorTableViewCell ()
@property(nonatomic) int changeBrightness;
@property(nonatomic) int baseBrightness;
@end

@implementation SFISensorTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
}


- (void)initialize:(UITableView *)tableView listRow:(int)indexPathRow device:(SFIDevice *)currentSensor {
    int currentDeviceType = currentSensor.deviceType;

    NSUInteger height = [self computeSensorRowHeight:currentSensor];
    NSString *id = currentSensor.isExpanded ?
            [NSString stringWithFormat:@"SensorExpanded_%d_%ld", currentDeviceType, (unsigned long) height] :
            @"SensorSmall";

    UIImageView *imgDevice;
    UILabel *lblDeviceValue;
    UILabel *lblDecimalValue;
    UILabel *lblDegree;
    UILabel *lblDeviceName;
    UILabel *lblDeviceStatus;

    UIImageView *imgSettings;
    UIButton *btnDevice;
    UIButton *btnDeviceImg;
    UIButton *btnSettings;
    UILabel *leftBackgroundLabel;
    UILabel *rightBackgroundLabel;
    UIButton *btnSettingsCell;

//    UIColor *standard_blue = [self makeStandardBlue];
    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];

    int positionIndex = indexPathRow % 15;
    if (positionIndex < 7) {
        self.changeBrightness = self.baseBrightness - (positionIndex * 10);
    }
    else {
        self.changeBrightness = (self.baseBrightness - 70) + ((positionIndex - 7) * 10);
    }

    //Left Square - Creation
    leftBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,5,LEFT_LABEL_WIDTH,SENSOR_ROW_HEIGHT-10)];
    leftBackgroundLabel.tag = 111;
    leftBackgroundLabel.userInteractionEnabled = YES;
    leftBackgroundLabel.backgroundColor = [self makeStandardBlue];
    [self.contentView addSubview:leftBackgroundLabel];

    btnDeviceImg = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDeviceImg.backgroundColor = [UIColor clearColor];
    [btnDeviceImg addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];

    if (currentDeviceType == 7) {
        //In case of thermostat show value instead of image
        //For Integer Value
        lblDeviceValue = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 5, 12, 60, 70)];
        lblDeviceValue.backgroundColor = [UIColor clearColor];
        lblDeviceValue.textColor = [UIColor whiteColor];
        lblDeviceValue.textAlignment = NSTextAlignmentCenter;
        lblDeviceValue.font = [UIFont fontWithName:@"Avenir-Heavy" size:45];
        [lblDeviceValue addSubview:btnDeviceImg];

        //For Decimal Value
        lblDecimalValue = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 10, 40, 20, 30)];
        lblDecimalValue.backgroundColor = [UIColor clearColor];
        lblDecimalValue.textColor = [UIColor whiteColor];
        lblDecimalValue.textAlignment = NSTextAlignmentCenter;
        lblDecimalValue.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];

        //For Degree
        lblDegree = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 10, 25, 20, 20)];
        lblDegree.backgroundColor = [UIColor clearColor];
        lblDegree.textColor = [UIColor whiteColor];
        lblDegree.textAlignment = NSTextAlignmentCenter;
        lblDegree.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
        lblDegree.text = @"°";

        [self.contentView addSubview:lblDeviceValue];
        [self.contentView addSubview:lblDecimalValue];
        [self.contentView addSubview:lblDegree];
    }
    else {
        imgDevice = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 3, 12, 53, 70)];
        imgDevice.userInteractionEnabled = YES;
        [imgDevice addSubview:btnDeviceImg];
        btnDeviceImg.frame = imgDevice.bounds;
        [self.contentView addSubview:imgDevice];
    }

    btnDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDevice.frame = leftBackgroundLabel.bounds;
    btnDevice.backgroundColor = [UIColor clearColor];
    [btnDevice addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftBackgroundLabel addSubview:btnDevice];

    CGFloat width = self.frame.size.width;

    //Right Rectangle - Creation
    rightBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH + 11, 5, width - LEFT_LABEL_WIDTH - 25, SENSOR_ROW_HEIGHT - 10)];
    rightBackgroundLabel.backgroundColor = [self makeStandardBlue];
    [self.contentView addSubview:rightBackgroundLabel];

    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, (width - LEFT_LABEL_WIDTH - 90), 30)];
    lblDeviceName.backgroundColor = [UIColor clearColor];
    lblDeviceName.textColor = [UIColor whiteColor];
    lblDeviceStatus.font = [UIFont fontWithName:@"Avenir-Heavy" size:16];
    [rightBackgroundLabel addSubview:lblDeviceName];

    lblDeviceStatus = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, 180, 60)];
    lblDeviceStatus.backgroundColor = [UIColor clearColor];
    lblDeviceStatus.textColor = [UIColor whiteColor];
    lblDeviceStatus.numberOfLines = 2;
    lblDeviceStatus.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    [rightBackgroundLabel addSubview:lblDeviceStatus];

    imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(width - 60, 37, 23, 23)];
    imgSettings.image = [UIImage imageNamed:@"icon_config.png"];
    imgSettings.alpha = 0.5;
    imgSettings.userInteractionEnabled = YES;

    btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.frame = imgSettings.bounds;
    btnSettings.backgroundColor = [UIColor clearColor];
    [btnSettings addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgSettings addSubview:btnSettings];

    btnSettingsCell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettingsCell.frame = CGRectMake(width - 80, 5, 60, 80);
    btnSettingsCell.backgroundColor = [UIColor clearColor];
    [btnSettingsCell addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btnSettingsCell];

    //Fill values
    lblDeviceName.text = currentSensor.deviceName;

    //Set values according to device type
    int currentDeviceId = currentSensor.deviceID;


    //Get the value to be displayed on right rectangle
    NSString *currentValue;
    NSString *currentStateValue;

    SFIDeviceKnownValues *currentDeviceValue;
    switch (currentDeviceType) {
        case 1:
            //Switch
            //Only one value
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:0];
            currentValue = currentDeviceValue.value;

            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else if (currentValue == nil) {
                lblDeviceStatus.text = @"Could not update sensor\ndata.";
            }
            else {
                lblDeviceStatus.text = [currentDeviceValue choiceForBoolValueTrueValue:@"ON" falseValue:@"OFF" nilValue:currentValue];
            }

            break;

        case 2: {
            //Multilevel switch

//            //Get State
//            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
//            currentStateValue = currentDeviceValue.value;

            //Get Percentage
            SFIDeviceKnownValues *currentLevelKnownValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.mostImpValueIndex];
            NSString *currentLevel = currentLevelKnownValue.value;

            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            //PY 291113
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if (currentSensor.imageName == nil) {
                imgDevice.image = [UIImage imageNamed:DT2_MULTILEVEL_SWITCH_TRUE];
            }

            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else {
                lblDeviceStatus.text = [currentLevelKnownValue choiceForLevelValueZeroValue:@"OFF"
                                                                               nonZeroValue:[NSString stringWithFormat:@"Dimmable, %@%%", currentLevel]
                                                                                   nilValue:@"Could not update sensor\ndata."];
            }
            break;
        }
        case 3: {
            //Binary Sensor
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];

            lblDeviceStatus.text = [currentDeviceValue choiceForBoolValueTrueValue:@"OPEN"
                                                                        falseValue:@"CLOSED"
                                                                          nilValue:@"Could not update sensor\ndata."
                                                                       nonNilValue:currentValue];

            NSString *imageName = [currentDeviceValue choiceForBoolValueTrueValue:DT3_BINARY_SENSOR_TRUE
                                                                       falseValue:DT3_BINARY_SENSOR_FALSE
                                                                         nilValue:currentSensor.imageName];
            imgDevice.image = [UIImage imageNamed:imageName];
            break;
        }

        case 4: {
            //Get State
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];

            //Get Percentage
            SFIDeviceKnownValues *currentLevelKnownValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.mostImpValueIndex];

            NSString *image_name = (currentSensor.imageName == nil) ? DT4_LEVEL_CONTROL_TRUE : currentSensor.imageName;
            imgDevice.image = [UIImage imageNamed:image_name];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else {
                float intLevel = [currentLevelKnownValue floatValue];
                intLevel = (intLevel / 256) * 100;

                // Set soem defaults
                NSString *status_str;

                if (!currentDeviceValue.hasValue) {
                    if (currentDeviceValue == nil) {
                        status_str = @"Could not update sensor\ndata.";
                    }
                    else if (currentLevelKnownValue.hasValue) {
                        status_str = [NSString stringWithFormat:@"Dimmable, %.0f%%", intLevel];
                    }
                    else {
                        status_str = @"Dimmable";
                    }
                }
                else if (currentDeviceValue.boolValue == true) {
                    if ([currentLevelKnownValue hasValue]) {
                        status_str = [NSString stringWithFormat:@"ON, %.0f%%", intLevel];
                    }
                    else {
                        status_str = @"ON";
                    }
                }
                else {
                    if ([currentLevelKnownValue hasValue]) {
                        status_str = [NSString stringWithFormat:@"OFF, %.0f%%", intLevel];
                    }
                    else {
                        status_str = @"OFF";
                    }
                }

                lblDeviceStatus.text = status_str;
            }

            break;
        }
        case 5:
            //Door Lock
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT5_DOOR_LOCK_TRUE];
                lblDeviceStatus.text = @"LOCKED";
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT5_DOOR_LOCK_FALSE];
                lblDeviceStatus.text = @"UNLOCKED";
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }
            break;
        case 6:
            //Alarm
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - TODO: Change later
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT6_ALARM_TRUE];
                lblDeviceStatus.text = @"ON";
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT6_ALARM_FALSE];
                lblDeviceStatus.text = @"OFF";
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }
            break;
        case 7: {
            //Thermostat
            NSString *strValue = @"";

            NSString *strStatus;
            NSString *strOperatingMode;
            NSString *heatingSetpoint;
            NSString *coolingSetpoint;

            NSArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];
            for (SFIDeviceKnownValues *currentKnownValue in currentKnownValues) {
                if ([currentKnownValue.valueName isEqualToString:@"SENSOR MULTILEVEL"]) {
                    strValue = currentKnownValue.value;
                    //lblDeviceValue.text = [NSString stringWithFormat:@"%@°",currentKnownValue.value] ;
                }
                else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT SETPOINT HEATING"]) {
                    heatingSetpoint = [NSString stringWithFormat:@" HI %@°", currentKnownValue.value];
                }
                else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT SETPOINT COOLING"]) {
                    coolingSetpoint = [NSString stringWithFormat:@" LO %@°", currentKnownValue.value];
                }
                else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT OPERATING STATE"]) {
                    strOperatingMode = currentKnownValue.value;
                }
            }

            strStatus = [NSString stringWithFormat:@"%@, %@, %@", strOperatingMode, coolingSetpoint, heatingSetpoint];

            //Calculate values
            NSArray *thermostatValues = [strValue componentsSeparatedByString:@"."];

            NSString *strIntegerValue = thermostatValues[0];
            if ([thermostatValues count] == 2) {
                NSString *strDecimalValue = thermostatValues[1];
                lblDecimalValue.text = [NSString stringWithFormat:@".%@", strDecimalValue];
            }

            lblDeviceValue.text = strIntegerValue;
            if ([strIntegerValue length] == 1) {
                lblDecimalValue.frame = CGRectMake((width / 4) - 25, 40, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 25, 20, 20);
            }
            else if ([strIntegerValue length] == 3) {
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:30]];
                [lblDecimalValue setFont:heavy_font];
                [lblDegree setFont:heavy_font];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 38, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 30, 20, 20);
            }
            else if ([strIntegerValue length] == 4) {
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:22]];
                [lblDecimalValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                [lblDegree setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 35, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 30, 20, 20);
            }


            lblDeviceStatus.text = strStatus;
            break;
        }
        case 11: {
            //Motion Sensor
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.25), 12, 53, 70);
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT11_MOTION_SENSOR_TRUE];
                [strStatus appendString:@"MOTION DETECTED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT11_MOTION_SENSOR_FALSE];
                [strStatus appendString:@"NO MOTION"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }
            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 12: {
            //ContactSwitch
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;

            //PY - Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                [strStatus appendString:@"OPEN"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                [strStatus appendString:@"CLOSED"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 13: {
            //Fire Sensor
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT13_FIRE_SENSOR_TRUE];
                [strStatus appendString:@"ALARM: FIRE DETECTED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT13_FIRE_SENSOR_FALSE];
                [strStatus appendString:@"OK"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 14: {
            //Water Sensor
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT14_WATER_SENSOR_TRUE];
                [strStatus appendString:@"FLOODED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT14_WATER_SENSOR_FALSE];
                [strStatus appendString:@"OK"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }

            break;
        }
        case 15: {
            //Gas Sensor
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT15_GAS_SENSOR_TRUE];
                [strStatus appendString:@"ALARM: GAS DETECTED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT15_GAS_SENSOR_FALSE];
                [strStatus appendString:@"OK"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 17: {
            //Vibration Sensor
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT17_VIBRATION_SENSOR_TRUE];
                [strStatus appendString:@"VIBRATION DETECTED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT17_VIBRATION_SENSOR_FALSE];
                [strStatus appendString:@"NO VIBRATION"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 19: {
            //Keyfob
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT19_KEYFOB_TRUE];
                [strStatus appendString:@"LOCKED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT19_KEYFOB_FALSE];
                [strStatus appendString:@"UNLOCKED"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 22:
            //Electric Measurement Switch - AC
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 10, 53, 70);
            //PY 291113 - Show only State
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else {
                if ([currentStateValue isEqualToString:@"true"]) {
                    lblDeviceStatus.text = @"ON";
                }
                else if ([currentStateValue isEqualToString:@"false"]) {
                    lblDeviceStatus.text = @"OFF";
                }
                else {
                    if (currentStateValue == nil) {
                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
                    }
                    else {
                        lblDeviceStatus.text = currentValue;
                    }
                }
                break;
            }
            // pass through!
        case 23: {
            //Electric Measurement Switch - DC
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
            //PY 291113 - Show only State
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else {
                if ([currentStateValue isEqualToString:@"true"]) {
                    lblDeviceStatus.text = @"ON";
                }
                else if ([currentStateValue isEqualToString:@"false"]) {
                    lblDeviceStatus.text = @"OFF";
                }
                else {
                    if (currentStateValue == nil) {
                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
                    }
                    else {
                        lblDeviceStatus.text = currentValue;
                    }
                }
            }
            break;
        }
        case 27: {
            //Temperature Sensor
            NSString *strValue = @"";

            NSArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];
            for (SFIDeviceKnownValues *currentKnownValue in currentKnownValues) {
                if ([currentKnownValue.valueName isEqualToString:@"MEASURED_VALUE"]) {
                    strValue = currentKnownValue.value;
                }
                else if ([currentKnownValue.valueName isEqualToString:@"TOLERANCE"]) {
                    lblDeviceStatus.text = [NSString stringWithFormat:@"Tolerance: %@", currentKnownValue.value];
                }
            }

            //Calculate values
            NSArray *temperatureValues = [strValue componentsSeparatedByString:@"."];


            NSString *strIntegerValue = temperatureValues[0];

            if ([temperatureValues count] == 2) {
                NSString *strDecimalValue = temperatureValues[1];
                lblDecimalValue.text = [NSString stringWithFormat:@".%@", strDecimalValue];
            }

            lblDeviceValue.text = strIntegerValue;
            if ([strIntegerValue length] == 1) {
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 40, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 25, 20, 20);
            }
            else if ([strIntegerValue length] == 3) {
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:30]];
                [lblDecimalValue setFont:heavy_font];
                [lblDegree setFont:heavy_font];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 38, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 30, 20, 20);
            }
            else if ([strIntegerValue length] == 4) {
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:22]];
                [lblDecimalValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                [lblDegree setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 35, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 30, 20, 20);
            }

            break;
        }
        case 34: {
            //Keyfob
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT34_SHADE_TRUE];
                lblDeviceStatus.text = @"OPEN";
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT34_SHADE_FALSE];
                lblDeviceStatus.text = @"CLOSED";
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }
            break;
        }
        default: {
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            break;
        }
    }

    btnDevice.tag = indexPathRow;
    btnDeviceImg.tag = indexPathRow;
    btnSettings.tag = indexPathRow;
    btnSettingsCell.tag = indexPathRow;

    [self.contentView addSubview:imgSettings];
}

- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDevice:(int)id valuesIndex:(int)index {
    return nil;
}

- (UIColor *)makeStandardBlue {
    return nil;
}

- (NSArray *)currentKnownValuesForDevice:(int)id {
    return nil;
}

- (void)onSettingClicked:(id)onSettingClicked {

}

- (void)heatingSliderTapped:(id)heatingSliderTapped {

}

- (void)sliderDidEndSliding:(id)sliderDidEndSliding {

}

- (void)heatingSliderDidEndSliding:(id)heatingSliderDidEndSliding {

}

- (void)fanModeSelected:(id)fanModeSelected {

}

- (void)sliderTapped:(id)sliderTapped {

}

- (void)coolingSliderTapped:(id)coolingSliderTapped {

}

- (void)coolingSliderDidEndSliding:(id)coolingSliderDidEndSliding {

}

- (void)modeSelected:(id)modeSelected {

}

- (void)onDismissTamper:(id)onDismissTamper {

}

- (void)onSaveSensorData:(id)onSaveSensorData {

}

- (void)tfLocationFinished:(id)tfLocationFinished {

}

- (void)tfLocationDidChange:(id)tfLocationDidChange {

}

- (void)onDeviceClicked:(id)onDeviceClicked {

}

- (NSUInteger)computeSensorRowHeight:(SFIDevice *)device {
    return 0;
}

@end
    