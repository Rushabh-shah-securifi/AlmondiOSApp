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
    if(genericDevice != nil){
        NSDictionary *deviceIndexes = genericDevice.Indexes;
        NSArray *indexIDs = deviceIndexes.allKeys;
        for(NSString *indexID in indexIDs){
            DeviceIndex *deviceIndex = deviceIndexes[indexID];
            GenericIndexClass *genericIndexObj = toolkit.genericIndexes[deviceIndex.genericIndex];
            genericIndexObj.rowID = deviceIndex.rowID;
            
            NSString *checkString = isScene? @"Scene": @"Rule";

            SFIButtonSubProperties *subProperty = [self findSubProperty:triggers actions:(NSArray*)actions deviceID:deviceID index:indexID.intValue istrigger:isTrigger];
            GenericValue *genericValue = nil;
            if(subProperty != nil)
                genericValue = [GenericIndexUtil getMatchingGenericValueForGenericIndexID:genericIndexObj.ID forValue:subProperty.matchData];
            GenericIndexValue *genericIndexValue = [[GenericIndexValue alloc]initWithGenericIndex:genericIndexObj genericValue:genericValue index:indexID.intValue deviceID:deviceID];

            
            //rule trigger
            if(!isScene && isTrigger && [self isToBeAdded:genericIndexObj.excludeFrom checkString:checkString]){
                NSLog(@"util - rule trigger");
                [genericIndexValues addObject:genericIndexValue];
            }
            //scene action, rule action
            else if( (isScene || !isTrigger) && [genericIndexObj.type isEqualToString:ACTUATOR] && [self isToBeAdded:genericIndexObj.excludeFrom checkString:checkString]){
                NSLog(@"util - scene/rule action");
                [genericIndexValues addObject:genericIndexValue];
            }
        }
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

+(BOOL)isActionDevice:(int) deviceType{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericDeviceClass *genericDevice = toolkit.genericDevices[@(deviceType).stringValue];
    if(genericDevice != nil){
        if(genericDevice.isActuator && [self isToBeAdded:genericDevice.excludeFrom checkString:@"Action"]){
            return  YES;
        }
    }
    return NO;
}

+(BOOL)isTriggerDevice:(int)deviceType{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericDeviceClass *genericDevice = toolkit.genericDevices[@(deviceType).stringValue];
    if(genericDevice != nil){
        if([self isToBeAdded:genericDevice.excludeFrom checkString:@"Trigger"]){
            return  YES;
        }
    }
    return NO;
}

+ (BOOL)shouldYouSkipTheValue:(GenericValue*)genericValue isScene:(BOOL)isScene{
    if(isScene && ([RuleSceneUtil isToBeAdded:genericValue.excludeFrom checkString:@"Scene"] == NO))
        return YES;
    else if(!isScene && ([RuleSceneUtil isToBeAdded:genericValue.excludeFrom checkString:@"Rule"]) == NO)
        return YES;
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

+ (NSArray *)handleNestThermostat:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues isScene:(BOOL)isScene triggers:(NSMutableArray*)triggers{
    RulesNestThermostat *rulesNestThermostatObject = [[RulesNestThermostat alloc]init];
    NSArray *newGenIndexVals = [rulesNestThermostatObject createNestThermostatGenericIndexValues:genericIndexValues deviceID:deviceID];
    if(isScene){
        newGenIndexVals = [rulesNestThermostatObject filterIndexesBasedOnModeForIndexes:newGenIndexVals propertyList:triggers deviceId:deviceID];
    }
    return newGenIndexVals;
}

@end
