//
//  SFIRulesActionButton.m
//  Tableviewcellpratic
//
//  Created by Securifi-Mac2 on 24/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//


#import "SwitchButton.h"
#import "SFIColors.h"
#import "RulesConstants.h"
#import <QuartzCore/QuartzCore.h>

@implementation SwitchButton{
    UIView * bgView;
    UIImageView * imgIcon;
    UILabel *lblTitle;
    UILabel *lblMain;
    UILabel *countLable;
    UILabel *lblDeviceName;
    BOOL isTrigger;
    
}

-(id) initWithFrame: (CGRect) frame
{
    frame.size.height = 80;
    frame.size.width = 80;
    return [super initWithFrame:frame];
    //    return self;
}
-(id) initializ: (CGRect) frame isTrigger:(BOOL)isTrigger
{
    return [ self initWithFrame:frame];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
   
}

- (void)changeStylewithColor:(BOOL)isTrigger{
    UIColor *selectedColor= isTrigger?[SFIColors ruleBlueColor]:[SFIColors ruleOrangeColor];
    if (!isTrigger || self.selected) {
        lblTitle.textColor = selectedColor;
        bgView.backgroundColor = selectedColor;
    }else{
        lblTitle.textColor = [SFIColors ruleGraycolor];
        bgView.backgroundColor = [SFIColors ruleGraycolor];
    }
}

- (void)adDeviceName:(NSString *)title
{
    //device name title
    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
    lblDeviceName.text = title;
    [lblDeviceName setFont: [lblDeviceName.font fontWithSize: fontSize]];
    lblDeviceName.numberOfLines=0;
    lblDeviceName.textColor = self.currentTitleColor;
    lblDeviceName.textAlignment = NSTextAlignmentCenter;
    lblDeviceName.textColor = [UIColor blackColor];
    [self addSubview:lblDeviceName];
}

- (void)addBgView:(int)y widthAndHeight:(int)widthAndHeight
{
    //bgview
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, y , widthAndHeight,widthAndHeight)];
    bgView.backgroundColor = [SFIColors ruleGraycolor];
    bgView.userInteractionEnabled = NO;
    [self addSubview:bgView];
}


- (void)addImage:(UIImage *)iconImage y:(int)y widthAndHeight:(int)widthAndHeight {
    imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, widthAndHeight, widthAndHeight)];
    imgIcon.userInteractionEnabled = NO;
    
    
    //img adjustments
    float height = iconImage.size.height;
    float width = iconImage.size.width;
    float scale;
    int heightFactor = bgView.frame.size.height/imageHeightFactor;
    scale = height/heightFactor;
    height = heightFactor;
    width /= scale;
    //
    imgIcon.image = iconImage;
    CGRect frame = imgIcon.frame;
    frame.size.width = width;
    frame.size.height = height;
    imgIcon.frame = frame;
    imgIcon.center = bgView.center;
    [self addSubview:imgIcon];
}

- (void)addBottomText:(NSString *)bottomText x:(int)x y:(int)y width:(int)width height:(int)height{
    //label
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y,width,height)];
    lblTitle.text = bottomText;
    [lblTitle setFont: [lblTitle.font fontWithSize: fontSize]];
    lblTitle.numberOfLines=0;
    lblTitle.textColor = self.currentTitleColor;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor blackColor];
    [self addSubview:lblTitle];
}

- (void)setupValues:(UIImage*)iconImage topText:(NSString*)topText bottomText:(NSString *)bottomText{//upperScroll
    
    
    if(topText != nil){
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, triggerActionBtnWidth, triggerActionBtnHeight);
        [self adDeviceName:topText];
        [self addBgView:lblDeviceName.frame.size.height widthAndHeight:triggerActionBtnWidth];
        [self addImage:iconImage y:bgView.frame.origin.y widthAndHeight:bgView.frame.size.width];
        [self addBottomText:bottomText x:0 y:bgView.frame.origin.y + bgView.frame.size.height + textPadding width:self.frame.size.width height:textHeight];
        
            
    }
    else{
       [self addBgView:0 widthAndHeight:self.frame.size.width-textHeight -10];
        [self addImage:iconImage y:bgView.frame.origin.y - 10 widthAndHeight:self.frame.size.width-textHeight - 10];
        [self addBottomText:bottomText x:-5 y:bgView.frame.size.height+textPadding width:self.frame.size.width-textHeight height:textHeight];
    }
    isTrigger?[self changeBGColor:[SFIColors ruleBlueColor]]:[self changeBGColor:[SFIColors ruleBlueColor]];
    
}
- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden{
    
    if(countLable.text != nil){
        NSLog(@"countlabel is nil");
        countLable.text =nil;
    }
    countLable = [[UILabel alloc]initWithFrame:CGRectMake(bgView.frame.origin.x + bgView.frame.size.width -9, -3, 16, 16)];
    CALayer * l1 = [countLable layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:8];
    [l1 setBorderColor:[[UIColor whiteColor] CGColor]];
    [l1 setBorderWidth: 1.5];
    
    countLable.backgroundColor = [SFIColors ruleOrangeColor];//FF9500
    countLable.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:3];
    countLable.font = [UIFont systemFontOfSize:9];
    countLable.textColor = [UIColor whiteColor];
    //[countLable setFont:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:4]];
    countLable.text = [NSString stringWithFormat:@"%d",btnCount];
    countLable.textAlignment = NSTextAlignmentCenter;
    countLable.hidden = ishidden;
    [self addSubview:countLable];
    
    
    
}
- (void)changeBGColor:(UIColor*)color{
    bgView.backgroundColor = color;
    lblTitle.textColor = color;
}

- (void)changeImageColor:(UIColor*)color{
    imgIcon.image = [imgIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imgIcon setTintColor:color];
}
- (void)setButtonCross:(BOOL)isHidden{
    if(self.crossButton.text != nil){
        self.crossButton.text =nil;
    }
    self.crossButton = [[UILabel alloc]initWithFrame:CGRectMake(bgView.frame.origin.x  + bgView.frame.size.width - 12, 16, 16, 16)];
    CALayer * l1 = [self.crossButton layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:8];
    
    // You can even add a border
    
    [l1 setBorderColor:[[SFIColors ruleLightGrayColor] CGColor]];//FF3B30
    
    [l1 setBorderWidth: 1.5];
    
    self.crossButton.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:10];
    self.crossButton.textColor = [UIColor whiteColor];
    self.crossButton.text = @"X";
    self.crossButton.shadowColor = [SFIColors ruleLightGrayColor];

    self.crossButton.textAlignment = NSTextAlignmentCenter;
    self.crossButton.hidden = isHidden;
    [self.crossButton setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:self.crossButton];
}


@end

