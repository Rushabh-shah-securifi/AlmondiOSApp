//
//  HueColorPicker.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HueColorPicker.h"
#import "ILHuePickerView.h"
#import "SFIHuePickerView.h"
@interface HueColorPicker ()<ILHuePickerViewDelegate>
@end
@implementation HueColorPicker

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.genericIndexValue = genericIndexValue;
        [self drawHueColorPicker];
    }
    return self;
}
-(void)drawHueColorPicker{
    
    SFIHuePickerView *huePickerView = [[SFIHuePickerView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    huePickerView.convertedValue = 0;
    huePickerView.allowSelection = YES;
    huePickerView.delegate = self;
    huePickerView.propertyType = SFIDevicePropertyType_COLOR_HUE;
    [huePickerView setConvertedValue:50000];
    [self addSubview:huePickerView];
    
    
}
- (void)huePicked:(float)hue picker:(ILHuePickerView *)picker {
    //    SFISlider *slider_saturation = [self sliderForDevicePropertyType:SFIDevicePropertyType_SATURATION];
    //    SFISlider *slider_brightness = [self sliderForDevicePropertyType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
    
    SFIHuePickerView *hue_picker = (SFIHuePickerView *) picker;
     NSString *sensor_value = @([hue_picker convertToSensorValue]).stringValue;
    [self.delegate saveDeviceNewValue:sensor_value forGenericIndexValue:_genericIndexValue];
    
    //    [self processColorTintChange:slider_brightness saturationSlider:slider_saturation huePicker:hue_picker];
    
  
    //    [self processColorPropertyValueChange:hue_picker.propertyType newValue:sensor_value];
    //    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)hue_picker.tag Value:[NSString stringWithFormat:@"%d",sensor_value]];
    
}

@end
