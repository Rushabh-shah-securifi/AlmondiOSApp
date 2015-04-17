//
//  SFINotificationsViewController.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/18/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "SFITableViewController.h"

@interface SFINotificationsViewController : UITableViewController

// Default is NO.
// when YES, a test data store is used to generate fake Notifications for all possible
// device type-index values. Useful for unit testing and visual inspection without needing to post
// actual notifications from the cloud/APN.
@property(nonatomic) BOOL enableTestStore;

// Default YES
@property(nonatomic) BOOL markAllViewedOnDismiss;

// Default NO
@property(nonatomic) BOOL enableDeleteAllButton;

// Default NO
@property(nonatomic) BOOL enableDebugMode;

@end


