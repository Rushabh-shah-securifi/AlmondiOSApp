#import "NPPickerIndicator.h"
#import "NPColorPickerView.h"
#import <QuartzCore/QuartzCore.h>
@implementation NPPickerIndicator

@synthesize insets;
@synthesize borderWidth;
@synthesize fillColor = fillColor_;
@synthesize pickerView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       borderWidth = 10;
       self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
   CGContextRef context = UIGraphicsGetCurrentContext();
   CGRect viewFrame = self.bounds;
   
   viewFrame = (CGRect) { viewFrame.origin.x + self.insets.left, viewFrame.origin.y+ self.insets.top,
      viewFrame.size.width - self.insets.left - self.insets.right, viewFrame.size.height - self.insets.top - self.insets.bottom};
   
   CGFloat maxRadius = MIN(viewFrame.size.width, viewFrame.size.height) / 2;
   CGFloat internalRadius = maxRadius - borderWidth;
   CGPoint center = CGPointMake(CGRectGetMidX(viewFrame), CGRectGetMidY(viewFrame));

   CGMutablePathRef path = CGPathCreateMutable();
   CGPathAddRelativeArc(path, &CGAffineTransformIdentity, center.x, center.y, internalRadius, 0, 2*M_PI);
   CGContextSaveGState(context);
   
   // internal color
   CGContextAddPath(context, path);
   CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
   CGContextDrawPath(context, kCGPathFill);

   // outline
   CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
   CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
   CGPathMoveToPoint(path, &CGAffineTransformIdentity, center.x + maxRadius, center.y);
   CGPathAddRelativeArc(path, &CGAffineTransformIdentity, center.x, center.y, maxRadius, 0, 2*M_PI);
   CGContextAddPath(context, path);
   CGContextDrawPath(context, kCGPathEOFillStroke);
   CGContextRestoreGState(context);
   CGPathRelease(path);
}

@end
