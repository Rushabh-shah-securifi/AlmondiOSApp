//
//  DevicePayload.h
//  SecurifiApp
//
//  Created by Masood on 22/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericIndexValue.h"
#import "Device.h"

@interface DevicePayload : NSObject
+ (GenericCommand*)getSensorIndexUpdate:(GenericIndexValue*)genericIndexValue mii:(int)mii;
+ (GenericCommand*)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value;
+ (GenericCommand*)getNameLocationChange:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value;
@end
