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
#import "SwitchButton.h"

@interface DimmerButton()
@property (nonatomic) SwitchButton *conditionBtn;
@end
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
    [super changeBGColor:self.isTrigger clearColor:selected showTitle:NO isScene:self.isScene];
   UIColor *color = !selected?[SFIColors ruleGraycolor]:[SFIColors ruleBlueColor];
    self.conditionBtn.backgroundColor = color;
    //[self changeStyle];
}

- (void)setupValues:(NSString*)text  Title:(NSString*)title suffix:(NSString*)suffix isTrigger:(BOOL)isTrigger isScene:(BOOL)isScene{
    //awakefromnib
    self.isScene = isScene;
    self.isTrigger = isTrigger;
    self.dimValue = text;
    self.backgroundColor = [UIColor clearColor];
   
    if(self.isTrigger && !isScene){
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(65,0 , 65, 60)];
        lblMain = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64 ,60)];
        lblMain.numberOfLines = 2;
        lblMain.lineBreakMode = NSLineBreakByWordWrapping;
        self.conditionBtn = [[SwitchButton alloc]initWithFrame:CGRectMake(0, 0, 64,60)];
        [self.conditionBtn addBgView:0 widthAndHeight:60];
        NSLog(@"condition text %@",[self.subProperties getcondition]);
        [self.conditionBtn mainLabel:@"" text:[self.subProperties getcondition] size:35.0f];
        self.conditionBtn.backgroundColor = [SFIColors ruleGraycolor];
        [self.conditionBtn addTarget: self action:@selector(onCondition:) forControlEvents:UIControlEventTouchUpInside];
        self.conditionBtn.subProperties = self.subProperties;
        [self addSubview:self.conditionBtn];
    }
    else{
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-textHeight + 5,self.frame.size.height-textHeight +5)];
        lblMain = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width-textHeight + 5,self.frame.size.height-textHeight)];
        
    }
    self.bgView.backgroundColor = [SFIColors ruleGraycolor];
    [self addSubview:self.bgView];
    
    
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
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:(isTrigger && !isScene)?25.0f:35.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:(isTrigger && !isScene)?25.0f:35.0f]} range:NSMakeRange(text.length,suffix.length)];
    [lblMain setAttributedText:strTemp];
    
    self.bottomLabel.text = title;
}


- (void)setupValues:(NSString*)text  Title:(NSString*)title displayText:(NSString*)displayText suffix:(NSString*)suffix{
    //device name title
    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width,textHeight)];
    //    self.bottomLabel.font = self.titleLabel.font;
    lblDeviceName.text = title;
    lblDeviceName.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:topFontSize];
    lblDeviceName.numberOfLines=0;
    lblDeviceName.textAlignment = NSTextAlignmentCenter;
    lblDeviceName.textColor = [UIColor blackColor];
    [self addSubview:lblDeviceName];
    
    //set value
    self.dimValue = text;
    self.backgroundColor = [UIColor clearColor];
    
    //self.bgView
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, lblDeviceName.frame.size.height, dimFrameWidth-20,entryBtnWidth +5)];
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
    self.bottomLabel.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:fontSize];
    self.bottomLabel.numberOfLines=0;
    self.bottomLabel.textColor = [SFIColors ruleGraycolor];
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.bottomLabel];

    //lblmain adjutments
    self.prefix = suffix;
    
    NSString *strTopTitleLabelText = [text stringByAppendingString:suffix];
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:strTopTitleLabelText];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:20.0f]} range:NSMakeRange(0,text.length)]; //40
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:20.0f]} range:NSMakeRange(text.length,suffix.length)];
    [lblMain setAttributedText:strTemp];//24
    lblMain.lineBreakMode = NSLineBreakByWordWrapping;
    lblMain.numberOfLines = 0;
}

- (NSString *)scaledValue:(NSString*)text{
    return [NSString stringWithFormat:@"%d", (int) ([text intValue]/self.factor)];
}


