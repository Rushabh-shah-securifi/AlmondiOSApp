//
//  DrawerViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import <MessageUI/MessageUI.h>

@interface DrawerViewController : UIViewController <UITableViewDataSource, UITabBarControllerDelegate, MFMailComposeViewControllerDelegate >
@property (nonatomic, retain) IBOutlet UITableView *drawTable;

//PY 111013 - Integration with new UI
@property (nonatomic, retain) NSMutableArray *almondList;
@property (nonatomic,retain) NSString *currentMAC;
@end
