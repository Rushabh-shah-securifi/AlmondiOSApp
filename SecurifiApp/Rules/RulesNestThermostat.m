//
//  RulesNestThermostat.m
//  Tableviewcellpratic
//
//  Created by Masood on 20/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import "RulesNestThermostat.h"
#import "IndexValueSupport.h"
#import "SFIButtonSubProperties.h"
#import "GenericIndexValue.h"
#import "GenericIndexClass.h"
#import "GenericValue.h"

@implementation RulesNestThermostat

-(NSArray*) createNestThermostatGenericIndexValues:(NSArray*)genericIndexValues deviceID:(int)deviceID{
    NSArray* newGenericIndexValues = [self nestThermostat:deviceID withGenericIndexValues:genericIndexValues];
    [self adjustCellIDs:deviceID withGenericIndexValues:newGenericIndexValues];
    return newGenericIndexValues;
}

- (NSArray*)nestThermostat:(int)deviceID withGenericIndexValues:(NSArray*)genericIndexVals{
    NSString *value = [Device getValueForIndex:2 deviceID:deviceID];//2 is mode index
    BOOL canCool = [self canCool:value];
    BOOL canHeat = [self canHeat:value];
    value = [Device getValueForIndex:9 deviceID:deviceID];//9 is fan index
    BOOL hasFan = [self hasFan:value];
    
    NSMutableArray *newGenericIndexValues = [[NSMutableArray alloc] init];
    
    for(GenericIndexValue *genIndexVal in genericIndexVals){//strong because, deviceIndex will just be a pointer otherwise
        
        /*****    faster   *****/
        GenericIndexValue *newGenericIndexVal = nil;
        if(canCool == NO && canHeat == NO){
            if(genIndexVal.index == 2)//SFIDevicePropertyType_NEST_THERMOSTAT_MODE
                continue;
            else if(genIndexVal.index == 3)//SFIDevicePropertyType_THERMOSTAT_TARGET
                continue;
            else if(genIndexVal.index == 5)//SFIDevicePropertyType_THERMOSTAT_RANGE_LOW
                continue;
            else if(genIndexVal.index == 6)//SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH
                continue;
            else if(genIndexVal.index == 16)//SFIDevicePropertyType_HVAC_STATE
                continue;
        }
        else if(canCool == NO && canHeat == YES){
            if(genIndexVal.index == 2){//SFIDevicePropertyType_NEST_THERMOSTAT_MODE
                //create new device index
                newGenericIndexVal = [self indexValuesForHasHeatWithDeviceIndex:genIndexVal index:genIndexVal.index];
            }
            else if(genIndexVal.index == 5)//SFIDevicePropertyType_THERMOSTAT_RANGE_LOW
                continue;
            else if(genIndexVal.index == 6)//SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH
                continue;
            else if (genIndexVal.index == 16){//SFIDevicePropertyType_HVAC_STATE
                //create new deivce index
                newGenericIndexVal = [self indexValuesForHasHeatWithDeviceIndex:genIndexVal index:genIndexVal.index];
            }
        }
        else if(canCool == YES && canHeat == NO){
            if(genIndexVal.index == 2){//SFIDevicePropertyType_NEST_THERMOSTAT_MODE
                //create new device index
                newGenericIndexVal = [self indexValuesForHasCoolWithDeviceIndex:genIndexVal index:genIndexVal.index];
            }
            else if(genIndexVal.index == 5)//SFIDevicePropertyType_THERMOSTAT_RANGE_LOW
                continue;
            else if(genIndexVal.index == 6)//SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH
                continue;
            else if (genIndexVal.index == 16){//SFIDevicePropertyType_HVAC_STATE
                //create new deivce index
                newGenericIndexVal = [self indexValuesForHasCoolWithDeviceIndex:genIndexVal index:genIndexVal.index];
            }
        }
        if(hasFan == NO){
            if(genIndexVal.index == 9){//SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE
                continue;
            }
        }
        if(newGenericIndexVal == nil)
            [newGenericIndexValues addObject:genIndexVal];
        else
            [newGenericIndexValues addObject:newGenericIndexVal];
    }//for loop
    return newGenericIndexValues;
}

