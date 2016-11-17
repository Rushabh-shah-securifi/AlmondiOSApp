//
//  TimeText.h
//  nOCD
//
//  Created by Argam on 10/28/15.
//  Copyright © 2015 MagicDevs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeText : NSObject

+ (NSString*) convertNumberToMonthMMM:(int) mon;
+ (NSString*) getShortDate:(long) thenTime;
+ (int) getCategory:(NSString*) time;
+ (NSArray*) getSubTime:(NSString*) time :(int) category;
+ (NSString*) getTime:(long) time;
+ (NSString*) getTime:(NSString*) time category:(int) category;

@end
