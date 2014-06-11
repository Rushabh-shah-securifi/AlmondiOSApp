//
//  SFIReachabilityManager.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIReachabilityManager : NSObject

+ (SFIReachabilityManager *)sharedManager;

- (BOOL)isReachable;

- (BOOL)isUnreachable;

- (BOOL)isReachableViaWWAN;

- (BOOL)isReachableViaWiFi;

@end
