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
#import "AlmondPlusConstants.h"

static NSString *simpleTableIdentifier = @"AccountCell";
#define CELL_PROFILE        0
#define CELL_OWNED_ALMOND   1
#define CELL_SHARED_ALMOND  2

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



@implementation SFIAccountsTableViewController

@synthesize userProfile, ownedAlmondList, sharedAlmondList;
@synthesize changedFirstName, changedLastName, tfFirstName, tfLastName;
@synthesize changedAddress1, changedAddress2, changedAddress3, changedCountry, changedZipcode;
@synthesize tfAddress1, tfAddress2, tfAddress3, tfCountry, tfZipCode, changedAlmondName;
@synthesize currentAlmondMAC, changedEmailID, nameChangedForAlmond, tfRenameAlmond;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                     [UIFont standardNavigationTitleFont], NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
                                                                    NSFontAttributeName : [UIFont standardNavigationTitleFont]
                                                                    };
    
    self.tableView.autoresizingMask= UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizesSubviews= YES;
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.title = @"Settings";
    
    ownedAlmondList = [[NSMutableArray alloc]init];
    sharedAlmondList = [[NSMutableArray alloc]init];
    
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
                   name:ALMOND_NAME_CHANGE_NOTIFIER
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

- (void)didReceiveMemoryWarning
{
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
- (IBAction)doneButtonHandler:(id)sender{
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
     [self.delegate userAccountDidDone:self];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == 0){
        if(userProfile.isExpanded){
            return EXPANDED_PROFILE_ROW_HEIGHT;
        }
    }
    else if([ownedAlmondList count] > 0){
        if(indexPath.row > 0 && indexPath.row <= [ownedAlmondList count]){
            SFIAlmondPlus *currentAlmond = [ownedAlmondList objectAtIndex:indexPath.row-1];
            if(currentAlmond.isExpanded){
                if([currentAlmond.accessEmailIDs count]>0){
                    return EXPANDED_OWNED_ALMOND_ROW_HEIGHT + 30 + ([currentAlmond.accessEmailIDs count] * 30);
                }
                return EXPANDED_OWNED_ALMOND_ROW_HEIGHT;
            }
        }
    } else if([sharedAlmondList count] > 0){
         if(indexPath.row > [ownedAlmondList count] && indexPath.row <= ([ownedAlmondList count] +[sharedAlmondList count])){
             SFIAlmondPlus *currentAlmond = [sharedAlmondList objectAtIndex:indexPath.row-1];
             if(currentAlmond.isExpanded){
                 return EXPANDED_SHARED_ALMOND_ROW_HEIGHT;
             }
         }
    }
    else{
        return 120;
    }
   
    return 120;
 }

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1 + [ownedAlmondList count] + [sharedAlmondList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if(indexPath.row == 0){
        cell = [self createUserProfileCell:cell listRow:(int)indexPath.row];
    }
    
    if ([ownedAlmondList count] > 0){
        if(indexPath.row > 0 && indexPath.row <= [ownedAlmondList count]){
            cell = [self createOwnedAlmondCell:cell listRow:(int)indexPath.row];
        }
    }
    
    if([sharedAlmondList count] > 0){
        if(indexPath.row > [ownedAlmondList count] && indexPath.row <= ([ownedAlmondList count] +[sharedAlmondList count])){
            cell = [self createSharedAlmondCell:cell listRow:(int)indexPath.row];
        }
    }
    return cell;
    
}


