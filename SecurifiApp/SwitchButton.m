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
        UIImageView * imgIcon;
  
    UILabel *countLable;
    
}

-(id) initWithFrame:(CGRect)frame
{
    frame.size.height = 80;
    frame.size.width = 80;
    return [super initWithFrame:frame];
    //    return self;
}

- (void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    [super changeBGColor:self.isTrigger clearColor:selected showTitle:self.showTitle];
   
}

- (void)adDeviceName:(NSString *)title
{
    //device name title
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,textHeight)];
    //    self.bottomLabel.font = self.titleLabel.font;
    self.topLabel.text = title;
    [self.topLabel setFont: [self.topLabel.font fontWithSize: fontSize]];
    self.topLabel.numberOfLines=0;
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    self.topLabel.textColor = [SFIColors darkGrayColor];
    [self addSubview:self.topLabel];
}

- (void)addBgView:(int)y widthAndHeight:(int)widthAndHeight
{
    //bgview
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, y , widthAndHeight,widthAndHeight)];
    self.bgView.userInteractionEnabled = NO;
    [self addSubview:self.bgView];
}


- (void)addImage:(UIImage *)iconImage y:(int)y widthAndHeight:(int)widthAndHeight {
    imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, widthAndHeight, widthAndHeight)];
    imgIcon.userInteractionEnabled = NO;
    
    
    //img adjustments
    float height = iconImage.size.height;
    float width = iconImage.size.width;
    float scale;
    int heightFactor = self.bgView.frame.size.height/imageHeightFactor;
    scale = height/heightFactor;
    height = heightFactor;
    width /= scale;
    //
    imgIcon.image = iconImage;
    CGRect frame = imgIcon.frame;
    frame.size.width = width;
    frame.size.height = height;
    imgIcon.frame = frame;
    imgIcon.center = self.bgView.center;
    [self addSubview:imgIcon];
}

- (void)addBottomText:(NSString *)bottomText x:(int)x y:(int)y width:(int)width height:(int)height{
    //label
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,width,height)];
    self.bottomLabel.text = bottomText;
    [self.bottomLabel setFont: [self.bottomLabel.font fontWithSize: fontSize]];
    self.bottomLabel.numberOfLines=0;
    self.bottomLabel.textColor = self.currentTitleColor;
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.textColor = [SFIColors ruleGraycolor];
    [self addSubview:self.bottomLabel];
}

- (void)setupValues:(UIImage*)iconImage topText:(NSString*)topText bottomText:(NSString *)bottomText isTrigger:(BOOL)isTrigger{//upperScroll
    self.isTrigger = isTrigger;
    if(topText != nil){
        self.showTitle = YES;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, triggerActionBtnWidth, triggerActionBtnHeight);
        [self adDeviceName:topText];
        [self addBgView:self.topLabel.frame.size.height widthAndHeight:triggerActionBtnWidth];
        [self addImage:iconImage y:self.bgView.frame.origin.y widthAndHeight:self.bgView.frame.size.width];
        [self addBottomText:bottomText x:0 y:self.bgView.frame.origin.y + self.bgView.frame.size.height + textPadding width:self.frame.size.width height:textHeight];
        if(topText.length >0 || !isTrigger)
            self.bgView.backgroundColor = self.isTrigger?[SFIColors ruleBlueColor]:[SFIColors ruleOrangeColor];
         
    }
    else{
       [self addBgView:0 widthAndHeight:self.frame.size.width-textHeight -10];
        [self addImage:iconImage y:self.bgView.frame.origin.y - 10 widthAndHeight:self.frame.size.width-textHeight - 10];
        [self addBottomText:bottomText x:-5 y:self.bgView.frame.size.height+textPadding width:self.frame.size.width-textHeight height:textHeight];
        self.bgView.backgroundColor = [SFIColors ruleGraycolor];
    }
}
- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden{
    
    if(countLable.text != nil){
        NSLog(@"countlabel is nil");
        countLable.text =nil;
    }
    countLable = [[UILabel alloc]initWithFrame:CGRectMake(self.bgView.frame.origin.x + self.bgView.frame.size.width -9, -3, 16, 16)];
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
    self.bgView.backgroundColor = color;
//    self.bottomLabel.textColor = color;
}

- (void)changeImageColor:(UIColor*)color{
    imgIcon.image = [imgIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imgIcon setTintColor:color];
}
- (void)setButtonCross:(BOOL)isHidden{
    if(self.crossButton.text != nil){
        self.crossButton.text =nil;
    }
    self.crossButton = [[UILabel alloc]initWithFrame:CGRectMake(self.bgView.frame.origin.x  + self.bgView.frame.size.width - 12, 16, 16, 16)];
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

