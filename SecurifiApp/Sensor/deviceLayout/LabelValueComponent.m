//
//  LabelValueComponent.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 08/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "LabelValueComponent.h"
#import "UIFont+Securifi.h"
#import "UIViewController+Securifi.h"
#import "Colours.h"
@interface LabelValueComponent ()
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *valueLabel;
@end
@implementation LabelValueComponent

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue propertyName:(NSString *)propertyName
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.genericIndexValue = genericIndexValue;
        [self drawTextField:propertyName];
    }
    return self;
}
-(void)drawTextField:(NSString *)propertyName{
    self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, self.frame.size.height - 5)];
    self.nameLabel.text = propertyName;
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont securifiFont:15];
    //    [self.deviceNameField becomeFirstResponder];
    
    
    self.valueLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 150, 0, 130, self.frame.size.height - 5)];
    self.valueLabel.text = self.genericIndexValue.genericValue.value;
    self.valueLabel.textColor = [UIColor whiteColor];
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    self.valueLabel.font = [UIFont securifiFont:15];
    UIImageView *textCheckMarkView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 10 , 2, self.frame.size.height -7 , self.frame.size.height -5)];
    textCheckMarkView.alpha = 0.7;
    NSLog(@"frame width: %f, frame height: %f", self.frame.size.width, self.frame.size.height);
    textCheckMarkView.image = [UIImage imageNamed:@"right-arrow"];
    
    UIButton *btnCloseNotification = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCloseNotification.frame = CGRectMake(self.frame.size.width - 80, 0, 80, 35);
    btnCloseNotification.backgroundColor = [UIColor clearColor];
    [btnCloseNotification addTarget:self action:@selector(tapCheckMark) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btnCloseNotification];
    [self addSubview:textCheckMarkView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.valueLabel];
    
}
-(void)tapCheckMark{
    [self.delegate save:self.valueLabel.text forGenericIndexValue:_genericIndexValue];
}

@end
