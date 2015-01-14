//
// Created by Matthew Sinclair-Day on 1/14/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Conversion)

// Returns hexadecimal string of NSData. Empty string if data is empty.
- (NSString *)hexadecimalString;

@end