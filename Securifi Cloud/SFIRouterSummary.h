//
//  SFIRouterSummary.h
//  Securifi Cloud
//
//  Created by Securifi-Mac2 on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SFIRouterSummary : NSObject
@property int wirelessSettingsCount;
@property (nonatomic, retain) NSArray *wirelessSettings;
@property int connectedDeviceCount;
@property int blockedMACCount;
@property int blockedContentCount;
@property (nonatomic, retain) NSString *routerUptime;
@end
