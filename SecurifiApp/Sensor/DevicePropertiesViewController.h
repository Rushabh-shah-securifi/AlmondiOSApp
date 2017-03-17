//
//  DevicePropertiesViewController.h
//  SecurifiApp
//
//  Created by Masood on 1/30/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericParams.h"

@interface DevicePropertiesViewController : UIViewController
@property (nonatomic)GenericParams *genericParams;
@property BOOL userProfile;
@end
