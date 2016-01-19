//
//  ScenePayload.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 14/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ScenePayload.h"
#import "Analytics.h"

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
    
    NSLog(@"scene local update payload: %@", payloadDict);
    return payloadDict;
}



@end
