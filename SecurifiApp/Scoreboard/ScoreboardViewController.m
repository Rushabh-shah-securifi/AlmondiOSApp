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
#import "SFIPreferences.h"
#import "NSData+Conversion.h"
#import "UIViewController+Securifi.h"
#import "SFINotificationsViewController.h"
#import "ScoreboardDebugLoggerViewController.h"
#import "DebugLogger.h"
#import "ScoreboardTextEditorViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@import MessageUI;


#define SEC_CLOUD           0
#define SEC_NOTIFICATIONS   1
#define SEC_ALMONDS         2
#define SEC_EVENTS          3
#define SEC_NETWORK         4
#define SEC_REQUESTS        5
#define SEC_LOGS            6

@interface ScoreboardViewController () <MFMailComposeViewControllerDelegate, ScoreboardTextEditorViewControllerProtocol>
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *statusBarButton;
@property(nonatomic) Scoreboard *scoreboard;
@property(nonatomic) NSArray *almonds;
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

    _statusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithTarget:nil action:nil];
    self.navigationItem.rightBarButtonItem = _statusBarButton;

    NSDictionary *attributes = self.navigationController.navigationBar.titleTextAttributes;

    UIRefreshControl *refresh = [UIRefreshControl new];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refresh Scoreboard" attributes:attributes];
    [refresh addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)loadScoreboard {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.scoreboard = [toolkit scoreboardSnapshot];
    self.almonds = [toolkit almondList];
}

#pragma mark - Event handlers

