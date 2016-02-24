//
//  HueSliderView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HueSliderView.h"
#import "SFISlider.h"
#import "UIFont+Securifi.h"
#import "SFIColors.h"

@implementation HueSliderView
-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
    //    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)drawSlider{
    SFISlider *brightnessSlider = [[SFISlider alloc]initWithFrame:self.frame];
    const CGFloat slider_x_offset = 10.0;
    const CGFloat slider_right_inset = 20.0;
    brightnessSlider = [self makeSlider:0 maxValue:100 propertyType:SFIDevicePropertyType_BRIGHTNESS sliderLeftInset:slider_x_offset sliderRightInset:slider_right_inset slider:brightnessSlider];
    
    brightnessSlider.continuous = YES;
    brightnessSlider.allowToSlide = YES;
    brightnessSlider.sensorMaxValue = 255;
    brightnessSlider.convertedValue = 0; // to be assigned
    brightnessSlider.backgroundColor = [UIColor clearColor];
    [self addSubview:brightnessSlider];
}
- (SFISlider *)makeSlider:(float)minVal maxValue:(float)maxValue propertyType:(SFIDevicePropertyType)propertyType sliderLeftInset:(CGFloat)sliderLeftInset sliderRightInset:(CGFloat)sliderRightInset slider:(SFISlider*) slider {
    slider.propertyType = propertyType;
    slider.minimumValue = minVal;
    slider.maximumValue = maxValue;
    slider.popUpViewColor = [SFIColors clientGreenColor];//[self.color complementaryColor];
    slider.textColor = [UIColor whiteColor];//[slider.popUpViewColor blackOrWhiteContrastingColor];
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

- (void)onSliderDidEndSliding:(id)sender {
    SFISlider *slider = sender;
    
    float sensorValue = [slider convertToSensorValue];
    NSString *newValue = [NSString stringWithFormat:@"%d", (int) sensorValue];
    
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
    //[self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)slider.tag Value:newValue];
}



@end
