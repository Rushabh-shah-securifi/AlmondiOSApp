

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

+ (NSDictionary*)getIndexesDicForArray:(NSArray*)genericIndexValues isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene;

+ (NSArray *)getGenericIndexValueArrayForID:(int)deviceID type:(int)deviceType isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene triggers:(NSMutableArray*)triggers action:(NSMutableArray*)actions;

+ (BOOL) isToBeAdded:(NSString*)dataString checkString:(NSString*)checkString;

+ (BOOL) showGenericDevice:(int)type isTrigger:(BOOL) isTrigger isScene:(BOOL)isScene;

+ (BOOL)showGenericValue:(GenericValue *)index isScene:(BOOL)isScene isTrigger:(BOOL)isTrigger;

@end
