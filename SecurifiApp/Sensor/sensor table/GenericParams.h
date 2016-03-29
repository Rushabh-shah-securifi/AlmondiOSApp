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
@property(nonatomic) NSString *deviceName;
@property(nonatomic) GenericIndexValue *headerGenericIndexValue;
@property(nonatomic) UIColor *color;

-(id)initWithGenericIndexValue:(GenericIndexValue*)headerGenericIndexValue indexValueList:(NSArray*)indexValueList deviceName:(NSString*)deviceName color:(UIColor*)color;
-(void)setGenericParamsWithGenericIndexValue:(GenericIndexValue*)headerGenericIndexValue indexValueList:(NSArray*)indexValueList deviceName:(NSString*)deviceName color:(UIColor*)color;
@end
