//
//  SFIUserProfileCell.m
//  SecurifiApp
//
//  Created by K Murali Krishna on 13/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIUserProfileCell.h"

@interface SFIUserProfileCell()
@property NSMutableArray* changedValue;
@property NSMutableArray *textFieldView;
@property float baseYCordinate;
@property NSMutableArray *userProfileData;
@property NSString* keyvalue;
@property NSDictionary *profileNumberFieldname;
@property NSDictionary  *NSLocalizedStringForUserProfileLabels;
@end

@implementation SFIUserProfileCell
NSArray *fieldNumbersForEachCategory;
#pragma mark - Keyboard methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldFinished:(UITextField*) tfName {
    _changedValue[tfName.tag] = tfName.text;
    [tfName resignFirstResponder];
}

-(void)textFieldDidChange:(UITextField *)tfName {
    _changedValue[tfName.tag] = tfName.text;
}

- (void) onChangePasswordButtonClicked:(id)sender {
    [self.delegate onChangePasswordClicked:sender];
}

- (void)sendUpdateUserProfileRequest {
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject:UPDATE_USERPROFILE_REQUEST forKey:COMMAND_TYPE];
    if([_keyvalue isEqualToString:@"Address"]){
        [data setObject:_changedValue[0] forKey:@"AddressLine1"];
        [data setObject:_changedValue[1] forKey:@"AddressLine2"];
        [data setObject:_changedValue[2] forKey:@"AddressLine3"];
    }else{
        [data setObject:_changedValue[0] forKey:_keyvalue];
    }
    
    NSArray *localizesStrings =@[ACCOUNTS_HUD_UPDATINGDETAILS, UPDATING_ACCOUNT_DETAILS];
    [self.delegate sendRequest:(CommandType*)CommandType_ACCOUNTS_USER_RELATED withCommandString:UPDATE_USERPROFILE_REQUEST withDictionaryData:data withLocalizedStrings:localizesStrings ];
}


- (void) onEditOrDoneButtonClicked :(id)sender {
    UIButton *btn = (UIButton *) sender;
    if([btn.titleLabel.text isEqualToString:NSLocalizedString(ACCOUNTS_USERPROFILE_BUTTON_DONE, DONE)]) {
        
        [self sendUpdateUserProfileRequest];
        [btn setTitle:NSLocalizedString(ACCOUNTS_USERPROFILE_BUTTON_EDIT, EDIT) forState:UIControlStateNormal];
        for(int count=0; count< _userProfileData.count; count++){
            ((UITextField*)_textFieldView[count]).enabled = FALSE;
        }
    }
    else {
        [btn setTitle:NSLocalizedString(ACCOUNTS_USERPROFILE_BUTTON_DONE, DONE) forState:UIControlStateNormal];
        for(int count=0; count< _userProfileData.count; count++){
            ((UITextField*)_textFieldView[count]).enabled = TRUE;
        }
        UITextField * textField = (UITextField*)_textFieldView[0];
        [textField becomeFirstResponder];
    }
}

-(SFIUserProfileCell*)initWithFrame:(CGRect)frame {
    return [super initWithFrame:frame];
}


-(void) initWith :(CGRect)frame withUserProfileData: (SFIUserProfile*) userProfile{
    
    _userProfile = userProfile;
    _userProfileData = ((SFIUserProfile*)userProfile).data;
    _baseYCordinate = 0;
    _changedValue = [NSMutableArray new];
    _keyvalue = ((SFIUserProfile*)userProfile).keyValue;
    _NSLocalizedStringForUserProfileLabels = @{@0:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_PRIMARYEMAIL, PRIMARY_EMAIL),
                                               @1:NSLocalizedString(ACCOUNTS_USERPROFILE_BUTTON_CHANGEPASSWORD, CHANGE_PASSWORD),
                                               @2:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_FIRSTNAME, FIRST_NAME),
                                               @3:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_LASTNAME, LAST_NAME),
                                               @4:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_ADDRESS, ADDRESS),
                                               @5:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_COUNTRY, COUNTRY),
                                               @6:NSLocalizedString(ACCOUNTS_USERPROFILE_LABEL_ZIPCODE, ZIP_CODE)
                                               };
    
    
    _baseYCordinate += 5;
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, _baseYCordinate, 120, 30)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor whiteColor];
    lbl.text = _keyvalue;
    [lbl setFont:[UIFont securifiBoldFont:13]];
    lbl.textAlignment = NSTextAlignmentLeft;
    [self addSubview:lbl];
    
    if(![_keyvalue isEqualToString:@"Email"]){
        UIButton *btnChange = [UIButton buttonWithType:UIButtonTypeCustom];
        btnChange.frame = CGRectMake(frame.size.width - 150, _baseYCordinate, 130, 30);
        btnChange.backgroundColor = [UIColor clearColor];
        [btnChange.titleLabel setFont:[UIFont standardUIButtonFont]];
        [btnChange setTitleColor:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.7] forState:UIControlStateNormal];
        btnChange.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        if([_keyvalue isEqualToString:@"ChangePassword"]){
            [btnChange addTarget:self action:@selector(onChangePasswordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btnChange setTitle:NSLocalizedString(ACCOUNTS_USERPROFILE_BUTTON_CHANGEPASSWORD, CHANGE_PASSWORD) forState:UIControlStateNormal];
        }else{
            [btnChange addTarget:self action:@selector(onEditOrDoneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            if ([_userProfile.data[0] isEqualToString:@""]) {
                [btnChange setTitle:NSLocalizedString(ACCOUNTS_USERPROFILE_BUTTON_ADD, ADD) forState:UIControlStateNormal];
            }
            else {
                [btnChange setTitle:NSLocalizedString(ACCOUNTS_USERPROFILE_BUTTON_EDIT, EDIT) forState:UIControlStateNormal];
            }
        }
        
        [self addSubview:btnChange];
    }
    
    int count = 0;
    _textFieldView = [NSMutableArray new];
    for(id obj in _userProfileData){
        _baseYCordinate += 20;
        _textFieldView[count] = [[UITextField alloc] initWithFrame:CGRectMake(10, _baseYCordinate, 100, 30)];
        ((UITextField*)_textFieldView[count]).placeholder = NSLocalizedString(@"accounts.userprofile.textfield.placeholder.firstName", @"We do not know your first name yet");
        [((UITextField*)_textFieldView[count]) setValue:[UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5] forKeyPath:@"_placeholderLabel.textColor"];
        if(![(NSString*)obj isEqualToString:@""]) {
            ((UITextField*)_textFieldView[count]).text = (NSString*)obj;
        }
        ((UITextField*)_textFieldView[count]).textAlignment = NSTextAlignmentLeft;
        ((UITextField*)_textFieldView[count]).tag = count;
        ((UITextField*)_textFieldView[count]).textColor = [UIColor whiteColor];
        ((UITextField*)_textFieldView[count]).font = [UIFont standardUITextFieldFont];
        [((UITextField*)_textFieldView[count]) setReturnKeyType:UIReturnKeyDone];
        [((UITextField*)_textFieldView[count]) addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [((UITextField*)_textFieldView[count]) addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        ((UITextField*)_textFieldView[count]).enabled = FALSE;
        [self addSubview:((UITextField*)_textFieldView[count])];
        count++;
    }
    
    _baseYCordinate += 30;
    UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, _baseYCordinate, 100, 1)];
    imgLine3.image = [UIImage imageNamed:LINE];
    imgLine3.alpha = 0.2;
    [self addSubview:imgLine3];
    
}

@end
