//
//  SensorsViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 2/13/12.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVReorderTableView.h"

@class SFICloudStatusBarButtonItem;

@interface SensorsViewController : UITableViewController <UITextFieldDelegate>

@property(nonatomic, weak) IBOutlet UITextField *txtInvisible;

- (IBAction)revealMenu:(id)sender;

- (IBAction)onRefreshSensorData:(id)sender;

@end
