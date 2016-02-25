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
#import "SensorButtonView.h"

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
-(void)notiFicationField:(NSString*)labelText andDevice:(Device*)device color:(UIColor *)color{
    NSArray *array = @[@"Always",@"When I'm away",@"never"];
    UILabel *Name = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
    Name.text = labelText;
    Name.font = [UIFont securifiBoldFont];
    Name.textColor = [UIColor whiteColor];
    [self addSubview:Name];
    SensorButtonView *sensorbuttons = [[SensorButtonView alloc]init];
    [sensorbuttons drawButton:array selectedValue:5];
    [self addSubview:sensorbuttons];
    
}

@end
