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
+ (void)deviceListCommand;
+ (void)getSensorIndexUpdate:(GenericIndexValue*)genericIndexValue mii:(int)mii;
+ (void)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value;
+ (void)getNameLocationChange:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value;
+ (void)sensorDidChangeNotificationSetting:(SFINotificationMode)newMode deviceID:(int)deviceID;
@end
