//
//  SliderComponentView.h
//  SecurifiApp
//
//  Created by Masood on 10/19/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "labelAndCheckButtonView.h"
#import "SFIButtonSubProperties.h"


@protocol SliderComponentViewDelegate
-(void)subpropertiesUpdate:(SFIButtonSubProperties*)subproperties isSelected:(BOOL)isSelected;
-(void) updateArray;
@end


@interface SliderComponentView : UIView

@property (nonatomic) id<SliderComponentViewDelegate> delegate;

-(id) initWithFrame:(CGRect)frame lableTitle:(NSString *)title isScene:(BOOL)isScene list:(NSArray *)listArr subproperties:(SFIButtonSubProperties*)subproperties genricIndexVal:(GenericIndexValue*)genricIndexVal;

@end
