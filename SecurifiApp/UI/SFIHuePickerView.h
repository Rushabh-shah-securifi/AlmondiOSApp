//
// Created by Matthew Sinclair-Day on 4/13/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "ILHuePickerView.h"


@interface SFIHuePickerView : ILHuePickerView

// Useful for tagging to associate the value with the underlying property type
@property(nonatomic) SFIDevicePropertyType propertyType;

// Specifies the maximum permitted value by the sensor (e.g. "65535")
// This value is used for converting between a "sensor" value and the picker's hue value range
@property(nonatomic) int sensorMaxValue;

// Converts the sensors value to the scale used by this slider
- (void)setConvertedValue:(float)sensorValue;

// Converts the current slider value to the scale used by the sensor
- (float)convertToSensorValue;

@end