//
//  AlmondStatus.h
//  SecurifiApp
//
//  Created by Masood on 8/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlmondStatus : NSObject
@property (nonatomic)BOOL internetStat; //if almond has internet
@property (nonatomic)BOOL isActive; //info about almond power :/
@property (nonatomic)BOOL isMaster;

@property (nonatomic)NSString *name;
@property (nonatomic)NSString *slaveUniqueName; //only for slave
@property (nonatomic)NSString *location;
@property (nonatomic)NSString *connecteVia;
@property (nonatomic)NSString *interface;
@property (nonatomic)NSString *signalStrength;
@property (nonatomic)NSString *ssid1;
@property (nonatomic)NSString *ssid2;
@property (nonatomic)NSMutableArray *keyVals;

+(AlmondStatus *)getMasterAlmondStatus:(SFIRouterSummary*)routerSummary;
+(void)updateSlaveStatus:(NSDictionary *)payload routerSummary:(SFIRouterSummary*)routerSummary slaveStat:(AlmondStatus *)slaveStat;
+ (BOOL)hasCompleteDetails:(AlmondStatus *)almStat;
@end
