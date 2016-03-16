//
//  HueColorPicker.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
#import "GenericProperty.h"

@protocol HueColorPickerDelegate
-(void)updateHueColorPicker:(NSString *)newValue;
@end
@interface HueColorPicker : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic) int min;
@property (nonatomic) int max;
@property(nonatomic)id<HueColorPickerDelegate> delegate;
@property (nonatomic)GenericProperty *deviceProperty;
-(void)drawHueColorPicker;
@end
