//
//  SFIDeviceIndex.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 09.06.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIDeviceIndex.h"

@implementation SFIDeviceIndex

- (instancetype)initWithValueType:(SFIDevicePropertyType)valueType {
    self = [super init];
    if (self) {
        _valueType = valueType;
    }
    
    return self;
}
@end
