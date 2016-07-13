//
//  HueColorPicker.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HueColorPicker.h"
#import "ILHuePickerView.h"
#import "CommonMethods.h"

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
    NSLog(@"initialize before");
    self.huePickerView = [[SFIHuePickerView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //this will overwrite value in setup (which is currently 65535)
    self.huePickerView.sensorMaxValue = self.genericIndexValue.genericIndex.formatter.max;

    NSLog(@"initialize after");
    self.huePickerView.convertedValue = 0;
    self.huePickerView.allowSelection = YES;
    self.huePickerView.delegate = self;
    self.huePickerView.propertyType = SFIDevicePropertyType_COLOR_HUE;
    float val = self.genericIndexValue.genericValue.value.floatValue;
    int deviceType = [Device getTypeForID:self.genericIndexValue.deviceID];
    
    
    if (deviceType ==  SFIDeviceType_AlmondBlink_64) {
        int RGB = self.genericIndexValue.genericValue.value.intValue;
        
        int r =  ((RGB & 0xF800) >> 8);
        int g = ((RGB & 0x7E0) >> 3);
        int b = ((RGB & 0x1F) << 3);
        NSLog(@"r= %d,g= %d,b=%d",r,g,b);

        CGFloat h, s, l;
        RVNColorRGBtoHSL(r, g, b,
                         &h, &s, &l);
        
        float value = (65535/255) * h;
        
        [self.huePickerView setConvertedValue:value];
        NSLog(@"colorhex = %f ,RGB = %d hue= %f",value,RGB,h);
    }
    else
    [self.huePickerView setConvertedValue:val];
    
    [self addSubview:self.huePickerView];
}

- (void)huePicked:(float)hue picker:(ILHuePickerView *)picker {
//        SFISlider *slider_saturation = [self sliderForDevicePropertyType:SFIDevicePropertyType_SATURATION];
    //    SFISlider *slider_brightness = [self sliderForDevicePropertyType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
    
    SFIHuePickerView *hue_picker = (SFIHuePickerView *) picker;
    float sensorValue = [hue_picker convertToSensorValue];
    NSString *sensor_value = [NSString stringWithFormat:@"%d", (int) sensorValue];
    NSString *hexColor = [CommonMethods getColorHex:sensor_value];

        int deviceType = [Device getTypeForID:self.genericIndexValue.deviceID];
    
    
    if (deviceType ==  SFIDeviceType_AlmondBlink_64) {//special handling for blink
        NSString *hexValue = [CommonMethods getColorHex:sensor_value];
        NSLog(@"value = %@",sensor_value);
        sensor_value = [NSString stringWithFormat:@"%d",[CommonMethods getRGBValueForBlink:hexValue]];
        NSLog(@"sensorvalue for almondBlink %@,hexVale = %@",sensor_value,hexValue);
    }
    
    [self.delegate save:sensor_value forGenericIndexValue:_genericIndexValue currentView:self];
    
    //    [self processColorTintChange:slider_brightness saturationSlider:slider_saturation huePicker:hue_picker];
    
  
    //    [self processColorPropertyValueChange:hue_picker.propertyType newValue:sensor_value];
    //    [self.delegate tableViewCellValueDidChange:self CellInfo:self.cellInfo Index:(int)hue_picker.tag Value:[NSString stringWithFormat:@"%d",sensor_value]];
    
}
static void RVNColorRGBtoHSL(CGFloat red, CGFloat green, CGFloat blue, CGFloat *hue, CGFloat *saturation, CGFloat *lightness)
{
    CGFloat r = red / 255.0f;
    CGFloat g = green / 255.0f;
    CGFloat b = blue / 255.0f;
    
    CGFloat max = MAX(r, g);
    max = MAX(max, b);
    CGFloat min = MIN(r, g);
    min = MIN(min, b);
    
    CGFloat h;
    CGFloat s;
    CGFloat l = (max + min) / 2.0f;
    
    if (max == min) {
        h = 0.0f;
        s = 0.0f;
    }
    
    else {
        CGFloat d = max - min;
        s = l > 0.5f ? d / (2.0f - max - min) : d / (max + min);
        
        if (max == r) {
            h = (g - b) / d + (g < b ? 6.0f : 0.0f);
        }
        
        else if (max == g) {
            h = (b - r) / d + 2.0f;
        }
        
        else if (max == b) {
            h = (r - g) / d + 4.0f;
        }
        
        h /= 6.0f;
    }
    
    if (hue) {
        *hue = roundf(h * 255.0f);
    }
    
    if (saturation) {
        *saturation = roundf(s * 255.0f);
    }
    
    if (lightness) {
        *lightness = roundf(l * 255.0f);
    }
}

@end
