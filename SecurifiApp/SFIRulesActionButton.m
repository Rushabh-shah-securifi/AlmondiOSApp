//
//  SFIRulesActionButton.m
//  Tableviewcellpratic
//
//  Created by Securifi-Mac2 on 24/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//


#import "SFIRulesSwitchButton.h"
#import "SFIRulesActionButton.h"
#import "Colours.h"
#import "RulesConstants.h"
#import <QuartzCore/QuartzCore.h>

@implementation SFIRulesActionButton{
    UIView * bgView;
    UIImageView * imgIcon;
    UILabel *lblTitle;
    UILabel *lblMain;
    UILabel *countLable;
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)awakeFromNib {
    NSLog(@"awake from nib");
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height-17)];
    lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
    bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    [self addSubview:bgView];
    
    imgIcon = [[UIImageView alloc] initWithFrame:bgView.frame];
    [bgView addSubview:imgIcon];
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height, self.frame.size.width,self.frame.size.height-self.frame.size.width)];
    lblTitle.font = self.titleLabel.font;
    lblTitle.textColor = self.currentTitleColor;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblTitle];
    bgView.userInteractionEnabled = NO;
    imgIcon.userInteractionEnabled = NO;
}





-(id) initWithFrame: (CGRect) frame
{
    frame.size.height = 80;
    frame.size.width = 80;
    return [super initWithFrame:frame];
    //    return self;
}


- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self changeStyle];
}

- (void)changeStyle{
    if (self.selected) {
        lblTitle.textColor = [UIColor colorFromHexString:@"FF9500"];//FF9500
        bgView.backgroundColor = [UIColor colorFromHexString:@"FF9500"];
    }else{
        lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
        bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    }
}

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title{
    NSLog(@"");
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-textHeight -10 ,self.frame.size.height-textHeight - 10)];
    
    bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    [self addSubview:bgView];
    
    imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, bgView.frame.origin.y - 10, self.frame.size.width-textHeight - 10,self.frame.size.height-textHeight - 10)];
    NSLog(@"image frame :%f",imgIcon.frame.origin.y);
    [bgView addSubview:imgIcon];
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(-5 , bgView.frame.size.height+textPadding , self.frame.size.width-textHeight,textHeight)];
    [lblTitle setFont: [lblTitle.font fontWithSize: fontSize]];
    lblTitle.numberOfLines=0;
    lblTitle.textColor = self.currentTitleColor;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
    [self addSubview:lblTitle];
    bgView.userInteractionEnabled = NO;
    imgIcon.userInteractionEnabled = NO;
    
    float height = iconImage.size.height;
    float width = iconImage.size.width;
    float scale;
    //   NSLog(@"height width %f %f",height,width);
    
    //    if (height>bgView.frame.size.height) {
    int heightFactor = bgView.frame.size.height/imageHeightFactor;
    scale = height/heightFactor;
    height = heightFactor;
    width /= scale;
    //    }
    //    NSLog(@"height width %f %f",height,width);
    
    //    if (width>bgView.frame.size.height) {
    //                NSLog(@"width>bgView.frame.size.height");
    //        scale = width/bgView.frame.size.width;
    //        width = bgView.frame.size.width;
    //        height /= scale;
    //    }
    
    imgIcon.image = iconImage;
    CGRect frame = imgIcon.frame;
    frame.size.width = width;
    frame.size.height = height;
    imgIcon.frame = frame;
    imgIcon.center = bgView.center;
    lblTitle.text = title;
    
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
    
    countLable.backgroundColor = [UIColor colorFromHexString:@"FF9500"];//FF9500
    countLable.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:3];
    countLable.font = [UIFont systemFontOfSize:9];
    countLable.textColor = [UIColor whiteColor];
    //[countLable setFont:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:4]];
    countLable.text = [NSString stringWithFormat:@"%d",btnCount];
    countLable.textAlignment = NSTextAlignmentCenter;
    countLable.hidden = ishidden;
    [self addSubview:countLable];
    
    
    
}


@end

