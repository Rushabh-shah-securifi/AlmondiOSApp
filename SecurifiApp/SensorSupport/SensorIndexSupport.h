//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IndexValueSupport;


@interface SensorIndexSupport : NSObject

@property sfi_id indexId;
@property SFIDevicePropertyType indexType;
@property NSArray *indexValueSupports; // instance of IndexValueSupport

// returns all IndexValueSupport objects
- (NSArray*)push:(SFIDeviceType)device index:(SFIDevicePropertyType)type;

@end