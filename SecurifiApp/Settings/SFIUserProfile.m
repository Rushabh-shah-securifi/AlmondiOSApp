//
//  SFIUserProfile.m
//  Almond
//
//  Created by Priya Yerunkar on 15/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFIUserProfile.h"
#import <Foundation/Foundation.h>

@implementation SFIUserProfile
@synthesize label;
@synthesize keyValue;
@synthesize data;

- (id)init
{
    self = [super init];
    if (self)
    {
        data = [NSMutableArray new];
    }
    return self;
}
@end
