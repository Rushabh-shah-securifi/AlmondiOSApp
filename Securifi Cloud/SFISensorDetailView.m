//
//  SFISensorDetailView.h
//
//  Created by sinclair on 8/15/14.
//
#import "SFISensorDetailView.h"
#import "SFIConstants.h"
#import "SFIHighlightedButton.h"
#import "SFISlider.h"
#import "SFIColors.h"

@interface SFISensorDetailView ()
@property(nonatomic, readonly) float baseYCoordinate;
@property(nonatomic) BOOL layedOut;
@end

@implementation SFISensorDetailView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layedOut = NO;
        _baseYCoordinate = -20;
    }

    return self;
}

- (void)markYOffset:(int)val {
    _baseYCoordinate += val;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.layedOut) {
        return;
    }
    self.layedOut = YES;

    self.backgroundColor = [self makeStandardBlue];

    NSUInteger rowHeight = [self computeSensorRowHeight:self.device];
    self.frame = CGRectMake(10, 86, (LEFT_LABEL_WIDTH) + (self.frame.size.width - LEFT_LABEL_WIDTH - 25) + 1, rowHeight - SENSOR_ROW_HEIGHT);

    UIImageView *imgSettings;
    imgSettings.alpha = 1.0;

    [self layoutDevices];

    // Settings for all the sensors
    [self addSensorLabel];
    [self addLine];
    [self addDisplayNameField];
    [self addLine];
    [self addDeviceLocationField];
    [self addLine];
    [self markYOffset:5];
    [self addSaveButton];
}

- (void)layoutDevices {
    switch (self.device.deviceType) {
        case 1: {
            [self markYOffset:25];
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
            [self markYOffset:25];
            break;
        }
        case 6: {
            [self markYOffset:25];
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
        case 26: {
            [self markYOffset:25];
            break;
        }
        case 27: {
            [self configureTempSensor_27];
            [self markYOffset:25];
            break;
        }
        case 34: {
            [self configureShadeSensor_34];
            [self markYOffset:25];
            break;
        }
        default: {
            [self markYOffset:25];
            break;
        }
    }
}

- (void)addDisplayNameField {
    [self addFieldNameValue:@"Name" fieldValue:self.device.deviceName];
}

- (void)addDeviceLocationField {
    [self addFieldNameValue:@"Located at" fieldValue:self.device.location];
}

- (void)addFieldNameValue:(NSString *)fieldName fieldValue:(NSString *)fieldValue {
    [self addFieldNameLabel:fieldName];

    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];

    UITextField *deviceLocationTextField = [[UITextField alloc] initWithFrame:[self makeFieldValueRect:120]];
    deviceLocationTextField.tag = self.tag;
    deviceLocationTextField.text = fieldValue;
    deviceLocationTextField.textAlignment = NSTextAlignmentRight;
    deviceLocationTextField.textColor = [UIColor whiteColor];
    deviceLocationTextField.delegate = self;
    deviceLocationTextField.font = heavy_font;
    deviceLocationTextField.returnKeyType = UIReturnKeyDone;
    [deviceLocationTextField addTarget:nil action:@selector(sensorLocationTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [deviceLocationTextField addTarget:nil action:@selector(sensorLocationTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self addSubview:deviceLocationTextField];

    [self markYOffset:25];
}

- (void)addFieldNameLabel:(NSString *)fieldName {
    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];

    UILabel *label;
    label = [[UILabel alloc] initWithFrame:[self makeFieldNameLabelRect:100]];
    label.backgroundColor = [UIColor clearColor];
    label.text = fieldName;
    label.textColor = [UIColor whiteColor];
    label.font = heavy_font;

    [self addSubview:label];
}

- (void)addSaveButton {
    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];

    int button_width = 65;
    int right_margin = 10;

    UIButton *saveButton = [[SFIHighlightedButton alloc] initWithFrame:CGRectMake(self.frame.size.width - button_width - right_margin, self.baseYCoordinate, button_width, 30)];
    saveButton.tag = self.tag;
    saveButton.backgroundColor = [UIColor whiteColor];
    saveButton.titleLabel.font = heavy_font;
    [saveButton addTarget:nil action:@selector(onSaveSensorData:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[self makeStandardBlue] forState:UIControlStateNormal];

    [self addSubview:saveButton];
}

- (CGRect)makeFieldValueRect:(int)leftOffset {
    return CGRectMake(leftOffset - 10, self.baseYCoordinate, self.frame.size.width - leftOffset, 30);
}

- (CGRect)makeFieldNameLabelRect:(int)width {
    return CGRectMake(10, self.baseYCoordinate, width, 30);
}

- (void)addSensorLabel {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    label.frame = CGRectMake(10, self.baseYCoordinate - 5, 299, 30);
    label.text = [NSString stringWithFormat:@"SENSOR SETTINGS"];
    [self addSubview:label];
    [self markYOffset:25];
}

- (void)addTamperButton {
    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:12];

    UILabel *label;
    label = [[UILabel alloc] initWithFrame:[self makeFieldNameLabelRect:225]];
    label.backgroundColor = [UIColor clearColor];
    label.text = DEVICE_TAMPERED;
    label.textColor = [UIColor whiteColor];
    label.font = heavy_font;

    [self addSubview:label];

    UIButton *button = [[UIButton alloc] init];
    button.frame = [self makeFieldValueRect:235];//CGRectMake(self.frame.size.width - 100, self.baseYCoordinate + 6, 65, 20);
    button.tag = self.tag;
    [button addTarget:nil action:@selector(onDismissTamper:) forControlEvents:UIControlEventTouchDown];
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = heavy_font;
    [button setTitle:@"Dismiss" forState:UIControlStateNormal];

    UIColor *color = [UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6];
    [button setTitleColor:color forState:UIControlStateNormal];

    [self addSubview:button];
    [self markYOffset:35];
}

- (void)addLine {
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.baseYCoordinate, self.frame.size.width - 15, 1)];
    imgLine.image = [UIImage imageNamed:@"line.png"];
    imgLine.alpha = 0.5;
    [self addSubview:imgLine];
    [self markYOffset:5];
}

