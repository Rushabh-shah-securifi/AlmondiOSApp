//
//  GenericIndexUtil.h
//  SecurifiApp
//
//  Created by Masood on 11/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
@interface GenericIndexUtil : NSObject
+ (void)testGeenricIndexUtil;
+(NSDictionary*)getGenericIndexValueForID:(sfi_id)deviceId index:(int)index value:(NSString*)value;
+(NSDictionary *)getGenericIndexJsonForDeviceId:(sfi_id) deviceID index:(int) index;
+(NSDictionary*)getGenericIndexValueForGenericIndex:(NSString*)genericIndex value:(NSString*)value;
+(NSString*)getHeaderGenericIndexForDevice:(Device*)device;
+(NSString *)getIconImageFromGenericIndexDic:(NSDictionary *)genericIndexDict forValue:(NSString*)value;
+(NSString *)getLabelValueFromGenericIndexDict:(NSDictionary *)genericIndexDict forValue:(NSString*)value;
+ (NSDictionary*)getDeviceJsonForType:(int)type;
+ (NSMutableArray*)getGenericIndexesForDevice:(Device*)device;
@end
