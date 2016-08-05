//
//  GenericParams.m
//  SecurifiApp
//
//  Created by Masood on 23/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericParams.h"


@implementation GenericParams
-(id)initWithGenericIndexValue:(GenericIndexValue*)headerGenericIndexValue indexValueList:(NSArray*)indexValueList deviceName:(NSString*)deviceName color:(UIColor*)color isSensor:(BOOL)isSensor{
    self = [super init];
    if(self){
        self.headerGenericIndexValue = headerGenericIndexValue;
        self.indexValueList = indexValueList;
        self.deviceName = deviceName;
        self.color = color;
        self.isSensor = isSensor;
    }
    return self;
}

@end
