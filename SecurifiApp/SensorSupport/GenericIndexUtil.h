//
//  GenericIndexUtil.h
//  SecurifiApp
//
//  Created by Masood on 11/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericIndexUtil : NSObject
+ (void)testGeenricIndexUtil;
+(NSDictionary*)getGenericIndexValueForID:(sfi_id)deviceId index:(int)index value:(NSString*)value;
+(NSDictionary *)getGenericIndexJsonForDeviceId:(sfi_id) deviceID index:(int) index;
+(NSDictionary*)getGenericIndexValueForGenericIndex:(NSString*)genericIndex value:(NSString*)value;
@end
