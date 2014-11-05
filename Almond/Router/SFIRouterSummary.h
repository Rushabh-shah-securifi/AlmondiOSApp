//
//  SFIRouterSummary.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SFIRouterSummary : NSObject
@property(nonatomic) int wirelessSettingsCount;
@property(nonatomic) NSArray *wirelessSettings;
@property(nonatomic) int connectedDeviceCount;
@property(nonatomic) int blockedMACCount;
@property(nonatomic) int blockedContentCount;
@property(nonatomic) NSString *routerUptime;
@property(nonatomic) NSString *firmwareVersion;

@end
