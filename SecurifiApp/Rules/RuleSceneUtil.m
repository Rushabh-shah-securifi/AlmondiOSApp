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
    GenericValue *toggleValue = [[GenericValue alloc]initWithDisplayText:@"TOGGLE" icon:@"toggle_icon" toggleValue:@"toggle" value:@"toggle" excludeFrom:nil eventType:nil];
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
        NSLog(@" device Index %@ deviceType %@,devicename %@  generic index ID %@ istrigger %d ,istrigger %d",deviceIndex.index ,genericDevice.type ,genericDevice.name, genericIndexObj.ID,isTrigger,isScene);
        if([Device getValueForIndex:indexID.intValue deviceID:deviceID] == nil && !([genericDevice.type isEqualToString:@"0" ] || [genericDevice.type isEqualToString:@"500" ] || [genericDevice.type isEqualToString:@"501" ]))
            continue;
        if(![self showGenericIndex:genericIndexObj isTrigger:isTrigger isScene:isScene])
            continue;
        
        genericIndexObj.rowID = deviceIndex.rowID;
        
        SFIButtonSubProperties *subProperty = [self findSubProperty:triggers actions:(NSArray*)actions deviceID:deviceID index:indexID.intValue istrigger:isTrigger];
        GenericValue *genericValue = nil;
        if(subProperty != nil)
            genericValue = [GenericIndexUtil getMatchingGenericValueForGenericIndexID:genericIndexObj.ID forValue:subProperty.matchData];
        
        GenericIndexValue *genericIndexValue = [[GenericIndexValue alloc]initWithGenericIndex:genericIndexObj genericValue:genericValue index:indexID.intValue deviceID:deviceID];
        
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
    if(genericDevice != nil && [self isToBeAdded:genericDevice.excludeFrom checkString:isScene?@"Scene":@"Rule"]){
        if((!isScene && isTrigger) && genericDevice.isTrigger)
           return YES;
        else if ((!isTrigger || isScene) && genericDevice.isActuator)
            return YES;
        
    }
    return NO;
}


+(BOOL)showGenericIndex:(GenericIndexClass *)index isTrigger:(BOOL) isTrigger isScene:(BOOL)isScene{
    if([self isToBeAdded:index.excludeFrom checkString:isScene?@"Scene":@"Rule"]){
        if(!isScene && isTrigger)
            return YES;
        else if ((!isTrigger || isScene) && !index.readOnly)
            return YES;
        
    }
    return NO;
}

+ (BOOL)showGenericValue:(GenericValue *)index isScene:(BOOL)isScene{
    if([self isToBeAdded:index.excludeFrom checkString:isScene?@"Scene":@"Rule"]){
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

+ (NSArray *)handleNestThermostat:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues modeFilter:(BOOL)modeFilter triggers:(NSMutableArray*)triggers{
    NSArray *newGenIndexVals = [RulesNestThermostat createNestThermostatGenericIndexValues:genericIndexValues deviceID:deviceID];
    if(modeFilter){
        NSString *matchData = nil;
        for(SFIButtonSubProperties *subProperty in triggers){
            if(subProperty.deviceId == deviceID && subProperty.index == 2){
                matchData = subProperty.matchData;
            }
        }
        newGenIndexVals = [RulesNestThermostat filterIndexesBasedOnModeForIndexes:newGenIndexVals deviceId:deviceID matchData:matchData];
    }
    return newGenIndexVals;
}

+(NSArray*)handleNestThermostatForSensor:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues{
    NSArray *newGenIndexVals = [RulesNestThermostat getNestGenericIndexVals:deviceID withGenericIndexValues:genericIndexValues];
    newGenIndexVals = [RulesNestThermostat filterIndexesBasedOnModeForIndexes:newGenIndexVals deviceId:deviceID matchData:[Device getValueForIndex:2 deviceID:deviceID]];
    return newGenIndexVals;
}




@end
