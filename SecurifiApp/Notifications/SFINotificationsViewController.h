//
//  SFINotificationsViewController.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/18/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "SFITableViewController.h"
#import "NotificationsTestStore.h"
@interface SFINotificationsViewController : UITableViewController

// Required
@property(nonatomic, copy) NSString *almondMac;

// Default is NO.
// when YES, a test data store is used to generate fake Notifications for all possible
// device type-index values. Useful for unit testing and visual inspection without needing to post
// actual notifications from the cloud/APN.
@property(nonatomic) BOOL enableTestStore;

// Default YES
@property(nonatomic) BOOL markAllViewedOnDismiss;

// Controls whether individual records can be deleted
// Default to YES
@property(nonatomic) BOOL enableDeleteNotification;

// Default NO
@property(nonatomic) BOOL enableDeleteAllButton;

// Default NO
@property(nonatomic) BOOL enableDebugMode;

// When specified, only notifications for the specified device and Almond are shown
@property(nonatomic) sfi_id deviceID;

// Default NO
@property(nonatomic) BOOL isForWifiClients;

@property(nonatomic) id <SFINotificationStore> store;
@property(nonatomic) BOOL resetBucketsAndNotifications;
-(NSDate *)tryGetBucket:(NSInteger)section ;
- (SFINotification *)tryGetNotificationForBucket:(NSDate *)bucket row:(NSInteger)row ;
- (SFINotification *)notificationForIndexPath:(NSIndexPath *)path;
- (NotificationsTestStore *)pickNotificationStore;
- (NSInteger)tryGetCachedNotificationCount:(NSDate *)bucket ;
@end


