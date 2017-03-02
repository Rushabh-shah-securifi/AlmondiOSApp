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
//for scene-rule
+ (NSArray *)handleNestThermostat:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues modeFilter:(BOOL)modeFilter triggers:(NSMutableArray*)triggers{
    NSArray *newGenIndexVals = [self getNestGenericIndexVals:deviceID withGenericIndexValues:genericIndexValues isSceneRule:YES];
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

//for sensor
+(NSArray*)handleNestThermostatForSensor:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues{
    NSArray *newGenIndexVals = [self getNestGenericIndexVals:deviceID withGenericIndexValues:genericIndexValues isSceneRule:NO];
    newGenIndexVals = [self filterIndexesBasedOnHomeAway:deviceID genericIndexVals:newGenIndexVals];
    newGenIndexVals = [self filterDeviceMode:newGenIndexVals deviceId:deviceID modeVal:[Device getValueForIndex:2 deviceID:deviceID]];
    return newGenIndexVals;
}

+(NSDictionary*)handleNestThermostatFornewDevice:(NSDictionary*)genericIndexValues deviceID:(int)deviceID{
    NSDictionary *newGenIndexValsDict =  [self getNestGenericIndexValsNewDevices:deviceID withGenericIndexValues:genericIndexValues];
    newGenIndexValsDict = [self filterIndexesBasedOnHomeAwaynewDevice:deviceID genericIndexVals:newGenIndexValsDict];
//    newGenIndexValsDict = [self filterDeviceMode:newGenIndexValsDict deviceId:deviceID modeVal:[Device getValueForIndex:2 deviceID:deviceID]];
    return newGenIndexValsDict;
}

+(NSDictionary*)filterIndexesBasedOnHomeAwaynewDevice:(int)deviceID genericIndexVals:(NSDictionary*)genericIndexVals{
    NSString *awayMode = [Device getValueForIndex:8 deviceID:deviceID];
    BOOL isAway = ([awayMode isEqualToString:@"away"] || [awayMode isEqualToString:@"auto-away"]);//away_mode index
    
    if(isAway){
        NSMutableDictionary *newGenericIndexValues = [[NSMutableDictionary alloc] init];
        for(NSString *key in genericIndexVals){
            NSArray *gvalArr = genericIndexVals[key];
            NSMutableArray *tempArr = [NSMutableArray new];
            for (GenericIndexValue *genIndexVal in gvalArr) {
                int index = genIndexVal.index;
                if(index == 8){
                    [tempArr addObject:genIndexVal];
                }
            }
            [newGenericIndexValues setObject:tempArr forKey:key];
        }
        return newGenericIndexValues;
    }
    return genericIndexVals;
}

+(NSArray*)filterIndexesBasedOnHomeAway:(int)deviceID genericIndexVals:(NSArray*)genericIndexVals{
    NSString *awayMode = [Device getValueForIndex:8 deviceID:deviceID];
    BOOL isAway = ([awayMode isEqualToString:@"away"] || [awayMode isEqualToString:@"auto-away"]);//away_mode index
    
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

+ (NSArray*)getNestGenericIndexVals:(int)deviceID withGenericIndexValues:(NSArray*)genericIndexVals isSceneRule:(BOOL)isSceneRule{
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
            if(genIndexVal.index == 2 && !isSceneRule)//SFIDevicePropertyType_NEST_THERMOSTAT_MODE
                newGenericIndexVal = [self addOnlyModeOff:genIndexVal];
            
            //incaseof scene rule we do not add even off mode
            else if(genIndexVal.index == 2 && isSceneRule)//SFIDevicePropertyType_NEST_THERMOSTAT_MODE
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


+ (NSDictionary*)getNestGenericIndexValsNewDevices:(int)deviceID withGenericIndexValues:(NSDictionary*)genericIndexVals{
    
    NSLog(@"can cool value: %@", [Device getValueForIndex:12 deviceID:deviceID]);
    BOOL canCool = [[Device getValueForIndex:12 deviceID:deviceID] isEqualToString:@"true"];
    BOOL canHeat = [[Device getValueForIndex:13 deviceID:deviceID] isEqualToString:@"true"];
    BOOL hasFan = [[Device getValueForIndex:15 deviceID:deviceID] isEqualToString:@"true"];//9 is fan index
    NSLog(@"can cool: %d, can head: %d, hasfan: %d", canCool, canHeat, hasFan);
    NSString *awayMode = [Device getValueForIndex:8 deviceID:deviceID];
    
    
    
    
    NSMutableDictionary *newGenericIndexValues = [[NSMutableDictionary alloc] init];
    
    NSString *modeValue = [Device getValueForIndex:2 deviceID:deviceID];
    if (((modeValue != nil && [modeValue isEqualToString:@"heat"] && canHeat)|| (modeValue != nil && [modeValue isEqualToString:@"cool"] && canCool))) {
        
        
        for(NSString *key in genericIndexVals.allKeys){//strong because, deviceIndex will just be a pointer otherwise
            
            NSArray *tempArr = genericIndexVals[key];
            /*****    faster   *****/
            NSMutableArray *newMutableArr  = [NSMutableArray new];
            for (GenericIndexValue *gval in tempArr) {
                if (gval.index != 5 && gval.index != 6) {
                    [newMutableArr addObject:gval];
                }
            }
            
            [newGenericIndexValues setObject:newMutableArr forKey:key ];
        }
        
    }
    else if (modeValue != nil && [modeValue isEqualToString:@"heat-cool"]) {
        for(NSString *key in genericIndexVals.allKeys){//strong because, deviceIndex will just be a pointer otherwise
            
            NSArray *tempArr = genericIndexVals[key];
            /*****    faster   *****/
            NSMutableArray *newMutableArr  = [NSMutableArray new];
            for (GenericIndexValue *gval in tempArr) {
                if (gval.index != 3) {
                    [newMutableArr addObject:gval];
                }
            }
            [newGenericIndexValues setObject:newMutableArr forKey:key ];
        }
    }
    
    else {
        
        for(NSString *key in genericIndexVals.allKeys){//strong because, deviceIndex will just be a pointer otherwise
            
            NSArray *tempArr = genericIndexVals[key];
            /*****    faster   *****/
            NSMutableArray *newMutableArr  = [NSMutableArray new];
            for (GenericIndexValue *gval in tempArr) {
                if (gval.index != 5 && gval.index != 6 && gval.index != 3) {
                    [newMutableArr addObject:gval];
                }
            }
            [newGenericIndexValues setObject:newMutableArr forKey:key ];
        }
    }
    if (([modeValue isEqualToString:@"heat-cool"]) && canHeat && canCool) {
        
        GenericIndexValue *highValue = [self getIndexValueBasedOnID:newGenericIndexValues indexID:6];
        
        GenericIndexValue *lowValue = [self getIndexValueBasedOnID:newGenericIndexValues indexID:5];
        
        int highTemp = highValue?[highValue.genericValue.value intValue]:90;
        int lowTemp = lowValue?[lowValue.genericValue.value intValue]:50;
        

        int lowMax = highTemp - 3 > 50 ? highTemp - 3 : 50;
        int highLowest = lowTemp + 3 < 90 ? lowTemp + 3 : 90;
        
        
        lowValue.genericIndex.formatter.max = lowMax;
        highValue.genericIndex.formatter.min = highLowest;
    }

return newGenericIndexValues;
}

+(GenericIndexValue *)getIndexValueBasedOnID:(NSMutableDictionary *)indexList indexID:(int)indexId{

    for(NSString *key in indexList.allKeys){//strong because, deviceIndex will just be a pointer otherwise
        NSArray *tempArr = indexList[key];
        for (GenericIndexValue *gval in tempArr) {
            if (gval.index == indexId) {
                return  gval;
            }
        }
    }
    return nil;
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
+(GenericIndexValue *) removeAutoAwayMode:(GenericIndexValue *)genericIndexValue{
    NSString *awayMode = [Device getValueForIndex:8 deviceID:genericIndexValue.deviceID];
    BOOL isAutoAway = [awayMode isEqualToString:@"auto-away"];
    GenericIndexClass *newGenericIndex = [[GenericIndexClass alloc]initWithGenericIndex:genericIndexValue.genericIndex];
    
    NSMutableDictionary *newGenericValueDict = [NSMutableDictionary new];
    NSDictionary *currentGenericValueDict = genericIndexValue.genericIndex.values;
    
    for(NSString *keyValue in currentGenericValueDict){
        GenericValue *gVal = currentGenericValueDict[keyValue];
        if(isAutoAway){
            if([gVal.value isEqualToString:@"home"]){
                [newGenericValueDict setValue:gVal forKey:keyValue];
            }else if([gVal.value isEqualToString:@"auto-away"]){
                [newGenericValueDict setValue:gVal forKey:keyValue];
            }
        }else{
            if([gVal.value isEqualToString:@"home"]){
                [newGenericValueDict setValue:gVal forKey:keyValue];
            }else if([gVal.value isEqualToString:@"away"]){
                [newGenericValueDict setValue:gVal forKey:keyValue];
            }
        }
    }
    
    newGenericIndex.values = newGenericValueDict;
    genericIndexValue.genericIndex = newGenericIndex;
    return genericIndexValue;
}

//cancool-false, canheat-false -> show only mode "off"  button
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

//for sensor
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
        }
        else if([matchData isEqualToString:@"off"]){
            for(GenericIndexValue *genIndexVal in genericIndexValues){
                if(genIndexVal.index == 3 || genIndexVal.index == 5 ||genIndexVal.index == 6 ||genIndexVal.index == 9){
                    [newGenericIndexValues removeObject:genIndexVal];
                }
            }
        }
        else if([matchData isEqualToString:@"eco"]){
            for(GenericIndexValue *genIndexVal in genericIndexValues){
                if(genIndexVal.index == 3 || genIndexVal.index == 5 ||genIndexVal.index == 6){
                    [newGenericIndexValues removeObject:genIndexVal];
                }
            }
        }
    }
    
    NSLog(@"new genericindex values after : %@", newGenericIndexValues);
    return newGenericIndexValues;
}

//for rule scene
+(GenericIndexClass *)filterValues:(GenericIndexClass *)genericINdex deviceId:(int)deviceId{
    BOOL canCool = [[Device getValueForIndex:12 deviceID:deviceId] isEqualToString:@"true"];
    BOOL canHeat = [[Device getValueForIndex:13 deviceID:deviceId] isEqualToString:@"true"];
    BOOL hasFan = [[Device getValueForIndex:15 deviceID:deviceId] isEqualToString:@"true"];

    NSString *nestModeValue = [Device getValueForIndex:8 deviceID:deviceId];
     NSString *modeValue = [Device getValueForIndex:2 deviceID:deviceId];
    
    if ([genericINdex.ID isEqualToString:@"56"]) {
        
        if ([nestModeValue isEqualToString:@"away"])
            return nil;
      
        GenericIndexClass *newIndex = [genericINdex copy];
        NSMutableDictionary *newValues = [NSMutableDictionary new];
        for (NSString *key in newIndex.values.allKeys) {
            
            if([key isEqualToString:@"off"] || [key isEqualToString:@"eco"]){
                [newValues setObject:newIndex.values[key] forKey:key];
            }
            else if([key isEqualToString:@"heat-cool"] && canCool && canHeat){
                [newValues setObject:newIndex.values[key] forKey:key];
            }
            else if(([key isEqualToString:@"heat"] && canHeat)  || ([key isEqualToString:@"cool"] && canCool)){
                [newValues setObject:newIndex.values[key] forKey:key];
            }
        }
        newIndex.values = newValues;
        return newIndex;
    }
    else if ([genericINdex.ID isEqualToString:@"67"]) {
        
        GenericIndexClass *newIndex = [genericINdex copy];
        NSMutableDictionary *newValues = [NSMutableDictionary new];
        for (NSString *key in newIndex.values.allKeys) {
            
            if([key isEqualToString:@"off"] ){
                [newValues setObject:newIndex.values[key] forKey:key];
            }
            else if([key isEqualToString:@"heating"] && canHeat){
                [newValues setObject:newIndex.values[key] forKey:key];
            }
            else if(([key isEqualToString:@"cooling"] && canCool)){
                [newValues setObject:newIndex.values[key] forKey:key];
            }
        }
        newIndex.values = newValues;
        return newIndex;
    }
    
    else if ([genericINdex.ID isEqualToString:@"61"] && ((!hasFan || ([nestModeValue isEqualToString:@"away"])) || [modeValue isEqualToString:@"off"])){
        return nil;
    }
    else if ([genericINdex.ID isEqualToString:@"58"] ||[genericINdex.ID isEqualToString:@"59"]) {
       
        if ([nestModeValue isEqualToString:@"away"])
            return nil;
        if (canCool && canHeat)
            return genericINdex;
        else
            return nil;
    }
    
    else if ([genericINdex.ID isEqualToString:@"57"]) {
        if ([nestModeValue isEqualToString:@"away"])
            return nil;
        if (!canCool && !canHeat)
            return nil;
        else if (canHeat || canCool || (canHeat && canCool))
            return genericINdex;
        
    } else if ([genericINdex.ID isEqualToString:@"60"]) {
        GenericIndexClass *newIndex = [genericINdex copy];
        //Review abhishek - unnecessary arguments.
        NSMutableDictionary *newValues = [NSMutableDictionary new];
        for (NSString *key in newIndex.values.allKeys) {
            
            if(![key isEqualToString:@"auto-away"]){
                [newValues setObject:newIndex.values[key] forKey:key];
            }
        }
        newIndex.values = newValues;
        return newIndex;
    }
    return nil;
}
+(NSDictionary*)filterDeviceMode:(NSDictionary*)genericIndexValues deviceId:(sfi_id)deviceId modeVal:(NSString*)modeVal{
    BOOL canCool = [[Device getValueForIndex:12 deviceID:deviceId] isEqualToString:@"true"];
    BOOL canHeat = [[Device getValueForIndex:13 deviceID:deviceId] isEqualToString:@"true"];
    BOOL hasFan = [[Device getValueForIndex:15 deviceID:deviceId] isEqualToString:@"true"];
    
    NSLog(@"can cool: %d, can heat: %d, modeval: %@", canCool, canHeat, modeVal);
    
    NSMutableDictionary *newGenericIndexValues = [NSMutableDictionary new];
    NSLog(@"new genericindex values before : %@", newGenericIndexValues);
    
    if(modeVal != nil){
        if([modeVal isEqualToString:@"heat"] || [modeVal isEqualToString:@"cool"]){
            NSLog(@"one");
            for(NSString *key in genericIndexValues.allKeys){
                NSArray *gvalArr = genericIndexValues[key];
                NSMutableArray *temMutableArr = [NSMutableArray new];
                for(GenericIndexValue *genIndexVal in gvalArr){
                    if(genIndexVal.index != 5 && genIndexVal.index !=6){
                        [temMutableArr addObject:genIndexVal];
                    }
                }
                [newGenericIndexValues setObject:temMutableArr forKey:key];
                
            }
        }
        if([modeVal isEqualToString:@"heat-cool"] || ([modeVal isEqualToString:@"heat"] && !canHeat) || ([modeVal isEqualToString:@"cool"] && !canCool)){
            NSLog(@"two");
            for(NSString *key in genericIndexValues.allKeys){
                NSArray *gvalArr = genericIndexValues[key];
                NSMutableArray *temMutableArr = [NSMutableArray new];
                for(GenericIndexValue *genIndexVal in gvalArr){
                    if(genIndexVal.index != 3){
                        [temMutableArr addObject:genIndexVal];
                    }
                }
                [newGenericIndexValues setObject:temMutableArr forKey:key];
                
            }
        }
        else if([modeVal isEqualToString:@"off"] || [modeVal isEqualToString:@"eco"]){
            NSLog(@"three");
            for(NSString *key in genericIndexValues.allKeys){
                NSArray *gvalArr = genericIndexValues[key];
                NSMutableArray *temMutableArr = [NSMutableArray new];
                for(GenericIndexValue *genIndexVal in gvalArr){
                    if(genIndexVal.index != 3 && genIndexVal.index != 5 && genIndexVal.index != 6){
                        [temMutableArr addObject:genIndexVal];
                    }
                }
                [newGenericIndexValues setObject:temMutableArr forKey:key];
                
            }
//            for(GenericIndexValue *genIndexVal in genericIndexValues){
//                if(genIndexVal.index == 3 || genIndexVal.index == 5 ||genIndexVal.index == 6||genIndexVal.index == 9){
//                    [newGenericIndexValues removeObject:genIndexVal];
//                }
//            }
        }
//        else if([modeVal isEqualToString:@"eco"]){
//            for(GenericIndexValue *genIndexVal in genericIndexValues){
//                if(genIndexVal.index == 3 || genIndexVal.index == 5 ||genIndexVal.index == 6){
//                    [newGenericIndexValues removeObject:genIndexVal];
//                }
//            }
//        }
        
//        if([modeVal isEqualToString:@"heat-cool"] && canCool && canHeat){
//            NSArray *gvalArr;
//            for(NSString *key in genericIndexValues.allKeys){
//                gvalArr = genericIndexValues[key];
//            }
//            GenericIndexValue *lowVal = [self getGenericIndexValueForIndex:5 list:genericIndexValues];
//            GenericIndexValue *highVal = [self getGenericIndexValueForIndex:6 list:genericIndexValues];
//            int lowTemp = lowVal ? lowVal.genericValue.value.intValue: 50;
//            int highTemp = highVal ? highVal.genericValue.value.intValue: 90;
//            int lowMax = highTemp - 3 > 50 ? highTemp - 3: 50;
//            int highStart = lowTemp + 3 < 90 ? lowTemp + 3: 90;
//            lowVal.genericIndex.formatter.max = lowMax;
//            highVal.genericIndex.formatter.min = highStart;
//            
//        }
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
        else if([mode isEqualToString:@"eco"] && (subProperty.index == 5 || subProperty.index ==6 ||subProperty.index == 3)){
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
