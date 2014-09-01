//
//  SFISensorDetailView.h
//
//  Created by sinclair on 8/15/14.
//
#import "SFISensorDetailView.h"
#import "SFIConstants.h"
#import "SFIHighlightedButton.h"
#import "SFISlider.h"

@interface SFISensorDetailView () <UITextFieldDelegate>
@property(nonatomic, readonly) float baseYCoordinate;
@property(nonatomic) BOOL layoutCalled;
@property(nonatomic) UITextField *deviceNameField;
@property(nonatomic) UITextField *deviceLocationField;

@property(nonatomic) UITextField *firstResponderField;
@end

@implementation SFISensorDetailView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layoutCalled = NO;
        _baseYCoordinate = -20;
    }

    return self;
}


#pragma mark - Layout

- (void)markYOffset:(int)val {
    _baseYCoordinate += val;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.firstResponderField) {
        if (!self.firstResponderField.isFirstResponder) {
            [self.firstResponderField becomeFirstResponder];
        }
    }

    if (self.layoutCalled) {
        return;
    }
    self.layoutCalled = YES;

    self.backgroundColor = self.color;

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
        case SFIDeviceType_BinarySwitch_1: {
            [self markYOffset:25];
            break;
        }
        case SFIDeviceType_MultiLevelSwitch_2: {
            [self configureMultiLevelSwitch_2];
            break;
        }
        case SFIDeviceType_BinarySensor_3: {
            [self configureBinarySensor_3];
            break;
        }
        case SFIDeviceType_MultiLevelOnOff_4: {
            [self configureLevelControl_4];
            break;
        }
        case SFIDeviceType_DoorLock_5: {
            [self markYOffset:25];
            break;
        }
        case SFIDeviceType_Alarm_6: {
            [self markYOffset:25];
            break;
        }
        case SFIDeviceType_Thermostat_7: {
            [self configureThermostat_7];
            break;
        }
        case SFIDeviceType_MotionSensor_11: {
            [self configureMotionSensor_11];
            break;
        }
        case SFIDeviceType_ContactSwitch_12: {
            [self configureContactSwitch_12];
            break;
        }
        case SFIDeviceType_FireSensor_13: {
            [self configureFireSensor_13];
            break;
        }
        case SFIDeviceType_WaterSensor_14: {
            [self configureWaterSensor_14];
            break;
        }
        case SFIDeviceType_GasSensor_15: {
            [self configureGasSensor_15];
            break;
        }
        case SFIDeviceType_VibrationOrMovementSensor_17: {
            [self configureGasSensor_17];
            break;
        }
        case SFIDeviceType_KeyFob_19: {
            [self configureKeyFob_19];
            break;
        }
        case SFIDeviceType_SmartACSwitch_22: {
            [self configureElectricMeasurementSwitch_22];
            break;
        }
        case SFIDeviceType_SmartDCSwitch_23: {
            [self configureElectricMeasurementSwitch_23];
            break;
        }
        case SFIDeviceType_WindowCovering_26: {
            [self markYOffset:25];
            break;
        }
        case SFIDeviceType_TemperatureSensor_27: {
            [self configureTempSensor_27];
            [self markYOffset:25];
            break;
        }
        case SFIDeviceType_Shade_34: {
            [self configureShadeSensor_34];
            [self markYOffset:25];
            break;
        }

        case SFIDeviceType_UnknownDevice_0:
        case SFIDeviceType_Controller_8:;
        case SFIDeviceType_SceneController_9:;
        case SFIDeviceType_StandardCIE_10:
        case SFIDeviceType_PersonalEmergencyDevice_16:
        case SFIDeviceType_RemoteControl_18:
        case SFIDeviceType_Keypad_20:
        case SFIDeviceType_StandardWarningDevice_21:
        case SFIDeviceType_OccupancySensor_24:
        case SFIDeviceType_LightSensor_25:
        case SFIDeviceType_SimpleMetering_28:
        case SFIDeviceType_ColorControl_29:
        case SFIDeviceType_PressureSensor_30:
        case SFIDeviceType_FlowSensor_31:
        case SFIDeviceType_ColorDimmableLight_32:
        case SFIDeviceType_HAPump_33:
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
            [self markYOffset:25];
            break;
        }
    }
}

#pragma mark - Public methods

- (NSString *)deviceName {
    return self.deviceNameField.text;
}

- (NSString *)deviceLocation {
    return self.deviceLocationField.text;
}

#pragma mark - Event handling

// Save button tapped
- (void)onSaveSensorNameLocationChanges:(id)sender {
    [self.delegate sensorDetailViewDidPressSaveButton:self];
}

- (void)onSensorNameTextFieldDidChange:(id)sender {

}

- (void)onSensorNameTextFieldFinishedEditing:(id)sender {

}

- (void)onSensorLocationTextFieldDidChange:(id)sender {

}

