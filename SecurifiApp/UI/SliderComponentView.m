//
//  SliderComponentView.m
//  SecurifiApp
//
//  Created by Masood on 10/19/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SliderComponentView.h"
#import "SFISlider.h"
#import "UIFont+Securifi.h"
#import "CommonMethods.h"

const int lableViewHeight = 20;

@interface SliderComponentView()
@property (nonatomic)labelAndCheckButtonView *labelView;
@property (nonatomic)SFISlider *slider;

@property (nonatomic) BOOL isScene;
@property (nonatomic) NSArray *subPropertiesArr;
@property (nonatomic) SFIButtonSubProperties *subProperties;
@property(nonatomic)int preValue;
@end


@implementation SliderComponentView
-(id) initWithFrame:(CGRect)frame lableTitle:(NSString *)title isScene:(BOOL)isScene list:(NSArray *)listArr subproperties:(SFIButtonSubProperties*)subproperties genricIndexVal:(GenericIndexValue*)genricIndexVal
{
    self = [super initWithFrame:frame];
    if(self){
        self.subProperties = subproperties;
        self.subPropertiesArr = listArr;
        self.isScene = isScene;
        self.preValue = 0;
        [self setUpComponent:title genericIndexVal:genricIndexVal];
    }
    return self;
}

-(void)setUpComponent:(NSString *)title genericIndexVal:(GenericIndexValue *)genericIndexValue{
    NSLog(@"setUpComponent hue component");
    
    self.labelView = [[labelAndCheckButtonView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, lableViewHeight)];
    self.labelView.isScene = self.isScene;
    [self.labelView setUpValues:[NSString stringWithFormat:@"  %@", title] withSelectButtonTitle:@"Select"];
    [self.labelView.selectButton addTarget:self action:@selector(onSelectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    int previousCount = [self getPreviousCount];
    if(previousCount )
        [self.labelView setSelected:YES];
    else
        [self.labelView setSelected:NO];
    [self.labelView setButtoncounter:previousCount isCountImageHiddn:self.isScene];//If self.isScene hide count button in select

    self.slider = [[SFISlider alloc]initWithFrame:CGRectMake(10, lableViewHeight, self.frame.size.width - 20, self.frame.size.height-lableViewHeight)];
    const CGFloat slider_x_offset = 10.0;
    const CGFloat slider_right_inset = 20.0;
    
    float min = (float)genericIndexValue.genericIndex.formatter.min;
    float max = (float)genericIndexValue.genericIndex.formatter.max;
    
    self.slider = [self makeSlider:1 maxValue:100 propertyType:SFIDevicePropertyType_BRIGHTNESS sliderLeftInset:slider_x_offset sliderRightInset:slider_right_inset slider:self.slider];
    
    self.slider.continuous = YES;
    self.slider.allowToSlide = YES;
    self.slider.sensorMaxValue = max;
    self.slider.convertedValue = 0; // to be assigned
    self.slider.backgroundColor = [UIColor lightGrayColor];
    self.slider.alpha = 0.3;
    
    if(self.isScene && _preValue != 0){
        if(self.subProperties.deviceType == SFIDeviceType_AlmondBlink_64)
            [self.slider setValue:[CommonMethods getBrightnessValue:@(_preValue).stringValue]];
        else
            [self.slider setConvertedValue:_preValue];
        self.slider.alpha = [self.slider value]/self.slider.maximumValue + 0.3;
    }
    
    NSLog(@" brightness slider adding ");
    
    [self addSubview:self.slider];
    [self addSubview:self.labelView];
}

- (SFISlider *)makeSlider:(float)minVal maxValue:(float)maxValue propertyType:(SFIDevicePropertyType)propertyType sliderLeftInset:(CGFloat)sliderLeftInset sliderRightInset:(CGFloat)sliderRightInset slider:(SFISlider*) slider {
    NSLog(@"drawSlider");
    slider.propertyType = propertyType;
    slider.minimumValue = minVal;
    slider.maximumValue = maxValue;
    slider.popUpViewColor = [UIColor redColor];
    slider.textColor = [UIColor whiteColor];
    slider.font = [UIFont securifiBoldFont:12];
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
    self.slider.alpha =  value / self.slider.maximumValue + 0.3;
    
    float sensorValue = [slider convertToSensorValue];
    NSString *newValue = [NSString stringWithFormat:@"%d", (int) sensorValue];
    NSLog(@"new sensor value: %@", newValue);
    self.subProperties.matchData = newValue;
    if(self.subProperties.deviceType == SFIDeviceType_AlmondBlink_64){
        newValue = @(slider.value).stringValue;
        newValue = @([self getConvertedValued:newValue]).stringValue;
        self.subProperties.matchData = newValue;
        NSLog(@"new decimal value: %@", newValue);
    }
    if(self.isScene){
        [self updateEntryForID:self.subProperties.deviceId index:self.subProperties.index matchData:newValue];
    }
}

-(int)getConvertedValued:(NSString *)newValue{
    //new value range is 0-100 only
//    if(newValue.intValue == 0){
//        newValue = @"1";
//    }
    float h, s, l;
    NSString *deviceValue = [Device getValueForIndex:3 deviceID:self.subProperties.deviceId];
    NSLog(@"rounded newvalue: %f, rgb value: %@", roundf(newValue.floatValue), deviceValue);
    [CommonMethods getHSLFromDecimal:deviceValue.intValue h:&h s:&s l:&l];
    l = roundf(newValue.floatValue) * 255.0 / 100.0; //had to convert to 255, only then its working.
    return [CommonMethods getRGBDecimalFromHSL:h s:s l:l];
}
- (void)onSliderDidEndSliding:(id)sender {
    SFISlider *slider = sender;
    float sensorValue = [slider convertToSensorValue];
    NSLog(@" sensor value %f",sensorValue);
    NSString *newValue = [NSString stringWithFormat:@"%d", (int) ceil(sensorValue)];
    self.subProperties.matchData = newValue;
    if(self.subProperties.deviceType == SFIDeviceType_AlmondBlink_64){
        newValue = @(slider.value).stringValue;
        newValue = @([self getConvertedValued:newValue]).stringValue;
        self.subProperties.matchData = newValue;
    }
    if(self.isScene){
        [self updateEntryForID:self.subProperties.deviceId index:self.subProperties.index matchData:newValue];
    }
    self.slider.alpha =  [slider value] / self.slider.maximumValue + 0.3;
}

-(void)onSelectButtonClick:(UIButton *)sender{
    NSLog(@"onSelectButtonClick");
    NSLog(@"subproperty match data: %@", self.subProperties.matchData);
    if(self.isScene){
        [self.labelView setSelected:!sender.selected];
        [self.delegate subpropertiesUpdate:self.subProperties isSelected:(BOOL)sender.selected];
        if(!sender.selected){
            [self.slider setValue:1];
            self.subProperties.matchData = @([self getConvertedValued:@"1"]).stringValue;
        }
        
    }
    else{
        [self.labelView setSelected:YES];
        [self.delegate subpropertiesUpdate:self.subProperties isSelected:(BOOL)sender.selected];
        //storing current value
        [self.labelView setButtoncounter:[self getPreviousCount] isCountImageHiddn:NO];
    }
}

-(int )getPreviousCount{
    int count = 0;
    for (SFIButtonSubProperties *properties in self.subPropertiesArr) {
        if(properties.index == self.subProperties.index && properties.deviceId == self.subProperties.deviceId){
            self.preValue = properties.matchData.intValue;
            count ++;
        }
    }
    return count;
}

-(void)updateEntryForID:(sfi_id)deviceId index:(int)index matchData:(NSString*)matchData{
    for(SFIButtonSubProperties *buttonProperties in self.subPropertiesArr){
        if(buttonProperties.deviceId == deviceId && buttonProperties.index == index){
            buttonProperties.matchData = matchData;
            [self.delegate updateArray];
            break;
        }
    }
}

@end
