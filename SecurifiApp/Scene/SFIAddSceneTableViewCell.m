//
//  SFIAddSceneTableViewCell.h
//
//  Created by tigran on 6/6/15.
//
#import "SFIAddSceneTableViewCell.h"
#import "SFIConstants.h"
#import "SFISensorDetailView.h"
#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"
#import "UIFont+Securifi.h"
#import "SFIDeviceIndex.h"
#import "SFISwitchButton.h"
#import "SFIDimmerButton.h"
#import "SFIHuePickerView.h"
#import "SFISlider.h"
#import "UIColor+Securifi.h"
#import "NPColorPickerView.h"

#define DEF_COULD_NOT_UPDATE_SENSOR @"Could not update sensor\ndata."

@interface SFIAddSceneTableViewCell () <SFISensorDetailViewDelegate,ILHuePickerViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,NPColorPickerViewDelegate>{
    IBOutlet UIView *viewDim;
    IBOutlet UIView *viewSwitchOnOff;
    
    IBOutlet UIView *viewAutoHeatCoolOff;
    //
    IBOutlet SFISwitchButton *btnAuto;
    IBOutlet SFISwitchButton *btnHeat;
    IBOutlet SFISwitchButton *btnCool;
    IBOutlet SFISwitchButton *btnOff;
    
    IBOutlet SFIDimmerButton *btnTermostatDimCool;
    IBOutlet SFIDimmerButton *btnTermostatDimHeat;
    IBOutlet SFISwitchButton *btnTermostatFanOn;
    IBOutlet SFISwitchButton *btnTermostatFanOff;
    
    SFIDimmerButton * currentDimmerButton;
    //
    IBOutlet UIView *viewPropertiesCell;
    IBOutlet UIView *viewSlider;
    IBOutlet SFIHuePickerView *huePicker;
    //
    IBOutlet SFISwitchButton *btnBinarySwitchOn;
    IBOutlet SFISwitchButton *btnBinarySwitchOff;
    //
    
    IBOutlet SFIDimmerButton *btnDim;
    IBOutlet SFISwitchButton *btnDimOn;
    IBOutlet SFISwitchButton *btnDimOff;
    
    float baseYCoordinate;
    
    IBOutlet UITextField *txtName;
    IBOutlet UITextField *txtDescription;
    NSMutableArray * pickerValuesArray;
    UIView * actionSheet;
    IBOutlet UIButton *btnDelete;
    
    //
    IBOutlet UIView *viewStandardWarningDevice_21;
    IBOutlet UITextField *txtTimer;
    IBOutlet SFISwitchButton *btnStandardWarningDeviceOff;
    IBOutlet SFISwitchButton *btnStandardWarningDeviceOn;
    
    IBOutlet UIView *sliderViewBrightness;
    IBOutlet NPColorPickerView *hueColorPickerView;
}

@property(nonatomic) UIImageView *deviceImageView;
@property(nonatomic) UIImageView *deviceImageViewSecondary;
@property(nonatomic) UILabel *deviceStatusLabel;
@property(nonatomic) UILabel *deviceValueLabel;

@property(nonatomic) SFISensorDetailView *detailView;

// For thermostat
@property(nonatomic) UILabel *decimalValueLabel;
@property(nonatomic) UILabel *degreeLabel;

@property(nonatomic) BOOL dirty;
@property(nonatomic) BOOL updatingState;

@property (strong, nonatomic) IBOutlet UILabel *lblName;

@end

@implementation SFIAddSceneTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.deviceValue = [SFIDeviceValue new]; // ensure no null pointers; layout code assumes there exists a Device Value that returns answers
    }
    
    return self;
}

