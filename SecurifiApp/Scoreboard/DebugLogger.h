//
// Created by Matthew Sinclair-Day on 3/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DebugLogger : NSObject

+ (DebugLogger *)instance;

- (void)open;

- (void)close;

- (void)clear;

- (void)writeLog:(NSString *)msg;

@end