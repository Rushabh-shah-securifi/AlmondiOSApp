//
//  SFIDeviceIndex.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 09.06.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIDeviceIndex : NSObject

- (instancetype)initWithValueType:(SFIDevicePropertyType)valueType;


@property(nonatomic, readonly) SFIDevicePropertyType valueType;
@property(nonatomic) NSArray *indexValues;
@property(nonatomic) int indexID;
@end
