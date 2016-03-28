//
//  GenericParams.m
//  SecurifiApp
//
//  Created by Masood on 23/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericParams.h"


@implementation GenericParams
-(id)initWithGenericIndexValue:(GenericIndexValue*)headerGenericIndexValue indexValueList:(NSArray*)indexValueList device:(Device*)device color:(UIColor*)color{
    self = [super init];
    if(self){
        self.headerGenericIndexValue = headerGenericIndexValue;
        self.indexValueList = indexValueList;
        self.device = device;
        self.color = color;
    }
    return self;
}

@end
