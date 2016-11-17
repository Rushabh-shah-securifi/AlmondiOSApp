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
    [self.huePickerView setConvertedValue:val];
    
    [self addSubview:self.huePickerView];
}

- (void)huePicked:(float)hue picker:(ILHuePickerView *)picker {
    SFIHuePickerView *hue_picker = (SFIHuePickerView *) picker;
    float sensorValue = [hue_picker convertToSensorValue];
    NSString *sensor_value = [NSString stringWithFormat:@"%d", (int) sensorValue];
    
    [self.delegate save:sensor_value forGenericIndexValue:_genericIndexValue currentView:self];
}


@end