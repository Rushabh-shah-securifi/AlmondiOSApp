//
//  SFINotificationsViewController.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/18/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFINotificationsViewController.h"
#import "SFINotificationTableViewCell.h"

@interface SFINotificationsViewController ()
@property(nonatomic) NSArray *buckets; // NSDate instances
@property(nonatomic) NSMutableDictionary *notifications; // NSDate bucket :: NSArray of notifications
@end

@implementation SFINotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self resetBucketsAndNotifications];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    self.navigationItem.leftBarButtonItem = doneButton;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidReceiveNotifications) name:kSFINotificationDidStore object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onDone {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.buckets.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDate *bucket = [self tryGetBucket:section];
    NSArray *notifications = [self tryGetNotificationListForBucket:bucket];
    return notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cell_id = @"not_cell";

    SFINotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFINotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    SFINotification *notification = [self notificationForIndexPath:indexPath];
    cell.notification = notification;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SFINotification *notification = [self notificationForIndexPath:indexPath];
    if (!notification || notification.viewed) {
        return;
    }

    [[SecurifiToolkit sharedInstance] markNotificationViewed:notification];
    notification.viewed = YES;

    [tableView reloadRowsAtIndexPaths:@[] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Buckets and Notification loading

- (void)resetBucketsAndNotifications {
    self.buckets = [[SecurifiToolkit sharedInstance] fetchDateBuckets:30];
    self.notifications = [NSMutableDictionary dictionary];
}

- (SFINotification *)notificationForIndexPath:(NSIndexPath *)path {
    NSDate *bucket = [self tryGetBucket:path.section];
    return [self tryGetNotificationForBucket:bucket row:path.row];
}

- (NSDate *)tryGetBucket:(NSInteger)section {
    NSUInteger index = (NSUInteger) section;
    NSArray *array = self.buckets;
    if (index >= array.count) {
        return nil;
    }
    return array[index];
}

- (SFINotification *)tryGetNotificationForBucket:(NSDate *)bucket row:(NSInteger)row {
    if (bucket == nil) {
        return nil;
    }

    NSArray *notifications = [self tryGetNotificationListForBucket:bucket];

    NSUInteger index = (NSUInteger) row;
    if (index >= notifications.count) {
        return nil;
    }

    return notifications[index];
}

- (NSArray *)tryGetNotificationListForBucket:(NSDate *)bucket {
    if (bucket == nil) {
        return nil;
    }

    NSMutableDictionary *dict = self.notifications;

    NSArray *notifications = dict[bucket];
    if (notifications == nil) {
        notifications = [[SecurifiToolkit sharedInstance] fetchNotificationsForBucket:bucket limit:100];
        dict[bucket] = notifications;
    }

    return notifications;
}

#pragma mark - Notification event handlers

// called when new notifications have been received from the cloud
- (void)onDidReceiveNotifications {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self && self.isBeingDismissed) {
            return;
        }

        // this is brain dead because we may want to make transition more graceful and not even automatic
        [self resetBucketsAndNotifications];
        [self.tableView reloadData];
    });
}

@end
