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
#import "SFICopyLabel.h"
#import "UIFont+Securifi.h"


#define TEMP_PICKER_ELEMENT_WIDTH 40
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

    if (self.layoutCalled) {
        return;
    }
    self.layoutCalled = YES;

    self.backgroundColor = self.color;

    NSUInteger rowHeight = [SFISensorDetailView computeSensorRowHeight:self.device expandedCell:YES];
    self.frame = CGRectMake(10, 86, (LEFT_LABEL_WIDTH) + (self.frame.size.width - LEFT_LABEL_WIDTH - 25) + 1, rowHeight - SENSOR_ROW_HEIGHT);

    // Add standard offset from top-level
    [self markYOffset:30];

    // Try adding tamper switch. Only some devices support it.
    [self tryAddTamper];

    // Customized per device
    [self layoutDeviceSettings];

    // Settings common to all sensors
    [self addSensorLabel];
    [self addShortLine];
    [self addDisplayNameField];
    [self addShortLine];
    [self addDeviceLocationField];
    [self addShortLine];
    [self markYOffset:5];
    [self addSaveButton];
}

- (void)layoutDeviceSettings {
    switch (self.device.deviceType) {
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
            [self configureDoorLock_5];
            break;
        }
        case SFIDeviceType_Thermostat_7: {
            [self configureThermostat_7];
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

        case SFIDeviceType_UnknownDevice_0:
        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_Alarm_6:
        case SFIDeviceType_Controller_8:;
        case SFIDeviceType_SceneController_9:;
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
            // nothing to do
            break;
        }
    }
}

// Adds a tamper message and dismiss button when needed; otherwise, does nothing; advances the y-offset
- (void)tryAddTamper {
    if (self.device.isTampered) {
        [self addTamperButton];
        [self addLine];
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
    [self.firstResponderField resignFirstResponder];
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

- (void)onSavePinCodeChanges:(id)sender {
    [self.firstResponderField resignFirstResponder];

    UITextField *field = [self textFieldForTag:SFIDevicePropertyType_USER_CODE];
    NSUInteger length = field.text.length;
    BOOL validated = (length >= 5 && length <= 8);


    if (validated) {
        NSString *value = field.text;

        V8HorizontalPickerView *picker = [self pickerViewForTag:SFIDevicePropertyType_USER_CODE];
        NSString *propertyName = [self makePinCodeDevicePropertyValueName:picker.currentSelectedIndex + 1];

        [self.delegate sensorDetailViewDidChangeSensorValue:self propertyName:propertyName newValue:value];
    }
    else {
        [self.delegate sensorDetailViewDidRejectSensorValue:self validationToast:@"PassCode must be 5 to 8 digits long"];
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.delegate sensorDetailViewWillStartMakingChanges:self];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField selectAll:self];
    self.firstResponderField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.firstResponderField == textField) {
        self.firstResponderField = nil;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.delegate sensorDetailViewWillCancelMakingChanges:self];
    return YES;
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

    UIFont *heavy_font = [UIFont securifiBoldFont];

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
    UIFont *heavy_font = [UIFont securifiBoldFont];

    UILabel *label;
    label = [[UILabel alloc] initWithFrame:[self makeFieldNameLabelRect:100]];
    label.backgroundColor = [UIColor clearColor];
    label.text = fieldName;
    label.textColor = [UIColor whiteColor];
    label.font = heavy_font;

    [self addSubview:label];
}

- (void)addSaveButton {
    SFIHighlightedButton *button = [self addButton:@"Save"];
    [button addTarget:self action:@selector(onSaveSensorNameLocationChanges:) forControlEvents:UIControlEventTouchUpInside];
}

- (SFIHighlightedButton *)addButton:(NSString *)buttonName {
    UIFont *heavy_font = [UIFont securifiBoldFontLarge];
    CGSize stringBoundingBox = [buttonName sizeWithAttributes:@{NSFontAttributeName : heavy_font}];

    int button_width = (int) (stringBoundingBox.width + 20);
    if (button_width < 60) {
        button_width = 60;
    }

    int right_margin = 10;
    CGRect frame = CGRectMake(self.frame.size.width - button_width - right_margin, self.baseYCoordinate, button_width, 30);

    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *normalColor = self.color;
    UIColor *highlightColor = whiteColor;

    SFIHighlightedButton *button = [[SFIHighlightedButton alloc] initWithFrame:frame];
    button.tag = self.tag;
    button.normalBackgroundColor = normalColor;
    button.highlightedBackgroundColor = highlightColor;
    button.titleLabel.font = heavy_font;
    [button setTitle:buttonName forState:UIControlStateNormal];
    [button setTitleColor:whiteColor forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateHighlighted];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = whiteColor.CGColor;

    [self addSubview:button];

    return button;
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
    label.font = [UIFont securifiBoldFont];
    label.frame = CGRectMake(10, self.baseYCoordinate - 5, 299, 30);
    label.text = [NSString stringWithFormat:@"SENSOR SETTINGS"];
    [self addSubview:label];
    [self markYOffset:25];
}

