//
// Created by Matthew Sinclair-Day on 2/23/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NotificationsTestStore : NSObject <SFINotificationStore>

@property NSString *almondMac; // MAC to be used for creating Notifications

- (void)setup;

@end