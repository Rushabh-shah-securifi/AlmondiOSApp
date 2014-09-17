//
//  SFIAccountsTableViewController.m
//  Almond
//
//  Created by Priya Yerunkar on 15/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFIAccountsTableViewController.h"
#import "MBProgressHUD.h"

@interface SFIAccountsTableViewController ()

@end


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

#define EXPANDED_PROFILE_ROW_HEIGHT 510

@implementation SFIAccountsTableViewController

@synthesize userProfile, ownedAlmondList, sharedAlmondList;
@synthesize changedFirstName, changedLastName, tfFirstName, tfLastName;
@synthesize changedAddress1, changedAddress2, changedAddress3, changedCountry, changedZipcode;
@synthesize tfAddress1, tfAddress2, tfAddress3, tfCountry, tfZipCode;

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
                                     [UIFont fontWithName:@"Avenir-Roman" size:18.0], NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.autoresizingMask= UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizesSubviews= YES;
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.title = @"Settings";
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(userProfileResponseCallback:)
                   name:USER_PROFILE_NOTIFIER
                 object:nil];
    

    [self sendUserProfileRequest];
    //[self showHudWithTimeout];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:USER_PROFILE_NOTIFIER
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
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    switch (indexPath.row) {
        case 0:
            if(userProfile.isExpanded){
                return EXPANDED_PROFILE_ROW_HEIGHT;
            }else{
                return 110;
            }
            break;
            
        default:
            return 90;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    cell = [self createUserProfileCell:cell listRow:indexPath.row];
    return cell;
    
}


