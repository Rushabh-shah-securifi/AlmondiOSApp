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
#import "Rule.h"
#import "SFIButtonSubProperties.h"

@implementation GenericIndexUtil


+(GenericIndexValue*)getHeaderGenericIndexValueForDevice:(Device*)device{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSArray *genericIndexValues = [self getGenericIndexValuesByPlacementForDevice:device placement:HEADER];
    if([genericIndexValues count] <= 0 && device.type == 60){
        genericIndexValues = [self getGenericIndexValuesNOHeader:device placment:@"Detail"];
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

+ (NSArray *)getDetailListForDevice:(int)deviceID{
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
//    else if(device.type == SFIDeviceType_HueLamp_48 && [[Device getValueForIndex:2 deviceID:deviceID] isEqualToString:@"false"]){
//        [detailList removeAllObjects];
//    }
    else if(device.type == SFIDeviceType_AlmondSiren_63)
        detailList = [self handleAlmondSiren:deviceID genericIndexValues:detailList];
    
    //NSArray *commonList = [self getCommonGenericIndexValue:device];
    //[detailList addObjectsFromArray:commonList];
    return [self getGroupedGenericIndexes:detailList device:device];
}
+ (NSArray *)getDetailListForClient:(int)clientID{
    Client *client = [Client findClientByID:@(clientID).stringValue];
   // [self getGroupedGenericIndexesForClient:<#(NSMutableArray *)#> device:client];
    NSMutableArray *clienTGenericIndex = [[self getClientDetailGenericIndexValuesListForClientID:@(clientID).stringValue] mutableCopy];
    clienTGenericIndex = [self getSortedIndexValues:clienTGenericIndex];
    clienTGenericIndex = [self getIndexValuesBasedOnSortedReadOnly:clienTGenericIndex];
    clienTGenericIndex = [self getGroupedGenericIndexesForClient:clienTGenericIndex device:client];
    
    
    return clienTGenericIndex;
    
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
+ (NSArray *)getGroupedGenericIndexes:(NSMutableArray *)detailList device:(Device *)device{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSMutableArray *groupedIndexValueList = [NSMutableArray new];
    NSArray *indexList;
    //name, location, devicespecific, automation, notification
    NSArray *displayOrder = @[@-1, @-2, @-45, @-46, @-47, @-48, @-42, @-43];
    NSDictionary *deviceDict = [self getDeviceSpecificInxedesDict:detailList];
    
    for(NSNumber *orderId in displayOrder){
        GenericIndexClass *genIndexObj = toolkit.genericIndexes[orderId.stringValue];
        
        if(orderId.integerValue == -45 || orderId.integerValue == -46 || orderId.integerValue == -47 || orderId.integerValue == -48){
            if(orderId.integerValue == -45 && deviceDict[@"0"])
                [self addIndexValueList:groupedIndexValueList gI:genIndexObj genericIndexes:deviceDict[@"0"]];
            else if(orderId.integerValue == -46 && deviceDict[@"1"])
                [self addIndexValueList:groupedIndexValueList gI:genIndexObj genericIndexes:deviceDict[@"1"]];
            else if(orderId.integerValue == -47 && deviceDict[@"2"])
                [self addIndexValueList:groupedIndexValueList gI:genIndexObj genericIndexes:deviceDict[@"2"]];
            else if(orderId.integerValue == -48 && deviceDict[@"3"])
                [self addIndexValueList:groupedIndexValueList gI:genIndexObj genericIndexes:deviceDict[@"3"]];
        }
        
        else{
            
            indexList = [self getCommonGenericIndexValues:device genericIndex:genIndexObj];
            [self addIndexValueList:groupedIndexValueList gI:genIndexObj genericIndexes:indexList];
        }
        /*
         if(orderId.intValue ==  -1 || orderId.intValue ==  -2){
         GenericIndexValue *gIVal = [self getGenericIndexeValueForGenericId:orderId.intValue device:device];
         [groupedIndexValueList addObject:gIVal];
         }
         else if(orderId.intValue == 10000){
         NSDictionary *dict = [self getDeviceSpecificInxedesDict:detailList];
         dict[@"0"]? [groupedIndexValueList addObject:dict[@"0"]]: nil;
         dict[@"1"]? [groupedIndexValueList addObject:dict[@"1"]]: nil;
         dict[@"2"]? [groupedIndexValueList addObject:dict[@"2"]]: nil;
         dict[@"3"]? [groupedIndexValueList addObject:dict[@"3"]]: nil;
         }
         else if(orderId.intValue ==  -42){
         GenericIndexValue *gIVal = [self getGenericIndexeValueForGenericId:-37 device:device];
         [groupedIndexValueList addObject:gIVal];
         gIVal = [self getGenericIndexeValueForGenericId:-38 device:device];
         [groupedIndexValueList addObject:gIVal];
         }
         else if(orderId.intValue ==  -43){
         GenericIndexValue *gIVal = [self getGenericIndexeValueForGenericId:-3 device:device];
         [groupedIndexValueList addObject:gIVal];
         gIVal = [self getGenericIndexeValueForGenericId:-39 device:device];
         [groupedIndexValueList addObject:gIVal];
         }
         */
    }
    
    return groupedIndexValueList;
}
+ (NSArray *)getGroupedGenericIndexesForClient:(NSMutableArray *)detailList device:(Client *)client{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSMutableArray *groupedIndexValueList = [NSMutableArray new];
    NSArray *indexList;
    //name, location, devicespecific, automation, notification
    NSArray *displayOrder = @[@-11, @-12, @-44, @-17, @-43, @-41];
    
    for(NSNumber *orderId in displayOrder){
        GenericIndexClass *genIndexObj = toolkit.genericIndexes[orderId.stringValue];
        
        indexList = [self getCommonGenericIndexValuesClient:client genericIndex:genIndexObj];
            [self addIndexValueList:groupedIndexValueList gI:genIndexObj genericIndexes:indexList];
    }
    return groupedIndexValueList;
}

+ (void)addIndexValueList:(NSMutableArray *)groupedIndexValueList gI:(GenericIndexClass *)gI genericIndexes:(NSArray *)genericIndexes{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:gI forKey:GENERIC_INDEX];
    [dict setObject:genericIndexes forKey:GENERIC_ARRAY];
    [groupedIndexValueList addObject:dict];
}



+ (NSArray *)getCommonGenericIndexValuesClient:(Client *)client genericIndex:(GenericIndexClass *)genericIndex{
    NSMutableArray *genericIndexVals = [NSMutableArray new];
    GenericIndexValue *gIVal;
    if(genericIndex == nil || genericIndex.elements.count == 0)
        return genericIndexVals;
    
    for(NSString *strId in genericIndex.elements){
        gIVal = [self getGenericIndexeValueForGenericIdClient:strId.integerValue client:client];
        if(gIVal)
            [genericIndexVals addObject:gIVal];
    }
    
    return genericIndexVals;
}

+ (NSArray *)getCommonGenericIndexValues:(Device *)device genericIndex:(GenericIndexClass *)genericIndex{
    NSMutableArray *genericIndexVals = [NSMutableArray new];
    GenericIndexValue *gIVal;
    if(genericIndex == nil || genericIndex.elements.count == 0)
        return genericIndexVals;
    
    for(NSString *strId in genericIndex.elements){
        gIVal = [self getGenericIndexeValueForGenericId:strId.integerValue device:device];
        if(gIVal)
           [genericIndexVals addObject:gIVal];
    }
    
    return genericIndexVals;
}

//0-status 1-temp 2-control 3-notitle
+ (NSDictionary *)getDeviceSpecificInxedesDict:(NSArray *)detailList{
    NSMutableDictionary *deviceSpecificDict = [NSMutableDictionary new];
    
    for(GenericIndexValue *gIVal in detailList){
        [self addToDictionary:deviceSpecificDict GenericIndexVal:gIVal groupID:gIVal.genericIndex.categoryLabel];
    }
    return deviceSpecificDict;
}

+(void)addToDictionary:(NSMutableDictionary *)deviceSpecificDict GenericIndexVal:(GenericIndexValue *)genericIndexVal groupID:(NSString *)groupID{
    NSMutableArray *augArray = [deviceSpecificDict valueForKey:groupID];
    if(augArray != nil){
        [augArray addObject:genericIndexVal];
        [deviceSpecificDict setValue:augArray forKey:groupID];
    }else{
        NSMutableArray *tempArray = [NSMutableArray new];
        [tempArray addObject:genericIndexVal];
        [deviceSpecificDict setValue:tempArray forKey:groupID];
    }
}

+ (GenericIndexValue *)getGenericIndexeValueForGenericIdClient:(NSInteger)genericId client:(Client *)client{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericIndexClass *genIndexObj = toolkit.genericIndexes[@(genericId).stringValue];
    if(genIndexObj == nil)
        return nil;
    
    GenericValue *genericValue = nil;
    GenericIndexClass *copyGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genIndexObj];
    if(genericId == -1 || genericId == -2 || genericId == -3){
        NSString *value;
        if(genericId == -1){
            value = client.name;
        }else{//notifyme
            value = @(client.notificationMode).stringValue;
        }
         genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:value value:value excludeFrom:nil transformedValue:nil prefix:@""];
    }
    else if(genericId == -37){
        NSString *countStr = @([self ruleListThatContainsDevice:NO deviceId:[client.deviceID intValue]].count).stringValue;
        genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:countStr value:countStr excludeFrom:nil transformedValue:nil prefix:@""];
    }
    else if(genericId == -38){
        NSString *countStr = @([self ruleListThatContainsDevice:YES deviceId:[client.deviceID intValue]].count).stringValue;
        genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:countStr value:countStr excludeFrom:nil transformedValue:nil prefix:@""];
    }
    else if(genericId == -39){
        genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:@"" value:@"" excludeFrom:nil transformedValue:nil prefix:@""];
    }
    return [[GenericIndexValue alloc]initWithGenericIndex:copyGenericIndex genericValue:genericValue index:copyGenericIndex.ID.intValue deviceID:[client.deviceID intValue]];
}

