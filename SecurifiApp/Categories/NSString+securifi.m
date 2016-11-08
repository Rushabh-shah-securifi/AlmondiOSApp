//
//  NSString+securifi.m
//  SecurifiApp
//
//  Created by Masood on 11/7/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "NSString+securifi.h"

@implementation NSString (securifi)

- (BOOL) containsString: (NSString*) substring
{
    return [self rangeOfString:substring options:NSCaseInsensitiveSearch].location != NSNotFound;
}

@end