-(UITableViewCell*) createUserProfileCell: (UITableViewCell*)cell listRow:(int)indexPathRow{
    //    //PY 070114
    //    //START: HACK FOR MEMORY LEAKS
    //    for(UIView *currentView in cell.contentView.subviews){
    //        [currentView removeFromSuperview];
    //    }
    //    [cell removeFromSuperview];
    //    //END: HACK FOR MEMORY LEAKS
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    float baseYCordinate = 0;
    
    UIView *backgroundLabel = [[UIView alloc]init];
    backgroundLabel.userInteractionEnabled = TRUE;
    
    backgroundLabel.backgroundColor = [UIColor colorWithRed:86.0/255.0 green:116.0/255.0 blue:124.0/255.0 alpha:1.0];
    
    
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate+7, self.tableView.frame.size.width-30, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    [lblTitle setFont:[UIFont fontWithName:@"Avenir-Light" size:25]];
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
        [lblName setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
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
        [lblEmail setFont:[UIFont fontWithName:@"Avenir-Roman" size:13]];
        lblEmail.text = userProfile.userEmail;
        lblEmail.textAlignment = NSTextAlignmentCenter;
        [backgroundLabel addSubview:lblEmail];
    }else{
        //Expanded View
        backgroundLabel.frame = CGRectMake(10, 5, self.tableView.frame.size.width - 20, EXPANDED_PROFILE_ROW_HEIGHT);
        imgArrow.image = [UIImage imageNamed:@"up_arrow.png"];
        
        //PRIMARY EMAIL
        UILabel *lblEmailTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width  -30, 30)];
        lblEmailTitle.backgroundColor = [UIColor clearColor];
        lblEmailTitle.textColor = [UIColor whiteColor];
        [lblEmailTitle setFont:[UIFont fontWithName:@"Avenir-Heavy" size:13]];
        lblEmailTitle.text = @"PRIMARY EMAIL";
        lblEmailTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblEmailTitle];
        
        baseYCordinate+=25;
        
        UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, self.tableView.frame.size.width  -30, 30)];
        lblEmail.backgroundColor = [UIColor clearColor];
        lblEmail.textColor = [UIColor whiteColor];
        [lblEmail setFont:[UIFont fontWithName:@"Avenir-Roman" size:13]];
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
        [lblPasswordTitle setFont:[UIFont fontWithName:@"Avenir-Heavy" size:13]];
        lblPasswordTitle.text = @"PASSWORD";
        lblPasswordTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblPasswordTitle];
        
        UIButton *btnChangePassword = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangePassword.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangePassword.backgroundColor = [UIColor clearColor];
        [btnChangePassword setTitle:@"Change Password" forState:UIControlStateNormal];
        [btnChangePassword.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:13]];
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
        [lblFNameTitle setFont:[UIFont fontWithName:@"Avenir-Heavy" size:13]];
        lblFNameTitle.text = @"FIRST NAME";
        lblFNameTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblFNameTitle];
        
        UIButton *btnChangeFName = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeFName.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeFName.backgroundColor = [UIColor clearColor];
        [btnChangeFName.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:13]];
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
        tfFirstName.font = [UIFont fontWithName:@"Avenir-Roman" size:13];
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
        [lblLNameTitle setFont:[UIFont fontWithName:@"Avenir-Heavy" size:13]];
        lblLNameTitle.text = @"LAST NAME";
        lblLNameTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblLNameTitle];
        
        UIButton *btnChangeLName = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeLName.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeLName.backgroundColor = [UIColor clearColor];
        [btnChangeLName.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:13]];
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
        tfLastName.font = [UIFont fontWithName:@"Avenir-Roman" size:13];
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
        [lblAddressTitle setFont:[UIFont fontWithName:@"Avenir-Heavy" size:13]];
        lblAddressTitle.text = @"ADDRESS";
        lblAddressTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblAddressTitle];
        
        UIButton *btnChangeAddress = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeAddress.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeAddress.backgroundColor = [UIColor clearColor];
        [btnChangeAddress.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:13]];
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
        tfAddress1.font = [UIFont fontWithName:@"Avenir-Roman" size:13];
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
        tfAddress2.font = [UIFont fontWithName:@"Avenir-Roman" size:13];
        tfAddress2.tag = ADDRESS_2;
        [tfAddress2 setReturnKeyType:UIReturnKeyDone];
        tfAddress2.delegate = self;
        [tfAddress2 addTarget:self action:@selector(address1TextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfAddress2 addTarget:self action:@selector(address1TextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
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
        tfAddress3.font = [UIFont fontWithName:@"Avenir-Roman" size:13];
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
        [lblCountryTitle setFont:[UIFont fontWithName:@"Avenir-Heavy" size:13]];
        lblCountryTitle.text = @"COUNTRY";
        lblCountryTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblCountryTitle];
        
        UIButton *btnChangeCountry = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeCountry.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeCountry.backgroundColor = [UIColor clearColor];
        [btnChangeCountry.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:13]];
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
        tfCountry.font = [UIFont fontWithName:@"Avenir-Roman" size:13];
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
        [lblZipCodeTitle setFont:[UIFont fontWithName:@"Avenir-Heavy" size:13]];
        lblZipCodeTitle.text = @"ZIP CODE";
        lblZipCodeTitle.textAlignment = NSTextAlignmentLeft;
        [backgroundLabel addSubview:lblZipCodeTitle];
        
        UIButton *btnChangeZipCode = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChangeZipCode.frame = CGRectMake(160, baseYCordinate, 130, 30);
        btnChangeZipCode.backgroundColor = [UIColor clearColor];
        [btnChangeZipCode.titleLabel setFont:[UIFont fontWithName:@"Avenir-Roman" size:13]];
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
        tfZipCode.font = [UIFont fontWithName:@"Avenir-Roman" size:13];
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
        [btnDeleteAccount.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:13]];
        btnDeleteAccount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [btnDeleteAccount addTarget:self action:@selector(onDeleteAccountClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundLabel addSubview:btnDeleteAccount];
        
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
    [self.tableView reloadData];
    
    
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
        //TODO: Send first name change request
        DLog(@"last name to send to cloud %@", changedFirstName);
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
        //TODO: Send last name change request
        [tfLastName resignFirstResponder];
        DLog(@"last name to send to cloud %@", changedLastName);
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
        //TODO: Send address change request
        DLog(@"address to send to cloud %@ %@ %@", changedAddress1, changedAddress2, changedAddress3);
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
        //TODO: Send country change request
        DLog(@"countryto send to cloud %@", changedCountry);
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
        //TODO: Send zipcode change request
        DLog(@"zipcode to send to cloud %@", changedZipcode);
        [btn setTitle:@"Edit" forState:UIControlStateNormal] ;
    }else{
        [btn setTitle:@"Done" forState:UIControlStateNormal] ;
        tfZipCode.enabled = TRUE;
        [tfZipCode becomeFirstResponder];
    }
}

-(void) onDeleteAccountClicked:(id)sender{
    DLog(@"onDeleteAccountClicked");
    //TODO: Send request to delete
    //Confirmation Box
    UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:@"Delete Account" message:@"Deleting the account will unlink your Almond(s) and delete user preferences. To confirm account deletion enter your password below." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert addButtonWithTitle:@"DELETE ACCOUNT"];
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index =%ld",(long)buttonIndex);
    if (buttonIndex == 1) {  //Delete Account
        UITextField *password = [alertView textFieldAtIndex:0];
        NSLog(@"password: %@", password.text);
    }
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
    [self.HUD show:YES];
    
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
            [self.HUD hide:YES];
        });
        
    }
    else {
        NSLog(@"Reason Code %d", obj.reasonCode);
    }
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

@end
