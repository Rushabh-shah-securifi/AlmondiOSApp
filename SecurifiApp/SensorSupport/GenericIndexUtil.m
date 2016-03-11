//
//  GenericIndexUtil.m
//  SecurifiApp
//
//  Created by Masood on 11/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericIndexUtil.h"
#import "SecurifiToolkit.h"
#import "Device.h"

@implementation GenericIndexUtil

+ (void)testGeenricIndexUtil{
    NSLog(@"getGenericIndexValueForID: %@", [self getGenericIndexValueForID:1 index:1 value:@"true"]);
    NSLog(@"getGenericIndexJsonForDeviceId: %@", [self getGenericIndexJsonForDeviceId:1 index:1]);
    NSLog(@"getGenericIndexValueForGenericIndex: %@", [self getGenericIndexValueForGenericIndex:@"2" value:@"false"]);
}

+(NSDictionary*)getGenericIndexValueForID:(sfi_id)deviceId index:(int)index value:(NSString*)value{
    NSDictionary *genericIndexJson = [self getGenericIndexJsonForDeviceId:deviceId index:index];
    NSDictionary *values = genericIndexJson[@"Values"];
    return values[value];
}

+(NSDictionary *)getGenericIndexJsonForDeviceId:(sfi_id) deviceID index:(int) index{
    Device *device = [Device getDeviceForID:deviceID];
    if(device){
        int deviceType = 1;
        NSDictionary *deviceJson = [self getDeviceJsonForType:deviceType];
        NSDictionary *indexes = deviceJson[@"Indexes"];
        NSArray *indexesKeys = indexes.allKeys;
        for(NSString *key in indexesKeys){
            if(key.intValue == index){
                NSDictionary *indexValDict = indexes[key];
                return [self getGenericIndexJsonForIndex:indexValDict[@"genericIndexID"]];
            }
        }
    }
    return nil;
}

+(NSDictionary*)getGenericIndexValueForGenericIndex:(NSString*)genericIndex value:(NSString*)value{
    NSDictionary *genericIndexJson = [self getGenericIndexJsonForIndex:genericIndex];
    NSDictionary *values = genericIndexJson[@"Values"];
    return values[value];
}


+(NSDictionary*)getDeviceJsonForType:(int)type{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSDictionary *devicesJson = toolkit.devicesJSON;
    NSArray *devicesJsonKeys = devicesJson.allKeys;
    for(NSString *deviceTypeKey in devicesJsonKeys){
        if(deviceTypeKey.intValue == type){
            return devicesJson[deviceTypeKey];
        }
    }
    return nil;
}

+(NSDictionary*)getGenericIndexJsonForIndex:(NSString*)genericIndex{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSDictionary *genericIndexesJson = toolkit.indexesJSON;
    NSArray *indexKeys = genericIndexesJson.allKeys;
    for(NSString *genericIndexKey in indexKeys){
        if(genericIndexKey.intValue == genericIndex.intValue){
            return genericIndexesJson[genericIndexKey];
        }
    }
    return nil;
}

/*
{//devices json
    "1": {
        "name": "Binary Switch",
        "defaultIcon": "@drawable/switch_off_new",
        "isActionDevice": "true",
        "isActuator": "true",
        "isTriggerDevice": "true",
        "Indexes": {
            "1": {
                "row_no": "1",
                "genericIndexID": "1"
            }
        }
    },
    "2":{
        "name":"Multilevel Switch",
        "defaultIcon":"@drawable/dimmer",
        "isActionDevice":"true",
        "isActuator":"true",
        "isTriggerDevice":"true",
        "Indexes": {
            "1": {
                "row_no": "1",
                "genericIndexID": "17"
            }
        }
 }
 */
/*
{//Generic index json
    "1": {
        "Name": "SWITCH BINARY",
        "Type": "Actuator",
        "DataType": "Bool",
        "ReadOnly": "false",
        "Placement": "Header",
        "Layout": "Toggle",
        "GroupLabel": "SWITCH",
        "Conditional": "false",
        "DefaultVisibility": "true",
        "HasToggleIcon": "true",
        "DefaultIcon": "switchon",
        "Values": {
            "true": {
                "ToggleValue": "false",
                "Icon": "switchon",
                "Label": "ON"
            },
            "false": {
                "ToggleValue": "false",
                "Icon": "switchoff",
                "Label": "OFF"
            }
        }
    },
    "2": {
        "Name": "SENSOR BINARY",
        "Type": "Sensor",
        "DataType": "Bool",
        "ReadOnly": "true",
        "Placement": "Header",
        "Layout": "Toggle",
        "GroupLabel": "SENSOR",
        "Conditional": "false",
        "DefaultVisibility": "true",
        "HasToggleIcon": "false",
        "ExcludeFrom": "scene",
        "DefaultIcon": "binarysensoron",
        "Values": {
            "true": {
                "ToggleValue": "NaN",
                "Icon": "binarysensoron",
                "Label": "ACTIVE"
            },
            "false": {
                "ToggleValue": "NaN",
                "Icon": "binarysensoroff",
                "Label": "INACTIVE"
            }
        }
    }
}*/

@end
