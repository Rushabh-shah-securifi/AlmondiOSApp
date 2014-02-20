//
//  SFISwitchViewController.h
//  Securifi Cloud
//
//  Created by Nirav Uchat on 5/21/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SFISingleton.h"

@interface SFISwitchViewController : UIViewController
{
       UIActivityIndicatorView *ai;
    //SFISingleton *singleton;
}
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
- (IBAction)switchHnadler:(id)sender;

@end
