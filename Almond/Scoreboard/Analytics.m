//
//  Analytics.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "Analytics.h"
#import "GAI.h"

#define GA_ID @"UA-52832244-1"

@implementation Analytics

+ (instancetype)sharedInstance {
    static Analytics *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)initialize {
    //    [GAI sharedInstance].trackUncaughtExceptions = YES;
    //    [GAI sharedInstance].dispatchInterval = 20;
    //    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];

    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:GA_ID];
}

- (void)markRouterReboot {
    id <GAITracker> tracker = [self trackerForName:@"router_reboot"];
    [tracker send:@{@"mark":@1}];
}

- (void)markSensorTiming:(NSTimeInterval)timeToToggle {
    double milliseconds = (double) (timeToToggle * 1000);
    NSNumber *num = @(milliseconds);

    id <GAITracker> tracker = [self trackerForName:@"sensor_on_off"];
    [tracker send:@{@"time":num}];
}

- (void)markLoginForm {
    id <GAITracker> tracker = [self trackerForName:@"login_form"];
    [tracker send:@{@"mark":@1}];
}

- (void)markAlmondAffiliation {
    id <GAITracker> tracker = [self trackerForName:@"router_affiliation"];
    [tracker send:@{@"mark":@1}];
}

- (void)markSignUpForm {
    id <GAITracker> tracker = [self trackerForName:@"signup_form"];
    [tracker send:@{@"mark":@1}];
}

- (void)markDeclineSignupLicense {
    id <GAITracker> tracker = [self trackerForName:@"license_decline"];
    [tracker send:@{@"mark":@1}];
}

- (id <GAITracker>)trackerForName:(NSString*)name {
    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithName:name trackingId:GA_ID];
    return tracker;
}

@end