- (void)onSensorLocationTextFieldFinishedEditing:(id)sender {

}

- (void)onDismissTamper:(id)sender {
    [self.delegate sensorDetailViewDidPressDismissTamperButton:self];
}

- (void)onSliderTapped:(id)sender {
    UIGestureRecognizer *recognizer = sender;

    SFISlider *slider = (SFISlider *) recognizer.view;
    if (slider.highlighted) {
        return;
    } // tap on thumb, let slider deal with it

    CGPoint pt = [recognizer locationInView:slider];
    CGFloat percentage = pt.x / slider.bounds.size.width;
    CGFloat delta = percentage * (slider.maximumValue - slider.minimumValue);
    CGFloat value = slider.minimumValue + delta;
    [slider setValue:value animated:YES];

    NSString *newValue = [NSString stringWithFormat:@"%d", (int) value];
    [self.delegate sensorDetailViewDidChangeSensorValue:self valueName:slider.deviceValueName newValue:newValue];
}

- (void)onSliderDidEndSliding:(id)sender {
    SFISlider *slider = sender;
    NSString *newValue = [NSString stringWithFormat:@"%d", (int) (slider.value)];
    [self.delegate sensorDetailViewDidChangeSensorValue:self valueName:slider.deviceValueName newValue:newValue];
}

- (void)onThermostatFanModeSelected:(id)sender {
    [self onUpdateSegmentedControlValue:sender valueName:@"THERMOSTAT FAN MODE"];
}

- (void)onThermostatModeSelected:(id)sender {
    [self onUpdateSegmentedControlValue:sender valueName:@"THERMOSTAT MODE"];
}

- (void)onUpdateSegmentedControlValue:(id)sender valueName:(NSString *)valueName {
    UISegmentedControl *ctrl = (UISegmentedControl *) sender;
    NSString *strModeValue = [ctrl titleForSegmentAtIndex:(NSUInteger) ctrl.selectedSegmentIndex];

    [self.delegate sensorDetailViewDidChangeSensorValue:self valueName:valueName newValue:strModeValue];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.firstResponderField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.firstResponderField == textField) {
        self.firstResponderField = nil;
    }
}

#pragma mark - Layout primitives

