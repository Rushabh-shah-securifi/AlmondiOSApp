//
// Created by Matthew Sinclair-Day on 6/9/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


// A container view for displaying a device's temperature.
@interface TemperatureView : UIView

// Required
// the actual temp value (e.g. 86.23)
// can contain a degrees symbol; when so, it is used and unitsSymbol is ignored
@property(nonatomic, copy) NSString *temperature;

// Optional
// used to specify the units, F or C
@property(nonatomic, copy) NSString *unitsSymbol;

// Optional
// when specified, the label is shown at the bottom of the view
// e.g. "Temperature" or "Set Point"
@property(nonatomic, copy) NSString *label;

// Optional
// defaults to clear color
@property(nonatomic, strong) UIColor *labelBackgroundColor;

// Optional
// defaults to white color
@property(nonatomic, strong) UIColor *labelTextColor;

@end