#import <Foundation/Foundation.h>

@interface NPConicGradient : NSObject {
   NSMutableArray * positions_;
}

typedef void (^Interpolater)(CGFloat percent, CGFloat sourceComps[], CGFloat endComps[], CGFloat outCompts[], size_t s) ;

@property (nonatomic, readwrite, assign) CGPoint center;
@property (nonatomic, readwrite, assign) CGFloat radius;
@property (nonatomic, readwrite, assign) CGFloat startAngle;
@property (nonatomic, readwrite, assign) CGFloat endAngle;
@property (nonatomic, readwrite, copy) Interpolater interpolater;
@property (nonatomic, readwrite, assign) NSUInteger interstices;


-(void)addColor:(UIColor *)color atPosition:(CGFloat) position;
-(void)drawInContext:(CGContextRef) context;

@end
