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

+(GenericCommand*)getSensorIndexUpdate:(GenericIndexValue*)genericIndexValue mii:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:UPDATE_DEVICE_INDEX forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:D_ID];
    [payload setValue:@(genericIndexValue.index).stringValue forKey:INDEX];
    [payload setValue:genericIndexValue.genericValue.toggleValue forKey:VALUE];
    
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_DEVICE_INDEX;
    command.command = [payload JSONString];
    return command;
}

//have to combile both methods
+(GenericCommand*)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:UPDATE_DEVICE_INDEX forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:D_ID];
    [payload setValue:@(genericIndexValue.index).stringValue forKey:INDEX];
    [payload setValue:value forKey:VALUE];
    
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_DEVICE_INDEX;
    command.command = [payload JSONString];
    return command;
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
+(GenericCommand*)getNameLocationChange:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value{
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    DeviceCommandType deviceCmdType = genericIndexValue.genericIndex.commandType;
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:UPDATE_DEVICE_NAME forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:D_ID];
    if(deviceCmdType == DeviceCommand_UpdateDeviceName)
        [payload setValue:value forKey:INDEX_NAME];//will replace by @"Name"
    else
    [payload setValue:value forKey:LOCATION];
    
    GenericCommand *command = [[GenericCommand alloc] init];
    command.commandType = CommandType_UPDATE_DEVICE_NAME;
    command.command = [payload JSONString];
    return command;
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
