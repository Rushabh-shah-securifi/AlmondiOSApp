//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SensorIndexSupport : NSObject

// returns all IndexValueSupport objects
- (NSArray *)resolve:(SFIDeviceType)device index:(SFIDevicePropertyType)type;

@end