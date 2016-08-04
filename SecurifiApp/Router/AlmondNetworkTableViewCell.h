//
//  AlmondNetworkTableViewCell.h
//  SecurifiApp
//
//  Created by Masood on 7/26/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AlmondNetworkTableViewCellDelegate
- (void)onAlmondTapDelegate:(int)almondCount;

- (void)onAddAlmondTapDelegate;
@end

@interface AlmondNetworkTableViewCell : UITableViewCell
//properties
@property (nonatomic) NSString* heading;

@property (nonatomic) NSArray *titles;

@property (nonatomic) NSArray *msgs;

@property (nonatomic) id<AlmondNetworkTableViewCellDelegate> delegate;
//methods
- (void)markReuse;

- (void)setHeading:(NSString*)heading titles:(NSArray *)titles almCount:(NSInteger)almCount;

- (void)createAlmondNetworkView;
@end
