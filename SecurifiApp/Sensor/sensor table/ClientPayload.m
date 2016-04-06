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

+(GenericCommand*)getUpdateClientPayloadForClient:(Client*)client mobileInternalIndex:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue: UPDATE_CLIENT forKey:@"CommandType"];
    
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
                               SCHEDULE:client.deviceSchedule
                               //deliberaly left few keys, I think all readonly keys should be ommitted
                               };
    [payload setValue:clients forKey:CLIENTS];
    
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_CLIENT;
    command.command = [payload JSONString];
    return command;
}


//"{
//""MobileInternalIndex"":""<random key>"",
//""CommandType"":""UpdateClient"",
//""Clients"":{
//    ""ID"":""2"",
//    ""Name"":""device1"",
//    ""Connection"":""wired"",
//    ""MAC"":""00:17:88:0a:04:41"",
//    ""Type"":""tv"",
//    ""LastKnownIP"":""10.2.2.11"",
//    ""Active"":""false"",
//    ""UseAsPresence"":""false"",
//    ""Wait"":""6"",""RX"":""121212121"",
//    ""TX"":""4232"",
//    ""Block"":""1""
//    ""Schedule"":""0,ffffff,0,0,0,0,0"",
//    ""Manufacturer"":""AsusTek"",
//    ""RSSI"":""-43"",
//    ""ForceInactive"":""0""
//}
//}"

@end
