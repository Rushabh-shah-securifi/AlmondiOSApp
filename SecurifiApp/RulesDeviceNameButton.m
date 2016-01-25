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
-(id)initiliaze:(BOOL)isTrigger andFrame:(CGRect)frame deviceType:(SFIDeviceType)devicetype deviceName:(NSString*)deviceName deviceId:(int)deviceId{
    self.selected = NO;
    self.isTrigger = isTrigger;
    [self deviceProperty:devicetype deviceName:deviceName deviceId:deviceId];
    return [super initWithFrame:frame];
}


- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
    self.titleLabel.textColor = self.selected?self.isTrigger? [SFIColors ruleBlueColor]: [SFIColors ruleOrangeColor]:[SFIColors ruleGraycolor];
}

-(void)deviceProperty:(SFIDeviceType)devicetype deviceName:(NSString*)deviceName deviceId:(int)deviceId{
    self.deviceName = deviceName;
    self.deviceType = devicetype;
    self.deviceId = deviceId;
    [super setTitle:deviceName forState:UIControlStateNormal];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:12];
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}





@end