- (void)setNewValue:(NSString*)text subProperties:(SFIButtonSubProperties *)subProperty{
    self.dimValue = text;
    [self.conditionBtn mainLabel:@"" text:[subProperty getcondition] size:35.0f];
    NSLog(@"condition label %@",[self.subProperties getcondition]);
    self.prefix = (self.prefix ==nil || self.prefix.length==0) ?@" ":self.prefix;
    NSMutableAttributedString *strTemp = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",text,self.prefix]];
    NSLog(@"prefix %@",self.prefix);
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:(_isTrigger && !_isScene)?25.0f:35.0f]} range:NSMakeRange(0,text.length)];
    [strTemp addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:(_isTrigger && !_isScene)?25.0f:35.0f]} range:NSMakeRange(text.length,self.prefix.length)];
    [lblMain setAttributedText:strTemp];
}
- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden{
    countLable = [[UILabel alloc]initWithFrame:CGRectMake(self.bgView.frame.origin.x + self.bgView.frame.size.width -9, -6, 16, 16)];
    
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
    crossButtonBGView = [[UIView alloc]initWithFrame:CGRectMake(self.bgView.frame.origin.x  + self.bgView.frame.size.width - 10, 13, countDiameter, countDiameter)];
    [self setLayer];
    [self addImage:[UIImage imageNamed:@"icon_cross_gray"] y:crossButtonBGView.frame.origin.y widthAndHeight:countDiameter];
    [crossButtonBGView setBackgroundColor:[SFIColors ruleLightGrayColor]];
    crossButtonBGView.hidden = isHidden;
    crossButtonBGView.userInteractionEnabled = NO;
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
-(void)setUpTextField:(NSString*)textFieldText displayText:(NSString*)displayText suffix:(NSString *)suffix isScene:(BOOL)isScene isTrigger:(BOOL)isTrigger{
    self.isScene = isScene;
    if(isTrigger && !isScene){
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(65,0 , 65, 60)];
        self.bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgView];
        self.textField = [[RuleTextField alloc] initWithFrame:CGRectMake(0, 0, 64 ,textHeight)];
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, self.textField.frame.size.height - 1, self.textField.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
        [self.textField.layer addSublayer:bottomBorder];
        
        self.textField.center = CGPointMake(self.bgView.bounds.size.width/2, self.bgView.bounds.size.height/2);
        self.textField.subProperties = self.subProperties;
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.text = @"";
        self.textField.textAlignment = NSTextAlignmentCenter;
        self.textField.textColor = [UIColor whiteColor];
        self.textField.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:15];
        [self.bgView addSubview:self.textField];
        self.conditionBtn = [[SwitchButton alloc]initWithFrame:CGRectMake(0, 0, 64,60)];
        [self.conditionBtn addBgView:0 widthAndHeight:60];
        NSLog(@"condition text %@",[self.subProperties getcondition]);
        [self.conditionBtn mainLabel:@"" text:[self.subProperties getcondition] size:35.0f];
        self.conditionBtn.backgroundColor = [SFIColors ruleGraycolor];
        [self.conditionBtn addTarget: self action:@selector(onCondition:) forControlEvents:UIControlEventTouchUpInside];
        self.conditionBtn.subProperties = self.subProperties;
        [self addSubview:self.conditionBtn];

    }
    else
    {
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-textHeight,self.frame.size.height -textHeight + 5)];
        self.bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgView];
        self.prefix = suffix;
        self.textField = [[RuleTextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-60,textHeight)];
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, self.textField.frame.size.height - 1, self.textField.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
        [self.textField.layer addSublayer:bottomBorder];
        
        self.textField.center = CGPointMake(self.bgView.bounds.size.width/2, self.bgView.bounds.size.height/2);
        self.textField.subProperties = self.subProperties;
        self.textField.keyboardType = UIKeyboardTypeDefault;
        self.textField.text = @"";
        self.textField.textAlignment = NSTextAlignmentCenter;
        self.textField.textColor = [UIColor whiteColor];
        self.textField.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:15];
        [self.bgView addSubview:self.textField];
    }
    self.bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bgView.frame.origin.y + self.bgView.frame.size.height + textPadding, self.frame.size.width,textHeight)];
    self.bottomLabel.text = displayText;
    [self.bottomLabel setFont: [self.bottomLabel.font fontWithSize: fontSize]];
    self.bottomLabel.numberOfLines=0;
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.textColor = [SFIColors ruleGraycolor];
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:self.bottomLabel];
}
-(void)onCondition:(id)sender{
    NSLog(@"onCondition");
    SwitchButton *button = (SwitchButton*)sender;
    [self.conditionBtn mainLabel:@"" text:@" " size:35.f];
    int newValue = self.conditionBtn.subProperties.condition;
    NSLog(@"new val :%d",newValue++);
    self.conditionBtn.subProperties.condition = (newValue++) %5;

    switch (self.conditionBtn.subProperties.condition) {
        case isLessThan:{
            [self.conditionBtn mainLabel:@"" text:@" < " size:35.f];
            break;
        }
        case isGreaterThan:{
            [self.conditionBtn mainLabel:@"" text:@" > " size:35.f];
            break;
        }
        case isLessThanOrEqual:{
            [self.conditionBtn mainLabel:@"" text:@"<=" size:35.f];
            break;
        }
        case isGreaterThanOrEqual:{
            [self.conditionBtn mainLabel:@"" text:@">=" size:35.f];
            break;
        }
        case isEqual:{
            [self.conditionBtn mainLabel:@"" text:@" = " size:35.f];
            break;
        }
        default:
            break;
    }
    self.subProperties.condition = self.conditionBtn.subProperties.condition;
    [self.delegate setSelectedCondition:self.subProperties];
    
}
@end
