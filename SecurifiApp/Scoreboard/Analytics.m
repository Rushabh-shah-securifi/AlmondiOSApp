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

@interface Analytics ()
@property(nonatomic, readonly) NSString *trackingId;
@end

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

- (void)initialize:(NSString*)trackingId {
    //    [GAI sharedInstance].trackUncaughtExceptions = YES;
    //    [GAI sharedInstance].dispatchInterval = 20;
    //    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];

    _trackingId = [trackingId copy];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:trackingId];

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
        ELog(@"Analytics: unable to process kSFIDidCompleteMobileCommandRequest: command payload was nil");
        return;
    }

    NSNumber *roundTripTime = info[@"timing"];
    NSTimeInterval resTime = roundTripTime.doubleValue;

    [self markSensorClick:cmd.deviceType timeToComplete:resTime];
}

- (void)markMemoryWarning {
    [self markEvent:@"app_mem_warn"];
}

- (void)markRouterUpdateFirmware {
    [self markEvent:@"router_update_firmware"];
}

- (void)markRouterReboot {
    [self markEvent:@"router_reboot"];
}

- (void)markSendRouterLogs {
    [self markEvent:@"router_send_logs"];
}

- (void)markSensorClick:(SFIDeviceType)deviceType timeToComplete:(NSTimeInterval)resResTime {
    NSUInteger milliseconds = (NSUInteger) (resResTime * 1000);
    NSNumber *interval = @(milliseconds);

    NSString *deviceTypeStr = [SFIDevice nameForType:deviceType];
    NSDictionary *params = [[GAIDictionaryBuilder createTimingWithCategory:@"sensor_click"
                                                                  interval:interval
                                                                      name:@"device"
                                                                     label:deviceTypeStr] build];

    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithTrackingId:self.trackingId];
    [tracker send:params];
}

- (void)markSensorScreen {
    [self trackScreen:@"Sensor"];
}

- (void)markRouterScreen {
    [self trackScreen:@"Router"];
}

- (void)markNotificationsScreen {
    [self trackScreen:@"Notifications"];
}

- (void)markLoginForm {
    [self trackScreen:@"Login"];
}

- (void)markAlmondAffiliation {
    [self trackScreen:@"Affiliation"];
}

- (void)markSignUpForm {
    [self trackScreen:@"SignUp"];
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
    id <GAITracker> tracker = [gai trackerWithTrackingId:self.trackingId];

    [tracker send:params];
}

- (void)trackScreen:(NSString *)name {
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
    NSMutableDictionary *params = [builder build];
    
    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithTrackingId:self.trackingId];

    [tracker set:kGAIDescription value:name];
    [tracker send:params];
}

@end
