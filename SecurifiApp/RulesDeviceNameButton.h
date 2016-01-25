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

@property(nonatomic)int deviceId;
@property(nonatomic)SFIDeviceType deviceType;
@property(nonatomic)NSString *deviceName;
@property(nonatomic)BOOL isTrigger;

-(id)initiliaze:(BOOL)isTrigger andFrame:(CGRect)frame deviceType:(SFIDeviceType)devicetype deviceName:(NSString*)deviceName deviceId:(int)deviceId;

@end
