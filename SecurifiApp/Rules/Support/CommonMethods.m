//
//  CommonMethods.m
//  SecurifiApp
//
//  Created by Masood on 19/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "CommonMethods.h"
#import "UIFont+Securifi.h"
#import "Colours.h"

@implementation CommonMethods

+ (BOOL) compareEntry:(BOOL)isSlider matchData:(NSString *)matchData eventType:(NSString *)eventType buttonProperties:(SFIButtonSubProperties *)buttonProperties{
    NSLog(@"(matchdata - property %@ == gval %@) (event type - property %@ == gval %@)",buttonProperties.matchData , matchData,buttonProperties.eventType,eventType);
    bool compareValue= isSlider || [matchData isEqualToString:buttonProperties.matchData];
    bool compareEvents=[eventType isEqualToString:buttonProperties.eventType];
    bool isWifiClient=![buttonProperties.eventType isEqualToString:@"AlmondModeUpdated"];
    BOOL isWeather = [buttonProperties.type isEqualToString:@"WeatherTrigger"];
    return (buttonProperties.eventType==nil && compareValue) ||
            (compareValue && compareEvents) ||
            (isWifiClient && compareEvents) ||
            (isWeather && compareValue);
}

+(NSString*)getDays:(NSArray*)earlierSelection{
    NSLog(@"earlierSelection count %ld ",earlierSelection.count);
    if(earlierSelection.count==7 || earlierSelection.count==0)
        return @"EveryDay";
    NSMutableDictionary *dayDict = [self setDayDict];
    //Loop through earlierSelection
    NSMutableString *days = [NSMutableString new];
    int i=0;
    for(NSString *dayVal in earlierSelection){
        if([dayVal isEqualToString:@""])
            continue;
        NSString *value=[dayDict valueForKey:dayVal];
        [days appendString:(i==0)?value:[NSString stringWithFormat:@",%@", value]];
        i++;
    }
    return [NSString stringWithString:days];
}

+(NSMutableDictionary*)setDayDict{
    NSMutableDictionary *dayDict = [NSMutableDictionary new];
    [dayDict setValue:@"Sun" forKey:@(0).stringValue];
    [dayDict setValue:@"Mon" forKey:@(1).stringValue];
    [dayDict setValue:@"Tue" forKey:@(2).stringValue];
    [dayDict setValue:@"Wed" forKey:@(3).stringValue];
    [dayDict setValue:@"Thu" forKey:@(4).stringValue];
    [dayDict setValue:@"Fri" forKey:@(5).stringValue];
    [dayDict setValue:@"Sat" forKey:@(6).stringValue];
    return dayDict;
}

+(BOOL)isDimmerLayout:(NSString*)genericLayout layout:(NSString *)layoutType{
    if(genericLayout  != nil){
        NSLog(@"genericLayout %@",genericLayout);
        if([genericLayout rangeOfString:layoutType options:NSCaseInsensitiveSearch].location != NSNotFound){// data string contains check string
            return YES;
        }
    }
    return NO;
}

+(void)clearTopScroll:(UIScrollView *)top middleScroll:(UIScrollView*)middle bottomScroll:(UIScrollView*)bottom{
    [self clearScrollView:top];
    [self clearScrollView:middle];
    [self clearScrollView:bottom];
}

+ (void)clearScrollView:(UIScrollView*)scrollView{
    NSLog(@"clearTopScrollView");
    NSArray *viewsToRemove = [scrollView subviews];
    for (UIView *v in viewsToRemove) {
        if (![v isKindOfClass:[UIImageView class]])
            [v removeFromSuperview];
    }
}

+ (NSMutableAttributedString *)getAttributeString:(NSString *)header fontSize:(int)fontsize LightFont:(BOOL)lightFontneed{
    UIFont *lightFont = lightFontneed?[UIFont securifiLightFont:fontsize]:[UIFont securifiBoldFont:fontsize];
    NSDictionary *arialDict = [NSDictionary dictionaryWithObject: lightFont forKey:NSFontAttributeName];
    NSMutableAttributedString *aAttrString = [[NSMutableAttributedString alloc] initWithString:header attributes: arialDict];
    return aAttrString;
}
+ (NSString *)getColorHex:(NSString*)value {
    return [self getHex:value factor:65535];
}

