//
//  WeatherPicker.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 13/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherPicker : NSObject
@property (nonatomic) UIView *parentView;
- (void) createPickerView;
@end
