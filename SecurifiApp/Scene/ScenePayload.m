//
//  ScenePayload.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 14/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ScenePayload.h"
#import "Analytics.h"
#import "SFIButtonSubProperties.h"

@implementation ScenePayload
- (NSMutableDictionary *)sendScenePayload:(NSDictionary*)sceneDict with:(NSInteger)randomMobileInternalIndex with:(NSString*)almondMac with:(NSMutableArray *)sceneEntry with:(NSString *)sceneName isLocal:(BOOL)local{
    
    
    NSMutableDictionary *newSceneInfo = [NSMutableDictionary new];
    NSMutableDictionary *payloadDict = [NSMutableDictionary new];
    
    if (sceneDict) {
        [payloadDict setValue:@"UpdateScene" forKey:@"CommandType"];
        [newSceneInfo setValue:[sceneDict valueForKey:@"ID"] forKey:@"ID"];
        [[Analytics sharedInstance] markUpdateScene];
        
    }else{
        [payloadDict setValue:@"AddScene" forKey:@"CommandType"];
        [[Analytics sharedInstance] markAddScene];
    }
    
    [payloadDict setValue:@(randomMobileInternalIndex) forKey:@"MobileInternalIndex"];
    [newSceneInfo setValue:sceneName forKey:@"Name"];
    if(!local){
        [payloadDict setValue:almondMac forKey:@"AlmondMAC"];
    }
    
    //[self configuresCeneEntryListForSave];
    [newSceneInfo setValue:sceneEntry forKey:@"SceneEntryList"];
    
    [payloadDict setValue:newSceneInfo forKey:@"Scenes"];
    
    return payloadDict;
}

+(NSDictionary*)getScenePayload:(Rule*)scene mobileInternalIndex:(int)mii isEdit:(BOOL)isEdit{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    NSMutableDictionary *newSceneInfo = [NSMutableDictionary new];
    NSMutableDictionary *payloadDict = [NSMutableDictionary new];
    
    if (isEdit) {
        [payloadDict setValue:@"UpdateScene" forKey:@"CommandType"];
        [newSceneInfo setValue:scene.ID forKey:@"ID"];
        [[Analytics sharedInstance] markUpdateScene];
        
    }else{
        [payloadDict setValue:@"AddScene" forKey:@"CommandType"];
        [[Analytics sharedInstance] markAddScene];
    }
    [payloadDict setValue:@(mii) forKey:@"MobileInternalIndex"];
    [newSceneInfo setValue:scene.name forKey:@"Name"];
    [payloadDict setValue:plus.almondplusMAC forKey:@"AlmondMAC"];

    [newSceneInfo setValue:[self createSceneEntriesPayload:scene.triggers] forKey:@"SceneEntryList"];
    [payloadDict setValue:newSceneInfo forKey:@"Scenes"];
    
    return payloadDict;
}

+(NSMutableArray *)createSceneEntriesPayload:(NSArray*)sceneEntries{
    NSMutableArray * triggersArray = [[NSMutableArray alloc]init];
    for (SFIButtonSubProperties *subProperty in sceneEntries) {
        NSDictionary *sceneEntry = [self createSceneEntry:subProperty];
        if(sceneEntry!=nil)
            [triggersArray addObject:sceneEntry];
    }
    return triggersArray;
}


+(NSDictionary*)createSceneEntry:(SFIButtonSubProperties*)subProperty{
    return @{
             @"DeviceID" : @(subProperty.deviceId).stringValue,
             @"Index" : @(subProperty.index).stringValue,
             @"Value" : subProperty.matchData
             };
}

@end