- (void)addTamperButton {
    UIFont *heavy_font = [UIFont securifiBoldFont];

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
    [self markYOffset:40];
}

- (void)addLine {
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.baseYCoordinate, self.frame.size.width - 15, 1)];
    imgLine.image = [UIImage imageNamed:@"line.png"];
    imgLine.alpha = 0.6;
    [self addSubview:imgLine];
    [self markYOffset:5];
}

- (void)addShortLine {
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.baseYCoordinate, self.frame.size.width - 20, 1)];
    imgLine.image = [UIImage imageNamed:@"line.png"];
    imgLine.alpha = 0.3;
    [self addSubview:imgLine];
    [self markYOffset:5];
}

- (UISlider *)makeSliderWithMinValue:(float)minVal maxValue:(float)maxValue propertyType:(SFIDevicePropertyType)propertyType {
    // Set the height high enough to ensure touch events are not missed.
    const CGFloat slider_height = 25.0;

    //Display slider
    CGRect frame = CGRectMake(40.0, self.baseYCoordinate, (self.frame.size.width - 90), slider_height);
    SFISlider *slider = [[SFISlider alloc] initWithFrame:frame];
    slider.tag = self.tag;
    slider.propertyType = propertyType;
    slider.minimumValue = minVal;
    slider.maximumValue = maxValue;
    slider.popUpViewColor = [self.color complementaryColor];
    slider.textColor = [slider.popUpViewColor blackOrWhiteContrastingColor];
    slider.font = [UIFont securifiBoldFont:22];
    [slider addTarget:self action:@selector(onSliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    //
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    formatter.multiplier = @(1); // don't multiply numbers by 100
    slider.numberFormatter = formatter;
    slider.maxFractionDigitsDisplayed = 0;
    //
    UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSliderTapped:)];
    [slider addGestureRecognizer:tapSlider];

    [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateHighlighted];
    [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"] forState:UIControlStateNormal];

    // Initialize the slider value
    SFIDeviceKnownValues *currentDeviceValue = [self.deviceValue knownValuesForProperty:propertyType];
    float sliderValue = [currentDeviceValue floatValue];
    [slider setValue:sliderValue animated:NO];

    return slider;
}

- (void)addStatusLabel:(NSArray *)statusMessages {
    UIFont *const heavy_12 = [UIFont securifiBoldFont];
    UIColor *const white_color = [UIColor whiteColor];
    UIColor *const clear_color = [UIColor clearColor];

    // Status
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate, 60, 30)];
    statusLabel.textColor = white_color;
    statusLabel.text = @"Status";
    statusLabel.font = heavy_12;
    [self addSubview:statusLabel];

    // Messages
    SFICopyLabel *valueLabel = [[SFICopyLabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 230, self.baseYCoordinate, 220, 50)];
    valueLabel.userInteractionEnabled = YES; // allow user to copy value
    valueLabel.textColor = white_color;
    valueLabel.backgroundColor = clear_color;
    valueLabel.font = heavy_12;
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.numberOfLines = statusMessages.count;
    [self addSubview:valueLabel];

    valueLabel.text = [statusMessages componentsJoinedByString:@"\n"];
}

