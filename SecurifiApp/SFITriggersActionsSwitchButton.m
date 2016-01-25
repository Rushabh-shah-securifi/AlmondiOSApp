//
//  SFITriggersActionsSwitchButton.m
//  Tableviewcellpratic
//
//  Created by Masood on 27/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.FF9500
//

#import "SFITriggersActionsSwitchButton.h"
#import "SFIRulesSwitchButton.h"
#import "Colours.h"
#import "RulesConstants.h"

@implementation SFITriggersActionsSwitchButton{
    UIView * bgView;
    UIImageView * imgIcon;
    UILabel *lblTitle;
    UILabel *lblDeviceName;
}


-(id) initWithFrame: (CGRect) frame
{
    frame.size.width = triggerActionBtnWidth;
    frame.size.height = triggerActionBtnHeight;
    return [super initWithFrame:frame];
    //    return self;
}

- (void)changeBGColor:(BOOL)isTrigger clearColor:(BOOL)clearColor{
    UIColor *color= isTrigger?[UIColor colorFromHexString:@"02a8f3"]:[UIColor colorFromHexString:@"FF9500"];
    color=clearColor?[UIColor clearColor]:color;
    bgView.backgroundColor = color;
    lblTitle.textColor = color;
    lblDeviceName.textColor = color;
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
        lblDeviceName.textColor = [UIColor colorFromHexString:@"02a8f3"];
        lblTitle.textColor = [UIColor colorFromHexString:@"02a8f3"];
        bgView.backgroundColor = [UIColor colorFromHexString:@"02a8f3"];
    }else{
        lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
        bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    }
}

- (void)setupValues:(UIImage*)iconImage Title:(NSString*)title displayText:(NSString *)displayText{
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
    
    //bgview
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, lblDeviceName.frame.size.height , triggerActionBtnWidth,triggerActionBtnWidth )];
    bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    bgView.userInteractionEnabled = NO;
    [self addSubview:bgView];
    
    //img
    imgIcon = [[UIImageView alloc] initWithFrame:bgView.frame];
    imgIcon.userInteractionEnabled = NO;
    [self addSubview:imgIcon];
    
    //label
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.origin.y + bgView.frame.size.height + textPadding , self.frame.size.width,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
    lblTitle.text = displayText;
    [lblTitle setFont: [lblTitle.font fontWithSize: fontSize]];
    lblTitle.numberOfLines=0;
    lblTitle.textColor = self.currentTitleColor;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor blackColor];
    [self addSubview:lblTitle];
    
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
    
}

- (void)setButtonCross:(BOOL)isHidden{
    if(self.crossButton.titleLabel.text != nil){
        self.crossButton.titleLabel.text =nil;
    }
    self.crossButton = [[CrossButton alloc]initWithFrame:CGRectMake(bgView.frame.origin.x  + bgView.frame.size.width - 12, 16, 16, 16)];
    CALayer * l1 = [self.crossButton layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:8];
    
    // You can even add a border
    
    [l1 setBorderColor:[[UIColor colorFromHexString:@"F7F7F7"] CGColor]];//FF3B30
    
    [l1 setBorderWidth: 1.5];
    
    self.crossButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:3];
    self.crossButton.titleLabel.textColor = [UIColor blackColor];
    self.crossButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
   
    [self.crossButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.crossButton setTitle:@"X" forState:UIControlStateNormal];
    [self.crossButton setTitleShadowColor:[UIColor redColor] forState:UIControlStateNormal];
    self.crossButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.crossButton.hidden = isHidden;
    [self.crossButton setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:self.crossButton];
}
@end
