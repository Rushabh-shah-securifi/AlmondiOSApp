//
//  RouterPayload.h
//  SecurifiApp
//
//  Created by Masood on 06/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouterPayload : NSObject

+ (GenericCommand*)routerSummary:(int)mii;

+ (GenericCommand*)getWirelessSettings:(int)mii;

+ (GenericCommand*)setWirelessSettings:(int)mii wirelessSettings:(SFIWirelessSetting*)wirelessSettingObj isEnabled:(BOOL)isEnabled;

+ (GenericCommand*)routerReboot:(int)mii;

+ (GenericCommand*)sendLogs:(NSString*)message mii:(int)mii;

@end
