//
//  HorzSlider.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <V8HorizontalPickerView/V8HorizontalPickerView.h>
#import "GenericProperty.h"
#import "Device.h"
@protocol HorzSliderDelegate
-(void)updatePickerValue:(NSString *)newValue;
@end
@interface HorzSlider : UIView
@property (nonatomic) NSInteger  min;
@property (nonatomic) NSInteger max;
@property (nonatomic)id<HorzSliderDelegate> delegate;
@property (nonatomic)UIColor *color;
@property (nonatomic)GenericProperty *deviceProperty;


-(void)drawSlider;
@end
