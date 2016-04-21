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

@implementation RuleSceneUtil


+(NSArray*)getActuatorIndexes:(int)deviceType{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSMutableArray *genericIndexes = [NSMutableArray new];
    GenericDeviceClass *genericDevice = toolkit.genericDevices[@(deviceType).stringValue];
    if(genericDevice != nil){
        NSDictionary *deviceIndexes = genericDevice.Indexes;
        NSArray *indexIDs = deviceIndexes.allKeys;
        for(NSString *indexID in indexIDs){
            DeviceIndex *deviceIndex = deviceIndexes[indexID];
            GenericIndexClass *genericIndex = toolkit.genericIndexes[deviceIndex.genericIndex];
            if([genericIndex.type isEqualToString:ACTUATOR] && [self isToBeAdded:genericDevice.excludeFrom checkString:@"Scene"]){ //if it is actuator and not to be excluded
                [genericIndexes addObject:genericIndex];
            }
        }
    }
    return genericIndexes;
}


+(BOOL)isActuatorDevice:(int) deviceType{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericDeviceClass *genericDevice = toolkit.genericDevices[@(deviceType).stringValue];
    if(genericDevice != nil){
        if(genericDevice.isActuator && [self isToBeAdded:genericDevice.excludeFrom checkString:@"Action"]){
            return  YES;
        }
    }
    return NO;
}

//datastring -> (index)trigger_action, trigger, action, nil | (device)scene, rule, scene_rule, nil
//isexclueded there at device,index,value level
+(BOOL) isToBeAdded:(NSString*)dataString checkString:(NSString*)checkString{
    if(dataString  != nil){
        if([dataString rangeOfString:checkString options:NSCaseInsensitiveSearch].location != NSNotFound){// data string contains check string
            return NO;
        }
    }
    return  YES;
}



@end