- (void)markWillReuseCell:(BOOL)updating {
    self.dirty = YES;
    self.updatingState = updating;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //    if (self.dirty) {
    //        self.dirty = NO;
    //
    //        [self tearDown];
    //        [self layoutTileFrame];
    //        [self layoutDeviceImageCell];
    //
    //        if (self.updatingState) {
    //            [self setUpdatingSensorStatus];
    //        }
    //        else {
    //            [self layoutDeviceInfo];
    //        }
    viewPropertiesCell.hidden = YES;
    viewAutoHeatCoolOff.hidden = YES;
    viewStandardWarningDevice_21.hidden = YES;
    viewDim.hidden = YES;
    viewSwitchOnOff.hidden = YES;
    huePicker.hidden = YES;
    viewSlider.hidden = YES;
    sliderViewBrightness.hidden = YES;
    
    
    if (self.isSceneProperiesCell) {
        viewPropertiesCell.hidden = NO;
        CGRect fr = viewPropertiesCell.frame;
        fr.origin.y = 0;
        fr.origin.x = (self.frame.size.width - fr.size.width)/2;
        viewPropertiesCell.frame = fr;
        txtName.text = self.sceneName;
        [txtName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:
         UIControlEventEditingChanged];
        if (!self.showDeleteButton) {
            btnDelete.hidden = YES;
        }
        return;
    }
    self.lblName.text = self.device.deviceName;
    
    for (SFISlider *sl in viewSlider.subviews) {
        if ([sl isKindOfClass:[SFISlider class]]) {
            [sl removeFromSuperview];
        }
    }
    for (SFISlider *sl in sliderViewBrightness.subviews) {
        if ([sl isKindOfClass:[SFISlider class]]) {
            [sl removeFromSuperview];
        }
    }
    
    
    
    if (self.device.deviceType == SFIDeviceType_StandardWarningDevice_21) {
        [self layoutStandardWarningDevice_21];
        return;
    }
    
    if (self.device.deviceType == SFIDeviceType_Thermostat_7) {
        [self layoutThermostat_7];
        return;
    }
    
    
    float curr_y = self.lblName.frame.size.height + self.lblName.frame.origin.y;
    
    NSArray * deviceIndexesArray = [self.cellInfo valueForKey:@"deviceIndexes"];
    
    for (NSDictionary *dict in deviceIndexesArray) {
        NSInteger valueType = [[dict valueForKey:@"valueType"] integerValue];
        switch (valueType) {
            case SFIDevicePropertyType_SWITCH_BINARY:
            case SFIDevicePropertyType_BASIC:
            case SFIDevicePropertyType_ALARM_STATE:
            case SFIDevicePropertyType_SENSOR_BINARY:
            case SFIDevicePropertyType_LOCK_STATE:
            {
                btnBinarySwitchOff.tag = [[dict valueForKey:@"indexID"] integerValue];
                btnBinarySwitchOn.tag = [[dict valueForKey:@"indexID"] integerValue];
                btnBinarySwitchOff.selected = NO;
                btnBinarySwitchOn.selected = NO;
                viewSwitchOnOff.hidden = NO;
                CGRect fr = viewSwitchOnOff.frame;
                fr.origin.y = curr_y;
                fr.origin.x = (self.frame.size.width - fr.size.width)/2;
                viewSwitchOnOff.frame = fr;
                curr_y+=viewSwitchOnOff.frame.size.height;
                
                [btnBinarySwitchOff setupValues:[UIImage imageNamed:[dict valueForKey:@"offImage"]] Title:[dict valueForKey:@"offTitle"]];
                [btnBinarySwitchOn setupValues:[UIImage imageNamed:[dict valueForKey:@"onImage"]] Title:[dict valueForKey:@"onTitle"]];
                NSArray *existingValues = [self.cellInfo valueForKey:@"existingValues"];
                if (existingValues.count>0) {
                    if ([[existingValues[0] valueForKey:@"Value"] boolValue]) {
                        btnBinarySwitchOn.selected = YES;
                        btnBinarySwitchOff.selected = NO;
                    }else{
                        btnBinarySwitchOn.selected = NO;
                        btnBinarySwitchOff.selected = YES;
                    }
                }
                break;
            }
            case SFIDevicePropertyType_SWITCH_MULTILEVEL:
            {
                viewDim.hidden = NO;
                CGRect fr = viewDim.frame;
                fr.origin.y = curr_y;
                fr.origin.x = (self.frame.size.width - fr.size.width)/2;
                viewDim.frame = fr;
                curr_y+=viewDim.frame.size.height;
                
                
                btnDimOn.dimOnValue = [dict valueForKey:@"onValue"];
                btnDimOff.dimOffValue = [dict valueForKey:@"offValue"];
                
                
                [btnDimOn setupValues:[UIImage imageNamed:[dict valueForKey:@"onImage"]] Title:[dict valueForKey:@"onTitle"]];
                
                [btnDimOff setupValues:[UIImage imageNamed:[dict valueForKey:@"offImage"]] Title:[dict valueForKey:@"offTitle"]];
                
                [btnDim setupValues:@"0" Title:@"DIM" Prefix:[dict valueForKey:@"dimPrefix"]];
                
                btnDimOn.tag = [[dict valueForKey:@"onIndex"] integerValue];
                btnDimOff.tag = [[dict valueForKey:@"offIndex"] integerValue];
                btnDim.tag = [[dict valueForKey:@"dimIndex"] integerValue];
                btnDimOn.selected = NO;
                btnDimOff.selected = NO;
                btnDim.selected = NO;
                
                NSArray *existingValues = [self.cellInfo valueForKey:@"existingValues"];
                if (existingValues.count>0) {
                    if (self.device.deviceType==SFIDeviceType_MultiLevelSwitch_2) {
                        if ([[existingValues[0] valueForKey:@"Value"] integerValue]!=0) {
                            btnDimOn.selected = YES;
                            btnDimOff.selected = NO;
                            btnDim.selected = YES;
                            NSString * val =[existingValues[0] valueForKey:@"Value"] ;
                            
                            [btnDim setNewValue:val];
                        }else{
                            btnDimOn.selected = NO;
                            btnDimOff.selected = YES;
                            btnDim.selected = NO;
                            [btnDim setNewValue:@"0"];
                        }
                    }else{
                        for (NSDictionary *dict in existingValues) {
                            if ([[dict valueForKey:@"Index"] integerValue] == btnDim.tag) {
                                [btnDim setNewValue:[dict valueForKey:@"Value"]];
                                btnDim.selected = YES;
                            }
                            if ([[dict valueForKey:@"Index"] integerValue] == btnDimOn.tag) {
                                if ([[dict valueForKey:@"Value"] integerValue]==0) {
                                    btnDimOn.selected = NO;
                                    btnDimOff.selected = YES;
                                }else{
                                    btnDimOn.selected = YES;
                                    btnDimOff.selected = NO;
                                }
                            }
                        }
                    }
                    
                }
                
                break;
            }
            case SFIDevicePropertyType_COLOR_HUE:
            {
                /*
                [hueColorPickerView setBackgroundColor: [UIColor whiteColor]];
                hueColorPickerView.hidden = NO;
                const float hue = [[self.deviceValue knownValuesForProperty:SFIDevicePropertyType_COLOR_HUE] floatValue];
                
                int picker_height = 320;
                CGRect picker_frame = CGRectMake((CGRectGetWidth(self.bounds)-picker_height)/2,curr_y,picker_height , picker_height);
                
                hueColorPickerView.tag = [[dict valueForKey:@"indexID"] integerValue];
                hueColorPickerView.frame = picker_frame;
                hueColorPickerView.delegate = self;
                
                curr_y+=320;
                
                NSArray *existingValues = [self.cellInfo valueForKey:@"existingValues"];
                if (existingValues.count>0) {
                    
                    for (NSDictionary *dict in existingValues) {
                        if ([[dict valueForKey:@"Index"] integerValue] == huePicker.tag) {
                            const float sensorValue = [[dict valueForKey:@"Value"] floatValue];
                            //                            [hueColorPickerView setConvertedValue:sensorValue];
                        }
                    }
                }
                break;
               */
                 huePicker.hidden = NO;
                 const float hue = [[self.deviceValue knownValuesForProperty:SFIDevicePropertyType_COLOR_HUE] floatValue];
                 
                 int picker_height = 100;
                 CGRect picker_frame = CGRectMake(0,curr_y, CGRectGetWidth(self.bounds), picker_height);
                 
                 // Display hue picker
                 //                {
                 //                    SFIHuePickerView *huePicker = [[SFIHuePickerView alloc] initWithFrame:picker_frame];
                 huePicker.tag = [[dict valueForKey:@"indexID"] integerValue];
                 huePicker.frame = picker_frame;
                 huePicker.convertedValue = hue;
                 huePicker.propertyType = SFIDevicePropertyType_COLOR_HUE;
                 huePicker.delegate = self;
                 //                    [self addSubview:huePicker];
                 //                    [self markYOffsetUsingRect:picker_frame addAdditional:0];
                 //
                 //                    [self placeNameLabel:NSLocalizedString(@"sensors.label.Color", @"Color") valueLabel:[[huePicker.color hexString] uppercaseString]];
                 //                }
                 curr_y+=100;
                 
                 NSArray *existingValues = [self.cellInfo valueForKey:@"existingValues"];
                 if (existingValues.count>0) {
                 
                 for (NSDictionary *dict in existingValues) {
                 if ([[dict valueForKey:@"Index"] integerValue] == huePicker.tag) {
                 const float sensorValue = [[dict valueForKey:@"Value"] floatValue];
                 [huePicker setConvertedValue:sensorValue];
                 }
                 }
                 }
                 break;
            }
            case SFIDevicePropertyType_SATURATION:
            {
                viewSlider.hidden = NO;
                CGRect fr = viewSlider.frame;
                fr.origin.y = curr_y;
                fr.origin.x = (self.frame.size.width - fr.size.width)/2;
                viewSlider.frame = fr;
                curr_y+=viewSlider.frame.size.height;
                
                baseYCoordinate = 37;
                const float saturation = [[self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SATURATION] floatValue];
                const CGFloat slider_x_offset = 10.0;
                const CGFloat slider_right_inset = 20.0;
                
                SFISlider *slider = [self makeSlider:0 maxValue:100 propertyType:SFIDevicePropertyType_SATURATION sliderLeftInset:slider_x_offset sliderRightInset:slider_right_inset];// SFISlider *saturation_slider
                slider.continuous = YES;
                slider.sensorMaxValue = 255;
                slider.convertedValue = saturation;
                [slider addTarget:self action:@selector(onHueLampColorPropertyIsChanging:) forControlEvents:(UIControlEventValueChanged)];
                [slider addTarget:self action:@selector(onColorPropertyDidChange:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                slider.tag =[[dict valueForKey:@"indexID"] integerValue];
                [viewSlider addSubview:slider];
                //                [self markYOffset:20];
                
                //                [self placeNameLabel:@"Saturation" valueLabel:saturation_slider.sliderFormattedValue];
                NSArray *existingValues = [self.cellInfo valueForKey:@"existingValues"];
                if (existingValues.count>0) {
                    
                    for (NSDictionary *dict in existingValues) {
                        if ([[dict valueForKey:@"Index"] integerValue] == slider.tag) {
                            const float sensorValue = [[dict valueForKey:@"Value"] floatValue];
                            [slider setConvertedValue:sensorValue];
                        }
                    }
                }
                break;
            }
            case SFIDevicePropertyType_BRIGHTNESS:
            {
                sliderViewBrightness.hidden = NO;
                CGRect fr = viewSlider.frame;
                fr.origin.y = curr_y;
                fr.origin.x = (self.frame.size.width - fr.size.width)/2;
                sliderViewBrightness.frame = fr;
                curr_y+=sliderViewBrightness.frame.size.height;
                
                baseYCoordinate = 37;
                const float saturation = [[self.deviceValue knownValuesForProperty:SFIDevicePropertyType_BRIGHTNESS] floatValue];
                const CGFloat slider_x_offset = 10.0;
                const CGFloat slider_right_inset = 20.0;
                
                SFISlider *slider = [self makeSlider:0 maxValue:100 propertyType:SFIDevicePropertyType_BRIGHTNESS sliderLeftInset:slider_x_offset sliderRightInset:slider_right_inset];// SFISlider *saturation_slider
                slider.continuous = YES;
                slider.sensorMaxValue = 255;
                slider.convertedValue = saturation;
                [slider addTarget:self action:@selector(onHueLampColorPropertyIsChanging:) forControlEvents:(UIControlEventValueChanged)];
                [slider addTarget:self action:@selector(onColorPropertyDidChange:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                slider.tag =[[dict valueForKey:@"indexID"] integerValue];
                [sliderViewBrightness addSubview:slider];
                //                [self markYOffset:20];
                
                //                [self placeNameLabel:@"Saturation" valueLabel:saturation_slider.sliderFormattedValue];
                
                NSArray *existingValues = [self.cellInfo valueForKey:@"existingValues"];
                if (existingValues.count>0) {
                    
                    for (NSDictionary *dict in existingValues) {
                        if ([[dict valueForKey:@"Index"] integerValue] == slider.tag) {
                            const float sensorValue = [[dict valueForKey:@"Value"] floatValue];
                            [slider setConvertedValue:sensorValue];
                        }
                    }
                }
                break;
            }
            default:
                break;
        }
    }
    
    
    
    //    for (SFIDeviceIndex *deviceIndex in deviceIndexes) {
    //        switch (deviceIndex.valueType) {
    //
    //
    //
    //
    //            case SFIDevicePropertyType_SATURATION:
    //            {
    //                baseYCoordinate = curr_y;
    //                const float saturation = [[self.deviceValue knownValuesForProperty:SFIDevicePropertyType_SATURATION] floatValue];
    //                const CGFloat slider_x_offset = 10.0;
    //                const CGFloat slider_right_inset = 20.0;
    //
    //                SFISlider *saturation_slider = [self makeSlider:0 maxValue:100 propertyType:SFIDevicePropertyType_SATURATION sliderLeftInset:slider_x_offset sliderRightInset:slider_right_inset];
    //                saturation_slider.continuous = YES;
    //                saturation_slider.sensorMaxValue = 255;
    //                saturation_slider.convertedValue = saturation;
    //                [saturation_slider addTarget:self action:@selector(onHueLampColorPropertyIsChanging:) forControlEvents:(UIControlEventValueChanged)];
    //                [saturation_slider addTarget:self action:@selector(onColorPropertyDidChange:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    //                [self addSubview:saturation_slider];
    //                //                [self markYOffset:20];
    //
    //                //                [self placeNameLabel:@"Saturation" valueLabel:saturation_slider.sliderFormattedValue];
    //                curr_y+=100;
    //            }
    //
    //                break;
    //            default:
    //                break;
    //        }
    //    }
    
    
    
    //        if (self.isExpandedView) {
    //            SFISensorDetailView *detailView = [SFISensorDetailView new];
    //            detailView.frame = self.frame;
    //            detailView.tag = self.tag;
    //            detailView.delegate = self;
    //            detailView.device = device;
    //            detailView.deviceValue = self.deviceValue;
    //            detailView.color = self.cellColor;
    //
    //            [self.contentView addSubview:detailView];
    //            self.detailView = detailView;
    //        }
    //
    //        if (self.updatingState) {
    //            self.deviceStatusLabel.text = self.updatingStatusMessage;
    //        }
    //        else {
    //            self.deviceStatusLabel.text = self.deviceStatusMessage;
    //        }
    //    }
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
    //    _deviceNameLabel = deviceNameLabel;
    
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
    
    // Set up the sensor icon views
    // There are two views composted on top of each other.
    // The main icon view is on the bottom, and a secondary view is available for
    // overlaying a second icon on top.
    CGRect imageView_frame = CGRectMake(LEFT_LABEL_WIDTH / 3, 12, 53, 70);
    //
    self.deviceImageView = [[UIImageView alloc] initWithFrame:imageView_frame];
    self.deviceImageView.userInteractionEnabled = YES;
    //
    [self.deviceImageView addSubview:deviceImageButton];
    deviceImageButton.frame = self.deviceImageView.bounds;
    [self.contentView addSubview:self.deviceImageView];
    //
    self.deviceImageViewSecondary = [[UIImageView alloc] initWithFrame:imageView_frame];
    [self.contentView addSubview:self.deviceImageViewSecondary];
}
//- (void)makeSlider:(float)minVal maxValue:(float)maxValue propertyType:(SFIDevicePropertyType)propertyType sliderLeftInset:(CGFloat)sliderLeftInset sliderRightInset:(CGFloat)sliderRightInset{
//    // Set the height high enough to ensure touch events are not missed.
//    const CGFloat slider_height = 100;//25.0;
//
//    //Display slider
//    CGFloat slider_width = CGRectGetWidth(self.bounds) - sliderRightInset;
//    CGRect slider_frame = CGRectMake(sliderLeftInset, slider.frame.origin.y, slider_width, slider_height);// instead 0
//
//    //    SFISlider *slider = [[SFISlider alloc] initWithFrame:slider_frame];
////    slider.frame = slider_frame;
//    slider.tag = self.tag;
//    slider.propertyType = propertyType;
//    slider.minimumValue = minVal;
//    slider.maximumValue = maxValue;
//    slider.popUpViewColor = [UIColor redColor];//[self.color complementaryColor];
//    slider.textColor = [UIColor redColor];//[slider.popUpViewColor blackOrWhiteContrastingColor];
//    slider.font = [UIFont securifiBoldFont:22];
//    [slider addTarget:self action:@selector(onSliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
//    //
//    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    formatter.numberStyle = NSNumberFormatterPercentStyle;
//    formatter.multiplier = @(1); // don't multiply numbers by 100
//    slider.numberFormatter = formatter;
//    slider.maxFractionDigitsDisplayed = 0;
//    //
//    UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSliderTapped:)];
//    [slider addGestureRecognizer:tapSlider];
//
//    [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateNormal];
//    [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateHighlighted];
//    [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"] forState:UIControlStateNormal];
//    [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"] forState:UIControlStateNormal];
//}

- (SFISlider *)makeSlider:(float)minVal maxValue:(float)maxValue propertyType:(SFIDevicePropertyType)propertyType sliderLeftInset:(CGFloat)sliderLeftInset sliderRightInset:(CGFloat)sliderRightInset {
    // Set the height high enough to ensure touch events are not missed.
    const CGFloat slider_height = 25.0;
    
    //Display slider
    CGFloat slider_width = CGRectGetWidth(self.bounds) - sliderRightInset;
    CGRect slider_frame = CGRectMake(sliderLeftInset, baseYCoordinate, slider_width, slider_height);// instead 0
    
    SFISlider *slider = [[SFISlider alloc] initWithFrame:slider_frame];
    slider.tag = self.tag;
    slider.propertyType = propertyType;
    slider.minimumValue = minVal;
    slider.maximumValue = maxValue;
    slider.popUpViewColor = [UIColor redColor];//[self.color complementaryColor];
    slider.textColor = [UIColor whiteColor];//[slider.popUpViewColor blackOrWhiteContrastingColor];
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
    
    return slider;
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
    
    float sensorValue = [slider convertToSensorValue];
    NSString *newValue = [NSString stringWithFormat:@"%d", (int) sensorValue];
    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)slider.tag Value:newValue];
}

- (void)onSliderDidEndSliding:(id)sender {
    SFISlider *slider = sender;
    
    float sensorValue = [slider convertToSensorValue];
    NSString *newValue = [NSString stringWithFormat:@"%d", (int) sensorValue];
    
    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)slider.tag Value:newValue];
    
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
    //    [self.delegate tableViewCellDidPressSettings:self];
}