- (UISlider*)makeSliderWithMinValue:(float)minVal maxValue:(float)maxValue {
    // Set the height high enough to ensure touch events are not missed.
    const CGFloat slider_height = 25.0;

    //Display slider
    UISlider *slider = [SFISlider new];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        slider.frame = CGRectMake(40.0, self.baseYCoordinate, self.frame.size.width - 110, slider_height);
    }
    else {
        // code for 3.5-inch screen
        slider.frame = CGRectMake(40.0, self.baseYCoordinate - 10, (self.frame.size.width - 110), slider_height);
    }

    slider.tag = self.tag;
    slider.minimumValue = minVal;
    slider.maximumValue = maxValue;
    [slider addTarget:nil action:@selector(sliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];

    UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:nil action:@selector(sliderTapped:)];
    [slider addGestureRecognizer:tapSlider];

    [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateHighlighted];
    [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"] forState:UIControlStateNormal];

    return slider;
}

- (void)configureMultiLevelSwitch_2 {
    [self markYOffset:35];

    UIImageView *minImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate - 5, 24, 24)];
    [minImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
    [self addSubview:minImage];

    // Display slider
    UISlider *slider = [self makeSliderWithMinValue:0 maxValue:99];
    float currentSliderValue = 0.0;
    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentDeviceValue in currentKnownValues) {
        if ([currentDeviceValue.valueName isEqualToString:@"SWITCH MULTILEVEL"]) {
            currentSliderValue = [currentDeviceValue.value floatValue];
            break;
        }
    }
    [slider setValue:currentSliderValue animated:YES];
    [self addSubview:slider];

    UIImageView *maxImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 110) + 50, self.baseYCoordinate - 5, 24, 24)];
    [maxImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
    [self addSubview:maxImage];

    [self markYOffset:25];
    [self addLine];
}

