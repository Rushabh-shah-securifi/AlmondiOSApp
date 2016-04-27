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

@interface GenericIndexUtil : NSObject
+ (NSMutableArray *)getDetailListForDevice:(int)deviceID;
+ (NSMutableArray*)getGenericIndexValuesByPlacementForDevice:(Device*)device placement:(NSString*)placement;
+ (GenericIndexValue*)getHeaderGenericIndexValueForDevice:(Device*)device;
+ (GenericIndexValue *) getClientHeaderGenericIndexValueForClient:(Client*) client;
+ (NSArray*) getClientDetailGenericIndexValuesListForClientID:(NSString*)clientID;
+ (GenericValue*)getMatchingGenericValueForGenericIndexID:(NSString*)genericIndexID forValue:(NSString*)value;
@end
