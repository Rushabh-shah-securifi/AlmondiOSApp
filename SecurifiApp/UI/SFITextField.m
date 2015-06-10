//
// Created by Matthew Sinclair-Day on 6/10/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFITextField.h"


@interface SFITextField () <UITextFieldDelegate>
@end

@implementation SFITextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _mode = SFITextFieldMode_normal;
    }

    return self;
}

- (void)setMode:(SFITextFieldMode)mode {
    _mode = mode;

    if (mode == SFITextFieldMode_numbersOnly || mode == SFITextFieldMode_numbersInRange) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.delegate = self;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // validate numbers and number range only
    //
    if (self.mode != SFITextFieldMode_numbersOnly && self.mode != SFITextFieldMode_numbersInRange) {
        return YES;
    }

    NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    BOOL onlyNumbers = [string stringByTrimmingCharactersInSet:nonNumberSet].length == string.length;
    
    if (!onlyNumbers) {
        return NO;
    }

    // test for leading zeros
    NSString *new_str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (new_str.length == 0) {
        // empty is OK for now
        return YES;
    }

    if (self.mode == SFITextFieldMode_numbersInRange) {
        return [self ensureInNumberRange:new_str];
    }

    return YES;
}

- (BOOL)ensureInNumberRange:(NSString *)new_str {
    // test for leading zeros
    if ([new_str hasPrefix:@"0"]) {
        return NO;
    }

    NSInteger value = [new_str integerValue];
    return value >= self.minNumber && value <= self.maxNumber;
}

@end