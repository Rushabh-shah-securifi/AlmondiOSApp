//
// Created by Matthew Sinclair-Day on 6/9/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "TemperatureView.h"
#import "UIFont+Securifi.h"

#define LEFT_LABEL_WIDTH        100
#define DEF_DEGREES_SYMBOL      @"\u00B0"

@interface TemperatureView ()
@property(nonatomic) UILabel *deviceValueLabel;
@property(nonatomic) UILabel *decimalValueLabel;
@property(nonatomic) UILabel *degreeLabel;
@end

@implementation TemperatureView

- (void)layoutSubviews {
    [super layoutSubviews];

    UIColor *clear_color = [UIColor clearColor];
    UIColor *white_color = [UIColor whiteColor];

    // In case of thermostat show value instead of image
    // For Integer Value
    [self.deviceValueLabel removeFromSuperview];
    self.deviceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 5, 12, 60, 70)];
    self.deviceValueLabel.backgroundColor = clear_color;
    self.deviceValueLabel.textColor = white_color;
    self.deviceValueLabel.textAlignment = NSTextAlignmentCenter;
    self.deviceValueLabel.font = [UIFont securifiBoldFont:45];

    // For Decimal Value
    [self.decimalValueLabel removeFromSuperview];
    self.decimalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 20, 40, 20, 30)];
    self.decimalValueLabel.backgroundColor = clear_color;
    self.decimalValueLabel.textColor = white_color;
    self.decimalValueLabel.textAlignment = NSTextAlignmentCenter;
    self.decimalValueLabel.adjustsFontSizeToFitWidth = YES;
    self.decimalValueLabel.font = [UIFont securifiBoldFont:18];

    // For Degree
    [self.degreeLabel removeFromSuperview];
    self.degreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 20, 25, 20, 20)];
    self.degreeLabel.backgroundColor = clear_color;
    self.degreeLabel.textColor = white_color;
    self.degreeLabel.textAlignment = NSTextAlignmentCenter;
    self.degreeLabel.font = [UIFont standardHeadingBoldFont];
    self.degreeLabel.text = DEF_DEGREES_SYMBOL; // degree sign

    [self addSubview:self.deviceValueLabel];
    [self addSubview:self.decimalValueLabel];
    [self addSubview:self.degreeLabel];

    [self setTemperatureValue:self.temperature];
}

- (void)setTemperatureValue:(NSString *)value {
    NSArray *tempValues = [value componentsSeparatedByString:@"."];
    switch ([tempValues count]) {
        case 0: {
            [self setTemperatureIntegerValue:nil decimalValue:nil degreesValue:nil];
            break;
        }
        case 1: {
            [self setTemperatureIntegerValue:tempValues[0] decimalValue:nil degreesValue:nil];
            break;
        }
        default: {
            NSString *decimal = tempValues[1];
            NSString *degrees = nil;

            // check for embedded degrees marker
            NSRange range = [decimal rangeOfString:DEF_DEGREES_SYMBOL];
            if (range.length > 0) {
                degrees = [decimal substringFromIndex:range.location];
                decimal = [decimal substringToIndex:range.location];
            }

            [self setTemperatureIntegerValue:tempValues[0] decimalValue:decimal degreesValue:degrees];
            break;
        }
    }
}

- (void)setTemperatureIntegerValue:(NSString *)integerValue decimalValue:(NSString *)decimalValue degreesValue:(NSString *)degreesValue {
    UIFont *heavy_14 = [UIFont securifiBoldFontLarge];

    self.deviceValueLabel.text = integerValue;

    if (decimalValue.length > 0) {
        self.decimalValueLabel.text = [NSString stringWithFormat:@".%@", decimalValue];
    }
    else {
        self.decimalValueLabel.text = nil;
    }

    if (degreesValue.length > 0) {
        self.degreeLabel.text = degreesValue;
    }
    else {
        self.degreeLabel.text = DEF_DEGREES_SYMBOL;
    }

    NSUInteger integerValue_length = [integerValue length];
    if (integerValue_length == 1) {
        self.decimalValueLabel.frame = CGRectMake((self.frame.size.width / 4) - 25, 40, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 25, 20, 20);
    }
    else if (integerValue_length == 3) {
        self.deviceValueLabel.font = [heavy_14 fontWithSize:30];
        self.decimalValueLabel.font = heavy_14;
        self.degreeLabel.font = heavy_14;

        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 38, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 30, 20, 20);
    }
    else if (integerValue_length == 4) {
        UIFont *heavy_10 = [heavy_14 fontWithSize:10];

        self.deviceValueLabel.font = [heavy_14 fontWithSize:22];
        self.decimalValueLabel.font = heavy_10;
        self.degreeLabel.font = heavy_10;

        self.decimalValueLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 35, 20, 30);
        self.degreeLabel.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 30, 20, 20);
    }
}

@end