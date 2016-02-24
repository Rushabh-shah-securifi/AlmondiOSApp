//
//  SensorButtonView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 24/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SensorButtonView.h"
#import "UIFont+Securifi.h"
#import "SFIColors.h"

@implementation SensorButtonView
-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
    //    return self;
}
-(void)drawButton:(NSDictionary *)valuedict color:(UIColor *)color{
    NSArray *allkeys = [valuedict allKeys];
    int xPos = 0;
    for(int i =0;i < allkeys.count ;i++){
        NSDictionary *dict = [valuedict valueForKey:[allkeys objectAtIndex:i]];
        CGRect textRect = [self adjustDeviceNameWidth:[dict valueForKey:@"Label"]];
        CGRect frame = CGRectMake(xPos, 20, textRect.size.width + 5, 30);
        UIButton *button = [[UIButton alloc ]initWithFrame:frame];
        [button setTitle:[dict valueForKey:@"Label"] forState:UIControlStateNormal];
        button.backgroundColor = [SFIColors clientGreenColor];
        button.titleLabel.font = [UIFont securifiBoldFont];
        button.tag = i;
        button.alpha = 0.3;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        xPos = xPos + button.frame.size.width;
    }
    
    
}

-(void)onButtonClicked:(UIButton*)senderButton{
    for(UIButton *button in [[senderButton superview] subviews]){
        if([button isKindOfClass:[UILabel class]])
            continue;
        if( button.tag == senderButton.tag){
            button.alpha = 1.0;
            button.selected = YES;
        }
        else{
            button.alpha = 0.3;
            button.selected = NO;
        }
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

@end
