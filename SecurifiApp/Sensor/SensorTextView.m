//
//  SensorTextView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SensorTextView.h"
#import "UIFont+Securifi.h"

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
    deviceNameField.textColor = [UIColor whiteColor];
    deviceNameField.font = [UIFont securifiLightFont];
    [self addSubview:deviceNameField];

}

@end
