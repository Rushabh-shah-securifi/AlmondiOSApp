//
//  RouterPayload.h
//  SecurifiApp
//
//  Created by Masood on 06/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFIRouterTableViewController.h"

@interface RouterPayload : NSObject

+ (void)routerSummary:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac;

+ (void)getWirelessSettings:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac;

+ (void)setWirelessSettings:(int)mii wirelessSettings:(SFIWirelessSetting*)wirelessSettingObj isEnabled:(BOOL)isEnabled isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac;

+ (void)updateFirmware:(int)mii version:(NSString*)version isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac;

+ (void)routerReboot:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac;

+ (void)sendLogs:(NSString*)message mii:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac;

@end
