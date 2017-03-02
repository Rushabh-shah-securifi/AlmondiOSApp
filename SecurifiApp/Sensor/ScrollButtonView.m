//
//  ScrollButtonView.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 02/03/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "ScrollButtonView.h"
#import "UICommonMethods.h"
#import "UIFont+Securifi.h"


#define FONT_SIZE 16
#define MAX_LENGTH 18
@interface ScrollButtonView()
@property (nonatomic)UIColor *color;
@property (nonatomic)NSArray *locationArr;
@end
@implementation ScrollButtonView

-(id) initWithFrame:(CGRect)frame color:(UIColor *)color location:(NSString *)location
{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        [self addButtons:location];
    }
    return self;
}
-(void)addButtons:(NSString *)location{
    int pos = 5;
    int i = 0;

    self.locationArr = [Device getDeviceLocations];
    for (NSString *deviceLocation in self.locationArr) {
        pos = [self addDeviceLocation:deviceLocation tag:i xpos:pos  matchingTag:location];
        i++;
    }
    self.contentSize = CGSizeMake(pos +10,self.contentSize.height);
    
}
- (int)addDeviceLocation:(NSString *)deviceLocation tag:(int)tag xpos:(int)xpos matchingTag:(NSString *)matchingLoc{
    double deviceButtonHeight = 26;
    CGRect textRect = [UICommonMethods adjustDeviceNameWidth:deviceLocation fontSize:20 maxLength:25];
    CGRect frame = CGRectMake(xpos, 5, textRect.size.width + 15, deviceButtonHeight);
    UIButton *deviceLocBtn = [[UIButton alloc]initWithFrame:frame];
    
    [deviceLocBtn setTitle:deviceLocation forState:UIControlStateNormal];
    deviceLocBtn.tag = tag;
    deviceLocBtn.selected = NO;
    
    if([matchingLoc isEqualToString:deviceLocation]){
        deviceLocBtn.selected = YES;
    }
    [self selectedButton:deviceLocBtn];
    
    deviceLocBtn.titleLabel.font = [UIFont securifiFont:16];
    deviceLocBtn.layer.cornerRadius = 13;//half of the width
    deviceLocBtn.layer.borderWidth=1.0f;
    [deviceLocBtn addTarget:self action:@selector(onDeviceLocClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:deviceLocBtn];
    
    return xpos + textRect.size.width +20;
}

-(void)onDeviceLocClick:(id)sender{
    UIButton *deviceBtn = (UIButton *)sender;
    //toggeling
    [self toggleHighlightForDeviceNameButton:deviceBtn];
    deviceBtn.selected = YES;
    [self selectedButton:deviceBtn];
    [self.delegate updateDeviceListLocation:[self.locationArr objectAtIndex:deviceBtn.tag]];
    
}

-(void)selectedButton:(UIButton *)deviceLocBtn{
    if(deviceLocBtn.selected){
        deviceLocBtn.backgroundColor = [UIColor grayColor];
        [deviceLocBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deviceLocBtn.layer.borderColor=[UIColor whiteColor].CGColor;
    }
    else{
        deviceLocBtn.backgroundColor = [UIColor whiteColor];
        [deviceLocBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        deviceLocBtn.layer.borderColor=[UIColor grayColor].CGColor;
    }
}
-(void)toggleHighlightForDeviceNameButton:(UIButton *)currentButton{
    for(UIButton *button in [self subviews]){
        if([button isKindOfClass:[UIButton class]]){
            button.selected = NO;
            [self selectedButton:button];
        }
    }
    currentButton.selected = YES;
    
}

@end
