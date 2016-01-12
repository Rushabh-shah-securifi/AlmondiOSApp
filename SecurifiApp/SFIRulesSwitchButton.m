//
//  SFISwitchButton.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 09.06.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

//checkpoint buttonframe
//checkpoint buttonframe updated

#import "SFIRulesSwitchButton.h"
#import "Colours.h"
#import "RulesConstants.h"

@implementation SFIRulesSwitchButton{
    UIView * bgView;
    UIImageView * imgIcon;
    UILabel *lblTitle;
    UILabel *lblMain;
    
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
    frame.size.height = frameSize;
    frame.size.width = frameSize;
    return [super initWithFrame:frame];
    //    return self;
}

- (void)changeBGColor:(UIColor*)color{
    bgView.backgroundColor = color;
    lblTitle.textColor = color;
}

- (void)changeImageColor:(UIColor*)color{
    imgIcon.image = [imgIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [imgIcon setTintColor:color];
}

- (void)setSelected:(BOOL)selected{
    NSLog(@"setSelected: %d", selected);
    [super setSelected:selected];
    [self changeStyle];
}

- (void)changeStyle{
    if (self.selected) {
        lblTitle.textColor = [UIColor colorFromHexString:@"02a8f3"];
        bgView.backgroundColor = [UIColor colorFromHexString:@"02a8f3"];
    }else{
        lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
        bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    }
}

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title{
    NSLog(@"");
//    self.backgroundColor = [UIColor blackColor];
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-textHeight,self.frame.size.height-textHeight)];
    bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    [self addSubview:bgView];
    
    imgIcon = [[UIImageView alloc] initWithFrame:bgView.frame];
    [bgView addSubview:imgIcon];
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height+textPadding , self.frame.size.width-textHeight,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
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


@end
