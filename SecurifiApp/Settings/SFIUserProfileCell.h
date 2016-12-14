//
//  SFIUserProfileCell.h
//  SecurifiApp
//
//  Created by K Murali Krishna on 13/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIUserProfile.h"
#import "UIFont+Securifi.h"
#import "SFIAccountMacros.h"

@protocol UserProfileCellDelegate <NSObject>

-(void) sendRequest:(CommandType*)commandType withCommandString:(NSString*)commandString withDictionaryData:(NSMutableDictionary*)data withLocalizedStrings:(NSArray*)strings ;

-(void) onChangePasswordClicked:(id)sender;
@end


@interface SFIUserProfileCell : UIView

@property int profileNumber;
@property NSString* fieldValue;
@property SFIUserProfile* userProfile;
@property (nonatomic, strong) id delegate;

-(void) initWith :(CGRect)frame withUserProfileData: (SFIUserProfile*) data;


@end
