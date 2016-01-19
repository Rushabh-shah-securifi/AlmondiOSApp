//
//  RulesDeviceNameButton.h
//  RulesUI
//
//  Created by Masood on 30/11/15.
//  Copyright © 2015 Masood. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecurifiToolkit/SFIDevice.h"

@interface RulesDeviceNameButton : UIButton
//@property(nonatomic) SFIDevice *device;
//@property(nonatomic) SFIDeviceType deviceType; //for mode, clients
@property(nonatomic)int deviceId;
@property(nonatomic)SFIDeviceType deviceType;
@property(nonatomic)NSString *deviceName;
- (void)changeStyle;
@end
