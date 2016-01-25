//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "IndexValueSupport.h"
#import "ValueFormatter.h"


@implementation IndexValueSupport

- (instancetype)initWithValueType:(SFIDevicePropertyType)valueType {
    self = [super init];
    if (self) {
        _notificationIgnoreIndex = NO;
        _valueType = valueType;
        _matchType = MatchType_equals;
        self.eventType=nil;
    }

    return self;
}

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
- (NSString *)getDisplayText:(NSString *)value {
    if([self valueFormatterDoesNotExist])
        return self.displayText;
    return [NSString stringWithFormat:@"%@ %@%@", self.displayText, value, self.valueFormatter.suffix];
}
- (BOOL)valueFormatterDoesNotExist{
    return self.valueFormatter.suffix == nil || self.valueFormatter.suffix.length ==0 ;
}


- (NSString *)formatNotificationText:(NSString *)sensorValue {
    if (sensorValue == nil) {
        sensorValue = @"";
    }

    if (_valueTransformer) {
        sensorValue = _valueTransformer(sensorValue);
    }

    if (_valueFormatter) {
        return [_valueFormatter formatNotificationValue:sensorValue];
    }

    NSString *text = self.notificationText;
    if (text) {
        return text;
    }

    return sensorValue;
}

@end