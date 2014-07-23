//
//  SFISensorTableViewCell.h
//
//  Created by sinclair on 6/25/14.
//
#import "SFISensorTableViewCell.h"
#import "SFIConstants.h"
#import "SFIHighlightedButton.h"


@implementation SFISensorTableViewCell

- (void)initialize:(UITableView *)tableView listRow:(int)indexPathRow device:(SFIDevice *)currentSensor {
    static NSString *sensor_cell_id = @"SensorCell";

    int currentDeviceType = currentSensor.deviceType;

    NSUInteger height = [self computeSensorRowHeight:currentSensor];
    NSString *id = currentSensor.isExpanded ? [NSString stringWithFormat:@"SensorExpanded_%ld", (unsigned long) height] : sensor_cell_id;

    UITableViewCell *cell = self;
    //START: HACK FOR MEMORY LEAKS
    for (
            UIView *currentView in cell.contentView.subviews) {
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS

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


    int positionIndex = indexPathRow % 15;
    if (positionIndex < 7) {
//        self.changeBrightness = self.baseBrightness - (positionIndex * 10);
    }
    else {
//        self.changeBrightness = (self.baseBrightness - 70) + ((positionIndex - 7) * 10);
    }

    //Left Square - Creation
    leftBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, LEFT_LABEL_WIDTH, SENSOR_ROW_HEIGHT - 10)];
    leftBackgroundLabel.userInteractionEnabled = YES;
    UIColor *standard_blue = nil;//[UIColor colorWithHue:(CGFloat) (self.changeHue / 360.0) saturation:(CGFloat) (self.changeSaturation / 100.0) brightness:(CGFloat) (self.changeBrightness / 100.0) alpha:1];
    leftBackgroundLabel.backgroundColor = standard_blue;
    [cell addSubview:leftBackgroundLabel];

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

        [cell addSubview:lblDeviceValue];
        [cell addSubview:lblDecimalValue];
        [cell addSubview:lblDegree];
    }
    else {
        imgDevice = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 3, 12, 53, 70)];
        imgDevice.userInteractionEnabled = YES;
        [imgDevice addSubview:btnDeviceImg];
        btnDeviceImg.frame = imgDevice.bounds;
        [cell addSubview:imgDevice];
    }

    btnDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDevice.frame = leftBackgroundLabel.bounds;
    btnDevice.backgroundColor = [UIColor clearColor];
    [btnDevice addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftBackgroundLabel addSubview:btnDevice];

    //Right Rectangle - Creation
    rightBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH + 11, 5, tableView.frame.size.width - LEFT_LABEL_WIDTH - 25, SENSOR_ROW_HEIGHT - 10)];
    rightBackgroundLabel.backgroundColor = standard_blue;
    [cell addSubview:rightBackgroundLabel];

    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, (tableView.frame.size.width - LEFT_LABEL_WIDTH - 90), 30)];
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

    imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 60, 37, 23, 23)];
    imgSettings.image = [UIImage imageNamed:@"icon_config.png"];
    imgSettings.alpha = 0.5;
    imgSettings.userInteractionEnabled = YES;

    btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.frame = imgSettings.bounds;
    btnSettings.backgroundColor = [UIColor clearColor];
    [btnSettings addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgSettings addSubview:btnSettings];

    btnSettingsCell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettingsCell.frame = CGRectMake(tableView.frame.size.width - 80, 5, 60, 80);
    btnSettingsCell.backgroundColor = [UIColor clearColor];
    [btnSettingsCell addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnSettingsCell];

    //Fill values
    lblDeviceName.text = currentSensor.deviceName;

    //Set values according to device type
    int currentDeviceId = currentSensor.deviceID;
    int deviceValueID;
    NSMutableArray *currentKnownValues = nil;

    //Pass current device info in map
