//
//  HomeScreenAppDelegate.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 12/10/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "HomeScreenAppDelegate.h"

@implementation HomeScreenAppDelegate

#pragma mark - Public methods; subclasses override

- (SecurifiConfigurator *)toolkitConfigurator {
    return [SecurifiConfigurator new];
}

- (NSString *)crashReporterApiKey {
    return @"d68e94e89ffba7d497c7d8a49f2a58f45877e7c3";
}


@end
