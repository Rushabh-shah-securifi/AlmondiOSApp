//
//  SFICloudLinkViewController.m
//  SecurifiApp
//
//  Created by Matthew Sinclair-Day on 7/18/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Colours/Colours.h>
#import "SFICloudLinkViewController.h"
#import "UIFont+Securifi.h"
#import "Analytics.h"

typedef NS_ENUM(unsigned int, SFICloudLinkViewControllerMode) {
    SFICloudLinkViewControllerMode_promptForLinkCode,
    SFICloudLinkViewControllerMode_successLink,
    SFICloudLinkViewControllerMode_errorLink,
};

@interface SFICloudLinkViewController () <UITextFieldDelegate>
@property(nonatomic) NSString *linkCode;
@property(nonatomic) enum SFICloudLinkViewControllerMode mode;
@property(nonatomic) AffiliationUserComplete *affilitationDetails;
@end

@implementation SFICloudLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mode = SFICloudLinkViewControllerMode_promptForLinkCode;

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };

    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    self.navigationItem.title = NSLocalizedString(@"Link Almond", @"Cloud Link");

    self.tableView.bounces = NO;

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelLink)];
    UIBarButtonItem *link = [[UIBarButtonItem alloc] initWithTitle:@"Link" style:UIBarButtonItemStylePlain target:self action:@selector(onLink)];
    link.enabled = NO;

    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem = link;

    [[Analytics sharedInstance] markAlmondAffiliation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAffiliationUserComplete:) name:AFFILIATION_COMPLETE_NOTIFIER object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFFILIATION_COMPLETE_NOTIFIER object:nil];
}

#pragma mark - Action methods

- (void)onLink {
    BOOL empty = (self.linkCode.length == 0);
    if (empty) {
        return;
    }
}

- (void)onCancelLink {

}

- (void)onLocalLink {

}

