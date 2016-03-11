//
//  SensorButtonView.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

@protocol SensorButtonViewDelegate
@optional
-(void)updateButtonStatus:(NSString *)newValue;
@end

@interface SensorButtonView : UIView
@property (nonatomic)UIColor *color;
@property (nonatomic) NSDictionary *deviceValueDict;
@property (nonatomic) Device *device;
@property (nonatomic)id<SensorButtonViewDelegate> delegate;
-(void)drawButton:(NSDictionary *)valuedict color:(UIColor *)color;
-(void)drawButton:(NSArray*)array selectedValue:(int)selectedValue;
@end