//edit array or create new device index
//We can not just send valuetype, because we need to edit indexvalues
- (GenericIndexValue *)indexValuesForHasHeatWithDeviceIndex:(GenericIndexValue *)genericIndexValue index:(int)index{
    GenericIndexClass *newGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genericIndexValue.genericIndex];
    
    NSMutableDictionary *newGenericValueDict = [NSMutableDictionary new];
    NSDictionary *currentGenericValueDict = genericIndexValue.genericIndex.values;
    
    if(index == 2){
        for(NSString *keyValue in currentGenericValueDict){
            GenericValue *gVal = currentGenericValueDict[keyValue];
            if([gVal.value isEqualToString:@"heat"])
                [newGenericValueDict setValue:gVal forKey:keyValue];
            else if([gVal.value isEqualToString:@"off"]){
                [newGenericValueDict setValue:gVal forKey:keyValue];
            }
        }
    }
    else if(index == 16){
        for(NSString *keyValue in currentGenericValueDict){
            GenericValue *gVal = currentGenericValueDict[keyValue];
            if([gVal.value isEqualToString:@"heating"])
                [newGenericValueDict setValue:gVal forKey:keyValue];
            else if([gVal.value isEqualToString:@"off"]){
                [newGenericValueDict setValue:gVal forKey:keyValue];
            }
        }
    }
    newGenericIndex.values = newGenericValueDict;
    genericIndexValue.genericIndex = newGenericIndex;
    return genericIndexValue;

}


- (GenericIndexValue *)indexValuesForHasCoolWithDeviceIndex:(GenericIndexValue *)genericIndexValue index:(int)index{
    GenericIndexClass *newGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genericIndexValue.genericIndex];
    
    NSMutableDictionary *newGenericValueDict = [NSMutableDictionary new];
    NSDictionary *currentGenericValueDict = genericIndexValue.genericIndex.values;
    
    if(index == 2){
        for(NSString *keyValue in currentGenericValueDict){
            GenericValue *gVal = currentGenericValueDict[keyValue];
            if([gVal.value isEqualToString:@"cool"])
                [newGenericValueDict setValue:gVal forKey:keyValue];
            else if([gVal.value isEqualToString:@"off"]){
                [newGenericValueDict setValue:gVal forKey:keyValue];
            }
        }
    }
    else if(index == 16){
        for(NSString *keyValue in currentGenericValueDict){
            GenericValue *gVal = currentGenericValueDict[keyValue];
            if([gVal.value isEqualToString:@"cooling"])
                [newGenericValueDict setValue:gVal forKey:keyValue];
            else if([gVal.value isEqualToString:@"off"]){
                [newGenericValueDict setValue:gVal forKey:keyValue];
            }
        }
    }
    newGenericIndex.values = newGenericValueDict;
    genericIndexValue.genericIndex = newGenericIndex;
    return genericIndexValue;
}


- (void)adjustCellIDs:(int)deviceID withGenericIndexValues:(NSArray*)genericIndexValues{
    NSString *value = [Device getValueForIndex:2 deviceID:deviceID];//2 is mode index
    BOOL canCool = [self canCool:value];
    BOOL canHeat = [self canHeat:value];
    value = [Device getValueForIndex:9 deviceID:deviceID];//9 is fan index
    BOOL hasFan = [self hasFan:value];
    
    for(GenericIndexValue *genIndexVal in genericIndexValues){ //strong because, deviceIndex will just be a pointer otherwise
        /*****    faster   *****/
        GenericIndexClass *genericIndex = genIndexVal.genericIndex;
        if(canCool == NO && canHeat == NO){
            if(genIndexVal.index == 4){//SFIDevicePropertyType_HUMIDITY
                genericIndex.rowID = @"1";
            }
            else if(genIndexVal.index == 10){//SFIDevicePropertyType_CURRENT_TEMPERATURE
                genericIndex.rowID = @"1";
            }
            else if(genIndexVal.index == 11){//SFIDevicePropertyType_ISONLINE
                genericIndex.rowID = @"2";
            }
            else if(genIndexVal.index == 9){//SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE
                genericIndex.rowID = @"2";
            }
        }
        else if((canCool == YES && canHeat == NO) || (canCool == NO && canHeat == YES)){
            if(genIndexVal.index == 3){//SFIDevicePropertyType_THERMOSTAT_TARGET
                genericIndex.rowID = @"2";
            }
            else if(genIndexVal.index == 4){//SFIDevicePropertyType_HUMIDITY
                genericIndex.rowID = @"1";
            }
            else if(genIndexVal.index == 10){//SFIDevicePropertyType_CURRENT_TEMPERATURE
                genericIndex.rowID = @"1";
            }
            else if(genIndexVal.index == 2){//SFIDevicePropertyType_NEST_THERMOSTAT_MODE
                genericIndex.rowID = @"3";
            }
            else if(genIndexVal.index == 11){//SFIDevicePropertyType_ISONLINE
                genericIndex.rowID = @"3";
            }
            else if(genIndexVal.index == 9){//SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE
                genericIndex.rowID = @"4";
            }
            else if(genIndexVal.index == 16){//SFIDevicePropertyType_HVAC_STATE
                genericIndex.rowID = @"4";
            }
        }
        if(hasFan == NO){
            if(genIndexVal.index == 4){//SFIDevicePropertyType_HUMIDITY
                genericIndex.rowID = @"1";
            }
        }
    }//for loop
}


