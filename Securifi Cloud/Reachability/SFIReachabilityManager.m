//
//  SFIReachabilityManager.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIReachabilityManager.h"
#import "Reachability.h"

@interface SFIReachabilityManager ()
@property(strong, nonatomic, readonly) Reachability *reachability;
@end

@implementation SFIReachabilityManager

#pragma mark -
#pragma mark Default Manager

+ (SFIReachabilityManager *)sharedManager {
    static SFIReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

#pragma mark -
#pragma mark Initialization

- (id)init {
    self = [super init];
    if (self) {
        // Initialize Reachability
        _reachability = [Reachability reachabilityWithHostname:CLOUD_SERVER];
        // Start Monitoring
        [self.reachability startNotifier];
    }
    return self;
}

- (void)dealloc {
    // Stop Notifier
    if (_reachability) {
        [_reachability stopNotifier];
    }
}

#pragma mark -
#pragma mark Public methods

- (BOOL)isReachable {
    return self.reachability.isReachable;
}

- (BOOL)isUnreachable {
    return !self.reachability.isReachable;
}

- (BOOL)isReachableViaWWAN {
    return self.reachability.isReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi {
    return self.reachability.isReachableViaWiFi;
}

@end
