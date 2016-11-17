//
//  RuleSceneUtil.m
//  SecurifiApp
//
//  Created by Masood on 20/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "RuleSceneUtil.h"
#import "GenericDeviceClass.h"
#import "GenericIndexClass.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "DeviceIndex.h"
#import "Device.h"
#import "GenericIndexValue.h"
#import "SFIButtonSubProperties.h"
#import "GenericIndexUtil.h"
#import "RulesNestThermostat.h"

@implementation RuleSceneUtil

+ (NSDictionary*)getIndexesDicForArray:(NSArray*)genericIndexValues isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene{
    NSMutableDictionary *rowIndexValDict = [NSMutableDictionary new];
    for(GenericIndexValue *genericIndexValue in genericIndexValues){
        if(genericIndexValue.genericIndex.showToggleInRules){
            [self getToggleParms:genericIndexValue isTrigger:isTrigger isScene:isScene];
        }
        [self addToDictionary:rowIndexValDict GenericIndexVal:genericIndexValue rowID:genericIndexValue.genericIndex.rowID.intValue];
    }
    return rowIndexValDict;
}

+ (void)getToggleParms:(GenericIndexValue *)genericIndexValue isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene{
    GenericValue *toggleValue = [[GenericValue alloc]initWithDisplayText:NSLocalizedString(@"toggle", @"TOGGLE") icon:@"toggle_icon" toggleValue:@"toggle" value:@"toggle" excludeFrom:nil eventType:nil notificationText:@""];
    NSMutableDictionary *valuesDict = [genericIndexValue.genericIndex.values mutableCopy];
    [valuesDict setValue:toggleValue forKey:@"toggle"];
    if(isScene || (isTrigger && !isScene))
        [valuesDict removeObjectForKey:@"toggle"];
    genericIndexValue.genericIndex.values = valuesDict;
}

+(void)addToDictionary:(NSMutableDictionary *)rowIndexValDict GenericIndexVal:(GenericIndexValue *)genericIndexVal rowID:(int)rowID{
    NSMutableArray *augArray = [rowIndexValDict valueForKey:[NSString stringWithFormat:@"%d",rowID]];
    if(augArray != nil){
        [augArray addObject:genericIndexVal];
        [rowIndexValDict setValue:augArray forKey:[NSString stringWithFormat:@"%d",rowID]];
    }else{
        NSMutableArray *tempArray = [NSMutableArray new];
        [tempArray addObject:genericIndexVal];
        [rowIndexValDict setValue:tempArray forKey:[NSString stringWithFormat:@"%d",rowID]];
    }
}

+(NSArray *)getGenericIndexValueArrayForID:(int)deviceID type:(int)deviceType isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene triggers:(NSMutableArray*)triggers action:(NSMutableArray*)actions{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSMutableArray *genericIndexValues = [NSMutableArray new];
    
    GenericDeviceClass *genericDevice = toolkit.genericDevices[@(deviceType).stringValue];
    if(genericDevice==nil)
        return genericIndexValues;
    
    NSDictionary *deviceIndexes = genericDevice.Indexes;
    NSArray *indexIDs = deviceIndexes.allKeys;
    for(NSString *indexID in indexIDs){
        DeviceIndex *deviceIndex = deviceIndexes[indexID];
        GenericIndexClass *genericIndexObj = toolkit.genericIndexes[deviceIndex.genericIndex];
        GenericIndexClass *copyGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genericIndexObj];
        NSLog(@" device Index %@ deviceType %@,devicename %@  generic index ID %@ istrigger %d ,isScene %d",deviceIndex.index ,genericDevice.type ,genericDevice.name, copyGenericIndex.ID,isTrigger,isScene);
        int type = [genericDevice.type intValue];
        if([Device getValueForIndex:indexID.intValue deviceID:deviceID] == nil && !(type == 0 || type == 500 || type == 501 || type == 502))
            continue;
        if(![self showGenericIndex:copyGenericIndex isTrigger:isTrigger isScene:isScene])
            continue;
        
        copyGenericIndex.rowID = deviceIndex.rowID;
        
        SFIButtonSubProperties *subProperty = [self findSubProperty:triggers actions:(NSArray*)actions deviceID:deviceID index:indexID.intValue istrigger:isTrigger];
        GenericValue *genericValue = nil;
        if(subProperty != nil)
            genericValue = [GenericIndexUtil getMatchingGenericValueForGenericIndexID:copyGenericIndex.ID forValue:subProperty.matchData];
        
        if(deviceIndex.min != nil && deviceIndex.max  != nil){
            copyGenericIndex.formatter.min = deviceIndex.min.intValue;
            copyGenericIndex.formatter.max = deviceIndex.max.intValue;
        }
        
        GenericIndexValue *genericIndexValue = [[GenericIndexValue alloc]initWithGenericIndex:copyGenericIndex genericValue:genericValue index:indexID.intValue deviceID:deviceID];
        
        [genericIndexValues addObject:genericIndexValue];
        
    }
    return genericIndexValues;
}

+(SFIButtonSubProperties *)findSubProperty:(NSArray*)triggers actions:(NSArray*)actions deviceID:(int)deviceID index:(int)index istrigger:(BOOL)isTrigger{
    NSArray *list = isTrigger? triggers: actions;
    for(SFIButtonSubProperties *subProperty in list){
        if(deviceID == subProperty.deviceId && index == subProperty.index){
            return subProperty;
        }
    }
    return nil;
}

+(BOOL)showGenericDevice:(int)deviceType isTrigger:(BOOL) isTrigger isScene:(BOOL)isScene{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericDeviceClass *genericDevice = toolkit.genericDevices[@(deviceType).stringValue];
    //NSLog(@"devicetype: %d, istrigger: %d", deviceType, genericDevice.isTrigger);
    if(genericDevice != nil && [self isToBeAdded:genericDevice.excludeFrom checkString:isScene?@"Scene":@"Rule"]){
        if((!isScene && isTrigger) && genericDevice.isTrigger)
            return YES;
        else if ((!isTrigger || isScene) && genericDevice.isActuator)
            return YES;
        
    }
    return NO;
}

//if(!isScene && [self isToBeAdded:index.excludeFrom checkString:@"Trigger"])
+(BOOL)showGenericIndex:(GenericIndexClass *)index isTrigger:(BOOL) isTrigger isScene:(BOOL)isScene{
    NSString *checkString = isScene?@"Scene":@"Rule";
    if([self isToBeAdded:index.excludeFrom checkString:checkString]){
        if(!isScene && isTrigger && [self isToBeAdded:index.excludeFrom checkString:@"Trigger"])
            return YES;
        else if ((!isTrigger || isScene) && !index.readOnly)
            return YES;
        
    }
    return NO;
}

+ (BOOL)showGenericValue:(GenericValue *)index isScene:(BOOL)isScene isTrigger:(BOOL)isTrigger{
    //isrule and trigger -> do not add
    if([self isToBeAdded:index.excludeFrom checkString:isScene?@"Scene":@"Rule"]){
        if(isScene || (!isTrigger && [self isToBeAdded:index.excludeFrom checkString:@"Action"]))
            return YES;
        else if(isTrigger)
            return YES;
    }
    return NO;
}


+ (BOOL) isToBeAdded:(NSString*)dataString checkString:(NSString*)checkString{
    if(dataString  != nil){
        if([dataString rangeOfString:checkString options:NSCaseInsensitiveSearch].location != NSNotFound){// data string contains check string
            return NO;
        }
    }
    return  YES;
}

@end
