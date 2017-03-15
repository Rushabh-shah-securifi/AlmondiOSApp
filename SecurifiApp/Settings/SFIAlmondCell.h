//
//  SFIAlmondCell.h
//  SecurifiApp
//
//  Created by K Murali Krishna on 13/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIkit.h>
#import "UIFont+Securifi.h"
#import "SFIAccountMacros.h"
#import "SFISecondaryUser.h"

@protocol onClickButtonsAlmondCell <NSObject>

-(void) reloadTable: (int) index;

-(void) onUnlinkAlmondClicked:(id)sender;
-(void) onInviteClicked:(id)sender;
-(void) onRemoveSharedAlmondClicked:(id)sender;
-(void) onChangeAlmondNameClicked:(NSString*)newAlmondName almondMac:(NSString*)mac;
-(void) onEmailRemoveClicked:(id)sender;
-(void) sendRequest:(CommandType*)commandType withData:(NSArray*)data withLocalizedStrings:(NSArray*)strings ;
-(void) showToastForMoreThan32Chars;
-(void) almondNameChangeTimerDelegate;
-(void) reloadTableFromAlmondCell;
-(void) unableToChangeNameDelegate;

@end

@interface SFIAlmondCell : UIView

@property id delegate;

-(void)initWith:(CGRect)frame withBound:(CGRect)bound isOwnedAlmond:(BOOL)isOwnedAlmond listRow:(int)indexPathRow ownedAlmondList:(NSMutableArray*)ownedList sharedAlmondList:(NSMutableArray*)sharedList;

@end
