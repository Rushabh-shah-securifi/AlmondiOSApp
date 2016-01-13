//
//  SFIPickerIndicatorView1.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 13/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFIPickerIndicatorView1.h"
#import "Colours.h"
@implementation SFIPickerIndicatorView1

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.color1 = [UIColor colorFromHexString:@"02a8f3"];
        self.backgroundColor = [UIColor colorFromHexString:@"02a8f3"];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self initializeControl:self.frame];
}

- (void)initializeControl:(CGRect)rect {
    CGColorRef white_ref = self.color1.CGColor;
    
    if (self.shapeLayer1) {
        [self.shapeLayer1 removeFromSuperlayer];
    }
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [self linePath:rect];
    layer.fillColor = white_ref;
    layer.strokeColor = white_ref;
    layer.lineWidth = self.frame.size.height;
    
    self.shapeLayer1 = layer;
    [self.layer addSublayer:layer];
}

- (CGPathRef)linePath:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    
    CGPoint point = CGPointMake(rect.size.width, 0);
    [path addLineToPoint:point];
    
    return path.CGPath;
}
@end


