//
//  DimmerButtonActiopn.m
//  Tableviewcellpratic
//
//  Created by Securifi-Mac2 on 27/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import "DimmerButton.h"
#import "SFIColors.h"
#import "RulesConstants.h"


@implementation DimmerButton{
    UIView *bgView;
    UILabel *lblMain;
    UILabel *countLable;
    UILabel *lblDeviceName;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(id) initWithFrame: (CGRect) frame
{
    return [super initWithFrame:frame];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [super changeBGColor:self.isTrigger clearColor:selected showTitle:NO];
    //[self changeStyle];
}

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)suffix isTrigger:(BOOL)isTrigger{
    //awakefromnib
    self.isTrigger = isTrigger;
    self.dimValue = text;
    self.backgroundColor = [UIColor clearColor];
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -5, self.frame.size.width-textHeight,self.frame.size.height-textHeight)];
    self.bgView.backgroundColor = [SFIColors ruleGraycolor];
    [self addSubview:self.bgView];
    
    lblMain = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width-textHeight,self.frame.size.height-textHeight)];
    lblMain.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:lblMain];
    
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bgView.frame.size.height+textPadding -5, self.frame.size.width-textHeight,textHeight)];
    [self.bottomLabel setFont: [self.bottomLabel.font fontWithSize: fontSize]];
    self.bottomLabel.numberOfLines=0;
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.textColor = [SFIColors ruleGraycolor];
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.bottomLabel];
    
    self.bgView.userInteractionEnabled = NO;
    lblMain.userInteractionEnabled = NO;
    //awakefromnib
    
    self.prefix = suffix;
    NSString *strTopTitleLabelText = [text stringByAppendingString:suffix];
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:40.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:24.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(text.length,suffix.length)];
    [lblMain setAttributedText:strTemp];
    self.bottomLabel.text = title;
}


- (void)setupValues:(NSString*)text  Title:(NSString*)title displayText:(NSString*)displayText suffix:(NSString*)suffix{
    //device name title
    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,textHeight)];
    //    self.bottomLabel.font = self.titleLabel.font;
    lblDeviceName.text = title;
    [lblDeviceName setFont: [lblDeviceName.font fontWithSize: fontSize]];
    lblDeviceName.numberOfLines=0;
    lblDeviceName.textAlignment = NSTextAlignmentCenter;
    lblDeviceName.textColor = [SFIColors darkGrayColor];
    [self addSubview:lblDeviceName];
    
    //set value
    self.dimValue = text;
    self.backgroundColor = [UIColor clearColor];
    
    //self.bgView
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, lblDeviceName.frame.size.height, triggerActionDimWidth,triggerActionBtnWidth -5)];
    self.bgView.backgroundColor = [SFIColors ruleGraycolor];
    self.bgView.userInteractionEnabled = NO;
    [self addSubview:self.bgView];
    
    //lblmain
    lblMain = [[UILabel alloc] initWithFrame:self.bgView.frame];
    lblMain.textAlignment = NSTextAlignmentCenter;
    lblMain.userInteractionEnabled = NO;
    [self addSubview:lblMain];
    
    //self.bottomLabel
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bgView.frame.origin.y + self.bgView.frame.size.height + textPadding, self.frame.size.width,textHeight)];
    self.bottomLabel.text = displayText;
    [self.bottomLabel setFont: [self.bottomLabel.font fontWithSize: fontSize]];
    self.bottomLabel.numberOfLines=0;
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.textColor = [SFIColors ruleGraycolor];
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.bottomLabel];
    
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
- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden{
    
    countLable = [[UILabel alloc]initWithFrame:CGRectMake(self.bgView.frame.origin.x + self.bgView.frame.size.width -10, -10, 16, 16)];
    
    CALayer * l1 = [countLable layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:8];
    
    [l1 setBorderColor:[[UIColor whiteColor] CGColor]];
    [l1 setBorderWidth: 1];
    
    countLable.backgroundColor = [SFIColors ruleOrangeColor];//FF9500
    
    countLable.backgroundColor = [SFIColors ruleOrangeColor];//FF9500
    countLable.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:3];
    countLable.font = [UIFont systemFontOfSize:9];
    countLable.textColor =[SFIColors ruleOrangeColor];
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
    [self.crossButton setBackgroundColor:[SFIColors ruleLightGrayColor]];
    [self addSubview:self.crossButton];
}

@end
