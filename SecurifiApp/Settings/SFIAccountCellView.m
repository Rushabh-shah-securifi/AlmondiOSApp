//
//  SFIAccountCellView.m
//  SecurifiApp
//
//  Created by K Murali Krishna on 13/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFIAccountCellView.h"
#import "SFIUserProfileCell.h"
#import "MBProgressHUD.h"
#import "SFIAccountMacros.h"

@interface SFIAccountCellView()

@property (nonatomic) CGRect frameValue;
@property UIImageView *imgArrow;
@property NSMutableArray* userProfileData;
@property NSString* firstName;
@property NSString* lastName;
@property NSString* email;
@property NSString* yFrameDictionary;
@end


@implementation SFIAccountCellView

@synthesize imgArrow;

-(SFIAccountCellView*) initWithFrame:(CGRect) frame {
    return [super initWithFrame:frame];
}

-(void) initWith :(CGRect)frame {
    
    _frameValue = frame;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(userProfileResponseCallback:)
                   name:ACCOUNTS_RELATED
                 object:nil];
    
    [center addObserver:self
               selector:@selector(updateProfileResponseCallback:)
                   name:DYNAMIC_ACCOUNT_RESPONSE
                 object:nil];
    
    NSLocalizedStringForUserProfileLabels = @{
                                              @0:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_FIRSTNAME, FIRST_NAME),
                                              @1:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_LASTNAME, LAST_NAME),
                                              @2:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_ADDRESS, ADDRESS),
                                              @3:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_COUNTRY, COUNTRY),
                                              @4:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_ZIPCODE, ZIP_CODE)
                                              };
    
    //[self drawAccountCell:frame];
}

NSDictionary  *NSLocalizedStringForUserProfileLabels;
NSArray *fieldNumbersForEachCategory;

-(void) sendRequest:(CommandType *)commandType withCommandString:(NSString*)commandString withDictionaryData:(NSMutableDictionary *)data withLocalizedStrings:(NSArray *)strings {
    [self.delegate sendRequest:commandType withCommandString:commandString withDictionaryData:data withLocalizedStrings:strings];
}


#pragma - button click methods
- (void)onProfileClicked:(id)sender {
    if (_isExpanded) {
        _isExpanded = FALSE;
    }
    else {
        _isExpanded = TRUE;
    }
    [self.delegate onProfileButtonClicked:sender];
}


-(void) onChangePasswordClicked:(id)sender {
    [self.delegate onChangePasswordButtonClicked:sender];
}

-(void) onDeleteAccountClicked: (id)sender {
    [self.delegate onDeleteAccountButtonClicked:sender];
}


#pragma - utility methods
-(void) drawAccountCell:(CGRect)frame {
    [[self subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    self.userInteractionEnabled = TRUE;
    float baseYCordinate=0;
    self.backgroundColor = [UIColor colorWithRed:86.0 / 255.0 green:116.0 / 255.0 blue:124.0 / 255.0 alpha:1.0];
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate + 7, frame.size.width - 30, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    [lblTitle setFont:[UIFont securifiLightFont:25]];
    lblTitle.text = NSLocalizedString(ACCOUNTS_USERPROFILE_TITLE_ACCOUNT, ACCOUNTS);
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblTitle];
    
    imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 60, 12, 23, 23)];
    [self addSubview:imgArrow];
    
    UIButton *btnProfile = [UIButton buttonWithType:UIButtonTypeCustom];
    btnProfile.frame = CGRectMake(frame.size.width - 80, baseYCordinate + 5, 50, 50);
    btnProfile.backgroundColor = [UIColor clearColor];
    [btnProfile addTarget:self action:@selector(onProfileClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnProfile];
    
    baseYCordinate = 45;
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, frame.size.width - 35, 1)];
    imgLine.image = [UIImage imageNamed:LINE];
    
    imgLine.alpha = 0.5;
    [self addSubview:imgLine];
    baseYCordinate += 5;
    
    if (!_isExpanded) {
        [self profileisNotExpaded:frame yCoord:baseYCordinate];
    }
    else {
        [self profileIsExpanded:frame yCoord:baseYCordinate];
    }
    
    self.backgroundColor = [UIColor colorWithRed:86.0 / 255.0 green:116.0 / 255.0 blue:124.0 / 255.0 alpha:1.0];
}

