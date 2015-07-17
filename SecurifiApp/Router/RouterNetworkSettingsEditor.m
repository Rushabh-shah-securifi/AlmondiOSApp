//
// Created by Matthew Sinclair-Day on 7/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

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
@property(nonatomic, strong) SFIAlmondLocalNetworkSettings *working;
@end


@implementation RouterNetworkSettingsEditor

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {

    }

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.bounces = NO;
    self.working = self.settings.copy;

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelEdits)];
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onSaveEdits)];
    save.enabled = NO;

    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = save;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TABLE_ROW_count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    enum TABLE_ROW row = (enum TABLE_ROW) indexPath.row;
    switch (row) {
        case TABLE_ROW_SSID_2: {
            NSString *cell_id = @"ssid2";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:@"SSID 2.5Ghz" fieldValue:self.working.ssid2];
            return cell;
        }
        case TABLE_ROW_SSID_5: {
            NSString *cell_id = @"ssid5";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:@"SSID 5Ghz" fieldValue:self.working.ssid5];
            return cell;
        }
        case TABLE_ROW_IP_ADDR: {
            NSString *cell_id = @"host";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:@"IP Address" fieldValue:self.working.host];
            return cell;
        }
        case TABLE_ROW_ADMIN_LOGIN: {
            NSString *cell_id = @"login";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:@"Admin Login" fieldValue:self.working.login];
            return cell;
        }
        case TABLE_ROW_ADMIN_PWD: {
            NSString *cell_id = @"pwd";
            UITableViewCell *cell = [self makeNameValueCell:tableView id:cell_id fieldTag:row fieldLabel:@"Admin Password" fieldValue:self.working.password];
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

    cell.textLabel.text = fieldLabel;
    cell.textLabel.font = font;
    
    [cell.contentView addSubview:field];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Please note that without cloud control you will not receive notifications nor have the ability to control your Almond remotely.\n"; // newline adds bottom padding
}

#pragma mark - Action handlers

- (void)onSaveEdits {
    [self.delegate networkSettingsEditorDidChangeSettings:self settings:self.working];
}

- (void)onCancelEdits {
    [self.delegate networkSettingsEditorDidCancel:self];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    str = [str stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];

    if (str.length == 0) {
        return NO;
    }

    enum TABLE_ROW row = (enum TABLE_ROW) textField.tag;
    switch (row) {
        case TABLE_ROW_SSID_2:
            self.working.ssid2 = str;
            [self tryEnableSaveButton];
            break;
        case TABLE_ROW_SSID_5:
            self.working.ssid5 = str;
            [self tryEnableSaveButton];
            break;
        case TABLE_ROW_IP_ADDR:
            self.working.host = str;
            [self tryEnableSaveButton];
            break;
        case TABLE_ROW_ADMIN_LOGIN:
            self.working.login = str;
            [self tryEnableSaveButton];
            break;
        case TABLE_ROW_ADMIN_PWD:
            self.working.password = str;
            [self tryEnableSaveButton];
            break;
        case TABLE_ROW_count:
            break;
    }

    return YES;
}

- (void)tryEnableSaveButton {
    BOOL same = [self.working isEqual:self.settings];
    self.navigationItem.rightBarButtonItem.enabled = !same;
}

@end