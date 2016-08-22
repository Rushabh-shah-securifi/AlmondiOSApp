//
//  MoreCellTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 8/22/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PROFILE_PIC @"ProfilePicture"

@protocol MoreCellTableViewCellDelegate
-(void)onLogoutTapDelegate;
-(void)onImageTapDelegate:(UIButton *)button;
@end

@interface MoreCellTableViewCell : UITableViewCell

@property (weak, nonatomic)id<MoreCellTableViewCellDelegate> delegate;

-(void)setUpMoreCell1;

-(void)setUpMoreCell2:(NSDictionary*)moreFeature;

-(void)setUpMoreCell3;
@end
