//
//  SFINotificationTableViewCell.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/19/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFINotificationTableViewCell : UITableViewCell

@property NSDate notificationTime;
@property SFIDeviceType deviceType;
@property NSString *event;

@end