-(void) profileisNotExpaded :(CGRect)frame yCoord:(float)baseYCordinate{
    self.frame = CGRectMake(10, 5, frame.size.width - 20, 110);
    imgArrow.image = [UIImage imageNamed:DOWN_ARROW];
    baseYCordinate += 5;
    
    UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, frame.size.width - 30, 20)];
    lblName.backgroundColor = [UIColor clearColor];
    lblName.textColor = [UIColor whiteColor];
    [lblName setFont:[UIFont securifiBoldFontLarge]];
    
    if ([(NSString*)_firstName isEqualToString:@""] && [(NSString*)_lastName isEqualToString:@""]) {
        lblName.text = NSLocalizedString(ACCOUNTS_USERPROFILE_TITLE_PLACEHOLDER_NAME , WE_DONT_KNOW_YOUR_NAME_YET);
    }
    else if (_firstName == NULL) {
        lblName.text = @"";
    }
    else {
        lblName.text = [NSString stringWithFormat:@"%@ %@", (NSString*)_firstName, (NSString*)_lastName];
    }
    
    lblName.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblName];
    baseYCordinate += 25;
    
    UILabel *lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, frame.size.width - 30, 30)];
    lblEmail.backgroundColor = [UIColor clearColor];
    lblEmail.textColor = [UIColor whiteColor];
    [lblEmail setFont:[UIFont standardUITextFieldFont]];
    lblEmail.text = _email;
    lblEmail.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblEmail];
}

-(void) profileIsExpanded: (CGRect)frame yCoord:(float)baseYCordinate {
    
    self.frame = CGRectMake(10, 5, frame.size.width - 20, EXPANDED_PROFILE_ROW_HEIGHT - 10);
    imgArrow.image = [UIImage imageNamed:UP_ARROW];
    int yFrame=0;
    
    int profileNumber = 0;
    
    for(id userProfileData in _userProfileData){
        
        int height = (profileNumber == 4) ?100 :(profileNumber == 1)?30:50;
        if(profileNumber == 5){
            yFrame += 100;
        }else if(profileNumber == 2){
            yFrame += 30;
        }else{
            yFrame += 50;
        }
        
        CGRect userProfileCellframe = CGRectMake(0, yFrame,frame.size.width-20,height);
        
        SFIUserProfileCell* profileCell = [[SFIUserProfileCell alloc] initWithFrame:userProfileCellframe];
        
        [profileCell initWith:userProfileCellframe withUserProfileData:userProfileData ];
        
        profileCell.delegate = self;
        
        [self addSubview: profileCell];
        
        profileNumber++;
        
    }
    
    
    baseYCordinate += 400;
    UIButton *btnDeleteAccount = [[UIButton alloc] init];
    btnDeleteAccount.frame = CGRectMake(frame.size.width / 2 - 80, baseYCordinate, 140, 30);
    btnDeleteAccount.backgroundColor = [UIColor clearColor];
    [[btnDeleteAccount layer] setBorderWidth:2.0f];
    [[btnDeleteAccount layer] setBorderColor:[UIColor colorWithHue:0 / 360.0 saturation:0 / 100.0 brightness:100 / 100.0 alpha:1.0].CGColor];
    [btnDeleteAccount setTitle:NSLocalizedString(ACCOUNTS_USERPROFILE_BUTTON_DELETEACCOUNT, DELETE_ACCOUNT) forState:UIControlStateNormal];
    [btnDeleteAccount setTitleColor:[UIColor colorWithHue:0 / 360.0 saturation:0 / 100.0 brightness:100 / 100.0 alpha:1.0] forState:UIControlStateNormal];
    [btnDeleteAccount.titleLabel setFont:[UIFont securifiBoldFont:13]];
    btnDeleteAccount.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btnDeleteAccount addTarget:self action:@selector(onDeleteAccountClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnDeleteAccount];
}


