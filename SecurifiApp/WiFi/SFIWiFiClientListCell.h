//
//  SFIWiFiClientListCell.h
//  Wifi
//
//  Created by Tigran Aslanyan on 26.05.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SFIConnectedDevice;


@interface SFIWiFiClientListCell : UITableViewCell

@property (nonatomic, assign, getter = isExpandable) BOOL expandable;
@property (nonatomic, assign, getter = isExpanded) BOOL expanded;

- (void)addIndicatorView;
- (void)removeIndicatorView;
- (BOOL)containsIndicatorView;
- (void)accessoryViewAnimation;

- (void)createClientCell:(SFIConnectedDevice*)connectedDevice;

@end
