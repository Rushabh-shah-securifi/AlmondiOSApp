//
//  SFICloudLinkViewController.m
//  SecurifiApp
//
//  Created by Matthew Sinclair-Day on 7/18/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Colours/Colours.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SFICloudLinkViewController.h"
#import "UIFont+Securifi.h"
#import "Analytics.h"
#import "RouterNetworkSettingsEditor.h"

#define AFFILIATION_CODE_MAX_LENGTH 6
#define BUTTON_LINK_TAG 1

typedef NS_ENUM(unsigned int, SFICloudLinkViewControllerState) {
    SFICloudLinkViewControllerState_promptForLinkCode,
    SFICloudLinkViewControllerState_successLink,
    SFICloudLinkViewControllerState_errorLink,
};

@interface SFICloudLinkViewController () <UITextFieldDelegate, RouterNetworkSettingsEditorDelegate>
@property(nonatomic) NSString *linkCode;
@property(nonatomic) enum SFICloudLinkViewControllerState state;
@property(nonatomic) AffiliationUserComplete *affiliationDetails;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end

@implementation SFICloudLinkViewController

+ (UIViewController *)cloudLinkController {
    SFICloudLinkViewController *ctrl = [SFICloudLinkViewController new];
    ctrl.enableLocalAlmondLink = [SecurifiToolkit sharedInstance].configuration.enableLocalNetworking;

    return [[UINavigationController alloc] initWithRootViewController:ctrl];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = NSLocalizedString(@"cloudlink.title.Cloud Link", @"Cloud Link");
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.state = SFICloudLinkViewControllerState_promptForLinkCode;

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };

    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    self.navigationItem.title = NSLocalizedString(@"Link Almond", @"Cloud Link");

    // keep the table view from being placed underneath the nav bar
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.contentOffset = CGPointMake(0, -20);

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelLink)];
    self.navigationItem.leftBarButtonItem = cancel;

    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];

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
    [self.view endEditing:YES];
    
    NSString *code = self.linkCode;

    BOOL empty = (code.length == 0);
    if (empty) {
        return;
    }

    NSString *msg = NSLocalizedString(@"Please wait while your Almond is being linked to cloud.", @"Please wait while your Almond is being linked to cloud.");
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self showHud:msg];
    });

    [self sendAffiliationRequest:code];
}

