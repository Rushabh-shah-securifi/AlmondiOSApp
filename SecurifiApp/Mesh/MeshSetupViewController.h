//
//  MeshSetupViewController.h
//  SecurifiApp
//
//  Created by Masood on 7/27/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlmondStatus.h"
#import "AlmondJsonCommandKeyConstants.h"

@interface MeshSetupViewController : UIViewController
@property (nonatomic) AlmondStatus *almondStatObj;
@property (nonatomic) BOOL isStatusView;
@end
