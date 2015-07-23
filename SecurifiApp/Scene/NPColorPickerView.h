
#import <UIKit/UIKit.h>

@class NPColorPickerView;

@protocol NPColorPickerViewDelegate <NSObject> 

-(void)NPColorPickerView:(NPColorPickerView *)view didSelectColor:(UIColor *) color;

@end

extern NSString * kColorProperty;

@interface NPColorPickerView : UIView

@property (nonatomic, readwrite, strong) UIColor * color;
@property (nonatomic, readwrite, assign) UIEdgeInsets insets;
@property (nonatomic, readwrite, assign) CGFloat donutThickness;
@property (nonatomic, readwrite, assign) id<NPColorPickerViewDelegate> delegate;

@end