#pragma mark - Custom cell creation
-(UITableViewCell*) createUserProfileCell: (UITableViewCell*)cell listRow:(int)indexPathRow{
   
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    float baseYCordinate = 0;
    
    UIView *backgroundLabel = [[UIView alloc]init];
    backgroundLabel.userInteractionEnabled = TRUE;
    
    backgroundLabel.backgroundColor = [UIColor colorWithRed:86.0/255.0 green:116.0/255.0 blue:124.0/255.0 alpha:1.0];
    
    
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate+7, self.tableView.frame.size.width-30, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    [lblTitle setFont:[UIFont securifiLightFont:25]];
    lblTitle.text = @"Account";
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [backgroundLabel addSubview:lblTitle];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-60, 12, 23, 23)];
    [backgroundLabel addSubview:imgArrow];
    
    UIButton *btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
    btnProfile.frame =  CGRectMake(self.tableView.frame.size.width-80, baseYCordinate+5, 50, 50);
    btnProfile.backgroundColor = [UIColor clearColor];
    [btnProfile addTarget:self action:@selector(onProfileClicked:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundLabel addSubview:btnProfile];
    
    
    baseYCordinate = 45;
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
    imgLine.image = [UIImage imageNamed:@"line.png"];
    imgLine.alpha = 0.5;
    [backgroundLabel addSubview:imgLine];
    baseYCordinate+=5;
    
    if(!userProfile.isExpanded){
        
        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, 110);
        
        imgArrow.image = [UIImage imageNamed:@"down_arrow.png"];
        
        baseYCordinate+=5;

        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 20)];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.textColor = [UIColor whiteColor];
        [lblName setFont:[UIFont securifiBoldFontLarge]];
        if([userProfile.firstName isEqualToString:@""] && [userProfile.lastName isEqualToString:@""]){
            lblName.text = @"We don't know your name yet";
        }else if(userProfile.firstName == NULL){
            lblName.text = @""; //Default;
        }
        else{
            lblName.text = [NSString stringWithFormat:@"%@ %@", userProfile.firstName, userProfile.lastName];
        }
        lblName.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblName];
        baseYCordinate+=25;
        
        UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width  -30, 30)];
        lblEmail.backgroundColor = [UIColor clearColor];
        lblEmail.textColor = [UIColor whiteColor];
        [lblEmail setFont:[UIFont standardUITextFieldFont]];
        lblEmail.text = userProfile.userEmail;
        lblEmail.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblEmail];
    }else{
        //Expanded View
        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, EXPANDED_PROFILE_ROW_HEIGHT-10);
        imgArrow.image = [UIImage imageNamed:@"up_arrow.png"];
        
        //PRIMARY EMAIL
        UILabel *lblEmailTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width  -30, 30)];
        lblEmailTitle.backgroundColor = [UIColor clearColor];
        lblEmailTitle.textColor = [UIColor whiteColor];
        [lblEmailTitle setFont:[UIFont securifiBoldFont:13]];
        lblEmailTitle.text = @"PRIMARY EMAIL";
        lblEmailTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblEmailTitle];
        
        baseYCordinate+=25;
        
        UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width  -30, 30)];
        lblEmail.backgroundColor = [UIColor clearColor];
        lblEmail.textColor = [UIColor whiteColor];
        [lblEmail setFont:[UIFont standardUITextFieldFont]];
        lblEmail.text = userProfile.userEmail;
        lblEmail.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblEmail];
        
        baseYCordinate+=30;
        
        UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine1.image = [UIImage imageNamed:@"line.png"];
        imgLine1.alpha = 0.2;
        [backgroundLabel addSubview:imgLine1];
        
        baseYCordinate+=5;
        
        //Password
        UILabel *lblPasswordTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblPasswordTitle.backgroundColor = [UIColor clearColor];
        lblPasswordTitle.textColor = [UIColor whiteColor];
        [lblPasswordTitle setFont:[UIFont securifiBoldFont:13]];
        lblPasswordTitle.text = @"PASSWORD";
        lblPasswordTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblPasswordTitle];
        
        UIButton *btnChangePassword = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangePassword.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangePassword.backgroundColor = [UIColor clearColor];
        [btnChangePassword setTitle:@"Change Password" forState:UIControlStateNormal];
        [btnChangePassword.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangePassword setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangePassword.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangePassword addTarget:self action:@selector(onChangePasswordClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnChangePassword];
        
        baseYCordinate+=30;
        UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine2.image = [UIImage imageNamed:@"line.png"];
        imgLine2.alpha = 0.2;
        [backgroundLabel addSubview:imgLine2];
        
        //First Name
        baseYCordinate+=5;
        UILabel *lblFNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblFNameTitle.backgroundColor = [UIColor clearColor];
        lblFNameTitle.textColor = [UIColor whiteColor];
        [lblFNameTitle setFont:[UIFont securifiBoldFont:13]];
        lblFNameTitle.text = @"FIRST NAME";
        lblFNameTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblFNameTitle];
        
        UIButton *btnChangeFName = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeFName.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeFName.backgroundColor = [UIColor clearColor];
        [btnChangeFName.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeFName setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeFName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeFName addTarget:self action:@selector(onFirstNameClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if([userProfile.firstName isEqualToString:@""]){
            [btnChangeFName setTitle:@"Add" forState:UIControlStateNormal];
        }else{
            [btnChangeFName setTitle:@"Edit" forState:UIControlStateNormal];
        }
        
        [backgroundLabel addSubview:btnChangeFName];
        
        baseYCordinate+=20;
        
        tfFirstName = [[UITextField alloc] initWithFrame:CGRectMake(10,  baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfFirstName.placeholder = @"We do not know your first name yet";
        [tfFirstName setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if(![userProfile.firstName isEqualToString:@""]){
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
        
        baseYCordinate+=30;
        
        UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine3.image = [UIImage imageNamed:@"line.png"];
        imgLine3.alpha = 0.2;
        [backgroundLabel addSubview:imgLine3];
        
        //Last Name
        baseYCordinate+=5;
        UILabel *lblLNameTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblLNameTitle.backgroundColor = [UIColor clearColor];
        lblLNameTitle.textColor = [UIColor whiteColor];
        [lblLNameTitle setFont:[UIFont securifiBoldFont:13]];
        lblLNameTitle.text = @"LAST NAME";
        lblLNameTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblLNameTitle];
        
        UIButton *btnChangeLName = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeLName.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeLName.backgroundColor = [UIColor clearColor];
        [btnChangeLName.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeLName setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeLName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeLName addTarget:self action:@selector(onLastNameClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if([userProfile.lastName isEqualToString:@""]){
            [btnChangeLName setTitle:@"Add" forState:UIControlStateNormal];
        }else{
            [btnChangeLName setTitle:@"Edit" forState:UIControlStateNormal];
        }
        
        [backgroundLabel addSubview:btnChangeLName];
        
        baseYCordinate+=20;
        tfLastName = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfLastName.placeholder = @"We do not know your last name yet";
        [tfLastName setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if(![userProfile.lastName isEqualToString:@""]){
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
        
        baseYCordinate+=30;
        UIImageView *imgLine4 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine4.image = [UIImage imageNamed:@"line.png"];
        imgLine4.alpha = 0.2;
        [backgroundLabel addSubview:imgLine4];
        
        //Address
        baseYCordinate+=5;
        UILabel *lblAddressTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblAddressTitle.backgroundColor = [UIColor clearColor];
        lblAddressTitle.textColor = [UIColor whiteColor];
        [lblAddressTitle setFont:[UIFont securifiBoldFont:13]];
        lblAddressTitle.text = @"ADDRESS";
        lblAddressTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblAddressTitle];
        
        UIButton *btnChangeAddress = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeAddress.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeAddress.backgroundColor = [UIColor clearColor];
        [btnChangeAddress.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeAddress setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeAddress.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeAddress addTarget:self action:@selector(onAddressChangeClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if([userProfile.addressLine1 isEqualToString:@""] && [userProfile.addressLine2 isEqualToString:@""] && [userProfile.addressLine3 isEqualToString:@""]){
            [btnChangeAddress setTitle:@"Add" forState:UIControlStateNormal];
        }else{
            [btnChangeAddress setTitle:@"Edit" forState:UIControlStateNormal];
        }
        
        [backgroundLabel addSubview:btnChangeAddress];
        
        baseYCordinate+=20;
        tfAddress1 = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfAddress1.placeholder = @"Address Line 1";
        [tfAddress1 setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if(![userProfile.addressLine1 isEqualToString:@""]){
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
        
        baseYCordinate+=20;
        tfAddress2 = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfAddress2.placeholder = @"Address Line 2";
        [tfAddress2 setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if(![userProfile.addressLine2 isEqualToString:@""]){
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
        
        baseYCordinate+=20;
        tfAddress3 = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfAddress3.placeholder = @"Address Line 3";
        [tfAddress3 setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if(![userProfile.addressLine3 isEqualToString:@""]){
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
        
        baseYCordinate+=30;
        UIImageView *imgLine5 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine5.image = [UIImage imageNamed:@"line.png"];
        imgLine5.alpha = 0.2;
        [backgroundLabel addSubview:imgLine5];
        
        //Country
        baseYCordinate+=5;
        UILabel *lblCountryTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblCountryTitle.backgroundColor = [UIColor clearColor];
        lblCountryTitle.textColor = [UIColor whiteColor];
        [lblCountryTitle setFont:[UIFont securifiBoldFont:13]];
        lblCountryTitle.text = @"COUNTRY";
        lblCountryTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblCountryTitle];
        
        UIButton *btnChangeCountry = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeCountry.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeCountry.backgroundColor = [UIColor clearColor];
        [btnChangeCountry.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeCountry setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeCountry.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeCountry addTarget:self action:@selector(onCountryClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if([userProfile.country isEqualToString:@""]){
            [btnChangeCountry setTitle:@"Add" forState:UIControlStateNormal];
        }else{
            [btnChangeCountry setTitle:@"Edit" forState:UIControlStateNormal];
        }
        
        [backgroundLabel addSubview:btnChangeCountry];
        
        baseYCordinate+=20;
        tfCountry = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfCountry.placeholder = @"In which country do you reside?";
        [tfCountry setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if(![userProfile.country isEqualToString:@""]){
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
        
        baseYCordinate+=30;
        UIImageView *imgLine6 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine6.image = [UIImage imageNamed:@"line.png"];
        imgLine6.alpha = 0.2;
        [backgroundLabel addSubview:imgLine6];
        
        //ZipCode
        baseYCordinate+=5;
        UILabel *lblZipCodeTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 80, 30)];
        lblZipCodeTitle.backgroundColor = [UIColor clearColor];
        lblZipCodeTitle.textColor = [UIColor whiteColor];
        [lblZipCodeTitle setFont:[UIFont securifiBoldFont:13]];
        lblZipCodeTitle.text = @"ZIP CODE";
        lblZipCodeTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblZipCodeTitle];
        
        UIButton *btnChangeZipCode = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeZipCode.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeZipCode.backgroundColor = [UIColor clearColor];
        [btnChangeZipCode.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeZipCode setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeZipCode.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeZipCode addTarget:self action:@selector(onZipCodeClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if([userProfile.zipCode isEqualToString:@""]){
            [btnChangeZipCode setTitle:@"Add" forState:UIControlStateNormal];
        }else{
            [btnChangeZipCode setTitle:@"Edit" forState:UIControlStateNormal];
        }
        
        [backgroundLabel addSubview:btnChangeZipCode];
        
        baseYCordinate+=20;
        tfZipCode = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 30)];
        tfZipCode.placeholder = @"What is your ZIP Code?";
        [tfZipCode setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if(![userProfile.zipCode isEqualToString:@""]){
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
        
        baseYCordinate+=30;
        UIImageView *imgLine7 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine7.image = [UIImage imageNamed:@"line.png"];
        imgLine7.alpha = 0.2;
        [backgroundLabel addSubview:imgLine7];
        
        //Delete Account
        baseYCordinate+=10;
        
        UIButton *btnDeleteAccount = [[UIButton alloc]init];
        btnDeleteAccount.frame = CGRectMake(self.tableView.frame.size.width/2 - 80, baseYCordinate, 140, 30);
        btnDeleteAccount.backgroundColor = [UIColor clearColor];
        [[btnDeleteAccount layer] setBorderWidth:2.0f];
        [[btnDeleteAccount layer] setBorderColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:1.0].CGColor];
        [btnDeleteAccount setTitle:@"DELETE ACCOUNT" forState:UIControlStateNormal];
        [btnDeleteAccount setTitleColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:1.0] forState:UIControlStateNormal ];
        [btnDeleteAccount.titleLabel setFont:[UIFont securifiBoldFont:13]];
        btnDeleteAccount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btnDeleteAccount addTarget:self action:@selector(onDeleteAccountClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnDeleteAccount];
        
    }
    
    
    [cell addSubview:backgroundLabel];
    return cell;
}


-(UITableViewCell*) createOwnedAlmondCell: (UITableViewCell*)cell listRow:(int)indexPathRow{
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    float baseYCordinate = 0;
    
    UIView *backgroundLabel = [[UIView alloc]init];
    backgroundLabel.userInteractionEnabled = TRUE;
    
    backgroundLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:168.0/255.0 blue:225.0/255.0 alpha:1.0];
    
    SFIAlmondPlus *currentAlmond = [ownedAlmondList objectAtIndex:indexPathRow-1];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, baseYCordinate+7, self.tableView.frame.size.width-90, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    [lblTitle setFont:[UIFont securifiLightFont:25]];
    lblTitle.text = currentAlmond.almondplusName;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [backgroundLabel addSubview:lblTitle];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-60, 12, 23, 23)];
    [backgroundLabel addSubview:imgArrow];
    
    UIButton *btnExpandOwnedRow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExpandOwnedRow.frame =  CGRectMake(self.tableView.frame.size.width-80, baseYCordinate+5, 50, 50);
    btnExpandOwnedRow.backgroundColor = [UIColor clearColor];
    [btnExpandOwnedRow addTarget:self action:@selector(onOwnedAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnExpandOwnedRow.tag = indexPathRow-1;
    [backgroundLabel addSubview:btnExpandOwnedRow];
    
    
    baseYCordinate = 45;
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
    imgLine.image = [UIImage imageNamed:@"line.png"];
    imgLine.alpha = 0.5;
    [backgroundLabel addSubview:imgLine];
    baseYCordinate+=5;
    
    if(!currentAlmond.isExpanded){
        
        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, 110);
        
        imgArrow.image = [UIImage imageNamed:@"down_arrow.png"];
        
        baseYCordinate+=5;
        
        UILabel *lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 20)];
        lblStatus.backgroundColor = [UIColor clearColor];
        lblStatus.textColor = [UIColor whiteColor];
        [lblStatus setFont:[UIFont securifiBoldFont:14]];

        lblStatus.text = @"You own this Almond";
        
        lblStatus.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblStatus];
        baseYCordinate+=20;
        
        UILabel *lblShared = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width  -30, 30)];
        lblShared.backgroundColor = [UIColor clearColor];
        lblShared.textColor = [UIColor whiteColor];
        [lblShared setFont:[UIFont standardUITextFieldFont]];

        lblShared.text = [NSString stringWithFormat:@"Shared with %d other(s)", (int)[currentAlmond.accessEmailIDs count]];
        lblShared.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblShared];
    }else{
        //Expanded View
        float expandedLabelSize = EXPANDED_OWNED_ALMOND_ROW_HEIGHT;
        if([currentAlmond.accessEmailIDs count]>0){
             expandedLabelSize = expandedLabelSize + 30 + ([currentAlmond.accessEmailIDs count] * 25);
        }
        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, expandedLabelSize-10);
        imgArrow.image = [UIImage imageNamed:@"up_arrow.png"];
        
        //Almond Name
        UILabel *lblAlmondTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 120, 30)];
        lblAlmondTitle.backgroundColor = [UIColor clearColor];
        lblAlmondTitle.textColor = [UIColor whiteColor];
        [lblAlmondTitle setFont:[UIFont standardUITextFieldFont]];
        lblAlmondTitle.text = @"DEVICE NAME";
        lblAlmondTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblAlmondTitle];
        
        UIButton *btnUnlinkAlmond = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUnlinkAlmond.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnUnlinkAlmond.backgroundColor = [UIColor clearColor];
        [btnUnlinkAlmond setTitle:@"Unlink" forState:UIControlStateNormal];
        [btnUnlinkAlmond.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnUnlinkAlmond setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7] forState:UIControlStateNormal];
        btnUnlinkAlmond.tag = indexPathRow - 1;
        btnUnlinkAlmond.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnUnlinkAlmond addTarget:self action:@selector(onUnlinkAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnUnlinkAlmond];
        
        baseYCordinate+=25;
        
        tfRenameAlmond = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, 180, 30)];
        tfRenameAlmond.placeholder = @"Almond Name";
        [tfRenameAlmond setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        tfRenameAlmond.text = currentAlmond.almondplusName;
        tfRenameAlmond.textAlignment = NSTextAlignmentLeft;
        tfRenameAlmond.textColor = [UIColor whiteColor];
        tfRenameAlmond.font = [UIFont standardUITextFieldFont];
        tfRenameAlmond.tag = indexPathRow - 1;;
        [tfRenameAlmond setReturnKeyType:UIReturnKeyDone];
        tfRenameAlmond.delegate = self;
        tfRenameAlmond.enabled = FALSE;
        [tfRenameAlmond addTarget:self action:@selector(almondNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfRenameAlmond addTarget:self action:@selector(almondNameTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [backgroundLabel addSubview:tfRenameAlmond];
        
        
        UIButton *btnChangeAlmondName = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeAlmondName.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeAlmondName.backgroundColor = [UIColor clearColor];
        [btnChangeAlmondName setTitle:@"Rename Almond" forState:UIControlStateNormal];
        [btnChangeAlmondName.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeAlmondName setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeAlmondName.tag = indexPathRow - 1;
        btnChangeAlmondName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeAlmondName addTarget:self action:@selector(onChangeAlmondNameClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnChangeAlmondName];
        
        baseYCordinate+=30;
        UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine2.image = [UIImage imageNamed:@"line.png"];
        imgLine2.alpha = 0.2;
        [backgroundLabel addSubview:imgLine2];
        
        if([currentAlmond.accessEmailIDs count]>0){
            baseYCordinate+=5;
            UILabel *lblEmailTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 120, 30)];
            lblEmailTitle.backgroundColor = [UIColor clearColor];
            lblEmailTitle.textColor = [UIColor whiteColor];
            [lblEmailTitle setFont:[UIFont securifiBoldFont:13]];
            lblEmailTitle.text = @"ACCESS EMAIL";
            lblEmailTitle.textAlignment = NSTextAlignmentLeft;
            [backgroundLabel addSubview:lblEmailTitle];
            
            
            //Show text field for each email id
            
            for(int index=0; index < [currentAlmond.accessEmailIDs count];index++){
                baseYCordinate+=25;
                NSString *currentEmail = [currentAlmond.accessEmailIDs objectAtIndex:index];
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
                [btnEmailRemove setTitle:@"Remove" forState:UIControlStateNormal];
                [btnEmailRemove.titleLabel setFont:[UIFont standardUIButtonFont]];
                btnEmailRemove.tag = index;
                btnEmailRemove.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                [btnEmailRemove addTarget:self action:@selector(onEmailRemoveClicked:) forControlEvents:UIControlEventTouchUpInside];
                [backgroundLabel addSubview:btnEmailRemove];
            }
            
            baseYCordinate+=30;
            UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
            imgLine.image = [UIImage imageNamed:@"line.png"];
            imgLine.alpha = 0.2;
            [backgroundLabel addSubview:imgLine];
        }
        
        baseYCordinate+=12;
        
        UIButton *btnInvite = [[UIButton alloc]init];
        btnInvite.frame = CGRectMake(self.tableView.frame.size.width/2 - 60, baseYCordinate, 110, 30);
        btnInvite.backgroundColor = [UIColor clearColor];
        [[btnInvite layer] setBorderWidth:2.0f];
        [[btnInvite layer] setBorderColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:1.0].CGColor];
        [btnInvite setTitle:@"INVITE MORE" forState:UIControlStateNormal];
        [btnInvite setTitleColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:1.0] forState:UIControlStateNormal ];
        [btnInvite.titleLabel setFont:[UIFont securifiBoldFont:13]];
        btnInvite.tag = indexPathRow - 1;
        btnInvite.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btnInvite addTarget:self action:@selector(onInviteClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnInvite];
    }
    
    
    [cell addSubview:backgroundLabel];
    return cell;
}


