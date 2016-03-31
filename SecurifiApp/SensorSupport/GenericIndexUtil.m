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
#import "Client.h"

@implementation GenericIndexUtil


+(GenericIndexValue*)getHeaderGenericIndexValueForDevice:(Device*)device{
    NSArray *genericIndexValues = [self getGenericIndexValuesByPlacementForDevice:device placement:HEADER];
    NSString *headerText = @"";
    NSString *detailText = @"";
    int index = 0;
    GenericValue *genericValue;
    GenericIndexClass *genericIndex;
    for(GenericIndexValue *genericIndexValue in genericIndexValues){
        if(genericIndexValue.genericValue == nil)
            continue;
        if([genericIndexValue.genericIndex.placement isEqualToString:HEADER]){
            headerText = genericIndexValue.genericValue.displayText;
            genericValue = genericIndexValue.genericValue;
            genericIndex = genericIndexValue.genericIndex;
            if(genericIndexValue.genericValue.icon.length == 0)
                headerText = @"";
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
//    return [[GenericProperties alloc]initWithDeviceID:device.ID index:index genericValue:genericValue];
    return [[GenericIndexValue alloc]initWithGenericIndex:genericIndex genericValue:genericValue index:index deviceID:device.ID];
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
            [genericIndexValues addObject:[[GenericIndexValue alloc]initWithGenericIndex:genericIndexObj genericValue:genericValue index:IndexId.intValue deviceID:device.ID]];
        }
    }
    return genericIndexValues;
}

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

+ (NSMutableArray *)getDetailListForDevice:(int)deviceID{
    Device *device = [Device getDeviceForID:deviceID];
    
    NSMutableArray *detailList = [self getGenericIndexValuesByPlacementForDevice:device placement:@"Detail"];
    NSArray *commonList = [self getCommonGenericIndexValue:device];
    [detailList addObjectsFromArray:commonList];
    return detailList;
}

+ (NSArray*)getCommonGenericIndexValue:(Device*)device{
    NSMutableArray *genericIndexValues = [NSMutableArray new];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSDictionary *commonIndexDict = [Device getCommonIndexesDict];
    
    NSArray *orderedKeys = [commonIndexDict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2];
    }];
    
    for(NSString *key in orderedKeys){
        int genericIndex = [[commonIndexDict valueForKey:key] intValue];
        NSString *value;
        if([key isEqualToString:@"Name"]){
            value = device.name;
        }else if([key isEqualToString:@"Location"]){
            value = device.location;
        }else{//notifyme
//            value = device.
        }
        GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:value value:value];
        GenericIndexClass *genIndexObj = toolkit.genericIndexes[@(genericIndex).stringValue];
        [genericIndexValues addObject:[[GenericIndexValue alloc]initWithGenericIndex:genIndexObj genericValue:genericValue index:0 deviceID:device.ID]];
    }
    
    return genericIndexValues;
}

+ (GenericIndexValue *) getClientHeaderGenericIndexValueForClient:(Client*) client{
    NSString *status = client.deviceAllowedType==1 ? BLOCKED: client.isActive? ACTIVE: INACTIVE;
    GenericValue *genericValue = [self getMatchingGenericValueForGenericIndexID:@"-12" forValue:client.deviceType];
    if(genericValue == nil){ //if devicetype is wronglysent only expected return is nil
        genericValue = [[GenericValue alloc]initWithDisplayText:status icon:@"icon_help" toggleValue:nil value:client.deviceType];
    }else{
        genericValue.displayText = status;
    }
    return [[GenericIndexValue alloc]initWithGenericIndex:nil genericValue:genericValue index:client.deviceID.intValue deviceID:client.deviceID.intValue];
}

