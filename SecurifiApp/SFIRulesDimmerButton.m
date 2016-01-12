//
//  SFIRulesDimmerButton.m
//  SecurifiApp
//
//  Created by Masood on 12/01/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFIRulesDimmerButton.h"
#import "Colours.h"
#import "RulesConstants.h"

@implementation SFIRulesDimmerButton{
    UIView *bgView;
    UILabel *lblMain;
    UILabel *lblTitle;
}

-(id) initWithFrame: (CGRect) frame
{
    //    frame.size.height = 100;
    //    frame.size.width = 100;
    return [super initWithFrame:frame];
}

- (void)changeBGColor:(UIColor*)color{
    bgView.backgroundColor = color;
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

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)suffix{
    //awakefromnib
    self.dimValue = text;
    self.backgroundColor = [UIColor clearColor];
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-textHeight,self.frame.size.height-textHeight)];
    lblTitle.textColor = [UIColor colorFromHexString:@"757575"];
    bgView.backgroundColor = [UIColor colorFromHexString:@"757575"];
    [self addSubview:bgView];
    
    lblMain = [[UILabel alloc] initWithFrame:bgView.frame];
    lblMain.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:lblMain];
    
    lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, bgView.frame.size.height+textPadding , self.frame.size.width-textHeight,textHeight)];
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
@end