- (BOOL)canCool:(NSString*)value{
    if([value.lowercaseString isEqualToString:@"cool"] || [value.lowercaseString isEqualToString:@"heat-cool"]){
        return YES;
    }
    return NO;
}

- (BOOL)canHeat:(NSString*)value{
    if([value.lowercaseString isEqualToString:@"heat"] || [value.lowercaseString isEqualToString:@"heat-cool"]){
        return YES;
    }
    return NO;
}

-(BOOL)hasFan:(NSString*)value{
    return [value isEqualToString:@"true"];
}


-(NSArray*)filterIndexesBasedOnModeForIndexes:(NSArray*)genericIndexValues propertyList:(NSMutableArray*)propertyList deviceId:(sfi_id)deviceId{
    NSString *matchData;
    NSMutableArray *newGenericIndexValues = [genericIndexValues mutableCopy];
    
    for(SFIButtonSubProperties *subProperty in propertyList){
        if(subProperty.deviceId == deviceId && subProperty.index == 2){
            matchData = subProperty.matchData;
        }
    }
    
    if([matchData isEqualToString:@"heat"] || [matchData isEqualToString:@"cool"]){
        for(GenericIndexValue *genIndexVal in genericIndexValues){
            if(genIndexVal.index == 5 || genIndexVal.index ==6){
                [newGenericIndexValues removeObject:genIndexVal];
            }
        }
    }
    else if([matchData isEqualToString:@"heat-cool"]){
        for(GenericIndexValue *genIndexVal in genericIndexValues){
            if(genIndexVal.index == 3){
                [newGenericIndexValues removeObject:genIndexVal];
            }
        }
    }else{
        for(GenericIndexValue *genIndexVal in genericIndexValues){
            if(genIndexVal.index == 3 || genIndexVal.index == 5 ||genIndexVal.index == 6){
                [newGenericIndexValues removeObject:genIndexVal];
            }
        }
    }
    
    return newGenericIndexValues;
}

+(void)removeTemperatureIndexes:(int)deviceId mode:(NSString *)mode entries:(NSMutableArray *)entries{
    NSMutableArray *newPropertyList = [NSMutableArray new];
    
    for(SFIButtonSubProperties *subProperty in entries){
        if(subProperty.deviceId != deviceId)
            continue;
        if(([mode isEqualToString:@"heat"] || [mode isEqualToString:@"cool"]) &&(subProperty.index == 5 || subProperty.index ==6))
            [newPropertyList addObject:subProperty];
        else if([mode isEqualToString:@"heat-cool"] && subProperty.index == 3)
            [newPropertyList addObject:subProperty];
        else if([mode isEqualToString:@"off"] && (subProperty.index == 5 || subProperty.index ==6 ||subProperty.index == 3)){
            [newPropertyList addObject:subProperty];
        }
    }
    [entries removeObjectsInArray:newPropertyList];
}
/*
 mode - 2
 target - 3
 humidity - 4
 rangelow - 5
 rangehigh - 6
 isOnline - 11
 fanState - 9
 temperature - 10
 hvac - 16
 */
@end