- (void)addHorizontalPicker:(NSString *)labelText propertyType:(SFIDevicePropertyType)propertyType selectionPointMiddle:(BOOL)yesOrLeftSelection {
    UIFont *const heavy_12 = [UIFont securifiBoldFont];
    UIFont *const heavy_16 = [UIFont standardHeadingBoldFont];

    const int control_height = 40;

    // Set Point label
    UILabel *setPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, self.baseYCoordinate, 60, control_height)];
    setPointLabel.textColor = [UIColor whiteColor];
    setPointLabel.font = heavy_12;
    setPointLabel.text = labelText;
    [self addSubview:setPointLabel];

    UIColor *const contrastingColor = [self.color blackOrWhiteContrastingColor];

    // Picker
    V8HorizontalPickerView *picker = [[V8HorizontalPickerView alloc] initWithFrame:CGRectZero];
    picker.tag = propertyType; // we stored the type of property in the tag info; will use in delegate methods and callbacks
    picker.frame = CGRectMake(70.0, self.baseYCoordinate, self.frame.size.width - 80, control_height);
    picker.layer.cornerRadius = 4;
    picker.layer.borderWidth = 1.0;
    picker.layer.borderColor = [UIColor whiteColor].CGColor;
    picker.backgroundColor = [UIColor clearColor];
    picker.selectedTextColor = contrastingColor;
    picker.elementFont = heavy_16;
    picker.textColor = [UIColor whiteColor];
    picker.indicatorPosition = V8HorizontalPickerIndicatorBottom;
    picker.delegate = self;
    picker.dataSource = self;

    // width depends on propertyType
    const NSInteger element_width = [self horizontalPickerView:picker widthForElementAtIndex:0];

    if (yesOrLeftSelection) {
        picker.selectionPoint = CGPointMake((picker.frame.size.width) / 2, 0);   // middle of picker
    }
    else {
        picker.selectionPoint = CGPointMake(element_width / 2, 0);   // left end of picker
    }

    SFIPickerIndicatorView *indicatorView = [[SFIPickerIndicatorView alloc] initWithFrame:CGRectMake(0, 0, element_width, 2)];
    indicatorView.color = contrastingColor;
    picker.selectionIndicatorView = indicatorView;

    [self addSubview:picker];
    [self setPickerSelection:picker propertyType:propertyType];

    [self markYOffset:control_height + 10];
}

#pragma mark - Sensor layouts

- (void)configureMultiLevelSwitchMinValue:(int)minValue maxValue:(int)maxValue {
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

    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.text = batteryStatus;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont securifiBoldFont];
    label.frame = CGRectMake(10, self.baseYCoordinate, 299, 30);
    [self addSubview:label];

    [self markYOffset:25];;
    [self addLine];
}

- (void)configureDoorLock_5 {
    int maxUsers = [self maximumPinCodes];
    if (maxUsers <= 0) {
        // nothing to do
        return;
    }

    [self addHorizontalPicker:@"Pins" propertyType:SFIDevicePropertyType_USER_CODE selectionPointMiddle:NO];
    [self addShortLine];

    UITextField *field = [self addFieldNameValue:@"Code" fieldValue:@""];
    field.tag = SFIDevicePropertyType_USER_CODE;
    field.keyboardType = UIKeyboardTypeNumberPad;
    //
    NSDictionary *textAttributes = @{
            NSForegroundColorAttributeName : [[UIColor whiteColor] colorWithAlphaComponent:0.5],
            NSFontAttributeName : [field.font fontWithSize:10],
    };
    field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Code is not specified." attributes:textAttributes];

    [self setPinCodeTextField:1]; // preset the text field for first pin

    [self markYOffset:5];
    [self addShortLine];
    [self markYOffset:5];

    SFIHighlightedButton *button = [self addButton:@"Save Pin"];
    button.tag = SFIDevicePropertyType_USER_CODE;
    [button addTarget:self action:@selector(onSavePinCodeChanges:) forControlEvents:UIControlEventTouchUpInside];

    [self markYOffset:40];
    [self addLine];
    [self markYOffset:5];
}

- (void)configureThermostat_7 {
    // Temp selectors
    [self addHorizontalPicker:@"Heating" propertyType:SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING selectionPointMiddle:YES];
    [self addHorizontalPicker:@"Cooling" propertyType:SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING selectionPointMiddle:YES];
    [self addLine];
    [self markYOffset:5];

    UIFont *const heavy_12 = [UIFont securifiBoldFont];
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
    modeSegmentControl.frame = CGRectMake(90.0, self.baseYCoordinate, self.frame.size.width - 100, 25.0);
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

- (void)configureElectricMeasurementSwitch_22 {
    SFIDeviceValue *deviceValue = self.deviceValue;

    unsigned int acCurrentDivisor = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_CURRENTDIVISOR] hexToIntValue];
    unsigned int acCurrentMultiplier = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_CURRENTMULTIPLIER] hexToIntValue];
    unsigned int acPowerDivisor = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_POWERDIVISOR] hexToIntValue];
    unsigned int acPowerMultiplier = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_POWERMULTIPLIER] hexToIntValue];
    unsigned int acVoltageMultiplier = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_VOLTAGEMULTIPLIER] hexToIntValue];
    unsigned int acVoltageDivisor = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_AC_VOLTAGEDIVISOR] hexToIntValue];
    unsigned int activePower = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_ACTIVE_POWER] hexToIntValue];
    unsigned int rmsCurrent = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_RMS_CURRENT] hexToIntValue];
    unsigned int rmsVoltage = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_RMS_VOLTAGE] hexToIntValue];

    float power = (float) activePower * acPowerMultiplier / acPowerDivisor;
    float voltage = (float) rmsVoltage * acVoltageMultiplier / acVoltageDivisor;
    float current = (float) rmsCurrent * acCurrentMultiplier / acCurrentDivisor;

    NSString *power_str = [NSString stringWithFormat:@"Power is %.3fW", power];
    NSString *current_str = [NSString stringWithFormat:@"Current is %.3fA", current];
    NSString *voltage_str = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];

    [self addStatusLabel:@[power_str, current_str, voltage_str]];
    [self markYOffset:55];
    [self addLine];
}

