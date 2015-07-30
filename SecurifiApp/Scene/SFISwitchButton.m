//
//  SFISwitchButton.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 09.06.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFISwitchButton.h"
#import "Colours.h"

@implementation SFISwitchButton{
    UIView *    bgView;
    UIImageView * imgIcon;
    UILabel *lblTitle;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (void)awakeFromNib {
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
    //    float heigth = [self getHeightByWidth:self.titleLabel.text :self.titleLabel.font :self.frame.size.width];
    //    bottomTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-heigth, self.frame.size.width, heigth)];
    //    bottomTitleLabel.font = self.titleLabel.font;
    //    bottomTitleLabel.text = self.titleLabel.text;
    //    bottomTitleLabel.textColor = self.currentTitleColor;
    //    bottomTitleLabel.textAlignment = NSTextAlignmentCenter;
    //    [self setTitle:@"" forState:UIControlStateNormal];
    //    [self addSubview:bottomTitleLabel];
    //
    //    topTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 17)];
    //    topTitleLabel.backgroundColor = self.currentTitleColor;
    //    topTitleLabel.textAlignment = NSTextAlignmentCenter;
    //    imgButton = [[UIImageView alloc] initWithImage:self.imageView.image];
    //    [imgButton sizeToFit];
    //    [self setImage:nil forState:UIControlStateNormal];
    //    imgButton.center = CGPointMake(topTitleLabel.frame.size.width/2, topTitleLabel.frame.size.height/2);
    //
    //    [self addSubview:topTitleLabel];
    //    [self addSubview:imgButton];
}


- (void)setSelected:(BOOL)selected{
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
    float height = iconImage.size.height;
    float width = iconImage.size.width;
    float scale;
    if (height>bgView.frame.size.height) {
        scale = height/bgView.frame.size.height;
        height = bgView.frame.size.height;
        width /= scale;
    }
    
    if (width>bgView.frame.size.height) {
        scale = width/bgView.frame.size.width;
        width = bgView.frame.size.width;
        height /= scale;
    }
    
    imgIcon.image = iconImage;
    CGRect frame = imgIcon.frame;
    frame.size.width = width;
    frame.size.height = height;
    frame.origin.x = (bgView.frame.size.width-width)/2;
    frame.origin.y = (bgView.frame.size.height-height)/2;
    imgIcon.frame = frame;
    lblTitle.text = title;
}
@end
