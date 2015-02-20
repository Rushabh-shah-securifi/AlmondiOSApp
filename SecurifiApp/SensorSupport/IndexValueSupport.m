//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "IndexValueSupport.h"
#import "ValueFormatter.h"


@implementation IndexValueSupport

- (BOOL)matchesData:(NSString *)data {
    switch (self.matchType) {
        case MatchType_equals:
            return [self.matchData isEqualToString:data];
        case MatchType_notequals:
            return ![self.matchData isEqualToString:data];
    }

    return NO;
}

- (NSString *)formatValue:(NSString *)value {
    return value;
}


- (ValueFormatter *)valueFormatter {
    if (_valueFormatter == nil) {
        _valueFormatter = [ValueFormatter new];
    }
    return _valueFormatter;
}


@end