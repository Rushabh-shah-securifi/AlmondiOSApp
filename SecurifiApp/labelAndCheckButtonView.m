//
//  labelAndCheckButtonView.m
//  Tableviewcellpratic
//
//  Created by Securifi-Mac2 on 05/11/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import "labelAndCheckButtonView.h"
#import "RulesConstants.h"
#import "Colours.h"
#import "SFIColors.h"

@implementation labelAndCheckButtonView


const int hueLabelWidth = 100;
const int hueButtonLabelSize = 60;
const int hueButtonSize = 20;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (void)setSelected:(BOOL)selected{
    [self.selectButton setSelected:selected];
    [self changeColor];
}
-(void)changeColor{
    if (self.selectButton.selected) {
        self.selectButton.backgroundColor = [SFIColors ruleOrangeColor];
    }else{
        self.selectButton.backgroundColor = [UIColor clearColor];
    }
    
}
-(void)setUpValues:(NSString*)propertyName withSelectButtonTitle:(NSString*)title{
    
    //propertyName
    self.propertyNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, hueLabelWidth, hueSubViewSize)];
    self.propertyNameLabel.text = propertyName;
    [self.propertyNameLabel setFont: [self.propertyNameLabel.font fontWithSize:11]];
    self.propertyNameLabel.textAlignment = NSTextAlignmentLeft;
    
    //select Button
    self.selectButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - hueButtonLabelSize, 0, hueButtonLabelSize, hueSubViewSize)];
    [self.selectButton setTitle:title forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.selectButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.selectButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.selectButton.titleLabel.font = [UIFont systemFontOfSize:11];
    
    [self addSubview:self.propertyNameLabel];
    [self addSubview:self.selectButton];
}

- (void)setButtoncounter:(int)btnCount isCountImageHiddn:(BOOL)ishidden{
    //assuming 20 cross 20 box
    if(self.countLable.text != nil){
        self.countLable.text = nil;
    }
    self.countLable = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - (countDiameter + 2), 2, countDiameter, countDiameter)];
    CALayer * l1 = [self.countLable layer];
    [l1 setMasksToBounds:YES];
    [l1 setCornerRadius:countDiameter/2];
    
    // You can even add a border
    
    [l1 setBorderColor:[[UIColor colorFromHexString:@"FF9500"] CGColor]];
    [l1 setBorderWidth: 1];
    self.countLable.backgroundColor = [UIColor whiteColor];//FF9500
    self.countLable.font = [UIFont fontWithName:@"AvenirLTStd-Heavy" size:3];
    self.countLable.font = [UIFont systemFontOfSize:9];
    //[self.countLable setFont:[UIFont fontWithName:@"AvenirLTStd-Heavy" size:4]];
    self.countLable.text = [NSString stringWithFormat:@"%d",btnCount];
    self.countLable.textAlignment = NSTextAlignmentCenter;
    self.countLable.hidden = ishidden;
    [self addSubview:self.countLable];
    
    //select Button
    self.selectButton.frame = CGRectMake(self.frame.size.width - (hueButtonLabelSize + countDiameter + 4), 0, hueButtonLabelSize, hueSubViewSize);
    
    [self addSubview:self.propertyNameLabel];
    [self addSubview:self.selectButton];
    
}

@end