//
//  DevicePropertyTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 1/30/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericIndexValue.h"
@protocol DevicePropertyTableViewCellDelegate
@optional
-(void)deviceNameUpdate:(NSString *)name genericIndexValue:(GenericIndexValue*)genericIndexValue;
-(void)deviceOnOffSwitchUpdate:(NSString *)status genericIndexValue:(GenericIndexValue*)genericIndexValue;
-(void)linkToNextScreen:(GenericIndexValue *)genericIndexValue;

@end


@interface DevicePropertyTableViewCell : UITableViewCell
@property (nonatomic,weak) id<DevicePropertyTableViewCellDelegate> delegate;
- (void)setUpCell:(NSDictionary *)cellDict property:(NSString *)property genericValue:(GenericIndexValue *)gIval;
- (void)setRightLabelColor:(UIColor *)color;

@end
