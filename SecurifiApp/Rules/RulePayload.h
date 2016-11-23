//
//  RulePayload.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 13/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rule.h"


@interface RulePayload : NSObject
@property (nonatomic,strong)Rule *rule;

- (NSDictionary*)validateRule:(NSInteger)randomMobileInternalIndex valid:(NSString *)valid;
- (NSDictionary*)createRulePayload:(NSInteger)randomMobileInternalIndex with:(BOOL)isInitilized valid:(NSString*)valid;
@end