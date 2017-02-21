//
//  GenericIndexUtil.h
//  SecurifiApp
//
//  Created by Masood on 11/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericValue.h"
#import "Device.h"
#import "GenericIndexValue.h"

#define GENERIC_INDEX @"generic_index"
#define GENERIC_ARRAY @"generic_inxex_values_array"

@interface GenericIndexUtil : NSObject
+ (NSArray *)getDetailListForDevice:(int)deviceID;
+ (NSMutableArray*)getGenericIndexValuesByPlacementForDevice:(Device*)device placement:(NSString*)placement;
+ (GenericIndexValue*)getHeaderGenericIndexValueForDevice:(Device*)device;
+ (GenericIndexValue *) getClientHeaderGenericIndexValueForClient:(Client*) client;
+ (NSArray*) getClientDetailGenericIndexValuesListForClientID:(NSString*)clientID;
+ (GenericValue*)getMatchingGenericValueForGenericIndexID:(NSString*)genericIndexID forValue:(NSString*)value;


+ (NSArray *)getGroupedGenericIndexes:(NSMutableArray *)detailList device:(Device *)device;


+ (NSArray *)getDetailListForClient:(int)clientID;
@end
