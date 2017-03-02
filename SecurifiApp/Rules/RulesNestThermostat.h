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
#import "GenericIndexClass.h"

@interface RulesNestThermostat : NSObject
+(void)removeTemperatureIndexes:(int)deviceId mode:(NSString *)mode entries:(NSMutableArray *)entries;

+ (NSArray *)handleNestThermostat:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues modeFilter:(BOOL)isScene triggers:(NSMutableArray*)triggers;

+ (NSArray*)handleNestThermostatForSensor:(int)deviceID genericIndexValues:(NSArray*)genericIndexValues;


+(NSDictionary*)handleNestThermostatFornewDevice:(NSDictionary*)genericIndexValues deviceID:(int)deviceID;

+(GenericIndexClass *)filterValues:(GenericIndexClass *)genericINdex deviceId:(int)deviceId;
@end
