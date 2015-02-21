//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "IndexValueSupport.h"
#import "ValueFormatter.h"


@implementation IndexValueSupport

- (ValueFormatter *)valueFormatter {
    if (_valueFormatter == nil) {
        _valueFormatter = [ValueFormatter new];
    }
    return _valueFormatter;
}

- (BOOL)matchesData:(NSString *)data {
    switch (self.matchType) {
        case MatchType_equals:
            return [self.matchData isEqualToString:data];
        case MatchType_not_equals:
            return ![self.matchData isEqualToString:data];
        case MatchType_any:
            return YES;
    }

    return NO;
}

- (NSString *)formatNotificationText:(NSString *)sensorValue {
    if (_valueFormatter) {
        [_valueFormatter formatNotificationValue:sensorValue];
    }

    NSString *text = self.notificationText;
    if (text) {
        return [NSString stringWithFormat:text, sensorValue];
    }

    return sensorValue;
}

@end