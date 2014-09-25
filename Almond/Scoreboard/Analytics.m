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

#define GA_ID @"UA-52832244-2"

@implementation Analytics

+ (instancetype)sharedInstance {
    static Analytics *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialize {
    //    [GAI sharedInstance].trackUncaughtExceptions = YES;
    //    [GAI sharedInstance].dispatchInterval = 20;
    //    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];

    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:GA_ID];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCompleteMobileCommandRequest:) name:kSFIDidCompleteMobileCommandRequest object:nil];
}

- (void)onCompleteMobileCommandRequest:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    if (!info) {
        return;
    }
    info = info[@"data"];
    if (!info) {
        return;
    }

    MobileCommandRequest *cmd = info[@"command"];
    if (!cmd) {
        NSLog(@"Analytics: unable to process kSFIDidCompleteMobileCommandRequest: command payload was nil");
        return;
    }

    NSNumber *roundTripTime = info[@"timing"];
    NSTimeInterval resTime = roundTripTime.doubleValue;

    [self markSensor:cmd.deviceType timeToComplete:resTime];
}

- (void)markMemoryWarning {
    [self markEvent:@"app_mem_warn"];
}

- (void)markRouterReboot {
    [self markEvent:@"router_reboot"];
}

- (void)markSensor:(SFIDeviceType)deviceType timeToComplete:(NSTimeInterval)resResTime {
    double milliseconds = (double) (resResTime * 1000);
    NSNumber *interval = @(milliseconds);

    NSString *deviceTypeStr = [SFIDevice nameForType:deviceType];
    NSDictionary *params = [[GAIDictionaryBuilder createTimingWithCategory:@"sensor_click"
                                                                  interval:interval
                                                                      name:@"device"
                                                                     label:deviceTypeStr] build];

    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithTrackingId:GA_ID];
    [tracker send:params];
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
    NSDictionary *params = [[GAIDictionaryBuilder createEventWithCategory:@"action"     // Event category (required)
                                                                   action:eventName     // Event action (required)
                                                                    label:@"invoke"     // Event label
                                                                    value:nil] build];

    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithTrackingId:GA_ID];

    [tracker send:params];
}

- (void)trackScreen:(NSString *)name {
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
    NSMutableDictionary *params = [builder build];
    
    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithTrackingId:GA_ID];

    [tracker set:kGAIDescription value:name];
    [tracker send:params];
}

@end
