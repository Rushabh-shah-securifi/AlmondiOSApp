//
//  SFIAccountCellView.h
//  SecurifiApp
//
//  Created by K Murali Krishna on 13/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SFIUserProfile.h"
#import "SFIUserProfileCell.h"
#import "UIFont+Securifi.h"
#import "SFIAccountMacros.h"

@protocol onButtonsClickedFromAccountCell <NSObject>

-(void) onProfileButtonClicked:(id)sender;

-(void) onChangePasswordButtonClicked :(id)sender;

-(void) onDeleteAccountButtonClicked :(id)sender;

-(void) sendRequest:(CommandType*)commandType withCommandString:(NSString*)commandString withDictionaryData:(NSMutableDictionary*)data withLocalizedStrings:(NSArray*)strings;

-(void) showToastonTableViewController:(NSDictionary*) dictionary;

-(void) loadAlmondList;
@end


@interface SFIAccountCellView : UIView <UserProfileCellDelegate>
@property BOOL isExpanded;
@property (nonatomic, strong) id delegate;
-(void) drawAccountCell:(CGRect)frame;
-(void) initWith :(CGRect)frame ;

@end

