//
//  CommonMethods.h
//  SecurifiApp
//
//  Created by Masood on 19/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIButtonSubProperties.h"

@interface CommonMethods : NSObject
+(BOOL) compareEntry:(BOOL)isSlider matchData:(NSString *)matchData eventType:(NSString *)eventType buttonProperties:(SFIButtonSubProperties *)buttonProperties;
+(NSString*)getDays:(NSArray*)earlierSelection;
+(BOOL)isDimmerLayout:(NSString*)genericLayout layout:(NSString *)layoutType;
@end
