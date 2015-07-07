//
// Created by Matthew Sinclair-Day on 7/7/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AlertViewAction : NSObject

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(AlertViewAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, getter=isEnabled) BOOL enabled;

- (void)invoke;

@end