//
// Created by Matthew Sinclair-Day on 6/10/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFITextField.h"


@interface SFITextField () <UITextFieldDelegate>
@property(nonatomic, weak) id <UITextFieldDelegate> registeredDelegate;
@end

@implementation SFITextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _mode = SFITextFieldMode_normal;
    }

    return self;
}

#pragma mark - Special delegate handling

- (void)setDelegate:(id <UITextFieldDelegate>)delegate {
    if (delegate == self) {
        return;
    }
    self.registeredDelegate = delegate;
    super.delegate = delegate;
}

#pragma mark - Mode

- (void)setMode:(SFITextFieldMode)mode {
    _mode = mode;

    if (mode == SFITextFieldMode_numbersOnly || mode == SFITextFieldMode_numbersInRange) {
        self.keyboardType = UIKeyboardTypeNumberPad;
        super.delegate = self;
    }
    else if (self.registeredDelegate) {
        super.delegate = self.registeredDelegate;
    }
    else {
        super.delegate = nil;
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    id <UITextFieldDelegate> de = self.registeredDelegate;
    if (de && [de respondsToSelector:@selector(textFieldShouldBeginEditing:)]) {
        [de textFieldShouldBeginEditing:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    id <UITextFieldDelegate> de = self.registeredDelegate;
    if (de && [de respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [de textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    id <UITextFieldDelegate> de = self.registeredDelegate;
    if (de && [de respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
        [de textFieldShouldEndEditing:textField];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    id <UITextFieldDelegate> de = self.registeredDelegate;
    if (de && [de respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [de textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    id <UITextFieldDelegate> de = self.registeredDelegate;
    if (de && [de respondsToSelector:@selector(textFieldShouldClear:)]) {
        [de textFieldShouldClear:textField];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    id <UITextFieldDelegate> de = self.registeredDelegate;
    if (de && [de respondsToSelector:@selector(textFieldShouldReturn:)]) {
        [de textFieldShouldReturn:textField];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // validate numbers and number range only
    //
    if (self.mode != SFITextFieldMode_numbersOnly && self.mode != SFITextFieldMode_numbersInRange) {
        id <UITextFieldDelegate> de = self.registeredDelegate;
        if (de && [de respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            return [de textField:textField shouldChangeCharactersInRange:range replacementString:string];
        }
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