#pragma - responseCallbacks
- (void) userProfileResponseCallback: (id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[data valueForKey:@"data"] options:kNilOptions error:&error];
    
    NSString *commandType = [dictionary valueForKey:COMMAND_TYPE];
    if(![commandType isEqualToString:@"UserProfileResponse"])
        return;
    
    NSLog(@"%@ and %@ is the address of the account cell class and moreviewcontroller",self,self.delegate);
    NSString* success = [dictionary valueForKey:SUCCESS];
    _userProfileData = [NSMutableArray new];
    if ([success isEqualToString:@"true"]) {
        
        _firstName = [dictionary valueForKey:FirstName];
        _lastName = [dictionary valueForKey:@"LastName"];
        _email = [[SecurifiToolkit sharedInstance] loginEmail];
        
        SFIUserProfile* email = [SFIUserProfile new];
        email.label = @"PRIMARY EMAIL ";
        email.keyValue = @"Email";
        [email.data addObject: [[SecurifiToolkit sharedInstance] loginEmail]];
        [_userProfileData addObject:email];
        
        SFIUserProfile* changePassword = [SFIUserProfile new];
        changePassword.label = CHANGE_PASSWORD;
        changePassword.keyValue = @"ChangePassword";
        [_userProfileData addObject:changePassword];
        
        SFIUserProfile* firstName = [SFIUserProfile new];
        firstName.label = FIRST_NAME;
        firstName.keyValue = FirstName;
        [firstName.data addObject:[dictionary valueForKey:FirstName]];
        [_userProfileData addObject:firstName];
        
        SFIUserProfile* lastName = [SFIUserProfile new];
        lastName.label = LAST_NAME;
        lastName.keyValue = LastName;
        [lastName.data addObject:[dictionary valueForKey:LastName]];
        [_userProfileData addObject:lastName];
        
        SFIUserProfile* address = [SFIUserProfile new];
        address.label = @"ADDRESS";
        address.keyValue = @"Address";
        [address.data addObject:[dictionary valueForKey:@"AddressLine1"]];
        [address.data addObject:[dictionary valueForKey:@"AddressLine2"]];
        [address.data addObject:[dictionary valueForKey:@"AddressLine3"]];
        [_userProfileData addObject:address];
        
        SFIUserProfile* country = [SFIUserProfile new];
        country.label = @"COUNTRY";
        country.keyValue = @"Country";
        [country.data addObject:[dictionary valueForKey:@"Country"]];
        [_userProfileData addObject:country];
        
        SFIUserProfile* zipCode = [SFIUserProfile new];
        zipCode.label = @"ZIPCODE";
        zipCode.keyValue = @"ZipCode";
        [zipCode.data addObject:[dictionary valueForKey:@"ZipCode"]];
        [_userProfileData addObject:zipCode];
        
        [self.delegate loadAlmondList];
    }
}



- (void)updateProfileResponseCallback:(id)sender {
    [self.delegate stopHUD];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    NSError* error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[data valueForKey:@"data"] options:kNilOptions error:&error];
    
    BOOL success = false;
    NSString *keyToUpdate;
    NSMutableArray* dataToUpdate = [NSMutableArray new];
    
    for (NSString* key in dictionary) {
        if([key isEqualToString:COMMAND_TYPE]);
        else if([key isEqualToString:SUCCESS]){
            if([[dictionary valueForKey:key] isEqualToString:@"true"])
                success = true;
        }else{
            keyToUpdate = key;
            if([keyToUpdate isEqualToString:@"AddressLine3"]){
                keyToUpdate = @"Address";
            }
            [dataToUpdate addObject:[dictionary valueForKey:key]];
        }
    }
    
    if(success){
        for(int index = 0; index < [_userProfileData count]; index++){
            NSString* keyValue = ((SFIUserProfile*)_userProfileData[index]).keyValue;
            if([keyValue isEqualToString:keyToUpdate]){
                ((SFIUserProfile*)_userProfileData[index]).data =  dataToUpdate;
                break;
            }
        }
    }else{
        NSLog(@"%@",dictionary);
        [self.delegate showToastonTableViewController:dictionary];
    }
    NSLog(@"update profile response is called");
}

@end
