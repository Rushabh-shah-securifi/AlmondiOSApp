//
//  SFIAccountsTableViewController.m
//  Almond
//
//  Created by Priya Yerunkar on 15/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFIAccountsTableViewController.h"
#import "MBProgressHUD.h"
#import "iToast.h"
#import "UIFont+Securifi.h"
#import "Analytics.h"

static NSString *simpleTableIdentifier = @"AccountCell";

#define FIRST_NAME  0
#define LAST_NAME   1
#define ADDRESS_1   2
#define ADDRESS_2   3
#define ADDRESS_3   4
#define COUNTRY     5
#define ZIPCODE     6

#define NAME_CHANGED_OWNED_ALMOND   1
#define NAME_CHANGED_SHARED_ALMOND  2

#define DELETE_ACCOUNT_CONFIRMATION     0
#define UNLINK_ALMOND_CONFIRMATION      1
#define USER_INVITE_ALERT               2

#define EXPANDED_PROFILE_ROW_HEIGHT 520
#define EXPANDED_OWNED_ALMOND_ROW_HEIGHT 170
#define EXPANDED_SHARED_ALMOND_ROW_HEIGHT 120


@interface SFIAccountsTableViewController ()
@property(nonatomic) NSMutableArray *ownedAlmondList;
@property(nonatomic) NSMutableArray *sharedAlmondList;
@property(nonatomic) SFIUserProfile *userProfile;

@property(nonatomic) NSString *changedFirstName;
@property(nonatomic) NSString *changedLastName;
@property(nonatomic) NSString *changedAddress1;
@property(nonatomic) NSString *changedAddress2;
@property(nonatomic) NSString *changedAddress3;
@property(nonatomic) NSString *changedCountry;
@property(nonatomic) NSString *changedZipcode;
@property(nonatomic) NSString *changedAlmondName;
@property(nonatomic) NSString *currentAlmondMAC;
@property(nonatomic) NSString *changedEmailID;

@property(nonatomic, readonly) MBProgressHUD *HUD;

@property(nonatomic, readonly) UITextField *tfFirstName;
@property(nonatomic, readonly) UITextField *tfLastName;
@property(nonatomic, readonly) UITextField *tfAddress1;
@property(nonatomic, readonly) UITextField *tfAddress2;
@property(nonatomic, readonly) UITextField *tfAddress3;
@property(nonatomic, readonly) UITextField *tfCountry;
@property(nonatomic, readonly) UITextField *tfZipCode;
@property(nonatomic, readonly) UITextField *tfRenameAlmond;

@property(nonatomic) int nameChangedForAlmond;
@property NSTimer *almondNameChangeTimer;
@property BOOL isAlmondNameChangeSuccessful;

@end

@implementation SFIAccountsTableViewController

@synthesize userProfile, ownedAlmondList, sharedAlmondList;
@synthesize changedFirstName, changedLastName, tfFirstName, tfLastName;
@synthesize changedAddress1, changedAddress2, changedAddress3, changedCountry, changedZipcode;
@synthesize tfAddress1, tfAddress2, tfAddress3, tfCountry, tfZipCode, changedAlmondName;
@synthesize currentAlmondMAC, changedEmailID, nameChangedForAlmond, tfRenameAlmond;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };

    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizesSubviews = YES;

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    self.navigationItem.title = NSLocalizedString(@"accounts.navbar-title.settings", @"Accounts Settings");

    ownedAlmondList = [[NSMutableArray alloc] init];
    sharedAlmondList = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(userProfileResponseCallback:)
                   name:USER_PROFILE_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(delAccountResponseCallback:)
                   name:DELETE_ACCOUNT_RESPONSE_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(updateProfileResponseCallback:)
                   name:UPDATE_USER_PROFILE_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(ownedAlmondDataResponseCallback:)
                   name:ALMOND_AFFILIATION_DATA_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(unlinkAlmondResponseCallback:)
                   name:UNLINK_ALMOND_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(userInviteResponseCallback:)
                   name:USER_INVITE_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(delSecondaryUserResponseCallback:)
                   name:DELETE_SECONDARY_USER_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(almondNameChangeResponseCallback:)
                   name:kSFIDidChangeAlmondName
                 object:nil];

    [center addObserver:self
               selector:@selector(sharedAlmondDataResponseCallback:)
                   name:ME_AS_SECONDARY_USER_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(delMeAsSecondaryUserResponseCallback:)
                   name:DELETE_ME_AS_SECONDARY_USER_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(mobileCommandResponseCallback:)
                   name:MOBILE_COMMAND_NOTIFIER
                 object:nil];

    [self sendUserProfileRequest];
    
    [[Analytics sharedInstance] markAccountsScreen];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:USER_PROFILE_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:DELETE_ACCOUNT_RESPONSE_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:UPDATE_USER_PROFILE_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:ALMOND_AFFILIATION_DATA_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:UNLINK_ALMOND_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:USER_INVITE_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:DELETE_SECONDARY_USER_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:ALMOND_NAME_CHANGE_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:ME_AS_SECONDARY_USER_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:DELETE_ME_AS_SECONDARY_USER_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:MOBILE_COMMAND_NOTIFIER
                    object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HUD mgt

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}


#pragma mark - Button Handlers

- (IBAction)doneButtonHandler:(id)sender {
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.delegate userAccountDidDone:self];
}

#pragma mark - Data access

- (SFIAlmondPlus *)ownedAlmondAtIndexPathRow:(NSInteger)row {
    NSUInteger index = (NSUInteger) (row - 1);
    if (index >= ownedAlmondList.count) {
        return nil;
    }
    return ownedAlmondList[index];
}