- (void)configureBinarySensor_3 {
    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentDeviceValue in currentKnownValues) {
        //Display only battery - PY 291113
        NSString *batteryStatus;
        if ([currentDeviceValue.valueName isEqualToString:@"BATTERY"]) {
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor clearColor];
            //Check the status of value
            NSString *currentValue;
            if ([currentValue isEqualToString:@"1"]) {
                //Battery Low
                batteryStatus = @"Low Battery";
            }
            else {
                //Battery OK
                batteryStatus = @"Battery OK";
            }
            label.text = batteryStatus;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];

            [self markYOffset:25];
            label.frame = CGRectMake(10, self.baseYCoordinate, 299, 30);
            [self addSubview:label];
        }
    }

    [self markYOffset:25];;
    [self addLine];
}

- (void)configureLevelControl_4 {
    //Level Control
    [self markYOffset:35];
    UIImageView *minImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate - 5, 24, 24)];
    [minImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
    [self addSubview:minImage];

    // Display slider
    UISlider *slider = [self makeSliderWithMinValue:0 maxValue:255];
    float currentSliderValue = 0.0;
    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentDeviceValue in currentKnownValues) {
        if ([currentDeviceValue.valueName isEqualToString:@"SWITCH MULTILEVEL"]) {
            currentSliderValue = [currentDeviceValue.value floatValue];
            break;
        }
    }
    [slider setValue:currentSliderValue animated:YES];
    [self addSubview:slider];

    UIImageView *maxImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 110) + 50, self.baseYCoordinate - 5, 24, 24)];
    [maxImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
    [self addSubview:maxImage];

    [self markYOffset:25];
    [self addLine];
}

