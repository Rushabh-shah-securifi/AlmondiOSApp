//
//  MySubscriptionsTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 12/5/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlmondPlan.h"


#define TITLE @"title"
#define IS_EXPANDED @"is_expanded"
#define CHANGE_PLAN @"CHANGE PLAN"
#define CHOOSE_PLAN @"CHOOSE PLAN"
#define FREE_TRAIL @"FREE TRAIL"
#define CANCEL_SUBSCRIPTION @"CANCEL SUBSCRIPTION"


@protocol MySubscriptionsTableViewCellDelegate
- (void)onLeftBtnTapDelegate:(NSString *)btnTitle;
- (void)onRightBtnTapDelegate:(NSString *)btnTitle;
@end

@interface MySubscriptionsTableViewCell : UITableViewCell
@property (nonatomic, weak) id<MySubscriptionsTableViewCellDelegate> delegate;

-(void)setUpCell:(NSDictionary *)featureDict almondPlan:(AlmondPlan *)plan;
@end
