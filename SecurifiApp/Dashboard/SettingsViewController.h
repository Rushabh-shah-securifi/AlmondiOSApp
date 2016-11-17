//
//  SettingsViewController.h
//  Dashbord
//
//  Created by Securifi Support on 21/03/16.
//  Copyright © 2016 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFITabBarController.h"

@interface SettingsViewController : UIViewController <UITableViewDataSource , UITableViewDelegate>{
    IBOutlet UIScrollView *Scroller;
}

- (IBAction)buttonDone:(id)sender;

@end
