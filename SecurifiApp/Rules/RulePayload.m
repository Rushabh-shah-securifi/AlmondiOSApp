//
//  RulePayload.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 13/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "RulePayload.h"
#import "SFIButtonSubProperties.h"
#import "Device.h"

@implementation RulePayload

/**{"ID":4,"Value":"false","MobileInternalIndex":1271920418,"CommandType":"ValidateRule"}**/

- (NSDictionary*)validateRule:(NSInteger)randomMobileInternalIndex valid:(NSString *)valid{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    if (!plus.almondplusMAC) {
        return nil;
    }
    NSMutableDictionary *rulePayload = [[NSMutableDictionary alloc]init];
    
    [rulePayload setValue:self.rule.ID forKey:@"ID"];
    [rulePayload setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    [rulePayload setValue:valid forKey:@"Value"];
    [rulePayload setValue:@(randomMobileInternalIndex).stringValue forKey:@"MobileInternalIndex"];
    [rulePayload setValue:@"ValidateRule" forKey:@"CommandType"];
 
    return rulePayload;
    
}


- (NSDictionary*)createRulePayload:(NSInteger)randomMobileInternalIndex with:(BOOL)isInitilized valid:(NSString *)valid{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    if (!plus.almondplusMAC) {
        return nil;
    }
    NSMutableDictionary *rulePayload = [[NSMutableDictionary alloc]init];
    
    [rulePayload setValue:@([valid boolValue]) forKey:@"Valid"];
    [rulePayload setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
    [rulePayload setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    [rulePayload setValue:self.rule.name forKey:@"Name"];
    if(!isInitilized){ //check if its in add state
        [rulePayload setValue:@"AddRule" forKey:@"CommandType"];
    }
    else{
        [rulePayload setValue:@"UpdateRule" forKey:@"CommandType"];
        [rulePayload setValue:self.rule.ID forKey:@"ID"]; //Get From Rule instance
        isInitilized = NO;//setting it to not to reflect
    }
    
    NSArray *devices =toolkit.devices;
    
    [self removeInvalidEntries:self.rule.triggers devices:devices clients:toolkit.clients];
    [self removeInvalidEntries:self.rule.actions devices:devices clients:toolkit.clients];
    
    [rulePayload setValue:[self createTriggerPayload] forKey:@"Triggers"];
    [rulePayload setValue:[self createActionPayload] forKey:@"Results"];
    NSLog(@"rule payload: %@", rulePayload);
    return rulePayload;
    
}

-(NSMutableArray *)createTriggerPayload{
    NSMutableArray * triggersArray = [[NSMutableArray alloc]init];
    for (SFIButtonSubProperties *dimButtonProperty in self.rule.triggers) {
        NSDictionary *triggerDeviceProperty = [self createTriggerDeviceObject:dimButtonProperty];
        if(triggerDeviceProperty!=nil)
         [triggersArray addObject:triggerDeviceProperty];
    }
    return triggersArray;
}
-(BOOL)findDevice:(int)deviceId devices:(NSArray *)devices{
    for(Device *device in devices){
        if(device.ID == deviceId)
            return YES;
    }
    return NO;
}



-(void)removeInvalidEntries:(NSMutableArray *)entries devices:(NSArray *)devices clients:(NSArray *)clients{
    NSMutableArray *invalidEntries=[NSMutableArray new];
    for(SFIButtonSubProperties *properties in entries){
        properties.eventType=properties.eventType==nil?@"":properties.eventType;
        properties.type=properties.type==nil?@"":properties.type;
        NSLog(@"event type %@",properties.eventType);
        if([properties.eventType isEqualToString:@"TimeTrigger"]
           ||[properties.eventType isEqualToString:@"AlmondModeUpdated"]
           ||[properties.type isEqualToString:@"NetworkResult"]
           ||[properties.type isEqualToString:@"WeatherTrigger"])
            continue;
        
        else if([properties.eventType isEqualToString:@"ClientJoined"] || [properties.eventType isEqualToString:@"ClientLeft"]){
            if(![Client findClientByMAC:properties.matchData])
                [invalidEntries addObject:properties];
        }
        else if( ![self findDevice:properties.deviceId devices:devices])
            [invalidEntries addObject:properties];
    }
    if(invalidEntries.count>0)
        [entries removeObjectsInArray:invalidEntries ];
    NSLog(@"self.rule.action count %ld",(unsigned long)self.rule.actions.count);
}
-(NSDictionary *)createTriggerDeviceObject:(SFIButtonSubProperties*)property{
    property.eventType=property.eventType==nil?@"":property.eventType;

    if([property.eventType isEqualToString:@"AlmondModeUpdated"])
         return @{
                 @"Type" : @"EventTrigger",
                 @"ID" : @(1),
                 @"EventType" : @"AlmondModeUpdated",
                 @"Value" : property.matchData,
                 @"Grouping" : @"AND",
                 @"Valid":@"true",
                 @"Condition" : @"eq"
                 };
       
    
   else if([property.eventType isEqualToString:@"ClientJoined"] || [property.eventType isEqualToString:@"ClientLeft"])
        return @{
                 @"Type" : @"EventTrigger",
                 @"ID" : @(property.deviceId),
                 @"EventType" : property.eventType,
                 @"Value" : property.matchData,
                 @"Grouping" : @"AND",
                 @"Valid":@"true",
                 @"Condition" : @"eq"
                 };
    
   else if([property.type isEqualToString:@"WeatherTrigger"]){
       NSString *weatherType;
       NSString *value = property.matchData;
       NSString *condition = [property getconditionPayload];
       
       if(property.index == 1){
           weatherType = property.matchData;
           value = property.delay;
           condition = @"eq";
       }else if(property.index == 2){
           weatherType = @"WeatherCondition";
           value = property.matchData;
           condition = @"eq";
       }else if(property.index == 3){
           weatherType = @"Temperature";
       }
       else if(property.index == 4){
           weatherType = @"Humidity";
       }
       else if(property.index == 5){
           weatherType = @"Pressure";
       }
       
           
       return @{
                @"Type" : @"WeatherTrigger",
                @"WeatherType" : weatherType,
                @"Duration":@"0",
                @"Value" : value,
                @"Grouping" : @"AND",
                @"Condition" : condition,
                @"Valid":@"true"
                
                };
   }
    

    else if([property.eventType isEqualToString:@"TimeTrigger"]){
        if(property.time.segmentType==0)
            return nil;
        else
            return @{
                     @"Type" : @"TimeTrigger",
                     @"Range" : @(property.time.range),
                     @"Hour" : @(property.time.hours),
                     @"Minutes" : @(property.time.mins),
                     @"DayOfMonth" : @"*",
                     @"DayOfWeek" : [self getDayOfWeek:property.time.dayOfWeek],
                     @"MonthOfYear" : @"*",
                     @"Grouping" : @"AND",
                     @"Valid": @"true"
                     
                     };
        
    }
    
    else
        return @{
                 @"Type" : @"DeviceTrigger",
                 @"ID" : @(property.deviceId),
                 @"Index" : @(property.index),
                 @"Value" : property.matchData,
                 @"Grouping" : @"AND",
                 @"Valid":@"true",
                 @"Condition" : [property getconditionPayload]
                 };
    
}

-(NSString*)getDayOfWeek:(NSArray*)days{
    NSMutableString *dayOfWeek = [NSMutableString new];
    int i=0;
    if(days.count == 0 || days == nil)
        return @"*";
    for(NSString *day in days){
        if(i == 0){
            [dayOfWeek appendString:day];
        }else
            [dayOfWeek appendString:[NSString stringWithFormat:@",%@", day]];
        i++;
    }
    return [NSString stringWithString:dayOfWeek];
}

//-(NSDictionary *)createWiFiClientObject:(SFIButtonSubProperties*)wiFiClientProperty{
//    NSDictionary *dict = @{
//                           @"Type" : @"EventTrigger",
//                           @"ID" : @(wiFiClientProperty.index),
//                           @"EventType" : wiFiClientProperty.eventType,
//                           @"Value" : wiFiClientProperty.matchData,
//                           @"Grouping" : @"AND",
//                           @"Valid":wiFiClientProperty.valid? @"true": @"false",
//                           @"Condition" : @"eq"
//                           };
//    
//    return dict;
//}

-(NSMutableArray *)createActionPayload{
    NSMutableArray * actionsArray = [[NSMutableArray alloc]init];
    for (SFIButtonSubProperties *property in self.rule.actions) {
        NSDictionary *actionsProperty = [self createActionDeviceObject:property];
        [actionsArray addObject:actionsProperty];
    }
    return actionsArray;
}

-(NSDictionary *)createActionDeviceObject:(SFIButtonSubProperties*)dimButtonProperty{
    
    if(dimButtonProperty.type!=nil && [dimButtonProperty.type isEqualToString:@"NetworkResult"]){
        NSDictionary *dict = @{
                               @"Type":@"NetworkResult",
                               @"ID":@(1),
                               @"Index":@(1),
                               @"Value":@"reboot",
                               @"PreDelay":@(dimButtonProperty.delay.intValue),
                               @"Valid": @"true"
                               };
        return dict;
        
    }
    else if(dimButtonProperty.eventType!=nil && [dimButtonProperty.eventType isEqualToString:@"AlmondModeUpdated"] ){
        NSDictionary *dict = @{
                               @"Type":@"EventResult",
                               @"ID":@(1),
                               @"EventType":@"AlmondModeUpdated",
                               @"Value":dimButtonProperty.matchData,
                               @"PreDelay":@(dimButtonProperty.delay.intValue),
                               @"Valid": @"true"
                               };
        return dict;
    }
    NSDictionary *dict = @{
                           @"Type":@"DeviceResult",
                           @"ID":@(dimButtonProperty.deviceId),
                           @"Index":@(dimButtonProperty.index),
                           @"Value":dimButtonProperty.matchData,
                           @"PreDelay":@(dimButtonProperty.delay.intValue),
                           @"Valid": @"true"
                           };
    return dict;
}

@end
