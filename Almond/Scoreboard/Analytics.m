//
//  Analytics.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "Analytics.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

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

- (void)markMemoryWarning {
    [self markEvent:@"app_mem_warn"];
}

- (void)markRouterReboot {
    [self markEvent:@"router_reboot"];
}

- (void)markSensorTiming:(NSTimeInterval)timeToToggle {
    double milliseconds = (double) (timeToToggle * 1000);
    NSNumber *num = @(milliseconds);

    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithTrackingId:GA_ID];

    [tracker set:kGAIEvent value:@"sensor_on_off"];
    [tracker send:@{@"time" : num}];
}

- (void)markLoginForm {
    [self trackScreen:@"login_form"];
}

- (void)markAlmondAffiliation {
    [self trackScreen:@"router_affiliation"];
}

- (void)markSignUpForm {
    [self trackScreen:@"signup_form"];
}

- (void)markDeclineSignupLicense {
    [self markEvent:@"license_decline"];
}

- (void)markEvent:(NSString *)eventName {
    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithTrackingId:GA_ID];

    NSDictionary *params = [[GAIDictionaryBuilder createEventWithCategory:@"action"     // Event category (required)
                                                                   action:eventName     // Event action (required)
                                                                    label:@"invoke"     // Event label
                                                                    value:nil] build];

    [tracker send:params];
}

- (void)trackScreen:(NSString *)name {
    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithTrackingId:GA_ID];
    NSDictionary *params = @{kGAIScreenName : name};
    [tracker send:params];
}

@end
