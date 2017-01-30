//
//  DevicePropertyTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 1/30/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DevicePropertyTableViewCell : UITableViewCell
- (void)setUpCell:(NSDictionary *)cellDict indexPath:(NSIndexPath *)indexPath;
@end
