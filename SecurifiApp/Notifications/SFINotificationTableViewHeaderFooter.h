//
// Created by Matthew Sinclair-Day on 2/11/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(int, SFINotificationTableViewHeaderFooterMode) {
    SFINotificationTableViewHeaderFooter_header,
    SFINotificationTableViewHeaderFooter_middle,
    SFINotificationTableViewHeaderFooter_footer,
};

@interface SFINotificationTableViewHeaderFooter : UIView

@property(nonatomic) SFINotificationTableViewHeaderFooterMode mode;
@property(nonatomic) NSDate *bucketDate;

@end