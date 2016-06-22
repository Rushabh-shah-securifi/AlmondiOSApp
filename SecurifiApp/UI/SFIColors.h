//
//  SFIColors.h
//  ReorderTest
//
//  Created by Priya Yerunkar  on 04/10/13.
//  Copyright (c) 2013 Ben Vogelzang. All rights reserved.
//

@interface SFIColors : NSObject <NSCoding>

+ (SFIColors *)colorForIndex:(NSUInteger)index;

+ (SFIColors *)greenColor;

+ (SFIColors *)blueColor;

+ (SFIColors *)redColor;

+ (SFIColors *)pinkColor;

+ (SFIColors *)purpleColor;

+ (SFIColors *)limeColor;

+ (SFIColors *)yellowColor;

+ (UIColor *)ruleBlueColor;

+ (UIColor *)ruleOrangeColor;

+ (UIColor *)ruleGraycolor;

+ (UIColor *)ruleLightGrayColor;

+ (UIColor *)darkGrayColor;

+ (UIColor *)lightGreenColor;

+ (UIColor *)ruleLightOrangeColor;

+ (UIColor *)disableGreenColor;

+ (UIColor *)clientInActiveGrayColor;

+ (UIColor *)clientBlockedGrayColor;

+ (UIColor *)clientGreenColor;

+ (UIColor *)gridBlockColor;

+ (UIColor *)testGrayColor;

+ (UIColor *)test1GrayColor;

+ (UIColor *)lightBlueColor;

+ (UIColor *)lightOrangeDashColor;

+ (UIColor *)lightGrayColor;

- (instancetype)initWithHue:(int)hue saturation:(int)saturation brightness:(int)brightness colorName:(NSString *)colorName;

// Returns a UIColor whose brightness is computed as an incrementally gradation on the position index.
// The index is assumed to be a row number in a table view or a similar indexed structure.
// This method is used for coloring a sequence of table cells with the same color tint that varies by brightness.
- (UIColor *)makeGradatedColorForPositionIndex:(NSUInteger)index;

// Convert to a UIColor
- (UIColor *)color;

// Converts to a UIColor having the specified brightness.
// Brightness value: 0 - 100.
- (UIColor *)colorWithBrightness:(int)brightness;

+ (UIColor *)lighterColorForColor:(UIColor *)c;

+ (UIColor *)darkerColorForColor:(UIColor *)c;

@end