//    for (SFIDeviceValue *deviceValue in self.deviceValueList) {
//        deviceValueID = deviceValue.deviceID;
//        if (currentDeviceId == deviceValueID) {
//            currentKnownValues = deviceValue.knownValues;
//        }
//    }

    //Get the value to be displayed on right rectangle
    NSString *currentValue;
    NSString *currentStateValue;

    SFIDeviceKnownValues *currentDeviceValue;
    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];
    switch (currentDeviceType) {
        case 1:
            //Switch
            //Only one value
            currentDeviceValue = currentKnownValues[0];
            currentValue = currentDeviceValue.value;

            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else {
                if ([currentValue isEqualToString:@"true"]) {
                    lblDeviceStatus.text = @"ON";
                }
                else if ([currentValue isEqualToString:@"false"]) {
                    lblDeviceStatus.text = @"OFF";
                }
                else {
                    if (currentValue == nil) {
                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
                    }
                    else {
                        lblDeviceStatus.text = currentValue;
                    }
                }
            }
            break;

        case 2: {
            //Multilevel switch

//            //Get State
//            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
//            currentStateValue = currentDeviceValue.value;

            //Get Percentage
            SFIDeviceKnownValues *currentLevelKnownValue = currentKnownValues[(NSUInteger) currentSensor.mostImpValueIndex];
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
                if (![currentLevel isEqualToString:@""]) {
                    if ([currentLevel isEqualToString:@"0"]) {
                        lblDeviceStatus.text = @"OFF";
                    }
                    else {
                        lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %@%%", currentLevel];
                    }
                }
                else {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
            }




//                if([currentStateValue isEqualToString:@"true"]){
//                    if(![currentLevel isEqualToString:@""]){
//                        lblDeviceStatus.text =  [NSString stringWithFormat:@"ON, %@%%", currentLevel];
//                    }else{
//                        lblDeviceStatus.text =  @"ON";
//                    }
//                }else if([currentStateValue isEqualToString:@"false"]){
//                    if(![currentLevel isEqualToString:@""]){
//                        lblDeviceStatus.text = [NSString stringWithFormat:@"OFF, %@%%", currentLevel];
//                    }else{
//                        lblDeviceStatus.text =  @"OFF";
//                    }
//                }else{
//                    if(currentStateValue==nil){
//                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
//                        if(currentDeviceValue == nil){
//                            if(![currentLevel isEqualToString:@""]){
//                                lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %@%%", currentLevel];
//                            }else{
//                                lblDeviceStatus.text =  @"Dimmable";
//                            }
//                        }
//                    }else{
//                        if(![currentLevel isEqualToString:@""]){
//                            lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %@%%", currentLevel];
//                        }else{
//                            lblDeviceStatus.text =  @"Dimmable";
//                        }
//                    }
//                }
//            }

            break;
        }
        case 3:
            //Binary Sensor
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY 291113 - Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT3_BINARY_SENSOR_TRUE];
                lblDeviceStatus.text = @"OPEN";
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT3_BINARY_SENSOR_FALSE];
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


            //            if([currentSensor.mostImpValueName isEqualToString:TAMPER]){
            //                // imgDevice.frame = CGRectMake(25, 15, 53,60);
            //                lblDeviceStatus.text = @"TAMPERED";
            //                if([currentStateValue isEqualToString:@"false"]){
            //                    imgDevice.image = [UIImage imageNamed:@"door_off_tamper.png"];
            //                }else if([currentStateValue isEqualToString:@"true"]){
            //                    imgDevice.image = [UIImage imageNamed:@"door_on_tamper.png"];
            //                }
            //            }else if([currentSensor.mostImpValueName isEqualToString:@"LOW BATTERY"]){
            //                //imgDevice.frame = CGRectMake(25, 15, 53,60);
            //                lblDeviceStatus.text = @"LOW BATTERY";
            //                if([currentStateValue isEqualToString:@"false"]){
            //                    imgDevice.image = [UIImage imageNamed:@"door_off_battery.png"];
            //                }
            //            }else{
            //                //Check OPEN CLOSE State
            //                currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
            //                currentValue = currentDeviceValue.value;
            //                if([currentValue isEqualToString:@"true"]){
            //                    // imgDevice.frame = CGRectMake(30, 20, 40.5,60);
            //                    lblDeviceStatus.text = @"OPEN";
            //                }else if([currentValue isEqualToString:@"false"]){
            //                    //imgDevice.frame = CGRectMake(30, 15, 40.5,60);
            //                    lblDeviceStatus.text = @"CLOSED";
            //                }else{
            //                    if(currentValue==nil){
            //                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
            //                    }else{
            //                        lblDeviceStatus.text = currentValue;
            //                    }
            //                }
            //            }



            //            currentDeviceValue = [currentKnownValues objectAtIndex:0];
            //            currentValue = currentDeviceValue.value;
            //            if([currentValue isEqualToString:@"true"]){
            //                imgDevice.frame = CGRectMake(30, 20, 40.5,60);
            //                lblDeviceStatus.text = @"OPEN";
            //            }else{
            //                imgDevice.frame = CGRectMake(30, 15, 40.5,60);
            //                lblDeviceStatus.text = @"CLOSED";
            //            }
            //            imgDevice.image = [UIImage imageNamed:@"door_on.png"];
            break;

        case 4:
