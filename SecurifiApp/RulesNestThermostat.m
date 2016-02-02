//
//  RulesNestThermostat.m
//  Tableviewcellpratic
//
//  Created by Masood on 20/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import "RulesNestThermostat.h"
#import "SFIDeviceIndex.h"
#import "IndexValueSupport.h"

@implementation RulesNestThermostat

-(NSArray*) createNestThermostatDeviceIndexes:(NSArray*) deviceIndexes deviceValue:(SFIDeviceValue*)deviceValue{
    NSLog(@"createNestThermostatDeviceIndexes");
    deviceIndexes = [self nestThermostat:deviceValue withDeviceIndexes:deviceIndexes];
    deviceIndexes = [self adjustCellIDs:deviceValue withDeviceIndexes:deviceIndexes];
    return deviceIndexes;
}

//edit array or create new device index
//We can not just send valuetype, because we need to edit indexvalues
-(SFIDeviceIndex *) indexValuesForHasHeatWithDeviceIndex:(SFIDeviceIndex *) deviceIndex{
    NSMutableArray *newIndexValues = [[NSMutableArray alloc] init];
    SFIDevicePropertyType type = deviceIndex.valueType;
    // for only heat true
    if(type == SFIDevicePropertyType_NEST_THERMOSTAT_MODE){
        for(IndexValueSupport *indexValue in deviceIndex.indexValues){
            if ([indexValue.matchData caseInsensitiveCompare:@"heat"] == NSOrderedSame) {
                [newIndexValues addObject:indexValue];
            }else if([indexValue.matchData caseInsensitiveCompare:@"off"] == NSOrderedSame){
                [newIndexValues addObject:indexValue];
            }
        }
        deviceIndex.indexValues = newIndexValues;
    }
    
    else if(type == SFIDevicePropertyType_HVAC_STATE){
        for(IndexValueSupport *indexValue in deviceIndex.indexValues){
            if ([indexValue.matchData caseInsensitiveCompare:@"heating"] == NSOrderedSame) {
                [newIndexValues addObject:indexValue];
            }
            else if([indexValue.matchData caseInsensitiveCompare:@"off"] == NSOrderedSame){
                [newIndexValues addObject:indexValue];
            }
        }
        deviceIndex.indexValues = newIndexValues;
    }
    
    return deviceIndex;
}

-(SFIDeviceIndex *) indexValuesForHasCoolWithDeviceIndex:(SFIDeviceIndex *) deviceIndex{
    NSMutableArray *newIndexValues = [[NSMutableArray alloc] init];
    SFIDevicePropertyType type = deviceIndex.valueType;
    // for only heat true
    if(type == SFIDevicePropertyType_NEST_THERMOSTAT_MODE){
        for(IndexValueSupport *indexValue in deviceIndex.indexValues){
            if ([indexValue.matchData caseInsensitiveCompare:@"cool"] == NSOrderedSame) {
                [newIndexValues addObject:indexValue];
            }else if([indexValue.matchData caseInsensitiveCompare:@"off"] == NSOrderedSame){
                [newIndexValues addObject:indexValue];
            }
        }
        deviceIndex.indexValues = newIndexValues;
    }
    
    else if(type == SFIDevicePropertyType_HVAC_STATE){
        for(IndexValueSupport *indexValue in deviceIndex.indexValues){
            if ([indexValue.matchData caseInsensitiveCompare:@"cooling"] == NSOrderedSame) {
                [newIndexValues addObject:indexValue];
            }
            else if([indexValue.matchData caseInsensitiveCompare:@"off"] == NSOrderedSame){
                [newIndexValues addObject:indexValue];
            }
        }
        deviceIndex.indexValues = newIndexValues;
    }
    
    return deviceIndex;
}

