//
//  SFIColors.h
//  ReorderTest
//
//  Created by Priya Yerunkar  on 04/10/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIColors : NSObject <NSCoding>

+ (NSArray*)colors;

@property (nonatomic, assign, readonly) int hue;
@property (nonatomic, assign, readonly) int saturation;
@property (nonatomic, assign, readonly) int brightness;
@property (nonatomic, strong, readonly) NSString *colorName;

- (instancetype)initWithHue:(int)hue saturation:(int)saturation brightness:(int)brightness colorName:(NSString *)colorName;

@end
