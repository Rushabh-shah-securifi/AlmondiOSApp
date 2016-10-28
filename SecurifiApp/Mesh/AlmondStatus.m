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
    NSString *name = [SecurifiToolkit sharedInstance].currentAlmond.almondplusName;
    NSDictionary *ssid = [self getSSIDs:routerSummary];
    AlmondStatus *almondStat = [AlmondStatus new];
    [self getStatus:almondStat name:name location:name connetedVia:@"Directly" interface:@"Wired" signalStrength:@"" ssid1:ssid[@"2G"] ssid2:ssid[@"5G"] internetStat:YES isMaster:YES active:YES];
    return almondStat;
}

/*
 {
 "CommandMode":"Reply",
 "CommandType":"SlaveDetailsMobile",
 "SlaveUniqueName":"Almond 2333",
 "ID":"1",
 "Name":"Downstairs",
 "Active":"true",
 "Interface":"Wired",
 "InternetStatus":"true",
 "SignalStrength":"0"
 "MobileInternalIndex":"ttWsbWY91duqYuxOz2v5C2IrGFCm65Yz",
 "Success":"true",
 "Reason":"0"
 }
 */
+(void)updateSlaveStatus:(NSDictionary *)payload routerSummary:(SFIRouterSummary*)routerSummary slaveStat:(AlmondStatus *)slaveStat{
    if([self payloadHasCompleteData:payload]){
        NSDictionary *ssid = [self getSSIDs:routerSummary];
        [self getStatus:slaveStat
                   name:payload[NAME]
               location:payload[NAME]
            connetedVia:payload[CONNECTED_VIA]?:@"***"
              interface:payload[INTERFACE]
         signalStrength:payload[SIGNAL_STRENGTH]
                  ssid1:ssid[@"2G"] ssid2:ssid[@"5G"]
           internetStat:[payload[@"InternetStatus"] boolValue]
               isMaster:NO
                 active:[payload[ACTIVE] boolValue]];
        slaveStat.slaveUniqueName = payload[SLAVE_UNIQUE_NAME];
    }
    else if([self payloadHasPartialData:payload]){
        NSDictionary *ssid = [self getSSIDs:routerSummary];
        [self getStatus:slaveStat
                   name:payload[NAME]
               location:payload[NAME]
            connetedVia:payload[CONNECTED_VIA]?:@"***"
              interface:payload[INTERFACE]
         signalStrength:slaveStat.signalStrength?:@""
                  ssid1:ssid[@"2G"] ssid2:ssid[@"5G"]
           internetStat:[payload[@"InternetStatus"] boolValue]
               isMaster:NO
                 active:[payload[ACTIVE] boolValue]];
        slaveStat.slaveUniqueName = payload[SLAVE_UNIQUE_NAME];
    }
    else{//has only signal strength
        slaveStat.signalStrength = payload[SIGNAL_STRENGTH];
    }
}

+ (BOOL)payloadHasCompleteData:(NSDictionary *)payload{
    if([self hasSignalStrength:payload[SIGNAL_STRENGTH]] && payload[CONNECTED_VIA]){
        return YES;
    }
    return NO;
}

+ (BOOL)payloadHasPartialData:(NSDictionary *)payload{
    //partial data means data w/o signal strength
    if([self hasSignalStrength:payload[SIGNAL_STRENGTH]] == NO){
        return  YES;
    }
    return NO;
}

+ (BOOL)hasCompleteDetails:(AlmondStatus *)almStat{
    //this is required as we are now getting 2 response (sometimes)one would exclusively have sginalstrength and the other rest.
    //we shall for now just check connectedvia key and signal strenght key to differentiate commands
    if(almStat.connecteVia && [self hasSignalStrength:almStat.signalStrength]){
        return YES;
    }
    return NO;
}

+ (BOOL)hasSignalStrength:(NSString *)sigStrength{
    if(sigStrength == nil)
        return NO;
    return [sigStrength.lowercaseString isEqualToString:@"n/a"]? NO: YES;
}

+ (void)getStatus:(AlmondStatus *)stat name:(NSString*)name location:(NSString*)location connetedVia:(NSString*)connetedVia interface:(NSString*)interface signalStrength:(NSString*)signalStrength ssid1:(NSString*)ssid1 ssid2:(NSString*)ssid2 internetStat:(BOOL)internetStat isMaster:(BOOL)isMaster active:(BOOL)isactive{
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
    [keyVals addObject:@{@"Connected Via":connetedVia}];
    [keyVals addObject:@{@"Interface":interface}];
    [keyVals addObject:@{@"Connection Status":(isactive? @"Active": @"Inactive")}];
    [keyVals addObject:@{@"Internet Status":(internetStat? @"Online": @"Offline")}];
    if(!isMaster && [interface isEqualToString:@"Wireless"])
        [keyVals addObject:@{@"Signal Strength":[self getSignalStrength:signalStrength.integerValue]}];
    if(ssid2)
        [keyVals addObject:@{@"5 GHz SSID":ssid2}];
    [keyVals addObject:@{@"2.4 GHz SSID":ssid1}];
    stat.keyVals = keyVals;
}

+ (NSString *)getSignalStrength:(NSInteger)sig{
    // RSSI levels range from -50dBm (100%) to -100dBm (0%)
    // Signal Quality Levels : Highest 5. Lowest 0
    if(sig >= -50)
        return @"Excellent";
    else if(sig < -50 && sig >=-73)
        return @"Good";
    else if(sig < -73 && sig >= -87)
        return @"Poor";
    else
        return @"Extremely Poor";
}


+(NSDictionary *)getSSIDs:(SFIRouterSummary*)routerSummary{
    NSMutableDictionary *ssids = [NSMutableDictionary new];
    for(SFIWirelessSummary *settings in routerSummary.wirelessSummaries){
        if([settings.type isEqualToString:@"2G"])
            ssids[@"2G"] = settings.ssid?:@"";
        else if([settings.type isEqualToString:@"5G"])
            ssids[@"5G"] = settings.ssid?:@"";
    }
    return ssids;
}
@end
