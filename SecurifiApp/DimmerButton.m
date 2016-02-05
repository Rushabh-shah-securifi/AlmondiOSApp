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
    UIView *crossButtonBGView;
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
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-textHeight,self.frame.size.height-textHeight)];
    self.bgView.backgroundColor = [SFIColors ruleGraycolor];
    [self addSubview:self.bgView];
    
    lblMain = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width-textHeight,self.frame.size.height-textHeight)];
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
    lblDeviceName.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:10];
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
    NSLog(@"btncount %d",btnCount);
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
    countLable.textColor =[UIColor whiteColor];
    //[countLable setFont:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:4]];
    countLable.text = [NSString stringWithFormat:@"%d",btnCount];
    NSLog(@" count.text %@",countLable.text);
    countLable.textAlignment = NSTextAlignmentCenter;
    countLable.hidden = ishidden;
    [UIView transitionWithView:countLable duration:1
                       options:UIViewAnimationOptionTransitionCurlUp //change to whatever animation you like
                    animations:^ { [self addSubview:countLable]; }
                    completion:nil];
    
    [self addSubview:countLable];
    
    
    
}

- (void)setButtonCross:(BOOL)isHidden{
//    if(self.crossButton.text != nil){
//        self.crossButton.text =nil;
//    }
    crossButtonBGView = [[UIView alloc]initWithFrame:CGRectMake(self.bgView.frame.origin.x  + self.bgView.frame.size.width - 8, 12, countDiameter, countDiameter)];
    [self setLayer];
    [self addImage:[UIImage imageNamed:@"icon_cross_gray"] y:crossButtonBGView.frame.origin.y widthAndHeight:countDiameter];
    [crossButtonBGView setBackgroundColor:[SFIColors ruleLightGrayColor]];
    crossButtonBGView.hidden = isHidden;
    [self addSubview:crossButtonBGView];
}

-(void)setLayer{
    CALayer * l1 = [crossButtonBGView layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:countDiameter/2];
    [l1 setBorderColor:[[SFIColors ruleLightGrayColor] CGColor]];//FF3B30
    [l1 setBorderWidth: 1.5];
}

- (void)addImage:(UIImage *)iconImage y:(int)y widthAndHeight:(int)widthAndHeight {
    self.crossButtonImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, widthAndHeight, widthAndHeight)];
    self.crossButtonImage.userInteractionEnabled = NO;
    //img adjustments
    float height = iconImage.size.height;
    float width = iconImage.size.width;
    float scale;
    int heightFactor = self.bgView.frame.size.height/crossButtonScale;
    scale = height/heightFactor;
    height = heightFactor;
    width /= scale;
    
    self.crossButtonImage.image = iconImage;
    CGRect frame = self.crossButtonImage.frame;
    frame.size.width = width;
    frame.size.height = height;
    self.crossButtonImage.frame = frame;
    self.crossButtonImage.center = CGPointMake(crossButtonBGView.bounds.size.width/2, crossButtonBGView.bounds.size.height/2);
    [crossButtonBGView addSubview:self.crossButtonImage];
}
-(void)setUpTextField:(NSString*)textFieldText displayText:(NSString*)displayText{
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-textHeight,self.frame.size.height -textHeight)];
    self.bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.bgView];
    self.textField = [[RuleTextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-60,textHeight)];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.textField.frame.size.height - 1, self.textField.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
    [self.textField.layer addSublayer:bottomBorder];
    
    self.textField.center = CGPointMake(self.bgView.bounds.size.width/2, self.bgView.bounds.size.height/2);
    self.textField.subProperties = self.subProperties;
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.textField.text = textFieldText;
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.textColor = [UIColor whiteColor];
    self.textField.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:15];
    self.textField.backgroundColor = [UIColor greenColor];
    [self.bgView addSubview:self.textField];
    
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bgView.frame.origin.y + self.bgView.frame.size.height + textPadding, self.frame.size.width,textHeight)];
    self.bottomLabel.text = displayText;
    [self.bottomLabel setFont: [self.bottomLabel.font fontWithSize: fontSize]];
    self.bottomLabel.numberOfLines=0;
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.textColor = [SFIColors ruleGraycolor];
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:self.bottomLabel];
}

@end
