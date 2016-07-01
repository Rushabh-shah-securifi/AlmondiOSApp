//
//  ColorComponentView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 30/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "labelAndCheckButtonView.h"
#import "SFIHuePickerView.h"
#import "SFIButtonSubProperties.h"
@protocol ColorComponentViewDelegate
@optional
-(void)saveNewValue:(int)val;
-(void)subpropertiesUpdate:(SFIButtonSubProperties*)subproperties isSelected:(BOOL)isSelected;

@end
@interface ColorComponentView : UIView
@property(nonatomic)labelAndCheckButtonView *labelView;
@property(nonatomic)id<ColorComponentViewDelegate> delegate;
@property(nonatomic)SFIHuePickerView *huePicker;



-(id) initWithFrame:(CGRect)frame setUpValue:(NSString *)value ButtonTitle:(NSString *)title andIsScene:(BOOL)isScene list:(NSArray *)listArr subproperties:(SFIButtonSubProperties*)subproperties;
@end
