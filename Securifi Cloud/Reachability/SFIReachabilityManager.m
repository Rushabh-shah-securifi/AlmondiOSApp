//
//  SFIReachabilityManager.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIReachabilityManager.h"
#import "AlmondPlusSDKConstants.h"
#import "Reachability.h"

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
#pragma mark Memory Management
- (void)dealloc {
    // Stop Notifier
    if (_reachability) {
        [_reachability stopNotifier];
    }
}
#pragma mark -
#pragma mark Class Methods
+ (BOOL)isReachable {
    return [[[SFIReachabilityManager sharedManager] reachability] isReachable];
}
+ (BOOL)isUnreachable {
    return ![[[SFIReachabilityManager sharedManager] reachability] isReachable];
}
+ (BOOL)isReachableViaWWAN {
    return [[[SFIReachabilityManager sharedManager] reachability] isReachableViaWWAN];
}
+ (BOOL)isReachableViaWiFi {
    return [[[SFIReachabilityManager sharedManager] reachability] isReachableViaWiFi];
}
#pragma mark -
#pragma mark Private Initialization
- (id)init {
    self = [super init];
    if (self) {
        // Initialize Reachability
        self.reachability = [Reachability reachabilityWithHostname:CLOUD_SERVER];
        // Start Monitoring
        [self.reachability startNotifier];
    }
    return self;
}
@end
