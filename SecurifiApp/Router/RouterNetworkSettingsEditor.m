//
// Created by Matthew Sinclair-Day on 7/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Colours/Colours.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <SecurifiToolkit/SFIAlmondLocalNetworkSettings.h>
#import "RouterNetworkSettingsEditor.h"
#import "UIFont+Securifi.h"

typedef NS_ENUM(unsigned int, TABLE_ROW) {
    TABLE_ROW_SSID_2 = 0,
    TABLE_ROW_SSID_5,
    TABLE_ROW_IP_ADDR,
    TABLE_ROW_ADMIN_LOGIN,
    TABLE_ROW_ADMIN_PWD,
    TABLE_ROW_count
};

typedef NS_ENUM(unsigned int, RouterNetworkSettingsEditorState) {
    RouterNetworkSettingsEditorState_promptForLinkCode,
    RouterNetworkSettingsEditorState_successOnLink,
    RouterNetworkSettingsEditorState_errorOnLink,
};

@interface RouterNetworkSettingsEditor () <UITextFieldDelegate>
@property(nonatomic) enum RouterNetworkSettingsEditorState state;
@property(nonatomic, strong) NSString *linkErrorSuccessMessage;
@property(nonatomic, strong) SFIAlmondLocalNetworkSettings *workingSettings;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end


@implementation RouterNetworkSettingsEditor

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"router.network-title.Local Link", @"Local Link");
    }

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.state = RouterNetworkSettingsEditorState_promptForLinkCode;

    // keep the table view from being placed underneath the nav bar
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.contentOffset = CGPointMake(0, -20);

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.workingSettings = self.settings ? self.settings.copy : [SFIAlmondLocalNetworkSettings new];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };

    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    self.navigationItem.title = NSLocalizedString(@"Local Link Almond", @"Local Link");

    [self buttonsForLinkState];

    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - State management

- (void)markSuccessOnLink {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.linkErrorSuccessMessage = NSLocalizedString(@"router.msg-link.The Almond was successfully linked.", @"The Almond was successfully linked.");
        self.state = RouterNetworkSettingsEditorState_successOnLink;

        // make sure the right nav buttons are placed and enabled
        [self buttonsForDoneState];

        [self.tableView reloadData];
    });
}

- (void)markErrorOnLink:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.linkErrorSuccessMessage = msg;
        self.state = RouterNetworkSettingsEditorState_errorOnLink;

        // make sure the right nav buttons are placed and enabled
        [self buttonsForLinkState];
        [self tryEnableSaveButton];

        [self.tableView reloadData];
    });
}

- (void)buttonsForLinkState {
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelEdits)];
    self.navigationItem.leftBarButtonItem = cancel;

    if (self.mode == RouterNetworkSettingsEditorMode_link) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSaveEdits)];
        save.enabled = NO;
        self.navigationItem.rightBarButtonItem = save;
    }
}

