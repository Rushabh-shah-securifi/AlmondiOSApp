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
    [self getStatus:almondStat name:name location:name connetedVia:@"Directly" interface:@"Wired" signalStrength:@"" ssid1:ssid[@"2G"] ssid2:ssid[@"5G"] internetStat:YES isMaster:YES active:YES hop:0];
    return almondStat;
}

+(void)updateSlaveStatus:(NSDictionary *)payload routerSummary:(SFIRouterSummary*)routerSummary slaveStat:(AlmondStatus *)slaveStat{
    if([self payloadHasCompleteData:payload]){
        NSLog(@"status 1");
        NSDictionary *ssid = [self getSSIDs:routerSummary];
        [self getStatus:slaveStat
                   name:payload[NAME]
               location:payload[NAME]
            connetedVia:payload[CONNECTED_VIA]?:@"***"
              interface:payload[INTERFACE]
         signalStrength:[self hasSignalStrength:payload[SIGNAL_STRENGTH]]?payload[SIGNAL_STRENGTH]: SLAVE_OFFLINE
                  ssid1:ssid[@"2G"] ssid2:ssid[@"5G"]
           internetStat:[payload[@"InternetStatus"] boolValue]
               isMaster:NO
                 active:[payload[ACTIVE] boolValue]
                    hop:[payload[HOP_COUNT] integerValue]];
        slaveStat.slaveUniqueName = payload[SLAVE_UNIQUE_NAME];
    }
    else if([self payloadHasPartialData:payload]){//partial data means signal strength is n/a and has connectionvia tag
        NSLog(@"status 2");
        NSDictionary *ssid = [self getSSIDs:routerSummary];
        [self getStatus:slaveStat
                   name:payload[NAME]
               location:payload[NAME]
            connetedVia:payload[CONNECTED_VIA]?:@"***"
              interface:payload[INTERFACE]
         signalStrength:slaveStat.signalStrength
                  ssid1:ssid[@"2G"] ssid2:ssid[@"5G"]
           internetStat:[payload[@"InternetStatus"] boolValue]
               isMaster:NO
                 active:[payload[ACTIVE] boolValue]
                    hop:[payload[HOP_COUNT] integerValue]];
        slaveStat.slaveUniqueName = payload[SLAVE_UNIQUE_NAME];
        NSLog(@"signal str payload: %@, sig obj: %@", payload[SIGNAL_STRENGTH], slaveStat.signalStrength);
    }
    else{//has only signal strength (this could be n/a when slave is offline
        NSLog(@"status 3");
        slaveStat.signalStrength = [self hasSignalStrength:payload[SIGNAL_STRENGTH]]?payload[SIGNAL_STRENGTH]: SLAVE_OFFLINE;
    }
}

    
+ (BOOL)payloadHasCompleteData:(NSDictionary *)payload{
    if([payload[HOP_COUNT] integerValue] == 1){
        return YES;
    }
    if([self hasSignalStrength:payload[SIGNAL_STRENGTH]] && payload[CONNECTED_VIA]){
        return YES;
    }
    return NO;
}

+ (BOOL)payloadHasPartialData:(NSDictionary *)payload{
    //partial data means data w/o signal strength and has other keys
    if([self hasSignalStrength:payload[SIGNAL_STRENGTH]] == NO && payload[CONNECTED_VIA] != nil){
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
    NSLog(@"signal strength: %@", sigStrength);
    if(sigStrength == nil)
        return NO;
    return [sigStrength.lowercaseString isEqualToString:@"n/a"]? NO: YES;
}

+ (void)getStatus:(AlmondStatus *)stat name:(NSString*)name location:(NSString*)location connetedVia:(NSString*)connetedVia interface:(NSString*)interface signalStrength:(NSString*)signalStrength ssid1:(NSString*)ssid1 ssid2:(NSString*)ssid2 internetStat:(BOOL)internetStat isMaster:(BOOL)isMaster active:(BOOL)isactive hop:(NSInteger)hopCount{
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
    stat.hopCount = hopCount;
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
