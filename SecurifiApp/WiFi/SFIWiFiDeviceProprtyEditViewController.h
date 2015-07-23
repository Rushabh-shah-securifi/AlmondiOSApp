//
//  SFIWiFiDeviceProprtyEditViewController.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 13.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIConnectedDevice.h"

@protocol SFIWiFiDeviceProprtyEditViewDelegate
- (void)updateDeviceInfo:(SFIConnectedDevice *)deviceInfo;
@end

@interface SFIWiFiDeviceProprtyEditViewController : UIViewController

@property (weak) id<SFIWiFiDeviceProprtyEditViewDelegate> delegate;
@property(assign)int editFieldIndex;
@property(strong)SFIConnectedDevice *connectedDevice;

@end
