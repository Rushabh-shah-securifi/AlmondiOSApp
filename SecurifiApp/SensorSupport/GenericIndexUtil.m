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
#import "SFIAlmondPlus.h"
#import "AlmondManagement.h"
#import "AlmondPlan.h"
#import "NSString+securifi.h"

@implementation GenericIndexUtil


+(GenericIndexValue*)getHeaderGenericIndexValueForDevice:(Device*)device{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSArray *genericIndexValues = [self getGenericIndexValuesByPlacementForDevice:device placement:HEADER];
    
    if([genericIndexValues count] <= 0 && device.type == 60){
        genericIndexValues = [self getGenericIndexValuesNOHeader:device placment:@"Detail"];
    }
    if(device.type == 65){

        GenericValue *gVal = [[GenericValue alloc]initWithDisplayText:@"" iconText:nil value:@"1" excludeFrom:@"" transformedValue:@"" prefix:@""];
        gVal.icon = @"vibration_off";
        GenericIndexClass *gIndex = [GenericIndexClass new];
        GenericIndexValue *gIndexValue = [GenericIndexValue new];
        gIndexValue.genericValue = gVal;
        gIndexValue.genericIndex = gIndex;
        gIndexValue.deviceID = device.ID;
        return gIndexValue;
     }
    if([genericIndexValues count] <= 0){
        return [[GenericIndexValue alloc]initWithGenericIndex:nil genericValue:[[GenericValue alloc]initUnknownDevice] index:0 deviceID:device.ID];
    }
    
    NSString *headerText = @"";
    NSMutableString *detailText = [[NSMutableString alloc]initWithString:@""];
    int index = 0;
    GenericValue *genericValue; //the value assigned to this will be generic value of header
    GenericIndexClass *genericIndex;
    BOOL headerFound = NO;
    
    for(GenericIndexValue *genericIndexValue in genericIndexValues){
        if(genericIndexValue.genericValue == nil)
            continue;
        
        if(([genericIndexValue.genericIndex.placement isEqualToString:HEADER] || [genericIndexValue.genericIndex.placement isEqualToString:@"Header_Detail_Primary"]) && headerFound == NO){
            headerFound = YES;
            
            genericValue = genericIndexValue.genericValue;
            genericIndex = genericIndexValue.genericIndex;
            
            if([genericIndex.layoutType isEqualToString:@"SLIDER_ICON"] || [genericIndex.layoutType isEqualToString:@"TEXT_VIEW_ONLY"]){
                headerText = [NSString stringWithFormat:@"%@ %@", genericIndexValue.genericIndex.groupLabel, genericIndexValue.genericValue.displayText];
            }
            else{
                headerText = genericIndexValue.genericValue.displayText;
            }
            if(genericIndexValue.genericValue.icon.length == 0)
                headerText = @"";
            
            index = genericIndexValue.index;
        }
        
        else if([genericIndexValue.genericIndex.placement containsString:HEADER]){ //contains
            if(genericIndexValue.genericValue.iconText){
                if(detailText.length == 0 && headerText.length == 0)
                    [detailText appendString:[NSString stringWithFormat:@"%@ %@", genericIndexValue.genericIndex.groupLabel, genericIndexValue.genericValue.iconText]];
                else
                    [detailText appendString:[NSString stringWithFormat:@", %@ %@", genericIndexValue.genericIndex.groupLabel, genericIndexValue.genericValue.iconText]];
            }
            else{
                if(detailText.length == 0 && headerText.length == 0)
                    [detailText appendString:[NSString stringWithFormat:@"%@", genericIndexValue.genericValue.displayText]];
                else
                    [detailText appendString:[NSString stringWithFormat:@", %@", genericIndexValue.genericValue.displayText]];
            }
        }
    }//for
    
    if(genericValue == nil){
        genericValue = [GenericValue new];
        GenericDeviceClass *genericDevice = toolkit.genericDevices[@(device.type).stringValue];
        genericValue.icon = genericDevice.defaultIcon;
    }
    
    if(detailText.length > 0){
        genericValue = [[GenericValue alloc]initWithGenericValue:genericValue text:[NSString stringWithFormat:@"%@ %@", headerText, detailText]];
    }
    else if(headerText.length > 0){
        genericValue = [[GenericValue alloc]initWithGenericValue:genericValue text:[NSString stringWithFormat:@"%@", headerText]];
    }

    NSLog(@"Final header text: %@, detail text: %@", headerText, detailText);
    return [[GenericIndexValue alloc]initWithGenericIndex:genericIndex genericValue:genericValue index:index deviceID:device.ID];
}