-(UITableViewCell*) createSharedAlmondCell: (UITableViewCell*)cell listRow:(int)indexPathRow{
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    float baseYCordinate = 0;
    
    UIView *backgroundLabel = [[UIView alloc]init];
    backgroundLabel.userInteractionEnabled = TRUE;
    
    backgroundLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:203.0/255.0 blue:124.0/255.0 alpha:1.0];
    
    indexPathRow = indexPathRow - (int)[ownedAlmondList count];
    SFIAlmondPlus *currentAlmond = [sharedAlmondList objectAtIndex:indexPathRow-1];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(30, baseYCordinate+7, self.tableView.frame.size.width-90, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    [lblTitle setFont:[UIFont securifiLightFont:25]];
    lblTitle.text = currentAlmond.almondplusName;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [backgroundLabel addSubview:lblTitle];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-60, 12, 23, 23)];
    [backgroundLabel addSubview:imgArrow];
    
    UIButton *btnExpandOwnedRow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnExpandOwnedRow.frame =  CGRectMake(self.tableView.frame.size.width-80, baseYCordinate+5, 50, 50);
    btnExpandOwnedRow.backgroundColor = [UIColor clearColor];
    [btnExpandOwnedRow addTarget:self action:@selector(onSharedAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnExpandOwnedRow.tag = indexPathRow-1;
    [backgroundLabel addSubview:btnExpandOwnedRow];
    
    
    baseYCordinate = 45;
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
    imgLine.image = [UIImage imageNamed:@"line.png"];
    imgLine.alpha = 0.5;
    [backgroundLabel addSubview:imgLine];
    baseYCordinate+=5;
    
    if(!currentAlmond.isExpanded){
        
        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, 110);
        
        imgArrow.image = [UIImage imageNamed:@"down_arrow.png"];
        
        baseYCordinate+=5;
        
        UILabel *lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width - 30, 20)];
        lblStatus.backgroundColor = [UIColor clearColor];
        lblStatus.textColor = [UIColor whiteColor];
        [lblStatus setFont:[UIFont securifiBoldFontLarge]];
        
        lblStatus.text = @"Shared with you by";
        
        lblStatus.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblStatus];
        baseYCordinate+=20;
        
        UILabel *lblShared = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width  -30, 30)];
        lblShared.backgroundColor = [UIColor clearColor];
        lblShared.textColor = [UIColor whiteColor];
        [lblShared setFont:[UIFont standardUITextFieldFont]];
        lblShared.text = currentAlmond.ownerEmailID;
        lblShared.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblShared];
    }else{
        //Expanded View
        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, EXPANDED_SHARED_ALMOND_ROW_HEIGHT-10);
        imgArrow.image = [UIImage imageNamed:@"up_arrow.png"];
        
        //Almond Name
        UILabel *lblAlmondTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 120, 30)];
        lblAlmondTitle.backgroundColor = [UIColor clearColor];
        lblAlmondTitle.textColor = [UIColor whiteColor];
        [lblAlmondTitle setFont:[UIFont securifiBoldFont:13]];
        lblAlmondTitle.text = @"DEVICE NAME";
        lblAlmondTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblAlmondTitle];
        
        UIButton *btnUnlinkAlmond = [UIButton buttonWithType:UIButtonTypeCustom];
        btnUnlinkAlmond.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnUnlinkAlmond.backgroundColor = [UIColor clearColor];
        [btnUnlinkAlmond setTitle:@"Remove" forState:UIControlStateNormal];
        [btnUnlinkAlmond.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnUnlinkAlmond setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7] forState:UIControlStateNormal];
        btnUnlinkAlmond.tag = indexPathRow - 1;
        btnUnlinkAlmond.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnUnlinkAlmond addTarget:self action:@selector(onRemoveSharedAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnUnlinkAlmond];
        
        baseYCordinate+=25;
        
        tfRenameAlmond = [[UITextField alloc] initWithFrame:CGRectMake(10, baseYCordinate, 180, 30)];
        tfRenameAlmond.placeholder = @"Almond Name";
        [tfRenameAlmond setValue:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        tfRenameAlmond.text = currentAlmond.almondplusName;
        tfRenameAlmond.textAlignment = NSTextAlignmentLeft;
        tfRenameAlmond.textColor = [UIColor whiteColor];
        tfRenameAlmond.font = [UIFont standardUITextFieldFont];
        tfRenameAlmond.tag = indexPathRow - 1;;
        [tfRenameAlmond setReturnKeyType:UIReturnKeyDone];
        tfRenameAlmond.delegate = self;
        tfRenameAlmond.enabled = FALSE;
        [tfRenameAlmond addTarget:self action:@selector(almondNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfRenameAlmond addTarget:self action:@selector(almondNameTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [backgroundLabel addSubview:tfRenameAlmond];
        
        
        UIButton *btnChangeAlmondName = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeAlmondName.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeAlmondName.backgroundColor = [UIColor clearColor];
        [btnChangeAlmondName setTitle:@"Rename Almond" forState:UIControlStateNormal];
        [btnChangeAlmondName.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChangeAlmondName setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChangeAlmondName.tag = indexPathRow - 1;
        btnChangeAlmondName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [btnChangeAlmondName addTarget:self action:@selector(onChangeSharedAlmondNameClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnChangeAlmondName];
        
        baseYCordinate+=30;
        UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
        imgLine2.image = [UIImage imageNamed:@"line.png"];
        imgLine2.alpha = 0.2;
        [backgroundLabel addSubview:imgLine2];
    }
    
    
    [cell addSubview:backgroundLabel];
    return cell;
}

#pragma mark - Class methods
-(void)onProfileClicked:(id)sender {
    if(userProfile.isExpanded){
        userProfile.isExpanded = FALSE;
    }else{
        userProfile.isExpanded = TRUE;
    }
    //Reload only User profile row
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
   // [self.tableView reloadData];
    
    
}


-(void)onChangePasswordClicked:(id)sender {
    //Display option to change password
    DLog(@"Change Password Clicked");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AccountsStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordNavigationTop"];
    [self presentViewController:mainView animated:YES completion:nil];
}

-(void)onFirstNameClicked:(id)sender{
    DLog(@"onFirstNameClicked");
    UIButton *btn = (UIButton*) sender;
    if([btn.titleLabel.text isEqualToString:@"Done"]){
        //Send first name change request
        DLog(@"first name to send to cloud %@", changedFirstName);
        if(changedFirstName.length!=0){
            userProfile.firstName = changedFirstName;
            [self sendUpdateUserProfileRequest];
        }
        [btn setTitle:@"Edit" forState:UIControlStateNormal] ;
        [tfFirstName resignFirstResponder];
    }else{
        [btn setTitle:@"Done" forState:UIControlStateNormal] ;
        tfFirstName.enabled = TRUE;
        [tfFirstName becomeFirstResponder];
    }
}

-(void)onLastNameClicked:(id)sender{
    DLog(@"onLastNameClicked");
    UIButton *btn = (UIButton*) sender;
    if([btn.titleLabel.text isEqualToString:@"Done"]){
        //Send last name change request
        [tfLastName resignFirstResponder];
        DLog(@"last name to send to cloud %@", changedLastName);
        if(changedLastName.length!=0){
            userProfile.lastName = changedLastName;
            [self sendUpdateUserProfileRequest];
        }
        [btn setTitle:@"Edit" forState:UIControlStateNormal] ;
    }else{
        [btn setTitle:@"Done" forState:UIControlStateNormal] ;
        tfLastName.enabled = TRUE;
        [tfLastName becomeFirstResponder];
    }
}

-(void)onAddressChangeClicked:(id)sender{
    DLog(@"onAddressChangeClicked");
    UIButton *btn = (UIButton*) sender;
    if([btn.titleLabel.text isEqualToString:@"Done"]){
        [tfAddress1 resignFirstResponder];
        //Send address change request
        DLog(@"address to send to cloud %@ %@ %@", changedAddress1, changedAddress2, changedAddress3);
        BOOL isChanged = FALSE;
        if(changedAddress1.length!=0){
            userProfile.addressLine1 = changedAddress1;
            isChanged = TRUE;
        }
        if(changedAddress2.length!=0){
            userProfile.addressLine2= changedAddress2;
            isChanged = TRUE;
        }
        if(changedAddress3.length!=0){
            userProfile.addressLine3 = changedAddress3;
            isChanged = TRUE;
        }
        if(isChanged){
            [self sendUpdateUserProfileRequest];
        }
        [btn setTitle:@"Edit" forState:UIControlStateNormal] ;
    }else{
        [btn setTitle:@"Done" forState:UIControlStateNormal] ;
        tfAddress1.enabled = TRUE;
        tfAddress2.enabled = TRUE;
        tfAddress3.enabled = TRUE;
        [tfAddress1 becomeFirstResponder];
    }
}

-(void)onCountryClicked:(id)sender{
    DLog(@"onCountryClicked");
    UIButton *btn = (UIButton*) sender;
    if([btn.titleLabel.text isEqualToString:@"Done"]){
         [tfCountry resignFirstResponder];
        //Send country change request
        DLog(@"countryto send to cloud %@", changedCountry);
        if(changedCountry.length!=0){
            userProfile.country = changedCountry;
            [self sendUpdateUserProfileRequest];
        }
        [btn setTitle:@"Edit" forState:UIControlStateNormal] ;
    }else{
        [btn setTitle:@"Done" forState:UIControlStateNormal] ;
        tfCountry.enabled = TRUE;
        [tfCountry becomeFirstResponder];
    }
}

-(void)onZipCodeClicked:(id)sender{
    DLog(@"onZipCodeClicked");
    UIButton *btn = (UIButton*) sender;
    if([btn.titleLabel.text isEqualToString:@"Done"]){
         [tfZipCode resignFirstResponder];
        //Send zipcode change request
        DLog(@"zipcode to send to cloud %@", changedZipcode);
        if(changedZipcode.length!=0){
            userProfile.zipCode = changedZipcode;
            [self sendUpdateUserProfileRequest];
        }
        [btn setTitle:@"Edit" forState:UIControlStateNormal] ;
    }else{
        [btn setTitle:@"Done" forState:UIControlStateNormal] ;
        tfZipCode.enabled = TRUE;
        [tfZipCode becomeFirstResponder];
    }
}

-(void) onDeleteAccountClicked:(id)sender{
    DLog(@"onDeleteAccountClicked");
    //Confirmation Box
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Delete Account" message:@"Deleting the account will unlink your Almond(s) and delete user preferences. To confirm account deletion enter your password below." delegate:self cancelButtonTitle:@"Cancel"  otherButtonTitles:@"Delete", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alert.tag = DELETE_ACCOUNT_CONFIRMATION;
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];

}

-(void)onOwnedAlmondClicked:(id)sender{
    DLog(@"onOwnedAlmondClicked");
    UIButton *btn = (UIButton*) sender;
    NSUInteger index = (NSUInteger)btn.tag;
    SFIAlmondPlus *currentAlmond = [ownedAlmondList objectAtIndex:index];
     DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
    if(currentAlmond.isExpanded){
        currentAlmond.isExpanded = FALSE;
    }else{
        currentAlmond.isExpanded = TRUE;
    }
    //Reload only that particular row
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:index+1 inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView reloadData];
}

-(void)onChangeAlmondNameClicked:(id)sender {
    DLog(@"onChangeAlmondNameClicked");
    UIButton *btn = (UIButton*) sender;
    NSUInteger index = (NSUInteger)btn.tag;
    if([btn.titleLabel.text isEqualToString:@"Done"]){
        [tfRenameAlmond resignFirstResponder];
        [btn setTitle:@"Rename Almond" forState:UIControlStateNormal] ;

    SFIAlmondPlus *currentAlmond = [ownedAlmondList objectAtIndex:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
    DLog(@"New Almond Name %@", changedAlmondName);
    currentAlmondMAC = currentAlmond.almondplusMAC;
    if(changedAlmondName.length == 0){
        return;
    }else if (changedAlmondName.length > 32){
         [[[iToast makeText:@"Almond Name cannot be more than 32 characters."] setGravity:iToastGravityBottom] show:iToastTypeWarning];
        return;
    }
    nameChangedForAlmond = NAME_CHANGED_OWNED_ALMOND;
    [self sendAlmondNameChangeRequest:currentAlmond.almondplusMAC];
    }else{
        [btn setTitle:@"Done" forState:UIControlStateNormal];
        tfRenameAlmond.enabled = TRUE;
        [tfRenameAlmond becomeFirstResponder];
        
    }
}


-(void)onChangeSharedAlmondNameClicked:(id)sender {
    DLog(@"onChangeSharedAlmondNameClicked");
    UIButton *btn = (UIButton*) sender;
    NSUInteger index = (NSUInteger)btn.tag;
    
    if([btn.titleLabel.text isEqualToString:@"Done"]){
        [tfRenameAlmond resignFirstResponder];
        [btn setTitle:@"Rename Almond" forState:UIControlStateNormal] ;
        SFIAlmondPlus *currentAlmond = [sharedAlmondList objectAtIndex:index];
        DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
        DLog(@"New Almond Name %@", changedAlmondName);
        currentAlmondMAC = currentAlmond.almondplusMAC;
        if(changedAlmondName.length == 0){
            return;
        }else if (changedAlmondName.length > 32){
            [[[iToast makeText:@"Almond Name cannot be more than 32 characters."] setGravity:iToastGravityBottom] show:iToastTypeWarning];
            return;
        }
        
        nameChangedForAlmond = NAME_CHANGED_SHARED_ALMOND;
        [self sendAlmondNameChangeRequest:currentAlmond.almondplusMAC];
    }else{
        [btn setTitle:@"Done" forState:UIControlStateNormal];
        tfRenameAlmond.enabled = TRUE;
        [tfRenameAlmond becomeFirstResponder];
      
    }

}

-(void)onUnlinkAlmondClicked:(id)sender{
    DLog(@"onUnlinkAlmondClicked");
    UIButton *btn = (UIButton*) sender;
    NSUInteger index = (NSUInteger)btn.tag;
    SFIAlmondPlus *currentAlmond = [ownedAlmondList objectAtIndex:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
    
    //Confirmation Box
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Unlink Almond" message:@"To confirm unlinking Almond enter your password below." delegate:self cancelButtonTitle:@"Cancel"  otherButtonTitles:@"Unlink", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alert.tag = UNLINK_ALMOND_CONFIRMATION;
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];
    
    currentAlmondMAC = currentAlmond.almondplusMAC;
    
}

-(void)onInviteClicked:(id)sender{
    DLog(@"onInviteClicked");
    UIButton *btn = (UIButton*) sender;
    NSUInteger index = (NSUInteger)btn.tag;
    SFIAlmondPlus *currentAlmond = [ownedAlmondList objectAtIndex:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
    currentAlmondMAC = currentAlmond.almondplusMAC;
    
    //Invitation Email Input Box
    NSString *alertMessage = [NSString stringWithFormat:@"By inviting someone they can access %@",currentAlmond.almondplusName];
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Invite By Email" message:alertMessage delegate:self cancelButtonTitle:@"Cancel"  otherButtonTitles:@"Invite", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = USER_INVITE_ALERT;
    [[alert textFieldAtIndex:0] setDelegate:self];
    [alert show];

}

-(void)onEmailRemoveClicked:(id)sender{
    DLog(@"onEmailRemoveClicked");
    UIButton *btn = (UIButton*) sender;
    NSUInteger index = (NSUInteger)btn.tag;
    
    CGPoint buttonOrigin = btn.frame.origin;
    CGPoint pointInTableview = [self.tableView convertPoint:buttonOrigin fromView:btn.superview];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pointInTableview];
    SFIAlmondPlus *currentAlmond;
    if (indexPath) {
        currentAlmond = [ownedAlmondList objectAtIndex:indexPath.row - 1];
    }
    currentAlmondMAC = currentAlmond.almondplusMAC;
    changedEmailID = [currentAlmond.accessEmailIDs objectAtIndex:index];
    DLog(@"Selected Almond Name %@",currentAlmond.almondplusName);
    DLog(@"Selected Email %@",  [currentAlmond.accessEmailIDs objectAtIndex:index]);
    [self sendDelSecondaryUserRequest:[currentAlmond.accessEmailIDs objectAtIndex:index] almondMAC:currentAlmond.almondplusMAC];
}

-(void)onSharedAlmondClicked:(id)sender{
    DLog(@"onSharedAlmondClicked");
    UIButton *btn = (UIButton*) sender;
    NSUInteger index = (NSUInteger)btn.tag;
    SFIAlmondPlus *currentAlmond = [sharedAlmondList objectAtIndex:index];
    DLog(@"Selected Almond Name %@", currentAlmond.almondplusName);
    if(currentAlmond.isExpanded){
        currentAlmond.isExpanded = FALSE;
    }else{
        currentAlmond.isExpanded = TRUE;
    }
    //Reload only that particular row
    int indexPathRow = (int) (index + [ownedAlmondList count]);
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:indexPathRow+1 inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
    //[self.tableView reloadData];
}

-(void)onRemoveSharedAlmondClicked:(id)sender{
    DLog(@"onRemoveSharedAlmondClicked");
    UIButton *btn = (UIButton*) sender;
    NSUInteger index = (NSUInteger)btn.tag;
    SFIAlmondPlus *currentAlmond = [sharedAlmondList objectAtIndex:index];
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
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    
    UITextField *password=[alertView textFieldAtIndex:0];
    BOOL flag = TRUE;
    if(password.text.length == 0){
        flag = FALSE;
    }
    return flag;
    
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index =%ld",(long)buttonIndex);
    if(alertView.tag == DELETE_ACCOUNT_CONFIRMATION){
        if (buttonIndex == 1) {  //Delete Account
            UITextField *password = [alertView textFieldAtIndex:0];
            NSLog(@"password: %@", password.text);
            //Send request to delete
            [self sendDeleteAccountRequest:password.text];
        }
    }
    else if(alertView.tag == UNLINK_ALMOND_CONFIRMATION){
        if (buttonIndex == 1) {  //Unlink Almond
            UITextField *password = [alertView textFieldAtIndex:0];
            NSLog(@"password: %@", password.text);
            //Send request to delete
            [self sendUnlinkAlmondRequest:password.text almondMAC:currentAlmondMAC];
        }
    }
    else if(alertView.tag == USER_INVITE_ALERT){
        if (buttonIndex == 1) {  //Invite user to share Almond
            UITextField *emailID = [alertView textFieldAtIndex:0];
            NSLog(@"emailID: %@", emailID.text);
            changedEmailID = emailID.text;
            //Send request to delete
            [self sendUserInviteRequest:emailID.text almondMAC:currentAlmondMAC];
        }
    }
    
    
}

#pragma mark - Push Notification
-(void)removePushNotification{
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:PUSH_NOTIFICATION_TOKEN];
    //TODO: For test - Remove
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PUSH_NOTIFICATION_STATUS];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    //deviceToken = @"7ff2a7b3707fe43cdf39e25522250e1257ee184c59ca0d901b452040d85fd794";
    [[SecurifiToolkit sharedInstance] asyncRequestDeregisterForNotification:deviceToken];
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
    _HUD.labelText = @"Loading account details...";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    [self asyncSendCommand:cloudCommand];
}

- (void)userProfileResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    UserProfileResponse *obj = (UserProfileResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    NSLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);
    
    if (obj.isSuccessful) {
        //Store user profile information
        userProfile = [[SFIUserProfile alloc]init];
        userProfile.firstName = obj.firstName;
        userProfile.lastName = obj.lastName;
        userProfile.addressLine1 = obj.addressLine1;
        userProfile.addressLine2 = obj.addressLine2;
        userProfile.addressLine3 = obj.addressLine3;
        userProfile.country = obj.country;
        userProfile.zipCode = obj.zipCode;
        
        //Get from keychain
        userProfile.userEmail =  [[SecurifiToolkit sharedInstance] loginEmail];
        
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
            //[self.HUD hide:YES];
        });
        
    }
    else {
        NSLog(@"Reason Code %d", obj.reasonCode);
        [self.HUD hide:YES];
    }
    
    [self sendOwnedAlmondDataRequest];
}