- (SFIAlmondPlus *)sharedAlmondAtIndexPathRow:(NSInteger)row {
    NSUInteger index = (NSUInteger) (row - 1);
    if (index >= sharedAlmondList.count) {
        return nil;
    }
    return sharedAlmondList[index];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    if (indexPath.row == 0) {
        if (userProfile.isExpanded) {
            return EXPANDED_PROFILE_ROW_HEIGHT;
        }
    }
    else if ([ownedAlmondList count] > 0) {
        if (indexPath.row > 0 && indexPath.row <= [ownedAlmondList count]) {
            SFIAlmondPlus *currentAlmond = [self ownedAlmondAtIndexPathRow:indexPath.row];
            if (currentAlmond.isExpanded) {
                if ([currentAlmond.accessEmailIDs count] > 0) {
                    return EXPANDED_OWNED_ALMOND_ROW_HEIGHT + 30 + ([currentAlmond.accessEmailIDs count] * 30);
                }
                return EXPANDED_OWNED_ALMOND_ROW_HEIGHT;
            }
        }
    }
    else if ([sharedAlmondList count] > 0) {
        if (indexPath.row > [ownedAlmondList count] && indexPath.row <= ([ownedAlmondList count] + [sharedAlmondList count])) {
            SFIAlmondPlus *currentAlmond = [self sharedAlmondAtIndexPathRow:indexPath.row];
            if (currentAlmond.isExpanded) {
                return EXPANDED_SHARED_ALMOND_ROW_HEIGHT;
            }
        }
    }
    else {
        return 120;
    }

    return 120;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1 + [ownedAlmondList count] + [sharedAlmondList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (indexPath.row == 0) {
        cell = [self createUserProfileCell:cell listRow:(int) indexPath.row];
    }

    if ([ownedAlmondList count] > 0) {
        if (indexPath.row > 0 && indexPath.row <= [ownedAlmondList count]) {
            cell = [self createOwnedAlmondCell:cell listRow:(int) indexPath.row];
        }
    }

    if ([sharedAlmondList count] > 0) {
        if (indexPath.row > [ownedAlmondList count] && indexPath.row <= ([ownedAlmondList count] + [sharedAlmondList count])) {
            cell = [self createSharedAlmondCell:cell listRow:(int) indexPath.row];
        }
    }
    return cell;

}


#pragma mark - Custom cell creation

- (UITableViewCell *)createUserProfileCell:(UITableViewCell *)cell listRow:(int)indexPathRow {

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;


    float baseYCordinate = 0;

    UIView *backgroundLabel = [[UIView alloc] init];
    backgroundLabel.userInteractionEnabled = TRUE;

    backgroundLabel.backgroundColor = [UIColor colorWithRed:86.0 / 255.0 green:116.0 / 255.0 blue:124.0 / 255.0 alpha:1.0];


    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate + 7, self.tableView.frame.size.width - 30, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    [lblTitle setFont:[UIFont securifiLightFont:25]];
    lblTitle.text = NSLocalizedString(@"accounts.userprofile.title.account", @"Account");
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [backgroundLabel addSubview:lblTitle];

    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 60, 12, 23, 23)];
    [backgroundLabel addSubview:imgArrow];

    UIButton *btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
    btnProfile.frame = CGRectMake(self.tableView.frame.size.width - 80, baseYCordinate + 5, 50, 50);
    btnProfile.backgroundColor = [UIColor clearColor];
    [btnProfile addTarget:self action:@selector(onProfileClicked:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundLabel addSubview:btnProfile];


    baseYCordinate = 45;
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
    imgLine.image = [UIImage imageNamed:@"line"];
    imgLine.alpha = 0.5;
    [backgroundLabel addSubview:imgLine];
    baseYCordinate += 5;

    if (!userProfile.isExpanded) {

        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, 110);

        imgArrow.image = [UIImage imageNamed:@"down_arrow"];

        baseYCordinate += 5;

        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 20)];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.textColor = [UIColor whiteColor];
        [lblName setFont:[UIFont securifiBoldFontLarge]];
        if ([userProfile.firstName isEqualToString:@""] && [userProfile.lastName isEqualToString:@""]) {
            lblName.text = NSLocalizedString(@"accounts.userprofile.title.placeholder.name", @"We don't know your name yet");
        }
        else if (userProfile.firstName == NULL) {
            lblName.text = @""; //Default;
        }
        else {
            lblName.text = [NSString stringWithFormat:@"%@ %@", userProfile.firstName, userProfile.lastName];
        }
        lblName.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblName];
        baseYCordinate += 25;

        UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        lblEmail.backgroundColor = [UIColor clearColor];
        lblEmail.textColor = [UIColor whiteColor];
        [lblEmail setFont:[UIFont standardUITextFieldFont]];
        lblEmail.text = userProfile.userEmail;
        lblEmail.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblEmail];
    }
    else {
        //Expanded View
        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, EXPANDED_PROFILE_ROW_HEIGHT - 10);
        imgArrow.image = [UIImage imageNamed:@"up_arrow"];

        //PRIMARY EMAIL
        UILabel *lblEmailTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        lblEmailTitle.backgroundColor = [UIColor clearColor];
        lblEmailTitle.textColor = [UIColor whiteColor];
        [lblEmailTitle setFont:[UIFont securifiBoldFont:13]];
        lblEmailTitle.text = NSLocalizedString(@"accounts.userprofile.label.primaryEmail", @"PRIMARY EMAIL");
        lblEmailTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblEmailTitle];

        baseYCordinate += 25;

        UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        lblEmail.backgroundColor = [UIColor clearColor];
        lblEmail.textColor = [UIColor whiteColor];
        [lblEmail setFont:[UIFont standardUITextFieldFont]];
        lblEmail.text = userProfile.userEmail;
        lblEmail.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblEmail];

        baseYCordinate += 30;

        UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine1.image = [UIImage imageNamed:@"line"];
        imgLine1.alpha = 0.2;
        [backgroundLabel addSubview:imgLine1];

        baseYCordinate += 5;

        //Password
        UILabel *lblPasswordTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblPasswordTitle.backgroundColor = [UIColor clearColor];
        lblPasswordTitle.textColor = [UIColor whiteColor];
        [lblPasswordTitle setFont:[UIFont securifiBoldFont:13]];
        lblPasswordTitle.text = NSLocalizedString(@"accounts.userprofile.label.password", @"PASSWORD");
        lblPasswordTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblPasswordTitle];

        UIButton *btnChangePassword = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangePassword.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangePassword.backgroundColor = [UIColor clearColor];
        [btnChangePassword setTitle:NSLocalizedString(@"accounts.userprofile.button.changePassword", @"Change Password") forState:UIControlStateNormal];
        [btnChangePassword.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangePassword setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangePassword.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangePassword addTarget:self action:@selector(onChangePasswordClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnChangePassword];

        baseYCordinate += 30;
        UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine2.image = [UIImage imageNamed:@"line"];
        imgLine2.alpha = 0.2;
        [backgroundLabel addSubview:imgLine2];

        //First Name
        baseYCordinate += 5;
        UILabel *lblFNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblFNameTitle.backgroundColor = [UIColor clearColor];
        lblFNameTitle.textColor = [UIColor whiteColor];
        [lblFNameTitle setFont:[UIFont securifiBoldFont:13]];
        lblFNameTitle.text = NSLocalizedString(@"accounts.userprofile.label.firstName", @"FIRST NAME");
        lblFNameTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblFNameTitle];

        UIButton *btnChangeFName = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeFName.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeFName.backgroundColor = [UIColor clearColor];
        [btnChangeFName.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeFName setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeFName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeFName addTarget:self action:@selector(onFirstNameClicked:) forControlEvents:UIControlEventTouchUpInside];

        if ([userProfile.firstName isEqualToString:@""]) {
            [btnChangeFName setTitle:NSLocalizedString(@"accounts.userprofile.button.add", @"Add") forState:UIControlStateNormal];
        }
        else {
            [btnChangeFName setTitle:NSLocalizedString(@"accounts.userprofile.button.edit", @"Edit") forState:UIControlStateNormal];
        }

        [backgroundLabel addSubview:btnChangeFName];

        baseYCordinate += 20;

        tfFirstName = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfFirstName.placeholder = NSLocalizedString(@"accounts.userprofile.textfield.placeholder.firstName", @"We do not know your first name yet");
        [tfFirstName setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if (![userProfile.firstName isEqualToString:@""]) {
            tfFirstName.text = userProfile.firstName;
        }
        tfFirstName.textAlignment = NSTextAlignmentLeft;
        tfFirstName.textColor = [UIColor whiteColor];
        tfFirstName.font = [UIFont standardUITextFieldFont];
        tfFirstName.tag = FIRST_NAME;
        //[tfName becomeFirstResponder];
        [tfFirstName setReturnKeyType:UIReturnKeyDone];
        tfFirstName.delegate = self;
        [tfFirstName addTarget:self action:@selector(firstNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfFirstName addTarget:self action:@selector(firstNameTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        tfFirstName.enabled = FALSE;
        [backgroundLabel addSubview:tfFirstName];

        baseYCordinate += 30;

        UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine3.image = [UIImage imageNamed:@"line"];
        imgLine3.alpha = 0.2;
        [backgroundLabel addSubview:imgLine3];

        //Last Name
        baseYCordinate += 5;
        UILabel *lblLNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblLNameTitle.backgroundColor = [UIColor clearColor];
        lblLNameTitle.textColor = [UIColor whiteColor];
        [lblLNameTitle setFont:[UIFont securifiBoldFont:13]];
        lblLNameTitle.text = NSLocalizedString(@"accounts.userprofile.label.lastName", @"LAST NAME");
        lblLNameTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblLNameTitle];

        UIButton *btnChangeLName = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeLName.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeLName.backgroundColor = [UIColor clearColor];
        [btnChangeLName.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeLName setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeLName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeLName addTarget:self action:@selector(onLastNameClicked:) forControlEvents:UIControlEventTouchUpInside];

        if ([userProfile.lastName isEqualToString:@""]) {
            [btnChangeLName setTitle:NSLocalizedString(@"accounts.userprofile.button.add", @"Add") forState:UIControlStateNormal];
        }
        else {
            [btnChangeLName setTitle:NSLocalizedString(@"accounts.userprofile.button.edit", @"Edit") forState:UIControlStateNormal];
        }

        [backgroundLabel addSubview:btnChangeLName];

        baseYCordinate += 20;
        tfLastName = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfLastName.placeholder = NSLocalizedString(@"accounts.userprofile.textfield.placeholder.lastName", @"We do not know your last name yet");
        [tfLastName setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if (![userProfile.lastName isEqualToString:@""]) {
            tfLastName.text = userProfile.lastName;
        }
        tfLastName.textAlignment = NSTextAlignmentLeft;
        tfLastName.textColor = [UIColor whiteColor];
        tfLastName.font = [UIFont standardUITextFieldFont];
        tfLastName.tag = LAST_NAME;
        [tfLastName setReturnKeyType:UIReturnKeyDone];
        tfLastName.delegate = self;
        [tfLastName addTarget:self action:@selector(lastNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfLastName addTarget:self action:@selector(lastNameTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        tfLastName.enabled = FALSE;
        [backgroundLabel addSubview:tfLastName];

        baseYCordinate += 30;
        UIImageView *imgLine4 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine4.image = [UIImage imageNamed:@"line"];
        imgLine4.alpha = 0.2;
        [backgroundLabel addSubview:imgLine4];

        //Address
        baseYCordinate += 5;
        UILabel *lblAddressTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblAddressTitle.backgroundColor = [UIColor clearColor];
        lblAddressTitle.textColor = [UIColor whiteColor];
        [lblAddressTitle setFont:[UIFont securifiBoldFont:13]];
        lblAddressTitle.text = NSLocalizedString(@"accounts.userprofile.label.address", @"ADDRESS");
        lblAddressTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblAddressTitle];

        UIButton *btnChangeAddress = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeAddress.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeAddress.backgroundColor = [UIColor clearColor];
        [btnChangeAddress.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeAddress setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeAddress.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeAddress addTarget:self action:@selector(onAddressChangeClicked:) forControlEvents:UIControlEventTouchUpInside];

        if ([userProfile.addressLine1 isEqualToString:@""] && [userProfile.addressLine2 isEqualToString:@""] && [userProfile.addressLine3 isEqualToString:@""]) {
            [btnChangeAddress setTitle:NSLocalizedString(@"accounts.userprofile.button.add", @"Add") forState:UIControlStateNormal];
        }
        else {
            [btnChangeAddress setTitle:NSLocalizedString(@"accounts.userprofile.button.edit", @"Edit") forState:UIControlStateNormal];
        }

        [backgroundLabel addSubview:btnChangeAddress];

        baseYCordinate += 20;
        tfAddress1 = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfAddress1.placeholder = NSLocalizedString(@"accounts.userprofile.textfield.placeholder.address1", @"Address Line 1");
        [tfAddress1 setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if (![userProfile.addressLine1 isEqualToString:@""]) {
            tfAddress1.text = userProfile.addressLine1;
        }
        tfAddress1.textAlignment = NSTextAlignmentLeft;
        tfAddress1.textColor = [UIColor whiteColor];
        tfAddress1.font = [UIFont standardUITextFieldFont];
        tfAddress1.tag = ADDRESS_1;
        [tfAddress1 setReturnKeyType:UIReturnKeyDone];
        tfAddress1.delegate = self;
        [tfAddress1 addTarget:self action:@selector(address1TextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfAddress1 addTarget:self action:@selector(address1TextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        tfAddress1.enabled = FALSE;
        [backgroundLabel addSubview:tfAddress1];

        baseYCordinate += 20;
        tfAddress2 = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfAddress2.placeholder = NSLocalizedString(@"accounts.userprofile.textfield.placeholder.address2", @"Address Line 2");
        [tfAddress2 setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if (![userProfile.addressLine2 isEqualToString:@""]) {
            tfAddress2.text = userProfile.addressLine2;
        }
        tfAddress2.textAlignment = NSTextAlignmentLeft;
        tfAddress2.textColor = [UIColor whiteColor];
        tfAddress2.font = [UIFont standardUITextFieldFont];
        tfAddress2.tag = ADDRESS_2;
        [tfAddress2 setReturnKeyType:UIReturnKeyDone];
        tfAddress2.delegate = self;
        [tfAddress2 addTarget:self action:@selector(address2TextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfAddress2 addTarget:self action:@selector(address2TextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        tfAddress2.enabled = FALSE;
        [backgroundLabel addSubview:tfAddress2];

        baseYCordinate += 20;
        tfAddress3 = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfAddress3.placeholder = NSLocalizedString(@"accounts.userprofile.textfield.placeholder.address3", @"Address Line 3");
        [tfAddress3 setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if (![userProfile.addressLine3 isEqualToString:@""]) {
            tfAddress3.text = userProfile.addressLine3;
        }
        tfAddress3.textAlignment = NSTextAlignmentLeft;
        tfAddress3.textColor = [UIColor whiteColor];
        tfAddress3.font = [UIFont standardUITextFieldFont];
        tfAddress3.tag = ADDRESS_3;
        [tfAddress3 setReturnKeyType:UIReturnKeyDone];
        tfAddress3.delegate = self;
        [tfAddress3 addTarget:self action:@selector(address3TextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfAddress3 addTarget:self action:@selector(address3TextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        tfAddress3.enabled = FALSE;
        [backgroundLabel addSubview:tfAddress3];

        baseYCordinate += 30;
        UIImageView *imgLine5 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine5.image = [UIImage imageNamed:@"line"];
        imgLine5.alpha = 0.2;
        [backgroundLabel addSubview:imgLine5];

        //Country
        baseYCordinate += 5;
        UILabel *lblCountryTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblCountryTitle.backgroundColor = [UIColor clearColor];
        lblCountryTitle.textColor = [UIColor whiteColor];
        [lblCountryTitle setFont:[UIFont securifiBoldFont:13]];
        lblCountryTitle.text = NSLocalizedString(@"accounts.userprofile.label.country", @"COUNTRY");
        lblCountryTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblCountryTitle];

        UIButton *btnChangeCountry = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeCountry.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeCountry.backgroundColor = [UIColor clearColor];
        [btnChangeCountry.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeCountry setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeCountry.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeCountry addTarget:self action:@selector(onCountryClicked:) forControlEvents:UIControlEventTouchUpInside];

        if ([userProfile.country isEqualToString:@""]) {
            [btnChangeCountry setTitle:NSLocalizedString(@"accounts.userprofile.button.add", @"Add") forState:UIControlStateNormal];
        }
        else {
            [btnChangeCountry setTitle:NSLocalizedString(@"accounts.userprofile.button.edit", @"Edit") forState:UIControlStateNormal];
        }

        [backgroundLabel addSubview:btnChangeCountry];

        baseYCordinate += 20;
        tfCountry = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfCountry.placeholder = NSLocalizedString(@"accounts.userprofile.textfield.placeholder.country", @"In which country do you reside?");
        [tfCountry setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if (![userProfile.country isEqualToString:@""]) {
            tfCountry.text = userProfile.country;
        }
        tfCountry.textAlignment = NSTextAlignmentLeft;
        tfCountry.textColor = [UIColor whiteColor];
        tfCountry.font = [UIFont standardUITextFieldFont];
        tfCountry.tag = COUNTRY;
        [tfCountry setReturnKeyType:UIReturnKeyDone];
        tfCountry.delegate = self;
        [tfCountry addTarget:self action:@selector(countryTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfCountry addTarget:self action:@selector(countryTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        tfCountry.enabled = FALSE;
        [backgroundLabel addSubview:tfCountry];

        baseYCordinate += 30;
        UIImageView *imgLine6 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine6.image = [UIImage imageNamed:@"line"];
        imgLine6.alpha = 0.2;
        [backgroundLabel addSubview:imgLine6];

        //ZipCode
        baseYCordinate += 5;
        UILabel *lblZipCodeTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblZipCodeTitle.backgroundColor = [UIColor clearColor];
        lblZipCodeTitle.textColor = [UIColor whiteColor];
        [lblZipCodeTitle setFont:[UIFont securifiBoldFont:13]];
        lblZipCodeTitle.text = NSLocalizedString(@"accounts.userprofile.label.zipCode", @"ZIP CODE");
        lblZipCodeTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblZipCodeTitle];

        UIButton *btnChangeZipCode = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeZipCode.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeZipCode.backgroundColor = [UIColor clearColor];
        [btnChangeZipCode.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeZipCode setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeZipCode.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeZipCode addTarget:self action:@selector(onZipCodeClicked:) forControlEvents:UIControlEventTouchUpInside];

        if ([userProfile.zipCode isEqualToString:@""]) {
            [btnChangeZipCode setTitle:NSLocalizedString(@"accounts.userprofile.button.add", @"Add") forState:UIControlStateNormal];
        }
        else {
            [btnChangeZipCode setTitle:NSLocalizedString(@"accounts.userprofile.button.edit", @"Edit") forState:UIControlStateNormal];
        }

        [backgroundLabel addSubview:btnChangeZipCode];

        baseYCordinate += 20;
        tfZipCode = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfZipCode.placeholder = NSLocalizedString(@"accounts.userprofile.textfield.placeholder.zipCode", @"What is your ZIP Code?");
        [tfZipCode setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if (![userProfile.zipCode isEqualToString:@""]) {
            tfZipCode.text = userProfile.zipCode;
        }
        tfZipCode.textAlignment = NSTextAlignmentLeft;
        tfZipCode.textColor = [UIColor whiteColor];
        tfZipCode.font = [UIFont standardUITextFieldFont];
        tfZipCode.tag = ZIPCODE;
        [tfZipCode setReturnKeyType:UIReturnKeyDone];
        tfZipCode.delegate = self;
        [tfZipCode addTarget:self action:@selector(zipcodeTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfZipCode addTarget:self action:@selector(zipcodeTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        tfZipCode.enabled = FALSE;
        [backgroundLabel addSubview:tfZipCode];

        baseYCordinate += 30;
        UIImageView *imgLine7 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine7.image = [UIImage imageNamed:@"line"];
        imgLine7.alpha = 0.2;
        [backgroundLabel addSubview:imgLine7];

        //Delete Account
        baseYCordinate += 10;

        UIButton *btnDeleteAccount = [[UIButton alloc] init];
        btnDeleteAccount.frame = CGRectMake(self.tableView.frame.size.width / 2 - 80, baseYCordinate, 140, 30);
        btnDeleteAccount.backgroundColor = [UIColor clearColor];
        [[btnDeleteAccount layer] setBorderWidth:2.0f];
        [[btnDeleteAccount layer] setBorderColor:[UIColor colorWithHue:0 / 360.0 saturation:0 / 100.0 brightness:100 / 100.0 alpha:1.0].CGColor];
        [btnDeleteAccount setTitle:NSLocalizedString(@"accounts.userprofile.button.deleteAccount", @"DELETE ACCOUNT") forState:UIControlStateNormal];
        [btnDeleteAccount setTitleColor:[UIColor colorWithHue:0 / 360.0 saturation:0 / 100.0 brightness:100 / 100.0 alpha:1.0] forState:UIControlStateNormal];
        [btnDeleteAccount.titleLabel setFont:[UIFont securifiBoldFont:13]];
        btnDeleteAccount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btnDeleteAccount addTarget:self action:@selector(onDeleteAccountClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnDeleteAccount];

    }


    [cell addSubview:backgroundLabel];
    return cell;
}


- (UITableViewCell *)createOwnedAlmondCell:(UITableViewCell *)cell listRow:(int)indexPathRow {

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;


    float baseYCordinate = 0;

    UIView *backgroundLabel = [[UIView alloc] init];
    backgroundLabel.userInteractionEnabled = TRUE;
    backgroundLabel.backgroundColor = [UIColor colorWithRed:0.0 / 255.0 green:168.0 / 255.0 blue:225.0 / 255.0 alpha:1.0];

    SFIAlmondPlus *currentAlmond = [self ownedAlmondAtIndexPathRow:indexPathRow];

    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, baseYCordinate + 7, self.tableView.frame.size.width - 90, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.font = [UIFont securifiLightFont:25];
    lblTitle.adjustsFontSizeToFitWidth = YES;
    lblTitle.text = currentAlmond.almondplusName;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [backgroundLabel addSubview:lblTitle];

    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 60, 12, 23, 23)];
    [backgroundLabel addSubview:imgArrow];

    UIButton *btnExpandOwnedRow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExpandOwnedRow.frame = CGRectMake(self.tableView.frame.size.width - 80, baseYCordinate + 5, 50, 50);
    btnExpandOwnedRow.backgroundColor = [UIColor clearColor];
    [btnExpandOwnedRow addTarget:self action:@selector(onOwnedAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnExpandOwnedRow.tag = indexPathRow;
    [backgroundLabel addSubview:btnExpandOwnedRow];


    baseYCordinate = 45;
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
    imgLine.image = [UIImage imageNamed:@"line"];
    imgLine.alpha = 0.5;
    [backgroundLabel addSubview:imgLine];
    baseYCordinate += 5;

    if (!currentAlmond.isExpanded) {

        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, 110);

        imgArrow.image = [UIImage imageNamed:@"down_arrow"];

        baseYCordinate += 5;

        UILabel *lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 20)];
        lblStatus.backgroundColor = [UIColor clearColor];
        lblStatus.textColor = [UIColor whiteColor];
        [lblStatus setFont:[UIFont securifiBoldFont:14]];

        lblStatus.text = NSLocalizedString(@"accounts.ownedAlmond.label.YouOwnThisAlmond", @"You own this Almond");

        lblStatus.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblStatus];
        baseYCordinate += 20;

        UILabel *lblShared = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        lblShared.backgroundColor = [UIColor clearColor];
        lblShared.textColor = [UIColor whiteColor];
        [lblShared setFont:[UIFont standardUITextFieldFont]];

        lblShared.text = [NSString stringWithFormat:NSLocalizedString(@"accounts.ownedAlmond.label.SharedWithOthers", @"Shared with %d other(s)"), (int) [currentAlmond.accessEmailIDs count]];
        lblShared.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblShared];
    }
    else {
        //Expanded View
        float expandedLabelSize = EXPANDED_OWNED_ALMOND_ROW_HEIGHT;
        if ([currentAlmond.accessEmailIDs count] > 0) {
            expandedLabelSize = expandedLabelSize + 30 + ([currentAlmond.accessEmailIDs count] * 25);
        }
        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, expandedLabelSize - 10);
        imgArrow.image = [UIImage imageNamed:@"up_arrow"];

        //Almond Name
        UILabel *lblAlmondTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 120, 30)];
        lblAlmondTitle.backgroundColor = [UIColor clearColor];
        lblAlmondTitle.textColor = [UIColor whiteColor];
        [lblAlmondTitle setFont:[UIFont standardUITextFieldFont]];
        lblAlmondTitle.text = NSLocalizedString(@"accounts.ownedAlmond.label.deviceName", @"DEVICE NAME");
        lblAlmondTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblAlmondTitle];

        UIButton *btnUnlinkAlmond = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUnlinkAlmond.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnUnlinkAlmond.backgroundColor = [UIColor clearColor];
        [btnUnlinkAlmond setTitle:NSLocalizedString(@"accounts.ownedAlmond.button.Unlink", @"Unlink") forState:UIControlStateNormal];
        [btnUnlinkAlmond.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnUnlinkAlmond setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnUnlinkAlmond.tag = indexPathRow;
        btnUnlinkAlmond.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnUnlinkAlmond addTarget:self action:@selector(onUnlinkAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnUnlinkAlmond];

        baseYCordinate += 25;

        CGFloat rename_button_width = 130;
        CGFloat rename_textfield_width = CGRectGetWidth(self.tableView.bounds) - 10 - rename_button_width - 30;
        tfRenameAlmond = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, rename_textfield_width - 10, 30)];
        tfRenameAlmond.placeholder = NSLocalizedString(@"accounts.ownedAlmond.textfield.placeholder.almondName", @"Almond Name");
        [tfRenameAlmond setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        tfRenameAlmond.text = currentAlmond.almondplusName;
        tfRenameAlmond.textAlignment = NSTextAlignmentLeft;
        tfRenameAlmond.textColor = [UIColor whiteColor];
        tfRenameAlmond.font = [UIFont standardUITextFieldFont];
        tfRenameAlmond.tag = indexPathRow;
        [tfRenameAlmond setReturnKeyType:UIReturnKeyDone];
        tfRenameAlmond.delegate = self;
        tfRenameAlmond.enabled = FALSE;
        [tfRenameAlmond addTarget:self action:@selector(almondNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfRenameAlmond addTarget:self action:@selector(almondNameTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [backgroundLabel addSubview:tfRenameAlmond];


        UIButton *btnChangeAlmondName = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeAlmondName.frame = CGRectMake(10 + rename_textfield_width, baseYCordinate, rename_button_width, 30);
        btnChangeAlmondName.backgroundColor = [UIColor clearColor];
        btnChangeAlmondName.titleLabel.font = [UIFont standardUIButtonFont];
        [btnChangeAlmondName setTitle:NSLocalizedString(@"accounts.ownedAlmond.button.RenameAlmond", @"Rename Almond") forState:UIControlStateNormal];
        [btnChangeAlmondName setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeAlmondName.tag = indexPathRow;
        btnChangeAlmondName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeAlmondName addTarget:self action:@selector(onChangeAlmondNameClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnChangeAlmondName];

        baseYCordinate += 30;
        UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine2.image = [UIImage imageNamed:@"line"];
        imgLine2.alpha = 0.2;
        [backgroundLabel addSubview:imgLine2];

        if ([currentAlmond.accessEmailIDs count] > 0) {
            baseYCordinate += 5;
            UILabel *lblEmailTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 120, 30)];
            lblEmailTitle.backgroundColor = [UIColor clearColor];
            lblEmailTitle.textColor = [UIColor whiteColor];
            [lblEmailTitle setFont:[UIFont securifiBoldFont:13]];
            lblEmailTitle.text = NSLocalizedString(@"accounts.ownedAlmond.label.accessEmail", @"ACCESS EMAIL");
            lblEmailTitle.textAlignment = NSTextAlignmentLeft;
            [backgroundLabel addSubview:lblEmailTitle];


            //Show text field for each email id

            for (int index = 0; index < [currentAlmond.accessEmailIDs count]; index++) {
                baseYCordinate += 25;
                NSString *currentEmail = currentAlmond.accessEmailIDs[index];
                UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 220, 30)];
                lblEmail.backgroundColor = [UIColor clearColor];
                lblEmail.textColor = [UIColor whiteColor];
                [lblEmail setFont:[UIFont standardUITextFieldFont]];
                lblEmail.text = currentEmail;
                lblEmail.textAlignment = NSTextAlignmentLeft;
                [backgroundLabel addSubview:lblEmail];

                UIButton *btnEmailRemove = [UIButton buttonWithType:UIButtonTypeCustom];
                btnEmailRemove.frame = CGRectMake(160, baseYCordinate, 130, 30);
                btnEmailRemove.backgroundColor = [UIColor clearColor];
                [btnEmailRemove setTitle:NSLocalizedString(@"accounts.ownedAlmond.button.Remove", @"Remove") forState:UIControlStateNormal];
                [btnEmailRemove.titleLabel setFont:[UIFont standardUIButtonFont]];
                btnEmailRemove.tag = index;
                btnEmailRemove.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                [btnEmailRemove addTarget:self action:@selector(onEmailRemoveClicked:) forControlEvents:UIControlEventTouchUpInside];
                [backgroundLabel addSubview:btnEmailRemove];
            }

            baseYCordinate += 30;
            UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
            imgLine.image = [UIImage imageNamed:@"line"];
            imgLine.alpha = 0.2;
            [backgroundLabel addSubview:imgLine];
        }

        baseYCordinate += 12;

        UIButton *btnInvite = [[UIButton alloc] init];
        btnInvite.frame = CGRectMake(self.tableView.frame.size.width / 2 - 60, baseYCordinate, 110, 30);
        btnInvite.backgroundColor = [UIColor clearColor];
        [[btnInvite layer] setBorderWidth:2.0f];
        [[btnInvite layer] setBorderColor:[UIColor colorWithHue:0 / 360.0 saturation:0 / 100.0 brightness:100 / 100.0 alpha:1.0].CGColor];
        [btnInvite setTitle:NSLocalizedString(@"accounts.ownedAlmond.button.InviteMore", @"INVITE MORE") forState:UIControlStateNormal];
        [btnInvite setTitleColor:[UIColor colorWithHue:0 / 360.0 saturation:0 / 100.0 brightness:100 / 100.0 alpha:1.0] forState:UIControlStateNormal];
        [btnInvite.titleLabel setFont:[UIFont securifiBoldFont:13]];
        btnInvite.tag = indexPathRow;
        btnInvite.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btnInvite addTarget:self action:@selector(onInviteClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnInvite];
    }


    [cell addSubview:backgroundLabel];
    return cell;
}


- (UITableViewCell *)createSharedAlmondCell:(UITableViewCell *)cell listRow:(int)indexPathRow {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    float baseYCoordinate = 0;

    UIView *backgroundLabel = [[UIView alloc] init];
    backgroundLabel.userInteractionEnabled = TRUE;

    backgroundLabel.backgroundColor = [UIColor colorWithRed:0.0 / 255.0 green:203.0 / 255.0 blue:124.0 / 255.0 alpha:1.0];

    // Adjust indexing by accounting for "Owned" Almond preceeding the shared
    indexPathRow = indexPathRow - (int) [ownedAlmondList count];
    SFIAlmondPlus *currentAlmond = [self sharedAlmondAtIndexPathRow:indexPathRow];

    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, baseYCoordinate + 7, self.tableView.frame.size.width - 90, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    [lblTitle setFont:[UIFont securifiLightFont:25]];
    lblTitle.text = currentAlmond.almondplusName;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [backgroundLabel addSubview:lblTitle];

    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 60, 12, 23, 23)];
    [backgroundLabel addSubview:imgArrow];

    UIButton *btnExpandOwnedRow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExpandOwnedRow.frame = CGRectMake(self.tableView.frame.size.width - 80, baseYCoordinate + 5, 50, 50);
    btnExpandOwnedRow.backgroundColor = [UIColor clearColor];
    [btnExpandOwnedRow addTarget:self action:@selector(onSharedAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnExpandOwnedRow.tag = indexPathRow;
    [backgroundLabel addSubview:btnExpandOwnedRow];


    baseYCoordinate = 45;
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCoordinate, self.tableView.frame.size.width - 35, 1)];
    imgLine.image = [UIImage imageNamed:@"line"];
    imgLine.alpha = 0.5;
    [backgroundLabel addSubview:imgLine];
    baseYCoordinate += 5;

    if (!currentAlmond.isExpanded) {

        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, 110);

        imgArrow.image = [UIImage imageNamed:@"down_arrow"];

        baseYCoordinate += 5;

        UILabel *lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCoordinate, self.tableView.frame.size.width - 30, 20)];
        lblStatus.backgroundColor = [UIColor clearColor];
        lblStatus.textColor = [UIColor whiteColor];
        [lblStatus setFont:[UIFont securifiBoldFontLarge]];

        lblStatus.text = NSLocalizedString(@"accounts.sharedAlmond.label.SharedWithYouBy", @"Shared with you by");

        lblStatus.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblStatus];
        baseYCoordinate += 20;

        UILabel *lblShared = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCoordinate, self.tableView.frame.size.width - 30, 30)];
        lblShared.backgroundColor = [UIColor clearColor];
        lblShared.textColor = [UIColor whiteColor];
        [lblShared setFont:[UIFont standardUITextFieldFont]];
        lblShared.text = currentAlmond.ownerEmailID;
        lblShared.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblShared];
    }
    else {
        //Expanded View
        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, EXPANDED_SHARED_ALMOND_ROW_HEIGHT - 10);
        imgArrow.image = [UIImage imageNamed:@"up_arrow"];

        //Almond Name
        UILabel *lblAlmondTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCoordinate, 120, 30)];
        lblAlmondTitle.backgroundColor = [UIColor clearColor];
        lblAlmondTitle.textColor = [UIColor whiteColor];
        [lblAlmondTitle setFont:[UIFont securifiBoldFont:13]];
        lblAlmondTitle.text = NSLocalizedString(@"accounts.sharedAlmond.label.deviceName", @"DEVICE NAME");
        lblAlmondTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblAlmondTitle];

        UIButton *btnUnlinkAlmond = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUnlinkAlmond.frame = CGRectMake(160, baseYCoordinate, 130, 30);
        btnUnlinkAlmond.backgroundColor = [UIColor clearColor];
        [btnUnlinkAlmond setTitle:NSLocalizedString(@"accounts.sharedAlmond.button.Remove", @"Remove") forState:UIControlStateNormal];
        [btnUnlinkAlmond.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnUnlinkAlmond setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnUnlinkAlmond.tag = indexPathRow;
        btnUnlinkAlmond.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnUnlinkAlmond addTarget:self action:@selector(onRemoveSharedAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnUnlinkAlmond];

        baseYCoordinate += 25;

        CGFloat rename_button_width = 130;
        CGFloat rename_textfield_width = CGRectGetWidth(self.tableView.bounds) - 10 - rename_button_width - 30;
        tfRenameAlmond = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCoordinate, rename_textfield_width - 10, 30)];
        tfRenameAlmond.placeholder = NSLocalizedString(@"accounts.sharedAlmond.textfield.placeholder.almondName", @"Almond Name");
        [tfRenameAlmond setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        tfRenameAlmond.text = currentAlmond.almondplusName;
        tfRenameAlmond.textAlignment = NSTextAlignmentLeft;
        tfRenameAlmond.textColor = [UIColor whiteColor];
        tfRenameAlmond.font = [UIFont standardUITextFieldFont];
        tfRenameAlmond.tag = indexPathRow;;
        [tfRenameAlmond setReturnKeyType:UIReturnKeyDone];
        tfRenameAlmond.delegate = self;
        tfRenameAlmond.enabled = FALSE;
        [tfRenameAlmond addTarget:self action:@selector(almondNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfRenameAlmond addTarget:self action:@selector(almondNameTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [backgroundLabel addSubview:tfRenameAlmond];


        UIButton *btnChangeAlmondName = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeAlmondName.frame = CGRectMake(10 + rename_textfield_width, baseYCoordinate, rename_button_width, 30);
        btnChangeAlmondName.backgroundColor = [UIColor clearColor];
        [btnChangeAlmondName setTitle:NSLocalizedString(@"accounts.sharedAlmond.button.RenameAlmond", @"Rename Almond") forState:UIControlStateNormal];
        [btnChangeAlmondName.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeAlmondName setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeAlmondName.tag = indexPathRow;
        btnChangeAlmondName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeAlmondName addTarget:self action:@selector(onChangeSharedAlmondNameClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnChangeAlmondName];

        baseYCoordinate += 30;
        UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCoordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine2.image = [UIImage imageNamed:@"line"];
        imgLine2.alpha = 0.2;
        [backgroundLabel addSubview:imgLine2];
    }


    [cell addSubview:backgroundLabel];
    return cell;
}

#pragma mark - Class methods

- (void)onProfileClicked:(id)sender {
    if (userProfile.isExpanded) {
        userProfile.isExpanded = FALSE;
    }
    else {
        userProfile.isExpanded = TRUE;
    }
    //Reload only User profile row
    NSIndexPath *rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray *rowsToReload = @[rowToReload];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
    // [self.tableView reloadData];


}


- (void)onChangePasswordClicked:(id)sender {
    //Display option to change password
    DLog(@"Change Password Clicked");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AccountsStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordNavigationTop"];
    [self presentViewController:mainView animated:YES completion:nil];
}

- (void)onFirstNameClicked:(id)sender {
    DLog(@"onFirstNameClicked");
    UIButton *btn = (UIButton *) sender;
    if ([btn.titleLabel.text isEqualToString:NSLocalizedString(@"accounts.userprofile.button.done", @"Done")]) {
        //Send first name change request
        DLog(@"first name to send to cloud %@", changedFirstName);
        if (changedFirstName.length != 0) {
            userProfile.firstName = changedFirstName;
            [self sendUpdateUserProfileRequest];
        }
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.edit", @"Edit") forState:UIControlStateNormal];
        [tfFirstName resignFirstResponder];
        tfFirstName.enabled = FALSE;
    }
    else {
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.done", @"Done") forState:UIControlStateNormal];
        tfFirstName.enabled = TRUE;
        [tfFirstName becomeFirstResponder];
    }
}

- (void)onLastNameClicked:(id)sender {
    DLog(@"onLastNameClicked");
    UIButton *btn = (UIButton *) sender;
    if ([btn.titleLabel.text isEqualToString:NSLocalizedString(@"accounts.userprofile.button.done", @"Done")]) {
        //Send last name change request
        [tfLastName resignFirstResponder];
        DLog(@"last name to send to cloud %@", changedLastName);
        if (changedLastName.length != 0) {
            userProfile.lastName = changedLastName;
            [self sendUpdateUserProfileRequest];
        }
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.edit", @"Edit") forState:UIControlStateNormal];
        tfLastName.enabled = FALSE;
    }
    else {
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.done", @"Done") forState:UIControlStateNormal];
        tfLastName.enabled = TRUE;
        [tfLastName becomeFirstResponder];
    }
}

- (void)onAddressChangeClicked:(id)sender {
    DLog(@"onAddressChangeClicked");
    UIButton *btn = (UIButton *) sender;
    if ([btn.titleLabel.text isEqualToString:NSLocalizedString(@"accounts.userprofile.button.done", @"Done")]) {
        [tfAddress1 resignFirstResponder];
        //Send address change request
        DLog(@"address to send to cloud %@ %@ %@", changedAddress1, changedAddress2, changedAddress3);
        BOOL isChanged = FALSE;
        if (changedAddress1.length != 0) {
            userProfile.addressLine1 = changedAddress1;
            isChanged = TRUE;
        }
        if (changedAddress2.length != 0) {
            userProfile.addressLine2 = changedAddress2;
            isChanged = TRUE;
        }
        if (changedAddress3.length != 0) {
            userProfile.addressLine3 = changedAddress3;
            isChanged = TRUE;
        }
        if (isChanged) {
            [self sendUpdateUserProfileRequest];
        }
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.edit", @"Edit") forState:UIControlStateNormal];
        tfAddress1.enabled = FALSE;
        tfAddress2.enabled = FALSE;
        tfAddress3.enabled = FALSE;
    }
    else {
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.done", @"Done") forState:UIControlStateNormal];
        tfAddress1.enabled = TRUE;
        tfAddress2.enabled = TRUE;
        tfAddress3.enabled = TRUE;
        [tfAddress1 becomeFirstResponder];
    }
}

- (void)onCountryClicked:(id)sender {
    DLog(@"onCountryClicked");
    UIButton *btn = (UIButton *) sender;
    if ([btn.titleLabel.text isEqualToString:NSLocalizedString(@"accounts.userprofile.button.done", @"Done")]) {
        [tfCountry resignFirstResponder];
        //Send country change request
        DLog(@"countryto send to cloud %@", changedCountry);
        if (changedCountry.length != 0) {
            userProfile.country = changedCountry;
            [self sendUpdateUserProfileRequest];
        }
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.edit", @"Edit") forState:UIControlStateNormal];
        tfCountry.enabled = FALSE;
    }
    else {
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.done", @"Done") forState:UIControlStateNormal];
        tfCountry.enabled = TRUE;
        [tfCountry becomeFirstResponder];
    }
}

- (void)onZipCodeClicked:(id)sender {
    DLog(@"onZipCodeClicked");
    UIButton *btn = (UIButton *) sender;
    if ([btn.titleLabel.text isEqualToString:NSLocalizedString(@"accounts.userprofile.button.done", @"Done")]) {
        [tfZipCode resignFirstResponder];
        //Send zipcode change request
        DLog(@"zipcode to send to cloud %@", changedZipcode);
        if (changedZipcode.length != 0) {
            userProfile.zipCode = changedZipcode;
            [self sendUpdateUserProfileRequest];
        }
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.edit", @"Edit") forState:UIControlStateNormal];
        tfZipCode.enabled = FALSE;
    }
    else {
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.done", @"Done") forState:UIControlStateNormal];
        tfZipCode.enabled = TRUE;
        [tfZipCode becomeFirstResponder];
    }
}

- (void)onDeleteAccountClicked:(id)sender {
    DLog(@"onDeleteAccountClicked");
    //Confirmation Box
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"accounts.alert.onDeleteAccount.title", @"Delete Account") message:NSLocalizedString(@"accounts.alert.onDeleteAccount.message", @"Deleting the account will unlink your Almond(s) and delete user preferences. To confirm account deletion enter your password below.") delegate:self cancelButtonTitle:NSLocalizedString(@"accounts.alert.onDeleteAccount.Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"accounts.alert.onDeleteAccount.delete", @"Delete"), nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alert.tag = DELETE_ACCOUNT_CONFIRMATION;
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];

}

- (void)onOwnedAlmondClicked:(id)sender {
    DLog(@"onOwnedAlmondClicked");

    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;

    SFIAlmondPlus *currentAlmond = [self ownedAlmondAtIndexPathRow:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);

    if (currentAlmond.isExpanded) {
        currentAlmond.isExpanded = FALSE;
    }
    else {
        currentAlmond.isExpanded = TRUE;
    }

    //Reload only that particular row
    NSIndexPath *rowToReload = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationFade];

//    [self.tableView reloadData];
}

- (void)onChangeAlmondNameClicked:(id)sender {
    DLog(@"onChangeAlmondNameClicked");

    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;

    if ([btn.titleLabel.text isEqualToString:NSLocalizedString(@"accounts.userprofile.button.done", @"Done")]) {
        [tfRenameAlmond resignFirstResponder];
        [btn setTitle:NSLocalizedString(@"accounts.ownedAlmond.button.RenameAlmond", @"Rename Almond") forState:UIControlStateNormal];
        tfRenameAlmond.enabled = FALSE;

        SFIAlmondPlus *currentAlmond = [self ownedAlmondAtIndexPathRow:index];
        DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
        DLog(@"New Almond Name %@", changedAlmondName);

        currentAlmondMAC = currentAlmond.almondplusMAC;
        if (changedAlmondName.length == 0) {
            return;
        }
        else if (changedAlmondName.length > 32) {
            [[[iToast makeText:NSLocalizedString(@"accounts.itoast.almondNameMax32Characters", @"Almond Name cannot be more than 32 characters.")] setGravity:iToastGravityBottom] show:iToastTypeWarning];
            return;
        }
        nameChangedForAlmond = NAME_CHANGED_OWNED_ALMOND;
        [self sendAlmondNameChangeRequest:currentAlmond.almondplusMAC];
    }
    else {
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.done", @"Done") forState:UIControlStateNormal];
        tfRenameAlmond.enabled = TRUE;
        [tfRenameAlmond becomeFirstResponder];
    }
}


- (void)onChangeSharedAlmondNameClicked:(id)sender {
    DLog(@"onChangeSharedAlmondNameClicked");
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;

    if ([btn.titleLabel.text isEqualToString:NSLocalizedString(@"accounts.userprofile.button.done", @"Done")]) {
        [tfRenameAlmond resignFirstResponder];
        [btn setTitle:NSLocalizedString(@"accounts.sharedAlmond.button.RenameAlmond", @"Rename Almond") forState:UIControlStateNormal];
        tfRenameAlmond.enabled = FALSE;

        SFIAlmondPlus *currentAlmond = [self sharedAlmondAtIndexPathRow:index];
        DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
        DLog(@"New Almond Name %@", changedAlmondName);

        currentAlmondMAC = currentAlmond.almondplusMAC;
        if (changedAlmondName.length == 0) {
            return;
        }
        else if (changedAlmondName.length > 32) {
            [[[iToast makeText:NSLocalizedString(@"accounts.itoast.almondNameMax32Characters", @"Almond Name cannot be more than 32 characters.")] setGravity:iToastGravityBottom] show:iToastTypeWarning];
            return;
        }

        nameChangedForAlmond = NAME_CHANGED_SHARED_ALMOND;
        [self sendAlmondNameChangeRequest:currentAlmond.almondplusMAC];
    }
    else {
        [btn setTitle:NSLocalizedString(@"accounts.userprofile.button.done", @"Done") forState:UIControlStateNormal];
        tfRenameAlmond.enabled = TRUE;
        [tfRenameAlmond becomeFirstResponder];
    }
}

- (void)onUnlinkAlmondClicked:(id)sender {
    DLog(@"onUnlinkAlmondClicked");
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;

    SFIAlmondPlus *currentAlmond = [self ownedAlmondAtIndexPathRow:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);

    currentAlmondMAC = currentAlmond.almondplusMAC;

    //Confirmation Box
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"accounts.alert.onUnlinkAlmond.title", @"Unlink Almond") message:NSLocalizedString(@"accounts.alert.onUnlinkAlmond.message", @"To confirm unlinking Almond enter your password below.") delegate:self cancelButtonTitle:NSLocalizedString(@"accounts.alert.onUnlinkAlmond.Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"accounts.alert.onUnlinkAlmond.Unlink", @"Unlink"), nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alert.tag = UNLINK_ALMOND_CONFIRMATION;
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];

}

- (void)onInviteClicked:(id)sender {
    DLog(@"onInviteClicked");
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;

    SFIAlmondPlus *currentAlmond = [self ownedAlmondAtIndexPathRow:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);

    currentAlmondMAC = currentAlmond.almondplusMAC;

    //Invitation Email Input Box
    NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"accounts.alert.onInviteToShareAlmond.message", @"By inviting someone they can access %@"), currentAlmond.almondplusName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"accounts.alert.onInviteToShareAlmond.title", @"Invite By Email") message:alertMessage delegate:self cancelButtonTitle:NSLocalizedString(@"accounts.alert.onInviteToShareAlmond.Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"accounts.alert.onInviteToShareAlmond.Invite", @"Invite"), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = USER_INVITE_ALERT;
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];
}

