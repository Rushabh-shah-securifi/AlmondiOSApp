//
//  DevicePropertyTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 1/30/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"
@interface DevicePropertyTableViewCell : UITableViewCell
- (void)setUpCell:(NSDictionary *)cellDict property:(NSString *)property genericValue:(GenericIndexValue *)gIval;
- (void)setRightLabelColor:(UIColor *)color;
@end