+ (NSMutableArray *)getDetailListForDevice:(int)deviceID{
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    Device *device = [Device getDeviceForID:deviceID];
    
    NSMutableArray *detailList = [self getGenericIndexValuesByPlacementForDevice:device placement:@"Detail"];
    [detailList addObjectsFromArray:[self getGenericIndexValuesByPlacementForDevice:device placement:@"Badge"]];
    //NSLog(@"Detail list vals: %@", detailList);
    detailList = [self getSortedIndexValues:detailList];
    detailList = [self getIndexValuesBasedOnSortedReadOnly:detailList];
    
    if((device.type == SFIDeviceType_NestThermostat_57 && [[Device getValueForIndex:11 deviceID:deviceID] isEqualToString:@"false"]) || (device.type == SFIDeviceType_NestSmokeDetector_58 && [[Device getValueForIndex:5 deviceID:deviceID] isEqualToString:@"false"])){//don't paint indexes on offline
        [detailList removeAllObjects];
    }
    else if(device.type == SFIDeviceType_HueLamp_48 && [[Device getValueForIndex:2 deviceID:deviceID] isEqualToString:@"false"]){
        [detailList removeAllObjects];
    }else if(device.type == SFIDeviceType_AlmondSiren_63)
        detailList = [self handleAlmondSiren:deviceID genericIndexValues:detailList];
    
    NSArray *commonList = [self getCommonGenericIndexValue:device];
    [detailList addObjectsFromArray:commonList];
    return detailList;
}

