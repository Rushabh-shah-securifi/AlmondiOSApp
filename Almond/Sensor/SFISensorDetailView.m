//
//  SFISensorDetailView.h
//
//  Created by sinclair on 8/15/14.
//
#import "SFISensorDetailView.h"
#import "SFIConstants.h"
#import "SFIHighlightedButton.h"
#import "SFISlider.h"
#import "V8HorizontalPickerView.h"
#import "Colours.h"


#define PICKER_ELEMENT_WIDTH 30
#define TEMP_LOWEST_SETTABLE 35
#define TEMP_HIGHEST_SETTABLE 95

// ===================================================================================


// Draws an indicator line on the picker view showing which value is currently selected
@interface SFIPickerIndicatorView : UIView
@property UIColor *color;
@property CAShapeLayer *shapeLayer;
@end

@implementation SFIPickerIndicatorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.color = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }

    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self initializeControl:self.frame];
}

- (void)initializeControl:(CGRect)rect {
    CGColorRef white_ref = self.color.CGColor;

    if (self.shapeLayer) {
        [self.shapeLayer removeFromSuperlayer];
    }

    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [self linePath:rect];
    layer.fillColor = white_ref;
    layer.strokeColor = white_ref;
    layer.lineWidth = self.frame.size.height;

    self.shapeLayer = layer;
    [self.layer addSublayer:layer];
}

- (CGPathRef)linePath:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];

    CGPoint point = CGPointMake(rect.size.width, 0);
    [path addLineToPoint:point];

    return path.CGPath;
}

@end

// ===================================================================================

@interface SFISensorDetailView () <UITextFieldDelegate, V8HorizontalPickerViewDelegate, V8HorizontalPickerViewDataSource>
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

    NSUInteger rowHeight = [SFISensorDetailView computeSensorRowHeight:self.device];
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
            [self configureMultiLevelSwitchMinValue:0 maxValue:99];
            break;
        }
        case SFIDeviceType_BinarySensor_3: {
            [self configureBinarySensor_3];
            break;
        }
        case SFIDeviceType_MultiLevelOnOff_4: {
            [self configureMultiLevelSwitchMinValue:0 maxValue:255];
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
    [self.delegate sensorDetailViewDidChangeSensorValue:self propertyType:slider.propertyType newValue:newValue];
}

- (void)onSliderDidEndSliding:(id)sender {
    SFISlider *slider = sender;
    NSString *newValue = [NSString stringWithFormat:@"%d", (int) (slider.value)];

    [self.delegate sensorDetailViewDidChangeSensorValue:self propertyType:slider.propertyType newValue:newValue];
}

- (void)onThermostatFanModeSelected:(id)sender {
    [self onUpdateSegmentedControlValue:sender propertyType:SFIDevicePropertyType_THERMOSTAT_FAN_MODE];
}

- (void)onThermostatModeSelected:(id)sender {
    [self onUpdateSegmentedControlValue:sender propertyType:SFIDevicePropertyType_THERMOSTAT_MODE];
}