- (void)configureThermostat_7 {
    UIFont *const heavy_12 = [UIFont fontWithName:@"Avenir-Heavy" size:12];

    [self markYOffset:40];

    // Heating Set Point
    UILabel *lblHeating = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate - 5, 60, 30)];
    lblHeating.textColor = [UIColor whiteColor];
    lblHeating.font = heavy_12;
    lblHeating.text = @"Heating";
    [self addSubview:lblHeating];

    UILabel *lblMinHeat = [[UILabel alloc] initWithFrame:CGRectMake(70.0, self.baseYCoordinate - 3, 30, 24)];
    lblMinHeat.font = heavy_12;
    lblMinHeat.text = @"35°";
    lblMinHeat.textColor = [UIColor whiteColor];
    lblMinHeat.textAlignment = NSTextAlignmentCenter;
    lblMinHeat.backgroundColor = [UIColor clearColor];
    [self addSubview:lblMinHeat];

    const CGRect frame = self.frame;

    // Heat Slider
    UISlider *heatSlider = [self makeSliderWithMinValue:35 maxValue:95];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    const CGFloat slider_height = 25.0;
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        heatSlider.frame = CGRectMake(100.0, self.baseYCoordinate, frame.size.width - 160, slider_height);
    }
    else {
        // code for 3.5-inch screen
        heatSlider.frame = CGRectMake(100.0, self.baseYCoordinate - 10, frame.size.width - 160, slider_height);
    }
    [self addSubview:heatSlider];

    UILabel *lblMaxHeat = [[UILabel alloc] initWithFrame:CGRectMake(100 + (frame.size.width - 160), self.baseYCoordinate - 3, 30, 24)];
    lblMaxHeat.font = heavy_12;
    lblMaxHeat.text = @"95°";
    lblMaxHeat.textColor = [UIColor whiteColor];
    lblMaxHeat.textAlignment = NSTextAlignmentCenter;
    lblMaxHeat.backgroundColor = [UIColor clearColor];
    [self addSubview:lblMaxHeat];

    [self markYOffset:40];

    // Cooling Set Point
    UILabel *lblCooling = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate - 5, 60, 30)];
    lblCooling.textColor = [UIColor whiteColor];
    lblCooling.font = heavy_12;
    lblCooling.text = @"Cooling";
    [self addSubview:lblCooling];

    UILabel *lblMinCool = [[UILabel alloc] initWithFrame:CGRectMake(70.0, self.baseYCoordinate - 3, 30, 24)];
    lblMinCool.font = heavy_12;
    lblMinCool.text = @"35°";
    lblMinCool.textColor = [UIColor whiteColor];
    lblMinCool.textAlignment = NSTextAlignmentCenter;
    lblMinCool.backgroundColor = [UIColor clearColor];
    [self addSubview:lblMinCool];

    // Display Cooling slider
    UISlider *coolSlider = [self makeSliderWithMinValue:35 maxValue:95];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        coolSlider.frame = CGRectMake(100.0, self.baseYCoordinate, frame.size.width - 160, slider_height);
    }
    else {
        // code for 3.5-inch screen
        coolSlider.frame = CGRectMake(100.0, self.baseYCoordinate - 10, frame.size.width - 160, slider_height);
    }
    [self addSubview:coolSlider];

    UILabel *lblMaxCool = [[UILabel alloc] initWithFrame:CGRectMake(100 + (frame.size.width - 160), self.baseYCoordinate - 3, 30, 24)];
    lblMaxCool.font = heavy_12;
    lblMaxCool.text = @"95°";
    lblMaxCool.textColor = [UIColor whiteColor];
    lblMaxCool.textAlignment = NSTextAlignmentCenter;
    lblMaxCool.backgroundColor = [UIColor clearColor];
    [self addSubview:lblMaxCool];

    [self markYOffset:30];
    [self addLine];
    [self markYOffset:5];

    //Mode
    UILabel *lblMode = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate - 5, 100, 30)];
    lblMode.textColor = [UIColor whiteColor];
    lblMode.font = heavy_12;
    lblMode.text = @"Thermostat";
    [self addSubview:lblMode];

    //Font for segment control
    NSDictionary *attributes = @{NSFontAttributeName : heavy_12};

    UISegmentedControl *scMode = [[UISegmentedControl alloc] initWithItems:@[@"Auto", @"Heat", @"Cool", @"Off"]];
    scMode.frame = CGRectMake(self.frame.size.width - 220, self.baseYCoordinate, 180, 20);
    scMode.tag = self.tag;
    scMode.tintColor = [UIColor whiteColor];
    [scMode addTarget:nil action:@selector(modeSelected:) forControlEvents:UIControlEventValueChanged];
    [scMode setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self addSubview:scMode];

    [self markYOffset:30];
    [self addLine];
    [self markYOffset:5];

    //Fan Mode
    UILabel *lblFanMode = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate - 5, 60, 30)];
    lblFanMode.textColor = [UIColor whiteColor];
    lblFanMode.font = heavy_12;
    lblFanMode.text = @"Fan";
    [self addSubview:lblFanMode];

    UISegmentedControl *scFanMode = [[UISegmentedControl alloc] initWithItems:@[@"Auto Low", @"On Low"]];
    scFanMode.frame = CGRectMake(self.frame.size.width - 190, self.baseYCoordinate, 150, 20);
    scFanMode.tag = self.tag;

    [scFanMode setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [scFanMode addTarget:nil action:@selector(fanModeSelected:) forControlEvents:UIControlEventValueChanged];
    scFanMode.tintColor = [UIColor whiteColor];
    [self addSubview:scFanMode];

    [self markYOffset:30];
    [self addLine];

    //Status
    UILabel *lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate, 60, 30)];
    lblStatus.textColor = [UIColor whiteColor];
    lblStatus.text = @"Status";
    lblStatus.font = heavy_12;
    [self addSubview:lblStatus];

    //Operating state
    UILabel *lblOperatingState = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 250, self.baseYCoordinate, 220, 30)];
    lblOperatingState.textColor = [UIColor whiteColor];
    lblOperatingState.backgroundColor = [UIColor clearColor];
    lblOperatingState.font = heavy_12;
    lblOperatingState.textAlignment = NSTextAlignmentRight;
    [self addSubview:lblOperatingState];

    [self markYOffset:25];

    //Battery
    UILabel *lblBattery = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 250, self.baseYCoordinate - 5, 220, 30)];
    lblBattery.textColor = [UIColor whiteColor];
    lblBattery.font = heavy_12;
    lblBattery.backgroundColor = [UIColor clearColor];
    lblBattery.textAlignment = NSTextAlignmentRight;
    [self addSubview:lblBattery];

    [self markYOffset:25];
    [self addLine];

    //Set slider value
    float currentHeatingSliderValue = 0.0;
    float currentCoolingSliderValue = 0.0;

    NSMutableString *strState = [[NSMutableString alloc] init];

    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentDeviceValue in currentKnownValues) {
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
            [strState appendString:[NSString stringWithFormat:@"Thermostat is %@. ", currentDeviceValue.value]];
        }
        else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT FAN MODE"]) {
            if ([currentDeviceValue.value isEqualToString:@"Auto Low"]) {
                scFanMode.selectedSegmentIndex = 0;
            }
            else {
                scFanMode.selectedSegmentIndex = 1;
            }
        }
        else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT FAN STATE"]) {
            [strState appendString:[NSString stringWithFormat:@"Fan is %@.", currentDeviceValue.value]];
        }
        else if ([currentDeviceValue.valueName isEqualToString:@"BATTERY"]) {
            lblBattery.text = [NSString stringWithFormat:@"Battery is at %@%%.", currentDeviceValue.value];
        }
    }

    lblOperatingState.text = strState;

    [heatSlider setValue:currentHeatingSliderValue animated:YES];
    [coolSlider setValue:currentCoolingSliderValue animated:YES];
}

