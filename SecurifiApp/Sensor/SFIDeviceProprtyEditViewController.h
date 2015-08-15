//
//  SFIDeviceProprtyEditViewController.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 13.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SFIDeviceProprtyEditViewControllerDelegate
- (void)updateDeviceInfo:(SFIConnectedDevice *)deviceInfo;
@end

@interface SFIDeviceProprtyEditViewController : UIViewController

@property (weak) id<SFIDeviceProprtyEditViewControllerDelegate> delegate;
@property(assign)int editFieldIndex;
@property(strong)SFIDevice *device;
@property(strong)SFIDeviceValue *deviceValue;
@property(strong)NSString* selectedNotificationType;
@property(nonatomic) UIColor *cellColor;
@end
