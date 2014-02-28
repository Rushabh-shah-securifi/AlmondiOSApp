//
//  InitialSlidingViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
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
