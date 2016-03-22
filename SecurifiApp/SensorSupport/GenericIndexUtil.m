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
#import "GenericDeviceClass.h"
#import "GenericIndexClass.h"
#import "GenericValue.h"
#import "DeviceIndex.h"
#import "Formatter.h"
#import "GenericIndexValue.h"
#import "AlmondJsonCommandKeyConstants.h"

@implementation GenericIndexUtil


+(GenericProperties*)getHeaderGenericPropertiesForDevice:(Device*)device{
    NSArray *genericIndexValues = [self getGenericIndexValuesByPlacementForDevice:device placement:HEADER];
    NSString *headerText = @"";
    NSString *detailText = @"";
    int index = 0;
    GenericValue *genericValue;
    for(GenericIndexValue *genericIndexValue in genericIndexValues){
        if(genericIndexValue.genericValue == nil)
            continue;
        if([genericIndexValue.genericIndex.placement isEqualToString:HEADER]){
            headerText = genericIndexValue.genericValue.displayText;
            genericValue = genericIndexValue.genericValue;
            index = genericIndexValue.index;
        }else if([genericIndexValue.genericIndex.placement isEqualToString:DETAIL_HEADER]){
            if(genericIndexValue.genericValue.iconText)
                detailText = [NSString stringWithFormat:@"%@ %@", genericIndexValue.genericIndex.groupLabel, genericIndexValue.genericValue.icon];
            else
                detailText = genericIndexValue.genericValue.displayText;
        }
    }
    if(genericValue == nil)
        genericValue = [GenericValue new];
    if(detailText.length > 0)
        genericValue = [[GenericValue alloc]initWithGenericValue:genericValue text:[NSString stringWithFormat:@"%@ %@", headerText, detailText]];
    
    return [[GenericProperties alloc]initWithDeviceID:device.ID index:index genericValue:genericValue];
}

+(NSMutableArray*)getGenericIndexValuesByPlacementForDevice:(Device*)device placement:(NSString*)placement{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericDeviceClass *genericDevice = toolkit.genericDevices[@(device.type).stringValue];
    NSDictionary *deviceIndexes = genericDevice.Indexes;
    NSMutableArray *genericIndexValues = [NSMutableArray new];
    for(NSString *IndexId in deviceIndexes.allKeys){
        DeviceIndex *deviceIndex = deviceIndexes[IndexId];
        GenericIndexClass *genericIndexObj = toolkit.genericIndexes[deviceIndex.genericIndex];
        if([genericIndexObj.placement rangeOfString:placement options:NSCaseInsensitiveSearch].location != NSNotFound){
            NSLog(@"genericindex: %@", deviceIndex.genericIndex);
            GenericValue *genericValue = [self getMatchingGenericValueForGenericIndexID:genericIndexObj.ID
                                                                               forValue:[self getHeaderValueFromKnownValuesForDevice:device indexID:IndexId]];
            [genericIndexValues addObject:[[GenericIndexValue alloc]initWithGenericIndex:genericIndexObj genericValue:genericValue index:IndexId.intValue]];
        }
    }
    return genericIndexValues;
}

//
+(NSString*) getHeaderValueFromKnownValuesForDevice:(Device*)device indexID:(NSString*)indexID{
    for(DeviceKnownValues *knownValue in device.knownValues){
        if(knownValue.index == indexID.intValue){
            return knownValue.value;
        }
    }
    return nil;
}

+(GenericValue*)getMatchingGenericValueForGenericIndexID:(NSString*)genericIndexID forValue:(NSString*)value{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericIndexClass *genericIndexObject = toolkit.genericIndexes[genericIndexID];
    if(genericIndexObject == nil || value == nil)
        return nil;
    else if(genericIndexObject.values != nil){
        return genericIndexObject.values[value];
    }
    else if(genericIndexObject.formatter != nil){
        GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:[genericIndexObject.formatter transform:value] iconText:[genericIndexObject.formatter transform:value] value:value];
        return genericValue;
    }
    return [[GenericValue alloc]initWithDisplayText:nil iconText:value value:value];
}

+ (NSMutableArray *)getDetailListForDevice:(Device*)device{
    NSMutableArray *detailList = [self getGenericIndexValuesByPlacementForDevice:device placement:@"Detail"];
    NSArray *commonList = [self getCommonGenericIndexValue:device];
    [detailList addObject:commonList];
    return detailList;
}

+ (NSArray*)getCommonGenericIndexValue:(Device*)device{
    NSMutableArray *genericIndexValues = [NSMutableArray new];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSDictionary *commonIndexDict = [self createCommonIndexes];
    
    for(NSString *key in [NSDictionary new].allKeys){
        int genericIndex = [[commonIndexDict valueForKey:key] intValue];
        NSString *value = [key isEqualToString:@"Name"]? device.name: device.location;
        GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:value value:value];
        GenericIndexClass *genIndexObj = toolkit.genericIndexes[@(genericIndex).stringValue];
        [genericIndexValues addObject:[[GenericIndexValue alloc]initWithGenericIndex:genIndexObj genericValue:genericValue index:0]];
    }
    return genericIndexValues;
}

+(NSDictionary*)createCommonIndexes{
    return @{@"Name":@"-1", @"Location":@"-2", @"NotifyMe":@"-3"};
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
