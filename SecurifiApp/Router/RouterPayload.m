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

//+(void)sendRouterCommandForType:(RouterCmdType)type mii:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac version:(NSString*)version message:(NSString*)message{
//    if ([almondMac isEqualToString:NO_ALMOND]) {
//        return;
//    }
//    switch (type) {
//        case RouterCmdType_RouterSummaryReq:
//            if(isSimulator)
//                [RouterParser sendrouterSummary];
//            else
//                [[SecurifiToolkit sharedInstance] asyncSendCommand:[RouterPayload routerSummary:mii]];
//            break;
//        case RouterCmdType_GetWirelessSettingReq:
//            if(isSimulator)
//                [RouterParser getWirelessSetting];
//            else
//                [[SecurifiToolkit sharedInstance] asyncSendCommand:[RouterPayload getWirelessSettings:mii]];
//            break;
////        case RouterCmdType_SetWireLessSettingReq:
////            <#statements#>
////            break;
//        case RouterCmdType_UpdateFirmware:
//            if(isSimulator)
//                [RouterParser updateFirmwareResponse];
//            else
//                [[SecurifiToolkit sharedInstance] asyncSendCommand:[RouterPayload updateFirmware:mii version:version]];
//            [[Analytics sharedInstance] markRouterUpdateFirmware];
//            break;
//
//        case RouterCmdType_RebootReq:
//            if(isSimulator)
//                [RouterParser setRebootResponce];
//            else
//                [[SecurifiToolkit sharedInstance] asyncSendCommand:[RouterPayload routerReboot:mii]];
//            [[Analytics sharedInstance] markRouterReboot];
//            break;
//        case RouterCmdType_SendLogsReq:
//            if(isSimulator)
//                [RouterParser setLogsResponce];
//            else
//                [[SecurifiToolkit sharedInstance] asyncSendCommand:[RouterPayload sendLogs:message mii:mii]];
//            [[Analytics sharedInstance] markSendRouterLogs];
//            break;
//        default:
//            break;
//    }
//    
//}

+ (void)routerSummary:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac{
    if(isSimulator){
        [RouterParser sendrouterSummary];
    }else{
        if ([almondMac isEqualToString:NO_ALMOND]) {
            return;
        }

        NSMutableDictionary *payload = [NSMutableDictionary new];
        [payload setValue:@"RouterSummary" forKey:@"CommandType"];
        [payload setValue:APP_ID forKey:@"AppID"];
        [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
        [payload setValue:almondMac forKey:@"AlmondMAC"];
        GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
        NSLog(@"sending router summery request %@",payload);
        [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
    }

}/*251176215905264 251176215905264*/

+ (void)getWirelessSettings:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac{
    if(isSimulator){
        [RouterParser getWirelessSetting];
    }else{
        if ([almondMac isEqualToString:NO_ALMOND]) {
            return;
        }
        NSMutableDictionary *payload = [NSMutableDictionary new];
        [payload setValue:@"GetWirelessSettings" forKey:@"CommandType"];
        [payload setValue:APP_ID forKey:@"AppID"];
        [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
        [payload setValue:almondMac forKey:@"AlmondMAC"];
        
        GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
        [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
    }
}


+ (void)setWirelessSettings:(int)mii wirelessSettings:(SFIWirelessSetting*)wirelessSettingObj isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac isTypeEnable:(BOOL)isTypeEnable{
    if(isSimulator){
        [RouterParser setWirelessSetting];
    }else{
        if ([almondMac isEqualToString:NO_ALMOND]) {
            return;
        }
        NSMutableDictionary *payload = [NSMutableDictionary new];
        [payload setValue:@"SetWirelessSettings" forKey:@"CommandType"];
        [payload setValue:APP_ID forKey:@"AppID"];
        [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
        [payload setValue:almondMac forKey:@"AlmondMAC"];
        
        NSMutableDictionary *wirelessSetting = [NSMutableDictionary new];
        NSLog(@"type: %@", wirelessSettingObj.type);
        [wirelessSetting setValue:wirelessSettingObj.type forKey:@"Type"];
        if(isTypeEnable)
            [wirelessSetting setValue:wirelessSettingObj.enabled?@"true":@"false" forKey:@"Enabled"];
        else
            [wirelessSetting setValue:wirelessSettingObj.ssid forKey:@"SSID"];
        
        [payload setValue:wirelessSetting forKey:@"WirelessSetting"];
        
        GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
        [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
    }
}
+(void)updateFirmware:(int)mii version:(NSString*)version isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac{
    if(isSimulator){
        [RouterParser updateFirmwareResponse];
    }else{
        if ([almondMac isEqualToString:NO_ALMOND]) {
            return;
        }
        NSMutableDictionary *payload = [NSMutableDictionary new];
        [payload setValue:@"FirmwareUpdate" forKey:@"CommandType"];
        [payload setValue:APP_ID forKey:@"AppID"];
        [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
        [payload setValue:@"true" forKey:@"Available"];
        [payload setValue:version forKey:@"Version"];
        [payload setValue:almondMac forKey:@"AlmondMAC"];
        
        GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
        [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
        [[Analytics sharedInstance] markRouterUpdateFirmware];
    }
}
    
+ (void)routerReboot:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac{
    if(isSimulator){
        [RouterParser setRebootResponce];
    }else{
        if ([almondMac isEqualToString:NO_ALMOND]) {
            return;
        }
        NSMutableDictionary *payload = [NSMutableDictionary new];
        [payload setValue:@"RebootRouter" forKey:@"CommandType"];
        [payload setValue:APP_ID forKey:@"AppID"];
        [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
        [payload setValue:almondMac forKey:@"AlmondMAC"];
        
        GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
        [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
        [[Analytics sharedInstance] markRouterReboot];
    }
}

+ (void)sendLogs:(NSString*)message mii:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac{
    if(isSimulator){
        [RouterParser setLogsResponce];
    }else{
        if ([almondMac isEqualToString:NO_ALMOND]) {
            return;
        }
        NSMutableDictionary *payload = [NSMutableDictionary new];
        [payload setValue:@"SendLogs" forKey:@"CommandType"];
        [payload setValue:APP_ID forKey:@"AppID"];
        [payload setValue:message forKey:@"Message"];
        [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
        [payload setValue:almondMac forKey:@"AlmondMAC"];
        
        GenericCommand *genericCmd = [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ROUTER_COMMAND_REQUEST_RESPONSE];
        [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
        [[Analytics sharedInstance] markSendRouterLogs];
    }
}


@end
