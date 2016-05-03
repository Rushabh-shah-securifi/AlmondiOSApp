//
//  RulesNestThermostat.h
//  Tableviewcellpratic
//
//  Created by Masood on 20/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecurifiToolkit/SFIDevice.h"
#import "SecurifiToolkit/SFIDeviceValue.h"

@interface RulesNestThermostat : NSObject

//altering device indexes as per the incoming conditions
+(NSArray*)createNestThermostatGenericIndexValues:(NSArray*)genericIndexValues deviceID:(int)deviceID;

+(NSArray*)filterIndexesBasedOnModeForIndexes:(NSArray*)genericIndexValues deviceId:(sfi_id)deviceId matchData:(NSString*)matchData;

+(void)removeTemperatureIndexes:(int)deviceId mode:(NSString *)mode entries:(NSMutableArray *)entries;

+ (NSArray*)getNestGenericIndexVals:(int)deviceID withGenericIndexValues:(NSArray*)genericIndexVals;
@end
