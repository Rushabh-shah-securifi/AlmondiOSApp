//
//  SFISensorDetailEditViewController.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 12.10.15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFISensorDetailEditViewController : UIViewController

@property(nonatomic) SFIDevice *device;
@property(nonatomic) SFIDeviceValue *deviceValue;
@property(nonatomic) UIColor *color;
@property (strong, nonatomic) NSString *iconImageName;
@property (strong, nonatomic) NSArray *statusTextArray;


@end
