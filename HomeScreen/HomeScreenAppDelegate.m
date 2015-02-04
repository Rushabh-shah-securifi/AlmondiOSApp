//
//  HomeScreenAppDelegate.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 12/10/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "HomeScreenAppDelegate.h"

#define CLOUD_HOST @"cloud.homescreenrouter.com"
#define CRASHLYTICS_KEY @"d68e94e89ffba7d497c7d8a49f2a58f45877e7c3"
#define ASSETS_PREFIX_ID @"HomeScreen"

@implementation HomeScreenAppDelegate

#pragma mark - Public methods; subclasses override

- (SecurifiConfigurator *)toolkitConfigurator {
    SecurifiConfigurator *cfg = [SecurifiConfigurator new];
    cfg.productionCloudHost = CLOUD_HOST;
    return cfg;
}

- (NSString *)crashReporterApiKey {
    return CRASHLYTICS_KEY;
}

- (NSString *)analyticsTrackingId {
    return [super analyticsTrackingId];
}

- (NSString *)assetsPrefixId {
    return ASSETS_PREFIX_ID;
}

@end
