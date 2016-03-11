//
//  CustomCellTableViewCell.h
//  RulesUI
//
//  Created by Securifi-Mac2 on 03/12/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCellTableViewCell.h"
@class CustomCellTableViewCell;

@protocol CustomCellTableViewCellDelegate
//- (void)activateScene:(SFIScenesTableViewCell*)cell Info:(NSDictionary*)cellInfo;
- (void)editRule:(CustomCellTableViewCell *)cell;
- (void)deleteRule:(CustomCellTableViewCell *)cell;
- (void)activateRule:(CustomCellTableViewCell *)cell;
@end


@interface CustomCellTableViewCell : UITableViewCell

//require all 3 for public usage
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *ruleNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *activeDeactiveSwitch;
@property (nonatomic)id<CustomCellTableViewCellDelegate> delegate;

@end
