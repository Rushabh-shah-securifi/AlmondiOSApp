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
    UILabel *lblTitle;
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
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,self.frame.size.height-17)];
    lblTitle.textColor = [SFIColors ruleGraycolor];
    bgView.backgroundColor = [SFIColors ruleGraycolor];
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


- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)suffix{
    //awakefromnib
    self.dimValue = text;
    self.backgroundColor = [UIColor clearColor];
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, -5, self.frame.size.width-textHeight,self.frame.size.height-textHeight)];
    lblTitle.textColor = [SFIColors ruleGraycolor];
    bgView.backgroundColor = [SFIColors ruleGraycolor];
    [self addSubview:bgView];
    
    lblMain = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width-textHeight,self.frame.size.height-textHeight)];
    lblMain.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:lblMain];
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height+textPadding -5, self.frame.size.width-textHeight,textHeight)];
    [lblTitle setFont: [lblTitle.font fontWithSize: fontSize]];
    lblTitle.textColor = self.currentTitleColor;
    lblTitle.numberOfLines=0;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [SFIColors ruleGraycolor];
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


- (void)setupValues:(NSString*)text  Title:(NSString*)title displayText:(NSString*)displayText suffix:(NSString*)suffix{
    //device name title
    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,textHeight)];
    //    lblTitle.font = self.titleLabel.font;
    lblDeviceName.text = title;
    [lblDeviceName setFont: [lblDeviceName.font fontWithSize: fontSize]];
    lblDeviceName.numberOfLines=0;
    lblDeviceName.textColor = self.currentTitleColor;
    lblDeviceName.textAlignment = NSTextAlignmentCenter;
    NSLog(@" devicename %@",lblDeviceName.text);
    lblDeviceName.textColor = [SFIColors ruleGraycolor];
    [self addSubview:lblDeviceName];
    NSLog(@" lbldevicename %@",title);
    
    //set value
    self.dimValue = text;
    self.backgroundColor = [UIColor clearColor];
    
    //bgview
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, lblDeviceName.frame.size.height, triggerActionDimWidth,triggerActionBtnWidth -5)];
    bgView.backgroundColor = [SFIColors ruleGraycolor];
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
    lblTitle.textColor = [SFIColors ruleGraycolor];
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
- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden{
    
    countLable = [[UILabel alloc]initWithFrame:CGRectMake(bgView.frame.origin.x + bgView.frame.size.width -10, -10, 16, 16)];
    
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
    [self.crossButton setBackgroundColor:[SFIColors ruleLightGrayColor]];
    [self addSubview:self.crossButton];
}

@end
