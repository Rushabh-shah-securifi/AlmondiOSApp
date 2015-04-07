//
//  ILColorPicker.m
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/2/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import "ILColorPickerView.h"


@interface ILColorPickerView ()
@property(nonatomic, strong) ILSaturationBrightnessPickerView *satPicker;
@property(nonatomic, strong) ILHuePickerView *huePicker;
@end

@implementation ILColorPickerView

#pragma mark - Setup

- (void)setup {
    [super setup];

    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];

    self.huePicker = [[ILHuePickerView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.huePicker];

    self.pickerLayout = ILColorPickerViewLayoutBottom;
}

#pragma mark - Property Set/Get

- (void)setPickerLayout:(ILColorPickerViewLayout)layout {
    _pickerLayout = layout;

    if (self.satPicker != nil) {
        [self.satPicker removeFromSuperview];
        self.satPicker = nil;
    }

    if (layout == ILColorPickerViewLayoutBottom) {
        self.huePicker.pickerOrientation = ILHuePickerViewOrientationHorizontal;
        [self.huePicker setFrame:CGRectMake(0, self.frame.size.height - 38, self.frame.size.width, 38)];

        self.satPicker = [[ILSaturationBrightnessPickerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 10 - 38)];
        self.satPicker.delegate = self;
        self.huePicker.delegate = self.satPicker;
        [self addSubview:self.satPicker];
    }
    else {
        self.huePicker.pickerOrientation = ILHuePickerViewOrientationVertical;
        [self.huePicker setFrame:CGRectMake(self.frame.size.width - 38, 0, 38, self.frame.size.height)];

        self.satPicker = [[ILSaturationBrightnessPickerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 10 - 38, self.frame.size.height)];
        self.satPicker.delegate = self;
        self.huePicker.delegate = self.satPicker;
        [self addSubview:self.satPicker];
    }
}

- (UIColor *)color {
    return self.satPicker.color;
}

- (void)setColor:(UIColor *)c {
    self.satPicker.color = c;
    self.huePicker.color = c;
}

#pragma mark - ILSaturationBrightnessPickerDelegate

- (void)colorPicked:(UIColor *)newColor forPicker:(ILSaturationBrightnessPickerView *)picker {
    [self.delegate colorPicked:newColor forPicker:self];
}

@end
