//
//  RuleSceneUtil.h
//  SecurifiApp
//
//  Created by Masood on 20/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RuleSceneUtil : NSObject
+(BOOL)isActionDevice:(int) deviceType;

+(BOOL)isTriggerDevice:(int)deviceType;

+(NSDictionary*)getIndexesDicForID:(int)deviceID type:(int)deviceType isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene triggers:(NSMutableArray*)triggers action:(NSMutableArray*)actions;
@end
