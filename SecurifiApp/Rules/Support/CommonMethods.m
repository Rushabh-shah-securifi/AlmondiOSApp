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
#import "AlmondJsonCommandKeyConstants.h"
#import "SFIColors.h"

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
+(void)setButtonProperties:(UIButton*)button title:(NSString *)title titleColor:(UIColor*)titleColor bgColor:(UIColor *)bgColor font:(UIFont *)font{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.backgroundColor = bgColor;
    button.titleLabel.font = font;
}

#pragma mark ui methods
+(void)addLineSeperator:(UIView*)view yPos:(int)ypos{
    UIView *lineSeperator = [[UIView alloc]initWithFrame:CGRectMake(0, ypos, view.frame.size.width, 1)];
    lineSeperator.backgroundColor = [SFIColors lineColor];
    [view addSubview:lineSeperator];
}

#pragma mark parsing
+ (NSDictionary*)parseJson:(NSString*)fileName{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName
                                                         ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:dataFromFile
                                                         options:kNilOptions
                                                           error:&error];
    
    if (error != nil) {
        NSLog(@"Error: was not able to load json file: %@.",fileName);
    }
    return data;
}

#pragma mark helpcenter json parsing methods
+ (NSDictionary *)getDict:(NSString*)helpItem itemName:(NSString*)itemName{//helpItem, itemName
    NSArray *helpItems = [[CommonMethods parseJson:@"helpCenterJson"] valueForKey:@"HelpItems"];
    NSDictionary *guide = [self getDictForName:helpItem array:helpItems];
    return [CommonMethods getDictForName:itemName array:guide[ITEMS]];
}

+ (NSDictionary *)getMeshDict:(NSString *)itemName{
    NSArray *meshItems = [[CommonMethods parseJson:@"helpCenterJson"] valueForKey:@"Mesh"];
    return [self getDictForName:itemName array:meshItems];
}
+ (NSDictionary *)getDictForName:(NSString*)name array:(NSArray*)array{
    for(NSDictionary *dict in array){
        if([dict[@"name"] isEqualToString:name]){
            return dict;
        }
    }
    return nil;
}

#pragma mark site monitoring methods
+(BOOL)isContainMonth:(NSString*)search{
    NSArray *monthArr = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    for (NSString *month  in monthArr) {
        if([[search uppercaseString] rangeOfString:[month uppercaseString]].location != NSNotFound)
            return YES;
    }
    return  NO;
    
}
+(BOOL)isContainCategory:(NSString*)search{
    NSArray *categoryArr =@[
    @"NC-17",
    @"R",
    @"PG-13",
    @"PG",
    @"G"
    ];
    for (NSString *category  in categoryArr) {
        if([category isEqualToString:search])
            return YES;
    }
    return  NO;
    
}
+(BOOL)isContainWeeKday:(NSString*)search{
    NSArray *weekDay = @[@"sunday", @"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday"];
    for (NSString *day  in weekDay) {
        if([[day uppercaseString] rangeOfString:[search uppercaseString]].location != NSNotFound)
            return YES;
    }
    return  NO;
    
}


