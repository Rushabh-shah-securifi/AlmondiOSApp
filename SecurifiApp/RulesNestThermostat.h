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
-(NSArray*) createNestThermostatDeviceIndexes:(NSArray*) deviceIndexes device:(SFIDevice*)device deviceValue:(SFIDeviceValue*)deviceValue;

@end
