//
//  MeshPayload.h
//  SecurifiApp
//
//  Created by Masood on 7/29/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeshPayload : NSObject

+(void)requestCheckForAddableWiredSlave:(int)mii;

+(void)requestCheckForAddableWirelessSlave:(int)mii;

+(void)requestBlinkLed:(int)mii slaveName:(NSString *)slaveName;

+(void)requestAddWiredSlave:(int)mii slaveName:(NSString *)slaveName;

+(void)requestAddWireLessSlave:(int)mii slaveName:(NSString *)slaveName;

+(void)requestSetSlaveName:(int)mii;

+(void)requestRemoveSlave:(int)mii uniqueName:(NSString*)uniqueName;

+(void)requestSlaveDetails:(int)mii slaveUniqueName:(NSString*)uniqueName;
@end