- (void)onDeviceClicked:(id)sender {
    //    [self.delegate tableViewCellDidClickDevice:self];
}

// toggles the label to reveal the underlying device type
- (void)onDeviceNameLabelTapped:(id)sender {
    //    UILabel *label = self.deviceNameLabel;
    //    NSString *name = self.device.deviceName;
    //
    //    if ([label.text isEqualToString:name]) {
    //        label.text = [SFIDevice nameForType:self.device.deviceType];
    //    }
    //    else {
    //        label.text = name;
    //    }
}

#pragma mark - SFISensorDetailViewDelegate methods


#pragma mark - Device layout

- (NSString *)imageNameForNoValue {
    return DEVICE_RELOAD_IMAGE;
}

- (void)setUpdatingSensorStatus {
    [self showDeviceValueLabels:NO];
    self.deviceImageView.image = [UIImage imageNamed:DEVICE_UPDATING_IMAGE];
    self.deviceImageViewSecondary.image = nil;
    
}

- (void)showDeviceValueLabels:(BOOL)show {
    self.deviceValueLabel.hidden = !show;
    self.decimalValueLabel.hidden = !show;
    self.degreeLabel.hidden = !show;
}

- (void)setDeviceStatusMessages:(NSArray *)statusMsgs {
    self.deviceStatusLabel.numberOfLines = (statusMsgs.count > 1) ? 0 : 1;
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

#pragma mark UI
- (IBAction)btnBinarySwitchOnTap:(id)sender{
    NSString * value = @"true";
    if (!btnBinarySwitchOn.selected) {
        btnBinarySwitchOn.selected = YES;
        btnBinarySwitchOff.selected = NO;
        
        switch (self.device.deviceType) {
            case SFIDeviceType_DoorLock_5:
                value = @"255";
                break;
            case SFIDeviceType_ZigbeeDoorLock_28:
                value = @"1";
                break;
            default:
                break;
        }
    }else{
        btnBinarySwitchOn.selected = NO;
        value = @"remove_from_entry_list";
    }
    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnBinarySwitchOn.tag Value:value];
}

