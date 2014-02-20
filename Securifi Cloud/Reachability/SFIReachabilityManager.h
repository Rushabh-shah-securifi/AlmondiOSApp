//
//  SFIReachabilityManager.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;
@interface SFIReachabilityManager : NSObject
@property (strong, nonatomic) Reachability *reachability;
#pragma mark -
#pragma mark Shared Manager
+ (SFIReachabilityManager *)sharedManager;
#pragma mark -
#pragma mark Class Methods
+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;
@end
