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
- (NSDictionary*)createRulePayload:(NSInteger)randomMobileInternalIndex with:(BOOL)isInitilized{
    NSLog(@" rulname.alertview %@",self.rule.name);
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    if (!plus.almondplusMAC) {
        return nil;
    }
    NSMutableDictionary *rulePayload = [[NSMutableDictionary alloc]init];
    
    
    [rulePayload setValue:@(randomMobileInternalIndex).stringValue forKey:@"MobileInternalIndex"];
    [rulePayload setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    [rulePayload setValue:self.rule.name forKey:@"Name"];
    if(!isInitilized){ //check if its in add state
        [rulePayload setValue:@"AddRule" forKey:@"CommandType"];
        NSLog(@" rule add");
    }
    else{
        
        NSLog(@" rul update");
        [rulePayload setValue:@"UpdateRule" forKey:@"CommandType"];
        NSLog(@"rule id edit %@ ",self.rule.ID);
        [rulePayload setValue:self.rule.ID forKey:@"ID"];
        [rulePayload setValue:self.rule.ID forKey:@"ID"]; //Get From Rule instance
        isInitilized = NO;//setting it to not to reflect
        
    }
    
    
    [rulePayload setValue:[self createTriggerPayload] forKey:@"Triggers"];
    [rulePayload setValue:[self createActionPayload] forKey:@"Results"];
    
    NSLog(@"rule payload : %@ ",rulePayload);
    return rulePayload;
    
}

-(NSMutableArray *)createTriggerPayload{
    NSMutableArray * triggersArray = [[NSMutableArray alloc]init];
    if(self.rule.time.isPresent){
        NSDictionary *timeDict = [self createTimeObject];
        [triggersArray addObject:timeDict];
    }
    for (SFIButtonSubProperties *dimButtonProperty in self.rule.triggers) {
        NSDictionary *triggerDeviceProperty = [self createTriggerDeviceObject:dimButtonProperty];
        [triggersArray addObject:triggerDeviceProperty];
    }
    return triggersArray;
}

-(NSDictionary *)createTriggerDeviceObject:(SFIButtonSubProperties*)property{
    NSDictionary *dict;
    if(property.deviceId == 0){
        if([property.eventType isEqualToString:@"AlmondModeUpdated"]){
            dict = @{
                                   @"Type" : @"EventTrigger",
                                   @"ID" : @(0).stringValue,
                                   @"EventType" : @"AlmondModeUpdated",
                                   @"Value" : property.matchData,
                                   @"Grouping" : @"AND",
                                   @"Validation":@"true",
                                   @"Condition" : @"eq"
                                   };
            return dict;

        }else{
            dict = @{
                     @"Type" : @"EventTrigger",
                     @"ID" : @(property.index),
                     @"EventType" : property.eventType,
                     @"Value" : property.matchData,
                     @"Grouping" : @"AND",
                     @"Validation":@"",
                     @"Condition" : @"eq"
                     };

        }
    }
    dict = @{
                           @"Type" : @"DeviceTrigger",
                           @"ID" : @(property.deviceId).stringValue,
                           @"Index" : @(property.index).stringValue,
                           @"Value" : property.matchData,
                           @"Grouping" : @"AND",
                           @"Validation":@"",
                           @"Condition" : @"eq"
                           };
    
    return dict;
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


-(NSDictionary*)createTimeObject{
    NSDictionary *Dict= @{
                          @"Type" : @"TimeTrigger",
                          @"Range" : @(self.rule.time.range),
                          @"Hour" : @(self.rule.time.hours),
                          @"Minutes" : @(self.rule.time.mins),
                          @"DayOfMonth" : @"*",
                          @"DayOfWeek" : self.rule.time.dayOfWeek,
                          @"MonthOfYear" : @"*",
                          @"Grouping" : @"AND",
                          @"Validation": @""
                          
                          };
    return Dict;
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
    if(dimButtonProperty.deviceId == 0){
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
