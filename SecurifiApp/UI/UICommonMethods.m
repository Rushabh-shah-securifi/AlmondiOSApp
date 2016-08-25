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

+(void)setupUpdateAvailableScreen:(UIView *)bgView viewWidth:(CGFloat)viewWidth{

    UILabel *hdrTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 22, viewWidth, 40)];
    
    [CommonMethods setLableProperties:hdrTitle text:NSLocalizedString(@"almond_update_available", @"Almond Update Available") textColor:[UIColor blackColor] fontName:@"AvenirLTStd-Heavy" fontSize:20 alignment:NSTextAlignmentCenter];
    
    hdrTitle.center = CGPointMake(viewWidth/2 + 5, hdrTitle.center.y);
    [bgView addSubview:hdrTitle];
    
    [CommonMethods addLineSeperator:bgView yPos:65];
    
    //image 200
    UIImageView *routerSettingImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, 200, 180)];
    routerSettingImg.center = CGPointMake(viewWidth/2, routerSettingImg.center.y);
    routerSettingImg.image = [UIImage imageNamed:@"almond_settings"];
    [bgView addSubview:routerSettingImg];
    
    //detail view
    UIView *detailView = [[UIView alloc]initWithFrame:CGRectMake(0, 315, viewWidth,250)];
    [bgView addSubview:detailView];
    
    UILabel *detailTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 20)];
    [CommonMethods setLableProperties:detailTitle text:NSLocalizedString(@"almond_requires_update", @"Your Almond requires an update.") textColor:[SFIColors ruleGraycolor] fontName:@"AvenirLTStd-Heavy" fontSize:20 alignment:NSTextAlignmentCenter];
    [detailView addSubview:detailTitle];
    
    UILabel *detail = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, viewWidth-15, 220)];
    NSString *text = NSLocalizedString(@"updateAlmondScreen", @"dashBoard Your Almond update... ");
    [CommonMethods setLableProperties:detail text:text textColor:[SFIColors ruleGraycolor] fontName:@"AvenirLTStd-Roman" fontSize:16 alignment:NSTextAlignmentCenter];
    [CommonMethods setLineSpacing:detail text:text spacing:3];
    [detail sizeToFit];
    [detailView addSubview:detail];
}

@end
