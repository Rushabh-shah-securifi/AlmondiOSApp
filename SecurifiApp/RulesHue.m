//
//  RulesHue.m
//  Tableviewcellpratic
//
//  Created by Masood on 17/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import "RulesHue.h"
#import <UIKit/UIKit.h>
#import "SecurifiToolkit/SFIDevice.h"
#import "SecurifiToolkit/SFIDeviceKnownValues.h"
#import "SecurifiToolkit/SFIDeviceValue.h"
#import "SecurifiToolkit/SecurifiTypes.h"
#import "SwitchButton.h"
#import "SFIButtonSubProperties.h"
#import "SecurifiToolkit/SFIDeviceKnownValues.h"
#import "SecurifiToolkit/SFIDeviceValue.h"
#import "SFIHuePickerView.h"
#import "SFISlider.h"
#import "labelAndCheckButtonView.h"
#import "UIFont+Securifi.h"
#import "SFIDeviceIndex.h"
#import "IndexValueSupport.h"
#import "ILHuePickerView.h"

#import "RulesConstants.h"

@interface RulesHue()<ILHuePickerViewDelegate>


//@property (nonatomic,strong)NSMutableDictionary *buttonsDict;
//@property (nonatomic,strong)NSMutableDictionary *storeDict;

@end



@implementation RulesHue

SFIHuePickerView *huePickerView;
SFISlider *brightnessSlider;
SFISlider *saturationSlider;

labelAndCheckButtonView *hueColorPickupLabelView;
labelAndCheckButtonView *saturationSliderLabelView;
labelAndCheckButtonView *brightnessSliderLabelView ;


-(id)initWithPropertiesTrigger:(NSMutableArray*)triggers action:(NSMutableArray*)actions isScene:(BOOL)isScene{
    if(self == [super init]){
        self.triggers = triggers;
        self.actions = actions;
        self.isScene = isScene;
    }
    return self;
}

-(void) createHueCellLayoutWithDeviceId:(int)deviceId deviceType:(int)deviceType deviceIndexes:(NSArray*)deviceIndexes deviceName:(NSString*)deviceName scrollView:(UIScrollView *)scrollView cellCount:(int)numberOfCells indexesDictionary:(NSDictionary*)deviceIndexesDict{
    for(int i = 0; i < numberOfCells; i++){
        [self HueLayout:scrollView withYScale:ROW_PADDING+(ROW_PADDING+frameSize)*i  withDeviceIndex:[deviceIndexesDict valueForKey:[NSString stringWithFormat:@"%d", i+1]] deviceId:deviceId deviceType:deviceType deviceName:deviceName];
        
    }
}