//            //Level Control
//            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
//            currentStateValue = currentDeviceValue.value;
//            //PY - Show only State
//            if([currentStateValue isEqualToString:@"true"]){
//                imgDevice.image = [UIImage imageNamed:DT4_LEVEL_CONTROL_TRUE];
//                lblDeviceStatus.text = @"ON";
//            }else if([currentStateValue isEqualToString:@"false"]){
//                imgDevice.image = [UIImage imageNamed:DT4_LEVEL_CONTROL_FALSE];
//                lblDeviceStatus.text = @"OFF";
//            }else{
//                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
//                if(currentStateValue==nil){
//                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
//                }else{
//                    lblDeviceStatus.text = currentValue;
//                }
//            }
        {

            //Get State
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;

            //Get Percentage
            SFIDeviceKnownValues *currentLevelKnownValue = currentKnownValues[(NSUInteger) currentSensor.mostImpValueIndex];
            NSString *currentLevel = currentLevelKnownValue.value;

            float intLevel = [currentLevel floatValue];
            intLevel = intLevel / 256 * 100;

            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            //PY 291113 - Show only State
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if (currentSensor.imageName == nil) {
                imgDevice.image = [UIImage imageNamed:DT4_LEVEL_CONTROL_TRUE];
            }
            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else {
                if ([currentStateValue isEqualToString:@"true"]) {
                    if (![currentLevel isEqualToString:@""]) {
                        lblDeviceStatus.text = [NSString stringWithFormat:@"ON, %.0f%%", intLevel];
                    }
                    else {
                        lblDeviceStatus.text = @"ON";
                    }
                }
                else if ([currentStateValue isEqualToString:@"false"]) {
                    if (![currentLevel isEqualToString:@""]) {
                        lblDeviceStatus.text = [NSString stringWithFormat:@"OFF, %.0f%%", intLevel];
                    }
                    else {
                        lblDeviceStatus.text = @"OFF";
                    }
                }
                else {
                    if (currentStateValue == nil) {
                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
                        if (currentDeviceValue == nil) {
                            if (![currentLevel isEqualToString:@""]) {
                                lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %.0f%%", intLevel];
                            }
                            else {
                                lblDeviceStatus.text = @"Dimmable";
                            }
                        }
                    }
                    else {
                        if (![currentLevel isEqualToString:@""]) {
                            lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %.0f%%", intLevel];
                        }
                        else {
                            lblDeviceStatus.text = @"Dimmable";
                        }
                    }
                }

                //TODO: Remove later - For testing
//                lblDeviceStatus.numberOfLines = 2;
//                lblDeviceStatus.text =  [NSString stringWithFormat:@"ON, %.0f%%\nLOW BATTERY", intLevel];

            }

            break;
        }
        case 5:
            //Door Lock
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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

            for (
                    SFIDeviceKnownValues *currentKnownValue in currentKnownValues) {
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
            NSString *strDecimalValue = @"";
            if ([thermostatValues count] == 2) {
                strDecimalValue = thermostatValues[1];
                lblDecimalValue.text = [NSString stringWithFormat:@".%@", strDecimalValue];
            }

            lblDeviceValue.text = strIntegerValue;
            if ([strIntegerValue length] == 1) {
                lblDecimalValue.frame = CGRectMake((tableView.frame.size.width / 4) - 25, 40, 20, 30);
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
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
//                imgDevice.image = [UIImage imageNamed:DT12_CONTACT_SWITCH_TRUE];
                [strStatus appendString:@"OPEN"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
//                imgDevice.image = [UIImage imageNamed:DT12_CONTACT_SWITCH_FALSE];
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
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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
        case 14:
            //Water Sensor
        {
//            NSString *text = @"89";
//            UIGraphicsBeginImageContext(CGSizeMake(53, 70));
//            [text drawAtPoint:CGPointMake(0, 0)
//                     withFont:[UIFont fontWithName:@"Avenir-Heavy" size:36]];
//            UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            imgDevice.image = result;

            NSMutableString *strStatus = [[NSMutableString alloc] init];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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
            }
            break;
        case 23:
            //Electric Measurement Switch - DC
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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
        case 27:
            //Temperature Sensor
        {
            NSString *strValue = @"";

            for (
                    SFIDeviceKnownValues *currentKnownValue in currentKnownValues) {
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
            NSString *strDecimalValue = @"";
            if ([temperatureValues count] == 2) {
                strDecimalValue = temperatureValues[1];
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
        case 34:
            //Keyfob
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
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
        default:
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            break;
    }


    btnDevice.tag = indexPathRow;
    btnDeviceImg.tag = indexPathRow;
    btnSettings.tag = indexPathRow;
    btnSettingsCell.tag = indexPathRow;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //Expanded View
    if (currentSensor.isExpanded) {
        //Settings icon - white
        imgSettings.alpha = 1.0;

        //Show values also
        UILabel *belowBackgroundLabel = [[UILabel alloc] init];
        belowBackgroundLabel.userInteractionEnabled = YES;
        belowBackgroundLabel.backgroundColor = standard_blue;


        UILabel *expandedLblText;
        float baseYCordinate = -20;
        //expandedLblText.backgroundColor = [UIColor greenColor];
        switch (currentDeviceType) {
            case 1:
                baseYCordinate = baseYCordinate + 25;
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //               currentDeviceValue = [currentKnownValues objectAtIndex:0];
//                //                expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
//                //Display Location - PY 291113
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            case 2: {
                baseYCordinate += 35;
                UIImageView *minImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 24, 24)];
                [minImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
                [belowBackgroundLabel addSubview:minImage];

                //Display slider
                UISlider *slider = [[UISlider alloc] init];
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate, tableView.frame.size.width - 110, 10.0);
                }
                else {
                    // code for 3.5-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate - 10, (tableView.frame.size.width - 110), 10.0);
                }

//                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40.0, baseYCordinate-10, (tableView.frame.size.width - 110), 10.0)];
                slider.tag = indexPathRow;
                slider.minimumValue = 0;
                slider.maximumValue = 99;
                [slider addTarget:self action:@selector(sliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
                [slider addGestureRecognizer:tapSlider];


                //Set slider value
                float currentSliderValue = 0.0;

                for (
                        int i = 0; i < [currentKnownValues count]; i++) {
                    currentDeviceValue = currentKnownValues[(NSUInteger) i];
                    //Get slider value
                    if ([currentDeviceValue.valueName isEqualToString:@"SWITCH MULTILEVEL"]) {
                        currentSliderValue = [currentDeviceValue.value floatValue];
                        break;
                    }
                }

                [slider setValue:currentSliderValue animated:YES];

                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateNormal];
                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateHighlighted];
                [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"]
                                    forState:UIControlStateNormal];
                [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"]
                                    forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:slider];

                UIImageView *maxImage = [[UIImageView alloc] initWithFrame:CGRectMake((tableView.frame.size.width - 110) + 50, baseYCordinate - 5, 24, 24)];
                [maxImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
                [belowBackgroundLabel addSubview:maxImage];

                baseYCordinate += 25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];

                baseYCordinate = baseYCordinate + 5;

//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //Display Location
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 3: {
                //Do not display the most important one
                for (
                        int i = 0; i < [currentKnownValues count]; i++) {
                    // if(i!= currentSensor.mostImpValueIndex ){

                    currentDeviceValue = currentKnownValues[(NSUInteger) i];
                    //Display only battery - PY 291113
                    NSString *batteryStatus;
                    if ([currentDeviceValue.valueName isEqualToString:@"BATTERY"]) {
                        expandedLblText = [[UILabel alloc] init];
                        [expandedLblText setBackgroundColor:[UIColor clearColor]];
                        //Check the status of value
                        if ([currentValue isEqualToString:@"1"]) {
                            //Battery Low
                            batteryStatus = @"Low Battery";
                        }
                        else {
                            //Battery OK
                            batteryStatus = @"Battery OK";
                        }
                        expandedLblText.text = batteryStatus;
                        expandedLblText.textColor = [UIColor whiteColor];
                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                        baseYCordinate = baseYCordinate + 25;
                        //// NSLog(@"Y Cordinate %f", baseYCordinate);
                        expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                        [belowBackgroundLabel addSubview:expandedLblText];
                    }
                    //                    expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];

                    // }
                }

                baseYCordinate += 25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];

                baseYCordinate = baseYCordinate + 5;

//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                //Display Location - PY 291113
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 4: {
                //Level Control
                baseYCordinate += 35;
                UIImageView *minImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 24, 24)];
                [minImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
                [belowBackgroundLabel addSubview:minImage];

                //Display slider
                UISlider *slider = [[UISlider alloc] init];
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate, tableView.frame.size.width - 110, 10.0);
                }
                else {
                    // code for 3.5-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate - 10, (tableView.frame.size.width - 110), 10.0);
                }

//                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40.0, baseYCordinate-10, tableView.frame.size.width - 110, 10.0)];
                slider.tag = indexPathRow;
                slider.minimumValue = 0;
                slider.maximumValue = 255;
                [slider addTarget:self action:@selector(sliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
                [slider addGestureRecognizer:tapSlider];


                //Set slider value
                float currentSliderValue = 0.0;

                for (
                        int i = 0; i < [currentKnownValues count]; i++) {
                    currentDeviceValue = currentKnownValues[(NSUInteger) i];
                    //Get slider value
                    if ([currentDeviceValue.valueName isEqualToString:@"SWITCH MULTILEVEL"]) {
                        currentSliderValue = [currentDeviceValue.value floatValue];
                        break;
                    }
                }

                [slider setValue:currentSliderValue animated:YES];

                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateNormal];
                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateHighlighted];
                [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"]
                                    forState:UIControlStateNormal];
                [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"]
                                    forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:slider];

                UIImageView *maxImage = [[UIImageView alloc] initWithFrame:CGRectMake((tableView.frame.size.width - 110) + 50, baseYCordinate - 5, 24, 24)];
                [maxImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
                [belowBackgroundLabel addSubview:maxImage];

                baseYCordinate += 25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];

                baseYCordinate = baseYCordinate + 5;
                break;
            }
            case 5: {
                //Door Lock
                baseYCordinate = baseYCordinate + 25;
                break;
            }
            case 6: {
                //Alarm
                baseYCordinate = baseYCordinate + 25;
                break;
            }
            case 7: {
                //Thermostat
                baseYCordinate += 40;

                //Heating Setpoint
                UILabel *lblHeating = [[UILabel alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 60, 30)];
                lblHeating.textColor = [UIColor whiteColor];
                [lblHeating setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblHeating.text = @"Heating";
                [belowBackgroundLabel addSubview:lblHeating];

//                UIImageView *minHeatImage = [[UIImageView alloc]initWithFrame:CGRectMake(80.0, baseYCordinate-3, 24,24)];
//                [minHeatImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
//                [belowBackgroundLabel addSubview:minHeatImage];
                UILabel *lblMinHeat = [[UILabel alloc] initWithFrame:CGRectMake(70.0, baseYCordinate - 3, 30, 24)];
                [lblMinHeat setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMinHeat.text = @"35°";
                lblMinHeat.textColor = [UIColor whiteColor];
                lblMinHeat.textAlignment = NSTextAlignmentCenter;
                lblMinHeat.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMinHeat];

                //Display heating slider
                UISlider *heatSlider = [[UISlider alloc] init];
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    heatSlider.frame = CGRectMake(100.0, baseYCordinate, tableView.frame.size.width - 160, 10.0);
                }
                else {
                    // code for 3.5-inch screen
                    heatSlider.frame = CGRectMake(100.0, baseYCordinate - 10, tableView.frame.size.width - 160, 10.0);
                }
//                UISlider *heatSlider = [[UISlider alloc] initWithFrame:CGRectMake(100.0, baseYCordinate-10, tableView.frame.size.width - 160, 10.0)];
                heatSlider.tag = indexPathRow;
                heatSlider.minimumValue = 35;
                heatSlider.maximumValue = 95;
                [heatSlider addTarget:self action:@selector(heatingSliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(heatingSliderTapped:)];
                [heatSlider addGestureRecognizer:tapSlider];

                [heatSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateNormal];
                [heatSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateHighlighted];
                [heatSlider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"] forState:UIControlStateNormal];
                [heatSlider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"] forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:heatSlider];

                UILabel *lblMaxHeat = [[UILabel alloc] initWithFrame:CGRectMake(100 + (tableView.frame.size.width - 160), baseYCordinate - 3, 30, 24)];
                [lblMaxHeat setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMaxHeat.text = @"95°";
                lblMaxHeat.textColor = [UIColor whiteColor];
                lblMaxHeat.textAlignment = NSTextAlignmentCenter;
                lblMaxHeat.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMaxHeat];

//                UIImageView *maxHeatImage = [[UIImageView alloc]initWithFrame:CGRectMake(100 + (tableView.frame.size.width - 160), baseYCordinate-3, 24,24)];
//                [maxHeatImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
//                [belowBackgroundLabel addSubview:maxHeatImage];

                baseYCordinate += 40;
                //PY 170114
//                UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width-35, 1)];
//                imgLine1.image = [UIImage imageNamed:@"line.png"];
//                imgLine1.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine1];
//                
//                baseYCordinate = baseYCordinate+10;

                //Cooling Setpoint
                UILabel *lblCooling = [[UILabel alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 60, 30)];
                lblCooling.textColor = [UIColor whiteColor];
                [lblCooling setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblCooling.text = @"Cooling";
                [belowBackgroundLabel addSubview:lblCooling];

//                UIImageView *minCoolingImage = [[UIImageView alloc]initWithFrame:CGRectMake(80.0, baseYCordinate-3, 24,24)];
//                [minCoolingImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
//                [belowBackgroundLabel addSubview:minCoolingImage];

                UILabel *lblMinCool = [[UILabel alloc] initWithFrame:CGRectMake(70.0, baseYCordinate - 3, 30, 24)];
                [lblMinCool setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMinCool.text = @"35°";
                lblMinCool.textColor = [UIColor whiteColor];
                lblMinCool.textAlignment = NSTextAlignmentCenter;
                lblMinCool.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMinCool];

                //Display Cooling slider
                UISlider *coolSlider = [[UISlider alloc] init];
                //CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    coolSlider.frame = CGRectMake(100.0, baseYCordinate, tableView.frame.size.width - 160, 10.0);
                }
                else {
                    // code for 3.5-inch screen
                    coolSlider.frame = CGRectMake(100.0, baseYCordinate - 10, tableView.frame.size.width - 160, 10.0);
                }
//                UISlider *coolSlider = [[UISlider alloc] initWithFrame:CGRectMake(100.0, baseYCordinate-10, tableView.frame.size.width - 160, 10.0)];
                coolSlider.tag = indexPathRow;
                coolSlider.minimumValue = 35;
                coolSlider.maximumValue = 95;
                [coolSlider addTarget:self action:@selector(coolingSliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                UITapGestureRecognizer *coolTapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coolingSliderTapped:)];
                [coolSlider addGestureRecognizer:coolTapSlider];

                [coolSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateNormal];
                [coolSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateHighlighted];
                [coolSlider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"] forState:UIControlStateNormal];
                [coolSlider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"] forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:coolSlider];

//                UIImageView *maxCoolImage = [[UIImageView alloc]initWithFrame:CGRectMake(tableView.frame.size.width - 160 + 100, baseYCordinate-3, 24,24)];
//                [maxCoolImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
//                [belowBackgroundLabel addSubview:maxCoolImage];

                UILabel *lblMaxCool = [[UILabel alloc] initWithFrame:CGRectMake(100 + (tableView.frame.size.width - 160), baseYCordinate - 3, 30, 24)];
                [lblMaxCool setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMaxCool.text = @"95°";
                lblMaxCool.textColor = [UIColor whiteColor];
                lblMaxCool.textAlignment = NSTextAlignmentCenter;
                lblMaxCool.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMaxCool];

                baseYCordinate += 30;
                UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                imgLine2.image = [UIImage imageNamed:@"line.png"];
                imgLine2.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine2];

                baseYCordinate = baseYCordinate + 10;

                //Mode
                UILabel *lblMode = [[UILabel alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 100, 30)];
                lblMode.textColor = [UIColor whiteColor];
                [lblMode setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMode.text = @"Thermostat";
                [belowBackgroundLabel addSubview:lblMode];

                //Font for segment control
                UIFont *font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
                NSDictionary *attributes = @{NSFontAttributeName : font};

                UISegmentedControl *scMode = [[UISegmentedControl alloc] initWithItems:@[@"Auto", @"Heat", @"Cool", @"Off"]];
                scMode.frame = CGRectMake(tableView.frame.size.width - 220, baseYCordinate, 180, 20);
                scMode.tag = indexPathRow;
                scMode.tintColor = [UIColor whiteColor];
                [scMode addTarget:self action:@selector(modeSelected:) forControlEvents:UIControlEventValueChanged];
                [scMode setTitleTextAttributes:attributes forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:scMode];

                baseYCordinate += 30;
                UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                imgLine3.image = [UIImage imageNamed:@"line.png"];
                imgLine3.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine3];

                baseYCordinate = baseYCordinate + 10;

                //Fan Mode
                UILabel *lblFanMode = [[UILabel alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 60, 30)];
                lblFanMode.textColor = [UIColor whiteColor];
                [lblFanMode setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblFanMode.text = @"Fan";
                [belowBackgroundLabel addSubview:lblFanMode];

                UISegmentedControl *scFanMode = [[UISegmentedControl alloc] initWithItems:@[@"Auto Low", @"On Low"]];
                scFanMode.frame = CGRectMake(tableView.frame.size.width - 190, baseYCordinate, 150, 20);
                scFanMode.tag = indexPathRow;

                [scFanMode setTitleTextAttributes:attributes forState:UIControlStateNormal];
                [scFanMode addTarget:self action:@selector(fanModeSelected:) forControlEvents:UIControlEventValueChanged];
                scFanMode.tintColor = [UIColor whiteColor];
                [belowBackgroundLabel addSubview:scFanMode];

                baseYCordinate += 30;
                UIImageView *imgLine4 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                imgLine4.image = [UIImage imageNamed:@"line.png"];
                imgLine4.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine4];

                baseYCordinate = baseYCordinate + 5;


                //Status
                UILabel *lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10.0, baseYCordinate, 60, 30)];
                lblStatus.textColor = [UIColor whiteColor];
                [lblStatus setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblStatus.text = @"Status";

                [belowBackgroundLabel addSubview:lblStatus];

                //baseYCordinate+=25;

                //Operating state
                UILabel *lblOperatingState = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 250, baseYCordinate, 220, 30)];
                lblOperatingState.textColor = [UIColor whiteColor];
                lblOperatingState.backgroundColor = [UIColor clearColor];
                [lblOperatingState setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblOperatingState.textAlignment = NSTextAlignmentRight;
                [belowBackgroundLabel addSubview:lblOperatingState];

                baseYCordinate += 25;
//                UIImageView *imgLine5 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width-35, 1)];
//                imgLine5.image = [UIImage imageNamed:@"line.png"];
//                imgLine5.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine5];
//                
//                baseYCordinate = baseYCordinate+10;

//                //Fan State
//                UILabel *lblFanState = [[UILabel alloc]initWithFrame:CGRectMake(10.0, baseYCordinate-5, 200, 30)];
//                lblFanState.textColor = [UIColor whiteColor];
//                [lblFanState setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:lblFanState];
//                
//                baseYCordinate+=25;
//                UIImageView *imgLine6 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width-35, 1)];
//                imgLine6.image = [UIImage imageNamed:@"line.png"];
//                imgLine6.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine6];
//                
//                baseYCordinate = baseYCordinate+10;

                //Battery
                UILabel *lblBattery = [[UILabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 250, baseYCordinate - 5, 220, 30)];
                lblBattery.textColor = [UIColor whiteColor];
                [lblBattery setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                [lblBattery setBackgroundColor:[UIColor clearColor]];
                lblBattery.textAlignment = NSTextAlignmentRight;
                [belowBackgroundLabel addSubview:lblBattery];

                baseYCordinate += 25;
                UIImageView *imgLine7 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                imgLine7.image = [UIImage imageNamed:@"line.png"];
                imgLine7.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine7];

                baseYCordinate = baseYCordinate + 5;

                //Set slider value
                float currentHeatingSliderValue = 0.0;
                float currentCoolingSliderValue = 0.0;

                NSMutableString *strState = [[NSMutableString alloc] init];

                for (
                        NSUInteger i = 0; i < [currentKnownValues count]; i++) {
                    currentDeviceValue = currentKnownValues[i];
                    //Get slider value
                    if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT SETPOINT HEATING"]) {
                        currentHeatingSliderValue = [currentDeviceValue.value floatValue];
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT SETPOINT COOLING"]) {
                        currentCoolingSliderValue = [currentDeviceValue.value floatValue];
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT MODE"]) {
                        if ([currentDeviceValue.value isEqualToString:@"Auto"]) {
                            scMode.selectedSegmentIndex = 0;
                        }
                        else if ([currentDeviceValue.value isEqualToString:@"Heat"]) {
                            scMode.selectedSegmentIndex = 1;
                        }
                        else if ([currentDeviceValue.value isEqualToString:@"Cool"]) {
                            scMode.selectedSegmentIndex = 2;
                        }
                        else if ([currentDeviceValue.value isEqualToString:@"Off"]) {
                            scMode.selectedSegmentIndex = 3;
                        }
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT OPERATING STATE"]) {
//                        lblOperatingState.text = [NSString stringWithFormat:@"Operating State is %@", currentDeviceValue.value];
                        [strState appendString:[NSString stringWithFormat:@"Thermostat is %@. ", currentDeviceValue.value]];
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT FAN MODE"]) {
                        if ([currentDeviceValue.value isEqualToString:@"Auto Low"]) {
                            scFanMode.selectedSegmentIndex = 0;
                        }
                        else {
                            scFanMode.selectedSegmentIndex = 1;
                        }
//                        lblFanMode.text = [NSString stringWithFormat:@"Fan Mode %@", currentDeviceValue.value];
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT FAN STATE"]) {
//                        lblFanState.text = [NSString stringWithFormat:@"Fan State is %@", currentDeviceValue.value];
                        [strState appendString:[NSString stringWithFormat:@"Fan is %@.", currentDeviceValue.value]];
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"BATTERY"]) {
                        lblBattery.text = [NSString stringWithFormat:@"Battery is at %@%%.", currentDeviceValue.value];
                    }

                }

                lblOperatingState.text = strState;

                [heatSlider setValue:currentHeatingSliderValue animated:YES];
                [coolSlider setValue:currentCoolingSliderValue animated:YES];

                break;
            }
            case 11: {
                //Motion Sensor
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(onDismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;

//                    if (currentSensor.isBatteryLow){
//                        //baseYCordinate = baseYCordinate+25;
//                        self.expandedRowHeight = self.expandedRowHeight + 20;
//                        expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate-5, 200, 30)];
//                        expandedLblText.text = BATTERY_IS_LOW;
//                        expandedLblText.textColor = [UIColor whiteColor];
//                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                        [belowBackgroundLabel addSubview:expandedLblText];
//                        
//                        baseYCordinate+=25;
//                        UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width-35, 1)];
//                        imgLine.image = [UIImage imageNamed:@"line.png"];
//                        imgLine.alpha = 0.5;
//                        [belowBackgroundLabel addSubview:imgLine];
//                        
//                        baseYCordinate = baseYCordinate+5;
//                    }
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
//                    if (currentSensor.isBatteryLow){
//                        //baseYCordinate = baseYCordinate+25;
//                       self.expandedRowHeight =self.expandedRowHeight + 40;
//                        expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate-5, 200, 30)];
//                        expandedLblText.text = BATTERY_IS_LOW;
//                        expandedLblText.textColor = [UIColor whiteColor];
//                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                        [belowBackgroundLabel addSubview:expandedLblText];
//                        
//                        baseYCordinate+=25;
//                        UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width-35, 1)];
//                        imgLine.image = [UIImage imageNamed:@"line.png"];
//                        imgLine.alpha = 0.5;
//                        [belowBackgroundLabel addSubview:imgLine];
//                        
//                        baseYCordinate = baseYCordinate+5;
//                    }
                }
                break;
            }
            case 12: {
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(onDismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                //Do not display the most important one
//                for(int i =0; i < [currentKnownValues count]; i++){
//                    // if(i!= currentSensor.mostImpValueIndex ){
//                    
//                    currentDeviceValue = [currentKnownValues objectAtIndex:i];
//                    //Display only battery - PY 291113
//                    NSString *batteryStatus;
//                    if([currentDeviceValue.valueName isEqualToString:@"LOW BATTERY"]){
//                        expandedLblText = [[UILabel alloc]init];
//                        [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                        //Check the status of value
//                        if([currentValue isEqualToString:@"1"]){
//                            //Battery Low
//                            batteryStatus = @"Low Battery";
//                        }else{
//                            //Battery OK
//                            batteryStatus = @"Battery OK";
//                        }
//                        expandedLblText.text = batteryStatus;
//                        expandedLblText.textColor = [UIColor whiteColor];
//                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                        
//                        //// NSLog(@"Y Cordinate %f", baseYCordinate);
//                        expandedLblText.frame = CGRectMake(10,baseYCordinate-5,299,30);
//                        [belowBackgroundLabel addSubview:expandedLblText];
//                    }
//                    
//                    
//                    //                    expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
//                    
//                    // }
//                }

//                baseYCordinate+=25;
//                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width-35, 1)];
//                imgLine.image = [UIImage imageNamed:@"line.png"];
//                imgLine.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine];
//                
//                baseYCordinate = baseYCordinate+5;

//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                //Display Location - PY 291113
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 13: {
                //Fire Sensor
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(onDismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                break;
            }
            case 14: {
                //Water Sensor
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(onDismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
//                    [[btnDismiss layer] setBorderWidth:1.0f];
//                    [[btnDismiss layer] setBorderColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:0.6].CGColor];

                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                break;
            }
            case 15: {
                //Gas Sensor
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(onDismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                break;
            }
            case 17: {
                //Vibration Sensor
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(onDismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                break;
            }
            case 19: {
                //KeyFob
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self
                                   action:@selector(onDismissTamper:)
                         forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                break;
            }
            case 22: {
                //Show values and calculations
                //Calculate values
                unsigned int activePower = 0;
                unsigned int acPowerMultiplier = 0;
                unsigned int acPowerDivisor = 0;
                unsigned int rmsVoltage = 0;
                unsigned int acVoltageMultipier = 0;
                unsigned int acVoltageDivisor = 0;
                unsigned int rmsCurrent = 0;
                unsigned int acCurrentMultipier = 0;
                unsigned int acCurrentDivisor = 0;
                NSString *currentDeviceTypeName;
                NSString *hexString;
                if (currentKnownValues != nil) {
                    for (
                            NSUInteger i = 0; i < [currentKnownValues count]; i++) {
                        SFIDeviceKnownValues *curDeviceValues = currentKnownValues[i];
                        currentDeviceTypeName = curDeviceValues.valueName;
                        hexString = curDeviceValues.value;
                        //                          NSString *hexIP = [NSString stringWithFormat:@"%lX", (long)[currentDevice.deviceIP integerValue]];
                        //							hexString = hexString.substring(2);
                        // NSLog(@"HEX STRING: %@", hexString);
                        NSScanner *scanner = [NSScanner scannerWithString:hexString];

                        if ([currentDeviceTypeName isEqualToString:@"ACTIVE_POWER"]) {
                            [scanner scanHexInt:&activePower];
                            //activePower = Integer.parseInt(hexString, 16);
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"AC_POWERMULTIPLIER"]) {
                            [scanner scanHexInt:&acPowerMultiplier];
                            //acPowerMultiplier = Integer.parseInt(hexString, 16);
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"AC_POWERDIVISOR"]) {
                            [scanner scanHexInt:&acPowerDivisor];
                            //acPowerDivisor = Integer.parseInt(hexString, 16);
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"RMS_VOLTAGE"]) {
                            [scanner scanHexInt:&rmsVoltage];
                            //rmsVoltage = Integer.parseInt(hexString, 16);
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"AC_VOLTAGEMULTIPLIER"]) {
                            [scanner scanHexInt:&acVoltageMultipier];
                            //acVoltageMultipier = Integer.parseInt(hexString, 16);
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"AC_VOLTAGEDIVISOR"]) {
                            [scanner scanHexInt:&acVoltageDivisor];
                            //acVoltageDivisor = Integer.parseInt(hexString, 16);
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"RMS_CURRENT"]) {
                            [scanner scanHexInt:&rmsCurrent];
                            //rmsCurrent = Integer.parseInt(hexString, 16);
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"AC_CURRENTMULTIPLIER"]) {
                            [scanner scanHexInt:&acCurrentMultipier];
                            //acCurrentMultipier = Integer.parseInt(hexString, 16);
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"AC_CURRENTDIVISOR"]) {
                            [scanner scanHexInt:&acCurrentDivisor];
                            //acCurrentDivisor = Integer.parseInt(hexString, 16);
                        }
                    }
                }

                float power = (float) activePower * acPowerMultiplier / acPowerDivisor;
                float voltage = (float) rmsVoltage * acVoltageMultipier / acVoltageDivisor;
                float current = (float) rmsCurrent * acCurrentMultipier / acCurrentDivisor;

                // NSLog(@"Power %f Voltage %f Current %f", power, voltage, current);

                expandedLblText = [[UILabel alloc] init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];

                //Display Power
                expandedLblText.text = [NSString stringWithFormat:@"Power is %.3fW", power];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate + 25;
                expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                [belowBackgroundLabel addSubview:expandedLblText];

                expandedLblText = [[UILabel alloc] init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];

                //Display Voltage
                expandedLblText.text = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate + 25;
                expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                [belowBackgroundLabel addSubview:expandedLblText];


                expandedLblText = [[UILabel alloc] init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];



                //Display Current
                expandedLblText.text = [NSString stringWithFormat:@"Current is %.3fA", current];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate + 25;
                expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                [belowBackgroundLabel addSubview:expandedLblText];

                baseYCordinate += 25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];

                baseYCordinate = baseYCordinate + 5;

