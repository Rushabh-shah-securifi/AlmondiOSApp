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
    [payload setValue:genericIndexValue.genericValue.toggleValue forKey:@"Value"];
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