- (void)onEmailRemoveClicked:(id)sender {
    DLog(@"onEmailRemoveClicked");
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;

    CGPoint buttonOrigin = btn.frame.origin;
    CGPoint pointInTableView = [self.tableView convertPoint:buttonOrigin fromView:btn.superview];

    SFIAlmondPlus *currentAlmond;

    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointInTableView];
    if (indexPath) {
        currentAlmond = [self ownedAlmondAtIndexPathRow:indexPath.row];
    }

    currentAlmondMAC = currentAlmond.almondplusMAC;
    changedEmailID = currentAlmond.accessEmailIDs[index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
    DLog(@"Selected Email %@", currentAlmond.accessEmailIDs[index]);
    [self sendDelSecondaryUserRequest:currentAlmond.accessEmailIDs[index] almondMAC:currentAlmond.almondplusMAC];
}

- (void)onSharedAlmondClicked:(id)sender {
    DLog(@"onSharedAlmondClicked");
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;

    SFIAlmondPlus *currentAlmond = [self sharedAlmondAtIndexPathRow:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);

    currentAlmond.isExpanded = !currentAlmond.isExpanded;

    // Reload only that particular row
    int indexPathRow = (int) (index + [ownedAlmondList count]);
    NSIndexPath *rowToReload = [NSIndexPath indexPathForRow:indexPathRow inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onRemoveSharedAlmondClicked:(id)sender {
    DLog(@"onRemoveSharedAlmondClicked");
    UIButton *btn = (UIButton *) sender;
    NSUInteger index = (NSUInteger) btn.tag;

    SFIAlmondPlus *currentAlmond = [self sharedAlmondAtIndexPathRow:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
    currentAlmondMAC = currentAlmond.almondplusMAC;

    //Remove Shared Almond
    [self sendDelMeAsSecondaryUserRequest:currentAlmond.almondplusMAC];
}

//- (void)presentLogonScreen {
//    DLog(@"%s", __PRETTY_FUNCTION__);
//
//    
//    // Present login screen
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//    SFILoginViewController *loginCtrl = [storyboard instantiateViewControllerWithIdentifier:@"SFILoginViewController"];
//    loginCtrl.delegate = self;
//    
//    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginCtrl];
//    
//    if (self.presentedViewController) {
//        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
//            [self presentViewController:navCtrl animated:YES completion:nil];
//        }];
//    }
//    else {
//        [self presentViewController:navCtrl animated:YES completion:nil];
//    }
//}

#pragma  mark - Alertview delgate

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    NSLog(@"alertViewShouldEnableFirstOtherButton");
    UITextField *password = [alertView textFieldAtIndex:0];
    BOOL flag = TRUE;
    if (password.text.length == 0) {
        flag = FALSE;
    }
    return flag;

}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"Button Index =%ld", (long) buttonIndex);
    if (alertView.tag == DELETE_ACCOUNT_CONFIRMATION) {
        if (buttonIndex == 1) {  //Delete Account
            UITextField *password = [alertView textFieldAtIndex:0];
            DLog(@"password: %@", password.text);
            //Send request to delete
            [self sendDeleteAccountRequest:password.text];
        }
    }
    else if (alertView.tag == UNLINK_ALMOND_CONFIRMATION) {
        if (buttonIndex == 1) {  //Unlink Almond
            UITextField *password = [alertView textFieldAtIndex:0];
            DLog(@"password: %@", password.text);
            //Send request to delete
            [self sendUnlinkAlmondRequest:password.text almondMAC:currentAlmondMAC];
        }
    }
    else if (alertView.tag == USER_INVITE_ALERT) {
        if (buttonIndex == 1) {  //Invite user to share Almond
            UITextField *emailID = [alertView textFieldAtIndex:0];
            NSLog(@"emailID: %@", emailID.text);
            changedEmailID = emailID.text;
            //Send request to delete
            [self sendUserInviteRequest:emailID.text almondMAC:currentAlmondMAC];
        }
    }


}