- (void)configureMotionSensor_11 {
    [self markYOffset:25];

    if (self.device.isTampered) {
        [self addTamperButton];
        [self addLine];
    }
}

- (void)configureContactSwitch_12 {
    [self markYOffset:25];

    if (self.device.isTampered) {
        [self addTamperButton];
        [self addLine];
    }
}

- (void)configureFireSensor_13 {
    [self markYOffset:25];

    if (self.device.isTampered) {
        [self addTamperButton];
        [self addLine];
    }
}

- (void)configureWaterSensor_14 {
    [self markYOffset:25];

    if (self.device.isTampered) {
        [self addTamperButton];
        [self addLine];
    }
}

- (void)configureGasSensor_15 {
    [self markYOffset:25];

    if (self.device.isTampered) {
        [self addTamperButton];
        [self addLine];
    }
}

- (void)configureGasSensor_17 {
    [self markYOffset:25];

    if (self.device.isTampered) {
        [self addTamperButton];
        [self addLine];
    }
}

- (void)configureKeyFob_19 {
    [self markYOffset:25];

    if (self.device.isTampered) {
        [self addTamperButton];
        [self addLine];
    }
}

- (void)configureElectricMeasurementSwitch_22 {
    //Show values and calculations
    //Calculate values
    unsigned int activePower = 0;
    unsigned int acPowerMultiplier = 0;
    unsigned int acPowerDivisor = 0;
    unsigned int rmsVoltage = 0;
    unsigned int acVoltageMultiplier = 0;
    unsigned int acVoltageDivisor = 0;
    unsigned int rmsCurrent = 0;
    unsigned int acCurrentMultiplier = 0;
    unsigned int acCurrentDivisor = 0;

    NSString *currentDeviceTypeName;
    NSString *hexString;

    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentDeviceValue in currentKnownValues) {
        currentDeviceTypeName = currentDeviceValue.valueName;
        hexString = currentDeviceValue.value;
        //                          NSString *hexIP = [NSString stringWithFormat:@"%lX", (long)[currentDevice.deviceIP integerValue]];
        //							hexString = hexString.substring(2);
        // DLog(@"HEX STRING: %@", hexString);
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
            [scanner scanHexInt:&acVoltageMultiplier];
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
            [scanner scanHexInt:&acCurrentMultiplier];
            //acCurrentMultipier = Integer.parseInt(hexString, 16);
        }
        else if ([currentDeviceTypeName isEqualToString:@"AC_CURRENTDIVISOR"]) {
            [scanner scanHexInt:&acCurrentDivisor];
            //acCurrentDivisor = Integer.parseInt(hexString, 16);
        }
    }

    float power = (float) activePower * acPowerMultiplier / acPowerDivisor;
    float voltage = (float) rmsVoltage * acVoltageMultiplier / acVoltageDivisor;
    float current = (float) rmsCurrent * acCurrentMultiplier / acCurrentDivisor;

    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    UILabel *expandedLblText;

    // Display Power
    expandedLblText = [[UILabel alloc] init];
    expandedLblText.backgroundColor = [UIColor clearColor];
    expandedLblText.text = [NSString stringWithFormat:@"Power is %.3fW", power];
    expandedLblText.textColor = [UIColor whiteColor];
    expandedLblText.font = heavy_font;
    [self markYOffset:25];
    expandedLblText.frame = CGRectMake(10, self.baseYCoordinate, 299, 30);
    [self addSubview:expandedLblText];

    // Display Voltage
    expandedLblText = [[UILabel alloc] init];
    expandedLblText.backgroundColor = [UIColor clearColor];
    expandedLblText.text = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];
    expandedLblText.textColor = [UIColor whiteColor];
    expandedLblText.font = heavy_font;
    [self markYOffset:25];
    expandedLblText.frame = CGRectMake(10, self.baseYCoordinate, 299, 30);
    [self addSubview:expandedLblText];

    // Display Current
    expandedLblText = [[UILabel alloc] init];
    expandedLblText.backgroundColor = [UIColor clearColor];
    expandedLblText.text = [NSString stringWithFormat:@"Current is %.3fA", current];
    expandedLblText.textColor = [UIColor whiteColor];
    expandedLblText.font = heavy_font;
    [self markYOffset:25];
    expandedLblText.frame = CGRectMake(10, self.baseYCoordinate, 299, 30);
    [self addSubview:expandedLblText];

    [self markYOffset:25];
    [self addLine];
}