+ (BOOL) isAllDigits:(NSString *)string
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [string rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound && string.length > 0;
}
+(BOOL)checkValidation:(NSString*)search date:(NSString *)date monthname:(NSString *)monthName{
    NSArray * searchArr = [search componentsSeparatedByString:@" "];
    NSString *day;
    NSString *month;
    for(NSString *str in searchArr){
        if( [self isContainMonth:str])
            month = str;
        
        if([self isNumeric:str])
            day = str;
        
    }
    NSLog(@" month and date %@,%@",day,month);
    if ([day isEqualToString:date] && [[month uppercaseString] isEqualToString:[monthName uppercaseString]]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isNumeric:(NSString *)code{
    
    NSScanner *ns = [NSScanner scannerWithString:code];
    int the_value;
    if ( [ns scanInt:&the_value] )
    {
        NSLog(@"INSIDE IF");
        return YES;
    }
    else {
        return  NO;
    }
}


+ (int )getRGBForHex:(NSString*)hueValue sliderValue:(NSString*)slider{
    NSLog(@"hueValue Slidr value %@,%@",hueValue,slider);
    NSString *colorHex = [CommonMethods getColorHex:hueValue];
    UIColor *color = [UIColor colorFromHexString:colorHex];
    CGFloat r,g,b,a;
    int sliderValue = [slider intValue];
    [color getRed:&r green:&g blue:&b alpha:&a];
    int red = (int)((r * 255 )  );
    int green = (int)((g * 255 ) );
    int blue = (int)((b * 255 ) );
    CGFloat h, s, l;
    RVNColorRGBtoHSL(r, g, b,
                     &h, &s, &l);
    NSLog(@"r= %f,g = %f,b = %f",r,g,b);
    
    int colorRGB =  (((red & 0xF8) << 8) | ((green & 0xFC) << 3) | (blue >> 3));
    NSLog(@"colorRGB %d",colorRGB)  ;
    colorRGB = [self getRGBFromHSB:[hueValue intValue] saturation:sliderValue];
    return colorRGB;
}

static void RVNColorRGBtoHSL(CGFloat red, CGFloat green, CGFloat blue, CGFloat *hue, CGFloat *saturation, CGFloat *lightness)
{
    CGFloat r = red / 255.0f;
    CGFloat g = green / 255.0f;
    CGFloat b = blue / 255.0f;
    
    CGFloat max = MAX(r, g);
    max = MAX(max, b);
    CGFloat min = MIN(r, g);
    min = MIN(min, b);
    
    CGFloat h;
    CGFloat s;
    CGFloat l = (max + min) / 2.0f;
    
    if (max == min) {
        h = 0.0f;
        s = 0.0f;
    }
    
    else {
        CGFloat d = max - min;
        s = l > 0.5f ? d / (2.0f - max - min) : d / (max + min);
        
        if (max == r) {
            h = (g - b) / d + (g < b ? 6.0f : 0.0f);
        }
        
        else if (max == g) {
            h = (b - r) / d + 2.0f;
        }
        
        else if (max == b) {
            h = (r - g) / d + 4.0f;
        }
        
        h /= 6.0f;
    }
    
    if (hue) {
        *hue = roundf(h * 255.0f);
    }
    
    if (saturation) {
        *saturation = roundf(s * 255.0f);
    }
    
    if (lightness) {
        *lightness = roundf(l * 255.0f);
    }
}

+(int)getRGBFromHSB:(int)hue saturation:(int)saturation {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    float h = (float)hue/65535;
    float s = (float)(saturation)/255;
    float l = 100.0;
    //    h = 55.0/255.0;
    //    s = 100.0;
    //    l = 126.0 * 100.0/255.0;
    NSLog(@"hue %d,and sat = %d ",hue,saturation);
    NSLog(@"h: %f, s: %f, l: %f", h, s, l);
    UIColor *color = [UIColor colorWithHue:h saturation:s
                                brightness:l alpha:1.0];
    
    
    if ( [color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        // color converted
    }
    
    NSLog(@"red = %f green =%f blue = %f",red*255  ,green*255  ,blue*255  );
    int colorRGB =  ((((int)(red*255) & 0xF8) << 8) | (((int)(green*255) & 0xFC) << 3) | ((int)(blue*255) >> 3));
    NSLog(@"Colorrgb: %d", colorRGB);
    return colorRGB;
}

+(float )getHueValue:(NSString *)value{
    int RGB = value.intValue;
    
    int r =  ((RGB & 0xF800) >> 8);
    int g = ((RGB & 0x7E0) >> 3);
    int b = ((RGB & 0x1F) << 3);
    NSLog(@"r= %d,g= %d,b=%d",r,g,b);
    
    CGFloat h, s, l;
    RVNColorRGBtoHSL(r, g, b,
                     &h, &s, &l);
    
    NSLog(@" h== %f,s== %f l== %f",h,s,l);
    float hueVal = h*(65535/255);
    NSLog(@"hue val: %f", hueVal);
    return hueVal;
    
}
+(float )getSatValue:(NSString *)value{
    
    int RGB = value.intValue;
    
    int r =  ((RGB & 0xF800) >> 8);
    int g = ((RGB & 0x7E0) >> 3);
    int b = ((RGB & 0x1F) << 3);
    
    NSLog(@"r= %d,g= %d,b=%d",r,g,b);
    CGFloat h, s, l;
    RVNColorRGBtoHSL(r, g, b,
                     &h, &s, &l);
    NSLog(@"h: %f, s: %f, l: %f", h, s, l);
    NSLog(@"saturation val: %f", s);
    return s;
}
+(NSString *)getShortAlmondName:(NSString*)almondName{
    return  [self getName:almondName length:20];
    
}

+(NSString *)getTitleShortName:(NSString *)name{
    return [self getName:name length:14];
}

+(NSString *)getName:(NSString *)name length:(int)lenght{
    NSString *newName = name;
    if(name.length >= lenght){
        newName = [name substringToIndex:lenght];
        newName = [NSString stringWithFormat:@"%@..", newName];
    }
    NSLog(@"new name: %@", newName);
    return newName;
}
@end