- (void)onUpdateSegmentedControlValue:(id)sender propertyType:(SFIDevicePropertyType)propertyType {
    UISegmentedControl *ctrl = (UISegmentedControl *) sender;
    NSString *strModeValue = [ctrl titleForSegmentAtIndex:(NSUInteger) ctrl.selectedSegmentIndex];

    [self.delegate sensorDetailViewDidChangeSensorValue:self propertyType:propertyType newValue:strModeValue];
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
    int button_width = 65;
    int right_margin = 10;
    CGRect frame = CGRectMake(self.frame.size.width - button_width - right_margin, self.baseYCoordinate, button_width, 30);

    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];

    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *normalColor = self.color;
    UIColor *highlightColor = whiteColor;

    SFIHighlightedButton *button = [[SFIHighlightedButton alloc] initWithFrame:frame];
    button.tag = self.tag;
    button.normalBackgroundColor = normalColor;
    button.highlightedBackgroundColor = highlightColor;
    button.titleLabel.font = heavy_font;
    [button addTarget:self action:@selector(onSaveSensorNameLocationChanges:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Save" forState:UIControlStateNormal];
    [button setTitleColor:whiteColor forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateHighlighted];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = whiteColor.CGColor;

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

    UIColor *whiteColor = [UIColor whiteColor];
//    UIColor *whiteColor = [UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6];
    UIColor *normalColor = self.color;
    UIColor *highlightColor = whiteColor;

    UILabel *label;
    label = [[UILabel alloc] initWithFrame:[self makeFieldNameLabelRect:225]];
    label.backgroundColor = self.color;
    label.text = DEVICE_TAMPERED;
    label.textColor = whiteColor;
    label.font = heavy_font;

    [self addSubview:label];

    SFIHighlightedButton *button = [[SFIHighlightedButton alloc] initWithFrame:CGRectZero];
    button.frame = [self makeFieldValueRect:235];//CGRectMake(self.frame.size.width - 100, self.baseYCoordinate + 6, 65, 20);
    button.tag = self.tag;
    button.normalBackgroundColor = normalColor;
    button.highlightedBackgroundColor = highlightColor;
    button.titleLabel.font = heavy_font;
    [button setTitle:@"Dismiss" forState:UIControlStateNormal];
    [button setTitleColor:whiteColor forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(onDismissTamper:) forControlEvents:UIControlEventTouchDown];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = whiteColor.CGColor;

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

- (UISlider *)makeSliderWithMinValue:(float)minVal maxValue:(float)maxValue propertyType:(SFIDevicePropertyType)propertyType {
    // Set the height high enough to ensure touch events are not missed.
    const CGFloat slider_height = 25.0;

    //Display slider
    SFISlider *slider = [SFISlider new];
    slider.frame = CGRectMake(40.0, self.baseYCoordinate, (self.frame.size.width - 90), slider_height);
    slider.tag = self.tag;
    slider.propertyType = propertyType;
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
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:propertyType];
    float sliderValue = [currentDeviceValue floatValue];
    [slider setValue:sliderValue animated:YES];

    return slider;
}

- (void)addStatusLabel:(NSArray *)statusMessages {
    UIFont *const heavy_12 = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    UIColor *const white_color = [UIColor whiteColor];
    UIColor *const clear_color = [UIColor clearColor];

    // Status
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate, 60, 30)];
    statusLabel.textColor = white_color;
    statusLabel.text = @"Status";
    statusLabel.font = heavy_12;
    [self addSubview:statusLabel];

    // Messages
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 230, self.baseYCoordinate, 220, 50)];
    valueLabel.textColor = white_color;
    valueLabel.backgroundColor = clear_color;
    valueLabel.font = heavy_12;
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.numberOfLines = statusMessages.count;
    [self addSubview:valueLabel];

    valueLabel.text = [statusMessages componentsJoinedByString:@"\n"];
}

- (void)addHorizontalPicker:(NSString *)labelText propertyType:(SFIDevicePropertyType)propertyType {
    UIFont *const heavy_12 = [UIFont fontWithName:@"Avenir-Heavy" size:12];

    // Set Point label
    UILabel *setPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate, 60, 30)];
    setPointLabel.textColor = [UIColor whiteColor];
    setPointLabel.font = heavy_12;
    setPointLabel.text = labelText;
    [self addSubview:setPointLabel];

    UIColor *const contrastingColor = [self.color blackOrWhiteContrastingColor];

    // Picker
    V8HorizontalPickerView *picker = [[V8HorizontalPickerView alloc] initWithFrame:CGRectZero];
    picker.tag = propertyType; // we stored the type of property in the tag info; will use in delegate methods and callbacks
    picker.frame = CGRectMake(70.0, self.baseYCoordinate, self.frame.size.width - 80, PICKER_ELEMENT_WIDTH);
    picker.layer.cornerRadius = 4;
    picker.layer.borderWidth = 1.0;
    picker.layer.borderColor = [UIColor whiteColor].CGColor;
    picker.backgroundColor = [UIColor clearColor];
    picker.selectedTextColor = contrastingColor;
    picker.elementFont = heavy_12;
    picker.textColor = [UIColor whiteColor];
    picker.indicatorPosition = V8HorizontalPickerIndicatorBottom;
    picker.selectionPoint = CGPointMake((picker.frame.size.width) / 2, 0);   // middle of picker
    picker.delegate = self;
    picker.dataSource = self;

    SFIPickerIndicatorView *indicatorView = [[SFIPickerIndicatorView alloc] initWithFrame:CGRectMake(0, 0, PICKER_ELEMENT_WIDTH, 2)];
    indicatorView.color = contrastingColor;
    picker.selectionIndicatorView = indicatorView;

    [self addSubview:picker];
    [self setPickerRow:propertyType picker:picker];
}

