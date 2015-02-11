//
// Created by Matthew Sinclair-Day on 2/9/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "CircleView.h"
#import "Colours.h"

@implementation CircleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.edgeColor = [UIColor pastelOrangeColor];
        self.fillColor = self.edgeColor;
        self.borderWidth = 5.0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    [self drawCircle:context];
    CGColorSpaceRelease(colorSpace);
}

- (void)drawCircle:(CGContextRef)ctx {
    CGSize canvasSize = self.bounds.size;
    CGFloat border_width = self.borderWidth;
    CGFloat scale = 1.0;

    CGContextSaveGState(ctx);

    UIColor *edgeColor = self.edgeColor;
    UIColor *fillColor = self.fillColor;

    // setup drawing attributes
    CGContextSetLineWidth(ctx, (CGFloat) (border_width * scale));
    CGContextSetStrokeColorWithColor(ctx, edgeColor.CGColor);
    CGContextSetFillColorWithColor(ctx, fillColor.CGColor);

    // setup the circle size
    CGRect circleRect = CGRectMake(0, 0, canvasSize.width, canvasSize.height);
    circleRect = CGRectInset(circleRect, border_width, border_width);

    // Draw the Circle
    CGContextFillEllipseInRect(ctx, circleRect);
    CGContextStrokeEllipseInRect(ctx, circleRect);

    CGContextRestoreGState(ctx);
}

@end