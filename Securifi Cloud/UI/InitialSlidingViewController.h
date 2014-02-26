//
//  InitialSlidingViewController.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/25/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "MBProgressHUD.h"

@interface InitialSlidingViewController : ECSlidingViewController
{
    MBProgressHUD               *HUD;
}
@property NSInteger state;
@property BOOL isCloudConnectionBroken;
@end
