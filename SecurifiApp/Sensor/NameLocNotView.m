//
//  NameLocNotView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "NameLocNotView.h"
#import "UIFont+Securifi.h"
#import "Device.h"
#import "SFIColors.h"

@implementation NameLocNotView
-(id) initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
    //    return self;
}

-(void)drawNameAndLoc:(NSString *)deviceName labelText:(NSString*)labelText{
    UILabel *Name = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
    Name.text = labelText;
    Name.font = [UIFont securifiBoldFont];
    Name.textColor = [UIColor whiteColor];
    [self addSubview:Name];
    
    self.deviceNameField = [[UITextField alloc]initWithFrame:CGRectMake(0,20,self.frame.size.width -10,30)];
    self.deviceNameField.text = deviceName;
    self.deviceNameField.textColor = [UIColor whiteColor];
    self.deviceNameField.font = [UIFont securifiLightFont];
    [self addSubview:self.deviceNameField];
    
    UIView *separatorView1 = [[UIView alloc]initWithFrame:CGRectMake(0,self.frame.size.height - 10,self.frame.size.width -15,1)];
    separatorView1.backgroundColor = [UIColor whiteColor];
    [self addSubview:separatorView1];
    
    

}
-(void)notiFicationField:(NSString*)labelText andDevice:(Device*)device{
    NSArray *array = @[@"Always",@"When I'm away,",@"never"];
    UILabel *Name = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
    Name.text = labelText;
    Name.font = [UIFont securifiBoldFont];
    Name.textColor = [UIColor whiteColor];
    [self addSubview:Name];
    int xPos = 0;
    for(int i = 0; i<array.count;i++){
        CGRect textRect = [self adjustDeviceNameWidth:[array objectAtIndex:i]];
        CGRect frame = CGRectMake(xPos, 20, textRect.size.width + 5, 30);
        UIButton *button = [[UIButton alloc ]initWithFrame:frame];
        [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        button.backgroundColor = [SFIColors clientGreenColor];
        button.titleLabel.font = [UIFont securifiBoldFont];
        button.tag = i;
        button.opaque = YES;
        button.alpha = 0.8;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onNotifyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        xPos = xPos + button.frame.size.width;

    }
 
    
}

-(CGRect)adjustDeviceNameWidth:(NSString*)deviceName{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGRect textRect;
    
    textRect.size = [deviceName sizeWithAttributes:attributes];
    if(deviceName.length > 18){
        NSString *temp=@"123456789012345678";
        textRect.size = [temp sizeWithAttributes:attributes];
    }
    return textRect;
}
-(void)onNotifyButtonClicked:(UIButton *)sender{
    for(UIButton *button in [[sender superview] subviews]){
        if([button isKindOfClass:[UILabel class]])
            continue;
        if( button.tag == sender.tag){
            button.alpha = 1.0;
            button.selected = YES;
        }
        else{
            button.alpha = 0.3;
            button.selected = NO;
        }
    }
   //values delegate to super view class
}
@end
