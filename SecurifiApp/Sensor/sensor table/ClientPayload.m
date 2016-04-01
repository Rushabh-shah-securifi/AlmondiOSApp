//
//  ClientPayload.m
//  SecurifiApp
//
//  Created by Masood on 01/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ClientPayload.h"

@implementation ClientPayload

+(NSDictionary*)getUpdateClientPayloadForClient:(Client*)client mobileInternalIndex:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setValue:@"UpdateClient" forKey:@"CommandType"];
    
    NSDictionary * clients = @{
                               @"ID":client.deviceID,
                               @"Name":client.name,
                               @"Connection":client.deviceConnection,
                               @"MAC":client.deviceMAC,
                               @"Type":client.deviceType,
                               @"LastKnownIP":client.deviceIP,
                               @"Active":client.isActive?@"true":@"false",
                               @"UseAsPresence":client.deviceUseAsPresence?@"true":@"false",
                               @"Wait":@(client.timeout).stringValue,
                               @"Block":@(client.deviceAllowedType).stringValue,
                               @"Schedule":client.deviceSchedule
                               //deliberaly left few keys, I think all readonly keys should be ommitted
                               };
    [payload setValue:clients forKey:@"Clients"];
    return payload;
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