#pragma mark - Cloud Command : Sender and Receivers

- (void)sendUserProfileRequest {
    UserProfileRequest *userProfileRequest = [[UserProfileRequest alloc] init];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_USER_PROFILE_REQUEST;
    cloudCommand.command = userProfileRequest;

    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"accounts.hud.loadingDetails", @"Loading account details...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];

    [self asyncSendCommand:cloudCommand];
}

- (void)userProfileResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    UserProfileResponse *obj = (UserProfileResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    DLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);

    if (obj.isSuccessful) {
        //Store user profile information
        userProfile = [[SFIUserProfile alloc] init];
        userProfile.firstName = obj.firstName;
        userProfile.lastName = obj.lastName;
        userProfile.addressLine1 = obj.addressLine1;
        userProfile.addressLine2 = obj.addressLine2;
        userProfile.addressLine3 = obj.addressLine3;
        userProfile.country = obj.country;
        userProfile.zipCode = obj.zipCode;

        //Get from keychain
        userProfile.userEmail = [[SecurifiToolkit sharedInstance] loginEmail];


        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
            //[self.HUD hide:YES];
        });

    }
    else {
        DLog(@"Reason Code %d", obj.reasonCode);
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.HUD hide:YES];
        });
    }

    [self sendOwnedAlmondDataRequest];
}