- (void)onRefresh {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self loadScoreboard];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SEC_CLOUD:
            return 3;
        case SEC_NOTIFICATIONS:
            return 5;
        case SEC_ALMONDS:
            return self.almonds.count;
        case SEC_EVENTS:
            return 1;
        case SEC_NETWORK:
            return 3;
        case SEC_REQUESTS:
            return 3;
        case SEC_LOGS:
            return 1;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case SEC_CLOUD:
            return @"Cloud";
        case SEC_NOTIFICATIONS:
            return @"Push Notifications";
        case SEC_ALMONDS:
            return @"Almond MACs";
        case SEC_EVENTS:
            return @"Events";
        case SEC_NETWORK:
            return @"Network";
        case SEC_REQUESTS:
            return @"Commands & Updates";
        case SEC_LOGS:
            return @"Logs & Data";
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    // whatever is the last section, we place a title
    if (section != SEC_LOGS) {
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

    NSInteger const section = indexPath.section;

    if (section == SEC_CLOUD) {
        return [self tableView:tableView cloudSectionCellForRowAtIndexPath:indexPath];
    }
    else if (section == SEC_NOTIFICATIONS) {
        if (indexPath.row == 0) {
            NSString *cell_id = @"notifications";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell_id];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.textLabel.text = @"Client Token";
            }
            NSString *token = [self pushNotificationClientToken];
            cell.detailTextLabel.text = (token.length == 0) ? @"Not registered" : token;
            return cell;
        }
        else if (indexPath.row == 1) {
            SFIPreferences *prefs = [SFIPreferences instance];
            NSDate *date = prefs.debugPushNotificationReceivedCountStartDate;
            NSInteger count = prefs.debugPushNotificationReceivedCount;

            NSString *dateStr = (date == nil) ? @"–––" : date.formattedDateTimeString;
            NSString *description = [NSString stringWithFormat:@"Since %@", dateStr];
            NSString *countStr = [NSString stringWithFormat:@"%li", (long) count];

            NSString *cell_id = @"notifications_recevied";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            cell.textLabel.text = description;
            cell.detailTextLabel.text = countStr;
            return cell;
        }
        else if (indexPath.row == 2) {
            NSString *cell_id = @"notifications_logctrl";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = @"View Handler Log";
            return cell;
        }
        else if (indexPath.row == 3) {
            NSString *cell_id = @"notifications_viewactual";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = @"View Notifications";
            return cell;
        }
        else if (indexPath.row == 4) {
            NSString *cell_id = @"notifications_viewtests";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.textLabel.text = @"Unit Test UI";
            return cell;
        }
    }
    else if (section == SEC_ALMONDS) {
        SFIAlmondPlus *almond = [self tryGetAlmond:indexPath];

        NSString *cell_id = @"almond";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell_id];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        cell.textLabel.text = almond.almondplusName;
        cell.detailTextLabel.text = almond.almondplusMAC;

        return cell;
    }
    else if (section == SEC_EVENTS) {
        NSString *cell_id = @"events";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = @"All Events";
        cell.detailTextLabel.text = [scoreboard formattedValue:[scoreboard allEventsCount]];
        return cell;
    }

    NSString *field = @"";
    NSString *value = nil;

    if (section == SEC_NETWORK) {
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
    else if (section == SEC_REQUESTS) {
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
    else if (section == SEC_LOGS) {
        NSString *cell_id = @"send_logs";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = @"Email Logs & Data";
        return cell;
    }

    UITableViewCell *cell = [self getFieldCell:tableView];
    cell.textLabel.text = field;
    cell.detailTextLabel.text = value;

    return cell;
}

- (SFIAlmondPlus *)tryGetAlmond:(NSIndexPath *)indexPath {
    NSUInteger index = (NSUInteger) indexPath.row;
    NSArray *almonds = self.almonds;
    SFIAlmondPlus *almond = index >= almonds.count ? nil : almonds[index];
    return almond;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cloudSectionCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    SecurifiConfigurator *config = toolkit.configuration;
    BOOL useProduction = toolkit.useProductionCloud;

    NSString *id = @"cloud";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:id];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }

    NSInteger row = indexPath.row;
    if (row == 0) {
        cell.textLabel.text = @"Production";
        cell.accessoryType = useProduction ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    else if (row == 1) {
        cell.textLabel.text = @"Development";
        cell.accessoryType = useProduction ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.textLabel.text = config.developmentCloudHost;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (section == SEC_CLOUD) {
        if (row == 0 || row == 1) {
            [self onSwitchServer];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger) section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            ScoreboardTextEditorViewController *ctrl = [ScoreboardTextEditorViewController new];
            ctrl.delegate = self;
            ctrl.text = [SecurifiToolkit sharedInstance].configuration.developmentCloudHost;
            [self.navigationController pushViewController:ctrl animated:YES];
        }
    }
    else if (section == SEC_ALMONDS) {
        NSString *token = nil;

        SFIAlmondPlus *almond = [self tryGetAlmond:indexPath];
        if (almond != nil) {
            token = almond.almondplusMAC;
        }

        if (token != nil) {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            pb.string = token;

            [self showToast:@"Copied Almond MAC"];
        }
    }
    else if (section == SEC_NOTIFICATIONS) {
        if (row == 0) {
            NSString *token = [self pushNotificationClientToken];
            if (token == nil) {
                token = @"";
            }

            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            pb.string = token;

            [self showToast:@"Copied token"];
        }
        else if (row == 1) {
            SFIPreferences *prefs = [SFIPreferences instance];
            [prefs resetDebugPushNotificationReceivedCount];
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self showToast:@"Reset counter"];
        }
        else if (row == 2) {
            ScoreboardDebugLoggerViewController *ctrl = [ScoreboardDebugLoggerViewController new];
            [self.navigationController pushViewController:ctrl animated:YES];
        }
        else if (row == 3) {
            SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            ctrl.enableTestStore = NO;
            ctrl.enableDeleteAllButton = YES;
            ctrl.markAllViewedOnDismiss = NO;
            ctrl.enableDebugMode = YES;
            [self.navigationController pushViewController:ctrl animated:YES];
        }
        else if (row == 4) {
            SFINotificationsViewController *ctrl = [[SFINotificationsViewController alloc] initWithStyle:UITableViewStyleGrouped];
            ctrl.enableTestStore = YES;
            ctrl.enableDeleteAllButton = NO;
            ctrl.markAllViewedOnDismiss = NO;
            ctrl.enableDebugMode = YES;

            UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
            [self presentViewController:nav_ctrl animated:YES completion:nil];
        }
    }
    else if (section == SEC_EVENTS) {
        NSArray *events = [self.scoreboard allEvents];
        events = [[events reverseObjectEnumerator] allObjects];

        ScoreboardEventViewController *ctrl = [ScoreboardEventViewController new];
        ctrl.events = events;

        [self.navigationController pushViewController:ctrl animated:YES];
    }
    else if (section == SEC_LOGS) {
        if (![MFMailComposeViewController canSendMail]) {
            [self showToast:@"Sending Mail is not supported on this device"];
            return;
        }

        [self showHUD:@"Preparing..."];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            MFMailComposeViewController *ctrl = [self prepareMailComposer];
            dispatch_async(dispatch_get_main_queue(), ^() {
                [self.HUD hide:YES];
                [self presentViewController:ctrl animated:YES completion:nil];
            });
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SEC_ALMONDS) {
        return 70;
    }
    if (indexPath.section == SEC_NOTIFICATIONS) {
        return 70;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)onSwitchServer {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    toolkit.useProductionCloud = !toolkit.useProductionCloud;
    [toolkit closeConnection];
    [toolkit initToolkit];
    [self onRefresh];
}

