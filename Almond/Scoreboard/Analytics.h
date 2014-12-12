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

- (void)initialize:(NSString *)trackingId;

- (void)markMemoryWarning;

- (void)markRouterReboot;

- (void)markSensor:(SFIDeviceType)deviceType timeToComplete:(NSTimeInterval)resResTime;

- (void)markLoginForm;

- (void)markAlmondAffiliation;

- (void)markSignUpForm;

- (void)markDeclineSignupLicense;

@end
