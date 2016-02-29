//
//  SFIWiFiClientListCell.h
//  Wifi
//
//  Created by Tigran Aslanyan on 26.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SFIConnectedDevice;
@class SFIWiFiClientListCell;

@protocol SFIWiFiClientListCellDelegate
- (void)btnSettingTapped:(NSDictionary *)connectedDevice index:(NSArray*)indexArray;
@optional
- (void)btnSettingTapped:(SFIWiFiClientListCell *)cell Info:(SFIConnectedDevice *)connectedDevice;
-(void)settingTapped:(SFIWiFiClientListCell*)cell Info:(SFIConnectedDevice*)connectedDevice;
@end

@interface SFIWiFiClientListCell : UITableViewCell

@property (weak) id<SFIWiFiClientListCellDelegate> delegate;
@property (nonatomic, assign, getter = isExpandable) BOOL expandable;
@property (nonatomic, assign, getter = isExpanded) BOOL expanded;
@property (strong) SFIConnectedDevice* connectedDevice;

- (void)addIndicatorView;
- (void)removeIndicatorView;
- (BOOL)containsIndicatorView;
- (void)accessoryViewAnimation;

- (void)createClientCell:(SFIConnectedDevice*)connectedDevice;
- (void)drawIndexes;

@end
