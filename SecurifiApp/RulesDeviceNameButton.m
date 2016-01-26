//
//  RulesDeviceNameButton.m
//  RulesUI
//
//  Created by Masood on 30/11/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import "RulesDeviceNameButton.h"
#import "SFIColors.h"

@implementation RulesDeviceNameButton


-(id) initWithFrame: (CGRect) frame
{
    return [super initWithFrame:frame];
    //    return self;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    NSLog(@" selected %d %d",selected,self.isTrigger);
    UIColor *color=selected?self.isTrigger? [SFIColors ruleBlueColor]: [SFIColors ruleOrangeColor]:[SFIColors ruleGraycolor];
    [self setTitleColor:color forState:UIControlStateNormal];
}

-(void)deviceProperty:(BOOL)isTrigger deviceType:(SFIDeviceType)devicetype deviceName:(NSString*)deviceName deviceId:(int)deviceId {
    self.isTrigger = isTrigger;
    
    self.deviceName = deviceName;
    self.deviceType = devicetype;
    self.deviceId = deviceId;
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitle:deviceName forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:12];
    self.titleLabel.numberOfLines = 1;
    super.titleLabel.textAlignment = NSTextAlignmentCenter;
}





@end
