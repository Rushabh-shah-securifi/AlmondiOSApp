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
#import "DeviceKnownValues.h"

@implementation SensorButtonView
-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
    //    return self;
}
-(void)drawButton:(NSDictionary *)valuedict color:(UIColor *)color{
    DeviceKnownValues *deviceValue = [DeviceKnownValues new];
    int selectedValue = 0;
    if(self.device){
        deviceValue  = [self.device.knownValues objectAtIndex:0];
    }
    NSArray *allkeys = [valuedict allKeys];
    
    NSMutableArray *labelsArray = [[NSMutableArray alloc]init];
    
    for(int i =0;i < allkeys.count ;i++){
        if([deviceValue.value isEqualToString:[allkeys objectAtIndex:i]]){
            selectedValue = i;
        }
        [labelsArray addObject:[[valuedict valueForKey:[allkeys objectAtIndex:i]]valueForKey:@"Label"]];
    }
    [self drawButton:labelsArray selectedValue:selectedValue];
}

-(void)drawButton:(NSArray*)array selectedValue:(int)selectedValue{
    
    int xPos = -10;
    for(int i = 0; i<array.count;i++){
        CGRect textRect = [self adjustDeviceNameWidth:[array objectAtIndex:i]];
        CGRect frame = CGRectMake(xPos + 10, 0, textRect.size.width + 10, self.frame.size.height);
        UIButton *button = [[UIButton alloc ]initWithFrame:frame];
        [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
        
        button.backgroundColor = [self darkerColorForColor:[SFIColors ruleBlueColor]];
        button.titleLabel.font = [UIFont securifiBoldFont];
        button.tag = i;
        button.opaque = YES;
        button.userInteractionEnabled = YES;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if(selectedValue == button.tag){
             button.backgroundColor = [UIColor whiteColor];
            [button setTitleColor:self.color forState:UIControlStateNormal];
        }
        
        [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        NSLog(@" button tags %ld",(long)button.tag);
        [self addSubview:button];
        xPos = xPos + button.frame.size.width ;
        
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
-(void)onButtonClicked:(UIButton *)sender{
    NSLog(@"onButtonClicked ");
    for(UIButton *button in [[sender superview] subviews]){
        if([button isKindOfClass:[UILabel class]])
            continue;
        if( button.tag == sender.tag){
            button.selected = YES;
            [button setTitleColor:[SFIColors ruleBlueColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[UIColor whiteColor]];
        }
        else{
            button.selected = NO;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:[self darkerColorForColor:[SFIColors ruleBlueColor]]];
        }
    }
    //values delegate to super view class
}
- (UIColor *)lighterColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                               green:MIN(g + 0.2, 1.0)
                                blue:MIN(b + 0.2, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

/*
 
 int xPos = 0;
 for(int i = 0; i<array.count;i++){
 CGRect textRect = [self adjustDeviceNameWidth:[array objectAtIndex:i]];
 CGRect frame = CGRectMake(xPos, 20, textRect.size.width + 5, 30);
 UIButton *button = [[UIButton alloc ]initWithFrame:frame];
 [button setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
 button.backgroundColor = [self darkerColorForColor:color];
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
 button.selected = YES;
 [button setTitleColor:[SFIColors ruleBlueColor] forState:UIControlStateNormal];
 [button setBackgroundColor:[UIColor whiteColor]];
 }
 else{
 button.selected = NO;
 [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
 [button setBackgroundColor:[self darkerColorForColor:[SFIColors ruleBlueColor]]];
 }
 }
 //values delegate to super view class
 }
 - (UIColor *)lighterColorForColor:(UIColor *)c
 {
 CGFloat r, g, b, a;
 if ([c getRed:&r green:&g blue:&b alpha:&a])
 return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
 green:MIN(g + 0.2, 1.0)
 blue:MIN(b + 0.2, 1.0)
 alpha:a];
 return nil;
 }
 
 - (UIColor *)darkerColorForColor:(UIColor *)c
 {
 CGFloat r, g, b, a;
 if ([c getRed:&r green:&g blue:&b alpha:&a])
 return [UIColor colorWithRed:MAX(r - 0.3, 0.0)
 green:MAX(g - 0.3, 0.0)
 blue:MAX(b - 0.3, 0.0)
 alpha:a];
 return nil;
 }

 */
@end
