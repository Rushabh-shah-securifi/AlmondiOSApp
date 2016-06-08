//
//  ClientPayload.m
//  SecurifiApp
//
//  Created by Masood on 01/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ClientPayload.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "KeyChainWrapper.h"

#define SEC_SERVICE_NAME                                    @"securifiy.login_service"
#define SEC_EMAIL                                           @"com.securifi.email"

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
    
    if(![self hasCompleteData:client])
        return;
    
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

+(BOOL)hasCompleteData:(Client*)client{
    if(client.deviceID == nil || client.name == nil || client.deviceConnection == nil || client.deviceMAC == nil || client.deviceType == nil ||client.deviceIP == nil || client.deviceSchedule == nil || client.category== nil){
        return NO;
    }
    return YES;
}

+ (void)resetClientCommand:(NSString *)mac clientID:(NSString*)clientID mii:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:@"RemoveClient" forKey:@"CommandType"];
    [payload setValue:toolkit.currentAlmond.almondplusMAC forKey:@"AlmondMAC"];
    NSDictionary *RemoveClient = @{
                                   MAC : mac,
                                   C_ID : clientID
                                   };
    
    [payload setValue:RemoveClient forKey:CLIENTS];
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_REQUEST];
    [toolkit asyncSendCommand:genericCmd];
}

+ (void)clientDidChangeNotificationSettings:(Client*)client mii:(int)mii newValue:(NSString*)notificaionVal{
    NSMutableDictionary * updateClientInfo = [NSMutableDictionary new];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSString *userID = [KeyChainWrapper retrieveEntryForUser:SEC_EMAIL forService:SEC_SERVICE_NAME];
    
    [updateClientInfo setValue:@"UpdatePreference" forKey:@"CommandType"];
    [updateClientInfo setValue:client.deviceID forKey:@"ClientID"];
    [updateClientInfo setValue:notificaionVal forKey:@"NotificationType"];
    [updateClientInfo setValue:userID forKey:@"UserID"];
    
    
    [updateClientInfo setValue:toolkit.currentAlmond.almondplusMAC forKey:@"AlmondMAC"];
    [updateClientInfo setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    
    GenericCommand *cloudCommand = [GenericCommand jsonStringPayloadCommand:updateClientInfo commandType:CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST];
    
    [toolkit asyncSendCommand:cloudCommand];
}


/*
 {
 "CommandType":"RemoveClient",
 "Clients":{ "ID": "1",
 "MAC": "1c:75:08:32:2a:6d"},
 "AlmondMAC": "251176214925585",
 "MobileInternalIndex":"324"
 }
 */
@end