- (IBAction)btnBinarySwitchOffTap:(id)sender{
    NSString * value = @"false";
    if (!btnBinarySwitchOff.selected) {
        btnBinarySwitchOn.selected = NO;
        btnBinarySwitchOff.selected = YES;
        
        switch (self.device.deviceType) {
            case SFIDeviceType_DoorLock_5:
                value = @"0";
                break;
            case SFIDeviceType_ZigbeeDoorLock_28:
                value = @"2";
                break;
            default:
                break;
        }
        
    }else{
        btnBinarySwitchOff.selected = NO;
        value = @"remove_from_entry_list";
    }
    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnBinarySwitchOff.tag Value:value];
    
}

#pragma mark
- (IBAction)btnDimOnTap:(id)sender{
    if (!btnDimOn.selected) {
        
        btnDimOn.selected = YES;
        btnDimOff.selected = NO;
        
        if (self.device.deviceType==SFIDeviceType_MultiLevelSwitch_2) {
            [btnDim setNewValue:btnDimOn.dimOnValue];
            btnDim.selected = YES;
        }
        
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnDimOn.tag Value:btnDimOn.dimOnValue];
    }else{
        btnDimOn.selected = NO;
        if (self.device.deviceType==SFIDeviceType_MultiLevelSwitch_2) {
            [btnDim setNewValue:btnDimOff.dimOffValue];
        }
        
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnDimOn.tag Value:@"remove_from_entry_list"];
    }
}
- (IBAction)btnDimOffTap:(id)sender{
    if (!btnDimOff.selected) {
        btnDimOn.selected = NO;
        btnDimOff.selected = YES;
        
        if (self.device.deviceType==SFIDeviceType_MultiLevelSwitch_2) {
            [btnDim setNewValue:btnDimOff.dimOffValue];
            btnDim.selected = NO;
        }
        
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnDimOff.tag Value:btnDimOff.dimOffValue];
    }else{
        btnDimOff.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnDimOff.tag Value:@"remove_from_entry_list"];
    }
}

