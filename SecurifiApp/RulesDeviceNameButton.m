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
    
    UIColor *color=selected?self.isTrigger? [SFIColors ruleBlueColor]: [SFIColors ruleOrangeColor]:[UIColor blackColor];
    if(selected){
        if(self.isTrigger && !self.isScene)
            color = [SFIColors ruleBlueColor];
        else if(!self.isTrigger || self.isScene)
            color = [SFIColors ruleOrangeColor];
    }
    else
        color = [UIColor blackColor];
        
    [self setTitleColor:color forState:UIControlStateNormal];
}

-(void)deviceProperty:(BOOL)isTrigger deviceType:(SFIDeviceType)devicetype deviceName:(NSString*)deviceName deviceId:(int)deviceId isScene:(BOOL)isScene{
    self.isTrigger = isTrigger;
    self.isScene = isScene;
    self.deviceName = deviceName;
    self.deviceType = devicetype;
    self.deviceId = deviceId;
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitle:deviceName forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:15];
    self.titleLabel.numberOfLines = 1;
    super.titleLabel.textAlignment = NSTextAlignmentCenter;
}





@end
