//
//  TextInput.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "TextInput.h"
#import "UIFont+Securifi.h"
@interface TextInput ()<UITextFieldDelegate>
@property (nonatomic)UITextField *deviceNameField;
@end
@implementation TextInput
-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
    //    return self;
}
-(void)drawTextField:(NSString*)name{
   self.deviceNameField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 5)];
    self.deviceNameField.text = name;
    self.deviceNameField.delegate = self;
    self.deviceNameField.backgroundColor = self.color;
    self.deviceNameField.textColor = [UIColor whiteColor];
    self.deviceNameField.font = [UIFont securifiLightFont:13];
    UIView *OnelineView = [[UIView alloc]initWithFrame:CGRectMake(self.deviceNameField.frame.origin.x, self.deviceNameField.frame.size.height , self.frame.size.width, 1)];
    OnelineView.backgroundColor = [UIColor whiteColor];
    OnelineView.alpha = 0.5;
    [self addSubview:OnelineView];
    [self addSubview:self.deviceNameField];

}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    UIImageView *textCheckMarkView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.height , 10, self.frame.size.height -10, self.frame.size.height -13)];
    textCheckMarkView.image = [UIImage imageNamed:@"iconSceneChekmark"];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCheckMark)];
    singleTap.numberOfTapsRequired = 1;
    [textCheckMarkView setUserInteractionEnabled:YES];
    [textCheckMarkView addGestureRecognizer:singleTap];
    
    
    [self addSubview:textCheckMarkView];
}
-(void)tapCheckMark{
    NSLog(@"tapCheckMark %@",self.deviceNameField.text);
    [self.delegate updateNewValue:self.deviceNameField.text];
}
@end
