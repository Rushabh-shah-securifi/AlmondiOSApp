//
//  SFITriggersActionsDimmerButton.m
//  Tableviewcellpratic
//
//  Created by Masood on 27/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import "SFITriggersActionsDimmerButton.h"
#import "Colours.h"
#import "RulesConstants.h"

@implementation SFITriggersActionsDimmerButton{
    UIView *bgView;
    UILabel *lblMain;
    UILabel *lblTitle;
    UILabel *lblDeviceName;
}


-(id) initWithFrame: (CGRect) frame
{
    return [super initWithFrame:frame];
}

- (void)changeBGColor:(UIColor*)color{
    bgView.backgroundColor = color;
    lblTitle.textColor = color;
    lblDeviceName.textColor = color;
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

- (void)setupValues:(NSString*)text  Title:(NSString*)title displayText:(NSString*)displayText suffix:(NSString*)suffix{
    //device name title
    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
    lblDeviceName.text = title;
    [lblDeviceName setFont: [lblDeviceName.font fontWithSize: fontSize]];
    lblDeviceName.numberOfLines=0;
    lblDeviceName.textColor = self.currentTitleColor;
    lblDeviceName.textAlignment = NSTextAlignmentCenter;
    lblDeviceName.textColor = [UIColor colorFromHexString:@"757575"];
    [self addSubview:lblDeviceName];
    NSLog(@" lbldevicename %@",title);
    
    //set value
    self.dimValue = text;
    self.backgroundColor = [UIColor clearColor];
    
    //bgview
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, lblDeviceName.frame.size.height, triggerActionDimWidth,triggerActionBtnWidth -5)];
    bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    bgView.userInteractionEnabled = NO;
    [self addSubview:bgView];
    
    //lblmain
    lblMain = [[UILabel alloc] initWithFrame:bgView.frame];
    lblMain.textAlignment = NSTextAlignmentCenter;
    lblMain.userInteractionEnabled = NO;
    [self addSubview:lblMain];
    
    //lbltitle
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.origin.y + bgView.frame.size.height + textPadding, self.frame.size.width,textHeight)];
    lblTitle.text = displayText;
    [lblTitle setFont: [lblTitle.font fontWithSize: fontSize]];
    lblTitle.textColor = self.currentTitleColor;
    lblTitle.numberOfLines=0;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblTitle];
    
    //lblmain adjutments
    self.prefix = suffix;
    NSLog(@"text: %@, suffix: %@", text, suffix);
    NSString *strTopTitleLabelText = [text stringByAppendingString:suffix];
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:20.0f]} range:NSMakeRange(0,text.length)]; //40
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:14.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(text.length,suffix.length)];
    [lblMain setAttributedText:strTemp];//24
    lblMain.lineBreakMode = NSLineBreakByWordWrapping;
    lblMain.numberOfLines = 0;
    
}




- (void)setNewValue:(NSString*)text{
    self.dimValue = text;
    NSString *strTopTitleLabelText = [text stringByAppendingString:self.prefix];
    
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:40.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:24.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(text.length,self.prefix.length)];
    
    [lblMain setAttributedText:strTemp];
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
    //[l1 setBackgroundColor:(__bridge CGColorRef _Nullable)([UIColor redColor])];
    [l1 setBorderWidth: 1.5];
    
    self.crossButton.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:3];
    self.crossButton.titleLabel.textColor = [UIColor whiteColor];
    self.crossButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    //self.crossButton.titleLabel.font = [UIFont systemFontOfSize:8];
    //[countLable setFont:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:4]];
    [self.crossButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.crossButton setTitle:@"X" forState:UIControlStateNormal];
    [self.crossButton setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.crossButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.crossButton.hidden = isHidden;
    [self.crossButton setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:self.crossButton];
}


@end
