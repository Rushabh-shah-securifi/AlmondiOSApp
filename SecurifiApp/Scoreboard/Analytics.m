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
#define HELP_ACTION @"Help Action"
#define MESH_ACTION @"Mesh Action"
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

//helpscreens
- (void)markTapproducts{
    [self markEvent:@"Tap Products" category:HELP_ACTION];
}

- (void)markTapWiFi{
    [self markEvent:@"Tap Wi-Fi" category:HELP_ACTION];
}

- (void)markTapSmartHome{
    [self markEvent:@"Tap SmartHome" category:HELP_ACTION];
}

- (void)markEmail{
    [self markEvent:@"Email" category:HELP_ACTION];
}

- (void)markCall{
    [self markEvent:@"Call" category:HELP_ACTION];
}
//mesh
- (void)markWired{
    [[Analytics sharedInstance] markEvent:@"Wired" category:MESH_ACTION];
}

- (void)markWireless{
    [[Analytics sharedInstance] markEvent:@"Wireless" category:MESH_ACTION];
}

- (void)markTroublePairingAlmond{
    [[Analytics sharedInstance] markEvent:@"Trouble Pairing Almond" category:MESH_ACTION];
}

- (void)markCanNotFindAlmond{
    [[Analytics sharedInstance] markEvent:@"Cannot Find Almond" category:MESH_ACTION];
}

- (void)markLedBlinking{
    [[Analytics sharedInstance] markEvent:@"Led Blinking" category:MESH_ACTION];
}

- (void)markLedNotBlinking{
    [[Analytics sharedInstance] markEvent:@"Led Not Blinking" category:MESH_ACTION];
}
- (void)markAddAnotherAlmond{
    [[Analytics sharedInstance] markEvent:@"Add Another Almond" category:MESH_ACTION];
}

- (void)markAddAlmondLater{
    [[Analytics sharedInstance] markEvent:@"Add Almond Later" category:MESH_ACTION];
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

- (void)markDevicesScreen {
    [self trackScreen:@"Devices"];
}

- (void)markSceneScreen {
    [self trackScreen:@"Scenes"];
}

- (void)markRouterScreen {
    [self trackScreen:@"Router"];
}

- (void)markMoreScreen {
    [self trackScreen:@"More"];
}

- (void)markNewSceneScreen {
    [self trackScreen:@"Add/Edit Scene"];
}

-(void)markAddOrEditRuleScreen{
    [self trackScreen:@"Add/Edit Rule"];
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

- (void)markAccountsScreen {
    [self trackScreen:@"Accounts"];
}

- (void)markLocalScreen {
    [self trackScreen:@"Local Link"];
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

//helpscreens
- (void)markHelpCenterScreen{
    [self trackScreen:@"Help Center"];
}

- (void)markQuickTipsScreen{
    [self trackScreen:@"Quick Tips"];
}

- (void)markHelpTopicsScreen{
    [self trackScreen:@"Help Topics"];
}

- (void)markSupportScreen{
    [self trackScreen:@"Support"];
}

- (void)markHelpDescriptionScreen{
    [self trackScreen:@"Help Description"];
}

//mesh
- (void)markMasterScreen{
    [self trackScreen:@"Master Details"];
}

- (void)markSlaveScreen{
    [self trackScreen:@"Slave Details"];
}

- (void)markAddAlmondScreen{
    [self trackScreen:@"Add Mesh Almond"];
}

//site map
- (void)markParentalPage{
    [self trackScreen:@"Parental control page"];
}
- (void)markLogWebHistory{
    [self trackScreen:@"web history enable"];
}
- (void)markALogDataUsage{
    [self trackScreen:@"log data usage"];
}
- (void)markWebHistoryPage{
    [self trackScreen:@"web history page"];
}
- (void)markCategoryChange{
    [self trackScreen:@"change category"];
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
