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

#define SENSOR_ACTION @"Sensor Action"
#define SCENE_ACTION @"Scene Action"
#define ROUTER_ACTION @"Router Action"
#define RULE_ACTION @"Rule Action"
#define MEMORY_WARNING @"Warning"
#define ACTION @"Action"

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

- (void)markSensorClick:(SFIDeviceType)deviceType timeToComplete:(NSTimeInterval)resResTime {
    NSUInteger milliseconds = (NSUInteger) (resResTime * 1000);
    NSNumber *interval = @(milliseconds);
    NSString *deviceTypeStr = securifi_name_to_device_type(deviceType);
    
    enum SFIAlmondConnectionMode mode = [[SecurifiToolkit sharedInstance] currentConnectionMode];
    NSString *eventCategory = @"Sensor Action";
    if(mode == SFIAlmondConnectionMode_local){
        eventCategory = [eventCategory stringByAppendingString:@" - Local"];
    }
    NSDictionary *params = [[GAIDictionaryBuilder createTimingWithCategory:eventCategory
                                                                  interval:interval
                                                                      name:@"Device"
                                                                     label:deviceTypeStr] build];

    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithTrackingId:self.trackingId];
    [tracker send:params];
}

- (void)markMemoryWarning {
    [self markEvent:@"App Memory Warning" category:MEMORY_WARNING];
}

- (void)markRouterUpdateFirmware {
    [self markEvent:@"Router Update Firmware" category:ROUTER_ACTION];
}

- (void)markRouterReboot {
    [self markEvent:@"Router Reboot" category:ROUTER_ACTION];
}

- (void)markSendRouterLogs {
    [self markEvent:@"Router Send Logs" category:ROUTER_ACTION];
}

- (void)markDeclineSignupLicense {
    [self markEvent:@"License Decline" category:ACTION];
}

- (void)markActivateScene {
    [self markEvent:@"Activate Scene" category:SCENE_ACTION];
}

- (void)markAddScene {
    [self markEvent:@"Add Scene" category:SCENE_ACTION];
}

- (void)markUpdateScene {
    [self markEvent:@"Edit Scene" category:SCENE_ACTION];
}

- (void)markDeleteScene {
    [self markEvent:@"Remove Scene" category:SCENE_ACTION];
}

- (void)markSensorLogs {
    [self markEvent:@"Sensor Logs" category:SENSOR_ACTION];
}

- (void)markSensorNameLocationChange {
    [self markEvent:@"Sensor Name/Location Change" category:SENSOR_ACTION];
}

- (void)markEditLocalConnection {
    [self markEvent:@"Edit Local Connection" category:ROUTER_ACTION];
}

- (void)markWifiClientUpdate {
    [self markEvent:@"Update WifiClient" category:ROUTER_ACTION];
}

- (void)markActivateRule {
    [self markEvent:@"Activate Rule" category:SCENE_ACTION];
}

- (void)markAddRule {
    [self markEvent:@"Add Rule" category:SCENE_ACTION];
}

- (void)markUpdateRule {
    [self markEvent:@"Edit Rule" category:SCENE_ACTION];
}

- (void)markDeleteRule {
    [self markEvent:@"Remove Rule" category:SCENE_ACTION];
}

- (void)markEvent:(NSString *)eventName category:(NSString *)eventCategory {
    enum SFIAlmondConnectionMode mode = [[SecurifiToolkit sharedInstance] currentConnectionMode];
    if(mode == SFIAlmondConnectionMode_local){
       eventCategory = [eventCategory stringByAppendingString:@" - Local"];
    }
    NSDictionary *params = [[GAIDictionaryBuilder createEventWithCategory:eventCategory     // Event category (required)
                                                                   action:eventName     // Event action (required)
                                                                    label:@"invoke"     // Event label
                                                                    value:nil] build];

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
    [self trackScreen:@"Notification Logs"];
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

- (void)markSceneScreen {
    [self trackScreen:@"Scenes"];
}

- (void)markNewSceneScreen {
    [self trackScreen:@"Add/Edit Scene"];
}

- (void)markAccountsScreen {
    [self trackScreen:@"Accounts"];
}

- (void)markLocalScreen {
    [self trackScreen:@"Local Link"];
}

- (void)markWifiClientScreen{
    [self trackScreen:@"Network Client"];
}

- (void)markLogoutAllScreen {
    [self trackScreen:@"LogoutAll"];
}

- (void)markRouterSettingsScreen {
    [self trackScreen:@"Router Settings"];
}

-(void)markRuleScreen{
    [self trackScreen:@"Rules"];
}

-(void)markAddOrEditRuleScreen{
    [self trackScreen:@"Add/Edit Rule"];
}


- (void)trackScreen:(NSString *)name {
    enum SFIAlmondConnectionMode mode = [[SecurifiToolkit sharedInstance] currentConnectionMode];
    
    if(mode == SFIAlmondConnectionMode_local){
        name = [name stringByAppendingString:@" - Local"];
    }
    NSLog(@"Name: %@", name);
    GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
    NSMutableDictionary *params = [builder build];
    
    GAI *gai = [GAI sharedInstance];
    id <GAITracker> tracker = [gai trackerWithTrackingId:self.trackingId];

    [tracker set:kGAIDescription value:name];
    [tracker send:params];
}

@end
