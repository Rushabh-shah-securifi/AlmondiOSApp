//
// Created by Matthew Sinclair-Day on 4/13/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIHuePickerView.h"


@implementation SFIHuePickerView

- (void)setup {
    [super setup];
    self.sensorMaxValue = 65535;
}

- (void)setConvertedValue:(float)sensorValue {
    self.hue = sensorValue / self.sensorMaxValue;
}

- (float)convertToSensorValue {
    return self.hue * self.sensorMaxValue;
}


@end