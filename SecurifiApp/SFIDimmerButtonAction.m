//
//  DimmerButtonActiopn.m
//  Tableviewcellpratic
//
//  Created by Securifi-Mac2 on 27/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import "SFIDimmerButtonAction.h"
#import "Colours.h"
#import "RulesConstants.h"


@implementation SFIDimmerButtonAction{
    UIView *bgView;
    UILabel *lblMain;
    UILabel *lblTitle;
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
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height-17)];
    lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
    bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    [self addSubview:bgView];
    
    lblMain = [[UILabel alloc] initWithFrame:bgView.frame];
    lblMain.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:lblMain];
    
    
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height, self.frame.size.width,self.frame.size.height-bgView.frame.size.height)];
    lblTitle.font = self.titleLabel.font;
    lblTitle.textColor = self.currentTitleColor;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblTitle];
    bgView.userInteractionEnabled = NO;
    lblMain.userInteractionEnabled = NO;
}

-(id) initWithFrame: (CGRect) frame
{
    //    frame.size.height = 100;
    //    frame.size.width = 100;
    return [super initWithFrame:frame];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    //[self changeStyle];
}

- (void)changeStylewithColor:(UIColor*)color{
    if (self.selected) {
        lblTitle.textColor = color;
        bgView.backgroundColor = color;
    }else{
        lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
        bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    }
}

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)suffix{
    //awakefromnib
    self.dimValue = text;
    self.backgroundColor = [UIColor clearColor];
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -5, self.frame.size.width-textHeight,self.frame.size.height-textHeight)];
    lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
    bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    [self addSubview:bgView];
    
    lblMain = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width-textHeight,self.frame.size.height-textHeight)];
    lblMain.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:lblMain];
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height+textPadding -5, self.frame.size.width-textHeight,textHeight)];
    [lblTitle setFont: [lblTitle.font fontWithSize: fontSize]];
    lblTitle.textColor = self.currentTitleColor;
    lblTitle.numberOfLines=0;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lblTitle];
    
    bgView.userInteractionEnabled = NO;
    lblMain.userInteractionEnabled = NO;
    //awakefromnib
    
    self.prefix = suffix;
    NSString *strTopTitleLabelText = [text stringByAppendingString:suffix];
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:40.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:24.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(text.length,suffix.length)];
    [lblMain setAttributedText:strTemp];
    lblTitle.text = title;
}


- (void)setNewValue:(NSString*)text{
    self.dimValue = text;
    NSString *strTopTitleLabelText = [text stringByAppendingString:self.prefix];
    
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:40.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:24.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(text.length,self.prefix.length)];
    
    [lblMain setAttributedText:strTemp];
}
- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden{
    
    countLable = [[UILabel alloc]initWithFrame:CGRectMake(bgView.frame.origin.x + bgView.frame.size.width -10, -10, 16, 16)];
    
    CALayer * l1 = [countLable layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:8];
    
    [l1 setBorderColor:[[UIColor whiteColor] CGColor]];
    [l1 setBorderWidth: 1];
    
    countLable.backgroundColor = [UIColor colorFromHexString:@"FF9500"];;//FF9500
    
    countLable.backgroundColor = [UIColor colorFromHexString:@"FF9500"];;//FF9500
    countLable.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:3];
    countLable.font = [UIFont systemFontOfSize:9];
    countLable.textColor =[UIColor wheatColor];
    //[countLable setFont:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:4]];
    countLable.text = [NSString stringWithFormat:@"%d",btnCount];
    countLable.textAlignment = NSTextAlignmentCenter;
    countLable.hidden = ishidden;
    [UIView transitionWithView:countLable duration:1
                       options:UIViewAnimationOptionTransitionCurlUp //change to whatever animation you like
                    animations:^ { [self addSubview:countLable]; }
                    completion:nil];
    
    [self addSubview:countLable];
    
    
    
}

@end
