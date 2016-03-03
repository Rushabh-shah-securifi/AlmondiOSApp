//
//  ScenePayload.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 14/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rule.h"
@class Rule;

@interface ScenePayload : NSObject
+(NSMutableDictionary*)getScenePayload:(Rule*)scene mobileInternalIndex:(int)mii isEdit:(BOOL)isEdit isSceneNameCompatibleWithAlexa:(BOOL)isCompatible;
+ (NSMutableDictionary*)getDeleteScenePayload:(Rule*)scene mobileInternalIndex:(int)mii;

@end