//
//  ColorComponentView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 30/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ColorComponentView.h"
#import "RulesConstants.h"
#import "ILHuePickerView.h"

@interface ColorComponentView ()<ILHuePickerViewDelegate>
@property (nonatomic) BOOL isScene;
@property(nonatomic)NSArray *subPropertiesArr;
@property(nonatomic)SFIButtonSubProperties *subProperties;
@property(nonatomic)CGFloat preValue;
@end

@implementation ColorComponentView

-(id) initWithFrame:(CGRect)frame setUpValue:(NSString *)value ButtonTitle:(NSString *)title andIsScene:(BOOL)isScene list:(NSArray *)listArr subproperties:(SFIButtonSubProperties*)subproperties;
{
    self = [super initWithFrame:frame];
    if(self){
        [self setUpComponent:value ButtonTitle:title andIsScene:isScene list:listArr subproperties:(SFIButtonSubProperties*)subproperties];
    }
    return self;
}
-(void)setUpComponent:(NSString *)value ButtonTitle:(NSString *)title andIsScene:(BOOL)isScene list:(NSArray *)listArr subproperties:(SFIButtonSubProperties*)subproperties{
    NSLog(@"setUpComponent hue component");
    self.subProperties = subproperties;
    self.subPropertiesArr = listArr;
    self.isScene = isScene;
    self.labelView = [[labelAndCheckButtonView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, hueSubViewSize)];
    self.labelView.isScene = YES;
    [self.labelView setUpValues:@"  Hue" withSelectButtonTitle:@"Select"];
    [self.labelView.selectButton addTarget:self action:@selector(onSelectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    int previousCount = [self getPreviousCount];
    if(previousCount )
        [self.labelView setSelected:YES];
    else
        [self.labelView setSelected:NO];
    [self.labelView setButtoncounter:previousCount isCountImageHiddn:self.isScene];//If self.isScene hide count button in select
    
    self.huePicker = [[SFIHuePickerView alloc]initWithFrame:CGRectMake(0, hueSubViewSize,self.frame.size.width ,self.frame.size.height-hueSubViewSize)];
    self.huePicker.convertedValue = 0;
    self.huePicker.delegate = self;
    self.huePicker.allowSelection = YES;
    NSLog(@"previous val = %f",self.preValue);
    if(self.isScene){
        [self.huePicker setConvertedValue:self.preValue];
    }

    [self addSubview:self.huePicker];
    [self addSubview:self.labelView];
    
    
}
- (void)huePicked:(float)hue picker:(ILHuePickerView *)picker {

    //    [self processColorTintChange:slider_brightness saturationSlider:slider_saturation huePicker:hue_picker];
    
    int sensor_value = [self.huePicker convertToSensorValue];
    [self saveNewValue:sensor_value];
    
}
-(void)onSelectButtonClick:(UIButton *)sender{
    NSLog(@"onSelectButtonClick");
    if(self.isScene){
        [self.labelView setSelected:!sender.selected];
        [self.delegate subpropertiesUpdate:self.subProperties isSelected:(BOOL)sender.selected];
        if(!sender.selected)
            [self.huePicker setConvertedValue:0];
    }
    else{
        [self.labelView setSelected:YES];
        [self.delegate subpropertiesUpdate:self.subProperties isSelected:(BOOL)sender.selected];
        //storing current value
        [self.labelView setButtoncounter:[self getPreviousCount] isCountImageHiddn:NO];
    }
    
    
    
}
-(void )saveNewValue:(int)sensor_value{
    NSLog(@"saveNewValue: %d",sensor_value);
    self.subProperties.matchData = @(sensor_value).stringValue;
}
-(int )getPreviousCount{
    int count = 0;
    NSLog(@"self.subProperties.index %d ,self.subProperties.deviceId %d \n",self.subProperties.index,self.subProperties.deviceId);
    for (SFIButtonSubProperties *properties in self.subPropertiesArr) {
        NSLog(@"properties.index %d ,properties.deviceId %d \n",properties.index,properties.deviceId);
        if(properties.index == self.subProperties.index && properties.deviceId == self.subProperties.deviceId)
            self.preValue = properties.matchData.floatValue;
        NSLog(@"properties.matchData %@",properties.matchData);
            count ++;
    }
    NSLog(@"count = %d",count);
    return count;
}
@end
