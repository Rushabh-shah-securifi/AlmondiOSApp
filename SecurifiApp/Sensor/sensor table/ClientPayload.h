//
//  ClientPayload.h
//  SecurifiApp
//
//  Created by Masood on 01/04/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientPayload : NSObject
+(NSDictionary*)getUpdateClientPayloadForClient:(Client*)client mobileInternalIndex:(int)mii;
@end
