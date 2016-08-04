//
//  MeshPayload.h
//  SecurifiApp
//
//  Created by Masood on 7/29/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeshPayload : NSObject
+(void)requestMestList:(int)mii;

+(void)requestCheckForAddableWiredSlave:(int)mii;

+(void)requestCheckForAddableWirelessSlave:(int)mii;

+(void)requestBlinkLed:(int)mii slaveName:(NSString *)slaveName;

+(void)requestAddWiredSlave:(int)mii slaveName:(NSString *)slaveName;

+(void)requestAddWireLessSlave:(int)mii slaveName:(NSString *)slaveName;

+(void)requestSetSlaveName:(int)mii;
@end
