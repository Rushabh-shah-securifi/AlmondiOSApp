//
//  UIFont+Securifi.m
//  Almond
//
//  Created by Securifi-Mac2 on 16/10/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "UIFont+Securifi.h"

#define AVENIR_HEAVY @"Avenir-Heavy"
#define AVENIR_ROMAN @"Avenir-Roman"
#define AVENIR_LIGHT @"Avenir-Light"

@implementation UIFont (Securifi)

+ (UIFont*)securifiFont:(CGFloat)fontSize{
    return [UIFont fontWithName:AVENIR_ROMAN size:fontSize];
}

+ (UIFont*)securifiBoldFont:(CGFloat)fontSize{
    return [UIFont fontWithName:AVENIR_HEAVY size:fontSize];
}

+ (UIFont*)securifiLightFont:(CGFloat)fontSize{
    return [UIFont fontWithName:AVENIR_LIGHT size:fontSize];
}

+ (UIFont*)securifiBoldFontSmall{
    return [UIFont fontWithName:AVENIR_HEAVY size:10];
}

+ (UIFont*)securifiBoldFont{
    return [UIFont fontWithName:AVENIR_HEAVY size:12];
}

+ (UIFont*)securifiBoldFontLarge{
    return [UIFont fontWithName:AVENIR_HEAVY size:14];
}

+ (UIFont*)securifiNormalFont{
    return [UIFont fontWithName:AVENIR_ROMAN size:12];
}



+ (UIFont*)securifiLightFont{
    return [UIFont fontWithName:AVENIR_LIGHT size:12];
}

+ (UIFont*)standardUILabelFont{
    return [UIFont fontWithName:AVENIR_HEAVY size:12];
}

+ (UIFont*)standardUITextFieldFont{
    return [UIFont fontWithName:AVENIR_ROMAN size:13];
}

+ (UIFont*)standardUIButtonFont{
    return [UIFont fontWithName:AVENIR_ROMAN size:13];
}

+ (UIFont*)standardHeadingFont{
    return [UIFont fontWithName:AVENIR_ROMAN size:16];
}

+ (UIFont*)standardHeadingBoldFont{
    return [UIFont fontWithName:AVENIR_HEAVY size:16];
}

+(UIFont*)standardNavigationTitleFont{
    return [UIFont fontWithName:AVENIR_ROMAN size:18.0];
}

@end
