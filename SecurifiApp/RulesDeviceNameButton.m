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
    self.titleLabel.textColor = self.selected?self.isTrigger? [SFIColors ruleBlueColor]: [SFIColors ruleOrangeColor]:[SFIColors ruleGraycolor];
}

-(void)deviceProperty:(BOOL)isTrigger deviceType:(SFIDeviceType)devicetype deviceName:(NSString*)deviceName deviceId:(int)deviceId {
    //self.selected = NO;
    self.isTrigger = isTrigger;

    self.deviceName = deviceName;
    self.deviceType = devicetype;
    self.deviceId = deviceId;
    [super setTitle:deviceName forState:UIControlStateNormal];
    self.titleLabel.numberOfLines = 1;
//    super.titleLabel.textColor = [UIColor blackColor];
    [super titleColorForState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:@"AvenirLTStd-Roman" size:12];
    self.titleLabel.text = deviceName;
    super.titleLabel.textAlignment = NSTextAlignmentCenter;
}





@end
