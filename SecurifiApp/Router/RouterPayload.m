//
//  RouterPayload.m
//  SecurifiApp
//
//  Created by Masood on 06/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "RouterPayload.h"
#import "RouterParser.h"
#import "Analytics.h"
#import "AlmondPlusConstants.h"

#define  APP_ID @"1001"

@implementation RouterPayload

+ (void)routerSummary:(int)mii mac:(NSString*)almondMac{

    if ([almondMac isEqualToString:NO_ALMOND]) {
        return;
    }

    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:@"RouterSummary" forKey:@"CommandType"];
    [payload setObject:APP_ID forKey:@"AppID"];
    [payload setObject:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setObject:almondMac forKey:@"AlmondMAC"];
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
    NSLog(@"sending router summery request %@",payload);
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
    

}/*251176215905264 251176215905264*/

+ (void)getWirelessSettings:(int)mii mac:(NSString*)almondMac{

    if ([almondMac isEqualToString:NO_ALMOND]) {
        return;
    }
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:@"GetWirelessSettings" forKey:@"CommandType"];
    [payload setObject:APP_ID forKey:@"AppID"];
    [payload setObject:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setObject:almondMac forKey:@"AlmondMAC"];
    
    GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
    
}
/*
 {
 "CommandType": "SetWirelessSettings",
 "AppID": "1001",
 "AlmondMAC": "251176220099140",
 "MobileInternalIndex": "4116",
 "ForceUpdate": "true",
 "WirelessSetting": {
 "Type": "5G",
 "SSID": "Almondp"
 }
 */

+ (void)setWirelessSettings:(int)mii wirelessSettings:(SFIWirelessSetting*)wirelessSettingObj mac:(NSString*)almondMac isTypeEnable:(BOOL)isTypeEnable forceUpdate:(NSString *)forceUpdate{

    if ([almondMac isEqualToString:NO_ALMOND]) {
        return;
    }
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:@"SetWirelessSettings" forKey:@"CommandType"];
    [payload setObject:APP_ID forKey:@"AppID"];
    [payload setObject:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setObject:almondMac forKey:@"AlmondMAC"];
    [payload setObject:forceUpdate forKey:@"ForceUpdate"];
    NSMutableDictionary *wirelessSetting = [NSMutableDictionary new];
    NSLog(@"type: %@", wirelessSettingObj.type);
    [wirelessSetting setObject:wirelessSettingObj.type forKey:@"Type"];
    if(isTypeEnable)
        [wirelessSetting setObject:wirelessSettingObj.enabled?@"true":@"false" forKey:@"Enabled"];
    else
        [wirelessSetting setObject:wirelessSettingObj.ssid forKey:@"SSID"];
    
    [payload setObject:wirelessSetting forKey:@"WirelessSetting"];
    
    GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
    
}
+(void)updateFirmware:(int)mii version:(NSString*)version mac:(NSString*)almondMac{
    if ([almondMac isEqualToString:NO_ALMOND]) {
        return;
    }
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:@"FirmwareUpdate" forKey:@"CommandType"];
    [payload setObject:APP_ID forKey:@"AppID"];
    [payload setObject:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setObject:@"true" forKey:@"Available"];
    [payload setObject:version forKey:@"Version"];
    [payload setObject:almondMac forKey:@"AlmondMAC"];
    
    GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
    [[Analytics sharedInstance] markRouterUpdateFirmware];
    
}
    
+ (void)routerReboot:(int)mii mac:(NSString*)almondMac{
    if ([almondMac isEqualToString:NO_ALMOND]) {
        return;
    }
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:@"RebootRouter" forKey:@"CommandType"];
    [payload setObject:APP_ID forKey:@"AppID"];
    [payload setObject:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setObject:almondMac forKey:@"AlmondMAC"];
    
    GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
    [[Analytics sharedInstance] markRouterReboot];
    
}

+ (void)sendLogs:(NSString*)message mii:(int)mii mac:(NSString*)almondMac{
    if ([almondMac isEqualToString:NO_ALMOND]) {
        return;
    }
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:@"SendLogs" forKey:@"CommandType"];
    [payload setObject:APP_ID forKey:@"AppID"];
    [payload setObject:message forKey:@"Message"];
    [payload setObject:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setObject:almondMac forKey:@"AlmondMAC"];
    
    GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
    [[Analytics sharedInstance] markSendRouterLogs];
    
}

//{"CommandType":"ChangeAlmondProperties","WebAdminPassword":"<Encrypted Pass>","Uptime":"105", "MobileInternalIndex":"78"}
+(void)requestAlmondPropertyChange:(int)mii action:(NSString*)action value:(NSString *)value uptime:(NSString *)uptime{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setObject:@"ChangeAlmondProperties" forKey:@"CommandType"];
    [payload setObject:value forKey:action];
    [payload setObject:@(mii).stringValue forKey:@"MobileInternalIndex"];
    if(uptime)
        [payload setObject:uptime forKey:@"Uptime"];
    
    GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_REQUEST];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
}

@end
