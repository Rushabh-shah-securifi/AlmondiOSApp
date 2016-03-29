//
//  DevicePayload.m
//  SecurifiApp
//
//  Created by Masood on 22/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DevicePayload.h"

@implementation DevicePayload

+(NSDictionary*)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setValue:@"UpdateDeviceIndex" forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:@"ID"];
    [payload setValue:@(genericIndexValue.index).stringValue forKey:@"Index"];
    if(genericIndexValue.genericValue.toggleValue)
    [payload setValue:genericIndexValue.genericValue.toggleValue forKey:@"Value"];
    return payload;
}

+(NSDictionary*)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setValue:@"UpdateDeviceIndex" forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:@"ID"];
    [payload setValue:@(genericIndexValue.index).stringValue forKey:@"Index"];
    if(genericIndexValue.genericValue.toggleValue)
        [payload setValue:value forKey:@"Value"];
    return payload;
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
+(NSDictionary*)getNameLocationChangePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii name:(NSString*)name location:(NSString*)location{
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:@"MobileInternalIndex"];
    [payload setValue:@"UpdateDeviceName" forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:@"ID"];
    [payload setValue:name forKey:@"Name"];
    [payload setValue:location forKey:@"Location"];
    return payload;
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
