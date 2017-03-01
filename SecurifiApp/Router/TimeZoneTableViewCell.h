//
//  TimeZoneTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 3/1/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeZoneTableViewCell : UITableViewCell
- (void)setupCell:(NSString *)country time:(NSString *)time;
@end