- (void)configureElectricMeasurementSwitch_23 {
    //Electric Measure - DC
    //Show values and calculations
    //Calculate values
    unsigned int dcPower = 0;
    unsigned int dcPowerMultiplier = 0;
    unsigned int dcPowerDivisor = 0;
    unsigned int dcVoltage = 0;
    unsigned int dcVoltageMultiplier = 0;
    unsigned int dcVoltageDivisor = 0;
    unsigned int dcCurrent = 0;
    unsigned int dcCurrentMultiplier = 0;
    unsigned int dcCurrentDivisor = 0;

    NSString *currentDeviceTypeName;
    NSString *hexString;

    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentDeviceValue in currentKnownValues) {
        currentDeviceTypeName = currentDeviceValue.valueName;
        hexString = currentDeviceValue.value;

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
            [scanner scanHexInt:&dcVoltageMultiplier];
        }
        else if ([currentDeviceTypeName isEqualToString:@"DC_VOLTAGEDIVISOR"]) {
            [scanner scanHexInt:&dcVoltageDivisor];
        }
        else if ([currentDeviceTypeName isEqualToString:@"DC_CURRENT"]) {
            [scanner scanHexInt:&dcCurrent];
        }
        else if ([currentDeviceTypeName isEqualToString:@"DC_CURRENTMULTIPLIER"]) {
            [scanner scanHexInt:&dcCurrentMultiplier];
        }
        else if ([currentDeviceTypeName isEqualToString:@"DC_CURRENTDIVISOR"]) {
            [scanner scanHexInt:&dcCurrentDivisor];
        }
    }

    float power = (float) dcPower * dcPowerMultiplier / dcPowerDivisor;
    float voltage = (float) dcVoltage * dcVoltageMultiplier / dcVoltageDivisor;
    float current = (float) dcCurrent * dcCurrentMultiplier / dcCurrentDivisor;

    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    UILabel *expandedLblText;

    // Display Power
    expandedLblText = [[UILabel alloc] init];
    expandedLblText.backgroundColor = [UIColor clearColor];
    expandedLblText.text = [NSString stringWithFormat:@"Power is %.3fW", power];
    expandedLblText.textColor = [UIColor whiteColor];
    expandedLblText.font = heavy_font;
    [self markYOffset:25];
    expandedLblText.frame = CGRectMake(10, self.baseYCoordinate, 299, 30);
    [self addSubview:expandedLblText];

    // Display Voltage
    expandedLblText = [[UILabel alloc] init];
    expandedLblText.backgroundColor = [UIColor clearColor];
    expandedLblText.text = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];
    expandedLblText.textColor = [UIColor whiteColor];
    expandedLblText.font = heavy_font;
    [self markYOffset:25];
    expandedLblText.frame = CGRectMake(10, self.baseYCoordinate, 299, 30);
    [self addSubview:expandedLblText];

    // Display Current
    expandedLblText = [[UILabel alloc] init];
    expandedLblText.backgroundColor = [UIColor clearColor];
    expandedLblText.text = [NSString stringWithFormat:@"Current is %.3fA", current];
    expandedLblText.textColor = [UIColor whiteColor];
    expandedLblText.font = heavy_font;
    [self markYOffset:25];
    expandedLblText.frame = CGRectMake(10, self.baseYCoordinate, 299, 30);
    [self addSubview:expandedLblText];

    [self markYOffset:25];
    [self addLine];
}

