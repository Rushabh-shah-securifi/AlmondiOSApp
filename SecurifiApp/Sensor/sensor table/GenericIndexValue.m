//
//  GenericIndexValue.m
//  SecurifiToolkit
//
//  Created by Masood on 15/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "GenericIndexValue.h"


@implementation GenericIndexValue
-(id)initWithGenericIndex:(GenericIndexClass*)genericIndex genericValue:(GenericValue*)genericValue index:(int)index deviceID:(int)deviceID{
    self = [super init];
    if(self){
        self.genericIndex = genericIndex;
        self.genericValue = genericValue;
        self.index = index;
        self.deviceID = deviceID;
    }
    return self;
}

+(GenericIndexValue*)getLightCopy:(GenericIndexValue*)genIndexVal{
    GenericIndexValue *copy = [[GenericIndexValue alloc]initWithGenericIndex:genIndexVal.genericIndex
                                                                genericValue:genIndexVal.genericValue
                                                                       index:genIndexVal.index
                                                                    deviceID:genIndexVal.deviceID];
    return  copy;
}
@end
