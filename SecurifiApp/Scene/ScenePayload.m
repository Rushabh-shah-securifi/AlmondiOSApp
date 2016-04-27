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
+(NSMutableDictionary*)getScenePayload:(Rule*)scene mobileInternalIndex:(int)mii isEdit:(BOOL)isEdit isSceneNameCompatibleWithAlexa:(BOOL)isCompatible{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    NSMutableDictionary *newSceneInfo = [NSMutableDictionary new];
    NSMutableDictionary *payloadDict = [NSMutableDictionary new];
    [payloadDict setValue:@(mii) forKey:@"MobileInternalIndex"];
    [payloadDict setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    if (isEdit) {
        [payloadDict setValue:@"UpdateScene" forKey:@"CommandType"];
        [newSceneInfo setValue:scene.ID forKey:@"ID"];
        [[Analytics sharedInstance] markUpdateScene];
        
    }else{
        [payloadDict setValue:@"AddScene" forKey:@"CommandType"];
        [[Analytics sharedInstance] markAddScene];
    }
    
    [newSceneInfo setValue:scene.name forKey:@"Name"];
    [newSceneInfo setValue:isCompatible? @"true": @"false" forKey:@"VoiceCompatible"];
    [newSceneInfo setValue:[self createSceneEntriesPayload:scene.triggers] forKey:@"SceneEntryList"];
    [payloadDict setValue:newSceneInfo forKey:@"Scenes"];
    
    return payloadDict;
}

+(NSMutableArray *)createSceneEntriesPayload:(NSArray*)sceneEntries{
    NSMutableArray * triggersArray = [[NSMutableArray alloc]init];
    for (SFIButtonSubProperties *subProperty in sceneEntries) {
        if(subProperty.deviceId == 1 && subProperty.index == 0 && ([subProperty.matchData isEqualToString:@"home"] || [subProperty.matchData isEqualToString:@"away"])){
            [self changeModeProperties:subProperty];
        }
        NSDictionary *sceneEntry = [self createSceneEntry:subProperty];
        if(sceneEntry!=nil)
            [triggersArray addObject:sceneEntry];
    }
    NSLog(@"scene payload: %@", triggersArray);
    return triggersArray;
}

+(void)changeModeProperties:(SFIButtonSubProperties*)modeProperty{
    modeProperty.deviceId = 0;
    modeProperty.index = 1;
}

+(NSDictionary*)createSceneEntry:(SFIButtonSubProperties*)subProperty{
    return @{
             @"ID" : @(subProperty.deviceId).stringValue,
             @"Index" : @(subProperty.index).stringValue,
             @"Value" : subProperty.matchData
             };
}

+ (NSMutableDictionary*)getDeleteScenePayload:(Rule*)scene mobileInternalIndex:(int)mii {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    
    NSMutableDictionary *payloadDict = [NSMutableDictionary new];
    [payloadDict setValue:@"RemoveScene" forKey:@"CommandType"];
    [payloadDict setValue:@{@"ID":scene.ID} forKey:@"Scenes"];
    [payloadDict setValue:@(mii) forKey:@"MobileInternalIndex"];
    [payloadDict setValue:plus.almondplusMAC forKey:@"AlmondMAC"];
    return payloadDict;
}

@end