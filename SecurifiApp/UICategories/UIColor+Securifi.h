//
// Created by Matthew Sinclair-Day on 4/20/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (Securifi)

+ (UIColor *)colorWithKelvin:(CGFloat)kelvin;

+ (UIColor *)securifiRouterTileSlateColor;

+ (UIColor *)securifiRouterTileGreenColor;

+ (UIColor *)securifiRouterTileBlueColor;

+ (UIColor *)securifiRouterTileYellowColor;

+ (UIColor *)securifiRouterTileRedColor;

+ (UIColor *)securifiLightBlue;

+ (UIColor*)securifiScreenBlue;

+ (UIColor *)securifiScreenGreen;

@end