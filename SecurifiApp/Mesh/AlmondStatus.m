//
//  AlmondStatus.m
//  SecurifiApp
//
//  Created by Masood on 8/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "AlmondStatus.h"
#import "AlmondJsonCommandKeyConstants.h"

@implementation AlmondStatus

+(AlmondStatus *)getMasterAlmondStatus:(SFIRouterSummary*)routerSummary{
    AlmondStatus *masterStatus = [AlmondStatus new];
    NSString *name = [SecurifiToolkit sharedInstance].currentAlmond.almondplusName;
    NSDictionary *ssid = [self getSSIDs:routerSummary];
    
    [self getStatus:name location:name connetedVia:@"Directly" interface:@"Wired" signalStrength:@"" ssid1:ssid[@"2G"] ssid2:ssid[@"5G"] internetStat:YES isMaster:YES active:YES];
    return masterStatus;
}

+(AlmondStatus *)getSlaveStatus:(NSDictionary *)payload routerSummary:(SFIRouterSummary*)routerSummary{
    AlmondStatus *stat = [AlmondStatus new];
    NSString *masterName = [SecurifiToolkit sharedInstance].currentAlmond.almondplusName;
    NSDictionary *ssid = [self getSSIDs:routerSummary];
    
    [self getStatus:payload[NAME] location:payload[NAME] connetedVia:masterName interface:payload[INTERFACE] signalStrength:payload[SIGNAL_STRENGTH] ssid1:ssid[@"2G"] ssid2:ssid[@"5G"] internetStat:[payload[@"InternetStatus"] boolValue] isMaster:NO active:[payload[ACTIVE] boolValue]];
    return stat;
}

+ (AlmondStatus *)getStatus:(NSString*)name location:(NSString*)location connetedVia:(NSString*)connetedVia interface:(NSString*)interface signalStrength:(NSString*)signalStrength ssid1:(NSString*)ssid1 ssid2:(NSString*)ssid2 internetStat:(BOOL)internetStat isMaster:(BOOL)isMaster active:(BOOL)isactive{
    AlmondStatus *stat = [AlmondStatus new];
    stat.internetStat = internetStat;
    stat.isActive = isactive;
    stat.isMaster = isMaster;
    stat.name = name;
    stat.location = location;
    stat.connecteVia = connetedVia;
    stat.interface = interface;
    stat.signalStrength = signalStrength;
    stat.ssid1 = ssid1;
    stat.ssid2 = ssid2;
    
    NSMutableArray *keyVals = [NSMutableArray new];
    [keyVals addObject:@{@"Location":location}];
    [keyVals addObject:@{@"Connected via":connetedVia}];
    [keyVals addObject:@{@"Interface":interface}];
    if(!isMaster)
        [keyVals addObject:@{@"Signal Strenght":signalStrength}];
    [keyVals addObject:@{@"5 GHz SSID":ssid2}];
    [keyVals addObject:@{@"2.4 GHz SSID":ssid1}];
    stat.keyVals = keyVals;
    return stat;
}


+(NSDictionary *)getSSIDs:(SFIRouterSummary*)routerSummary{
    NSMutableDictionary *ssids = [NSMutableDictionary new];
    for(SFIWirelessSummary *settings in routerSummary.wirelessSummaries){
        if([settings.type isEqualToString:@"2G"])
            ssids[@"2G"] = settings.ssid;
        else if([settings.type isEqualToString:@"5G"])
            ssids[@"5G"] = settings.ssid;
    }
    return ssids;
}
@end