- (void)configureTempSensor_27 {
/*
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
*/
}

- (void)configureShadeSensor_34 {

}

- (UIColor *)makeStandardBlue {
    SFIColors *color = self.currentColor;

    return [UIColor colorWithHue:(CGFloat) (color.hue / 360.0)
                      saturation:(CGFloat) (color.saturation / 100.0)
                      brightness:(CGFloat) (color.brightness / 100.0)
                           alpha:1];
}

- (NSUInteger)computeSensorRowHeight:(SFIDevice *)currentSensor {
    if (!currentSensor.isExpanded) {
        return SENSOR_ROW_HEIGHT;
    }

    switch (currentSensor.deviceType) {
        case 1:
            //Switch - 2 values
            return EXPANDED_ROW_HEIGHT;
        case 2:
            //Multilevel switch - 3 values
            return 270;
        case 3:
            //Sensor - 3 values
            return 260;
        case 4:
            return 270;
        case 7:
            return 455;
        case 11:
            if (currentSensor.isTampered) {
                return EXPANDED_ROW_HEIGHT + 50;
            }
            else {
                return EXPANDED_ROW_HEIGHT;
            }
        case 12:
            if (currentSensor.isTampered) {
                return 270;
            }
            else {
                return 230;
            }
        case 13:
        case 14:
        case 15:
        case 17:
        case 19:
            if (currentSensor.isTampered) {
                return EXPANDED_ROW_HEIGHT + 50;
            }
            else {
                return EXPANDED_ROW_HEIGHT;
            }
        case 22:
            //Multilevel switch - 5 values
            return 320;
        default:
            return EXPANDED_ROW_HEIGHT;
    }
}

- (NSArray *)currentKnownValuesForDevice {
    return self.deviceValue.knownValues;
}

@end