- (void)HueLayout:(UIScrollView *)scrollView withYScale:(int)yScale withDeviceIndex:(NSArray *)deviceIndexes deviceId:(int)deviceId deviceType:(SFIDeviceType)deviceType deviceName:(NSString*)deviceName{
    CGSize scrollableSize = CGSizeMake(scrollView.frame.size.width,
                                       500);
    [scrollView setContentSize:scrollableSize];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                            yScale,
                                                            scrollView.frame.size.width,
                                                            frameSize)];
    [scrollView addSubview:view];
    
    int i=0;
    for (SFIDeviceIndex *deviceIndex in deviceIndexes) {
        NSMutableArray *btnary=[[NSMutableArray alloc]init];
        int indexValCounter = 0;
        for (IndexValueSupport *iVal in deviceIndex.indexValues) {
            i++;
            indexValCounter++;
            if(deviceIndex.valueType == SFIDevicePropertyType_SWITCH_BINARY){
                SwitchButton *buttonHue = [[SwitchButton alloc] initWithFrame:CGRectMake(view.frame.origin.x, 0, indexButtonFrameSize, indexButtonFrameSize)];
                //                buttonHue.backgroundColor = [UIColor blackColor];
                buttonHue.tag = indexValCounter;
                buttonHue.valueType = deviceIndex.valueType;
                
                //subproperties
                buttonHue.subProperties = [self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData andEventType:nil deviceName:deviceName deviceType:deviceType];
                buttonHue.deviceType = deviceType;
                [buttonHue addTarget:self action:@selector(onHueButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                [buttonHue setupValues:[UIImage imageNamed:iVal.iconName] topText:nil bottomText:iVal.displayText isTrigger:self.isScene isDimButton:NO insideText:iVal.displayText isScene:self.isScene];
                [buttonHue changeImageColor:[UIColor whiteColor]];
                
                //set perv. count and highlight
                int buttonClickCount = 0;
                NSMutableArray *subProperties = self.isScene? self.triggers: self.actions;
                for(SFIButtonSubProperties *hueButtonProperty in subProperties){ //to do - you can add count property to subproperties and iterate array in reverse
                    if(hueButtonProperty.deviceId == deviceId && hueButtonProperty.index == deviceIndex.indexID && [hueButtonProperty.matchData isEqualToString:iVal.matchData]){
                        buttonHue.selected = YES;
                        buttonClickCount++;
                    }
                }
                
                buttonHue.center = CGPointMake(view.bounds.size.width/2,
                                               view.bounds.size.height/2);
                buttonHue.frame=CGRectMake(buttonHue.frame.origin.x + ((i-1) * (frameSize/2))+textHeight/2 ,
                                           buttonHue.frame.origin.y,
                                           buttonHue.frame.size.width,
                                           buttonHue.frame.size.height);
                //shifting
                [self shiftButtonsByWidth:frameSize View:view forIteration:i];
                
                //previous count
                if(buttonClickCount > 0 && !self.isScene){
                    [buttonHue setButtoncounter:buttonClickCount isCountImageHiddn:NO];
                }
                
                [btnary addObject:buttonHue];
                [view addSubview:buttonHue];
            }
            
            else if(deviceIndex.valueType == SFIDevicePropertyType_COLOR_HUE){
                //subview
                hueColorPickupLabelView = [[labelAndCheckButtonView alloc]initWithFrame:CGRectMake(view.frame.origin.x, 0, view.frame.size.width, hueSubViewSize)];
                hueColorPickupLabelView.isScene = self.isScene;
                [hueColorPickupLabelView setUpValues:@"  Hue" withSelectButtonTitle:@"Select"];
                [hueColorPickupLabelView.selectButton addTarget:self action:@selector(onHueColorPickerSelectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                //picker view
                huePickerView = [[SFIHuePickerView alloc]initWithFrame:CGRectMake(view.frame.origin.x, hueSubViewSize,view.frame.size.width ,view.frame.size.height-hueSubViewSize)];
                
                huePickerView.convertedValue = 0;
                huePickerView.allowSelection = YES;
                huePickerView.delegate = self;
                huePickerView.propertyType = SFIDevicePropertyType_COLOR_HUE;
                huePickerView.subProperties = [self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData andEventType:nil deviceName:deviceName deviceType:deviceType];
                
                //previous values
                BOOL isSelected = NO;
                int buttonClickCount = 0;
                float preValue = 0;
                NSMutableArray *subProperties = self.isScene? self.triggers: self.actions;
                for(SFIButtonSubProperties *hueProperty in subProperties){ //to do - you can add count property to subproperties and iterate array in reverse
                    if(hueProperty.deviceId == deviceId && hueProperty.index == deviceIndex.indexID){
                        isSelected = YES;
                        preValue = hueProperty.matchData.floatValue;
                        buttonClickCount++;
                    }
                }
                //previous values
                [hueColorPickupLabelView setSelected:isSelected];
                //previous count
                if(self.isScene){
                    [huePickerView setConvertedValue:preValue];
                }else if(buttonClickCount > 0){
                    [hueColorPickupLabelView setButtoncounter:buttonClickCount isCountImageHiddn:NO];
                }
                
                [btnary addObject:hueColorPickupLabelView];
                [btnary addObject:huePickerView];
                
                [view addSubview:hueColorPickupLabelView];
                [view addSubview:huePickerView];
            }
            
            else if(deviceIndex.valueType == SFIDevicePropertyType_SATURATION){
                view.frame = CGRectMake(0,
                                        yScale ,
                                        scrollView.frame.size.width,
                                        frameSize);
                
                //subview
                saturationSliderLabelView = [[labelAndCheckButtonView alloc]initWithFrame:CGRectMake(view.frame.origin.x, 0, view.frame.size.width, hueSubViewSize)];
                saturationSliderLabelView.isScene = self.isScene;
                [saturationSliderLabelView setUpValues:@"  Saturation" withSelectButtonTitle:@"Select"];
                [saturationSliderLabelView.selectButton addTarget:self action:@selector(onSaturationCheckButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                //sliderview
                const CGFloat slider_x_offset = 10.0;
                const CGFloat slider_right_inset = 20.0;
                CGFloat slider_width = view.frame.size.width - slider_right_inset;
                
                saturationSlider = [[SFISlider alloc]initWithFrame:CGRectMake(slider_x_offset, hueSubViewSize,slider_width ,view.frame.size.height - hueSubViewSize)];
                saturationSlider = [self makeSlider:0 maxValue:100 propertyType:SFIDevicePropertyType_SATURATION sliderLeftInset:slider_x_offset sliderRightInset:slider_right_inset slider:saturationSlider];
                
                
                saturationSlider.continuous = YES;
                saturationSlider.allowToSlide = YES; // Initial value
                saturationSlider.sensorMaxValue = 255;
                saturationSlider.convertedValue = 0; // to be assigned
                saturationSlider.backgroundColor = [UIColor grayColor];
                
                //slider view - sub-properties
                saturationSlider.subProperties = [self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData andEventType:nil deviceName:deviceName deviceType:deviceType];
                
                //previous values
                BOOL isSelected = NO;
                int buttonClickCount = 0;
                float preValue = 0;
                NSMutableArray *subProperties = self.isScene? self.triggers: self.actions;
                for(SFIButtonSubProperties *saturationProperty in subProperties){ //to do - you can add count property to subproperties and iterate array in reverse
                    if(saturationProperty.deviceId == deviceId && saturationProperty.index == deviceIndex.indexID){
                        isSelected = YES;
                        preValue = saturationProperty.matchData.floatValue;
                        buttonClickCount++;
                    }
                }
                //previous values
                [saturationSliderLabelView setSelected:isSelected];
                //previous count
                if(self.isScene){
                    [saturationSlider setConvertedValue:preValue];
                }else if(buttonClickCount > 0){
                    [saturationSliderLabelView setButtoncounter:buttonClickCount isCountImageHiddn:NO];
                }
                
                [btnary addObject:saturationSliderLabelView];
                [btnary addObject:saturationSlider];
                
                [view addSubview:saturationSliderLabelView];
                [view addSubview:saturationSlider];
                
            }
            
            else if(deviceIndex.valueType == SFIDevicePropertyType_BRIGHTNESS){
                
                view.frame = CGRectMake(0,
                                        yScale ,
                                        scrollView.frame.size.width,
                                        frameSize );
                
                //hue sub view
                brightnessSliderLabelView = [[labelAndCheckButtonView alloc]initWithFrame:CGRectMake(view.frame.origin.x, 0, view.frame.size.width, hueSubViewSize)];
                brightnessSliderLabelView.isScene = self.isScene;
                [brightnessSliderLabelView setUpValues:@"  Brightness" withSelectButtonTitle:@"Select"];
                [brightnessSliderLabelView.selectButton addTarget:self action:@selector(onBrightnessCheckButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                //slider view
                const CGFloat slider_x_offset = 10.0;
                const CGFloat slider_right_inset = 20.0;
                CGFloat slider_width = view.frame.size.width - slider_right_inset;
                brightnessSlider = [[SFISlider alloc]initWithFrame:CGRectMake(slider_x_offset,hueSubViewSize, slider_width,view.frame.size.height-hueSubViewSize)];
                
                brightnessSlider = [self makeSlider:0 maxValue:100 propertyType:SFIDevicePropertyType_BRIGHTNESS sliderLeftInset:slider_x_offset sliderRightInset:slider_right_inset slider:brightnessSlider];
                
                brightnessSlider.continuous = YES;
                brightnessSlider.allowToSlide = YES;
                brightnessSlider.sensorMaxValue = 255;
                brightnessSlider.convertedValue = 0; // to be assigned
                brightnessSlider.backgroundColor = [UIColor grayColor];
                
                //slider view - sub-properties
                brightnessSlider.subProperties = [self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData andEventType:nil deviceName:deviceName deviceType:deviceType];
                
                //previous values
                BOOL isSelected = NO;
                int buttonClickCount = 0;
                float preValue = 0;
                NSMutableArray *subProperties = self.isScene? self.triggers: self.actions;
                for(SFIButtonSubProperties *brightnessProperty in subProperties){ //to do - you can add count property to subproperties and iterate array in reverse
                    if(brightnessProperty.deviceId == deviceId && brightnessProperty.index == deviceIndex.indexID){
                        isSelected = YES;
                        preValue = brightnessProperty.matchData.floatValue;
                        buttonClickCount++;
                    }
                }
                //previous values
                [brightnessSliderLabelView setSelected:isSelected];
                //previous count/value
                if(self.isScene){
                    [brightnessSlider setConvertedValue:preValue];
                }else if(buttonClickCount > 0){
                    [brightnessSliderLabelView setButtoncounter:buttonClickCount isCountImageHiddn:NO];
                }
                
                
                [btnary addObject:brightnessSliderLabelView];
                [btnary addObject:brightnessSlider];
                
                [view addSubview:brightnessSliderLabelView];
                [view addSubview:brightnessSlider];
            }
            
        } //inner for loop, indexvalues
        
        
    }//outer for loop deviceindexes
    
    
}

-(void)setPreviousHighlightForID:(sfi_id)deviceId index:(int)indexId{
    //previous values
    BOOL isSelected = NO;
    int buttonClickCount = 0;
    NSMutableArray *subProperties = self.isScene? self.triggers: self.actions;
    for(SFIButtonSubProperties *brightnessProperty in subProperties){ //to do - you can add count property to subproperties and iterate array in reverse
        if(brightnessProperty.deviceId == deviceId && brightnessProperty.index == indexId){
            isSelected = YES;
            buttonClickCount++;
        }
    }
    //previous values
    [brightnessSliderLabelView setSelected:isSelected];
    //previous count
    if(buttonClickCount > 0 && !self.isScene){
        [brightnessSliderLabelView setButtoncounter:buttonClickCount isCountImageHiddn:NO];
    }
}

#pragma mark helper methods
-(SFIButtonSubProperties*) addSubPropertiesFordeviceID:(sfi_id)deviceID index:(int)index matchData:(NSString*)matchData andEventType:(NSString *)eventType deviceName:(NSString*)deviceName deviceType:(SFIDeviceType)deviceType{ //overLoaded
    SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
    subProperties.deviceId = deviceID;
    subProperties.index = index;
    subProperties.matchData = matchData;
    subProperties.eventType = eventType;
    subProperties.deviceName = deviceName;
    subProperties.deviceType = deviceType;
    return subProperties;
}

- (void) shiftButtonsByWidth:(int)width View:(UIView *)view forIteration:(int)i{
    for (int j = 1; j < i; j++) {
        UIView *childView = [view subviews][j-1];
        
        childView.frame = CGRectMake(childView.frame.origin.x -  (width/2),
                                     childView.frame.origin.y,
                                     childView.frame.size.width,
                                     childView.frame.size.height);
    }
}

//add to property to array
-(void) addToArray:(sfi_id)deviceId index:(int)index matchData:(NSString*)matchData andEventType:(NSString *)eventType deviceName:(NSString*)deviceName deviceType:(SFIDeviceType)deviceType{
    SFIButtonSubProperties *subProperties = [self addSubPropertiesFordeviceID:deviceId index:index matchData:matchData andEventType:nil deviceName:deviceName deviceType:deviceType];
    
    [self.actions addObject:subProperties];
}

//remove previous value
-(void) deleteFromTriggersArrayForID:(sfi_id)buttonId index:(int)buttonIndex{
    SFIButtonSubProperties *toBeDeletedProperty;
    for(SFIButtonSubProperties *buttonProperties in self.triggers){
        if(buttonProperties.deviceId == buttonId && buttonProperties.index == buttonIndex){
            toBeDeletedProperty = buttonProperties;
            break;
        }
    }
    if(toBeDeletedProperty)
        [self.triggers removeObject:toBeDeletedProperty];
    
}

-(void)updateEntryForID:(sfi_id)deviceId index:(int)index matchData:(NSString*)matchData{
    for(SFIButtonSubProperties *buttonProperties in self.triggers){
        if(buttonProperties.deviceId == deviceId && buttonProperties.index == index){
            buttonProperties.matchData = matchData;
            [self.delegate updateArray];
            break;
        }
    }
}
#pragma mark button click
-(void) onHueButtonClick:(id)sender{
    [self.delegate onSwitchButtonClick:sender];
}


#pragma mark - hueOperation
- (SFISlider *)makeSlider:(float)minVal maxValue:(float)maxValue propertyType:(SFIDevicePropertyType)propertyType sliderLeftInset:(CGFloat)sliderLeftInset sliderRightInset:(CGFloat)sliderRightInset slider:(SFISlider*) slider {
    slider.propertyType = propertyType;
    slider.minimumValue = minVal;
    slider.maximumValue = maxValue;
    slider.popUpViewColor = [UIColor redColor];//[self.color complementaryColor];
    slider.textColor = [UIColor whiteColor];//[slider.popUpViewColor blackOrWhiteContrastingColor];
    slider.font = [UIFont securifiBoldFont:22];
    [slider addTarget:self action:@selector(onSliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterPercentStyle;
    formatter.multiplier = @(1); // don't multiply numbers by 100
    slider.numberFormatter = formatter;
    slider.maxFractionDigitsDisplayed = 0;
    
    //
    UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSliderTapped:)];
    [slider addGestureRecognizer:tapSlider];
    
    [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb"] forState:UIControlStateHighlighted];
    [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background"] forState:UIControlStateNormal];
    
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
    if(slider.propertyType == SFIDevicePropertyType_BRIGHTNESS){
        brightnessSlider.subProperties.matchData = newValue;
        if(self.isScene){
            [self updateEntryForID:brightnessSlider.subProperties.deviceId index:brightnessSlider.subProperties.index matchData:newValue];
        }
    }else if(slider.propertyType == SFIDevicePropertyType_SATURATION){
        saturationSlider.subProperties.matchData = newValue;
        if(self.isScene){
            [self updateEntryForID:saturationSlider.subProperties.deviceId index:saturationSlider.subProperties.index matchData:newValue];
        }
    }
}

- (void)onSliderDidEndSliding:(id)sender {
    SFISlider *slider = sender;
    float sensorValue = [slider convertToSensorValue];
    NSString *newValue = [NSString stringWithFormat:@"%d", (int) sensorValue];
    
    if(slider.propertyType == SFIDevicePropertyType_BRIGHTNESS){
        brightnessSlider.subProperties.matchData = newValue;
        if(self.isScene){
            [self updateEntryForID:brightnessSlider.subProperties.deviceId index:brightnessSlider.subProperties.index matchData:newValue];
        }
    }else if(slider.propertyType == SFIDevicePropertyType_SATURATION){
        saturationSlider.subProperties.matchData = newValue;
        if(self.isScene){
            [self updateEntryForID:saturationSlider.subProperties.deviceId index:saturationSlider.subProperties.index matchData:newValue];
        }
    }
}

#pragma mark slider clicks
-(void)onBrightnessCheckButtonClick:(UIButton*)sender{ //This is enable button
    sfi_id sliderId = brightnessSlider.subProperties.deviceId;
    int sliderIndex = brightnessSlider.subProperties.index;
    if(self.isScene){
        [brightnessSliderLabelView setSelected:!sender.selected];
        [self deleteFromTriggersArrayForID:sliderId index:sliderIndex];
        if(sender.selected)
            [self.triggers addObject:brightnessSlider.subProperties];
        else
            [brightnessSlider setConvertedValue:0];
    }else{
        [brightnessSliderLabelView setSelected:YES];
        
        //storing current value
        [self addToArray:sliderId index:sliderIndex matchData:brightnessSlider.subProperties.matchData andEventType:brightnessSlider.subProperties.eventType deviceName:brightnessSlider.subProperties.deviceName deviceType:brightnessSlider.subProperties.deviceType];
        
        int buttonClickCount = 0;
        for(SFIButtonSubProperties *property in self.actions){ //to do - you can add count property to subproperties and iterate array in reverse
            if(property.deviceId == sliderId && property.index == sliderIndex){
                buttonClickCount++;
            }
        }
        [brightnessSliderLabelView setButtoncounter:buttonClickCount isCountImageHiddn:NO];
        //    [brightnessSlider setConvertedValue:0];
    }
    
    [self.delegate updateArray];
}

-(void)onSaturationCheckButtonClick:(UIButton*)sender{ //button check/uncheck
    sfi_id sliderId = saturationSlider.subProperties.deviceId;
    int sliderIndex = saturationSlider.subProperties.index;
    if(self.isScene){
        [saturationSliderLabelView setSelected:!sender.selected];
        [self deleteFromTriggersArrayForID:sliderId index:sliderIndex];
        if(sender.selected)
            [self.triggers addObject:saturationSlider.subProperties];
        else
            [saturationSlider setConvertedValue:0];
    }else{
        [saturationSliderLabelView setSelected:YES];
        
        //storing current value
        [self addToArray:sliderId index:sliderIndex matchData:saturationSlider.subProperties.matchData andEventType:saturationSlider.subProperties.eventType deviceName:saturationSlider.subProperties.deviceName deviceType:saturationSlider.subProperties.deviceType];
        
        int buttonClickCount = 0;
        for(SFIButtonSubProperties *property in self.actions){ //to do - you can add count property to subproperties and iterate array in reverse
            if(property.deviceId == sliderId && property.index == sliderIndex){
                buttonClickCount++;
            }
        }
        [saturationSliderLabelView setButtoncounter:buttonClickCount isCountImageHiddn:NO];
        //    [saturationSlider setConvertedValue:0];
    }
    
    
    [self.delegate updateArray];
}

//[self addSubPropertiesFordeviceID:deviceId index:deviceIndex.indexID matchData:iVal.matchData andEventType:iVal.eventType deviceName:deviceName deviceType:deviceType];

-(void)onHueColorPickerSelectButtonClick:(UIButton*)sender{//button click
    NSLog(@"onHueColorPickerSelectButtonClick");
    sfi_id pickerId = huePickerView.subProperties.deviceId;
    int pickerIndex = huePickerView.subProperties.index;
    if(self.isScene){
        [hueColorPickupLabelView setSelected:!sender.selected];
        [self deleteFromTriggersArrayForID:pickerId index:pickerIndex];
        if(sender.selected)
            [self.triggers addObject:huePickerView.subProperties];
        else
            [huePickerView setConvertedValue:0];
    }else{
        [hueColorPickupLabelView setSelected:YES]; //will change color aswell
        //getting current value of hue
        [self addToArray:pickerId index:pickerIndex matchData:huePickerView.subProperties.matchData andEventType:brightnessSlider.subProperties.eventType deviceName:brightnessSlider.subProperties.deviceName deviceType:brightnessSlider.subProperties.deviceType];
        
        int buttonClickCount = 0;
        for(SFIButtonSubProperties *property in self.actions){ //to do - you can add count property to subproperties and iterate array in reverse
            if(property.deviceId == pickerId && property.index == pickerIndex){
                buttonClickCount++;
            }
        }
        [hueColorPickupLabelView setButtoncounter:buttonClickCount isCountImageHiddn:NO];
    }
    
    //    [huePickerView setConvertedValue:0];
    [self.delegate updateArray];
}


#pragma mark - ILHuePickerViewDelegate methods
- (void)huePicked:(float)hue picker:(ILHuePickerView *)picker {
    NSLog(@"hue picked");
    //    SFISlider *slider_saturation = [self sliderForDevicePropertyType:SFIDevicePropertyType_SATURATION];
    //    SFISlider *slider_brightness = [self sliderForDevicePropertyType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
    
    SFIHuePickerView *hue_picker = (SFIHuePickerView *) picker;
    //    [self processColorTintChange:slider_brightness saturationSlider:slider_saturation huePicker:hue_picker];
    
    int sensor_value = [hue_picker convertToSensorValue];
    huePickerView.subProperties.matchData = @(sensor_value).stringValue ;
    if(self.isScene){
        [self updateEntryForID:huePickerView.subProperties.deviceId index:huePickerView.subProperties.index matchData:@(sensor_value).stringValue];
    }
    //    [self processColorPropertyValueChange:hue_picker.propertyType newValue:sensor_value];
    //    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)hue_picker.tag Value:[NSString stringWithFormat:@"%d",sensor_value]];
    
}



@end