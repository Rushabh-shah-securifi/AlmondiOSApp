#import <UIKit/UIKit.h>
@class NPColorPickerView;

@interface NPPickerIndicator : UIView 

@property (nonatomic, readwrite, assign) UIEdgeInsets insets;
@property (nonatomic, readwrite) UIColor * fillColor;
@property (nonatomic, readwrite, assign) CGFloat borderWidth;
@property (nonatomic, readwrite, weak) NPColorPickerView * pickerView;
 
@end
