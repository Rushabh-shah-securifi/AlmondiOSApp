//
//  GenericParams.h
//  SecurifiApp
//
//  Created by Masood on 23/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericIndexValue.h"
#import "Device.h"

@interface GenericParams : NSObject
@property(nonatomic) NSArray *indexValueList;
@property(nonatomic) Device *device;
@property(nonatomic) GenericIndexValue *headerGenericIndexValue;
@property(nonatomic) NSString *color;

-(id)initWithGenericIndexValue:(GenericIndexValue*)headerGenericIndexValue indexValueList:(NSArray*)indexValueList device:(Device*)device color:(NSString*)color;
@end