- (void)sendDeleteAccountRequest:(NSString *)password {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"accounts.hud.deletingAccount", @"Deleting account...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];

    //TODO: PY121214 - Uncomment later when Push Notification is implemented on cloud
    //Push Notification - START
    /*
    [self removePushNotification];
    */
    //Push Notification - END

    [[SecurifiToolkit sharedInstance] asyncRequestDeleteCloudAccount:password];
}


- (void)delAccountResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    DeleteAccountResponse *obj = (DeleteAccountResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    DLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);

    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
    if (!obj.isSuccessful) {
        DLog(@"Reason Code %d", obj.reasonCode);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = NSLocalizedString(@"accounts.deleteAccount.failure.reasonCode1", @"There was some error on cloud. Please try later.");
                break;

            case 2:
                failureReason = NSLocalizedString(@"accounts.deleteAccount.failure.reasonCode2", @"Sorry! You are not registered with us yet.");
                break;

            case 3:
                failureReason = NSLocalizedString(@"accounts.deleteAccount.failure.reasonCode3", @"You need to activate your account.");
                break;

            case 4:
                failureReason = NSLocalizedString(@"accounts.deleteAccount.failure.reasonCode4", @"You need to fill all the fields.");
                break;

            case 5:
                failureReason = NSLocalizedString(@"accounts.deleteAccount.failure.reasonCode5", @"The current password was incorrect.");
                break;

            case 6:
                failureReason = NSLocalizedString(@"accounts.deleteAccount.failure.reasonCode6", @"There was some error on cloud. Please try later.");
                break;


            default:
                failureReason = NSLocalizedString(@"accounts.deleteAccount.failure.default", @"Sorry! Deletion of account was unsuccessful.");
                break;

        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];

    }
    else {
        [self.delegate userAccountDidDelete:self];
    }
}