#pragma mark - Sensor layouts

- (void)configureMultiLevelSwitchMinValue:(int)minValue maxValue:(int)maxValue {
    [self markYOffset:35];

    UIImageView *minImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate, 24, 24)];
    [minImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
    [self addSubview:minImage];

    // Display slider
    UISlider *slider = [self makeSliderWithMinValue:minValue maxValue:maxValue propertyType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
    [self addSubview:slider];

    UIImageView *maxImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 90) + 50, self.baseYCoordinate, 24, 24)];
    [maxImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
    [self addSubview:maxImage];

    [self markYOffset:35];
    [self addLine];
}

- (void)configureBinarySensor_3 {
    SFIDeviceKnownValues *values = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_BATTERY];
    NSString *batteryStatus = [values choiceForLevelValueZeroValue:@"Battery OK" nonZeroValue:@"Low Battery" nilValue:@"Battery Unknown"];

    [self markYOffset:25];

    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.text = batteryStatus;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    label.frame = CGRectMake(10, self.baseYCoordinate, 299, 30);
    [self addSubview:label];

    [self markYOffset:25];;
    [self addLine];
}

- (void)configureThermostat_7 {
    // Temp selectors
    [self markYOffset:30];
    [self addHorizontalPicker:@"Heating" propertyType:SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING];

    [self markYOffset:40];
    [self addHorizontalPicker:@"Cooling" propertyType:SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING];

    [self markYOffset:40];
    [self addLine];
    [self markYOffset:5];

    UIFont *const heavy_12 = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    UIColor *const white_color = [UIColor whiteColor];
    NSDictionary *const attributes = @{NSFontAttributeName : heavy_12};
    SFIDeviceValue *const deviceValue = self.deviceValue;

    // Mode
    UILabel *modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate, 100, 30)];
    modeLabel.textColor = white_color;
    modeLabel.font = heavy_12;
    modeLabel.text = @"Mode";
    [self addSubview:modeLabel];
    //
    UISegmentedControl *modeSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Auto", @"Heat", @"Cool", @"Off"]];
    modeSegmentControl.frame = CGRectMake(90.0, self.baseYCoordinate, self.frame.size.width - 100, 25.0); //CGRectMake(self.frame.size.width - 190, self.baseYCoordinate, 180, 25);
    modeSegmentControl.tag = self.tag;
    modeSegmentControl.tintColor = white_color;
    [modeSegmentControl addTarget:self action:@selector(onThermostatModeSelected:) forControlEvents:UIControlEventValueChanged];
    [modeSegmentControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    //
    NSDictionary *choices = @{
            @"Auto" : @0,
            @"Heat" : @1,
            @"Cool" : @2,
            @"Off" : @3,
    };
    //
    NSNumber *modeSegment_index = [deviceValue choiceForPropertyValue:SFIDevicePropertyType_THERMOSTAT_MODE choices:choices default:@0];
    modeSegmentControl.selectedSegmentIndex = modeSegment_index.intValue;
    [self addSubview:modeSegmentControl];

    [self markYOffset:35];
    [self addLine];
    [self markYOffset:5];

    // Fan Mode
    UILabel *fanModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate, 60, 30)];
    fanModeLabel.textColor = white_color;
    fanModeLabel.font = heavy_12;
    fanModeLabel.text = @"Fan";
    [self addSubview:fanModeLabel];
    //
    UISegmentedControl *fanModeSegmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Auto Low", @"On Low"]];
    fanModeSegmentControl.frame = CGRectMake(90.0, self.baseYCoordinate, self.frame.size.width - 100, 25.0);
    fanModeSegmentControl.tag = self.tag;
    fanModeSegmentControl.tintColor = white_color;
    [fanModeSegmentControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [fanModeSegmentControl addTarget:self action:@selector(onThermostatFanModeSelected:) forControlEvents:UIControlEventValueChanged];
    //
    NSNumber *fanModeSegment_index = [deviceValue choiceForPropertyValue:SFIDevicePropertyType_THERMOSTAT_FAN_MODE choices:@{@"Auto Low" : @0} default:@1];
    fanModeSegmentControl.selectedSegmentIndex = fanModeSegment_index.intValue;
    //
    [self addSubview:fanModeSegmentControl];

    [self markYOffset:35];
    [self addLine];

    // Status
    NSString *values = [deviceValue valueForProperty:SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE default:@""];
    NSString *thermostat_str = [NSString stringWithFormat:@"Thermostat is %@", values];
    //
    values = [deviceValue valueForProperty:SFIDevicePropertyType_THERMOSTAT_FAN_STATE default:@""];
    NSString *fan_str = [NSString stringWithFormat:@"Fan is %@", values];
    //
    values = [deviceValue valueForProperty:SFIDevicePropertyType_BATTERY default:@""];
    NSString *battery_str = [NSString stringWithFormat:@"Battery is at %@%%", values];

    [self addStatusLabel:@[thermostat_str, fan_str, battery_str]];
    [self markYOffset:55];
    [self addLine];
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
    unsigned int activePower = 0;
    unsigned int acPowerMultiplier = 0;
    unsigned int acPowerDivisor = 0;
    unsigned int rmsVoltage = 0;
    unsigned int acVoltageMultiplier = 0;
    unsigned int acVoltageDivisor = 0;
    unsigned int rmsCurrent = 0;
    unsigned int acCurrentMultiplier = 0;
    unsigned int acCurrentDivisor = 0;

    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentDeviceValue in currentKnownValues) {
        NSScanner *scanner = [NSScanner scannerWithString:currentDeviceValue.value];

        switch (currentDeviceValue.propertyType) {
            case SFIDevicePropertyType_AC_CURRENTDIVISOR: {
                [scanner scanHexInt:&acCurrentDivisor];
                break;
            }
            case SFIDevicePropertyType_AC_CURRENTMULTIPLIER: {
                [scanner scanHexInt:&acCurrentMultiplier];
                break;
            }
            case SFIDevicePropertyType_AC_POWERDIVISOR: {
                [scanner scanHexInt:&acPowerDivisor];
                break;
            }
            case SFIDevicePropertyType_AC_POWERMULTIPLIER: {
                [scanner scanHexInt:&acPowerMultiplier];
                break;
            }
            case SFIDevicePropertyType_AC_VOLTAGEMULTIPLIER: {
                [scanner scanHexInt:&acVoltageMultiplier];
                break;
            }
            case SFIDevicePropertyType_ACTIVE_POWER: {
                [scanner scanHexInt:&activePower];
                break;
            }
            case SFIDevicePropertyType_RMS_CURRENT: {
                [scanner scanHexInt:&rmsCurrent];
                break;
            }
            case SFIDevicePropertyType_RMS_VOLTAGE: {
                [scanner scanHexInt:&rmsVoltage];
                break;
            }
            default:
                break;
        }
    }

    float power = (float) activePower * acPowerMultiplier / acPowerDivisor;
    float voltage = (float) rmsVoltage * acVoltageMultiplier / acVoltageDivisor;
    float current = (float) rmsCurrent * acCurrentMultiplier / acCurrentDivisor;

    NSString *power_str = [NSString stringWithFormat:@"Power is %.3fW", power];
    NSString *voltage_str = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];
    NSString *current_str = [NSString stringWithFormat:@"Current is %.3fA", current];

    [self markYOffset:25];
    [self addStatusLabel:@[power_str, voltage_str, current_str]];
    [self markYOffset:55];
    [self addLine];
}

