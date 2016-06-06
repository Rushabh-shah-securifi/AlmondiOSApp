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
#import "UIApplication+SecurifiNotifications.h"
#import "Analytics.h"

@interface SFINotificationsViewController ()
@property(nonatomic, readonly) id <SFINotificationStore> store;
@property(nonatomic) NSArray *buckets; // NSDate instances
@property(nonatomic) NSDictionary *bucketCounts; // NSDate :: NSNumber
@property(atomic) BOOL lockedToStoreUpdates;
@property(atomic) BOOL deletingRow;
@property(atomic) BOOL needsToRefreshBucketsAndStore;
@end

/*

Note that the controller listens for changed to the notification store and will reload itself when they arrive.
This poses a problem handling concurrent updates while the table is in the middle of animations or deleting a row.
Therefore, a locking procedure is implemented effectively blocking out table reloads during these operations.
 */
@implementation SFINotificationsViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.enableDeleteNotification = YES;
        self.markAllViewedOnDismiss = YES;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"NotificationsViewController - ViewDidLoad");
    _store = [self pickNotificationStore];

    [self resetBucketsAndNotifications];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    self.title = NSLocalizedString(@"notifications.title.Recent Activities", @"Recent Activities"); //todo localize me

    if (self.enableDeleteAllButton) {
        UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onDeleteAll)];
        delete.tintColor = [UIColor blackColor];
        self.navigationItem.leftBarButtonItem = delete;
    }

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    doneButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = doneButton;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor whiteColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidReceiveNotifications) name:kSFINotificationDidStore object:nil];
}

// Depending on how this controller is configured, a different storage is returned
- (NotificationsTestStore *)pickNotificationStore {
    if (self.enableTestStore) {
        // "Test" storage for the Debug tab; for visual functional testing of the Notifications UI
        NotificationsTestStore *store = [NotificationsTestStore new];

        NSString *almondMac;
        if (self.almondMac) {
            almondMac = self.almondMac;
        }
        else {
            almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
        }

        store.almondMac = almondMac;
        [store setup];

        return store;
    }
    else if (self.almondMac) {
        // Ephemeral "log" storage for the specified device
        return [[SecurifiToolkit sharedInstance] newDeviceLogStore:self.almondMac deviceId:self.deviceID forWifiClients:self.isForWifiClients];
    }
    else {
        // normal Notifications/Activity Viewer storage
        return [[SecurifiToolkit sharedInstance] newNotificationStore];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[Analytics sharedInstance] markNotificationsScreen];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    if (self.markAllViewedOnDismiss) {
        // on dismissing the view we mark all that were being shown as "viewed"
        SFINotification *mostRecent = [self mostRecentNotification];
        [self.store markAllViewedTo:mostRecent];

        // Tell the cloud add notifications were viewed
        // Note: there is a race condition that does not account for concurrent changes to this app's data store
        // while this operation is being called. This is due to an underspecified protocol between cloud and app.
        [[SecurifiToolkit sharedInstance] tryClearNotificationCount];

        // tell the world notifications were viewed
        [center postNotificationName:kApplicationDidViewNotifications object:nil];
    }

    // stop listening for our own notifications
    [center removeObserver:self];
}

- (void)onDone {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onDeleteAll {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.store deleteAllNotifications];
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.buckets.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDate *bucket = [self tryGetBucket:section];

    if (self.lockedToStoreUpdates) {
        NSInteger count = [self tryGetCachedNotificationCount:bucket];
        return (count == -1) ? 0 : count;
    }

    NSUInteger actualCount = [self.store countNotificationsForBucket:bucket];
    [self cacheNotificationCount:actualCount bucket:bucket];
    return actualCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SFINotification *notification = [self notificationForIndexPath:indexPath];

    NSString *cell_id = notification.viewed ? @"viewed_cell" : @"not_cell";
    SFINotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFINotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.enableDebugMode = self.enableDebugMode;
    }

    cell.notification = notification;
    cell.debugCellIndexNumber = (NSUInteger) indexPath.row;

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
        [self.store markViewed:notification];
        notification.viewed = YES;
    }

    // Sequence the row reload operation inside an animation transaction that can provide a completion handler
    // that will unlock the table
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self willUpdateTableCell];

        [CATransaction begin];
        [tableView beginUpdates];

        [CATransaction setCompletionBlock:^{
            [self didCompleteUpdateTableCell];
        }];

        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        [tableView endUpdates];
        [CATransaction commit];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.enableDeleteNotification) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Lock out updates to the notification store from being reflected here;
    // we can't have row counts change while the deletion is in progress
    self.deletingRow = YES;

    SFINotification *notification = [self notificationForIndexPath:indexPath];
    [self.store markDeleted:notification];

    dispatch_async(dispatch_get_main_queue(), ^() {
        DLog(@"start commitEditingStyle");

        [CATransaction begin];
        [tableView beginUpdates];

        NSDate *bucket = [self tryGetBucket:indexPath.section];
        NSInteger cachedCount = [self tryGetCachedNotificationCount:bucket];

        [CATransaction setCompletionBlock:^{
            DLog(@"CATransaction completion block");
            // when the animation has completed (and the row is deleted)
            // unlock the table, allowing for changes to the notification store to be reflected
            self.deletingRow = NO;
            [self didCompleteUpdateTableCell];
        }];

        // delete the row
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];

        // decrement count reflecting row deletion
        cachedCount--;
        if (cachedCount < 0) {
            cachedCount = 0;
        }
        [self cacheNotificationCount:(NSUInteger) cachedCount bucket:bucket];

        [tableView endUpdates];
        [CATransaction commit];

        DLog(@"done commitEditingStyle");
    });
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willBeginEditingRowAtIndexPath:indexPath];

    DLog(@"willBeginEditingRowAtIndexPath");
    [self willUpdateTableCell];

    dispatch_async(dispatch_get_main_queue(), ^() {
        // Preps in case commitEditingStyle is called to delete a row.
        // This ensures the current row count is stored in the cache and used by iOS when processing the "deleteRows" directive.
        // The value is then updated at the end of deletion transaction in commitEditingStyle method.
        NSInteger count = [tableView numberOfRowsInSection:indexPath.section];
        NSDate *bucket = [self tryGetBucket:indexPath.section];
        [self cacheNotificationCount:(NSUInteger) count bucket:bucket];
    });
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didEndEditingRowAtIndexPath:indexPath];

    if (!self.deletingRow) {
        DLog(@"didEndEditingRowAtIndexPath");
        [self didCompleteUpdateTableCell];
    }
}