- (IBAction)btnDimTap:(id)sender{
    if (self.device.deviceType==SFIDeviceType_MultiLevelSwitch_2) {
        btnDimOn.selected = NO;
        btnDimOff.selected = NO;
    }
    currentDimmerButton = sender;
    pickerValuesArray = [NSMutableArray new];
    
    if (self.device.deviceType == SFIDeviceType_MultiLevelOnOff_4) {
        for (int i=0; i<101; i++) {
            [pickerValuesArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }else{
        for (int i=[btnDimOff.dimOffValue intValue]; i<[btnDimOn.dimOnValue intValue]+1; i++) {
            [pickerValuesArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    
    
    [self setupPicker];
}

#pragma mark Picker

- (void)setupPicker{
    
    UIPickerView *chPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    chPicker.dataSource = self;
    chPicker.delegate = self;
    chPicker.showsSelectionIndicator = YES;
    
    chPicker.backgroundColor = [UIColor whiteColor];
    [chPicker selectRow:(NSInteger)index inComponent:0 animated:NO];
    
    ;
    
    
    actionSheet=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.parentViewController.view.frame.size.width, self.parentViewController.view.frame.size.height)];
    UIView * bg=[[UIView alloc] initWithFrame:actionSheet.frame];
    bg.backgroundColor = [UIColor blackColor];
    bg.alpha = 0.3;
    [actionSheet addSubview:bg];
    
    chPicker.frame = CGRectMake(0, actionSheet.frame.size.height-chPicker.frame.size.height, chPicker.frame.size.width, chPicker.frame.size.height);
    
    [actionSheet addSubview:chPicker];
    //yourView represent the view that contains UIPickerView and toolbar
    NSLog(@"%@",NSStringFromCGRect(actionSheet.frame));
    actionSheet.alpha = 0;
    [self.parentViewController.view addSubview:actionSheet];
    [UIView animateWithDuration:0.3 animations:^{
        actionSheet.alpha = 1;
    }completion:^(BOOL finished) {
        
    }];
}



#pragma mark UIPickerViewDelegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerValuesArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [pickerValuesArray objectAtIndex:row];
}

// Set the width of the component inside the picker
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 300;
}

// Item picked
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [UIView animateWithDuration:0.3 animations:^{
        actionSheet.alpha = 1;
    }completion:^(BOOL finished) {
        [actionSheet removeFromSuperview];
    }];
    
    [currentDimmerButton setNewValue:pickerValuesArray[row]];
    if (self.device.deviceType == SFIDeviceType_MultiLevelOnOff_4) {
        int v = [pickerValuesArray[row] intValue]*255/100;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)currentDimmerButton.tag Value:[NSString stringWithFormat:@"%d",v]];
    }else{
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)currentDimmerButton.tag Value:pickerValuesArray[row]];
    }
    currentDimmerButton.selected = YES;
}

