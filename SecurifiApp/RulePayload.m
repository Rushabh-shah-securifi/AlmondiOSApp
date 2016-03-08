//
//  RulePayload.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 13/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "RulePayload.h"
#import "SFIButtonSubProperties.h"

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
    
    [rulePayload setValue:valid forKey:@"Valid"];
    [rulePayload setValue:@(randomMobileInternalIndex).stringValue forKey:@"MobileInternalIndex"];
    [rulePayload setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    [rulePayload setValue:self.rule.name forKey:@"Name"];
    if(!isInitilized){ //check if its in add state
        [rulePayload setValue:@"AddRule" forKey:@"CommandType"];
    }
    else{
        [rulePayload setValue:@"UpdateRule" forKey:@"CommandType"];
        [rulePayload setValue:self.rule.ID forKey:@"ID"];
        [rulePayload setValue:self.rule.ID forKey:@"ID"]; //Get From Rule instance
        isInitilized = NO;//setting it to not to reflect
        
    }
    
    NSArray *devices =[toolkit deviceValuesList:plus.almondplusMAC];
    
    [self removeInvalidEntries:self.rule.triggers devices:devices clients:toolkit.wifiClientParser];
    [self removeInvalidEntries:self.rule.actions devices:devices clients:toolkit.wifiClientParser];
    
    [rulePayload setValue:[self createTriggerPayload] forKey:@"Triggers"];
    [rulePayload setValue:[self createActionPayload] forKey:@"Results"];
    

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
-(BOOL)findDevice:(int *)deviceId devices:(NSArray *)devices{
    for(SFIDeviceValue *deviceValue in devices){
        if(deviceValue.deviceID == deviceId)
            return YES;
    }
    return NO;
}

-(BOOL)findClient:(NSString *)mac devices:(NSArray *)clients{
    for(SFIConnectedDevice *client in clients){
        if([mac isEqualToString:client.deviceMAC])
            return YES;
    }
    return NO;
}

-(void)removeInvalidEntries:(NSMutableArray *)entries devices:(NSArray *)devices clients:(NSArray *)clients{
    NSMutableArray *invalidEntries=[NSMutableArray new];
    for(SFIButtonSubProperties *properties in entries){
        properties.eventType=properties.eventType==nil?@"":properties.eventType;
        properties.type=properties.type==nil?@"":properties.type;
        
        if([properties.eventType isEqualToString:@"TimeTrigger"]
           ||[properties.eventType isEqualToString:@"AlmondModeUpdated"]
           ||[properties.type isEqualToString:@"NetworkResult"])
            continue;
        
        else if([properties.eventType isEqualToString:@"ClientJoined"] || [properties.eventType isEqualToString:@"ClientLeft"]){
            
            if(![self findClient:properties.matchData devices:clients])
                [invalidEntries addObject:properties];
        }
        else if( ![self findDevice:properties.deviceId devices:devices])
            [invalidEntries addObject:properties];
    }
    if(invalidEntries.count>0)
        [entries removeObjectsInArray:invalidEntries ];
}
-(NSDictionary *)createTriggerDeviceObject:(SFIButtonSubProperties*)property{
    property.eventType=property.eventType==nil?@"":property.eventType;

    if([property.eventType isEqualToString:@"AlmondModeUpdated"])
         return @{
                 @"Type" : @"EventTrigger",
                 @"ID" : @(1).stringValue,
                 @"EventType" : @"AlmondModeUpdated",
                 @"Value" : property.matchData,
                 @"Grouping" : @"AND",
                 @"Validation":@"true",
                 @"Condition" : @"eq"
                 };
       
    
   else if([property.eventType isEqualToString:@"ClientJoined"] || [property.eventType isEqualToString:@"ClientLeft"])
        return @{
                 @"Type" : @"EventTrigger",
                 @"ID" : @(property.deviceId).stringValue,
                 @"EventType" : property.eventType,
                 @"Value" : property.matchData,
                 @"Grouping" : @"AND",
                 @"Validation":@"",
                 @"Condition" : @"eq"
                 };
       
    

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
                     @"Validation": @""
                     
                     };
        
    }
    
    else
        return @{
                 @"Type" : @"DeviceTrigger",
                 @"ID" : @(property.deviceId).stringValue,
                 @"Index" : @(property.index).stringValue,
                 @"Value" : property.matchData,
                 @"Grouping" : @"AND",
                 @"Validation":@"",
                 @"Condition" : @"eq"
                 };
    
}

-(NSString*)getDayOfWeek:(NSArray*)days{
    NSMutableString *dayOfWeek = [NSMutableString new];
    int i=0;
    for(NSString *day in days){
        if(i == 0){
            [dayOfWeek appendString:day];
        }else
            [dayOfWeek appendString:[NSString stringWithFormat:@",%@", day]];
        i++;
    }
    return [NSString stringWithString:dayOfWeek];
}

-(NSDictionary *)createWiFiClientObject:(SFIButtonSubProperties*)wiFiClientProperty{
    NSDictionary *dict = @{
                           @"Type" : @"EventTrigger",
                           @"ID" : @(wiFiClientProperty.index),
                           @"EventType" : wiFiClientProperty.eventType,
                           @"Value" : wiFiClientProperty.matchData,
                           @"Grouping" : @"AND",
                           @"Validation":@"",
                           @"Condition" : @"eq"
                           };
    
    return dict;
}

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
                               @"ID":@(1).stringValue,
                               @"Index":@(1).stringValue,
                               @"Value":@"reboot",
                               @"PreDelay":dimButtonProperty.delay,
                               @"Validation": @"true"
                               };
        return dict;
        
    }
    else if(dimButtonProperty.eventType!=nil && [dimButtonProperty.eventType isEqualToString:@"AlmondModeUpdated"] ){
        NSDictionary *dict = @{
                               @"Type":@"EventResult",
                               @"ID":@(1).stringValue,
                               @"EventType":@"AlmondModeUpdated",
                               @"Value":dimButtonProperty.matchData,
                               @"PreDelay":dimButtonProperty.delay,
                               @"Validation": @"true"
                               };
        return dict;
    }
    NSDictionary *dict = @{
                           @"Type":@"DeviceResult",
                           @"ID":@(dimButtonProperty.deviceId).stringValue,
                           @"Index":@(dimButtonProperty.index).stringValue,
                           @"Value":dimButtonProperty.matchData,
                           @"PreDelay":dimButtonProperty.delay,
                           @"Validation": @""
                           };
    return dict;
}

@end
