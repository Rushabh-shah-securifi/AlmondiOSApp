//
//  HorizontalPicker.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <V8HorizontalPickerView/V8HorizontalPickerView.h>
#import "GenericIndexValue.h"
#import "Device.h"
@protocol HorzSliderDelegate
-(void)save:(NSString *)newValue forGenericIndexValue:(GenericIndexValue *)genericIndexValue;
@end
@interface HorizontalPicker : UIView
@property (nonatomic)id<HorzSliderDelegate> delegate;
@property (nonatomic)UIColor *color;
@property (nonatomic)GenericIndexValue *genericIndexValue;
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue;

-(void)drawSlider;
@end
