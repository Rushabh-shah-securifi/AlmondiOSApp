//
// Created by Matthew Sinclair-Day on 6/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "ScoreboardNetworkSettingsViewController.h"
#import "SFIAlmondLocalNetworkSettings.h"


@interface ScoreboardNetworkSettingsViewController () <UITextFieldDelegate>
@property(nonatomic, strong) SFIAlmondLocalNetworkSettings *settings;
@property BOOL dirty;
@end

@implementation ScoreboardNetworkSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.bounces = NO;

    NSString *almondMac = self.almond.almondplusMAC;

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondLocalNetworkSettings *settings = [toolkit localNetworkSettingsForAlmond:almondMac];

    if (!settings) {
        settings = [SFIAlmondLocalNetworkSettings new];
        settings.almondplusMAC = almondMac;
    }

    self.settings = settings;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (self.dirty) {
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        [toolkit setLocalNetworkSettings:self.settings];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            NSString *cell_id = @"enabled";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            cell.textLabel.text = NSLocalizedString(@"Local Network Enabled", @"Local Network Enabled");
            cell.accessoryType = self.settings.enabled ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

            return cell;
        }
        case 1: {
            NSString *cell_id = @"host";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:1 fieldLabel:NSLocalizedString(@"scoreboard.localnetwork.IP Address", @"IP Address") fieldValue:self.settings.host];
            return cell;
        }
        case 2: {
            NSString *cell_id = @"port";
            NSUInteger value = self.settings.port;
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:2 fieldLabel:NSLocalizedString(@"scoreboard.localnetwork.Port", @"Port") fieldValue:[NSString stringWithFormat:@"%lu", (long) value]];
            return cell;
        }
        case 3: {
            NSString *cell_id = @"pwd";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:3 fieldLabel:NSLocalizedString(@"scoreboard.localnetwork.Password", @"Password") fieldValue:self.settings.password];
            return cell;
        }
        default:
            return nil;
    }
}

- (UITableViewCell *)makeNameValueCell:(UITableView *)tableView id:(NSString *)cell_id fieldTag:(int)fieldTag fieldLabel:(NSString *)fieldLabel fieldValue:(NSString *)fieldValue {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    CGRect frame = CGRectMake(CGRectGetWidth(tableView.frame) / 2, 0, CGRectGetWidth(tableView.frame) / 2, 40);

    UITextField *field = [[UITextField alloc] initWithFrame:frame];
    field.tag = fieldTag;
    field.delegate = self;
    field.text = fieldValue;

    cell.textLabel.text = fieldLabel;
    [cell.contentView addSubview:field];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row != 0) {
        return;
    }

    self.settings.enabled = !self.settings.enabled;
    self.dirty = YES;

    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    str = [str stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];

    if (str.length == 0) {
        return NO;
    }

    switch (textField.tag) {
        case 1:
            self.settings.host = str;
            self.dirty = YES;
            break;

        case 2: {
            if (str.length > 0) {
                self.settings.port = (NSUInteger) str.integerValue;
                self.dirty = YES;
            }

            break;
        }

        case 3:
            self.settings.password = str;
            self.dirty = YES;
            break;

        default:
            break;
    }

    return YES;
}

@end