- (void)onCancelLink {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onLocalLink {
    RouterNetworkSettingsEditor *editor = [RouterNetworkSettingsEditor new];
    editor.mode = RouterNetworkSettingsEditorMode_link;
    editor.delegate = self;
    editor.makeLinkedAlmondCurrentOne = YES;

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editor];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onDone {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tryEnableLinkButton:(NSUInteger)codeLength {
    if (self.state == SFICloudLinkViewControllerState_successLink) {
        return;
    }

    BOOL not_too_long = codeLength <= AFFILIATION_CODE_MAX_LENGTH;
    BOOL in_range = (codeLength > 0 && not_too_long);

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    for (UIView *view in cell.contentView.subviews) {
        if (view.tag == BUTTON_LINK_TAG) {
            UIButton *button = (UIButton *) view;
            button.enabled = in_range;
        }
    };
}

#pragma mark - HUD

- (void)showHud:(NSString *)msg {
    self.HUD.minShowTime = 2;
    self.HUD.labelText = NSLocalizedString(@"cloudlink.label.Linking to Cloud", @"Linking to Cloud");
    self.HUD.detailsLabelText = msg;
    [self.HUD show:YES];
    [self.HUD hide:YES afterDelay:10];
}

- (void)hideHud {
    [self.HUD hide:YES afterDelay:1];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    switch (self.state) {
        case SFICloudLinkViewControllerState_promptForLinkCode:
            return 2;
        case SFICloudLinkViewControllerState_successLink:
            return 1;
        case SFICloudLinkViewControllerState_errorLink:
            return 2;
        default:
            return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.state) {
        case SFICloudLinkViewControllerState_errorLink:
        case SFICloudLinkViewControllerState_promptForLinkCode:
            switch (section) {
                case 0:
                    return 1;
                case 1:
                    return self.enableLocalAlmondLink ? 2 : 1;
                default:
                    return 0;
            }

        case SFICloudLinkViewControllerState_successLink:
            return 2 + self.affiliationDetails.ssidCount;

        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return nil;
    }

    switch (self.state) {
        case SFICloudLinkViewControllerState_promptForLinkCode: {
            return NSLocalizedString(@"Run the Almond Account app and enter the code displayed.", @"Run the Almond Account app and enter the code displayed.");
        }

        case SFICloudLinkViewControllerState_successLink:
            return nil;

        case SFICloudLinkViewControllerState_errorLink: {
            NSString *str = [self reasonCodeMessage:self.affiliationDetails.reasonCode];
            return [str stringByAppendingString:@"\n\n"]; // add some padding to the bottom
        }

        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    //called after title for header. Added because titleforheader always shows bold font.
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]] && [self respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
        headerView.textLabel.font = [UIFont securifiFont:15];
        headerView.textLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;

    switch (self.state) {
        case SFICloudLinkViewControllerState_promptForLinkCode:
        case SFICloudLinkViewControllerState_errorLink:
            if (indexPath.section == 0) {
                return [self makeInputFieldCell:tableView id:@"code_field" fieldValue:self.linkCode];
            }
            else {
                if (row == 0) {
                    return [self makeButtonCell:tableView id:@"link_almond" buttonTitle:NSLocalizedString(@"cloudlink.button.Link Almond", "Link Almond") buttonTag:BUTTON_LINK_TAG action:@selector(onLink) solidBackground:YES];
                }

                // only called when enableLocalAlmondLink is YES
                return [self makeButtonCell:tableView id:@"local_link" buttonTitle:NSLocalizedString(@"cloudlink.button.Add Almond Locally", @"Add Almond Locally") buttonTag:0 action:@selector(onLocalLink) solidBackground:NO];
            }

        case SFICloudLinkViewControllerState_successLink: {
            AffiliationUserComplete *details = self.affiliationDetails;

            if (row == 0) {
                return [self makeNameValueCell:tableView id:@"almond_name" fieldTag:1 fieldLabel:NSLocalizedString(@"cloudlink.label.Name", @"Name") fieldValue:details.almondplusName];
            }
            else if (row == 1) {
                return [self makeNameValueCell:tableView id:@"almond_mac" fieldTag:1 fieldLabel:NSLocalizedString(@"cloudlink.label.MAC Address", @"MAC Address") fieldValue:details.formattedAlmondPlusMac];
            }
            else {
                NSUInteger ssid_index = (NSUInteger) (row - 2);
                NSString *label = (ssid_index == 0) ? NSLocalizedString(@"cloudlink.label.WIFI SSID", "WIFI SSID") : @"";

                NSArray *names = details.ssidNames;
                NSString *value = names[ssid_index];

                return [self makeNameValueCell:tableView id:@"almond_ssid" fieldTag:1 fieldLabel:label fieldValue:value];
            }
        }
    }

    return nil;
}

- (UITableViewCell *)makeNameValueCell:(UITableView *)tableView id:(NSString *)cell_id fieldTag:(int)fieldTag fieldLabel:(NSString *)fieldLabel fieldValue:(NSString *)fieldValue {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.tag = fieldTag;
    }

    UIFont *font = [UIFont standardUITextFieldFont];

    cell.textLabel.text = fieldLabel;
    cell.textLabel.font = font;

    cell.detailTextLabel.text = fieldValue;
    cell.detailTextLabel.font = font;

    return cell;
}

- (UITableViewCell *)makeInputFieldCell:(UITableView *)tableView id:(NSString *)cell_id fieldValue:(NSString *)fieldValue {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;

        CGFloat width = CGRectGetWidth(tableView.frame);
        CGFloat right_padding = 0;
        CGRect frame = CGRectMake(0, 0, width - right_padding, 40);

        UIFont *font = [[UIFont standardUITextFieldFont] fontWithSize:25];

        UITextField *field = [[UITextField alloc] initWithFrame:frame];
        field.delegate = self;
        field.placeholder = NSLocalizedString(@"Enter code", @"Enter code");
        field.font = font;
        field.text = fieldValue;
        field.textAlignment = NSTextAlignmentCenter;

        [cell.contentView addSubview:field];
    }

    return cell;
}

- (UITableViewCell *)makeButtonCell:(UITableView *)tableView id:(NSString *)cell_id buttonTitle:(NSString *)title buttonTag:(NSInteger)buttonTag action:(SEL)action solidBackground:(BOOL)solidBackground {
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
        button.tag = buttonTag;
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

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    str = [str stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];

    BOOL not_too_long = str.length <= AFFILIATION_CODE_MAX_LENGTH;

    if (not_too_long) {
        self.linkCode = str;
    }

    [self tryEnableLinkButton:self.linkCode.length];

    return not_too_long;
}

#pragma mark - Command Responses

- (void)onAffiliationUserComplete:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        NSNotification *notifier = (NSNotification *) sender;
        NSDictionary *data = [notifier userInfo];

        AffiliationUserComplete *obj = (AffiliationUserComplete *) [data valueForKey:@"data"];
        self.affiliationDetails = obj;

        if (obj.isSuccessful) {
            self.navigationItem.title = NSLocalizedString(@"Almond Linked", @"Almond Linked");
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
            self.navigationItem.leftBarButtonItem = nil;

            self.state = SFICloudLinkViewControllerState_successLink;
        }
        else {
            self.state = SFICloudLinkViewControllerState_errorLink;
        }

        [self.tableView reloadData];
        [self hideHud];
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

- (void)sendAffiliationRequest:(NSString *)linkCode {
    [[SecurifiToolkit sharedInstance] asyncSendAlmondAffiliationRequest:linkCode];
}

#pragma mark - RouterNetworkSettingsEditorDelegate methods

- (void)networkSettingsEditorDidLinkAlmond:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    // do nothing; wait for the didComplete callback
}

- (void)networkSettingsEditorDidChangeSettings:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings {
    [editor dismissViewControllerAnimated:YES completion:^() {
        [self onDone];
    }];
}

- (void)networkSettingsEditorDidCancel:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkSettingsEditorDidComplete:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:^() {
        [self onDone];
    }];
}

- (void)networkSettingsEditorDidUnlinkAlmond:(RouterNetworkSettingsEditor *)editor {
    [editor dismissViewControllerAnimated:YES completion:^() {
        [self onDone];
    }];
}

@end
