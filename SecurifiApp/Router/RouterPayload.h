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

+ (void)sendRouterCommandForType:(RouterCmdType)type mii:(int)mii isSimulator:(BOOL)isSimulator mac:(NSString*)almondMac version:(NSString*)version message:(NSString*)message;

@end
