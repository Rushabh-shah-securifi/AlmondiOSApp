//
//  SFIColors.h
//  ReorderTest
//
//  Created by Priya Yerunkar  on 04/10/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//

@interface SFIColors : NSObject <NSCoding>

// Returns the standard list of almond colors
+ (NSArray *)colors;

+ (SFIColors *)greenColor;

+ (SFIColors *)blueColor;

+ (SFIColors *)redColor;

+ (SFIColors *)pinkColor;

+ (SFIColors *)purpleColor;

+ (SFIColors *)limeColor;

+ (SFIColors *)yellowColor;

@property(nonatomic, readonly) int hue;
@property(nonatomic, readonly) int saturation;
@property(nonatomic, readonly) int brightness;
@property(nonatomic, readonly) NSString *colorName;

- (instancetype)initWithHue:(int)hue saturation:(int)saturation brightness:(int)brightness colorName:(NSString *)colorName;

// Returns a UIColor whose brightness is computed as an incrementally gradation on the position index.
// The index is assumed to be a row number in a table view or a similar indexed structure.
// This method is used for coloring a sequence of table cells with the same color tint that varies by brightness.
- (UIColor *)makeGradatedColorForPositionIndex:(int)index;

// Convert to a UIColor
- (UIColor *)color;

// Converts to a UIColor having the specified brightness.
// Brightness value: 0 - 100.
- (UIColor *)colorWithBrightness:(int)brightness;

@end