//                expandedLblText =[[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //Display Location
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 23: {
                //Electric Measure - DC
                //Show values and calculations
                //Calculate values
                unsigned int dcPower = 0;
                unsigned int dcPowerMultiplier = 0;
                unsigned int dcPowerDivisor = 0;
                unsigned int dcVoltage = 0;
                unsigned int dcVoltageMultipier = 0;
                unsigned int dcVoltageDivisor = 0;
                unsigned int dcCurrent = 0;
                unsigned int dcCurrentMultipier = 0;
                unsigned int dcCurrentDivisor = 0;
                NSString *currentDeviceTypeName;
                NSString *hexString;
                if (currentKnownValues != nil) {
                    for (
                            NSUInteger i = 0; i < [currentKnownValues count]; i++) {
                        SFIDeviceKnownValues *curDeviceValues = [currentKnownValues objectAtIndex:i];
                        currentDeviceTypeName = curDeviceValues.valueName;
                        hexString = curDeviceValues.value;

                        NSScanner *scanner = [NSScanner scannerWithString:hexString];

                        if ([currentDeviceTypeName isEqualToString:@"DC_POWER"]) {
                            [scanner scanHexInt:&dcPower];
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"DC_POWERMULTIPLIER"]) {
                            [scanner scanHexInt:&dcPowerMultiplier];
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"DC_POWERDIVISOR"]) {
                            [scanner scanHexInt:&dcPowerDivisor];
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"DC_VOLTAGE"]) {
                            [scanner scanHexInt:&dcVoltage];
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"DC_VOLTAGEMULTIPLIER"]) {
                            [scanner scanHexInt:&dcVoltageMultipier];
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"DC_VOLTAGEDIVISOR"]) {
                            [scanner scanHexInt:&dcVoltageDivisor];
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"DC_CURRENT"]) {
                            [scanner scanHexInt:&dcCurrent];
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"DC_CURRENTMULTIPLIER"]) {
                            [scanner scanHexInt:&dcCurrentMultipier];
                        }
                        else if ([currentDeviceTypeName isEqualToString:@"DC_CURRENTDIVISOR"]) {
                            [scanner scanHexInt:&dcCurrentDivisor];
                        }
                    }
                }

                float power = (float) dcPower * dcPowerMultiplier / dcPowerDivisor;
                float voltage = (float) dcVoltage * dcVoltageMultipier / dcVoltageDivisor;
                float current = (float) dcCurrent * dcCurrentMultipier / dcCurrentDivisor;

                // NSLog(@"Power %f Voltage %f Current %f", power, voltage, current);

                expandedLblText = [[UILabel alloc] init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];

                //Display Power
                expandedLblText.text = [NSString stringWithFormat:@"Power is %.3fW", power];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate + 25;
                expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                [belowBackgroundLabel addSubview:expandedLblText];

                expandedLblText = [[UILabel alloc] init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];

                //Display Voltage
                expandedLblText.text = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate + 25;
                expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                [belowBackgroundLabel addSubview:expandedLblText];


                expandedLblText = [[UILabel alloc] init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];



                //Display Current
                expandedLblText.text = [NSString stringWithFormat:@"Current is %.3fA", current];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate + 25;
                expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                [belowBackgroundLabel addSubview:expandedLblText];

                baseYCordinate += 25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];

                baseYCordinate = baseYCordinate + 5;

                break;
            }
            case 26: {
                //Window Covering
                baseYCordinate = baseYCordinate + 25;
                break;
            }
            case 27: {
                //Temperature Sensor
                baseYCordinate = baseYCordinate + 25;
                break;
            }
            case 34: {
                //Shade
                baseYCordinate = baseYCordinate + 25;
                break;
            }
            default:
                baseYCordinate += 25;