- (void)buttonsForDoneState {
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDoneEdits)];

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = done;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // after successfully linking/saving then do not show buttons or other stuff
    return (self.state == RouterNetworkSettingsEditorState_successOnLink) ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.mode) {
        case RouterNetworkSettingsEditorMode_editor:
            if (section == 0) {
                return TABLE_ROW_count;
            }
            else if (self.enableUnlinkActionButton) {
                return 1;
            }
            else {
                return 0;
            }

        case RouterNetworkSettingsEditorMode_link:
            return (section == 0) ? TABLE_ROW_count : 2;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        switch (self.mode) {
            case RouterNetworkSettingsEditorMode_editor: {
                NSString *cell_id = @"button_unlink";
                UITableViewCell *cell = [self makeButtonCell:tableView id:cell_id buttonTag:1 buttonTitle:NSLocalizedString(@"router.btn-title.Unlink Almond?", @"Unlink Almond?")];
                return cell;
            }

            case RouterNetworkSettingsEditorMode_link: {
                if (indexPath.row == 0) {
                    return [self makeButtonCell:tableView id:@"link_almond" buttonTitle:NSLocalizedString(@"router.btn-title.Link Almond Locally", @"Link Almond Locally") action:@selector(onSaveEdits) solidBackground:YES];
                }

                // only called when enableLocalAlmondLink is YES
                return [self makeButtonCell:tableView id:@"cloud_link" buttonTitle:NSLocalizedString(@"router.btn-title.Back to Cloud Link", @"Back to Cloud Link") action:@selector(onCancelEdits) solidBackground:NO];
            }
        }
    }

    enum TABLE_ROW row = (enum TABLE_ROW) indexPath.row;
    switch (row) {
        case TABLE_ROW_SSID_2: {
            NSString *cell_id = @"ssid2";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:NSLocalizedString(@"router.label.SSID 2.5GHz", @"SSID 2.5GHz") fieldValue:self.workingSettings.ssid2 secureField:NO];
            return cell;
        }
        case TABLE_ROW_SSID_5: {
            NSString *cell_id = @"ssid5";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:NSLocalizedString(@"router.label.SSID 5GHz", @"SSID 5GHz") fieldValue:self.workingSettings.ssid5 secureField:NO];
            return cell;
        }
        case TABLE_ROW_IP_ADDR: {
            NSString *cell_id = @"host";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:NSLocalizedString(@"router.label.IP Address", @"IP Address") fieldValue:self.workingSettings.host secureField:NO];
            return cell;
        }
        case TABLE_ROW_ADMIN_LOGIN: {
            NSString *cell_id = @"login";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:NSLocalizedString(@"router.label.Admin Login", @"Admin Login") fieldValue:self.workingSettings.login secureField:NO];
            return cell;
        }
        case TABLE_ROW_ADMIN_PWD: {
            NSString *cell_id = @"pwd";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:NSLocalizedString(@"router.label.Admin Password", @"Admin Password") fieldValue:self.workingSettings.password secureField:YES];
            return cell;
        }
        default:
            return nil;
    }
}

- (UITableViewCell *)makeNameValueCell:(UITableView *)tableView id:(NSString *)cell_id fieldTag:(int)fieldTag fieldLabel:(NSString *)fieldLabel fieldValue:(NSString *)fieldValue secureField:(BOOL)secureField {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;

        CGFloat width = CGRectGetWidth(tableView.frame) / 2;
        CGFloat right_padding = 15;
        CGRect frame = CGRectMake(width, 0, width - right_padding, 40);

        UIFont *font = [UIFont standardUITextFieldFont];

        UITextField *field = [[UITextField alloc] initWithFrame:frame];
        field.tag = fieldTag;
        field.delegate = self;
        field.text = fieldValue;
        field.font = font;
        field.textAlignment = NSTextAlignmentRight;
        field.secureTextEntry = secureField;

        cell.textLabel.text = fieldLabel;
        cell.textLabel.font = font;

        [cell.contentView addSubview:field];
    }

    return cell;
}

- (UITableViewCell *)makeButtonCell:(UITableView *)tableView id:(NSString *)cell_id buttonTag:(int)tag buttonTitle:(NSString *)title {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;

        CGFloat width = CGRectGetWidth(tableView.frame);
        CGRect frame = CGRectMake(0, 0, width, 40);
        frame = CGRectInset(frame, 10, 0);

        UIColor *color = [UIColor redColor];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = color;
        button.frame = frame;
        button.tag = tag;
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[color complementaryColor] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(onUnlinkAlmond) forControlEvents:UIControlEventTouchUpInside];

        [cell.contentView addSubview:button];
    }

    return cell;
}

- (UITableViewCell *)makeButtonCell:(UITableView *)tableView id:(NSString *)cell_id buttonTitle:(NSString *)title action:(SEL)action solidBackground:(BOOL)solidBackground {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];

        CGFloat width = CGRectGetWidth(tableView.frame);
        CGRect frame = CGRectMake(0, 0, width, 40);
        frame = CGRectInset(frame, 10, 0);

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        [button setTitle:title forState:UIControlStateNormal];

        UIColor *color = [UIColor infoBlueColor];

        if (solidBackground) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[color complementaryColor] forState:UIControlStateHighlighted];
            button.backgroundColor = color;
        }
        else {
            [button setTitleColor:color forState:UIControlStateNormal];
            [button setTitleColor:[color complementaryColor] forState:UIControlStateHighlighted];
            button.backgroundColor = [UIColor clearColor];
        }

        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];

        [cell.contentView addSubview:button];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return nil;
    }

    switch (self.state) {
        case RouterNetworkSettingsEditorState_promptForLinkCode: {
            NSString *msg = NSLocalizedString(@"router.title.No Cloud Warning", @"Please note that without cloud control you will not receive notifications nor have the ability to control your Almond remotely.");
            return [msg stringByAppendingString:@"\n"];  // newline adds bottom padding
        }

        case RouterNetworkSettingsEditorState_successOnLink:
        case RouterNetworkSettingsEditorState_errorOnLink: {
            NSString *msg = self.linkErrorSuccessMessage;
            return msg ? [msg stringByAppendingString:@"\n"] : nil;
        }

        default:
            return nil;
    }
}

