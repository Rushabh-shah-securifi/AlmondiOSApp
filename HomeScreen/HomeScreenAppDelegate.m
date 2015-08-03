//
//  HomeScreenAppDelegate.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 12/10/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "HomeScreenAppDelegate.h"

#define CLOUD_HOST @"cloud.homescreenrouter.com"
#define ASSETS_PREFIX_ID @"HomeScreen"
#define HOMESCREEN_GA_ID @"UA-54926195-4"

@implementation HomeScreenAppDelegate

#pragma mark - Public methods; subclasses override

- (SecurifiConfigurator *)toolkitConfigurator {
    SecurifiConfigurator *cfg = [SecurifiConfigurator new];
    cfg.productionCloudHost = CLOUD_HOST;
    cfg.enableRouterWirelessControl = NO; // disabled until the cloud and app have more robust support for changing SSID
    cfg.enableNotifications = YES;
    cfg.enableNotificationsHomeAwayMode = NO;
    return cfg;
}

- (NSString *)analyticsTrackingId {
    return HOMESCREEN_GA_ID;
}

- (NSString *)assetsPrefixId {
    return ASSETS_PREFIX_ID;
}

@end
