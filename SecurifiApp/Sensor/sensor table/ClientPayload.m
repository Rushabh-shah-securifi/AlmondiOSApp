//
//  ClientPayload.m
//  SecurifiApp
//
//  Created by Masood on 01/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ClientPayload.h"
#import "AlmondJsonCommandKeyConstants.h"

@implementation ClientPayload
+ (void)clientListCommand{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    //forboth cloud and local
    GenericCommand *genericCmd = [GenericCommand requestAlmondClients:toolkit.currentAlmond.almondplusMAC];
    [toolkit asyncSendCommand:genericCmd];
}

+(void)getUpdateClientPayloadForClient:(Client*)client mobileInternalIndex:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:UPDATE_CLIENT forKey:@"CommandType"];
    [payload setValue:toolkit.currentAlmond.almondplusMAC forKey:@"AlmondMAC"];
    
    NSDictionary * clients = @{
                               C_ID:client.deviceID,
                               CLIENT_NAME:client.name,
                               CONNECTION:client.deviceConnection,
                               MAC:client.deviceMAC,
                               CLIENT_TYPE:client.deviceType,
                               LAST_KNOWN_IP:client.deviceIP,
                               ACTIVE:client.isActive?@"true":@"false",
                               USE_AS_PRESENCE:client.deviceUseAsPresence?@"true":@"false",
                               WAIT:@(client.timeout).stringValue,
                               BLOCK:@(client.deviceAllowedType).stringValue,
                               SCHEDULE:client.deviceSchedule,
                               CATEGORY:client.category
                               //deliberaly left out few keys, I think all readonly keys should be ommitted
                               };
    [payload setValue:clients forKey:CLIENTS];
//    NSLog(@"client payload: %@", payload);
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_REQUEST];
    [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
}

@end
