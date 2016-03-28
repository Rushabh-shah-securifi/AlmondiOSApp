//
//  Slider.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericProperty.h"
@protocol SliderViewDelegate
-(void)updateSliderValue:(NSString*)newvalue;
@end
@interface Slider : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic) NSInteger min;
@property (nonatomic) NSInteger max;
@property(nonatomic)id<SliderViewDelegate> delegate;

@property (nonatomic)GenericProperty *deviceProperty;
-(void)drawSlider;

@end
