//
//  GenericIndexUtil.h
//  SecurifiApp
//
//  Created by Masood on 11/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericValue.h"
#import "Device.h"
#import "GenericProperties.h"

@interface GenericIndexUtil : NSObject

+(NSMutableArray*)getGenericIndexValuesByPlacementForDevice:(Device*)device placement:(NSString*)placement;
+(GenericProperties*)getHeaderGenericPropertiesForDevice:(Device*)device;
@end