- (void)sendDeleteAccountRequest:(NSString*)password {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = @"Deleting account...";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    
    [self removePushNotification];
    [[SecurifiToolkit sharedInstance] asyncRequestDeleteCloudAccount:password];
}

- (void)delAccountResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    DeleteAccountResponse *obj = (DeleteAccountResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    NSLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);
    
    [self.HUD hide:YES];
    if (!obj.isSuccessful) {
        NSLog(@"Reason Code %d", obj.reasonCode);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"There was some error on cloud. Please try later.";
                break;
                
            case 2:
                failureReason = @"Sorry! You are not registered with us yet.";
                break;
                
            case 3:
                failureReason = @"You need to activate your account.";
                break;
                
            case 4:
                failureReason = @"You need to fill all the fields.";
                break;
                
            case 5:
                failureReason = @"The current password was incorrect.";
                break;
                
            case 6:
                failureReason = @"There was some error on cloud. Please try later.";
                break;

                
            default:
                failureReason = @"Sorry! Deletion of account was unsuccessful.";
                break;
                
        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];

    }else{
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
    _HUD.labelText = @"Updating account details...";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    [self asyncSendCommand:cloudCommand];
}


-(void)updateProfileResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    UpdateUserProfileResponse *obj = (UpdateUserProfileResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    NSLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);
    
    [self.HUD hide:YES];
    if (!obj.isSuccessful) {
        
        NSLog(@"Reason Code %d", obj.reasonCode);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"There was some error on cloud. Please try later.";
                break;
                
            case 2:
                failureReason = @"You need to fill all the fields.";
                break;
                
            case 3:
                failureReason = @"Sorry! You are not registered with us yet.";
                break;
                
                
            default:
                failureReason = @"Sorry! Update was unsuccessful.";
                break;
                
        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
}