- (void)sendUpdateUserProfileRequest {
    UpdateUserProfileRequest *request = [[UpdateUserProfileRequest alloc] init];

    request.firstName = userProfile.firstName;
    request.lastName = userProfile.lastName;
    request.addressLine1 = userProfile.addressLine1;
    request.addressLine2 = userProfile.addressLine2;
    request.addressLine3 = userProfile.addressLine3;
    request.country = userProfile.country;
    request.zipCode = userProfile.zipCode;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_UPDATE_USER_PROFILE_REQUEST;
    cloudCommand.command = request;

    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"accounts.hud.updatingDetails", @"Updating account details...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];

    [self asyncSendCommand:cloudCommand];
}

//TODO: Localization
- (void)updateProfileResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    UpdateUserProfileResponse *obj = (UpdateUserProfileResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    DLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);

    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
    if (!obj.isSuccessful) {

        DLog(@"Reason Code %d", obj.reasonCode);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = NSLocalizedString(@"accounts.updateAccount.failure.reasonCode1", @"There was some error on cloud. Please try later.");
                break;

            case 2:
                failureReason = NSLocalizedString(@"accounts.updateAccount.failure.reasonCode2", @"You need to fill all the fields.");
                break;

            case 3:
                failureReason = NSLocalizedString(@"accounts.updateAccount.failure.reasonCode3", @"Sorry! You are not registered with us yet.");
                break;


            default:
                failureReason = NSLocalizedString(@"accounts.updateAccount.failure.default", @"Sorry! Update was unsuccessful.");
                break;

        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
}

