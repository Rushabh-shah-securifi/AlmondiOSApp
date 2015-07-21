//
// Created by Matthew Sinclair-Day on 7/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Colours/Colours.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "RouterNetworkSettingsEditor.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "UIFont+Securifi.h"

typedef NS_ENUM(unsigned int, TABLE_ROW) {
    TABLE_ROW_SSID_2 = 0,
    TABLE_ROW_SSID_5,
    TABLE_ROW_IP_ADDR,
    TABLE_ROW_ADMIN_LOGIN,
    TABLE_ROW_ADMIN_PWD,
    TABLE_ROW_count
};

@interface RouterNetworkSettingsEditor () <UITextFieldDelegate>
@property(nonatomic, strong) SFIAlmondLocalNetworkSettings *workingSettings;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end


@implementation RouterNetworkSettingsEditor

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Local Link";
    }

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    self.workingSettings = self.settings ? self.settings.copy : [SFIAlmondLocalNetworkSettings new];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };

    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    self.navigationItem.title = NSLocalizedString(@"Local Link Almond", @"Local Link");

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelEdits)];
    UIBarButtonItem *save = (self.mode == RouterNetworkSettingsEditorMode_link) ?
            [[UIBarButtonItem alloc] initWithTitle:@"Link" style:UIBarButtonItemStylePlain target:self action:@selector(onLink)] :
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSaveEdits)];
    save.enabled = NO;

    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;

    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.mode) {
        case RouterNetworkSettingsEditorMode_editor:
            return (section == 0) ? TABLE_ROW_count : 1;

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
                UITableViewCell *cell = [self makeButtonCell:tableView id:cell_id buttonTag:1 buttonTitle:@"Unlink Almond?"];
                return cell;
            }

            case RouterNetworkSettingsEditorMode_link: {
                if (indexPath.row == 0) {
                    return [self makeButtonCell:tableView id:@"link_almond" buttonTitle:@"Link Almond Locally" action:@selector(onSaveEdits) solidBackground:YES];
                }

                // only called when enableLocalAlmondLink is YES
                return [self makeButtonCell:tableView id:@"cloud_link" buttonTitle:@"Back to Cloud Link" action:@selector(onCancelEdits) solidBackground:NO];
            }
        }
    }

    enum TABLE_ROW row = (enum TABLE_ROW) indexPath.row;
    switch (row) {
        case TABLE_ROW_SSID_2: {
            NSString *cell_id = @"ssid2";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:@"SSID 2.5GHz" fieldValue:self.workingSettings.ssid2 secureField:NO];
            return cell;
        }
        case TABLE_ROW_SSID_5: {
            NSString *cell_id = @"ssid5";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:@"SSID 5GHz" fieldValue:self.workingSettings.ssid5 secureField:NO];
            return cell;
        }
        case TABLE_ROW_IP_ADDR: {
            NSString *cell_id = @"host";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:@"IP Address" fieldValue:self.workingSettings.host secureField:NO];
            return cell;
        }
        case TABLE_ROW_ADMIN_LOGIN: {
            NSString *cell_id = @"login";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:@"Admin Login" fieldValue:self.workingSettings.login secureField:NO];
            return cell;
        }
        case TABLE_ROW_ADMIN_PWD: {
            NSString *cell_id = @"pwd";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:@"Admin Password" fieldValue:self.workingSettings.password secureField:YES];
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

        CGFloat width = CGRectGetWidth(tableView.frame) / 2;
        CGRect frame = CGRectMake(width / 2, 0, width, 40);

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        [button setTitle:title forState:UIControlStateNormal];

        UIColor *color = [UIColor infoBlueColor];

        if (solidBackground) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[color complementaryColor] forState:UIControlStateHighlighted];
            button.backgroundColor = color;
            button.enabled = NO; // a bit of a kludge; treat the button as a Label

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
    if (section == 0) {
        return @"Please note that without cloud control you will not receive notifications nor have the ability to control your Almond remotely.\n"; // newline adds bottom padding
    }
    return nil;
}

#pragma mark - Action handlers

- (void)onLink {
    self.HUD.labelText = @"Establishing Local Link...";
    self.HUD.minShowTime = 2;

    SFIAlmondLocalNetworkSettings *settings = self.workingSettings.copy;
    [self.HUD showAnimated:YES whileExecutingBlock:^() {
        BOOL good = [settings testConnection];

        if (good) {
            [self.delegate networkSettingsEditorDidChangeSettings:self settings:settings];
        }
    }];
}

- (void)onSaveEdits {
    [self.delegate networkSettingsEditorDidChangeSettings:self settings:self.workingSettings];
}

- (void)onCancelEdits {
    [self.delegate networkSettingsEditorDidCancel:self];
}

- (void)onUnlinkAlmond {
    [self.delegate networkSettingsEditorDidUnlinkAlmond:self];
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