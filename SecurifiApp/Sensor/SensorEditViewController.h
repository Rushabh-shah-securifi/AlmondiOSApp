//
//  SensorEditViewController.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

@interface SensorEditViewController : UIViewController
@property (nonatomic,strong)NSArray *genericIndexs;
@property (nonatomic,strong)Device *device;

@end