+ (GenericIndexValue *)getGenericIndexeValueForGenericId:(NSInteger)genericId device:(Device *)device{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericIndexClass *genIndexObj = toolkit.genericIndexes[@(genericId).stringValue];
    if(genIndexObj == nil)
        return nil;
    
    GenericValue *genericValue = nil;
    GenericIndexClass *copyGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genIndexObj];
    if(genericId == -1 || genericId == -2 || genericId == -3){
        NSString *value;
        if(genericId == -1){
            value = device.name;
        }else if(genericId == -2){
            value = device.location;
        }else{//notifyme
            value = @(device.notificationMode).stringValue;
        }
        
        /*?*/
        genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:value value:value excludeFrom:nil transformedValue:nil prefix:@""];
    }
    else if(genericId == -37){
        NSString *countStr = @([self ruleListThatContainsDevice:NO deviceId:device.ID].count).stringValue;
        genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:countStr value:countStr excludeFrom:nil transformedValue:nil prefix:@""];
    }
    else if(genericId == -38){
        NSString *countStr = @([self ruleListThatContainsDevice:YES deviceId:device.ID].count).stringValue;
        genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:countStr value:countStr excludeFrom:nil transformedValue:nil prefix:@""];
    }
    else if(genericId == -39){
        genericValue = [[GenericValue alloc]initWithDisplayText:nil iconText:@"" value:@"" excludeFrom:nil transformedValue:nil prefix:@""];
    }
    return [[GenericIndexValue alloc]initWithGenericIndex:copyGenericIndex genericValue:genericValue index:copyGenericIndex.ID.intValue deviceID:device.ID];
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
+(NSArray *) getDetailForNavigationItems:(NSArray *)navigationItems clientID:(NSString*)clientID{
    NSMutableArray *genericIndexValues = [NSMutableArray new];
    Client *client = [Client findClientByID:clientID];
    NSArray *clientGenericIndexes = navigationItems;
    GenericIndexValue *genericIndexValue;
    GenericIndexClass *genericIndex;
    for(NSNumber *genericID in clientGenericIndexes){
        genericIndex = [self getGenericIndexForID:genericID.stringValue];
        if(genericIndex != nil){
            NSString *value = [Client getOrSetValueForClient:client genericIndex:genericID.intValue newValue:nil ifGet:YES];
            GenericValue *genericValue = [self getMatchingGenericValueForGenericIndexID:genericID.stringValue
                                                                               forValue:value];
            if([genericID integerValue] == -17){
                genericIndex.groupLabel = @"Use in Rules Engine";
                genericIndex.property = @"switchButton";
            }
            genericIndexValue = [[GenericIndexValue alloc]initWithGenericIndex:genericIndex genericValue:genericValue index:genericID.intValue deviceID:clientID.intValue];
            [genericIndexValues addObject:genericIndexValue];
        }
    }
    return genericIndexValues;
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

#pragma mark helper methods

+(NSMutableArray *)ruleListThatContainsDevice:(BOOL)isRule deviceId:(int)deviceID{
    NSMutableArray *ruleArr = [[NSMutableArray alloc]init];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    NSArray *ruleList = isRule?toolkit.ruleList:toolkit.scenesArray;
    if(!isRule){
        for(NSDictionary *sceneDict in ruleList){
            Rule *scene = [self getScene:sceneDict];
            for(SFIButtonSubProperties *subProperty in scene.triggers){
                
                if(subProperty.deviceId == deviceID){
                    if(![subProperty.eventType isEqualToString:@"AlmondModeUpdated"])
                    {
                        [ruleArr addObject: scene];
                        break ;
                    }
                }
            }
            
        }
        return ruleArr;
    }
    for(Rule *rules in ruleList){
        BOOL isRuleFound = NO;
        for(SFIButtonSubProperties *subProperty in rules.triggers){
            
            if(subProperty.deviceId == deviceID){
                if(![self checkEventType:subProperty.eventType]){
                    [ruleArr addObject: rules];
                    isRuleFound = YES;
                    break ;
                }
            }
        }
        if(isRuleFound)
            continue;
        
        for(SFIButtonSubProperties *subProperty in rules.actions){
            if(subProperty.deviceId == deviceID){
                if(![self checkEventType:subProperty.eventType]){
                    [ruleArr addObject: rules];
                    isRuleFound = YES;
                    break;
                }
            }
        }
        if(isRuleFound)
            continue;
    }
    return ruleArr;
}

+(BOOL)checkEventType:(NSString *)eventType{
    if([eventType isEqualToString:@"AlmondModeUpdated"] || [eventType isEqualToString:@"ClientJoined"] || [eventType isEqualToString:@"ClientLeft"]){
        return YES;
    }
    else
        return NO;
}

+(BOOL)isRepetingRule:(NSArray *)ruleArr rule:(Rule*)rule{
    for (Rule *ruleObj in ruleArr) {
        if([rule.ID isEqualToString:ruleObj.ID])
            return NO;
    }
    return YES;
}

+(Rule *)getScene:(NSDictionary*)dict{
    Rule *scene = [[Rule alloc]init];
    scene.ID = [dict valueForKey:@"ID"];
    scene.name = [dict valueForKey:@"Name"]==nil?@"":[dict valueForKey:@"Name"];
    scene.isActive = [[dict valueForKey:@"Active"] boolValue];
    scene.triggers= [NSMutableArray new];
    [self getEntriesList:[dict valueForKey:@"SceneEntryList"] list:scene.triggers];
    return scene;
}

+(void)getEntriesList:(NSArray*)sceneEntryList list:(NSMutableArray *)triggers{
    for(NSDictionary *triggersDict in sceneEntryList){
        SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
        NSLog(@"triggersDict %@",triggersDict);
        subProperties.deviceId = [[triggersDict valueForKey:@"ID"] intValue];
        subProperties.index = [[triggersDict valueForKey:@"Index"] intValue];
        subProperties.matchData = [triggersDict valueForKey:@"Value"];
        subProperties.valid = [[triggersDict valueForKey:@"Valid"] boolValue];
        subProperties.eventType = [triggersDict valueForKey:@"EventType"];
        //        subProperties.type = subProperties.deviceId==0?@"EventTrigger":@"DeviceTrigger";
        //        subProperties.delay=[triggersDict valueForKey:@"PreDelay"];
        //        [self addTime:triggersDict timeProperty:subProperties];
        [triggers addObject:subProperties];
    }
}

@end