-(void) sendOwnedAlmondDataRequest{
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

-(void)ownedAlmondDataResponseCallback:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    AlmondAffiliationDataResponse *obj = (AlmondAffiliationDataResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    
    if(obj.isSuccessful){
        //Update almond list
        NSLog(@"Owned Almond Count %d", obj.almondCount);
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
        
    }else{
        NSLog(@"Reason %@", obj.reason);
    }
    //[self.HUD hide:YES];
    
    [self sendSharedWithMeAlmondRequest];
}



- (void)sendUnlinkAlmondRequest:(NSString*)password almondMAC:(NSString*)almondMAC {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = @"Unlinking Almond...";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    
    [[SecurifiToolkit sharedInstance] asyncRequestUnlinkAlmond:almondMAC password:password];
}

-(void)unlinkAlmondResponseCallback:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    UnlinkAlmondResponse *obj = (UnlinkAlmondResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    
    if(obj.isSuccessful){
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
        
    }else{
        NSLog(@"Reason %@", obj.reason);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"There was some error on cloud. Please try later.";
                break;
                
            case 2:
                failureReason = @"Sorry! You are not registered with us yet.";
                break;
                
            case 3:
                failureReason = @"You need to activate your account.";
                break;
                
            case 4:
                failureReason = @"You need to fill all the fields.";
                break;
                
            case 5:
                failureReason = @"The current password was incorrect.";
                break;
                
            case 6:
                failureReason = @"There was some error on cloud. Please try later.";
                break;
                
                
            default:
                failureReason = @"Sorry! Unlinking of Almond was unsuccessful.";
                break;
                
        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    [self.HUD hide:YES];
}

- (void)sendUserInviteRequest:(NSString*)emailID almondMAC:(NSString*)almondMAC {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = @"Inviting user to share Almond...";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    [[SecurifiToolkit sharedInstance] asyncRequestInviteForSharingAlmond:almondMAC inviteEmail:emailID];
}

-(void)userInviteResponseCallback:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    UserInviteResponse *obj = (UserInviteResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    
    if(obj.isSuccessful){
        //Add shared user locally
        NSMutableArray *changedAlmondList = ownedAlmondList;
        for(SFIAlmondPlus *currentAlmond in changedAlmondList){
            NSMutableArray *currentEmailArray;
            if([currentAlmond.almondplusMAC isEqualToString:currentAlmondMAC]){
                currentEmailArray = currentAlmond.accessEmailIDs;
                if(currentEmailArray == nil){
                    currentEmailArray = [[NSMutableArray alloc]init];
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
        
    }else{
        NSLog(@"Reason %@", obj.reason);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"There was some error on cloud. Please try later.";
                break;
                
            case 2:
                failureReason = @"This user does not have a Securifi account.";
                break;
                
            case 3:
                failureReason = @"The user has not verified the Securifi account yet.";
                break;
                
            case 4:
                failureReason = @"You do not own this almond.";
                break;
                
            case 5:
                failureReason = @"You need to fill all the fields.";
                break;
                
            case 6:
                failureReason = @"You have already shared this almond with the user.";
                break;
                
            case 7:
                failureReason = @"You can not add yourself as secondary user.";
                break;
                
                
            default:
                failureReason = @"Sorry! Sharing of Almond was unsuccessful.";
                break;
                
        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    [self.HUD hide:YES];
}

- (void)sendDelSecondaryUserRequest:(NSString*)emailID almondMAC:(NSString*)almondMAC {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = @"Remove user from shared list...";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];

    [[SecurifiToolkit sharedInstance] asyncRequestDeleteSecondaryUser:almondMAC email:emailID];
}

-(void)delSecondaryUserResponseCallback:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    DeleteSecondaryUserResponse *obj = (DeleteSecondaryUserResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    
    if(obj.isSuccessful){
        //Remove access email id locally
         NSMutableArray *changedAlmondList = ownedAlmondList;
        // Update Almond List
        for (SFIAlmondPlus *currentAlmond in changedAlmondList) {
            if([currentAlmond.almondplusMAC isEqualToString:currentAlmondMAC]){
                //Remove access email id
                NSArray *currentAccessEmailList = currentAlmond.accessEmailIDs;
                NSMutableArray *newAccessEmailList = [NSMutableArray array];
                for(NSString *currentEmail in currentAccessEmailList){
                    if(![currentEmail isEqualToString:changedEmailID]){
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
        
    }else{
        NSLog(@"Reason %@", obj.reason);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"There was some error on cloud. Please try later.";
                break;
                
            case 2:
                failureReason = @"You need to fill all the fields. This user does not have a Securifi account.";
                break;
                
            case 4:
                failureReason = @"You are not associated with this Almond";
                break;
                
            case 5:
                failureReason = @"Secondary user not found.";
                break;
                
            case 6:
                failureReason = @"Secondary user is not associated with the given Almond.";
                break;
                
                
            default:
                failureReason = @"Sorry! Something went wrong. Try later.";
                break;
                
        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    [self.HUD hide:YES];
}

-(void)sendAlmondNameChangeRequest:(NSString*)almondplusMAC{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = @"Change almond name...";
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
        [self.HUD hide:YES];
        [[[iToast makeText:@"Sorry! We were unable to change Almond's name"] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
}


-(void)almondNameChangeResponseCallback:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    AlmondNameChangeResponse *obj = (AlmondNameChangeResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    
    // Timeout the commander timer
    [self.almondNameChangeTimer invalidate];
    self.isAlmondNameChangeSuccessful = TRUE;
    
    if(obj.isSuccessful){
        if(nameChangedForAlmond == NAME_CHANGED_OWNED_ALMOND){
        //Change Owned Almond Name
        for(SFIAlmondPlus *currentAlmond in ownedAlmondList){
            if([currentAlmond.almondplusMAC isEqualToString:currentAlmondMAC]){
                currentAlmond.almondplusName = changedAlmondName;
            }
        }
            
        }else if(nameChangedForAlmond == NAME_CHANGED_SHARED_ALMOND){
            //Change Shared Almond Name
            for(SFIAlmondPlus *currentAlmond in sharedAlmondList){
                if([currentAlmond.almondplusMAC isEqualToString:currentAlmondMAC]){
                    currentAlmond.almondplusName = changedAlmondName;
                }
            }
            
        }
        
        //Display in table
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
            //[self.HUD hide:YES];
        });
        
    }else{
        [[[iToast makeText:@"Sorry! We were unable to change Almond's name"] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    [self.HUD hide:YES];
}

-(void)mobileCommandResponseCallback:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    MobileCommandResponse *obj = (MobileCommandResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    
    // Timeout the commander timer
    [self.almondNameChangeTimer invalidate];
    self.isAlmondNameChangeSuccessful = TRUE;
    
    if(!obj.isSuccessful){
        NSString *failureReason = obj.reason;
        [[[iToast makeText:[NSString stringWithFormat:@"Sorry! We were unable to change Almond's name. %@", failureReason]] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    [self.HUD hide:YES];
}

- (void)sendSharedWithMeAlmondRequest {
    [[SecurifiToolkit sharedInstance] asyncRequestMeAsSecondaryUser];
}

-(void)sharedAlmondDataResponseCallback:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    MeAsSecondaryUserResponse *obj = (MeAsSecondaryUserResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    
    if(obj.isSuccessful){
        //Update almond list
        NSLog(@"Shared Almond Count %d", obj.almondCount);
        sharedAlmondList = obj.almondList;
        //Display in table
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.tableView reloadData];
        });
        
    }else{
        NSLog(@"Reason %@", obj.reason);
    }
    [self.HUD hide:YES];
}

- (void)sendDelMeAsSecondaryUserRequest:(NSString*)almondMAC {
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = @"Remove shared almond...";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];
    [self showHudWithTimeout];
    [[SecurifiToolkit sharedInstance] asyncRequestDeleteMeAsSecondaryUser:almondMAC];
}

-(void)delMeAsSecondaryUserResponseCallback:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    DeleteMeAsSecondaryUserResponse *obj = (DeleteMeAsSecondaryUserResponse *) [data valueForKey:@"data"];
    
    NSLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    
    if(obj.isSuccessful){
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
    }else{
        NSLog(@"Reason %@", obj.reason);
        //Display appropriate reason
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"There was some error on cloud. Please try later.";
                break;
                
            case 2:
                failureReason = @"You need to fill all the fields.";
                break;
                
            case 3:
                failureReason = @"You are not associated with this Almond..";
                break;
                
                
            default:
                failureReason = @"Sorry! Removing of shared Almond was unsuccessful.";
                break;
                
        }
        [[[iToast makeText:failureReason] setGravity:iToastGravityBottom] show:iToastTypeWarning];
    }
    [self.HUD hide:YES];
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

-(void)almondNameTextFieldDidChange:(UITextField *)tfName {
    DLog(@"almondName: %@", tfName.text);
    self.changedAlmondName = tfName.text;
}

- (void)almondNameTextFieldFinished:(UITextField *)tfName {
    DLog(@"almondName: %@", tfName.text);
    self.changedAlmondName = tfName.text;
    [tfName resignFirstResponder];
}

@end
