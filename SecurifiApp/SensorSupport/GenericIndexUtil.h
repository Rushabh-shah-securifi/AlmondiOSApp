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

+(NSArray*)getGenericIndexValuesByPlacementForDevice:(Device*)device placement:(NSString*)placement;
+(GenericValue*)getHeaderGenericValueForDevice:(Device*)device;
@end
