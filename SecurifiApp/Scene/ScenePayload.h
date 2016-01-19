//
//  ScenePayload.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 14/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScenePayload : NSObject
- (NSMutableDictionary *)sendScenePayload:(NSDictionary*)sceneDict with:(NSInteger)randomMobileInternalIndex with:(NSString*)almondMac with:(NSMutableArray *)sceneEntry with:(NSString *)sceneName isLocal:(BOOL)local;
//- (void)sendPayload:(NSDictionary*)sceneDict with:(NSInteger)randomMobileInternalIndex with:(NSString*)almondMac with:(NSMutableArray *)sceneEntry with:(NSString *)sceneName;
@end
