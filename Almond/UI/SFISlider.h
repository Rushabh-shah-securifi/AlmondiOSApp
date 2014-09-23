//
//  SFISlider.h
//
//  Created by sinclair on 8/5/14.
//
#import <Foundation/Foundation.h>
#import "ASValueTrackingSlider.h"


// A slider that has a larger thumb area for tracking touch events
@interface SFISlider : ASValueTrackingSlider

@property(nonatomic) SFIDevicePropertyType propertyType;

@end