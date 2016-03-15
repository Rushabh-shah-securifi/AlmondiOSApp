//
//  HueColorPicker.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"
@protocol HueColorPickerDelegate
-(void)updateHueColorPicker:(NSString *)newValue;
@end
@interface HueColorPicker : UIView
@property (nonatomic)NSMutableArray *componentArray;
@property (nonatomic) Device *device;
@property (nonatomic)UIColor *color;
@property(nonatomic)id<HueColorPickerDelegate> delegate;
-(void)drawHueColorPicker;
@end
