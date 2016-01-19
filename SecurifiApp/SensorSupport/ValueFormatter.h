//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, ValueFormatterAction) {
    ValueFormatterAction_scale,
    ValueFormatterAction_formatString,
};


@interface ValueFormatter : NSObject

// specifies the value transformation function to be used
// formatString indicates that notificationText, notificationPrefix, and suffix are treated as format templates to be passed to NSString formatString
// scale indicates that the value will be converted to an integer and then scaled to the max value indicated by scaleFactor; used for scaling a sensor value range like 1-255 to 1-100.
@property(nonatomic) ValueFormatterAction action;

@property(nonatomic) NSInteger maxValue;        // maximum value of raw value as provided by and to the sensor
@property(nonatomic) NSInteger scaledMaxValue;  // maximum value of scaled value shown in UI

// when specified, constitutes the text that will be used for the describing the changed value in a notification message
// takes precedent over notificationPrefix and notificationSuffix
@property(nonatomic) NSString *notificationText;

// when specified, becomes the text that will be prepended to the name of the device "<Your Switch>'s power...." and
// appended to the device value <device name> <prefix> <value> <suffix>
@property(nonatomic) NSString *notificationPrefix;

// when specified the value

@property(nonatomic) NSString *suffix;

- (NSString*)formatNotificationValue:(NSString*)sensorValue;

@end