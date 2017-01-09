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

+ (NSAttributedString *)getAttributedString:(NSString *)text subText:(NSString *)subText fontSize:(int)fontSize{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange boldRange = [text rangeOfString:subText];
    [attrString addAttribute:NSFontAttributeName value:[UIFont securifiBoldFont:fontSize] range:boldRange];
    return attrString;
}

+ (NSAttributedString *)getAttributedStringWithAttribute:(NSAttributedString *)attributedText subText:(NSString *)subText fontSize:(int)fontSize{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    NSRange boldRange = [attributedText.string rangeOfString:subText];
    [attrString addAttribute:NSFontAttributeName value:[UIFont securifiBoldFont:fontSize] range:boldRange];
    return attrString;
}
+ (NSAttributedString *)getAttributedString:(NSString *)text1 subText:(NSString *)subText text:(NSString *)text2 fontSize:(int)fontSize{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text1];
    NSAttributedString *attrString2 = [[NSAttributedString alloc] initWithString:text2];
    
    NSDictionary *attrDict = [NSDictionary dictionaryWithObject:[UIFont securifiBoldFont:fontSize] forKey:NSFontAttributeName];
    NSAttributedString *boldString = [[NSAttributedString alloc]initWithString:subText attributes:attrDict];
    
    [attrString appendAttributedString:boldString];
    [attrString appendAttributedString:attrString2];
    return attrString;
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
    UIColor *color = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
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