//                self.expandedRowHeight = 160;
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //               currentDeviceValue = [currentKnownValues objectAtIndex:0];
//                //                expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
//                //Display Location - PY 291113
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
        }

        //Settings for all the sensors
        expandedLblText = [[UILabel alloc] init];
        expandedLblText.backgroundColor = [UIColor clearColor];
        expandedLblText.textColor = [UIColor whiteColor];
        expandedLblText.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];

        expandedLblText.frame = CGRectMake(10, baseYCordinate - 5, 299, 30);
        expandedLblText.text = [NSString stringWithFormat:@"SENSOR SETTINGS"];
        [belowBackgroundLabel addSubview:expandedLblText];

        baseYCordinate = baseYCordinate + 25;

        UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
        imgLine1.image = [UIImage imageNamed:@"line.png"];
        imgLine1.alpha = 0.5;
        [belowBackgroundLabel addSubview:imgLine1];

        //Display Name
        baseYCordinate = baseYCordinate + 5;
        expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 100, 30)];
        expandedLblText.text = @"Name";
        expandedLblText.backgroundColor = [UIColor clearColor];
        expandedLblText.textColor = [UIColor whiteColor];
        expandedLblText.font = heavy_font;
        [belowBackgroundLabel addSubview:expandedLblText];

