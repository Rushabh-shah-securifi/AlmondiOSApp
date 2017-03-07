//
//  RegionTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 3/6/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  RegionTableViewCellDelegate

- (void)onRegionSelectedDelegate:(NSString *)region;

@end

@interface RegionTableViewCell : UITableViewCell

@property (nonatomic) id<RegionTableViewCellDelegate> delegate;

- (void)setupCell:(NSString *)region currentRegion:(NSString *)currentRegion;
@end
