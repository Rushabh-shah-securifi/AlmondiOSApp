//
//  ScoreboardViewController.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "ScoreboardViewController.h"
#import "SFICloudStatusBarButtonItem.h"

#define SEC_CONNECTION  0
#define SEC_REQUESTS    1

@interface ScoreboardViewController ()
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *statusBarButton;
@property(nonatomic) Scoreboard *scoreboard;
@property(nonatomic) NSTimer *updateTimer;
@end

@implementation ScoreboardViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Scoreboard";
        [self loadScoreboard];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _statusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithStandard];
    self.navigationItem.rightBarButtonItem = _statusBarButton;

    UIRefreshControl *refresh = [UIRefreshControl new];
    NSDictionary *attributes = self.navigationController.navigationBar.titleTextAttributes;
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Force scoreboard refresh" attributes:attributes];
    [refresh addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.updateTimer invalidate];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onUpdateFooterView) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.updateTimer invalidate];
}

- (void)loadScoreboard {
    self.scoreboard = [[SecurifiToolkit sharedInstance] scoreboard];
}

#pragma mark - Event handlers

- (void)onRefresh {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self loadScoreboard];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}

- (void)onUpdateFooterView {
    dispatch_async(dispatch_get_main_queue(), ^() {
        NSIndexSet *footer_section = [NSIndexSet indexSetWithIndex:SEC_REQUESTS];
        [self.tableView reloadSections:footer_section withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SEC_CONNECTION:
            return 3;
        case SEC_REQUESTS:
            return 3;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SEC_CONNECTION:
            return @"Network";
        case SEC_REQUESTS:
            return @"Commands & Updates";
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    // whatever is the last section, we place a title
    if (section != SEC_REQUESTS) {
        return nil;
    }

    NSDate *created = self.scoreboard.created;
    NSTimeInterval delta = -1 * [created timeIntervalSinceNow];
    NSString *time = [NSDateFormatter localizedStringFromDate:created dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];

    return [NSString stringWithFormat:@"Last refreshed %.0f secs ago @ %@", delta, time];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *id = @"field";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    Scoreboard *scoreboard = self.scoreboard;
    NSString *field = @"";
    NSString *value = nil;

    if (indexPath.section == SEC_CONNECTION) {
        switch (indexPath.row) {
            case 0: {
                field = @"Established Connections";
                value = [scoreboard formattedValue:scoreboard.connectionCount];
                break;
            }
            case 1: {
                field = @"Failed Connections";
                value = [scoreboard formattedValue:scoreboard.connectionFailedCount];
                break;
            }
            case 2: {
                field = @"Reachability Changes";
                value = [scoreboard formattedValue:scoreboard.reachabilityChangedCount];
                break;
            }
            default : {

            }
        } // end switch
    }
    else if (indexPath.section == SEC_REQUESTS) {
        switch (indexPath.row) {
            case 0: {
                field = @"Dynamic Updates";
                value = [scoreboard formattedValue:scoreboard.dynamicUpdateCount];
                break;
            }
            case 1: {
                field = @"Command Requests";
                value = [scoreboard formattedValue:scoreboard.commandRequestCount];
                break;
            }
            case 2: {
                field = @"Command Responses";
                value = [scoreboard formattedValue:scoreboard.commandResponseCount];
                break;
            }
            default : {

            }
        } // end switch
    }

    cell.textLabel.text = field;
    cell.detailTextLabel.text = value;

    return cell;
}


@end
