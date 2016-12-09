//
//  MySubscriptionsTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 12/5/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MySubscriptionsTableViewCellDelegate
- (void)onChangePlanDelegate;
- (void)onRenewPlanDelegate;
@end

@interface MySubscriptionsTableViewCell : UITableViewCell
@property (nonatomic, weak) id<MySubscriptionsTableViewCellDelegate> delegate;
- (void)setSubscriptionTitle:(NSString *)title;
@end
