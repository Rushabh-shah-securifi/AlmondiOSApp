//
//  ScoreboardViewController.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "ScoreboardViewController.h"
#import "SFICloudStatusBarButtonItem.h"
#import "ScoreboardEventViewController.h"

#define SEC_CLOUD       0
#define SEC_EVENTS      1
#define SEC_NETWORK     2
#define SEC_REQUESTS    3

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
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refresh Scoreboard" attributes:attributes];
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
    self.scoreboard = [[SecurifiToolkit sharedInstance] scoreboardSnapshot];
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SEC_CLOUD:
            return 2;
        case SEC_EVENTS:
            return 1;
        case SEC_NETWORK:
            return 3;
        case SEC_REQUESTS:
            return 3;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SEC_CLOUD:
            return @"Cloud";
        case SEC_EVENTS:
            return @"Events";
        case SEC_NETWORK:
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


- (UITableViewCell *)getFieldCell:(UITableView *)tableView {
    NSString *cell_id = @"field";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Scoreboard *scoreboard = self.scoreboard;

    if (indexPath.section == SEC_CLOUD) {
        return [self tableView:tableView cloudSectionCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == SEC_EVENTS) {
        UITableViewCell *cell = [self getFieldCell:tableView];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.text = @"All Events";
        cell.detailTextLabel.text = [scoreboard formattedValue:[scoreboard allEventsCount]];
        return cell;
    }

    NSString *field = @"";
    NSString *value = nil;

    if (indexPath.section == SEC_NETWORK) {
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

    UITableViewCell *cell = [self getFieldCell:tableView];
    cell.textLabel.text = field;
    cell.detailTextLabel.text = value;

    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cloudSectionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL useProduction = [SecurifiToolkit sharedInstance].useProductionCloud;

    NSString *id = @"cloud";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:id];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    if (indexPath.row == 0) {
        cell.textLabel.text = @"Production";
        cell.accessoryType = useProduction ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    else {
        cell.textLabel.text = @"Development";
        cell.accessoryType = useProduction ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SEC_CLOUD) {
        [self onSwitchServer];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger) indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (indexPath.section == SEC_EVENTS) {
        NSArray *events = [self.scoreboard allEvents];
        events = [[events reverseObjectEnumerator] allObjects];

        ScoreboardEventViewController *ctrl = [ScoreboardEventViewController new];
        ctrl.events = events;

        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

- (void)onSwitchServer {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    toolkit.useProductionCloud = !toolkit.useProductionCloud;
    [toolkit closeConnection];
    [toolkit initToolkit];
    [self onRefresh];
}

@end