//
// Created by Matthew Sinclair-Day on 6/9/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "TemperatureView.h"
#import "UIFont+Securifi.h"

#define DEF_DEGREES_SYMBOL      @"\u00B0"

@interface TemperatureView ()
@property(nonatomic, weak) UILabel *temperatureLabel;
@property(nonatomic, weak) UILabel *decimalLabel;
@property(nonatomic, weak) UILabel *degreeLabel;
@property(nonatomic, weak) UILabel *descriptionLabel;
@end

@implementation TemperatureView

- (UIColor *)labelBackgroundColor {
    if (!_labelBackgroundColor) {
        return [UIColor clearColor];
    }
    return _labelBackgroundColor;
}

- (UIColor *)labelTextColor {
    if (!_labelTextColor) {
        return [UIColor whiteColor];
    }
    return _labelTextColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // For Integer Value
    [self layoutDeviceValueLabel];

    // For Decimal Value
    [self layoutDecimalValueLabel];

    // For Degree
    [self layoutDegreeLabel];

    [self layoutDescriptionLabel];

    [self setTemperatureValue:self.temperature];
}

- (void)layoutDeviceValueLabel {
    [self.temperatureLabel removeFromSuperview];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 5, 12, 60, 70)];
    label.backgroundColor = self.labelBackgroundColor;
    label.textColor = self.labelTextColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont securifiBoldFont:45];

    [self addSubview:label];
    self.temperatureLabel = label;
}

- (void)layoutDecimalValueLabel {
    [self.decimalLabel removeFromSuperview];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 20, 40, 20, 30)];
    label.backgroundColor = self.labelBackgroundColor;
    label.textColor = self.labelTextColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    label.font = [UIFont securifiBoldFont:18];

    [self addSubview:label];
    self.decimalLabel = label;
}

- (void)layoutDegreeLabel {
    [self.degreeLabel removeFromSuperview];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 20, 25, 40, 30)];
    label.backgroundColor = self.labelBackgroundColor;
    label.textColor = self.labelTextColor;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont standardHeadingBoldFont];

    [self addSubview:label];
    self.degreeLabel = label;
}

- (void)layoutDescriptionLabel {
    if (self.label) {
        [self.descriptionLabel removeFromSuperview];

        UILabel *label = [[UILabel alloc] initWithFrame:self.frame];
        label.backgroundColor = self.labelBackgroundColor;
        label.textColor = self.labelTextColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont standardUILabelFont];
        label.text = self.label;
        //
        [label sizeToFit];
        label.frame = [self pinToButton:label.frame];

        [self addSubview:label];
        self.descriptionLabel = label;
    }
}

- (NSString *)degreeLabelText {
    if (self.unitsSymbol) {
        return [NSString stringWithFormat:@"%@%@", DEF_DEGREES_SYMBOL, self.unitsSymbol];
    }
    else {
        return DEF_DEGREES_SYMBOL;
    }
}

- (CGRect)pinToButton:(CGRect)frame {
    CGFloat super_height = CGRectGetHeight(self.frame);
    CGFloat cell_y = CGRectGetMaxY(frame);
    CGFloat cell_height = CGRectGetHeight(frame);
    CGFloat y_offset = super_height - cell_height - cell_y;

    CGFloat super_width = CGRectGetWidth(self.frame);

    return CGRectMake(10, y_offset, super_width, cell_height);
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

    self.temperatureLabel.text = integerValue;

    if (decimalValue.length > 0) {
        self.decimalLabel.text = [NSString stringWithFormat:@".%@", decimalValue];
    }
    else {
        self.decimalLabel.text = nil;
    }

    if (degreesValue.length > 0) {
        self.degreeLabel.text = degreesValue;
    }
    else {
        self.degreeLabel.text = self.degreeLabelText;
    }

    const CGFloat cell_width = CGRectGetWidth(self.frame);

    NSUInteger integerValue_length = integerValue.length;
    if (integerValue_length == 1) {
        self.decimalLabel.frame = CGRectMake((cell_width / 4) - 25, 40, 20, 30);
        self.degreeLabel.frame = CGRectMake(cell_width - 25, 25, 20, 20);
    }
    else if (integerValue_length == 3) {
        self.temperatureLabel.font = [heavy_14 fontWithSize:30];
        self.decimalLabel.font = heavy_14;
        self.degreeLabel.font = heavy_14;

        self.decimalLabel.frame = CGRectMake(cell_width - 10, 38, 20, 30);
        self.degreeLabel.frame = CGRectMake(cell_width - 10, 30, 20, 20);
    }
    else if (integerValue_length == 4) {
        UIFont *heavy_10 = [heavy_14 fontWithSize:10];

        self.temperatureLabel.font = [heavy_14 fontWithSize:22];
        self.decimalLabel.font = heavy_10;
        self.degreeLabel.font = heavy_10;

        self.decimalLabel.frame = CGRectMake(cell_width - 12, 35, 20, 30);
        self.degreeLabel.frame = CGRectMake(cell_width - 12, 30, 20, 20);
    }
}

@end