// when at bottom of table, let's try to load more records
- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    // UITableView only moves in one direction, y axis
    CGPoint point = scroll.contentOffset;

    CGFloat currentOffset = point.y;
    CGFloat maximumOffset = scroll.contentSize.height - scroll.frame.size.height;

    // Change 10.0 to adjust the distance from bottom
    if (maximumOffset - currentOffset <= 50.0) {
        [self.store ensureFetchNotifications:self.isForWifiClients];
    }
}

#pragma mark - Buckets and Notification loading

- (SFINotification *)mostRecentNotification {
    NSDate *bucket = [self tryGetBucket:0];
    if (bucket == nil) {
        return nil;
    }

    return [self tryGetNotificationForBucket:bucket row:0];
}

- (BOOL)resetBucketsAndNotifications {
    if (self.isUpdatingTableCell) {
        [self markNeedsResetBucketsAndNotifications];
        return NO;
    }

    self.buckets = [self.store fetchDateBuckets:365];
    self.bucketCounts = @{}; // important to clear cache on resetting buckets

    return YES;
}

- (SFINotification *)notificationForIndexPath:(NSIndexPath *)path {
    NSDate *bucket = [self tryGetBucket:path.section];
    return [self tryGetNotificationForBucket:bucket row:path.row];
}

- (BOOL)isLastBucket:(NSInteger)section  {
    NSUInteger index = (NSUInteger) section;
    NSArray *array = self.buckets;
    NSUInteger count = array.count - 1;
    return index == count;
}

- (NSDate *)tryGetBucket:(NSInteger)section {
    NSUInteger index = (NSUInteger) section;
    NSArray *array = self.buckets;
    if (index >= array.count) {
        return nil;
    }
    return array[index];
}

// check cache for bucket count.
// returns -1 if no value in cache
- (NSInteger)tryGetCachedNotificationCount:(NSDate *)bucket {
    NSDictionary *counts = self.bucketCounts;
    if (!counts) {
        return -1;
    }

    NSNumber *num = counts[bucket];
    if (!num) {
        return -1;
    }

    return num.integerValue;
}

- (void)cacheNotificationCount:(NSUInteger)count bucket:(NSDate *)bucket {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.bucketCounts];
    dict[bucket] = @(count);
    self.bucketCounts = dict;
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

        // the table might be locked against updates, and in that case this call returns NO.
        // the call to reset the table, however, is noted and will be handled later
        // when the table is unlocked
        BOOL needsReload = [self resetBucketsAndNotifications];
        if (needsReload) {
            [self.tableView reloadData];
        }
    });
}

#pragma mark - Internal locking and state management

// YES when the table is locked against changes to the notification store
- (BOOL)isUpdatingTableCell {
    return self.lockedToStoreUpdates;
}

// Indicates that the notification has changed while the table was locked
- (void)markNeedsResetBucketsAndNotifications {
    self.needsToRefreshBucketsAndStore = YES;
}

// Called prior to performing an operation that requires a consistent view of the table structure
- (void)willUpdateTableCell {
    self.lockedToStoreUpdates = YES;
}

// Called after performing an operation; reloads the notification store and reloads table if needed.
- (void)didCompleteUpdateTableCell {
    self.lockedToStoreUpdates = NO;

    // if updates arrived while the table was updating, we handle them now
    if (self.needsToRefreshBucketsAndStore) {
        self.needsToRefreshBucketsAndStore = NO;

        dispatch_async(dispatch_get_main_queue(), ^() {
            [self resetBucketsAndNotifications];
            [self.tableView reloadData];
        });
    }
}

@end
