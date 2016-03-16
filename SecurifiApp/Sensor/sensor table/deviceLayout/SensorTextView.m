//
//  SensorTextView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SensorTextView.h"
#import "UIFont+Securifi.h"
@interface SensorTextView ()<UITextFieldDelegate>
@end
@implementation SensorTextView
-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
    //    return self;
}
-(void)drawTextField:(NSString*)name{
   UITextField *deviceNameField = [[UITextField alloc]initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - 5)];
    deviceNameField.text = name;
    deviceNameField.delegate = self;
    deviceNameField.backgroundColor = self.color;
    deviceNameField.textColor = [UIColor whiteColor];
    deviceNameField.font = [UIFont securifiLightFont];
    [deviceNameField becomeFirstResponder];
    UIView *OnelineView = [[UIView alloc]initWithFrame:CGRectMake(deviceNameField.frame.origin.x, deviceNameField.frame.size.height  + 7, self.frame.size.width, 1)];
    OnelineView.backgroundColor = [UIColor whiteColor];
    OnelineView.alpha = 0.5;
    [self addSubview:OnelineView];
    [self addSubview:deviceNameField];

}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
   
    [self.delegate updateNewValue:textField.text];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    UIImageView *textCheckMarkView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.height , self.frame.origin.y + 10, self.frame.size.height -20, self.frame.size.height -23)];
    textCheckMarkView.image = [UIImage imageNamed:@"iconSceneChekmark"];
    [self addSubview:textCheckMarkView];
}
@end