+(void)setLabelProperties:(UILabel*)button title:(NSString *)title titleColor:(UIColor*)titleColor bgColor:(UIColor *)bgColor font:(UIFont *)font{
    button.text = title;
    button.textColor = titleColor;
    button.backgroundColor = bgColor;
    button.font = font;
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

+(void)getHSLFromDecimal:(int)decimal h:(float*)h s:(float*)s l:(float*)l{
    int RGB = decimal;
    
    int r =  ((RGB & 0xFF0000) >> 16);
    int g = ((RGB & 0x00FF00) >> 8);
    int b = (RGB & 0x0000FF);

    float nh, ns, nl;
    RGB2HSL(r, g, b, &nh, &ns, &nl);
    *h = nh;
    *s = ns;
    *l = nl;
}

+(float )getBrightnessValue:(NSString *)value{
    
    int RGB = value.intValue;
    
    int r =  ((RGB & 0xFF0000) >> 16);
    int g = ((RGB & 0x00FF00) >> 8);
    int b = (RGB & 0x0000FF);
    
//    NSLog(@"r= %d,g= %d,b=%d",r,g,b);
//    CGFloat h, s, l;
//    RVNColorRGBtoHSL(r, g, b,
//                     &h, &s, &l);
//    NSLog(@"h: %f, s: %f, l: %f", h, s, l);
//    NSLog(@"brightness val: %f", l);
//    return l;
    
    float nh, ns, nl;
    RGB2HSL(r, g, b, &nh, &ns, &nl);
    NSLog(@"h: %f, s: %f, l: %f", nh, ns, nl);
    NSLog(@"brightness val: %f", nl*100);

    return nl*100;
}

static void RGB2HSL(float r, float g, float b, float* outH, float* outS, float* outL)
{
    r = r/255.0f;
    g = g/255.0f;
    b = b/255.0f;
    
    
    float h,s, l, v, m, vm, r2, g2, b2;
    
    h = 0;
    s = 0;
    l = 0;
    
    v = MAX(r, g);
    v = MAX(v, b);
    m = MIN(r, g);
    m = MIN(m, b);
    
    l = (m+v)/2.0f;
    
    if (l <= 0.0){
        if(outH)
            *outH = h;
        if(outS)
            *outS = s;
        if(outL)
            *outL = l;
        return;
    }
    
    vm = v - m;
    s = vm;
    
    if (s > 0.0f){
        s/= (l <= 0.5f) ? (v + m) : (2.0 - v - m);
    }else{
        if(outH)
            *outH = h;
        if(outS)
            *outS = s;
        if(outL)
            *outL = l;
        return;
    }
    
    r2 = (v - r)/vm;
    g2 = (v - g)/vm;
    b2 = (v - b)/vm;
    
    if (r == v){
        h = (g == m ? 5.0f + b2 : 1.0f - g2);
    }else if (g == v){
        h = (b == m ? 1.0f + r2 : 3.0 - b2);
    }else{
        h = (r == m ? 3.0f + g2 : 5.0f - r2);
    }
    
    h/=6.0f;
    
    if(outH)
        *outH = h;
    if(outS)
        *outS = s;
    if(outL)
        *outL = l;
    
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
    NSLog(@"fun h: %f, s: %f, l: %f", h, s, l);
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

+(int)getRGBDecimalFromHSL:(float)h s:(float)s l:(float)l{
    float red, green, blue;
    NSLog(@"h: %f, s: %f, l: %f", h, s, l);
    HSL2RGB(h, s, l, &red, &green, &blue);
    NSLog(@"r = %f, g = %f, b = %f", red, green, blue);
    

    int colorRGB =  (((int)red << 16) | ((int)green << 8) | (int)blue);
    NSLog(@"Colorrgb: %d", colorRGB);
    return colorRGB;
}

static void HSL2RGB(float h, float s, float l, float* outR, float* outG, float* outB)
{
    float			temp1,temp2;
    float			temp[3];
    int				i;
    
    // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
    if(s == 0.0) {
        if(outR)
            *outR = l;
        if(outG)
            *outG = l;
        if(outB)
            *outB = l;
        return;
    }
    
    // Test for luminance and compute temporary values based on luminance and saturation
    if(l < 0.5)
        temp2 = l * (1.0 + s);
    else
        temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;
    
    // Compute intermediate values based on hue
    temp[0] = h + 1.0 / 3.0;
    temp[1] = h;
    temp[2] = h - 1.0 / 3.0;
    
    for(i = 0; i < 3; ++i) {
        
        // Adjust the range
        if(temp[i] < 0.0)
            temp[i] += 1.0;
        if(temp[i] > 1.0)
            temp[i] -= 1.0;
        
        
        if(6.0 * temp[i] < 1.0)
            temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
        else {
            if(2.0 * temp[i] < 1.0)
                temp[i] = temp2;
            else {
                if(3.0 * temp[i] < 2.0)
                    temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
                else
                    temp[i] = temp1;
            }
        }
    }
    
    // Assign temporary values to R, G, B
    if(outR)
        *outR = temp[0];
    if(outG)
        *outG = temp[1];
    if(outB)
        *outB = temp[2];
}

+(int)getRGBFromHSB:(int)hue saturation:(int)saturation {
    float red;
    float green;
    float blue;
    
    float h = 0.0;
    float s = 0.0;
    float l = 94.90196078431372 * 255.0 / 100.0;
    
    NSLog(@"h: %f, s: %f, l: %f", h, s, l);
    
    HSL2RGB(h, s, l, &red, &green, &blue);
    NSLog(@"r = %f, g = %f, b = %f", red, green, blue);
    
//    CGFloat nred;
//    CGFloat ngreen;
//    CGFloat nblue;
//    CGFloat alpha;
//    UIColor *color = [UIColor colorWithHue:h saturation:s
//                                brightness:l alpha:1.0];
//    if ( [color getRed:&nred green:&ngreen blue:&nblue alpha:&alpha]) {
//        // color converted
//    }
//    NSLog(@"r = %f, g = %f, b = %f", nred, ngreen, nblue);
    
    int colorRGB =  (((int)red << 16) | ((int)green << 8) | (int)blue);;
    NSLog(@"Colorrgb: %d", colorRGB);
    return colorRGB;
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
+(NSString *)hexToString:(NSString*)mac{
    
    NSString *stringWithoutColon = [mac
                                    stringByReplacingOccurrencesOfString:@":" withString:@""];
    unsigned long long int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:stringWithoutColon];
    [scanner scanHexLongLong:&outVal];
    NSLog(@"mac in decimal %@,%lld",mac,outVal);
    
    
    return @(outVal).stringValue;
}
+(NSArray *)getOrderedArr:(NSArray *)arr{

    NSArray *arrTem = [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([[obj1 valueForKey:@"LastVisitedEpoch"] integerValue] > [[obj2 valueForKey:@"LastVisitedEpoch"] integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if ([[obj1 valueForKey:@"LastVisitedEpoch"] integerValue] < [[obj2 valueForKey:@"LastVisitedEpoch"] integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    return [[NSMutableArray alloc]initWithArray:arrTem];
}
#pragma mark searchPage methods
+(NSDictionary *)createSearchDictObj:(NSArray*)allObj search:(NSString *)search{
    NSDictionary *catogeryDict = [self parseJson:@"CategoryMap"];
        allObj = [self getOrderedArr:allObj];
    
    NSMutableDictionary *dayDict = [NSMutableDictionary new];
    for(NSDictionary *uriDict in allObj)
    {
        NSString *ID = uriDict[@"subCategory"];
        NSDictionary *categoryName = catogeryDict[ID];
        if([search isEqualToString:@"LastHour"])
        {
            NSInteger lastHour = [uriDict[@"LastVisitedEpoch"] integerValue];
            NSInteger systemLastHour = round([[NSDate date] timeIntervalSince1970]) - 3600;
            
            if(lastHour < systemLastHour){
                NSLog(@"lastHour %ld systemLastHour %ld",lastHour,systemLastHour);
                continue;
            }
            
        }
        NSDictionary *categoryObj = @{@"ID":ID,
                                      @"categoty":categoryName[@"category"],
                                      @"subCategory":categoryName[@"categoryName"]};
        
        NSDictionary *uriInfo1 = @{
                                   @"hostName" : uriDict[@"Domain"],
                                   @"Epoc" : uriDict[@"LastVisitedEpoch"],
                                   @"date" : uriDict[@"Date"],
                                   @"categoryObj" : categoryObj
                                   };
        
        [self addToDictionary:dayDict uriInfo:uriInfo1 rowID:uriDict[@"Date"]];
        
    }
    NSLog(@"return Day dict %@",dayDict);
    return dayDict;
}
+ (void)addToDictionary:(NSMutableDictionary *)rowIndexValDict uriInfo:(NSDictionary *)uriInfo rowID:(NSString *)day{
    
    NSMutableArray *augArray = [rowIndexValDict valueForKey:[NSString stringWithFormat:@"%@",day]];
    if(augArray != nil){
        [augArray addObject:uriInfo];
        [rowIndexValDict setValue:augArray forKey:[NSString stringWithFormat:@"%@",day]];
    }else{
        NSMutableArray *tempArray = [NSMutableArray new];
        [tempArray addObject:uriInfo];
        [rowIndexValDict setValue:tempArray forKey:[NSString stringWithFormat:@"%@",day]];
    }
}
+ (NSString *)getTodayDate{
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"yyyy-MM-dd"]; // Date formater
    NSString *date = [dateformate stringFromDate:[NSDate date]]; // Convert date to string
    return date;
    
}

+ (NSString *) getLastWeekDayDate:(NSString *)weekDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    comps.day   = -7;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    for(int i = 0;i<7;i++){
        comps.day   = -i;
        NSDate *date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
        dateFormatter.dateFormat=@"EEEE";
        NSString *dayString = [[dateFormatter stringFromDate:date] capitalizedString];
        if([[dayString uppercaseString] rangeOfString:[weekDay uppercaseString]].location != NSNotFound){
            dateFormatter.dateFormat=@"yyyy-MM-dd";
            NSString *dayString = [[dateFormatter stringFromDate:date] capitalizedString];
            return dayString;
        }
        
    }
    return NULL;
}
+(NSString *)getPresentTime24Format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat=@"HH:mm";
    return [dateFormatter stringFromDate:[NSDate date]];
    
}
+ (NSString *)getYestardayDate{
    NSDateComponents *comps = [NSDateComponents new];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    comps.day   = -1;
    NSDate *date = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    [dateformate setDateFormat:@"yyyy-MM-dd"]; // Date formater
    NSString *dateStr = [dateformate stringFromDate:date]; // Convert date to string
    return dateStr;
    
}
+(NSArray *)domainEpocArr:(NSArray *)arr{
    NSMutableArray *epocSArr = [NSMutableArray new];
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self"
                                                                ascending: NO];
   
    if(arr.count > 0){
        NSDictionary *dict = [arr objectAtIndex:0];
        if(dict[@"Epochs"]==NULL)
            return @[];
        NSArray *epocArr = dict[@"Epochs"];
         arr =  [epocArr sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
        for(NSString *epoc in arr){
            NSDate *dat = [NSDate dateWithTimeIntervalSince1970:[epoc intValue]];
            [epocSArr addObject:[dat stringFromDate]];
        }
    }
    
    return epocSArr;
}
+(NSString *)isVulnerable:(NSString *)caseStr{
    if([caseStr isEqualToString:@"1"])
        return @"is vulnerable";
    else
        return @"may be vulnerable";
}
+(NSString *)type:(NSString *)type{
    if([type isEqualToString:@"1"])
        return @"Open telnet port with weak username and password";
    else if([type isEqualToString:@"2"])
        return @"Several open ports found in device ";
    else if([type isEqualToString:@"3"])
        return @"Local web page uses weak username and  password";
    else if([type isEqualToString:@"4"])
        return @"Port forwarding enabled for this device";
    else
        return @"Device using Universal Plug and Play(UPnP) service";
    
}

+ (NSString *)getExplanationText:(NSString *)type{
    if([type isEqualToString:@"1"])
        return @"Your device  has an open telnet (port:80) and uses a weak username and password. Telnet enabled devices are highly vulnerable to Mirai Botnet attacks. We suggest you block this device or create a strong username and password if you can access the telnet. Contact your device vendor for more assistance.";
    else if([type isEqualToString:@"2"])
        return @"Your device has open ports. These ports may be used by some applications for allowing remote access of your system. If you do not use this device for such applications,it may be vulnerable. We suggest you block this device or contact your device vendor.";
    else if([type isEqualToString:@"3"])
        return @"The local web interface for this device uses a weak username and password. We suggest you block the device or change the password. Typically, settings can be accessed by entering the ip address of the device in your web browser. Contact your device vendor for more assistance.";
    else if([type isEqualToString:@"4"])
        return @"Your device is being used for port forwarding. Port forwarding is usually enabled manually for gaming applications and for remote access of cameras and DVRs. If you are not aware of port forwarding for this device, we suggest you block this device or contact your device vendor.";
    else
        return @"UPnP is a protocol that applications use to automatically set up port forwarding in the router. Viruses and Malwares can use UPnP in devices to gain remote access of your network. You can disable UPnP on your Almond from the Wifi tab.";
  
    
}

+(BOOL)isIoTdevice:(NSString *)clientType{
    NSArray *iotTypes = @[@"withings",@"dlink_cameras",@"hikvision",@"foscam",@"motorola_connect",@"ibaby_monitor",@"osram_lightify",@"honeywell_appliances",@"ge_appliances",@"wink",@"airplay_speakers",@"sonos",@"belkin_wemo",@"samsung_smartthings",@"ring_doorbell",@"piper",@"canary",@"august_connect",@"nest_cam",@"nest_protect",@"nest_thermostat",@"amazon_dash",@"amazon_echo",@"nest",@"philips_hue"];
    if([iotTypes containsObject: clientType] )
        return YES;
    else return  NO;
}



=======
+(NSString *)colorShadesforValue:(int)defaultcolor byValueOfcolor:(NSString *)value{
    float hue = [value floatValue];
    int intClolor = defaultcolor/8;
    
    
    UIColor *color = [UIColor colorWithHue:(hue/defaultcolor) saturation:100 brightness:100 alpha:1.0];
    //                    NSDictionary *attr = @{
    //                            NSBackgroundColorAttributeName : color,
    //                    }
    //                    NSAttributedString *a = [[NSAttributedString alloc] initWithString:@"\u25a1" attributes:attr];
    if(hue>=0 && hue <= 1*intClolor)
        return [NSString stringWithFormat:@"%@(%@)",@"red shade",[color.hexString uppercaseString]];
    else if(hue>=1 && hue <= 2*intClolor)
        return [NSString stringWithFormat:@"%@(%@)",@"orange shade",[color.hexString uppercaseString]];
    else if(hue>=2 && hue <= 3*intClolor)
        return [NSString stringWithFormat:@"%@(%@)",@"yellow shade",[color.hexString uppercaseString]];
    else if(hue>=3 && hue <= 4*intClolor)
        return [NSString stringWithFormat:@"%@(%@)",@"green shade",[color.hexString uppercaseString]];
    else if(hue>=5 && hue <= 6*intClolor)
        return [NSString stringWithFormat:@"%@(%@)",@"indigo shade",[color.hexString uppercaseString]];
    else if(hue>=6 && hue <= 7*intClolor)
        return [NSString stringWithFormat:@"%@(%@)",@"violet shade",[color.hexString uppercaseString]];
    else if(hue > 7 *intClolor)
        return [NSString stringWithFormat:@"%@(%@)",@"reddish shade",[color.hexString uppercaseString]];
    else
        return [NSString stringWithFormat:@"(%@)",[color.hexString uppercaseString]];
}
@end