- (void)addDisplayNameField {
    UITextField *field = [self addFieldNameValue:@"Name" fieldValue:self.device.deviceName];
    [field addTarget:self action:@selector(onSensorNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [field addTarget:self action:@selector(onSensorNameTextFieldFinishedEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.deviceNameField = field;
}

- (void)addDeviceLocationField {
    UITextField *field = [self addFieldNameValue:@"Located at" fieldValue:self.device.location];
    [field addTarget:self action:@selector(onSensorLocationTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [field addTarget:self action:@selector(onSensorLocationTextFieldFinishedEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.deviceLocationField = field;
}

- (UITextField *)addFieldNameValue:(NSString *)fieldName fieldValue:(NSString *)fieldValue {
    [self addFieldNameLabel:fieldName];

    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];

    UITextField *field = [[UITextField alloc] initWithFrame:[self makeFieldValueRect:120]];
    field.tag = self.tag;
    field.text = fieldValue;
    field.textAlignment = NSTextAlignmentRight;
    field.textColor = [UIColor whiteColor];
    field.delegate = self;
    field.font = heavy_font;
    field.returnKeyType = UIReturnKeyDone;
    [self addSubview:field];

    [self markYOffset:25];

    return field;
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

    UIButton *button = [[SFIHighlightedButton alloc] initWithFrame:CGRectMake(self.frame.size.width - button_width - right_margin, self.baseYCoordinate, button_width, 30)];
    button.tag = self.tag;
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.font = heavy_font;
    [button addTarget:self action:@selector(onSaveSensorNameLocationChanges:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Save" forState:UIControlStateNormal];
    [button setTitleColor:self.color forState:UIControlStateNormal];

    [self addSubview:button];
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
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = heavy_font;
    [button setTitle:@"Dismiss" forState:UIControlStateNormal];

    [button addTarget:self action:@selector(onDismissTamper:) forControlEvents:UIControlEventTouchDown];

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

- (UISlider *)makeSliderWithMinValue:(float)minVal maxValue:(float)maxValue valueName:(NSString *)valueName {
    // Set the height high enough to ensure touch events are not missed.
    const CGFloat slider_height = 25.0;

    //Display slider
    SFISlider *slider = [SFISlider new];
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
    slider.deviceValueName = valueName;
    slider.minimumValue = minVal;
    slider.maximumValue = maxValue;

    [slider addTarget:self action:@selector(onSliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];

    UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSliderTapped:)];
    [slider addGestureRecognizer:tapSlider];

    [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateHighlighted];
    [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"] forState:UIControlStateNormal];

    // Initialize the slider value
    float sliderValue = 0.0;
    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentDeviceValue in currentKnownValues) {
        if ([currentDeviceValue.valueName isEqualToString:valueName]) {
            sliderValue = [currentDeviceValue.value floatValue];
            break;
        }
    }
    [slider setValue:sliderValue animated:YES];

    return slider;
}

#pragma mark - Sensor layouts

- (void)configureMultiLevelSwitch_2 {
    [self markYOffset:35];

    UIImageView *minImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate - 5, 24, 24)];
    [minImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
    [self addSubview:minImage];

    // Display slider
    UISlider *slider = [self makeSliderWithMinValue:0 maxValue:99 valueName:@"SWITCH MULTILEVEL"];
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
            NSString *currentValue = currentDeviceValue.value;
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
    UISlider *slider = [self makeSliderWithMinValue:0 maxValue:255 valueName:@"SWITCH MULTILEVEL"];
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
    UISlider *heatSlider = [self makeSliderWithMinValue:35 maxValue:95 valueName:@"THERMOSTAT SETPOINT HEATING"];
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
    UISlider *coolSlider = [self makeSliderWithMinValue:35 maxValue:95 valueName:@"THERMOSTAT SETPOINT COOLING"];
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
    [scMode addTarget:self action:@selector(onThermostatModeSelected:) forControlEvents:UIControlEventValueChanged];
    [scMode setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self addSubview:scMode];

    [self markYOffset:30];
    [self addLine];
    [self markYOffset:5];

    // Fan Mode
    UILabel *lblFanMode = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate - 5, 60, 30)];
    lblFanMode.textColor = [UIColor whiteColor];
    lblFanMode.font = heavy_12;
    lblFanMode.text = @"Fan";
    [self addSubview:lblFanMode];

    UISegmentedControl *scFanMode = [[UISegmentedControl alloc] initWithItems:@[@"Auto Low", @"On Low"]];
    scFanMode.frame = CGRectMake(self.frame.size.width - 190, self.baseYCoordinate, 150, 20);
    scFanMode.tag = self.tag;

    [scFanMode setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [scFanMode addTarget:self action:@selector(onThermostatFanModeSelected:) forControlEvents:UIControlEventValueChanged];
    scFanMode.tintColor = [UIColor whiteColor];
    [self addSubview:scFanMode];

    [self markYOffset:30];
    [self addLine];

    // Status
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

    NSMutableString *strState = [[NSMutableString alloc] init];

    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentDeviceValue in currentKnownValues) {
        if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT MODE"]) {
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

#pragma mark - Helpers

- (NSUInteger)computeSensorRowHeight:(SFIDevice *)currentSensor {
    if (!currentSensor.isExpanded) {
        return SENSOR_ROW_HEIGHT;
    }

    switch (currentSensor.deviceType) {
        case SFIDeviceType_BinarySwitch_1:
            return EXPANDED_ROW_HEIGHT;
        case SFIDeviceType_MultiLevelSwitch_2:
            return 270;
        case SFIDeviceType_BinarySensor_3:
            return 260;
        case SFIDeviceType_MultiLevelOnOff_4:
            return 270;
        case SFIDeviceType_Thermostat_7:
            return 455;
        case SFIDeviceType_MotionSensor_11:
            if (currentSensor.isTampered) {
                return EXPANDED_ROW_HEIGHT + 50;
            }
            else {
                return EXPANDED_ROW_HEIGHT;
            }
        case SFIDeviceType_ContactSwitch_12:
            if (currentSensor.isTampered) {
                return 270;
            }
            else {
                return 230;
            }

        case SFIDeviceType_FireSensor_13:
        case SFIDeviceType_WaterSensor_14:
        case SFIDeviceType_GasSensor_15:
        case SFIDeviceType_VibrationOrMovementSensor_17:
        case SFIDeviceType_KeyFob_19:
            if (currentSensor.isTampered) {
                return EXPANDED_ROW_HEIGHT + 50;
            }
            else {
                return EXPANDED_ROW_HEIGHT;
            }


        case SFIDeviceType_SmartACSwitch_22:
            return 320;

        case SFIDeviceType_UnknownDevice_0:
        case SFIDeviceType_DoorLock_5:
        case SFIDeviceType_Alarm_6:
        case SFIDeviceType_Controller_8:
        case SFIDeviceType_SceneController_9:
        case SFIDeviceType_StandardCIE_10:
        case SFIDeviceType_PersonalEmergencyDevice_16:
        case SFIDeviceType_RemoteControl_18:
        case SFIDeviceType_Keypad_20:
        case SFIDeviceType_StandardWarningDevice_21:
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
        default:
            return EXPANDED_ROW_HEIGHT;
    }
}

- (NSArray *)currentKnownValuesForDevice {
    return self.deviceValue.knownValues;
}

@end