- (void)sendOwnedAlmondDataRequest {
    AlmondAffiliationData *ownedAlmondListRequest = [[AlmondAffiliationData alloc] init];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_ALMOND_AFFILIATION_DATA_REQUEST;
    cloudCommand.command = ownedAlmondListRequest;

//    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
//    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//    _HUD.removeFromSuperViewOnHide = NO;
//    _HUD.labelText = @"Loading account details...";
//    _HUD.dimBackground = YES;
//    [self.navigationController.view addSubview:_HUD];
//    [self showHudWithTimeout];

    [self asyncSendCommand:cloudCommand];
}

- (void)ownedAlmondDataResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    AlmondAffiliationDataResponse *obj = (AlmondAffiliationDataResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);

    if (obj.isSuccessful) {
        //Update almond list
        DLog(@"Owned Almond Count %d", obj.almondCount);
        ownedAlmondList = obj.almondList;
        //For testing purpose
//
//        NSMutableArray *emailArray =  [NSMutableArray arrayWithObjects:@"abc@gmail.com", @"xyz@gmail.com", nil];
//        [[ownedAlmondList objectAtIndex:0]setAccessEmailIDs:emailArray];

        //Display in table
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
            // [self.HUD hide:YES];
        });

    }
    else {
        DLog(@"Reason %@", obj.reason);
    }
    //[self.HUD hide:YES];

    [self sendSharedWithMeAlmondRequest];
}


- (void)sendUnlinkAlmondRequest:(NSString *)password almondMAC:(NSString *)almondMAC {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"accounts.hud.unlinkingAlmond", @"Unlinking Almond...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];

    [[SecurifiToolkit sharedInstance] asyncRequestUnlinkAlmond:almondMAC password:password];
}

- (void)unlinkAlmondResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    UnlinkAlmondResponse *obj = (UnlinkAlmondResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);

    if (obj.isSuccessful) {
        //Remove almond locally
        NSArray *currentOwnedAlmondList = ownedAlmondList;
        NSMutableArray *newOwnedAlmondList = [NSMutableArray array];

        // Update Almond List
        for (SFIAlmondPlus *current in currentOwnedAlmondList) {
            if (![current.almondplusMAC isEqualToString:currentAlmondMAC]) {
                [newOwnedAlmondList addObject:current];
            }
        }

        ownedAlmondList = newOwnedAlmondList;


        //Display in table
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
            // [self.HUD hide:YES];
        });

    }
    else {
        DLog(@"Reason %@", obj.reason);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = NSLocalizedString(@"accounts.unlinkAlmond.failure.reasonCode1", @"There was some error on cloud. Please try later.");
                break;

            case 2:
                failureReason = NSLocalizedString(@"accounts.unlinkAlmond.failure.reasonCode2", @"Sorry! You are not registered with us yet.");
                break;

            case 3:
                failureReason = NSLocalizedString(@"accounts.unlinkAlmond.failure.reasonCode3", @"You need to activate your account.");
                break;

            case 4:
                failureReason = NSLocalizedString(@"accounts.unlinkAlmond.failure.reasonCode4", @"You need to fill all the fields.");
                break;

            case 5:
                failureReason = NSLocalizedString(@"accounts.unlinkAlmond.failure.reasonCode5", @"The current password was incorrect.");
                break;

            case 6:
                failureReason = NSLocalizedString(@"accounts.unlinkAlmond.failure.reasonCode6", @"There was some error on cloud. Please try later.");
                break;


            default:
                failureReason = NSLocalizedString(@"accounts.unlinkAlmond.failure.default", @"Sorry! Unlinking of Almond was unsuccessful.");
                break;

        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

- (void)sendUserInviteRequest:(NSString *)emailID almondMAC:(NSString *)almondMAC {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"accounts.hud.inviteUserToShareAlmond", @"Inviting user to share Almond...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    [[SecurifiToolkit sharedInstance] asyncRequestInviteForSharingAlmond:almondMAC inviteEmail:emailID];
}

- (void)userInviteResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    UserInviteResponse *obj = (UserInviteResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);

    if (obj.isSuccessful) {
        //Add shared user locally
        NSMutableArray *changedAlmondList = ownedAlmondList;
        for (SFIAlmondPlus *currentAlmond in changedAlmondList) {
            NSMutableArray *currentEmailArray;
            if ([currentAlmond.almondplusMAC isEqualToString:currentAlmondMAC]) {
                currentEmailArray = currentAlmond.accessEmailIDs;
                if (currentEmailArray == nil) {
                    currentEmailArray = [[NSMutableArray alloc] init];
                }
                [currentEmailArray addObject:changedEmailID];
            }
            currentAlmond.accessEmailIDs = currentEmailArray;
        }

        ownedAlmondList = changedAlmondList;

        //Display in table
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
            //[self.HUD hide:YES];
        });

    }
    else {
        DLog(@"Reason %@", obj.reason);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode1", @"There was some error on cloud. Please try later.");
                break;

            case 2:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode2", @"This user does not have a Securifi account.");
                break;

            case 3:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode3", @"The user has not verified the Securifi account yet.");
                break;

            case 4:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode4", @"You do not own this almond.");
                break;

            case 5:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode5", @"You need to fill all the fields.");
                break;

            case 6:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode6", @"You have already shared this almond with the user.");
                break;

            case 7:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.reasonCode7", @"You can not add yourself as secondary user.");
                break;


            default:
                failureReason = NSLocalizedString(@"accounts.inviteUserToShareAlmond.failure.default", @"Sorry! Sharing of Almond was unsuccessful.");
                break;

        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

- (void)sendDelSecondaryUserRequest:(NSString *)emailID almondMAC:(NSString *)almondMAC {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"accounts.hud.removeUserFromSharedList", @"Remove user from shared list...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];

    [[SecurifiToolkit sharedInstance] asyncRequestDeleteSecondaryUser:almondMAC email:emailID];
}

- (void)delSecondaryUserResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    DeleteSecondaryUserResponse *obj = (DeleteSecondaryUserResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);

    if (obj.isSuccessful) {
        //Remove access email id locally
        NSMutableArray *changedAlmondList = ownedAlmondList;
        // Update Almond List
        for (SFIAlmondPlus *currentAlmond in changedAlmondList) {
            if ([currentAlmond.almondplusMAC isEqualToString:currentAlmondMAC]) {
                //Remove access email id
                NSArray *currentAccessEmailList = currentAlmond.accessEmailIDs;
                NSMutableArray *newAccessEmailList = [NSMutableArray array];
                for (NSString *currentEmail in currentAccessEmailList) {
                    if (![currentEmail isEqualToString:changedEmailID]) {
                        [newAccessEmailList addObject:currentEmail];
                    }
                }
                currentAlmond.accessEmailIDs = newAccessEmailList;
            }
        }

        ownedAlmondList = changedAlmondList;

        //Display in table
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
            //[self.HUD hide:YES];
        });

    }
    else {
        DLog(@"Reason %@", obj.reason);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = NSLocalizedString(@"accounts.deleteSecondaryUser.failure.reasonCode1", @"There was some error on cloud. Please try later.");
                break;

            case 2:
                failureReason = NSLocalizedString(@"accounts.deleteSecondaryUser.failure.reasonCode2", @"You need to fill all the fields.");
                break;

            case 4:
                failureReason = NSLocalizedString(@"accounts.deleteSecondaryUser.failure.reasonCode4", @"You are not associated with this Almond");
                break;

            case 5:
                failureReason = NSLocalizedString(@"accounts.deleteSecondaryUser.failure.reasonCode5", @"Secondary user not found.");
                break;

            case 6:
                failureReason = NSLocalizedString(@"accounts.deleteSecondaryUser.failure.reasonCode6", @"Secondary user is not associated with the given Almond.");
                break;


            default:
                failureReason = NSLocalizedString(@"accounts.deleteSecondaryUser.failure.default", @"Sorry! Something went wrong. Try later.");
                break;

        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

- (void)sendAlmondNameChangeRequest:(NSString *)almondplusMAC {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"accounts.hud.changeAlmondName", @"Change almond name...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    [[SecurifiToolkit sharedInstance] asyncRequestChangeAlmondName:changedAlmondName almondMAC:almondplusMAC];

    [self.almondNameChangeTimer invalidate];
    self.almondNameChangeTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                                  target:self
                                                                selector:@selector(onChangeAlmondNameTimeout:)
                                                                userInfo:nil
                                                                 repeats:NO];

    self.isAlmondNameChangeSuccessful = FALSE;
}


