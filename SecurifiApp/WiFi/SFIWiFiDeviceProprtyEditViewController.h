//
//  SFIWiFiDeviceProprtyEditViewController.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 13.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

static const float ITEM_SPACING = 2.0;

@protocol SFIWiFiDeviceProprtyEditViewDelegate
- (void)updateDeviceInfo:(SFIConnectedDevice *)deviceInfo;
@end

@interface SFIWiFiDeviceProprtyEditViewController : UIViewController
@property (weak) id<SFIWiFiDeviceProprtyEditViewDelegate> delegate;
@property(assign)NSInteger editFieldIndex;
@property(strong)SFIConnectedDevice *connectedDevice;
@property(strong)NSString* userID;
@property(strong)NSString* selectedNotificationType;

@end
