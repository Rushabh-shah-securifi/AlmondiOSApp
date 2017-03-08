//
//  DeviceNotificationViewController.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 01/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"
#import "GenericParams.h"

@interface DeviceNotificationViewController : UIViewController
@property (nonatomic)GenericIndexValue *genericIndexValue;
@property (nonatomic)GenericParams *genericParams;
@property BOOL isSensor;
@end