- (void)configureElectricMeasurementSwitch_23 {
    SFIDeviceValue *deviceValue = self.deviceValue;

    unsigned int dcCurrent = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_DC_CURRENT] hexToIntValue];
    unsigned int dcCurrentDivisor = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_DC_CURRENTDIVISOR] hexToIntValue];
    unsigned int dcCurrentMultiplier = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_DC_CURRENTMULTIPLIER] hexToIntValue];
    unsigned int dcPower = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_DC_POWER] hexToIntValue];
    unsigned int dcPowerDivisor = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_DC_POWERDIVISOR] hexToIntValue];
    unsigned int dcPowerMultiplier = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_DC_POWERMULTIPLIER] hexToIntValue];
    unsigned int dcVoltage = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_DC_VOLTAGE] hexToIntValue];
    unsigned int dcVoltageDivisor = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_DC_VOLTAGEDIVISOR] hexToIntValue];
    unsigned int dcVoltageMultiplier = [[deviceValue knownValuesForProperty:SFIDevicePropertyType_DC_VOLTAGEMULTIPLIER] hexToIntValue];

    float power = (float) dcPower * dcPowerMultiplier / dcPowerDivisor;
    float voltage = (float) dcVoltage * dcVoltageMultiplier / dcVoltageDivisor;
    float current = (float) dcCurrent * dcCurrentMultiplier / dcCurrentDivisor;

    NSString *power_str = [NSString stringWithFormat:@"Power is %.3fW", power];
    NSString *current_str = [NSString stringWithFormat:@"Current is %.3fA", current];
    NSString *voltage_str = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];

    [self addStatusLabel:@[power_str, current_str, voltage_str]];
    [self markYOffset:55];
    [self addLine];
}

#pragma mark - Door Lock Pin Code helpers

- (int)maximumPinCodes {
    SFIDeviceKnownValues *values = [self.deviceValue knownValuesForProperty:SFIDevicePropertyType_MAXIMUM_USERS];
    int maxUsers = [values intValue];
    return maxUsers;
}

- (NSString *)pingCodeValue:(NSInteger)pinIndex {
    NSString *valueName = [self makePinCodeDevicePropertyValueName:pinIndex];

    SFIDeviceKnownValues *values = [self.deviceValue knownValuesForPropertyName:valueName];
    if (!values) {
        return @"";
    }
    return values.value;
}

- (NSString *)makePinCodeDevicePropertyValueName:(NSInteger)pinIndex {
    NSString *valueName = [SFIDeviceKnownValues propertyTypeToName:SFIDevicePropertyType_USER_CODE];
    valueName = [NSString stringWithFormat:@"%@_%d", valueName, pinIndex];
    return valueName;
}

#pragma mark - Helpers

+ (NSUInteger)computeSensorRowHeight:(SFIDevice *)currentSensor expandedCell:(BOOL)isExpanded {
    if (!isExpanded) {
        return SENSOR_ROW_HEIGHT;
    }

    NSUInteger tamperedExtra = currentSensor.isTampered ? 45 : 0; // accounts for the row presenting the tampered msg and dismiss button

    switch (currentSensor.deviceType) {
        case SFIDeviceType_MultiLevelSwitch_2:
            return 275 + tamperedExtra;

        case SFIDeviceType_BinarySensor_3:
            return 260 + tamperedExtra;

        case SFIDeviceType_MultiLevelOnOff_4:
            return 280 + tamperedExtra;

        case SFIDeviceType_DoorLock_5:
            return 380 + tamperedExtra;

        case SFIDeviceType_Thermostat_7:
            return 490 + tamperedExtra;

        case SFIDeviceType_SmartACSwitch_22:
        case SFIDeviceType_SmartDCSwitch_23:
            return 290 + tamperedExtra;

        case SFIDeviceType_UnknownDevice_0:
        case SFIDeviceType_BinarySwitch_1:
        case SFIDeviceType_Alarm_6:
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
            return EXPANDED_ROW_HEIGHT + tamperedExtra;
    }
}

