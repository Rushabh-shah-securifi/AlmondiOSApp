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
#import "GenericValue.h"

@implementation RuleSceneUtil

+(NSDictionary*)getIndexesDicForID:(int)deviceID type:(int)deviceType isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene triggers:(NSMutableArray *)triggers action:(NSMutableArray *)actions{
    NSArray *genericIndexValues = [self getGenericIndexValueArrayForID:deviceID type:deviceType isTrigger:isTrigger isScene:isScene triggers:triggers action:actions];
    
    NSMutableDictionary *rowIndexValDict = [NSMutableDictionary new];
    for(GenericIndexValue *genericIndexValue in genericIndexValues){
        [self addToDictionary:rowIndexValDict GenericIndexVal:genericIndexValue rowID:genericIndexValue.genericIndex.rowID.intValue];
    }
    return rowIndexValDict;
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
            if(!isScene && isTrigger && [self isToBeAdded:genericDevice.excludeFrom checkString:checkString]){
                NSLog(@"util - rule trigger");
                [genericIndexValues addObject:genericIndexValue];
            }
            //scene action, rule action
            else if( (isScene || !isTrigger) && [genericIndexObj.type isEqualToString:ACTUATOR] && [self isToBeAdded:genericDevice.excludeFrom checkString:checkString]){
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

+(BOOL) isToBeAdded:(NSString*)dataString checkString:(NSString*)checkString{
    if(dataString  != nil){
        if([dataString rangeOfString:checkString options:NSCaseInsensitiveSearch].location != NSNotFound){// data string contains check string
            return NO;
        }
    }
    return  YES;
}



@end
