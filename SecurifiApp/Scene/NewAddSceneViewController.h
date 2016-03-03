//
//  NewAddSceneViewController.h
//  SecurifiApp
//
//  Created by Masood on 19/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rule.h"

@interface NewAddSceneViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *triggersActionsScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *deviceListScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *deviceIndexButtonScrollView;
@property (strong, nonatomic) IBOutlet UILabel *informationLabel;

@property (copy, nonatomic)Rule *scene;
@property (nonatomic)BOOL isInitialized;
@end