#pragma mark - Picker methods

- (void)setPickerSelection:(V8HorizontalPickerView *)picker propertyType:(SFIDevicePropertyType)propertyType {
    // Initialize the slider value
    NSInteger row = [self getPickerViewSelectedIndex:propertyType];
    [picker scrollToElement:row animated:NO];
}

// converts the known value into an picker view element index
- (NSInteger)getPickerViewSelectedIndex:(SFIDevicePropertyType)propertyType {
    switch (propertyType) {
        case SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING:
        case SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING: {
            // thermostat
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

        case SFIDevicePropertyType_USER_CODE: {
            // door lock 5

        }

        default: {
            return 0;
        }
    }
}

- (NSInteger)horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
    SFIDevicePropertyType propertyType = (SFIDevicePropertyType) picker.tag;

    switch (propertyType) {
        case SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING:
        case SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING: {
            // thermostat
            return TEMP_PICKER_ELEMENT_WIDTH;
        }

        case SFIDevicePropertyType_USER_CODE: {
            // door lock 5
            return 60;
        }

        default: {
            return 0;
        }
    }
}

- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
    SFIDevicePropertyType propertyType = (SFIDevicePropertyType) picker.tag;

    switch (propertyType) {
        case SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING:
        case SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING: {
            // thermostat
            return TEMP_HIGHEST_SETTABLE - TEMP_LOWEST_SETTABLE;
        }

        case SFIDevicePropertyType_USER_CODE: {
            // door lock 5
            int maxUsers = [self maximumPinCodes];
            if (maxUsers < 0) {
                maxUsers = 0;
            }
            return maxUsers;
        }

        default: {
            return 0;
        }
    }

}

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
    SFIDevicePropertyType propertyType = (SFIDevicePropertyType) picker.tag;

    switch (propertyType) {
        case SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING:
        case SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING: {
            // thermostat
            index = index + TEMP_LOWEST_SETTABLE;
            return [NSString stringWithFormat:@"%ld\u00B0", (long) index]; // U+00B0 == degree sign
        }

        case SFIDevicePropertyType_USER_CODE: {
            // door lock 5
            NSInteger row = index + 1;
            return [NSString stringWithFormat:@"Pin %ld", (long) row];
        }

        default: {
            return @"";
        }
    }
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    SFIDevicePropertyType propertyType = (SFIDevicePropertyType) picker.tag;

    switch (propertyType) {
        case SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING:
        case SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING: {
            // thermostat
            NSInteger previousIndex = [self getPickerViewSelectedIndex:propertyType];

            if (previousIndex == index) {
                // no change to process
                // note this delegate is called when the initial value is set at time of UI set up; so we have to be careful
                // to trap this no-op state to prevent unnecessary updates being sent to the cloud
                return;
            }

            NSInteger temp = index + TEMP_LOWEST_SETTABLE;
            NSString *value = [NSString stringWithFormat:@"%ld", (long) temp];
            [self.delegate sensorDetailViewDidChangeSensorValue:self propertyType:propertyType newValue:value];

            return;
        }

        case SFIDevicePropertyType_USER_CODE: {
            // door lock 5
            [self setPinCodeTextField:index + 1];

            return;
        }

        default: {
            return;
        }
    }
}

- (void)setPinCodeTextField:(NSInteger)index {
    NSString *value = [self pingCodeValue:index];
    UITextField *field = [self textFieldForTag:SFIDevicePropertyType_USER_CODE];
    field.text = value;
}

- (UITextField *)textFieldForTag:(NSInteger)tag {
    for (UIView *view in self.subviews) {
        if (view.tag == tag) {
            if ([view isKindOfClass:[UITextField class]]) {
                UITextField *field = (UITextField *) view;
                return field;
            }
        }
    }
    return nil;
}

- (V8HorizontalPickerView *)pickerViewForTag:(NSInteger)tag {
    for (UIView *view in self.subviews) {
        if (view.tag == tag) {
            if ([view isKindOfClass:[V8HorizontalPickerView class]]) {
                V8HorizontalPickerView *picker = (V8HorizontalPickerView *) view;
                return picker;
            }
        }
    }

    return nil;
}

@end