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
   UITextField *deviceNameField = [[UITextField alloc]initWithFrame:self.frame];
    deviceNameField.text = name;
    deviceNameField.delegate = self;
    deviceNameField.backgroundColor = self.color;
    deviceNameField.textColor = [UIColor whiteColor];
    deviceNameField.font = [UIFont securifiLightFont];
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
    UIImageView *textCheckMarkView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - self.frame.size.height , 10, self.frame.size.height -10, self.frame.size.height -10)];
    textCheckMarkView.image = [UIImage imageNamed:@"iconSceneChekmark"];
    [self addSubview:textCheckMarkView];
}
@end
