//
//  Slider.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"

@protocol SliderViewDelegate
-(void)saveDeviceNewValue:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue;
@end

@interface Slider : UIView
@property (nonatomic)UIColor *color;
@property(nonatomic)id<SliderViewDelegate> delegate;
@property (nonatomic)GenericIndexValue *genericIndexValue;

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue;

@end
