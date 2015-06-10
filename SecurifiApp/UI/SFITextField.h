//
// Created by Matthew Sinclair-Day on 6/10/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

typedef NS_ENUM(unsigned int, SFITextFieldMode) {
    SFITextFieldMode_normal,            // default: standard UITextField
    SFITextFieldMode_numbersOnly,       // validates input is a number
    SFITextFieldMode_numbersInRange     // validates input is a number and within specified max and min range
};

@interface SFITextField : UITextField

// Useful for tagging to associate the value with the underlying property type
@property(nonatomic) SFIDevicePropertyType propertyType;

// optional
// defaults to SFITextFieldMode_normal
@property(nonatomic) SFITextFieldMode mode;

// optional
// used when mode is SFITextFieldMode_numbersInRange
@property(nonatomic) NSUInteger minNumber;
@property(nonatomic) NSUInteger maxNumber;

@end