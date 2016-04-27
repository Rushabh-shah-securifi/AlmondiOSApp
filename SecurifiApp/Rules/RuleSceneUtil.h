

//
//  RuleSceneUtil.h
//  SecurifiApp
//
//  Created by Masood on 20/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericValue.h"

@interface RuleSceneUtil : NSObject
+ (BOOL)isActionDevice:(int) deviceType;

+ (BOOL)isTriggerDevice:(int)deviceType;

+ (NSDictionary*)getIndexesDicForArray:(NSArray*)genericIndexValues isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene;

+ (NSArray *)getGenericIndexValueArrayForID:(int)deviceID type:(int)deviceType isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene triggers:(NSMutableArray*)triggers action:(NSMutableArray*)actions;

+ (BOOL) isToBeAdded:(NSString*)dataString checkString:(NSString*)checkString;

+ (BOOL)shouldYouSkipTheValue:(GenericValue*)genericValue isScene:(BOOL)isScene;

+ (NSArray *)handleNestThermostat:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues isScene:(BOOL)isScene triggers:(NSMutableArray*)triggers;
@end
