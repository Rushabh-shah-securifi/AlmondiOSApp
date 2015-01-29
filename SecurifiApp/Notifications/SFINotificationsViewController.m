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
// instances of SFINotification
@property(nonatomic) NSArray *notifications;
@end

@implementation SFINotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.notifications = [NSArray array];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    self.navigationItem.leftBarButtonItem = doneButton;

    self.notifications = [SecurifiToolkit sharedInstance].notifications;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidReceiveNotifications) name:kSFINotificationDidStore object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onDone {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cell_id = @"not_cell";

    SFINotificationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFINotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    
    SFINotification *notification = [self tryGetNotification:indexPath.row];
    cell.notification = notification;

    return cell;
}

- (SFINotification *)tryGetNotification:(NSInteger)row {
    NSUInteger index = (NSUInteger) row;
    NSArray *array = self.notifications;
    if (index >= array.count) {
        return nil;
    }
    return array[index];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SFINotification *notification = [self tryGetNotification:indexPath.row];
    if (!notification || notification.viewed) {
        return;
    }

    [[SecurifiToolkit sharedInstance] markNotificationViewed:notification];
    notification.viewed = YES;

    [tableView reloadRowsAtIndexPaths:@[] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Notification event handlers

// called when new notifications have been received from the cloud
- (void)onDidReceiveNotifications {
    NSArray *notifications = [SecurifiToolkit sharedInstance].notifications;

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self && self.isBeingDismissed) {
            return;
        }

        // this is brain dead because we may want to make transition more graceful and not even automatic
        self.notifications = notifications;
        [self.tableView reloadData];
    });
}

@end
