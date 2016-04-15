//
//  DevicePayload.m
//  SecurifiApp
//
//  Created by Masood on 22/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DevicePayload.h"
#import "AlmondJsonCommandKeyConstants.h"

@implementation DevicePayload

+ (void)deviceListCommand{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericCommand *genericCmd = [GenericCommand requestSensorDeviceList:toolkit.currentAlmond.almondplusMAC];
    [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
}

+(void)getSensorIndexUpdate:(GenericIndexValue*)genericIndexValue mii:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:UPDATE_DEVICE_INDEX forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:D_ID];
    [payload setValue:@(genericIndexValue.index).stringValue forKey:INDEX];
    [payload setValue:genericIndexValue.genericValue.toggleValue forKey:VALUE];
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_DEVICE_INDEX];
    [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
}

//have to combile both methods
+(void)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:UPDATE_DEVICE_INDEX forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:D_ID];
    [payload setValue:@(genericIndexValue.index).stringValue forKey:INDEX];
    [payload setValue:value forKey:VALUE];
    
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_DEVICE_INDEX];
    [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
}

/*
 
 "{
 ""MobileInternalIndex"":""<random key>"",
 ""CommandType"":""UpdateDeviceName"",
 ""ID"":""6"",
 ""Name"":""newswitchsss"",
 ""Location"":""default""
 }"
 
 */
+(void)getNameLocationChange:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value{
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    DeviceCommandType deviceCmdType = genericIndexValue.genericIndex.commandType;
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:UPDATE_DEVICE_NAME forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:D_ID];
    if(deviceCmdType == DeviceCommand_UpdateDeviceName)
        [payload setValue:value forKey:INDEX_NAME];//will replace by @"Name"
    else
    [payload setValue:value forKey:LOCATION];
    
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_DEVICE_NAME];
    [[SecurifiToolkit sharedInstance] asyncSendCommand:genericCmd];
}


@end

/*
 {
 "MobileInternalIndex":"<random key>",
 "CommandType":"UpdateDeviceIndex",
 "ID":"3",
 "Index":"1",
 "Value":"false"
 }
 
 */
