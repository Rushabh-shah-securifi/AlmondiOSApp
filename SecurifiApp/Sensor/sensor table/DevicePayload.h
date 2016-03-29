//
//  DevicePayload.h
//  SecurifiApp
//
//  Created by Masood on 22/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericIndexValue.h"
@interface DevicePayload : NSObject
+(NSDictionary*)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii;
+(NSDictionary*)getNameLocationChangePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii name:(NSString*)name location:(NSString*)location;
+(NSDictionary*)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value;
@end
