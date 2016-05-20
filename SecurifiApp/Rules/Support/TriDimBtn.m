//
//  TriDimBtn.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 20/05/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "TriDimBtn.h"
#import "RulesConstants.h"
#import "SFIColors.h"

@implementation TriDimBtn
UIView *bgView;
UILabel *lblMain;
UILabel *countLable;
UILabel *lblDeviceName;
UIView *crossButtonBGView;



-(id) initWithFrame: (CGRect) frame
{
    return [super initWithFrame:frame];
}
- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [super changeBGColor:self.isTrigger clearColor:selected showTitle:NO isScene:self.isScene];
    //[self changeStyle];
}

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)suffix isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene{
    //awakefromnib
    self.isScene = isScene;
    self.isTrigger = isTrigger;
    self.dimValue = text;
    self.backgroundColor = [UIColor clearColor];
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-textHeight + 5,self.frame.size.height-textHeight +5)];
    self.bgView.backgroundColor = [SFIColors ruleGraycolor];
    [self addSubview:self.bgView];
    
    lblMain = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width-textHeight + 5,self.frame.size.height-textHeight)];
    lblMain.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:lblMain];
    
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bgView.frame.size.height+textPadding, self.frame.size.width-textHeight,textHeight)];
    self.bottomLabel.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:fontSize];
    self.bottomLabel.numberOfLines=0;
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.textColor = [SFIColors ruleGraycolor];
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.bottomLabel];
    
    self.bgView.userInteractionEnabled = NO;
    lblMain.userInteractionEnabled = NO;
    //awakefromnib
    NSString *suf = (suffix == nil || suffix.length == 0)?@"":suffix;
    self.prefix = suf;
    NSString *strTopTitleLabelText = [text = (text == nil)?@"":text  stringByAppendingString:suf];
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:40.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:24.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(text.length,suffix.length)];
    [lblMain setAttributedText:strTemp];
    
    self.bottomLabel.text = title;
}

@end