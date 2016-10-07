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
    NSDictionary *payload = @{
                                  @"CommandMode":@"Request",
                                  @"CommandType":@"CheckForAddableWiredSlaveMobile",
                                  @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestCheckForAddableWirelessSlave:(int)mii{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"CheckForAddableWirelessSlaveMobile",
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestAddWiredSlave:(int)mii slaveName:(NSString *)slaveName{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"AddWiredSlaveMobile",
                              @"SlaveUniqueName":slaveName,
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestAddWireLessSlave:(int)mii slaveName:(NSString *)slaveName{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"AddWirelessSlaveMobile",
                              @"SlaveUniqueName":slaveName,
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestBlinkLed:(int)mii slaveName:(NSString *)slaveName{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"BlinkLedMobile",
                              @"SlaveUniqueName":slaveName,
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}



+(void)requestSetSlaveName:(int)mii uniqueSlaveName:(NSString *)uniqueSlaveName newName:(NSString *)newName{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"SetSlaveNameMobile",
                              @"SlaveUniqueName":uniqueSlaveName,
                              @"SlaveNewName":newName,
                              @"MobileInternalIndex":@(mii).stringValue

                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestRemoveSlave:(int)mii uniqueName:(NSString*)uniqueName{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"RemoveSlaveMobile",
                              @"SlaveUniqueName":uniqueName,
                              @"MobileInternalIndex":@(mii).stringValue
                              
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestForceRemoveSlave:(int)mii uniqueName:(NSString*)uniqueName{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"ForceRemoveSlaveMobile",
                              @"SlaveUniqueName":uniqueName,
                              @"MobileInternalIndex":@(mii).stringValue
                              
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}
+(void)requestSlaveDetails:(int)mii slaveUniqueName:(NSString*)uniqueName{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"SlaveDetailsMobile",
                              @"SlaveUniqueName":uniqueName,
                              @"MobileInternalIndex":@(mii).stringValue
                              
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestRai2UpMobile:(int)mii{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"Rai2UpMobile",
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)requestRai2DownMobile:(int)mii{
    NSDictionary *payload = @{
                              @"CommandMode":@"Request",
                              @"CommandType":@"Rai2DownMobile",
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    [self sendRequest:payload commandType:CommandType_UPDATE_REQUEST];
}

+(void)sendRequest:(NSDictionary *)payload commandType:(enum CommandType)commandType{
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:commandType];
    genericCmd.isMeshCmd = YES;
    [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
}
@end
