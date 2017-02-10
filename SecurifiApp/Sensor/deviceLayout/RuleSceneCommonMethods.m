//
//  RuleSceneCommonMethods.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 09/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "RuleSceneCommonMethods.h"
#import "SFIButtonSubProperties.h"
@implementation RuleSceneCommonMethods
+(Rule *)getScene:(NSDictionary*)dict{
    Rule *scene = [[Rule alloc]init];
    scene.ID = [dict valueForKey:@"ID"];
    scene.name = [dict valueForKey:@"Name"]==nil?@"":[dict valueForKey:@"Name"];
    scene.isActive = [[dict valueForKey:@"Active"] boolValue];
    scene.triggers= [NSMutableArray new];
    [self getEntriesList:[dict valueForKey:@"SceneEntryList"] list:scene.triggers];
    return scene;
}
+(void)getEntriesList:(NSArray*)sceneEntryList list:(NSMutableArray *)triggers{
    for(NSDictionary *triggersDict in sceneEntryList){
        SFIButtonSubProperties* subProperties = [[SFIButtonSubProperties alloc] init];
        NSLog(@"triggersDict %@",triggersDict);
        subProperties.deviceId = [[triggersDict valueForKey:@"ID"] intValue];
        subProperties.index = [[triggersDict valueForKey:@"Index"] intValue];
        subProperties.matchData = [triggersDict valueForKey:@"Value"];
        subProperties.valid = [[triggersDict valueForKey:@"Valid"] boolValue];
        subProperties.eventType = [triggersDict valueForKey:@"EventType"];
        [triggers addObject:subProperties];
    }
}
+(NSMutableArray *)isPresentInRuleList:(BOOL)isRule list:(NSArray *)ruleList deviceID:(int)deviceID{
    NSMutableArray *ruleArr = [[NSMutableArray alloc]init];
    
    //NSArray *ruleList = isRule?self.toolkit.ruleList:self.toolkit.scenesArray;
    NSLog(@"ruleList arr %@",ruleList);
    if(!isRule){
        BOOL tag =false;
        for(NSDictionary *sceneDict in ruleList){
            Rule *scene = [RuleSceneCommonMethods getScene:sceneDict];
            tag = [self isDeviceEntryFound:scene.triggers mutableArr:ruleArr rule:scene deviceId:deviceID];
            
        }
        return ruleArr;
    }
    for(Rule *rules in ruleList){
        BOOL tag = NO;
        tag = [self isDeviceEntryFound:rules.triggers mutableArr:ruleArr rule:rules deviceId:deviceID];
        if(tag)
            continue;
        
        tag = [self isDeviceEntryFound:rules.actions mutableArr:ruleArr rule:rules deviceId:deviceID];
        
        if(tag)
            continue;
    }
    return ruleArr;
}
+(BOOL)checkEventType:(NSString *)eventType{
    if([eventType isEqualToString:@"AlmondModeUpdated"] || [eventType isEqualToString:@"ClientJoined"] || [eventType isEqualToString:@"ClientLeft"]){
        return YES;
    }
    else
        return NO;
}
+(BOOL)isDeviceEntryFound:(NSArray *)entries mutableArr:(NSMutableArray*)array rule:(Rule*)rule deviceId:(int)deviceId{
    
    for(SFIButtonSubProperties *subProperty in entries){
        if(subProperty.deviceId == deviceId){
            if(![self checkEventType:subProperty.eventType])
            {
                [array addObject: rule];
                return YES;
                
            }
        }
    }
    return NO;
}
-(BOOL)checkEventType:(NSString *)eventType{
    if([eventType isEqualToString:@"AlmondModeUpdated"] || [eventType isEqualToString:@"ClientJoined"] || [eventType isEqualToString:@"ClientLeft"]){
        return YES;
    }
    else
        return NO;
}
@end