- (void)configureElectricMeasurementSwitch_23 {
    unsigned int dcPower = 0;
    unsigned int dcPowerMultiplier = 0;
    unsigned int dcPowerDivisor = 0;
    unsigned int dcVoltage = 0;
    unsigned int dcVoltageMultiplier = 0;
    unsigned int dcVoltageDivisor = 0;
    unsigned int dcCurrent = 0;
    unsigned int dcCurrentMultiplier = 0;
    unsigned int dcCurrentDivisor = 0;

    NSArray *currentKnownValues = [self currentKnownValuesForDevice];
    for (SFIDeviceKnownValues *currentDeviceValue in currentKnownValues) {
        NSScanner *scanner = [NSScanner scannerWithString:currentDeviceValue.value];

        switch (currentDeviceValue.propertyType) {
            case SFIDevicePropertyType_DC_CURRENT:
                [scanner scanHexInt:&dcCurrent];
                break;
            case SFIDevicePropertyType_DC_CURRENTDIVISOR:
                [scanner scanHexInt:&dcCurrentDivisor];
                break;
            case SFIDevicePropertyType_DC_CURRENTMULTIPLIER:
                [scanner scanHexInt:&dcCurrentMultiplier];
                break;
            case SFIDevicePropertyType_DC_POWER:
                [scanner scanHexInt:&dcPower];
                break;
            case SFIDevicePropertyType_DC_POWERDIVISOR:
                [scanner scanHexInt:&dcPowerDivisor];
                break;
            case SFIDevicePropertyType_DC_POWERMULTIPLIER:
                [scanner scanHexInt:&dcPowerMultiplier];
                break;
            case SFIDevicePropertyType_DC_VOLTAGE:
                [scanner scanHexInt:&dcVoltage];
                break;
            case SFIDevicePropertyType_DC_VOLTAGEDIVISOR:
                [scanner scanHexInt:&dcVoltageDivisor];
                break;
            case SFIDevicePropertyType_DC_VOLTAGEMULTIPLIER:
                [scanner scanHexInt:&dcVoltageMultiplier];
                break;
            default:
                break;
        }
    }

    float power = (float) dcPower * dcPowerMultiplier / dcPowerDivisor;
    float voltage = (float) dcVoltage * dcVoltageMultiplier / dcVoltageDivisor;
    float current = (float) dcCurrent * dcCurrentMultiplier / dcCurrentDivisor;

    NSString *power_str = [NSString stringWithFormat:@"Power is %.3fW", power];
    NSString *voltage_str = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];
    NSString *current_str = [NSString stringWithFormat:@"Current is %.3fA", current];

    [self markYOffset:25];
    [self addStatusLabel:@[power_str, voltage_str, current_str]];
    [self markYOffset:55];
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