//        baseYCordinate = baseYCordinate+25;
        UITextField *tfName = [[UITextField alloc] initWithFrame:CGRectMake(110, baseYCordinate, tableView.frame.size.width - 150, 30)];
        tfName.text = currentSensor.deviceName;
        tfName.textAlignment = NSTextAlignmentRight;
        tfName.textColor = [UIColor whiteColor];
        tfName.font = heavy_font;
        tfName.tag = indexPathRow;
        [tfName setReturnKeyType:UIReturnKeyDone];
        [tfName addTarget:self action:@selector(tfNameDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfName addTarget:self action:@selector(tfNameFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [belowBackgroundLabel addSubview:tfName];

        baseYCordinate = baseYCordinate + 25;
        UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
        imgLine2.image = [UIImage imageNamed:@"line.png"];
        imgLine2.alpha = 0.5;
        [belowBackgroundLabel addSubview:imgLine2];

        //Display Location - PY 291113
        baseYCordinate = baseYCordinate + 5;
        expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 100, 30)];
        expandedLblText.backgroundColor = [UIColor clearColor];
        expandedLblText.text = @"Located at";
        expandedLblText.textColor = [UIColor whiteColor];
        expandedLblText.font = heavy_font;
        [belowBackgroundLabel addSubview:expandedLblText];

        //baseYCordinate = baseYCordinate+25;
        UITextField *tfLocation = [[UITextField alloc] initWithFrame:CGRectMake(110, baseYCordinate, tableView.frame.size.width - 150, 30)];
        tfLocation.text = currentSensor.location;
        tfLocation.textAlignment = NSTextAlignmentRight;
        tfLocation.textColor = [UIColor whiteColor];
        tfLocation.delegate = self;
        tfLocation.font = heavy_font;
        tfLocation.tag = indexPathRow;
        tfLocation.returnKeyType = UIReturnKeyDone;
        [tfLocation addTarget:self action:@selector(tfLocationDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfLocation addTarget:self action:@selector(tfLocationFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [belowBackgroundLabel addSubview:tfLocation];

        baseYCordinate = baseYCordinate + 25;
        UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, tableView.frame.size.width - 35, 1)];
        imgLine3.image = [UIImage imageNamed:@"line.png"];
        imgLine3.alpha = 0.5;
        [belowBackgroundLabel addSubview:imgLine3];

        baseYCordinate = baseYCordinate + 10;
        UIButton *btnSave = [[SFIHighlightedButton alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 100, baseYCordinate, 65, 30)];
        btnSave.backgroundColor = [UIColor whiteColor];
        btnSave.titleLabel.font = heavy_font;
        btnSave.tag = indexPathRow;
        [btnSave addTarget:self action:@selector(onSaveSensorData:) forControlEvents:UIControlEventTouchUpInside];
        [btnSave setTitle:@"Save" forState:UIControlStateNormal];
        [btnSave setTitleColor:standard_blue forState:UIControlStateNormal];
        [belowBackgroundLabel addSubview:btnSave];

        NSUInteger rowHeight = [self computeSensorRowHeight:currentSensor];

        belowBackgroundLabel.frame = CGRectMake(10, 86, (LEFT_LABEL_WIDTH) + (tableView.frame.size.width - LEFT_LABEL_WIDTH - 25) + 1, rowHeight - SENSOR_ROW_HEIGHT);
        [cell addSubview:belowBackgroundLabel];
    }

    [cell addSubview:imgSettings];
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
    