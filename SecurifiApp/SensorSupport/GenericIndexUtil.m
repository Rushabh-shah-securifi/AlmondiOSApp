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
#import "DeviceKnownValues.h"

//devices json
#define INDEXES @"Indexes"
#define GENERIC_INDEX_ID @"genericIndexID"

//generic index
#define VALUES @"Values"
#define PLACEMENT @"Placement"
#define HEADER @"Header"
#define ICON @"Icon"
#define LABEL @"Label"

@implementation GenericIndexUtil

+ (void)testGeenricIndexUtil{
    NSLog(@"getGenericIndexValueForID: %@", [self getGenericIndexValueForID:1 index:1 value:@"true"]);
    NSLog(@"getGenericIndexJsonForDeviceId: %@", [self getGenericIndexJsonForDeviceId:1 index:1]);
    NSLog(@"getGenericIndexValueForGenericIndex: %@", [self getGenericIndexValueForGenericIndex:@"2" value:@"false"]);
}

+(NSDictionary*)getGenericIndexValueForID:(sfi_id)deviceId index:(int)index value:(NSString*)value{
    NSDictionary *genericIndexJson = [self getGenericIndexJsonForDeviceId:deviceId index:index];
    NSDictionary *values = genericIndexJson[VALUES];
    return values[value];
}

+(NSDictionary *)getGenericIndexJsonForDeviceId:(sfi_id) deviceID index:(int) index{
    Device *device = [Device getDeviceForID:deviceID];
    if(device){
        int deviceType = device.type;
        NSDictionary *deviceJson = [self getDeviceJsonForType:deviceType];
        NSDictionary *indexes = deviceJson[INDEXES];
        NSArray *indexesKeys = indexes.allKeys;
        for(NSString *key in indexesKeys){
            if(key.intValue == index){
                NSDictionary *indexValDict = indexes[key];
                return [self getGenericIndexJsonForIndex:indexValDict[GENERIC_INDEX_ID]];
            }
        }
    }
    return nil;
}

+(NSDictionary*)getGenericIndexValueForGenericIndex:(NSString*)genericIndex value:(NSString*)value{
    NSDictionary *genericIndexJson = [self getGenericIndexJsonForIndex:genericIndex];
    NSDictionary *values = genericIndexJson[VALUES];
    return values[value];
}


+ (NSDictionary*)getDeviceJsonForType:(int)type{
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

+ (NSMutableArray*)getGenericIndexesForDevice:(Device*)device{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSMutableArray *sortedGenericIndexes = [NSMutableArray new];
    NSDictionary *deviceJson = [self getDeviceJsonForType:device.type];
    NSDictionary *indexes = deviceJson[INDEXES];
    NSArray *indexesKeys = indexes.allKeys;
    NSArray *sortedPostKeys = [indexesKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];
    NSLog(@"sorted keys: %@", sortedPostKeys);
    for(NSString *sortedIndex in sortedPostKeys){
        NSDictionary *indexValDict = indexes[sortedIndex];
        NSLog(@" ondexValDict %@",indexValDict);
        NSLog(@"genericindex: %@", toolkit.genericIndexesJson[indexValDict[GENERIC_INDEX_ID]]);
        [sortedGenericIndexes addObject:toolkit.genericIndexesJson[indexValDict[GENERIC_INDEX_ID]]];
    }
    return sortedGenericIndexes;
}

+ (NSDictionary*)getGenericIndexJsonForIndex:(NSString*)genericIndex{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSDictionary *genericIndexesJson = toolkit.genericIndexesJson;
    NSArray *indexKeys = genericIndexesJson.allKeys;
    for(NSString *genericIndexKey in indexKeys){
        if(genericIndexKey.intValue == genericIndex.intValue){
            return genericIndexesJson[genericIndexKey];
        }
    }
    return nil;
}

+ (NSString*)getHeaderGenericIndexForDevice:(Device*)device{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    for(DeviceKnownValues *knownValue in device.knownValues){
        NSDictionary *genericIndex = toolkit.genericIndexesJson[@(knownValue.genericIndex).stringValue];
        if([genericIndex[PLACEMENT] isEqualToString:@"Header"]){
            return @(knownValue.genericIndex).stringValue;
            
        }
    }
    return nil;
}

+ (NSString *)getIconImageFromGenericIndexDic:(NSDictionary *)genericIndexDict forValue:(NSString*)value{
    return [[genericIndexDict[VALUES] valueForKey:value] valueForKey:ICON];
}

+ (NSString *)getLabelValueFromGenericIndexDict:(NSDictionary *)genericIndexDict forValue:(NSString*)value{
    return [[genericIndexDict[VALUES] valueForKey:value] valueForKey:LABEL];
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
