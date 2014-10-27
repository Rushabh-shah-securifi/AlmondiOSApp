//
//  SFIColors.h
//  ReorderTest
//
//  Created by Priya Yerunkar  on 04/10/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIColors : NSObject <NSCoding>

// Returns the standard list of almond colors
+ (NSArray*)colors;

@property (nonatomic, assign, readonly) int hue;
@property (nonatomic, assign, readonly) int saturation;
@property (nonatomic, assign, readonly) int brightness;
@property (nonatomic, strong, readonly) NSString *colorName;

- (instancetype)initWithHue:(int)hue saturation:(int)saturation brightness:(int)brightness colorName:(NSString *)colorName;

// Returns a UIColor whose brightness is computed as an incrementally gradation on the position index.
// The index is assumed to be a row number in a table view or similar UI structure.
// This is used to color a sequence of table cells with the same color tint and varying by brightness.
- (UIColor*)makeGradatedColorForPositionIndex:(int)index;

// Converts the SFIColors to a UIColor having the specified brightness.
// Brightness value: 0 - 100.
- (UIColor *)colorWithBrightness:(int)brightness;

@end
