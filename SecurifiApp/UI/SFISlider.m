//
//  SFISlider.h
//
//  Created by sinclair on 8/5/14.
//
#import "SFISlider.h"


@implementation SFISlider

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoAdjustTrackColor = NO;
        self.allowToSlide = YES;
    }

    return self;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumb_rect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    thumb_rect = CGRectInset(thumb_rect, -10, -10);
    return thumb_rect;
}

- (void)setConvertedValue:(float)sensorValue {
    float ratio = self.maximumValue / (float) self.sensorMaxValue;
    float sliderValue = sensorValue * ratio;
    sliderValue = roundf(sliderValue);
    [self setValue:sliderValue animated:NO];
}

- (float)convertToSensorValue {
    float slider_value = self.value;
    float scale_factor = (self.sensorMaxValue / self.maximumValue);
    float value = slider_value * scale_factor;
    value = roundf(value);
    return value;
}

- (NSString *)sliderFormattedValue {
    return [self.numberFormatter stringFromNumber:@(self.value)];
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //md01
    if (!self.allowToSlide) {
        [super cancelTrackingWithEvent:event];
        return NO;
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

@end