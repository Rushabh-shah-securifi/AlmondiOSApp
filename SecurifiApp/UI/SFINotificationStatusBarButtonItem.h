//
// Created by Matthew Sinclair-Day on 2/10/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SFINotificationStatusBarButtonItem : UIBarButtonItem

@property(nonatomic, readonly) NSUInteger notificationCount;

- (instancetype)initWithTarget:(id)target action:(SEL)action;

- (id)initWithStandard;

- (void)markNotificationCount:(NSUInteger)newCount;


@end