- (NSString *)pushNotificationClientToken {
    return [SFIPreferences instance].pushNotificationDeviceToken.hexadecimalString;
}

#pragma mark - Mail composer and MFMailComposeViewControllerDelegate methods

- (MFMailComposeViewController *)prepareMailComposer {
    MFMailComposeViewController *ctrl = [MFMailComposeViewController new];
    ctrl.mailComposeDelegate = self;
    ctrl.subject = [NSString stringWithFormat:@"[%@] Data and logs", [[UIDevice currentDevice] name]];

    NSMutableString *bodyText = [NSMutableString string];

    [bodyText appendString:@"\nAPN Registration\n"];
    [bodyText appendString:@"=========================\n"];
    NSString *token = [self pushNotificationClientToken];
    [bodyText appendFormat:@"token : %@\n", token];

    [bodyText appendString:@"\nAlmonds\n"];
    [bodyText appendString:@"=========================\n"];
    NSArray *almonds = self.almonds;
    for (SFIAlmondPlus *almond in almonds) {
        [bodyText appendFormat:@"%@ : %@\n", almond.almondplusName, almond.almondplusMAC];
    }

    [bodyText appendString:@"\nLogs and Data\n"];
    [bodyText appendString:@"=========================\n"];

    DebugLogger *debugLogger = [DebugLogger sharedInstance];
    NSData *data = [debugLogger logData];
    [ctrl addAttachmentData:data mimeType:@"text/plain" fileName:debugLogger.fileName];
    [bodyText appendFormat:@"%@\n", debugLogger.fileName];

    for (id logger in [DDLog allLoggers]) {
        if ([logger isKindOfClass:DDFileLogger.class]) {
            DDFileLogger *fileLogger = logger;
            NSArray *fileInfos = fileLogger.logFileManager.sortedLogFileInfos;
            for (DDLogFileInfo *fileInfo in fileInfos) {
                NSString *logFilePath = fileInfo.filePath;
                NSString *logFileName = fileInfo.fileName;

                NSData *logData = [NSData dataWithContentsOfFile:logFilePath];
                [ctrl addAttachmentData:logData mimeType:@"text/plain" fileName:logFileName];
                [bodyText appendFormat:@"%@\n", logFileName];
            }
        }
    }

    NSString *databaseCopyFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    BOOL success = [toolkit copyNotificationStoreTo:databaseCopyFilePath];
    if (success) {
        NSData *logData = [NSData dataWithContentsOfFile:databaseCopyFilePath];
        NSString *filename = @"toolkit_store.db";
        [ctrl addAttachmentData:logData mimeType:@"application/x-sqlite3" fileName:filename];
        [bodyText appendFormat:@"%@\n", filename];
    }

    [ctrl setMessageBody:bodyText isHTML:NO];
    return ctrl;
}

- (void)mailComposeController:(MFMailComposeViewController *)ctrl didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [ctrl dismissViewControllerAnimated:YES completion:^() {
        if (result == MFMailComposeResultFailed) {
            if (error) {
                [self showToast:[NSString stringWithFormat:@"Failed to send mail: %@", error.description]];
            }
            else {
                [self showToast:@"Failed to send mail"];
            }
        }
    }];
}

#pragma mark - ScoreboardTextEditorViewControllerProtocol methods

- (void)scoreboardTextEditorDidChangeText:(NSString *)newText {
    newText = [newText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (newText.length == 0) {
        return;
    }

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    SecurifiConfigurator *config = toolkit.configuration;
    config.developmentCloudHost = newText;

    [toolkit debugUpdateConfiguration:config];

    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}


@end
