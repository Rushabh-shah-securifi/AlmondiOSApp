//
//  RuleSceneCommonMethods.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 09/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rule.h"
@interface RuleSceneCommonMethods : NSObject
+(Rule *)getScene:(NSDictionary*)dict;
+(NSMutableArray *)isPresentInRuleList:(BOOL)isRule list:(NSArray *)ruleList deviceID:(int)deviceID;
@end