+(NSArray*) getClientDetailGenericIndexValuesListForClientID:(NSString*)clientID{
    NSMutableArray *genericIndexValues = [NSMutableArray new];
    Client *client = [Client findClientByID:clientID];
    NSArray *clientGenericIndexes = [self getClientGenericIndexes];
    GenericIndexValue *genericIndexValue;
    GenericIndexClass *genericIndex;
    for(NSNumber *genericID in clientGenericIndexes){
        genericIndex = [self getGenericIndexForID:genericID.stringValue];
        if(genericIndex != nil){
            GenericValue *genericValue = [self getMatchingGenericValueForGenericIndexID:genericID.stringValue
                                                                               forValue:[self getOrSetValueForClient:client genericIndex:genericID.intValue newValue:nil ifGet:YES]];
            genericIndexValue = [[GenericIndexValue alloc]initWithGenericIndex:genericIndex genericValue:genericValue index:clientID.intValue deviceID:clientID.intValue];
            [genericIndexValues addObject:genericIndexValue];
        }
    }
    
    return genericIndexValues;
}

+(GenericIndexClass*)getGenericIndexForID:(NSString*)genericIndexID{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    return toolkit.genericIndexes[genericIndexID];
}

+(NSArray*) getClientGenericIndexes{
    NSArray *genericIndexesArray = [NSArray arrayWithObjects:@-11,@-12,@-13,@-14,@-15,@-16,@-17,@-18,@-19,@-20,@-3, nil];
    return genericIndexesArray;
}

+(NSString*)getOrSetValueForClient:(Client*)client genericIndex:(int)genericIndex newValue:(NSString*)newValue ifGet:(BOOL)get{
    if(genericIndex == -11){
        if(get)
            return client.name;
        else
            client.name = newValue;
    }else if(genericIndex == -12){
        if(get)
            return client.deviceType;
        else
            client.deviceType = newValue;
    }else if(genericIndex == -13){
        if(get)
            return client.manufacturer;
        else
            client.manufacturer = newValue;
    }else if(genericIndex == -14){
        if(get)
            return client.deviceMAC;
        else
            client.deviceMAC = newValue;
    }else if(genericIndex == -15){
        if(get)
            return client.deviceLastActiveTime;
        else
            client.deviceLastActiveTime = newValue;
    }else if(genericIndex == -16){
        if(get)
            return client.deviceConnection;
        else
            client.deviceConnection = newValue;
    }else if(genericIndex == -17){
        if(get)
            return client.deviceUseAsPresence? @"true" : @"false";
        else
            client.deviceUseAsPresence = newValue.boolValue;
    }else if(genericIndex == -18){
        if(get)
            return @(client.timeout).stringValue;
        else
            client.timeout = newValue.integerValue;
    }else if(genericIndex == -19){
        if(get)
            return @(client.deviceAllowedType).stringValue;
        else
            client.deviceAllowedType = newValue.integerValue;
    }else if(genericIndex == -20){
        if(get)
            return client.rssi;
        else
            client.rssi = newValue;
    }else if(genericIndex == -3){
        if(get)
            return @"always"; //todo
//        else
//            client.deviceType = newValue;
    }
    return nil;
}

/*
 //connected json
 @property(nonatomic, retain) NSString *name;
 @property(nonatomic, retain) NSString *deviceIP;
 @property(nonatomic, strong) NSString *manufacturer;
 @property(nonatomic, strong) NSString *rssi;
 @property(nonatomic, retain) NSString *deviceMAC;
 @property(nonatomic, retain) NSString *deviceConnection;
 @property(nonatomic, retain) NSString *deviceID;
 @property(nonatomic, retain) NSString *deviceType;
 @property(nonatomic, assign) NSInteger timeout;
 @property(nonatomic, retain) NSString *deviceLastActiveTime;
 @property(nonatomic, assign) BOOL deviceUseAsPresence;
 @property(nonatomic, assign) BOOL isActive;
 
 @property(nonatomic) DeviceAllowedType deviceAllowedType;
 @property(nonatomic) NSString *deviceSchedule;
 
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
