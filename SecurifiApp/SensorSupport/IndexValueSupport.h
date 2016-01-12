//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiToolkit/SecurifiTypes.h"
@class ValueFormatter;

typedef NS_ENUM(int, MatchType) {
    MatchType_equals = 0, // matchData is exactly the same as the value
    MatchType_not_equals = 1, // matchData is NOT the same as the value
    MatchType_any = 2, // matchData is irrelevant; any value matches; used in cases where the index is simply for reporting information
};

// Defined a function whose input is the actual index value and the output is a transformed representation meant for
// formatting and display
typedef NSString *(^IndexValueTransformer)(NSString *);

@interface IndexValueSupport : NSObject

@property(nonatomic) NSString *layoutType;
@property(nonatomic) NSString *displayText;
@property(nonatomic) NSInteger minValue;
@property(nonatomic) NSInteger maxValue;

// When YES, the index value is ignored for processing Notifications and any such value is silently dropped
// Defaults to NO
@property(nonatomic) BOOL notificationIgnoreIndex;

@property(nonatomic, readonly) SFIDevicePropertyType valueType;

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

// when specified, the transformation function is called with the supplied index value to convert it into a representation
// suitable for subsequent formatting and presentation
@property(copy) IndexValueTransformer valueTransformer;

// when specified provides a formatter that formats an index's value into a formatted string
// either this is specified or notificationText, not one or the other
@property(nonatomic) ValueFormatter *valueFormatter;

- (instancetype)initWithValueType:(SFIDevicePropertyType)valueType;

// compares the value with this instances matchData to determine whether this instance should be used.
// matching is based on matchType rule; however, when matchData is nil, then this method always returns YES.
- (BOOL)matchesData:(NSString *)value;

- (NSString *)formatNotificationText:(NSString *)sensorValue;

@end