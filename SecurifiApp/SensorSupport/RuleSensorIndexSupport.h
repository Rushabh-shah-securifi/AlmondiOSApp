//
//  RuleSensorIndexSupport.h
//  SecurifiApp
//
//  Created by Masood on 12/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RuleSensorIndexSupport : NSObject

// returns all IndexValueSupport objects
- (NSArray *)resolve:(SFIDeviceType)device index:(SFIDevicePropertyType)type;

- (NSArray*)indexesFor:(SFIDeviceType)device;
- (NSArray *)getIndexesFor:(SFIDeviceType)device;
@end
