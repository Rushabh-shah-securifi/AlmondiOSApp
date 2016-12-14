//
//  SFIAccountsTableViewController.h
//  Almond
//
//  Created by Priya Yerunkar on 15/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIUserProfile.h"
#import "SFIAccountCellView.h"

@class SFIAccountsTableViewController;

@protocol SFIAccountDeleteDelegate

- (void)userAccountDidDelete:(SFIAccountsTableViewController *)ctrl;
- (void)userAccountDidDone:(SFIAccountsTableViewController *)ctrl;

@end

@interface SFIAccountsTableViewController : UITableViewController <UITextFieldDelegate, onButtonsClickedFromAccountCell ,onButtonsClickedFromAccountCell>
@property(weak, nonatomic) id <SFIAccountDeleteDelegate> delegate;

- (IBAction)doneButtonHandler:(id)sender;
@end