-(NSArray*) nestThermostat:(SFIDeviceValue*) deviceValue withDeviceIndexes:(NSArray*) deviceIndexes{
    //temp vars, pass as arguments
    //    SFIDeviceValue *deviceValue;
    SFIDeviceKnownValues *currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_COOL];
    BOOL canCool = [currentDeviceValue boolValue];
    currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_HEAT];
    BOOL canHeat = [currentDeviceValue boolValue];
    currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_HAS_FAN];
    BOOL hasFan = [currentDeviceValue boolValue];
    NSLog(@"can cool: %d\ncan heat: %d\nhasfan: %d", canCool, canHeat, hasFan);
    //    NSArray *deviceIndexes;
    //temp
    NSMutableArray *newDeviceIndexes = [[NSMutableArray alloc] init];
    for(__strong SFIDeviceIndex *deviceIndex in deviceIndexes){ //strong because, deviceIndex will just be a pointer otherwise
        
        /*****    faster   *****/
        NSLog(@"start for loop");
        if(canCool == NO && canHeat == NO){
            if(deviceIndex.valueType == SFIDevicePropertyType_NEST_THERMOSTAT_MODE)
                continue;
            else if(deviceIndex.valueType == SFIDevicePropertyType_THERMOSTAT_TARGET)
                continue;
            else if(deviceIndex.valueType == SFIDevicePropertyType_THERMOSTAT_RANGE_LOW)
                continue;
            else if(deviceIndex.valueType == SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH)
                continue;
            else if(deviceIndex.valueType == SFIDevicePropertyType_HVAC_STATE)
                continue;
        }
        else if(canCool == NO && canHeat == YES){
            if(deviceIndex.valueType == SFIDevicePropertyType_NEST_THERMOSTAT_MODE){
                //create new device index
                deviceIndex = [self indexValuesForHasHeatWithDeviceIndex:deviceIndex];
            }
            else if(deviceIndex.valueType == SFIDevicePropertyType_THERMOSTAT_RANGE_LOW)
                continue;
            else if(deviceIndex.valueType == SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH)
                continue;
            else if (deviceIndex.valueType == SFIDevicePropertyType_HVAC_STATE){
                //create new deivce index
                deviceIndex = [self indexValuesForHasHeatWithDeviceIndex:deviceIndex];
            }
        }
        else if(canCool == YES && canHeat == NO){
            if(deviceIndex.valueType == SFIDevicePropertyType_NEST_THERMOSTAT_MODE){
                //create new device index
                deviceIndex = [self indexValuesForHasCoolWithDeviceIndex:deviceIndex];
            }
            else if(deviceIndex.valueType == SFIDevicePropertyType_THERMOSTAT_RANGE_LOW)
                continue;
            else if(deviceIndex.valueType == SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH)
                continue;
            else if (deviceIndex.valueType == SFIDevicePropertyType_HVAC_STATE){
                //create new deivce index
                deviceIndex = [self indexValuesForHasCoolWithDeviceIndex:deviceIndex];
            }
        }
        if(hasFan == NO){
            if(deviceIndex.valueType == SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE){
                NSLog(@"has no fan");
                continue;
            }
        }
        [newDeviceIndexes addObject:deviceIndex];
    }//for loop
    return newDeviceIndexes;
}



-(NSArray*) adjustCellIDs:(SFIDeviceValue*)deviceValue withDeviceIndexes:(NSArray*) newDeviceIndexes{
    SFIDeviceKnownValues *currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_COOL];
    BOOL canCool = [currentDeviceValue boolValue];
    currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_CAN_HEAT];
    BOOL canHeat = [currentDeviceValue boolValue];
    currentDeviceValue = [deviceValue knownValuesForProperty:SFIDevicePropertyType_HAS_FAN];
    BOOL hasFan = [currentDeviceValue boolValue];
    NSLog(@"can cool: %d\ncan heat: %d\nhasfan: %d", canCool, canHeat, hasFan);
    
    
    for(SFIDeviceIndex *deviceIndex in newDeviceIndexes){ //strong because, deviceIndex will just be a pointer otherwise
        SFIDevicePropertyType type = deviceIndex.valueType;
        /*****    faster   *****/
        NSLog(@"start for loop");
        if(canCool == NO && canHeat == NO){
            NSLog(@"canCool == NO && canHeat == NO");
            if(type == SFIDevicePropertyType_HUMIDITY){
                deviceIndex.cellId = 1;
            }
            else if(type == SFIDevicePropertyType_CURRENT_TEMPERATURE){
                deviceIndex.cellId = 1;
            }
            else if(type == SFIDevicePropertyType_ISONLINE){
                deviceIndex.cellId = 2;
            }
            else if(type == SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE){
                deviceIndex.cellId = 2;
            }
        }
        else if((canCool == YES && canHeat == NO) || (canCool == NO && canHeat == YES)){
            NSLog(@"canCool == YES && canHeat == NO) || (canCool == NO && canHeat == YES");
            NSLog(@"before - deviceindex: %d cellid: %d", deviceIndex.indexID, deviceIndex.cellId);
            if(type == SFIDevicePropertyType_THERMOSTAT_TARGET){
                deviceIndex.cellId = 2;
            }
            else if(type == SFIDevicePropertyType_HUMIDITY){
                deviceIndex.cellId = 1;
            }
            else if(type == SFIDevicePropertyType_CURRENT_TEMPERATURE){
                deviceIndex.cellId = 1;
            }
            else if(type == SFIDevicePropertyType_NEST_THERMOSTAT_MODE){
                deviceIndex.cellId = 3;
            }
            else if(type == SFIDevicePropertyType_ISONLINE){
                deviceIndex.cellId = 3;
            }
            else if(type == SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE){
                deviceIndex.cellId = 4;
            }
            else if(type == SFIDevicePropertyType_HVAC_STATE){
                deviceIndex.cellId = 4;
            }
            NSLog(@"after - deviceindex: %d cellid: %d", deviceIndex.indexID, deviceIndex.cellId);
        }
        //        else if(canCool == NO && canHeat == YES){
        //
        //        }
        if(hasFan == NO){
            NSLog(@"hasFan == NO");
            if(deviceIndex.valueType == SFIDevicePropertyType_HUMIDITY){
                deviceIndex.cellId = 1;
            }
        }
    }//for loop
    return newDeviceIndexes;
}




@end
