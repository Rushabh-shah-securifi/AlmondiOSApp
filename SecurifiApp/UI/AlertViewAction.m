//
// Created by Matthew Sinclair-Day on 7/7/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "AlertViewAction.h"


@interface AlertViewAction ()
@property(nonatomic, copy) void (^handler)(AlertViewAction *);
@end

@implementation AlertViewAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(AlertViewAction *action))handler {
    return [[AlertViewAction alloc] initWithTitle:title handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title handler:(void (^)(AlertViewAction *))handler {
    self = [super init];
    if (self) {
        _title = [title copy];
        self.enabled = YES;
        self.handler = handler;
    }

    return self;
}

- (void)invoke {
    self.handler(self);
}

@end