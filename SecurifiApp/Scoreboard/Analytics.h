//
//  Analytics.h
//  Almond
//
//  Created by Matthew Sinclair-Day on 8/29/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
We need to capture Timing of Sensor On/Off, how many times Router Reboot is
hit, Track sensor, login , affiliation and Router, Sign up page hits.
 */

@interface Analytics : NSObject

+ (instancetype)sharedInstance;

#pragma mark Events

- (void)initialize:(NSString *)trackingId;

- (void)markMemoryWarning;

- (void)markRouterUpdateFirmware;

- (void)markRouterReboot;

- (void)markSendRouterLogs;

- (void)markDeclineSignupLicense;

- (void)markActivateScene;

- (void)markAddScene;

- (void)markUpdateScene;

- (void)markDeleteScene;

- (void)markSensorLogs;

- (void)markSensorNameLocationChange;

- (void)markEditLocalConnection;

- (void)markWifiClientUpdate;

- (void)markActivateRule;

- (void)markAddRule;

- (void)markUpdateRule;

- (void)markDeleteRule;
//helpscreens
- (void)markTapproducts;

- (void)markTapWiFi;

- (void)markTapSmartHome;

- (void)markEmail;

- (void)markCall;

//mesh
- (void)markWired;

- (void)markWireless;

- (void)markTroublePairingAlmond;

- (void)markCanNotFindAlmond;

- (void)markLedBlinking;

- (void)markLedNotBlinking;

- (void)markAddAnotherAlmond;

- (void)markAddAlmondLater;

#pragma mark screen Tracking

- (void)markSensorClick:(SFIDeviceType)deviceType timeToComplete:(NSTimeInterval)resResTime;

- (void)markDevicesScreen;

- (void)markSceneScreen;

- (void)markRouterScreen;

- (void)markMoreScreen;

- (void)markRuleScreen;

- (void)markNewSceneScreen;

- (void)markAddOrEditRuleScreen;

- (void)markAccountsScreen;

- (void)markNotificationsScreen;

- (void)markLoginForm;

- (void)markAlmondAffiliation;

- (void)markSignUpForm;

- (void)markLocalScreen;

- (void)markLogoutAllScreen;

- (void)markRouterSettingsScreen;

//helpscreens
- (void)markHelpCenterScreen;

- (void)markQuickTipsScreen;

- (void)markHelpTopicsScreen;

- (void)markSupportScreen;

- (void)markHelpDescriptionScreen;

//mesh
- (void)markMasterScreen;

- (void)markSlaveScreen;

- (void)markAddAlmondScreen;


//site map
- (void)markParentalPage;

- (void)markLogWebHistory;

- (void)markALogDataUsage;

- (void)markWebHistoryPage;

- (void)markCategoryChange;
@end
