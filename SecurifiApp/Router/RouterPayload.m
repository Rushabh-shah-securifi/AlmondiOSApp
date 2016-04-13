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

+(void)sendRouterCommandForType:(RouterCmdType)type mii:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac version:(NSString*)version message:(NSString*)message{
    if ([almondMac isEqualToString:NO_ALMOND]) {
        return;
    }
    switch (type) {
        case RouterCmdType_RouterSummaryReq:
            if(isSimulator)
                [RouterParser sendrouterSummary];
            else
                [[SecurifiToolkit sharedInstance] asyncSendCommand:[RouterPayload routerSummary:mii]];
            break;
        case RouterCmdType_GetWirelessSettingReq:
            if(isSimulator)
                [RouterParser getWirelessSetting];
            else
                [[SecurifiToolkit sharedInstance] asyncSendCommand:[RouterPayload getWirelessSettings:mii]];
            break;
//        case RouterCmdType_SetWireLessSettingReq:
//            <#statements#>
//            break;
        case RouterCmdType_UpdateFirmware:
            if(isSimulator)
                [RouterParser updateFirmwareResponse];
            else
                [[SecurifiToolkit sharedInstance] asyncSendCommand:[RouterPayload updateFirmware:mii version:version]];
            [[Analytics sharedInstance] markRouterUpdateFirmware];
            break;

        case RouterCmdType_RebootReq:
            if(isSimulator)
                [RouterParser setRebootResponce];
            else
                [[SecurifiToolkit sharedInstance] asyncSendCommand:[RouterPayload routerReboot:mii]];
            [[Analytics sharedInstance] markRouterReboot];
            break;
        case RouterCmdType_SendLogsReq:
            if(isSimulator)
                [RouterParser setLogsResponce];
            else
                [[SecurifiToolkit sharedInstance] asyncSendCommand:[RouterPayload sendLogs:message mii:mii]];
            [[Analytics sharedInstance] markSendRouterLogs];
            break;
        default:
            break;
    }
    
}
+ (GenericCommand*)routerSummary:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@"RouterSummary" forKey:@"CommandType"];
    [payload setValue:APP_ID forKey:@"AppID"];
    [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    
    return [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST];
}

+ (GenericCommand*)getWirelessSettings:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@"GetWirelessSettings" forKey:@"CommandType"];
    [payload setValue:APP_ID forKey:@"AppID"];
    [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    
    return [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST];
}


+ (GenericCommand*)setWirelessSettings:(int)mii wirelessSettings:(SFIWirelessSetting*)wirelessSettingObj isEnabled:(BOOL)isEnabled{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@"SetWirelessSettings" forKey:@"CommandType"];
    [payload setValue:APP_ID forKey:@"AppID"];
    [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    
    NSMutableDictionary *wirelessSetting = [NSMutableDictionary new];
    [wirelessSetting setValue:wirelessSettingObj.type forKey:@"Type"];
    [wirelessSetting setValue:isEnabled?@"true":@"false" forKey:@"Enabled"];
    [wirelessSetting setValue:wirelessSettingObj.ssid forKey:@"SSID"];
    [wirelessSetting setValue:@(wirelessSettingObj.channel).stringValue forKey:@"Channel"];
    [wirelessSetting setValue:wirelessSettingObj.encryptionType forKey:@"EncryptionType"];
    [wirelessSetting setValue:wirelessSettingObj.security forKey:@"Security"];
    [wirelessSetting setValue:wirelessSettingObj.wirelessMode forKey:@"WirelessMode"];
    
    [payload setValue:wirelessSetting forKey:@"WirelessSetting"];
    
    return [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST];
}

+(GenericCommand*)updateFirmware:(int)mii version:(NSString*)version{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@"FirmwareUpdate" forKey:@"CommandType"];
    [payload setValue:APP_ID forKey:@"AppID"];
    [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setValue:@"true" forKey:@"Available"];
    [payload setValue:version forKey:@"Version"];
    
    return [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST];
}
+ (GenericCommand*)routerReboot:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@"RebootRouter" forKey:@"CommandType"];
    [payload setValue:APP_ID forKey:@"AppID"];
    [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    
    return [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST];
}

+ (GenericCommand*)sendLogs:(NSString*)message mii:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@"SendLogs" forKey:@"CommandType"];
    [payload setValue:APP_ID forKey:@"AppID"];
    [payload setValue:message forKey:@"Message"];
    [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    
    return [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST];
}


@end
