//
//  SFIRouterSummary.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFIWirelessSummary;
@class SFIWirelessSetting;


@interface SFIRouterSummary : NSObject

@property(nonatomic) int wirelessSettingsCount;
@property(nonatomic) NSArray *wirelessSummaries; // SFIWirelessSummary
@property(nonatomic) int connectedDeviceCount;
@property(nonatomic) int blockedMACCount;
@property(nonatomic) int blockedContentCount;
@property(nonatomic) NSString *routerUptime;
@property(nonatomic) NSString *firmwareVersion;

// Returns the settings associated with the summary
- (SFIWirelessSummary *)summaryFor:(NSString *)ssid;


@end
