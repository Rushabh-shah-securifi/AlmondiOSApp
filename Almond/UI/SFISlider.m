//
//  SFISlider.h
//
//  Created by sinclair on 8/5/14.
//
#import "SFISlider.h"


@implementation SFISlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thumb_rect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    thumb_rect = CGRectInset(thumb_rect, -10, -10);
    return thumb_rect;
}


@end