//
//  LabelView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 21/11/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "LabelView.h"
#import "UIFont+Securifi.h"
#import "Rule.h"
@interface LabelView()
@property (nonatomic)UIColor *color;
@property (nonatomic)UILabel *Label;
@property (nonatomic)Rule *rule;
@property BOOL isRule;
@end
@implementation LabelView

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color rule:(Rule *)rule isRule:(BOOL)isRule
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.rule = rule;
        self.isRule = isRule;
        [self drawTextField:@""];
    }
    return self;
}

-(void)drawTextField:(NSString *)text{
    self.Label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width -15, self.frame.size.height - 5)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width -25, 0, 25, self.frame.size.height - 5)];
    imageView.image = [UIImage imageNamed:@"rightarrow-icon"];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width -50, 0, 50, self.frame.size.height - 5)];
    [button addTarget:self action:@selector(onButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    text = self.rule?self.rule.name:(self.isRule?@"This device is not part of any rule":@"This device is not part of any scene");
    self.Label.text = text;
    
    //    self.deviceNameField.backgroundColor = self.color;
    self.Label.textColor = [UIColor whiteColor];
    self.Label.font = [UIFont securifiFont:15];
    //    [self.deviceNameField becomeFirstResponder];
    UIView *OnelineView = [[UIView alloc]initWithFrame:CGRectMake(self.Label.frame.origin.x, self.Label.frame.size.height , self.frame.size.width, 1)];
    OnelineView.backgroundColor = [UIColor whiteColor];
    OnelineView.alpha = 0.5;
    
    [self addSubview:OnelineView];
    [self addSubview:self.Label];
    if(self.rule){
        [self addSubview:imageView];
        [self addSubview:button];
    }
}
-(void )onButtonClicked{
    NSLog(@"rule name %@",self.rule.name);
    [self.delegate lableArrowClicked:self.rule isRule:self.isRule];
}
@end
