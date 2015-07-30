//
//  SFIScenesTableViewCell.h
//  Scenes
//
//  Created by Tigran Aslanyan on 26.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SFIScenesTableViewCell;

@protocol SFIScenesTableViewCellDelegate
- (void)activateScene:(SFIScenesTableViewCell*)cell Info:(NSDictionary*)cellInfo;
@end

@interface SFIScenesTableViewCell : UITableViewCell

@property (weak) id<SFIScenesTableViewCellDelegate> delegate;
@property(nonatomic)UIColor *cellColor;
@property(nonatomic)NSArray * deviceIndexes;
@property(nonatomic)NSDictionary * cellInfo;
- (void)createScenesCell:(id)info;

@end
