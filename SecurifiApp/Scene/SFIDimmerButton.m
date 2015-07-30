//
//  SFIDimmerButton.m
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 09.06.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIDimmerButton.h"
#import "Colours.h"

@implementation SFIDimmerButton{
    UIView *    bgView;
    UILabel *lblMain;
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

- (void)setupValues:(NSString*)text  Title:(NSString*)title Prefix:(NSString*)prefix{
    self.prefix = prefix;
    NSString *strTopTitleLabelText = [text stringByAppendingString:prefix];
    
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:46.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:27.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(text.length,prefix.length)];
    
    [lblMain setAttributedText:strTemp];
    
    lblTitle.text = title;
}


- (void)setNewValue:(NSString*)text{
    NSString *strTopTitleLabelText = [text stringByAppendingString:self.prefix];
    
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:46.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:27.0f],NSBaselineOffsetAttributeName:@(12)} range:NSMakeRange(text.length,self.prefix.length)];
    
    [lblMain setAttributedText:strTemp];
}
@end
