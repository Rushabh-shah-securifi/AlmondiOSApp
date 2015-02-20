//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ValueFormatter;

typedef NS_ENUM(int, MatchType) {
    MatchType_equals    = 0,
    MatchType_notequals = 1,
};

@interface IndexValueSupport : NSObject

// compares the value with this instances matchData to determine whether this instance should be used.
// matching is based on matchType rule; however, when matchData is nil, then this method always returns YES.
- (BOOL)matchesData:(NSString*)value;

- (NSString*)formatValue:(NSString*)value;

// match data value; when nil, then match always is TRUE---this can be used to simply express a value formatter
@property(nonatomic) NSString *matchData;

// controls how matchesData compares values with this instance's data.
// defaults to MatchType_equals
@property(nonatomic) MatchType matchType;

// the name of the icon that will be displayed when this value is triggered
@property(nonatomic) NSString *iconName;

// the text that will be used when this value is triggered
// either this is specified or a ValueFormatter, not one or the other
@property(nonatomic) NSString *notificationText;

// when specified provides a formatter that formats an index's value into a formatted string
// either this is specified or notificationText, not one or the other
@property(nonatomic) ValueFormatter *valueFormatter;

@end