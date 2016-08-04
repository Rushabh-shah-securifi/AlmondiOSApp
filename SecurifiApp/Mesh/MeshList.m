//
//  MeshList.m
//  SecurifiApp
//
//  Created by Masood on 8/3/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MeshList.h"
#import "AlmondJsonCommandKeyConstants.h"
/*
 @interface AlmondStatus : NSObject
 @property (nonatomic)BOOL isConnected;
 @property (nonatomic)BOOL isMaster;
 
 @property (nonatomic)NSString *name;
 @property (nonatomic)NSString *location;
 @property (nonatomic)NSString *connecteVia;
 @property (nonatomic)NSString *interface;
 @property (nonatomic)NSString *signalStrength;
 @property (nonatomic)NSString *ssid1;
 @property (nonatomic)NSString *ssid2;
 @end
 
 @interface MeshList : NSObject
 @property (nonatomic)NSArray *statusArray;
 @property (nonatomic)NSString *commandMode;
 @property (nonatomic)NSString *commandType;
 @property (nonatomic)NSString *masterName;
 @property (nonatomic)int mii;
 @property (nonatomic)BOOL isSuccessful;
 @property (nonatomic)int reason;
 @end
 */
@implementation AlmondStatus

@end

@implementation MeshList
-(id)initWithMeshList:(NSDictionary *)meshList{
    self = [super init];
    if(self){
        self.commandMode = meshList[COMMAND_MODE];
        self.commandType = meshList[COMMAND_TYPE];
        self.masterName = meshList[MASTER_NAME];
        
        self.statusArray = [self getStatusArray:meshList];
        
        self.mii = [meshList[MOBILE_INTERNAL_INDEX] intValue];
        self.isSuccessful = [meshList[SUCCESS] boolValue];
        self.reason = [meshList[REASON] boolValue];
    }
    return self;
}


-(NSArray *)getStatusArray:(NSDictionary*)meshList{
    NSMutableArray *statusArray = [NSMutableArray new];
    //first object master
    [statusArray addObject:[self getStatus:meshList[MASTER_NAME] location:meshList[MASTER_NAME] connetedVia:meshList[CONNECTED_VIA] interface:meshList[INTERFACE] signalStrength:@"" ssid1:meshList[TwoGHzSSID] ssid2:meshList[FiveGHZSSID] isConnected:[meshList[CONNECTION] isEqualToString:@"Connected"] isMaster:YES]];
    
    //rest slaves
    for(NSDictionary *slave in meshList[SLAVES]){
        [statusArray addObject:[self getStatus:slave[SLAVE_NAME] location:slave[SLAVE_NAME] connetedVia:slave[CONNECTED_VIA] interface:slave[INTERFACE] signalStrength:slave[SIGNAL_STRENGTH] ssid1:meshList[TwoGHzSSID] ssid2:meshList[FiveGHZSSID] isConnected:[slave[CONNECTION] isEqualToString:@"Connected"] isMaster:NO]];
    }
    return statusArray;
}


-(AlmondStatus *)getStatus:(NSString*)name location:(NSString*)location connetedVia:(NSString*)connetedVia interface:(NSString*)interface signalStrength:(NSString*)signalStrength ssid1:(NSString*)ssid1 ssid2:(NSString*)ssid2 isConnected:(BOOL)isConnected isMaster:(BOOL)isMaster{
    AlmondStatus *stat = [AlmondStatus new];
    stat.isConnected = isConnected;
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
@end
