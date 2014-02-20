//
//  SFIWirelessSettingsControllerViewController.h
//  Securifi Cloud
//
//  Created by Securifi-Mac2 on 14/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIWirelessSetting.h"

@interface SFIWirelessSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *ssid;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *channel;
@property (weak, nonatomic) IBOutlet UITextField *encryptionType;
@property (weak, nonatomic) IBOutlet UITextField *security;
@property (nonatomic, retain)SFIWirelessSetting *currentSetting;

- (IBAction)setWirelessSettingsHandler:(id)sender;
@end