+(NSMutableArray*)getSortedIndexValues:(NSMutableArray*)detailList{
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    return [[detailList sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

+(NSMutableArray*)getIndexValuesBasedOnSortedReadOnly:(NSMutableArray*)detailList{
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"genericIndex.readOnly" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
    return [[detailList sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
}

+(NSMutableArray *)getGenericIndexValuesNOHeader:(Device *)device placment:(NSString*)placment{
    
    
    NSArray *genericIndexes = [self getGenericIndexValuesByPlacementForDevice:device placement:placment];
    if(genericIndexes!= nil && genericIndexes.count > 0){
        GenericIndexValue *genericIndexValue = [genericIndexes objectAtIndex:0];
        //NSLog(@"value display text icon %@,%@,%@",genericIndexValue.genericValue.value,genericIndexValue.genericValue.displayText,genericIndexValue.genericValue.icon);
        if(genericIndexValue.genericIndex.formatter != Nil){
            
            GenericValue *gValue = [GenericValue new];
            gValue.value =genericIndexValue.genericValue.value;
            gValue.displayText =genericIndexValue.genericValue.displayText;
            gValue.icon =genericIndexValue.genericValue.icon;
            genericIndexValue.genericValue = gValue;
            return  genericIndexes;
        }
        
        
    }
    return NULL;
}

+(NSMutableArray*)getGenericIndexValuesByPlacementForDevice:(Device*)device placement:(NSString*)placement{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSMutableArray *genericIndexValues = [NSMutableArray new];

    
    if(device.type == SFIDeviceType_GenericDevice_60){
        for(DeviceKnownValues *knownValue in device.knownValues){
            GenericIndexClass *genericIndexObj = toolkit.genericIndexes[knownValue.genericIndex];
            GenericIndexClass *copyGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genericIndexObj];
            
            if([copyGenericIndex.placement containsString:placement] || ([placement isEqualToString:@"Detail"] && [copyGenericIndex.placement isEqualToString:HEADER])){//contains
                GenericValue *genericValue = [self getMatchingGenericValueForGenericIndexID:copyGenericIndex.ID
                                                                                   forValue:knownValue.value];
                if(genericValue!=nil && knownValue.value != nil) //check for index exists
                    [genericIndexValues addObject:[[GenericIndexValue alloc]initWithGenericIndex:copyGenericIndex genericValue:genericValue index:knownValue.index deviceID:device.ID]];
            }
            
        }
    }
    
    else{
        GenericDeviceClass *genericDevice = toolkit.genericDevices[@(device.type).stringValue];
        if(genericDevice==nil)
            return [NSMutableArray new];
        NSDictionary *deviceIndexes = genericDevice.Indexes;
        NSMutableArray *deviceIndexesKeys = [NSMutableArray arrayWithArray:deviceIndexes.allKeys];
        
        for(NSString *IndexId in deviceIndexesKeys){
            DeviceIndex *deviceIndex = deviceIndexes[IndexId];
            GenericIndexClass *genericIndexObj = toolkit.genericIndexes[deviceIndex.genericIndex];
            
            GenericIndexClass *copyGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genericIndexObj];
            if(deviceIndex.placement != nil){
                copyGenericIndex.placement = deviceIndex.placement;
            }
            if([copyGenericIndex.placement containsString:placement]){//contains
                GenericValue *genericValue = [self getMatchingGenericValueForGenericIndexID:copyGenericIndex.ID
                                                                                   forValue:[self getHeaderValueFromKnownValuesForDevice:device indexID:IndexId]];
                
                //override device index values
                if(deviceIndex.min != nil && deviceIndex.max  != nil){
                    copyGenericIndex.formatter.min = deviceIndex.min.intValue;
                    copyGenericIndex.formatter.max = deviceIndex.max.intValue;
                }
                if(deviceIndex.appLabel != nil)
                    copyGenericIndex.groupLabel = deviceIndex.appLabel;
                
                
                if(genericValue!=nil && [Device getValueForIndex:IndexId.intValue deviceID:device.ID] != nil) //check for index exists
                    [genericIndexValues addObject:[[GenericIndexValue alloc]initWithGenericIndex:copyGenericIndex genericValue:genericValue index:IndexId.intValue deviceID:device.ID]];
            }
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
    //NSLog(@"value: %@", value);
//    if(value.length == 0 || value == nil)
//        value = @"NaN";
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericIndexClass *genericIndexObject = toolkit.genericIndexes[genericIndexID];
    if(genericIndexObject == nil || value == nil)
        return nil;
    else if(genericIndexObject.values != nil){
        return genericIndexObject.values[value]? genericIndexObject.values[value]: [[GenericValue alloc]initWithDisplayText:value icon:genericIndexObject.icon toggleValue:nil value:value excludeFrom:nil eventType:nil notificationText:@""];
    }
    else if(genericIndexObject.formatter != nil && ![genericIndexObject.layoutType isEqualToString:@"SLIDER_ICON"] && ![genericIndexObject.layoutType isEqualToString:@"TEXT_VIEW_ONLY"]){
        NSString *formattedValue=[genericIndexObject.formatter transform:value genericId:genericIndexID];
        NSLog(@"slider icon - display text: %@, value: %@ units : %@", [genericIndexObject.formatter transform:value genericId:genericIndexID], value,genericIndexObject.formatter.units);

        GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:formattedValue
                                                                     iconText:formattedValue
                                                                        value:value
                                                                  excludeFrom:genericIndexObject.excludeFrom
                                                             transformedValue:[genericIndexObject.formatter transformValue:value] prefix:@""];
        return genericValue;
    }
    else if(genericIndexObject.formatter != nil && ([genericIndexObject.layoutType isEqualToString:@"SLIDER_ICON"] || [genericIndexObject.layoutType isEqualToString:@"TEXT_VIEW_ONLY"])){
        NSLog(@"slider icon - display text: %@, value: %@ units : %@", [genericIndexObject.formatter transform:value genericId:genericIndexID], value,genericIndexObject.formatter.units);
        return [[GenericValue alloc]initWithDisplayText:[genericIndexObject.formatter transform:value genericId:genericIndexID]
                                                   icon:genericIndexObject.icon
                                            toggleValue:nil
                                                  value:value
                                            excludeFrom:nil
                                              eventType:nil
                                       transformedValue:[genericIndexObject.formatter transformValue:value] prefix:@"" andUnits:genericIndexObject.formatter.units]; //need icon aswell as transformedValue
    }
    return [[GenericValue alloc]initWithDisplayText:value icon:genericIndexObject.icon toggleValue:value value:value excludeFrom:genericIndexObject.excludeFrom eventType:nil notificationText:@""];
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
            value = @(device.notificationMode).stringValue;
        }
        GenericValue *genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:value value:value excludeFrom:nil transformedValue:nil prefix:@""];
        GenericIndexClass *genIndexObj = toolkit.genericIndexes[@(genericIndex).stringValue];
        [genericIndexValues addObject:[[GenericIndexValue alloc]initWithGenericIndex:genIndexObj genericValue:genericValue index:genericIndex deviceID:device.ID]];
    }
    
    return genericIndexValues;
}

#pragma mark client

+ (GenericIndexValue *) getClientHeaderGenericIndexValueForClient:(Client*) client{
    NSString *status = client.deviceAllowedType==1 ? ALLOWED_TYPE_BLOCKED: client.isActive? @"ACTIVE": @"INACTIVE";
    GenericValue *genericValue = [self getMatchingGenericValueForGenericIndexID:@(-12).stringValue forValue:client.deviceType]; //-12 client type - iphone, ipad etc.

    if(genericValue == nil){ //if devicetype is wronglysent only expected return is nil
        genericValue = [[GenericValue alloc]initWithDisplayText:status icon:@"help_icon" toggleValue:nil value:client.deviceType excludeFrom:nil eventType:nil notificationText:@""];
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
    SFIAlmondPlus *currentAlmond = [AlmondManagement currentAlmond];
    BOOL hasSubscribe = [AlmondPlan hasSubscription:currentAlmond.almondplusMAC];
    NSLog(@"hasSubscribe %d",hasSubscribe);
    for(NSNumber *genericID in clientGenericIndexes){
        
        
        genericIndex = [self getGenericIndexForID:genericID.stringValue];
        if(genericIndex != nil){
            NSString *value = [Client getOrSetValueForClient:client genericIndex:genericID.intValue newValue:nil ifGet:YES];
            GenericValue *genericValue = [self getMatchingGenericValueForGenericIndexID:genericID.stringValue
                                                                               forValue:value];
            genericIndexValue = [[GenericIndexValue alloc]initWithGenericIndex:genericIndex genericValue:genericValue index:genericID.intValue deviceID:clientID.intValue];
            
            if([genericID.stringValue isEqualToString:@"-27"] ){
                if(client.is_IoTDeviceType && hasSubscribe)
                [genericIndexValues addObject:genericIndexValue];
            }
            else if ([genericID.stringValue isEqualToString:@"-23"]){
                if(!client.is_IoTDeviceType && hasSubscribe)
                    [genericIndexValues addObject:genericIndexValue];
            }
            else
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
    if([client.deviceConnection isEqualToString:@"wired"] || !client.isActive)
        [clientGenericIndexes removeObjectsInArray:@[@-20]];

    return clientGenericIndexes;
}

+(GenericIndexClass*)getGenericIndexForID:(NSString*)genericIndexID{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    return toolkit.genericIndexes[genericIndexID];
}

+ (NSString*)getStatus:(int)deviceID value:(NSString *)value{
    Device *device = [Device getDeviceForID:deviceID];
    NSMutableArray *detailList = [self getGenericIndexValuesByPlacementForDevice:device placement:@"HeaderOnly"];
    [detailList addObjectsFromArray:[self getGenericIndexValuesByPlacementForDevice:device placement:@"Header_Detail"]];
    NSMutableString *status = [NSMutableString new];
    //NSLog(@"util value: %@", value);
    if(value == nil){//has icon text
        //NSLog(@"has icon text util");
        int i = 0;
        for(GenericIndexValue *genericIndexVal in detailList){
            if(i==0){
                [status appendString:[NSString stringWithFormat:@"%@ %@",genericIndexVal.genericIndex.groupLabel, genericIndexVal.genericValue.value]];
            }
            else{
                [status appendString:[NSString stringWithFormat:@", %@ %@",genericIndexVal.genericIndex.groupLabel, genericIndexVal.genericValue.value]];
            }
            i++;
        }
    }else{
        //NSLog(@"no icon text util");
        [status appendString:value];
        for(GenericIndexValue *genericIndexVal in detailList){
            [status appendString:[NSString stringWithFormat:@", %@", genericIndexVal.genericValue.value]];
        }
    }
    //NSLog(@"status: %@", status);
    return  status;
}


+(NSMutableArray*)handleAlmondSiren:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues{
    //for index 1 if value is false remove [2-4] indexes.
    BOOL isDisabled = [[Device getValueForIndex:1 deviceID:deviceID] isEqualToString:@"false"];
    NSMutableArray *newGenericIndexValues = [genericIndexValues mutableCopy];
    if(isDisabled){
        for(GenericIndexValue *genIndexVal in genericIndexValues){
            if(genIndexVal.index != 1)
                [newGenericIndexValues removeObject:genIndexVal];
        }
    }
    return newGenericIndexValues;
}


@end
