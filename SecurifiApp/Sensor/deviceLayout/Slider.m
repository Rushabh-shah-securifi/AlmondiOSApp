//
//  Slider.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "Slider.h"
#import "SFISlider.h"
#import "UIFont+Securifi.h"
#import "SFIColors.h"
#import "Colours.h"
#import "CommonMethods.h"

@interface Slider()
@property (nonatomic)SFISlider *brightnessSlider;
@end

@implementation Slider
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.genericIndexValue = genericIndexValue;
        [self drawSlider];
        self.backgroundColor = self.color;
    }
    return self;
}

-(void)drawSlider{
    UIImageView *brightnessDim = [[UIImageView alloc]initWithFrame:CGRectMake(0, 3, self.frame.size.height, self.frame.size.height -3)];//dimmer_min
    brightnessDim.image = [UIImage imageNamed:@"dimmer_min"];
    
    [self addSubview:brightnessDim];
    UIImageView *brightnessFull = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.height, 3, self.frame.size.height -5, self.frame.size.height -5)];
    brightnessFull.image = [UIImage imageNamed:@"brightness-icon"];
//    brightnessDim.backgroundColor = [SFIColors ruleOrangeColor];
//    brightnessFull.backgroundColor = [SFIColors ruleOrangeColor];
    [self addSubview:brightnessFull];
    
    self.brightnessSlider = [[SFISlider alloc]initWithFrame:CGRectMake(self.frame.size.height , 0, self.frame.size.width - (2*self.frame.size.height), self.frame.size.height)];
    const CGFloat slider_x_offset = 10.0;
    const CGFloat slider_right_inset = 20.0;
    
    float min = (float)self.genericIndexValue.genericIndex.formatter.min;
    float max = (float)self.genericIndexValue.genericIndex.formatter.max;
    
    self.brightnessSlider = [self makeSlider:min maxValue:max propertyType:SFIDevicePropertyType_BRIGHTNESS sliderLeftInset:slider_x_offset sliderRightInset:slider_right_inset slider:self.brightnessSlider];
    
    self.brightnessSlider.continuous = YES;
    self.brightnessSlider.allowToSlide = YES;
    self.brightnessSlider.sensorMaxValue = max;
    self.brightnessSlider.convertedValue = 0; // to be assigned
//    brightnessSlider.backgroundColor = [SFIColors ruleOrangeColor];
    NSLog(@"slider transformed value: %d", [self.genericIndexValue.genericValue.transformedValue intValue]);
    
    [self.brightnessSlider setValue:[self.genericIndexValue.genericValue.transformedValue intValue]];
    NSLog(@" brightness slider adding ");
    [self addSubview:self.brightnessSlider];
}

- (SFISlider *)makeSlider:(float)minVal maxValue:(float)maxValue propertyType:(SFIDevicePropertyType)propertyType sliderLeftInset:(CGFloat)sliderLeftInset sliderRightInset:(CGFloat)sliderRightInset slider:(SFISlider*) slider {
    NSLog(@"drawSlider");
    slider.propertyType = propertyType;
    slider.minimumValue = minVal;
    slider.maximumValue = maxValue;
    slider.popUpViewColor = [self darkerColorForColor:self.color];//[self.color complementaryColor];
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
    
    int sensorValue = [slider getConvertedValue:self.genericIndexValue.genericIndex.formatter.factor];
    NSString *newValue = [NSString stringWithFormat:@"%d", (int) sensorValue];
    int deviceType = [Device getTypeForID:self.genericIndexValue.deviceID];
    ;
    if (deviceType ==  SFIDeviceType_AlmondBlink_64) {
        [self.delegate blinkNew:newValue];
        return;
    }
    NSLog(@"end sliding new value: %@", newValue);
    [self.delegate save:newValue forGenericIndexValue:_genericIndexValue currentView:self];
    
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
    
    int sensorValue = [slider getConvertedValue:self.genericIndexValue.genericIndex.formatter.factor];
    
    NSString *newValue = [NSString stringWithFormat:@"%d", (int) sensorValue];
    int deviceType = [Device getTypeForID:self.genericIndexValue.deviceID];
    ;
    if (deviceType ==  SFIDeviceType_AlmondBlink_64) {
        [self.delegate blinkNew:newValue];
        return;
    }
    [self.delegate save:newValue forGenericIndexValue:_genericIndexValue currentView:self];
}

//-(int)getConvertedValue:(
- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

-(void)setSliderValue:(int)value{
    [self.brightnessSlider setValue:value animated:YES];
}
@end
