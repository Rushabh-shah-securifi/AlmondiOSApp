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
@property NSMutableArray *userProfilePlaceHolders;
@property NSString* keyvalue;
@property NSDictionary *profileNumberFieldname;
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
    [self.delegate sendRequest:(CommandType*)CommandType_ACCOUNTS_RELATED withCommandString:UPDATE_USERPROFILE_REQUEST withDictionaryData:data withLocalizedStrings:localizesStrings ];
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
    
    _changedValue = [NSMutableArray new];
    for(int count=0; count<userProfile.data.count; count++){
        _changedValue[count] = [userProfile.data objectAtIndex:count];
    }
    
    _userProfile = userProfile;
    _userProfileData = ((SFIUserProfile*)userProfile).data;
    _userProfilePlaceHolders = ((SFIUserProfile*)userProfile).placeHolders;
    
    _baseYCordinate = 0;
    _keyvalue = ((SFIUserProfile*)userProfile).keyValue;
    _baseYCordinate += 5;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, _baseYCordinate, 120, 30)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor whiteColor];
    lbl.text = _userProfile.label;
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
    
    _textFieldView = [NSMutableArray new];
    
    for(int count = 0;count < [_userProfileData count]; count++){
        _baseYCordinate += 20;
        _textFieldView[count] = [[UITextField alloc] initWithFrame:CGRectMake(10, _baseYCordinate, 200, 30)];
        
        NSString* fieldValue = [_userProfileData objectAtIndex:count];
        
        if([_userProfilePlaceHolders count] != 0){
            NSString* placeHolderValue = [_userProfilePlaceHolders objectAtIndex:count];
            ((UITextField*)_textFieldView[count]).attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolderValue attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:255.0 / 255.0 green:255.0 / 255.0 blue:255.0 / 255.0 alpha:0.5]}];
        }
        
        if(![fieldValue isEqualToString:@""]) {
            ((UITextField*)_textFieldView[count]).text = fieldValue;
        }
        
        ((UITextField*)_textFieldView[count]).textAlignment = NSTextAlignmentLeft;
        ((UITextField*)_textFieldView[count]).tag = count;
        ((UITextField*)_textFieldView[count]).textColor = [UIColor whiteColor];
        ((UITextField*)_textFieldView[count]).font = [UIFont standardUITextFieldFont];
        [((UITextField*)_textFieldView[count]) setReturnKeyType:UIReturnKeyDone];
        [((UITextField*)_textFieldView[count]) addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [((UITextField*)_textFieldView[count]) addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        ((UITextField*)_textFieldView[count]).enabled = true;
        [self addSubview:((UITextField*)_textFieldView[count])];
    }
    
    _baseYCordinate += 30;
    UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, _baseYCordinate, 330, 1)];
    imgLine3.image = [UIImage imageNamed:LINE];
    imgLine3.alpha = 0.2;
    [self addSubview:imgLine3];
}

@end