- (void)onChangeAlmondNameTimeout:(id)sender {
    [self.almondNameChangeTimer invalidate];

    if (!self.isAlmondNameChangeSuccessful) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.HUD hide:YES];
        });
        NSLog(@"onChangeAlmondNameTimeout nnnnnn");
        [[[iToast makeText:NSLocalizedString(@"accounts.itoast.unableToChangeAlmondName", @"Sorry! We were unable to change Almond's name111")] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
}


- (void)almondNameChangeResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    NSLog(@"AlmondNameChangeResponse %@",data);
    DynamicAlmondNameChangeResponse *obj = (DynamicAlmondNameChangeResponse *) [data valueForKey:@"data"];

    //DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    
    // Timeout the commander timer
    [self.almondNameChangeTimer invalidate];
    self.isAlmondNameChangeSuccessful = TRUE;
    
    if (obj.almondplusMAC.length != 0) {
        if (nameChangedForAlmond == NAME_CHANGED_OWNED_ALMOND) {
            //Change Owned Almond Name
            for (SFIAlmondPlus *currentAlmond in ownedAlmondList) {
                if ([currentAlmond.almondplusMAC isEqualToString:currentAlmondMAC]) {
                    currentAlmond.almondplusName = changedAlmondName;
                }
            }

        }
        else if (nameChangedForAlmond == NAME_CHANGED_SHARED_ALMOND) {
            //Change Shared Almond Name
            for (SFIAlmondPlus *currentAlmond in sharedAlmondList) {
                if ([currentAlmond.almondplusMAC isEqualToString:currentAlmondMAC]) {
                    currentAlmond.almondplusName = changedAlmondName;
                }
            }

        }

        //Display in table
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
            //[self.HUD hide:YES];
        });

    }
    else {
        NSLog(@"almondNameChangeResponseCallback nnnnnn");
        
        [[[iToast makeText:NSLocalizedString(@"accounts.itoast.unableToChangeAlmondName", @"Sorry! We were unable to change Almond's name2222")] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

- (void)mobileCommandResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    MobileCommandResponse *obj = (MobileCommandResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);

    // Timeout the commander timer
    [self.almondNameChangeTimer invalidate];
    self.isAlmondNameChangeSuccessful = TRUE;

    if (!obj.isSuccessful) {
        NSString *failureReason = obj.reason;
        NSLog(@"mobileCommandResponseCallback nnnnnn");
        dispatch_async(dispatch_get_main_queue(), ^() {
            [[[iToast makeText:[NSString stringWithFormat:NSLocalizedString(@"accounts.itoast.unableToChangeAlmondName", @"Sorry! We were unable to change Almond's name3333. %@"), failureReason]] setGravity:iToastGravityBottom] show:iToastTypeWarning];

        });
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

- (void)sendSharedWithMeAlmondRequest {
    [[SecurifiToolkit sharedInstance] asyncRequestMeAsSecondaryUser];
}

- (void)sharedAlmondDataResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    MeAsSecondaryUserResponse *obj = (MeAsSecondaryUserResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);

    if (obj.isSuccessful) {
        //Update almond list
        DLog(@"Shared Almond Count %d", obj.almondCount);
        sharedAlmondList = obj.almondList;
        //Display in table
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
        });

    }
    else {
        DLog(@"Reason %@", obj.reason);
    }
    
   GenericCommand *cmd = [[SecurifiToolkit sharedInstance] makeAlmondListCommand];
    [[SecurifiToolkit sharedInstance] asyncSendCommand:cmd];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

- (void)sendDelMeAsSecondaryUserRequest:(NSString *)almondMAC {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = NSLocalizedString(@"accounts.hud.removeSharedAlmond", @"Remove shared almond...");
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    [[SecurifiToolkit sharedInstance] asyncRequestDeleteMeAsSecondaryUser:almondMAC];
}

- (void)delMeAsSecondaryUserResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    DeleteMeAsSecondaryUserResponse *obj = (DeleteMeAsSecondaryUserResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);

    if (obj.isSuccessful) {
        //Remove almond locally
        NSArray *currentSharedAlmondList = sharedAlmondList;
        NSMutableArray *newSharedAlmondList = [NSMutableArray array];

        // Update Almond List
        for (SFIAlmondPlus *current in currentSharedAlmondList) {
            if (![current.almondplusMAC isEqualToString:currentAlmondMAC]) {
                [newSharedAlmondList addObject:current];
            }
        }

        sharedAlmondList = newSharedAlmondList;


        //Display in table
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
        });
    }
    else {
        DLog(@"Reason %@", obj.reason);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = NSLocalizedString(@"accounts.deleteMeAsSecondaryUser.failure.reasonCode1", @"There was some error on cloud. Please try later.");
                break;

            case 2:
                failureReason = NSLocalizedString(@"accounts.deleteMeAsSecondaryUser.failure.reasonCode2", @"You need to fill all the fields.");
                break;

            case 3:
                failureReason = NSLocalizedString(@"accounts.deleteMeAsSecondaryUser.failure.reasonCode3", @"You are not associated with this Almond.");
                break;


            default:
                failureReason = NSLocalizedString(@"accounts.deleteMeAsSecondaryUser.failure.default", @"Sorry! Removing of shared Almond was unsuccessful.");
                break;

        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

#pragma mark - Keyboard methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)firstNameTextFieldFinished:(UITextField *)tfName {
    DLog(@"tfName: %@", tfName.text);
    self.changedFirstName = tfName.text;
    [tfName resignFirstResponder];
}

- (void)firstNameTextFieldDidChange:(UITextField *)tfName {
    DLog(@"tfName: %@", tfName.text);
    self.changedFirstName = tfName.text;
}

- (void)lastNameTextFieldFinished:(UITextField *)tfName {
    DLog(@"tfLName: %@", tfName.text);
    self.changedLastName = tfName.text;
    [tfName resignFirstResponder];
}

- (void)lastNameTextFieldDidChange:(UITextField *)tfName {
    DLog(@"tfLName %@", tfName.text);
    self.changedLastName = tfName.text;
}

- (void)address1TextFieldFinished:(UITextField *)tfName {
    DLog(@"address1: %@", tfName.text);
    self.changedAddress1 = tfName.text;
    [tfName resignFirstResponder];
}

- (void)address1TextFieldDidChange:(UITextField *)tfName {
    DLog(@"address1: %@", tfName.text);
    self.changedAddress1 = tfName.text;
}

- (void)address2TextFieldFinished:(UITextField *)tfName {
    DLog(@"address2: %@", tfName.text);
    self.changedAddress2 = tfName.text;
    [tfName resignFirstResponder];
}

- (void)address2TextFieldDidChange:(UITextField *)tfName {
    DLog(@"address2: %@", tfName.text);
    self.changedAddress2 = tfName.text;
}

- (void)address3TextFieldFinished:(UITextField *)tfName {
    DLog(@"address3: %@", tfName.text);
    self.changedAddress3 = tfName.text;
    [tfName resignFirstResponder];
}

- (void)address3TextFieldDidChange:(UITextField *)tfName {
    DLog(@"address3: %@", tfName.text);
    self.changedAddress3 = tfName.text;
}

- (void)countryTextFieldFinished:(UITextField *)tfName {
    DLog(@"country: %@", tfName.text);
    self.changedCountry = tfName.text;
    [tfName resignFirstResponder];
}

- (void)countryTextFieldDidChange:(UITextField *)tfName {
    DLog(@"country: %@", tfName.text);
    self.changedCountry = tfName.text;
}

- (void)zipcodeTextFieldFinished:(UITextField *)tfName {
    DLog(@"zipcode: %@", tfName.text);
    self.changedZipcode = tfName.text;
    [tfName resignFirstResponder];
}

- (void)zipcodeTextFieldDidChange:(UITextField *)tfName {
    DLog(@"zipcode: %@", tfName.text);
    self.changedZipcode = tfName.text;
}

- (void)almondNameTextFieldDidChange:(UITextField *)tfName {
    DLog(@"almondName: %@", tfName.text);
    self.changedAlmondName = tfName.text;
}

- (void)almondNameTextFieldFinished:(UITextField *)tfName {
    DLog(@"almondName: %@", tfName.text);
    self.changedAlmondName = tfName.text;
    [tfName resignFirstResponder];
}

@end
