//
//  SFINotificationsViewController.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/18/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFINotificationsViewController.h"
#import "SFINotificationTableViewCell.h"
#import "SFINotificationTableViewHeaderFooter.h"
#import "UIFont+Securifi.h"
#import "NotificationsTestStore.h"

@interface SFINotificationsViewController ()
@property(nonatomic, readonly) id<SFINotificationStore> store;
@property(nonatomic) NSArray *buckets; // NSDate instances
@end

@implementation SFINotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.enableTestStore) {
        NotificationsTestStore *store = [NotificationsTestStore new];
        store.almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
        [store setup];
        _store = store;
    }
    else {
        _store = [[SecurifiToolkit sharedInstance] newNotificationStore];
    }

    [self resetBucketsAndNotifications];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    self.title = @"Recent Activities"; //todo localize me

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    doneButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = doneButton;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor whiteColor];

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
    return [self.store countNotificationsForBucket:bucket];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SFINotification *notification = [self notificationForIndexPath:indexPath];

    NSString *cell_id = notification.viewed ? @"viewed_cell" : @"not_cell";
    SFINotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFINotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.notification = notification;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == (self.buckets.count - 1)) {
        return 70;
    }

    return 2; // filler view only draws a vertical line; we have to handle this case because the table view will add footer spacing for all once one is provided
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });

    SFINotification *notification = [self notificationForIndexPath:indexPath];
    if (notification && !notification.viewed) {
        [[SecurifiToolkit sharedInstance] markNotificationViewed:notification];
        notification.viewed = YES;
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SFINotificationTableViewHeaderFooter *header = [[SFINotificationTableViewHeaderFooter alloc] initWithFrame:CGRectZero];
    header.mode = (section == 0) ? SFINotificationTableViewHeaderFooter_header : SFINotificationTableViewHeaderFooter_middle;
    header.bucketDate = [self tryGetBucket:section];
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == (self.buckets.count - 1)) {
        SFINotificationTableViewHeaderFooter *footer = [[SFINotificationTableViewHeaderFooter alloc] initWithFrame:CGRectZero];
        footer.mode = SFINotificationTableViewHeaderFooter_footer;
        return footer;
    }

    SFINotificationTableViewHeaderFooter *footer = [[SFINotificationTableViewHeaderFooter alloc] initWithFrame:CGRectZero];
    footer.mode = SFINotificationTableViewHeaderFooter_vertical_line;
    return footer;
}

#pragma mark - Buckets and Notification loading

- (void)resetBucketsAndNotifications {
    self.buckets = [self.store fetchDateBuckets:365];
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

    NSUInteger index = (NSUInteger) (row + 0);
    return [self.store fetchNotificationForBucket:bucket index:index];
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