- (void)actionSheet:(UIActionSheet *)_actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (_actionSheet.tag!=1) {
        actionSheet = nil;
        //        [self invite:pickerSelectedIndex];
    }
}

#pragma mark - ILHuePickerViewDelegate methods

- (void)huePicked:(float)hue picker:(ILHuePickerView *)picker {
    SFISlider *slider_saturation = [self sliderForDevicePropertyType:SFIDevicePropertyType_SATURATION];
    SFISlider *slider_brightness = [self sliderForDevicePropertyType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
    SFIHuePickerView *hue_picker = (SFIHuePickerView *) picker;
    
    [self processColorTintChange:slider_brightness saturationSlider:slider_saturation huePicker:hue_picker];
    
    int sensor_value = [hue_picker convertToSensorValue];
    
    [self processColorPropertyValueChange:hue_picker.propertyType newValue:sensor_value];
    
    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)hue_picker.tag Value:[NSString stringWithFormat:@"%d",sensor_value]];
}

#pragma mark - Color/Hue Lamp helpers

- (void)onHueLampColorPropertyIsChanging:(id)control {
    SFISlider *slider_brightness = [self sliderForDevicePropertyType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
    SFISlider *slider_saturation = [self sliderForDevicePropertyType:SFIDevicePropertyType_SATURATION];
    SFIHuePickerView *hue_picker = [self huePickerForDevicePropertyType:SFIDevicePropertyType_COLOR_HUE];
    
    [self processColorTintChange:slider_brightness saturationSlider:slider_saturation huePicker:hue_picker];
}

- (void)onColorDimmableLampColorPropertyIsChanging:(id)control {
    SFISlider *slider_brightness = [self sliderForDevicePropertyType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
    SFISlider *slider_saturation = [self sliderForDevicePropertyType:SFIDevicePropertyType_CURRENT_SATURATION];
    SFIHuePickerView *hue_picker = [self huePickerForDevicePropertyType:SFIDevicePropertyType_CURRENT_HUE];
    
    [self processColorTintChange:slider_brightness saturationSlider:slider_saturation huePicker:hue_picker];
}

- (void)onColorDimmableLampColorTemperaturePropertyIsChanging:(id)control {
    SFISlider *slider_temp = [self sliderForDevicePropertyType:SFIDevicePropertyType_COLOR_TEMPERATURE];
    
    float kelvin = slider_temp.convertToSensorValue;
    UIColor *color = [UIColor colorWithKelvin:kelvin];
    
    //    [self.delegate sensorDetailViewDidChangeSensorIconTintValue:self tint:color];
}

- (void)onColorPropertyDidChange:(id)control {
    SFISlider *slider = control;
    float sensor_value = [slider convertToSensorValue];
    [self processColorPropertyValueChange:slider.propertyType newValue:sensor_value];
}

- (void)processColorTintChange:(SFISlider *)slider_brightness saturationSlider:(SFISlider *)slider_saturation huePicker:(SFIHuePickerView *)hue_picker {
    float hue = [hue_picker hue];
    float saturation = [slider_saturation convertToSensorValue] / slider_saturation.sensorMaxValue;
    float brightness = [slider_brightness convertToSensorValue] / slider_brightness.sensorMaxValue;
    
    // put a floor underneath the brightness to prevent it from showing up as black
    if (brightness < 0.50) {
        brightness = 0.50;
    }
    
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    //    [self.delegate sensorDetailViewDidChangeSensorIconTintValue:self tint:color];
}

- (void)processColorPropertyValueChange:(SFIDevicePropertyType)propertyType newValue:(float)sensorValue {
    NSString *newValue = [NSString stringWithFormat:@"%i", (int) sensorValue];
    //    [self.delegate sensorDetailViewDidChangeSensorValue:self propertyType:propertyType newValue:newValue];
}

- (SFISlider *)sliderForDevicePropertyType:(SFIDevicePropertyType)propertyType {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[SFISlider class]]) {
            SFISlider *slider = (SFISlider *) view;
            if (slider.propertyType == propertyType) {
                return slider;
            }
        }
    }
    
    return nil;
}

