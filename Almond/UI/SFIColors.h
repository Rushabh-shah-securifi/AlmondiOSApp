//
//  SFIColors.h
//  ReorderTest
//
//  Created by Priya Yerunkar  on 04/10/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIColors : NSObject <NSCoding>
@property (nonatomic, assign) int hue;
@property (nonatomic, assign) int saturation;
@property (nonatomic, assign) int brightness;
@property (nonatomic, strong) NSString *colorName;
@end