+ (NSString *)getDimmableHex:(NSString*)value{
    return [self getHex:value factor:255];
}

+ (NSString *)getHex:(NSString*)value factor:(int)factor{
    if (!value) {
        return @"";
    }
    float hue = [value floatValue];
    hue = hue / factor;
    UIColor *color = [UIColor colorWithHue:hue saturation:100 brightness:100 alpha:1.0];
    return [color.hexString uppercaseString];
}

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color {
    // load the image
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}
+(UIImage *)MultiplyImageByConstantColor:(UIImage*)image andColor:(UIColor *)color {
    
    CGSize backgroundSize = image.size;
    UIGraphicsBeginImageContext(backgroundSize);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect backgroundRect;
    backgroundRect.size = backgroundSize;
    backgroundRect.origin.x = 0;
    backgroundRect.origin.y = 0;
    
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    CGContextSetRGBFillColor(ctx, r, g, b, a);
    CGContextFillRect(ctx, backgroundRect);
    
    CGRect imageRect;
    imageRect.size = image.size;
    imageRect.origin.x = (backgroundSize.width - image.size.width)/2;
    imageRect.origin.y = (backgroundSize.height - image.size.height)/2;
    
    // Unflip the image
    CGContextTranslateCTM(ctx, 0, backgroundSize.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, imageRect, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
+ (NSString *)stringFromWeekday:(NSInteger)weekday
{
    static NSString *strings[] = {
        @"Sunday",
        @"Monday",
        @"Tuesday",
        @"Wednesday",
        @"Thursday",
        @"Friday",
        @"Saturday",
    };
    
    return strings[weekday - 1];
}


+ (UIColor *)colorWithHexString:(NSString *)str_HEX  alpha:(CGFloat)alpha_range{
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf([str_HEX UTF8String], "%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha_range];
}

+ (NSString *) UIColorToHexString:(UIColor *)uiColor{
    CGFloat red,green,blue,alpha;
    [uiColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    NSString *hexString  = [NSString stringWithFormat:@"%02x%02x%02x%02x",
                            ((int)alpha),((int)red),((int)green),((int)blue)];
    return hexString;
}

+ (int )getRGBValueForBlink:(NSString*)hexColor{
    UIColor *color = [UIColor colorFromHexString:hexColor];
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    int red = (int)(r * 255);
    int green = (int)(g * 255);
    int blue = (int)(b * 255);
    
    NSLog(@"r= %f,g = %f,b = %f",r,g,b);
    int colorRGB =  (((red & 0xF8) << 8) | ((green & 0xFC) << 3) | (blue >> 3));
    NSLog(@"colorRGB %d",colorRGB)  ;
    return colorRGB;
}
#pragma mark label methods
+(void)setLableProperties:(UILabel*)label text:(NSString*)text textColor:(UIColor*)textColor fontName:(NSString *)fontName fontSize:(float)size alignment:(NSTextAlignment)alignment{
    label.text = text;
    label.font = [UIFont fontWithName:fontName size:size];
    label.numberOfLines = 0;
    label.textAlignment = alignment;
    label.textColor = textColor;
}


+(void)setLineSpacing:(UILabel*)label text:(NSString *)text spacing:(int)spacing{
    NSString *labelText = text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:spacing];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    label.attributedText = attributedString ;
}

#pragma mark button methods
+(void)setButtonProperties:(UIButton*)tapbutton title:(NSString *)title selector:(SEL)selector titleColor:(UIColor*)titleColor{
    [tapbutton setTitle:title forState:UIControlStateNormal];
    [tapbutton setTitleColor:titleColor forState:UIControlStateNormal];
    [tapbutton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark ui methods
+(void)addLineSeperator:(UIView*)view yPos:(int)ypos{
    UIView *lineSeperator = [[UIView alloc]initWithFrame:CGRectMake(0, ypos, view.frame.size.width, 1)];
    lineSeperator.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:lineSeperator];
}


@end