- (SFIHuePickerView *)huePickerForDevicePropertyType:(SFIDevicePropertyType)propertyType {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[SFIHuePickerView class]]) {
            SFIHuePickerView *picker = (SFIHuePickerView *) view;
            if (picker.propertyType == propertyType) {
                return picker;
            }
        }
    }
    
    return nil;
}

#pragma mark Thermostat 7

- (void)layoutThermostat_7{
    viewAutoHeatCoolOff.hidden = NO;
    CGRect fr = viewAutoHeatCoolOff.frame;
    fr.origin.y = 30;
    fr.origin.x = (self.frame.size.width - fr.size.width)/2;
    viewAutoHeatCoolOff.frame = fr;
    
    [btnAuto setupValues:[UIImage imageNamed:@"imgAuto"] Title:@"AUTO"];
    [btnHeat setupValues:[UIImage imageNamed:@"imgHeat"] Title:@"HEAT"];
    [btnCool setupValues:[UIImage imageNamed:@"imgCool"] Title:@"COOL"];
    [btnOff setupValues:[UIImage imageNamed:@"imgOff"] Title:@"OFF"];
    [btnTermostatFanOn setupValues:[UIImage imageNamed:@"imgFanOn"] Title:@"FAN ON"];
    [btnTermostatFanOff setupValues:[UIImage imageNamed:@"imgFanOff"] Title:@"FAN OFF"];
    
    [btnTermostatDimCool setupValues:@"35" Title:@"COOLING TEMP." Prefix:@"°F"];
    btnTermostatDimCool.tag = 5;
    
    
    [btnTermostatDimHeat setupValues:@"35" Title:@"HEATING TEMP." Prefix:@"°F"];
    btnTermostatDimHeat.tag = 4;
    
    btnAuto.tag = 2;
    btnHeat.tag = 2;
    btnCool.tag = 2;
    btnOff.tag = 2;
    
    
    btnAuto.selected = NO;
    btnHeat.selected = NO;
    btnCool.selected = NO;
    btnOff.selected = NO;
    NSArray * existingValues = [self.cellInfo valueForKey:@"existingValues"];
    
    for (NSDictionary * dict in existingValues) {
        if ([[dict valueForKey:@"Index"] integerValue]==2) {
            if ([[dict valueForKey:@"Value"] isEqualToString:@"Heat"]) {
                btnHeat.selected = YES;
            }
            if ([[dict valueForKey:@"Value"] isEqualToString:@"Auto"]) {
                btnAuto.selected = YES;
            }
            if ([[dict valueForKey:@"Value"] isEqualToString:@"Cool"]) {
                btnCool.selected = YES;
            }
            if ([[dict valueForKey:@"Value"] isEqualToString:@"Off"]) {
                btnOff.selected = YES;
            }
        }
        if ([[dict valueForKey:@"Index"] integerValue]==6) {
            if ([[dict valueForKey:@"Value"] isEqualToString:@"Auto Low"]) {
                btnTermostatFanOff.selected = YES;
            }else{
                btnTermostatFanOn.selected = YES;
            }
        }
        if ([[dict valueForKey:@"Index"] integerValue]==4) {
            [btnTermostatDimCool setupValues:[dict valueForKey:@"Value"] Title:@"COOLING TEMP." Prefix:@"°F"];
            btnTermostatDimCool.selected = YES;
        }
        if ([[dict valueForKey:@"Index"] integerValue]==5) {
            [btnTermostatDimHeat setupValues:[dict valueForKey:@"Value"] Title:@"HEATING TEMP." Prefix:@"°F"];
            btnTermostatDimHeat.selected = YES;
        }
    }
}

- (IBAction)btnAutoTap:(id)sender {
    if (!btnAuto.selected) {
        btnAuto.selected = YES;
        btnHeat.selected = NO;
        btnCool.selected = NO;
        btnOff.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnAuto.tag Value:@"Auto"];
    }else{
        btnAuto.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnAuto.tag Value:@"remove_from_entry_list"];
    }
}

