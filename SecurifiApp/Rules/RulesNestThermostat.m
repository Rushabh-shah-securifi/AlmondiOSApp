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

+ (NSArray *)handleNestThermostat:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues modeFilter:(BOOL)modeFilter triggers:(NSMutableArray*)triggers{
    NSArray *newGenIndexVals = [self getNestGenericIndexVals:deviceID withGenericIndexValues:genericIndexValues];
    if(modeFilter){
        NSString *matchData = nil;
        for(SFIButtonSubProperties *subProperty in triggers){
            if(subProperty.deviceId == deviceID && subProperty.index == 2){
                matchData = subProperty.matchData;
            }
        }
        newGenIndexVals = [self filterIndexesBasedOnModeForIndexes:newGenIndexVals deviceId:deviceID matchData:matchData];
    }
    return newGenIndexVals;
}

+(NSArray*)handleNestThermostatForSensor:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues{
    NSArray *newGenIndexVals = [self getNestGenericIndexVals:deviceID withGenericIndexValues:genericIndexValues];
    newGenIndexVals = [self filterIndexesBasedOnHomeAway:deviceID genericIndexVals:newGenIndexVals];
    newGenIndexVals = [self filterDeviceMode:newGenIndexVals deviceId:deviceID modeVal:[Device getValueForIndex:2 deviceID:deviceID]];
    return newGenIndexVals;
}


+(NSArray*)filterIndexesBasedOnHomeAway:(int)deviceID genericIndexVals:(NSArray*)genericIndexVals{
    BOOL isAway = [[Device getValueForIndex:8 deviceID:deviceID] isEqualToString:@"away"];//away_mode index
    
    if(isAway){
        NSMutableArray *newGenericIndexValues = [[NSMutableArray alloc] init];
        for(GenericIndexValue *genIndexVal in genericIndexVals){
            int index = genIndexVal.index;
            if(index == -1 || index == -2 || index == -3 || index == 8){
                [newGenericIndexValues addObject:genIndexVal];
            }
        }
        return newGenericIndexValues;
    }
    return genericIndexVals;
}


+ (NSArray*)getNestGenericIndexVals:(int)deviceID withGenericIndexValues:(NSArray*)genericIndexVals{
    NSLog(@"can cool value: %@", [Device getValueForIndex:12 deviceID:deviceID]);
    BOOL canCool = [[Device getValueForIndex:12 deviceID:deviceID] isEqualToString:@"true"];
    BOOL canHeat = [[Device getValueForIndex:13 deviceID:deviceID] isEqualToString:@"true"];
    BOOL hasFan = [[Device getValueForIndex:15 deviceID:deviceID] isEqualToString:@"true"];//9 is fan index
    NSLog(@"can cool: %d, can head: %d, hasfan: %d", canCool, canHeat, hasFan);
    NSMutableArray *newGenericIndexValues = [[NSMutableArray alloc] init];
    
    for(GenericIndexValue *genIndexVal in genericIndexVals){//strong because, deviceIndex will just be a pointer otherwise
        
        /*****    faster   *****/
        GenericIndexValue *newGenericIndexVal = nil;
        if(canCool == NO && canHeat == NO){
            if(genIndexVal.index == 2)//SFIDevicePropertyType_NEST_THERMOSTAT_MODE
                newGenericIndexVal = [self addOnlyModeOff:genIndexVal];
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
        if(hasFan == NO && genIndexVal.index == 9)//SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE
            continue;
        if(genIndexVal.index == 8)//homeaway
            newGenericIndexVal = [self removeAutoAwayMode:genIndexVal];
        
        if(newGenericIndexVal == nil)
            [newGenericIndexValues addObject:genIndexVal];
        else
            [newGenericIndexValues addObject:newGenericIndexVal];
    }//for loop
    return newGenericIndexValues;
}

+(GenericIndexValue *) removeAutoAwayMode:(GenericIndexValue *)genericIndexValue{
    GenericIndexClass *newGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genericIndexValue.genericIndex];
    
    NSMutableDictionary *newGenericValueDict = [NSMutableDictionary new];
    NSDictionary *currentGenericValueDict = genericIndexValue.genericIndex.values;
    
    for(NSString *keyValue in currentGenericValueDict){
        GenericValue *gVal = currentGenericValueDict[keyValue];
        if([gVal.value isEqualToString:@"home"]){
            [newGenericValueDict setValue:gVal forKey:keyValue];
        }else if([gVal.value isEqualToString:@"away"]){
            [newGenericValueDict setValue:gVal forKey:keyValue];
        }
    }
    
    newGenericIndex.values = newGenericValueDict;
    genericIndexValue.genericIndex = newGenericIndex;
    return genericIndexValue;
}

