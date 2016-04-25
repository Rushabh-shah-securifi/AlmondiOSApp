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
        GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:genericIndexObject.groupLabel
                                                                     iconText:[genericIndexObject.formatter transform:value]
                                                                        value:value
                                                                  excludeFrom:genericIndexObject.excludeFrom];
        return genericValue;
    }
    return [[GenericValue alloc]initWithDisplayText:value icon:value toggleValue:value value:value excludeFrom:genericIndexObject.excludeFrom eventType:nil];
}

+ (NSMutableArray *)getDetailListForDevice:(int)deviceID{
    Device *device = [Device getDeviceForID:deviceID];
    
    NSMutableArray *detailList = [self getGenericIndexValuesByPlacementForDevice:device placement:@"Detail"];
    [detailList addObjectsFromArray:[self getGenericIndexValuesByPlacementForDevice:device placement:@"Badge"]];
    
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
        GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:value value:value excludeFrom:nil];
        GenericIndexClass *genIndexObj = toolkit.genericIndexes[@(genericIndex).stringValue];
        [genericIndexValues addObject:[[GenericIndexValue alloc]initWithGenericIndex:genIndexObj genericValue:genericValue index:genericIndex deviceID:device.ID]];
    }
    
    return genericIndexValues;
}

+ (GenericIndexValue *) getClientHeaderGenericIndexValueForClient:(Client*) client{
    NSString *status = client.deviceAllowedType==1 ? ALLOWED_TYPE_BLOCKED: client.isActive? ACTIVE: INACTIVE;
    GenericValue *genericValue = [self getMatchingGenericValueForGenericIndexID:@(-12).stringValue forValue:client.deviceType];

    if(genericValue == nil){ //if devicetype is wronglysent only expected return is nil
        genericValue = [[GenericValue alloc]initWithDisplayText:status icon:@"help_icon" toggleValue:nil value:client.deviceType excludeFrom:nil eventType:nil];
    }else{
        genericValue = [[GenericValue alloc]initWithGenericValue:genericValue text:status];
    }
    return [[GenericIndexValue alloc]initWithGenericIndex:nil genericValue:genericValue index:client.deviceID.intValue deviceID:client.deviceID.intValue];
}

+(NSArray*) getClientDetailGenericIndexValuesListForClientID:(NSString*)clientID{
    NSMutableArray *genericIndexValues = [NSMutableArray new];
    Client *client = [Client findClientByID:clientID];
    NSArray *clientGenericIndexes = [self clientGenericIndex:client];
    GenericIndexValue *genericIndexValue;
    GenericIndexClass *genericIndex;
    for(NSNumber *genericID in clientGenericIndexes){
        genericIndex = [self getGenericIndexForID:genericID.stringValue];
        if(genericIndex != nil){
            NSString *value = [Client getOrSetValueForClient:client genericIndex:genericID.intValue newValue:nil ifGet:YES];
            GenericValue *genericValue = [self getMatchingGenericValueForGenericIndexID:genericID.stringValue
                                                                               forValue:value];
            genericIndexValue = [[GenericIndexValue alloc]initWithGenericIndex:genericIndex genericValue:genericValue index:genericID.intValue deviceID:clientID.intValue];
            [genericIndexValues addObject:genericIndexValue];
        }
    }
    
    return genericIndexValues;
}

+(NSArray*)clientGenericIndex:(Client*)client{
    NSMutableArray *clientGenericIndexes  = [[Client getClientGenericIndexes] mutableCopy];
    if(!client.canBeBlocked){
        [clientGenericIndexes removeObjectsInArray:@[@-19, @-22]];
    }
    return clientGenericIndexes;
}

+(GenericIndexClass*)getGenericIndexForID:(NSString*)genericIndexID{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    return toolkit.genericIndexes[genericIndexID];
}

@end