+ (NSUInteger)computeSensorRowHeight:(SFIDevice *)currentSensor {
    if (!currentSensor.isExpanded) {
        return SENSOR_ROW_HEIGHT;
    }

    switch (currentSensor.deviceType) {
        case SFIDeviceType_BinarySwitch_1:
            return EXPANDED_ROW_HEIGHT;
        case SFIDeviceType_MultiLevelSwitch_2:
            return 280;
        case SFIDeviceType_BinarySensor_3:
            return 260;
        case SFIDeviceType_MultiLevelOnOff_4:
            return 280;
        case SFIDeviceType_Thermostat_7:
            return 465;
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
        case SFIDeviceType_SmartDCSwitch_23:
            return 290;

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
    return self.deviceValue.knownDevicesValues;
}

#pragma mark - Picker methods

- (void)setPickerRow:(SFIDevicePropertyType)propertyType picker:(V8HorizontalPickerView *)picker {
    // Initialize the slider value
    NSInteger row = [self getSelectedIndex:propertyType];
    [picker scrollToElement:row animated:NO];
}

// converts the known value into an picker view element index
- (NSInteger)getSelectedIndex:(SFIDevicePropertyType)propertyType {
    NSString *val = [self.deviceValue valueForProperty:propertyType];
    if (!val) {
        return 0;
    }

    NSInteger temp = val.intValue;

    if (temp < TEMP_LOWEST_SETTABLE) {
        temp = TEMP_LOWEST_SETTABLE;
    }
    else if (temp > TEMP_HIGHEST_SETTABLE) {
        temp = TEMP_HIGHEST_SETTABLE;
    }

    return temp - TEMP_LOWEST_SETTABLE;
}

- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    return PICKER_ELEMENT_WIDTH;
}

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    return TEMP_HIGHEST_SETTABLE - TEMP_LOWEST_SETTABLE;
}

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    index = index + TEMP_LOWEST_SETTABLE;
    return [NSString stringWithFormat:@"%ld\u00B0", (long) index]; // U+00B0 == degree sign
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    SFIDevicePropertyType type = (SFIDevicePropertyType) picker.tag;
    NSInteger previousIndex = [self getSelectedIndex:type];

    if (previousIndex == index) {
        // no change to process
        // note this delegate is called when the initial value is set at time of UI set up; so we have to be careful
        // to trap this no-op state to prevent unnecessary updates being sent to the cloud
        return;
    }

    NSInteger temp = index + TEMP_LOWEST_SETTABLE;
    NSString *value = [NSString stringWithFormat:@"%ld", (long) temp];
    [self.delegate sensorDetailViewDidChangeSensorValue:self propertyType:type newValue:value];
}

@end