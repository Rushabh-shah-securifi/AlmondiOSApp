//
//  DelayPicker.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 22/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRulesViewController.h"
@class AddRulesViewController;

@interface DelayPicker : NSObject
-(void)addPickerForButton:(UIButton*)delayButton parentController:(AddRulesViewController*)parentController;
@end
