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
+ (NSDictionary*)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii;
+ (NSDictionary*)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value;
+ (NSDictionary*)getNameLocationChangePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii device:(Device*)device;
@end
