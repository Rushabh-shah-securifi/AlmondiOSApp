//
//  SFISlider.h
//
//  Created by sinclair on 8/5/14.
//
#import <Foundation/Foundation.h>
#import "ASValueTrackingSlider.h"


// A slider that has a larger thumb area for tracking touch events and knows how to convert from a sensor's value range
// to the slider's range. The sensor's value range is expressed through the property sensorMaxValue, and the slider
// can convert from a sensor's current device value and back using the methods setConvertedValue: and convertToSensorValue.
@interface SFISlider : ASValueTrackingSlider

// Useful for tagging to associate the value with the underlying property type
@property(nonatomic) SFIDevicePropertyType propertyType;

// Specifies the maximum permitted value by the sensor (e.g. "255")
// This value is converted to the slider's maxValue
@property(nonatomic) int sensorMinValue;
@property(nonatomic) int sensorMaxValue;

// Converts the sensors value to the scale used by this slider
- (void)setConvertedValue:(float)sensorValue;

// Converts the current slider value to the scale used by the sensor
- (float)convertToSensorValue;

// Returns a string indicating the current slider value
- (NSString *)sliderFormattedValue;

@end