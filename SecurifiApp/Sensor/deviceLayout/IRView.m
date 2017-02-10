//
//  IRView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 07/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "IRView.h"
#import "UIFont+Securifi.h"
#import "UIViewController+Securifi.h"
#import "Colours.h"
@interface IRView()
@property (nonatomic) UILabel *deviceNameField;
@end
@implementation IRView
-(id) initWithFrame:(CGRect)frame color:(UIColor *)color genericIndexValue:(GenericIndexValue *)genericIndexValue isSensor:(BOOL)isSensor
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        self.genericIndexValue = genericIndexValue;
        self.isSensor = isSensor;
        [self drawTextField];
    }
    return self;
}
-(void)drawTextField{
    _deviceNameField = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 5)];
    _deviceNameField.text = self.genericIndexValue.genericValue.value;
    _deviceNameField.textColor = [UIColor whiteColor];
    _deviceNameField.font = [UIFont securifiFont:15];
    //    [self.deviceNameField becomeFirstResponder];
    UIView *OnelineView = [[UIView alloc]initWithFrame:CGRectMake(_deviceNameField.frame.origin.x, _deviceNameField.frame.size.height , self.frame.size.width, 1)];
    OnelineView.backgroundColor = [UIColor whiteColor];
    OnelineView.alpha = 0.5;
    UIImageView *textCheckMarkView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.height , 5, self.frame.size.height -22, self.frame.size.height -15)];
    textCheckMarkView.alpha = 0.7;
    NSLog(@"frame width: %f, frame height: %f", self.frame.size.width, self.frame.size.height);
    textCheckMarkView.image = [UIImage imageNamed:@"right-arrow"];
    
    UIButton *btnCloseNotification = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCloseNotification.frame = CGRectMake(self.frame.size.width - self.frame.size.height - 20, 0, 60, 35);
    btnCloseNotification.backgroundColor = [UIColor clearColor];
    [btnCloseNotification addTarget:self action:@selector(tapCheckMark) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btnCloseNotification];
    [self addSubview:textCheckMarkView];
    [self addSubview:OnelineView];
    [self addSubview:_deviceNameField];
    
}
-(void)tapCheckMark{
    [self.delegate save:_deviceNameField.text forGenericIndexValue:_genericIndexValue];
}
@end