- (void)onDone {

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.mode) {
        case SFICloudLinkViewControllerMode_promptForLinkCode:
            return 2;
        case SFICloudLinkViewControllerMode_successLink:
            return 1;
        case SFICloudLinkViewControllerMode_errorLink:
            return 2;
        default:
            return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.mode) {
        case SFICloudLinkViewControllerMode_errorLink:
        case SFICloudLinkViewControllerMode_promptForLinkCode:
            switch (section) {
                case 0:
                    return 1;
                case 1:
                    return self.enableLocalAlmondLink ? 2 : 1;
                default:
                    return 0;
            }
        case SFICloudLinkViewControllerMode_successLink:
            return 3;

        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (self.mode) {
        case SFICloudLinkViewControllerMode_promptForLinkCode: {
            if (section != 0) {
                return nil;
            }

            return @"Type the Code shown on your Almond's screen, if you are already running the Touchscreen Wizard. Alternatively you can attain the Code from the Touchscreen Almond Account App.";
        }

        case SFICloudLinkViewControllerMode_successLink:
            return nil;

        case SFICloudLinkViewControllerMode_errorLink:
            return [self reasonCodeMessage:self.affilitationDetails.reasonCode];

        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;

    switch (self.mode) {
        case SFICloudLinkViewControllerMode_promptForLinkCode:
        case SFICloudLinkViewControllerMode_errorLink:
            if (indexPath.section == 0) {
                return [self makeInputFieldCell:tableView id:@"code_field"];
            }
            else {
                if (row == 0) {
                    return [self makeButtonCell:tableView id:@"link_almond" buttonTag:1 buttonTitle:@"Link Almond" action:@selector(onLink) solidBackground:YES];
                }

                return [self makeButtonCell:tableView id:@"local_link" buttonTag:1 buttonTitle:@"Add Almond Locally" action:@selector(onLocalLink) solidBackground:NO];
            }

        case SFICloudLinkViewControllerMode_successLink: {
            AffiliationUserComplete *details = self.affilitationDetails;

            if (row == 0) {
                return [self makeNameValueCell:tableView id:@"almond_name" fieldTag:1 fieldLabel:@"" fieldValue:details.almondplusName secureField:NO];
            }
            else if (row == 1) {
                return [self makeNameValueCell:tableView id:@"almond_mac" fieldTag:1 fieldLabel:@"MAC" fieldValue:details.formattedAlmondPlusMac secureField:NO];
            }
            else if (row == 2) {
                // trim and array each sid on its own line
                NSMutableArray *ssids = [NSMutableArray arrayWithArray:[details.wifiSSID componentsSeparatedByString:@","]];
                for (uint index = 0; index < ssids.count; index++) {
                    NSString *sid = ssids[index];
                    ssids[index] = [sid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];;
                }
                NSString *value = [ssids componentsJoinedByString:@"\n"];
                return [self makeNameValueCell:tableView id:@"almond_mac" fieldTag:1 fieldLabel:@"SSID" fieldValue:value secureField:NO];
            }

            break;
        }
    }

    return nil;
}

- (UITableViewCell *)makeNameValueCell:(UITableView *)tableView id:(NSString *)cell_id fieldTag:(int)fieldTag fieldLabel:(NSString *)fieldLabel fieldValue:(NSString *)fieldValue secureField:(BOOL)secureField {
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
    field.secureTextEntry = secureField;

    cell.textLabel.text = fieldLabel;
    cell.textLabel.font = font;

    [cell.contentView addSubview:field];
    return cell;
}

- (UITableViewCell *)makeInputFieldCell:(UITableView *)tableView id:(NSString *)cell_id {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    CGFloat width = CGRectGetWidth(tableView.frame);
    CGFloat right_padding = 0;
    CGRect frame = CGRectMake(width, 0, width - right_padding, 40);

    UIFont *font = [UIFont standardUITextFieldFont];

    UITextField *field = [[UITextField alloc] initWithFrame:frame];
    field.delegate = self;
    field.placeholder = @"Enter code";
    field.font = font;
    field.textAlignment = NSTextAlignmentLeft;

    [cell.contentView addSubview:field];
    return cell;
}

- (UITableViewCell *)makeButtonCell:(UITableView *)tableView id:(NSString *)cell_id buttonTag:(int)tag buttonTitle:(NSString *)title action:(SEL)action solidBackground:(BOOL)solidBackground {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    CGFloat width = CGRectGetWidth(tableView.frame) / 2;
    CGRect frame = CGRectMake(width / 2, 0, width, 40);


    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = tag;
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
    return cell;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    str = [str stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];

    BOOL valid = [self validateLinkCode:str];
    if (valid) {
        self.linkCode = str;
    }

    [self tryEnableLinkButton];
    return valid;
}

- (void)tryEnableLinkButton {
    BOOL valid = [self validateLinkCode:self.linkCode];
    self.navigationItem.rightBarButtonItem.enabled = valid;
}

- (BOOL)validateLinkCode:(NSString *)linkCode {
    NSUInteger length = linkCode.length;
    BOOL in_range = (length > 0 && length <= AFFILIATION_CODE_CHAR_COUNT);
    return in_range;
}

#pragma mark - Command Responses

- (void)onAffiliationUserComplete:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        NSNotification *notifier = (NSNotification *) sender;
        NSDictionary *data = [notifier userInfo];

        AffiliationUserComplete *obj = (AffiliationUserComplete *) [data valueForKey:@"data"];
        self.affilitationDetails = obj;

        if (obj.isSuccessful) {
            self.navigationItem.title = NSLocalizedString(@"Almond Linked", @"Almond Linked");
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
            self.navigationItem.leftBarButtonItem = nil;

            self.mode = SFICloudLinkViewControllerMode_successLink;
        }
        else {
            switch (obj.reasonCode) {
                case AffiliationUserCompleteFailureCode_loginAgain:
                case AffiliationUserCompleteFailureCode_loginAgain2:
                case AffiliationUserCompleteFailureCode_loginAgain3:
                    [self logoutUser];
                    break;

                default:
                    break;
            }

            self.mode = SFICloudLinkViewControllerMode_errorLink;
        }

        [self.tableView reloadData];
    });
}

- (NSString *)reasonCodeMessage:(enum AffiliationUserCompleteFailureCode)failureCode {
    switch (failureCode) {
        case AffiliationUserCompleteFailureCode_systemDown:
            return NSLocalizedString(@"Please try later.", @"Please try later.");

        case AffiliationUserCompleteFailureCode_invalidCode:
        case AffiliationUserCompleteFailureCode_invalidCode2:
            return NSLocalizedString(@"Please enter a valid code.", @"Please enter a valid code.");

        case AffiliationUserCompleteFailureCode_alreadyLinked:
            return NSLocalizedString(@"This Almond is already linked to another user.", @"This Almond is already linked to another user. \nContact us at support@securifi.com");

        case AffiliationUserCompleteFailureCode_loginAgain:
        case AffiliationUserCompleteFailureCode_loginAgain2:
        case AffiliationUserCompleteFailureCode_loginAgain3:
            return [NSString stringWithFormat:NSLocalizedString(@"Almond could not be affiliated", @"Almond could not be affiliated.\n%@"), failureCode];;

        default:
            return nil;
    }
}

- (void)logoutUser {
    [[SecurifiToolkit sharedInstance] asyncSendLogout];
}

@end
