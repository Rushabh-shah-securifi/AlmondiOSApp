//
//  SFIWiFiDeviceDetailViewController.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 11.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIConnectedDevice.h"
@protocol SFIWiFiDeviceDetailViewDelegate
- (void)removeClientTapped:(SFIConnectedDevice *)deviceInfo;
@end

@interface SFIWiFiDeviceDetailViewController : UIViewController

@property(strong)SFIConnectedDevice *connectedDevice;
@property (weak) id<SFIWiFiDeviceDetailViewDelegate> delegate;
@end
