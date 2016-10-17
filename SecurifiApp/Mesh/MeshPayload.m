//
//  MeshPayload.m
//  SecurifiApp
//
//  Created by Masood on 7/29/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MeshPayload.h"

@implementation MeshPayload

+(void)requestCheckForAddableWiredSlave:(int)mii{
    NSString *almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
    NSDictionary *payload = @{
                                  @"CommandMode":@"Request",
                                  @"CommandType":@"CheckForAddableWiredSlaveMobile",
                                  @"AlmondMAC" : almondMac? almondMac: @"",
                                  @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestCheckForAddableWirelessSlave:(int)mii{
    NSString *almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"CheckForAddableWirelessSlaveMobile",
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestAddWiredSlave:(int)mii slaveName:(NSString *)slaveName{
    NSString *almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"AddWiredSlaveMobile",
                              @"SlaveUniqueName":slaveName,
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestAddWireLessSlave:(int)mii slaveName:(NSString *)slaveName{
    NSString *almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"AddWirelessSlaveMobile",
                              @"SlaveUniqueName":slaveName,
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestBlinkLed:(int)mii slaveName:(NSString *)slaveName{
    NSString *almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"BlinkLedMobile",
                              @"SlaveUniqueName":slaveName,
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}



+(void)requestSetSlaveName:(int)mii uniqueSlaveName:(NSString *)uniqueSlaveName newName:(NSString *)newName{
    NSString *almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"SetSlaveNameMobile",
                              @"SlaveUniqueName":uniqueSlaveName,
                              @"SlaveNewName":newName,
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"MobileInternalIndex":@(mii).stringValue

                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestRemoveSlave:(int)mii uniqueName:(NSString*)uniqueName{
    NSString *almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"RemoveSlaveMobile",
                              @"SlaveUniqueName":uniqueName,
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"MobileInternalIndex":@(mii).stringValue
                              
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestForceRemoveSlave:(int)mii uniqueName:(NSString*)uniqueName{
    NSString *almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"ForceRemoveSlaveMobile",
                              @"SlaveUniqueName":uniqueName,
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"MobileInternalIndex":@(mii).stringValue
                              
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}
+(void)requestSlaveDetails:(int)mii slaveUniqueName:(NSString*)uniqueName almondMac:(NSString *)almondMac{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"SlaveDetailsMobile",
                              @"SlaveUniqueName":uniqueName,
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"MobileInternalIndex":@(mii).stringValue
                              
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)stopBlinkLed:(int)mii{
    NSString *almondMac = [[SecurifiToolkit sharedInstance] currentAlmond].almondplusMAC;
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"StopBlinkLedMobile",
                              @"AlmondMAC" : almondMac? almondMac: @"",
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)sendRequest:(NSDictionary *)payload commandType:(enum CommandType)commandType{
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:commandType];
    genericCmd.isMeshCmd = YES;
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
}
@end