#pragma mark - Action handlers

- (void)onLink {
    SFIAlmondLocalNetworkSettings *settings = self.workingSettings.copy;
    if (!settings.hasBasicCompleteSettings) {
        return;
    }

    self.HUD.labelText = NSLocalizedString(@"router.hud.Establishing Local Link...", @"Establishing Local Link...");
    self.HUD.minShowTime = 2;

    [self.HUD showAnimated:YES whileExecutingBlock:^() {
        // Test the connection (and interrogate the remote Almond for info about itself; the almond Mac and name
        // will be reflected in the settings after the test
        enum TestConnectionResult result = [settings testConnection];

        switch (result) {
            case TestConnectionResult_success: {
                SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

                SFIAlmondLocalNetworkSettings *old_settings = [toolkit localNetworkSettingsForAlmond:settings.almondplusMAC];
                if (old_settings) {
                    // in "Link Mode" we believe this is Almond is unknown to the app/system. In this case, it turns
                    // out we already know about it (settings already on file). So, we refuse to "link" (overwrite
                    // the settings).
                    [self markErrorOnLink:NSLocalizedString(@"router.error-msg.This Almond is already linked.", @"This Almond is already linked.")];
                    return;
                }

                // store the new/updated settings and update UI state; inform the delegate
                [toolkit setLocalNetworkSettings:settings];

                if (self.makeLinkedAlmondCurrentOne) {
                    SFIAlmondPlus *almond = settings.asLocalLinkAlmondPlus;

                    // switch the connection to Local
                    [toolkit setConnectionMode:SFIAlmondConnectionMode_local forAlmond:almond.almondplusMAC];
                    [toolkit setCurrentAlmond:almond];
                }

                [self markSuccessOnLink];
                [self.delegate networkSettingsEditorDidLinkAlmond:self settings:settings];

                break;
            }

            case TestConnectionResult_unknownError:
            case TestConnectionResult_unknown:
            case TestConnectionResult_macMismatch: {
                // should not be possible to get mac-mismatch error right now because this is only relevant when
                // editing settings on an unlinked Almond.
                [self markErrorOnLink:NSLocalizedString(@"router.error-msg.An error occurred trying to link with the Almond. Please try again.", @"An error occurred trying to link with the Almond. Please try again.")];
                break;
            }
        }
    }];
}

- (void)onSaveEdits {
    // validate edits just as if new link were being set up
    [self onLink];
}

- (void)onCancelEdits {
    [self.delegate networkSettingsEditorDidCancel:self];
}

- (void)onUnlinkAlmond {
    NSString *almondMac = self.settings.almondplusMAC;

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit removeLocalNetworkSettingsForAlmond:almondMac];

    [self.delegate networkSettingsEditorDidUnlinkAlmond:self];
}

- (void)onDoneEdits {
    [self.delegate networkSettingsEditorDidComplete:self];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    str = [str stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];

    enum TABLE_ROW row = (enum TABLE_ROW) textField.tag;
    switch (row) {
        case TABLE_ROW_SSID_2:
            self.workingSettings.ssid2 = str;
            [self tryEnableSaveButton];
            break;
        case TABLE_ROW_SSID_5:
            self.workingSettings.ssid5 = str;
            [self tryEnableSaveButton];
            break;
        case TABLE_ROW_IP_ADDR:
            self.workingSettings.host = str;
            [self tryEnableSaveButton];
            break;
        case TABLE_ROW_ADMIN_LOGIN:
            self.workingSettings.login = str;
            [self tryEnableSaveButton];
            break;
        case TABLE_ROW_ADMIN_PWD:
            self.workingSettings.password = str;
            [self tryEnableSaveButton];
            break;
        case TABLE_ROW_count:
            break;
    }

    return YES;
}

- (void)tryEnableSaveButton {
    BOOL same = [self.workingSettings isEqual:self.settings];
    self.navigationItem.rightBarButtonItem.enabled = !same;
}

@end