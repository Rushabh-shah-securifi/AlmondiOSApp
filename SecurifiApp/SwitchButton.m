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
    UILabel *lblMain;
        UIView *crossButtonBGView;
  
    UILabel *countLable;
}

-(id) initWithFrame:(CGRect)frame
{
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
    self.topLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:topFontSize];
    self.topLabel.numberOfLines=0;
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    self.topLabel.textColor = [UIColor blackColor];
    [self addSubview:self.topLabel];
}

- (void)addBgView:(int)y widthAndHeight:(int)widthAndHeight
{
    //bgview
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, y , widthAndHeight,widthAndHeight)];
    self.bgView.userInteractionEnabled = NO;
    [self addSubview:self.bgView];
}


- (void)addImage:(UIImage *)iconImage y:(int)y widthAndHeight:(int)widthAndHeight imageHeight:(int)imageHeight{
    imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, widthAndHeight, widthAndHeight)];
    imgIcon.userInteractionEnabled = NO;
    //img adjustments
    float height = iconImage.size.height;
    float width = iconImage.size.width;
    float scale;
    int heightFactor = imageHeight/imageHeightFactor;
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
    self.bottomLabel.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:fontSize];
    self.bottomLabel.numberOfLines=0;
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.textColor = [SFIColors ruleGraycolor];
    [self addSubview:self.bottomLabel];
}

- (void)setupValues:(UIImage*)iconImage topText:(NSString*)topText bottomText:(NSString *)bottomText isTrigger:(BOOL)isTrigger isDimButton:(BOOL)isDimButton insideText:(NSString *)insideText{//upperScroll
    self.isTrigger = isTrigger;
    if(topText != nil){
        self.showTitle = YES;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, entryBtnWidth, entryBtnHeight);
        [self adDeviceName:topText];
        [self addBgView:self.topLabel.frame.size.height widthAndHeight:entryBtnWidth];
        if(isDimButton)
            [self mainLabel:@"" text:insideText];
        else
            [self addImage:iconImage y:self.bgView.frame.origin.y widthAndHeight:self.bgView.frame.size.width imageHeight:self.bgView.frame.size.height];
        if(isTrigger)
            [self addBottomText:bottomText x:0 y:self.bgView.frame.origin.y + self.bgView.frame.size.height + textPadding width:self.frame.size.width height:textHeight];
        
        if(topText.length >0 || !isTrigger)
            self.bgView.backgroundColor = self.isTrigger?[SFIColors ruleBlueColor]:[SFIColors ruleOrangeColor];
         
    }
    else{
       [self addBgView:0 widthAndHeight:self.frame.size.width-textHeight -10];
        [self addImage:iconImage y:self.bgView.frame.origin.y - 10 widthAndHeight:self.frame.size.width-textHeight - 10 imageHeight:self.bgView.frame.size.height];
        [self addBottomText:bottomText x:-5 y:self.bgView.frame.size.height+textPadding width:self.frame.size.width-textHeight height:textHeight];
        self.bgView.backgroundColor = [SFIColors ruleGraycolor];
    }
}

- (void)setImage:(UIImage*)iconImage{
    
    self.showTitle = YES;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, separatorWidth, entryBtnHeight);
    [self adDeviceName:@""];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0,self.topLabel.frame.size.height , separatorWidth,entryBtnWidth)];
    self.bgView.userInteractionEnabled = NO;
    [self addSubview:self.bgView];
    
    [self addImage:iconImage y:self.bgView.frame.origin.y widthAndHeight:separatorWidth imageHeight:entryBtnWidth-10];
    [self addBottomText:@"" x:0 y:self.bgView.frame.origin.y + self.bgView.frame.size.height + textPadding width:self.frame.size.width height:textHeight];
    
}
- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden{
    
    if(countLable.text != nil){
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
    crossButtonBGView = [[UIView alloc]initWithFrame:CGRectMake(self.bgView.frame.origin.x  + self.bgView.frame.size.width - 10, 13, countDiameter, countDiameter)];
    crossButtonBGView.userInteractionEnabled = NO;
    [self setLayer];
    [self addImage1:[UIImage imageNamed:@"icon_cross_gray"] y:crossButtonBGView.frame.origin.y widthAndHeight:countDiameter];
    crossButtonBGView.hidden = isHidden;
    [crossButtonBGView setBackgroundColor:[SFIColors ruleLightGrayColor]];
//    crossButtonBGView.alpha = 0.85;
    [self addSubview:crossButtonBGView];
}

-(void)setLayer{
    CALayer * l1 = [crossButtonBGView layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:countDiameter/2];
    [l1 setBorderColor:[[UIColor whiteColor] CGColor]];//FF3B30
    [l1 setBorderWidth: 1.5];
}
- (void)setNewValue:(NSString*)text{
    
}
-(void)addImage1:(UIImage *)iconImage y:(int)y widthAndHeight:(int)widthAndHeight {
    self.crossButtonImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, widthAndHeight, widthAndHeight)];
    self.crossButtonImage.userInteractionEnabled = NO;
    //img adjustments
    float height = iconImage.size.height;
    float width = iconImage.size.width;
    float scale;
    int heightFactor = self.bgView.frame.size.height/crossButtonScale;
    scale = height/heightFactor;
    height = heightFactor;
    width /= scale;
//    self.crossButtonImage.alpha = 0.5;
    self.crossButtonImage.image = iconImage;
    CGRect frame = self.crossButtonImage.frame;
    frame.size.width = width;
    frame.size.height = height;
    self.crossButtonImage.frame = frame;
    self.crossButtonImage.center = CGPointMake(crossButtonBGView.bounds.size.width/2, crossButtonBGView.bounds.size.height/2);
    [crossButtonBGView addSubview:self.crossButtonImage];
}

- (void)mainLabel:(NSString *)suffix text:(NSString *)text {
    NSString *strTopTitleLabelText = [text stringByAppendingString:suffix];
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:17.0f]} range:NSMakeRange(0,text.length)]; //40
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:12.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(text.length,suffix.length)];
    //lblmain
    lblMain = [[UILabel alloc] initWithFrame:self.bgView.frame];
    lblMain.textAlignment = NSTextAlignmentCenter;
    lblMain.userInteractionEnabled = NO;
    [lblMain setAttributedText:strTemp];//24
    lblMain.lineBreakMode = NSLineBreakByWordWrapping;
    lblMain.numberOfLines = 0;
    [self addSubview:lblMain];
}

@end