- (IBAction)btnHeatTap:(id)sender {
    if (!btnHeat.selected) {
        btnAuto.selected = NO;
        btnHeat.selected = YES;
        btnCool.selected = NO;
        btnOff.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnAuto.tag Value:@"Heat"];
    }else{
        btnHeat.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnHeat.tag Value:@"remove_from_entry_list"];
    }
    
}

- (IBAction)btnCoolTap:(id)sender {
    if (!btnCool.selected) {
        btnAuto.selected = NO;
        btnHeat.selected = NO;
        btnCool.selected = YES;
        btnOff.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnAuto.tag Value:@"Cool"];
    }else{
        btnCool.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnCool.tag Value:@"remove_from_entry_list"];
    }
}

- (IBAction)btnOffTap:(id)sender {
    if (!btnOff.selected) {
        btnAuto.selected = NO;
        btnHeat.selected = NO;
        btnCool.selected = NO;
        btnOff.selected = YES;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnAuto.tag Value:@"Off"];
    }else{
        btnOff.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)btnOff.tag Value:@"remove_from_entry_list"];
    }
}

- (IBAction)btnFanOnTap:(id)sender {
    if (!btnTermostatFanOn.selected ) {
        btnTermostatFanOn.selected = YES;
        btnTermostatFanOff.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:6 Value:@"On Low"];
    }else{
        btnTermostatFanOn.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:6 Value:@"remove_from_entry_list"];
    }
}

- (IBAction)btnFanOffTap:(id)sender {
    if (!btnTermostatFanOff.selected ) {
        btnTermostatFanOn.selected = NO;
        btnTermostatFanOff.selected = YES;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:6 Value:@"Auto Low"];
    }else{
        btnTermostatFanOff.selected = NO;
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)6 Value:@"remove_from_entry_list"];
    }
}


- (IBAction)btnTermostatDimCoolTap:(id)sender{
    currentDimmerButton = sender;
    pickerValuesArray = [NSMutableArray new];
    for (int i=35; i<96; i++) {
        [pickerValuesArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    [self setupPicker];
}

- (IBAction)btnTermostatDimHeatTap:(id)sender{
    currentDimmerButton = sender;
    pickerValuesArray = [NSMutableArray new];
    for (int i=35; i<96; i++) {
        [pickerValuesArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    
    [self setupPicker];
}
#pragma mark Standard Warning Device 21
- (void)layoutStandardWarningDevice_21{
    viewStandardWarningDevice_21.hidden = NO;
    CGRect fr = viewStandardWarningDevice_21.frame;
    fr.origin.y = 30;
    fr.origin.x = (self.frame.size.width - fr.size.width)/2;
    viewStandardWarningDevice_21.frame = fr;
    
    [btnStandardWarningDeviceOn setupValues:[UIImage imageNamed:@"06_alarm_on"] Title:@"Ringing"];
    [btnStandardWarningDeviceOff setupValues:[UIImage imageNamed:@"06_alarm_off"] Title:@"Silent"];
    
    btnStandardWarningDeviceOn.selected = NO;
    btnStandardWarningDeviceOff.selected = NO;
    
    btnStandardWarningDeviceOn.tag = 1;
    btnStandardWarningDeviceOff.tag = 1;
    
    NSArray * existingValues = [self.cellInfo valueForKey:@"existingValues"];
    
    for (NSDictionary * dict in existingValues) {
        if ([[dict valueForKey:@"Index"] integerValue]==1) {
            int val = [[dict valueForKey:@"Value"] intValue];
            if (val>0) {
                btnStandardWarningDeviceOn.selected = YES;
                btnStandardWarningDeviceOff.selected = NO;
            }else{
                btnStandardWarningDeviceOn.selected = NO;
                btnStandardWarningDeviceOff.selected = YES;
            }
            txtTimer.text = [dict valueForKey:@"Value"];
        }
    }
}

- (IBAction)btnStandardWarningDeviceOnTap:(id)sender {
    btnStandardWarningDeviceOn.selected = YES;
    btnStandardWarningDeviceOff.selected = NO;
    txtTimer.text = @"65535";
    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:1 Value:txtTimer.text];
}

- (IBAction)btnStandardWarningDeviceOffTap:(id)sender {
    btnStandardWarningDeviceOn.selected = NO;
    btnStandardWarningDeviceOff.selected = YES;
    txtTimer.text = @"0";
    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:1 Value:txtTimer.text];
}

#pragma mark - Keyboard methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if ([textField isEqual:txtTimer]) {
        int val = [txtTimer.text intValue];
        if (val>65535) {
            val = 65535;
        }
        if (val<0) {
            val=0;
        }
        if (val>0) {
            btnStandardWarningDeviceOn.selected = YES;
            btnStandardWarningDeviceOff.selected = NO;
        }else{
            btnStandardWarningDeviceOn.selected = NO;
            btnStandardWarningDeviceOff.selected = YES;
        }
        [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:1 Value:txtTimer.text];
        return YES;
    }
    //    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:1 Value:@"0"];
    return YES;
}

-(void)textFieldDidChange :(UITextField *)theTextField{
    if ([theTextField isEqual:txtName])
    {
        [self.delegate sceneNameDidChange:self SceneName:txtName.text ActiveField:txtName];
    }
}
- (IBAction)btnDeleteTap:(id)sender {
    [self.delegate deleteSceneDidTapped:self];
}
#pragma mark
- (void)NPColorPickerView:(NPColorPickerView *)view didSelectColor:(UIColor *)color{
    
}
@end
