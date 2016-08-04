//
//  MeshPayload.m
//  SecurifiApp
//
//  Created by Masood on 7/29/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MeshPayload.h"

@implementation MeshPayload

+(void)requestMestList:(int)mii{
    
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"MeshList",
                              @"MobileInternalIndex":@(mii).stringValue
                              };

    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestCheckForAddableWiredSlave:(int)mii{
    NSDictionary *payload = @{
                                  @"CommandMode":@"Request",
                                  @"CommandType":@"CheckForAddableWiredSlave",
                                  @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_MESH_COMMAND];
}

+(void)requestCheckForAddableWirelessSlave:(int)mii{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"CheckForAddableWirelessSlave",
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_MESH_COMMAND];
}

+(void)requestAddWiredSlave:(int)mii slaveName:(NSString *)slaveName{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"AddWiredSlave",
                              @"SlaveUniqueName":slaveName,
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_MESH_COMMAND];
}

+(void)requestAddWireLessSlave:(int)mii slaveName:(NSString *)slaveName{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"AddWirelessSlave",
                              @"SlaveUniqueName":slaveName,
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_MESH_COMMAND];
}

+(void)requestBlinkLed:(int)mii slaveName:(NSString *)slaveName{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"BlinkLed",
                              @"SlaveUniqueName":slaveName,
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_MESH_COMMAND];
}



+(void)requestSetSlaveName:(int)mii{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"SetSlaveName",
                              @"SlaveUniqueName":@"Almond2103",
                              @"SlaveNewName":@"Family Room",
                              @"MobileInternalIndex":@(mii).stringValue

                              };
    [self sendRequest:payload commandType:CommandType_MESH_COMMAND];
}
/*
 {
 "CommandMode":"Request",
 "CommandType":"RemoveSlave",
 "SlaveUniqueName":"Almond123",
 "MobileInternalIndex":"ttWsbWY91duqYuxOz2v5C2IrGFCm65Yz"
 }
 */
+(void)requestRemoveSlave{
    
}
+(void)sendRequest:(NSDictionary *)payload commandType:(enum CommandType)commandType{
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:commandType];
    genericCmd.isMesh = YES;
    [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
}
@end
