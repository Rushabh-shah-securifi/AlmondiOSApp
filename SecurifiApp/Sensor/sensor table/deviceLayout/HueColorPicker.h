//
//  HueColorPicker.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "GenericIndexValue.h"

@protocol HueColorPickerDelegate
-(void)saveDeviceNewValue:(NSString *)newValue forGenericIndexValue:(GenericIndexValue*)genericIndexValue;
@end
@interface HueColorPicker : UIView
@property (nonatomic)UIColor *color;
@property(nonatomic)id<HueColorPickerDelegate> delegate;
@property (nonatomic)GenericIndexValue *genericIndexValue;

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue;
@end
