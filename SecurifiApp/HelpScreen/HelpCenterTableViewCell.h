//
//  HelpCenterTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 7/20/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpCenterTableViewCell : UITableViewCell

- (void)setUpHelpCell:(NSDictionary *)helpItem;

- (void)setUpHelpItemCell:(NSDictionary*)helpItem row:(NSInteger)row;

- (void)setUpSupportCell:(NSArray *)countryNumber row:(NSInteger)row;
@end