//cancool-false, canheat-false -> show only mode "off" button
+ (GenericIndexValue *)addOnlyModeOff:(GenericIndexValue *)genericIndexValue{
    GenericIndexClass *newGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genericIndexValue.genericIndex];
    
    NSMutableDictionary *newGenericValueDict = [NSMutableDictionary new];
    NSDictionary *currentGenericValueDict = genericIndexValue.genericIndex.values;
    
    for(NSString *keyValue in currentGenericValueDict){
        GenericValue *gVal = currentGenericValueDict[keyValue];
        if([gVal.value isEqualToString:@"off"]){
            [newGenericValueDict setValue:gVal forKey:keyValue];
        }
    }
    
    newGenericIndex.values = newGenericValueDict;
    genericIndexValue.genericIndex = newGenericIndex;
    return genericIndexValue;
}

//edit array or create new device index
//We can not just send valuetype, because we need to edit indexvalues
+ (GenericIndexValue *)indexValuesForHasHeatWithDeviceIndex:(GenericIndexValue *)genericIndexValue index:(int)index{
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


+ (GenericIndexValue *)indexValuesForHasCoolWithDeviceIndex:(GenericIndexValue *)genericIndexValue index:(int)index{
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


+(NSArray*)filterIndexesBasedOnModeForIndexes:(NSArray*)genericIndexValues deviceId:(sfi_id)deviceId matchData:(NSString*)matchData{
    NSMutableArray *newGenericIndexValues = [genericIndexValues mutableCopy];
    NSLog(@"new genericindex values before : %@", newGenericIndexValues);

    if(matchData != nil){
        if([matchData isEqualToString:@"heat"] || [matchData isEqualToString:@"cool"]){
            for(GenericIndexValue *genIndexVal in genericIndexValues){
                if(genIndexVal.index == 5 || genIndexVal.index ==6){
                    [newGenericIndexValues removeObject:genIndexVal];
                }
            }
        }
        else if([matchData isEqualToString:@"heat-cool"] ){
            for(GenericIndexValue *genIndexVal in genericIndexValues){
                if(genIndexVal.index == 3){
                    [newGenericIndexValues removeObject:genIndexVal];
                }
            }
        }else{
            for(GenericIndexValue *genIndexVal in genericIndexValues){
                if(genIndexVal.index == 3 || genIndexVal.index == 5 ||genIndexVal.index == 6 ||genIndexVal.index == 9){
                    [newGenericIndexValues removeObject:genIndexVal];
                }
            }
        }
    }
    
    NSLog(@"new genericindex values after : %@", newGenericIndexValues);
    return newGenericIndexValues;
}

+(NSArray*)filterDeviceMode:(NSArray*)genericIndexValues deviceId:(sfi_id)deviceId modeVal:(NSString*)modeVal{
    BOOL canCool = [[Device getValueForIndex:12 deviceID:deviceId] isEqualToString:@"true"];
    BOOL canHeat = [[Device getValueForIndex:13 deviceID:deviceId] isEqualToString:@"true"];
    NSLog(@"can cool: %d, can heat: %d, modeval: %@", canCool, canHeat, modeVal);
    
    NSMutableArray *newGenericIndexValues = [genericIndexValues mutableCopy];
    NSLog(@"new genericindex values before : %@", newGenericIndexValues);
    
    if(modeVal != nil){
        if([modeVal isEqualToString:@"heat"] || [modeVal isEqualToString:@"cool"]){
            NSLog(@"one");
            for(GenericIndexValue *genIndexVal in genericIndexValues){
                if(genIndexVal.index == 5 || genIndexVal.index ==6){
                    [newGenericIndexValues removeObject:genIndexVal];
                }
            }
        }
        if([modeVal isEqualToString:@"heat-cool"] || ([modeVal isEqualToString:@"heat"] && !canHeat) || ([modeVal isEqualToString:@"cool"] && !canCool)){
            NSLog(@"two");
            for(GenericIndexValue *genIndexVal in genericIndexValues){
                if(genIndexVal.index == 3){
                    [newGenericIndexValues removeObject:genIndexVal];
                }
            }
        }
        else if([modeVal isEqualToString:@"off"]){
            NSLog(@"three");
            for(GenericIndexValue *genIndexVal in genericIndexValues){
                if(genIndexVal.index == 3 || genIndexVal.index == 5 ||genIndexVal.index == 6||genIndexVal.index == 9){
                    [newGenericIndexValues removeObject:genIndexVal];
                }
            }
        }
        
        if([modeVal isEqualToString:@"heat-cool"] && canCool && canHeat){
            GenericIndexValue *lowVal = [self getGenericIndexValueForIndex:5 list:genericIndexValues];
            GenericIndexValue *highVal = [self getGenericIndexValueForIndex:6 list:genericIndexValues];
            int lowTemp = lowVal ? lowVal.genericValue.value.intValue: 50;
            int highTemp = highVal ? highVal.genericValue.value.intValue: 90;
            int lowMax = highTemp - 3 > 50 ? highTemp - 3: 50;
            int highStart = lowTemp + 3 < 90 ? lowTemp + 3: 90;
            lowVal.genericIndex.formatter.max = lowMax;
            highVal.genericIndex.formatter.min = highStart;
            
        }
    }
    
    NSLog(@"new genericindex values after : %@", newGenericIndexValues);
    return newGenericIndexValues;
}

+(GenericIndexValue*)getGenericIndexValueForIndex:(int)index list:(NSArray*)genericIndexValues{
    for(GenericIndexValue *genericIndVal in genericIndexValues){
        if(genericIndVal.index == index)
            return genericIndVal;
    }
    return nil;
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
        else if([mode isEqualToString:@"off"] && (subProperty.index == 5 || subProperty.index ==6 ||subProperty.index == 3 || subProperty.index == 9)){
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
 away_mode - 8
 isOnline - 11
 fanState - 9
 temperature - 10
 hvac - 16
 */

//-(void)handleNest3PointDiffForIndex:(int)index newValue:(NSString*)value{
//    NSLog(@"handleNest3PointDiffForIndex - index: %d, value: %@", index, value);
//    NSArray *scrollSubViews = [self.indexesScroll subviews];
//    for(UIView *view in scrollSubViews){
//        NSLog(@"view: %@", view);
//        if(![view isKindOfClass:[UIImageView class]]){
//            UIView *insideView = [[view subviews] objectAtIndex:1];
//            if([insideView isKindOfClass:[HorizontalPicker class]]){
//                NSLog(@"horizantal picker");
//                HorizontalPicker *picker = (HorizontalPicker*)insideView;
//
//                if(picker.genericIndexValue.index == 6 && index == 5){
//                    if([picker.genericIndexValue.genericValue.value intValue] - [value intValue] < 3){
//                        NSLog(@"updating value");
//                        [picker.horzPicker scrollToElement:([value intValue] + 3) + picker.genericIndexValue.genericIndex.formatter.min animated:YES];
//                    }
//                }else if(picker.genericIndexValue.index == 5 && index == 6){
//                    if([value intValue] - [picker.genericIndexValue.genericValue.value intValue]< 3){
//                        [picker.horzPicker scrollToElement:([value intValue]-3) + picker.genericIndexValue.genericIndex.formatter.min animated:YES];
//                    }
//                }
//
//            }
//        }
//    }
//}

+ (void)adjustCellIDs:(int)deviceID withGenericIndexValues:(NSArray*)genericIndexValues{
    BOOL canCool = [[Device getValueForIndex:12 deviceID:deviceID] isEqualToString:@"true"];
    BOOL canHeat = [[Device getValueForIndex:13 deviceID:deviceID] isEqualToString:@"true"];
    BOOL hasFan = [[Device getValueForIndex:15 deviceID:deviceID] isEqualToString:@"true"];//9 is fan index
    
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


@end
