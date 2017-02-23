//
//  UICommonMethods.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 31/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "UICommonMethods.h"
#import "CommonMethods.h"
#import "SWRevealViewController.h"
#import "SFIColors.h"

@implementation UICommonMethods

+(void)setLableProperties:(UILabel*)label text:(NSString*)text textColor:(UIColor*)textColor fontName:(NSString *)fontName fontSize:(float)size alignment:(NSTextAlignment)alignment{
    label.text = text;
    label.font = [UIFont fontWithName:fontName size:size];
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


+(void)setButtonProperties:(UIButton*)button title:(NSString *)title titleColor:(UIColor*)titleColor bgColor:(UIColor *)bgColor font:(UIFont *)font{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.backgroundColor = bgColor;
    button.titleLabel.font = font;
}


+(void)addLineSeperator:(UIView*)view yPos:(int)ypos{
    UIView *lineSeperator = [[UIView alloc]initWithFrame:CGRectMake(0, ypos, view.frame.size.width, 1)];
    lineSeperator.backgroundColor = [SFIColors lineColor];
    [view addSubview:lineSeperator];
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


+(CGRect)adjustDeviceNameWidth:(NSString*)name fontSize:(int)fontSize maxLength:(int)maxLength{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGRect textRect;
    textRect.size = [name sizeWithAttributes:attributes];
    if(name.length > maxLength){
        NSString *temp=@"123456789012345678";
        textRect.size = [temp sizeWithAttributes:attributes];
    }
    return textRect;
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


+(void)setupUpdateAvailableScreen:(UIView *)bgView viewWidth:(CGFloat)viewWidth{
    //image 200
    UIImageView *routerSettingImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, 200, 180)];
    routerSettingImg.center = CGPointMake(viewWidth/2, routerSettingImg.center.y);
    routerSettingImg.image = [UIImage imageNamed:@"almond_settings"];
    [bgView addSubview:routerSettingImg];
    
    //detail view
    UIView *detailView = [[UIView alloc]initWithFrame:CGRectMake(0, 235, viewWidth,250)];
    [bgView addSubview:detailView];
    
    UILabel *detailTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 20)];
    [UICommonMethods setLableProperties:detailTitle text:NSLocalizedString(@"almond_requires_update", @"Your Almond requires an update.") textColor:[SFIColors ruleGraycolor] fontName:@"AvenirLTStd-Heavy" fontSize:20 alignment:NSTextAlignmentCenter];
    [detailView addSubview:detailTitle];
    
    UILabel *detail = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, viewWidth-15, 220)];
    NSString *text = NSLocalizedString(@"updateAlmondScreen", @"dashBoard Your Almond update... ");
    [self setLableProperties:detail text:text textColor:[SFIColors ruleGraycolor] fontName:@"AvenirLTStd-Roman" fontSize:16 alignment:NSTextAlignmentCenter];
    [UICommonMethods setLineSpacing:detail text:text spacing:3];
    [detail sizeToFit];
    [detailView addSubview:detail];
}


+ (void)clearSubView:(UIView *)view{
    NSLog(@"view: %@, subview: %@", view, view.subviews);
    NSArray *subViews = view.subviews;
    for(UIView *view in subViews){
        [view removeFromSuperview];
    }
}

+ (void)clearSubviewsInScrollView:(UIScrollView *)scrollView{
    for(UIView *view in scrollView.subviews){
        if(![view isKindOfClass:[UIImage class]]){
            [view removeFromSuperview];
        }
    }
}

@end
