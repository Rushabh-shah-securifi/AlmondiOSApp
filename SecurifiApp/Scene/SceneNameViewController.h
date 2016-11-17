
//  SceneNameViewController.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 29/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rule.h"
@interface SceneNameViewController : UIViewController
@property (strong) Rule *scene;
@property BOOL isInitialized;
@end
