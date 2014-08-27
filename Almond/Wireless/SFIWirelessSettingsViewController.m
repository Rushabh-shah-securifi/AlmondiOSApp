//
//  SFIWirelessSettingsControllerViewController.m
//  Securifi Cloud
//
//  Created by Securifi-Mac2 on 14/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIWirelessSettingsViewController.h"

@interface SFIWirelessSettingsViewController ()

@end

@implementation SFIWirelessSettingsViewController
@synthesize security, encryptionType, channel, password, ssid, currentSetting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"Settings page");
    
    //Display information for wireless settings
    self.ssid.text = currentSetting.ssid;
    self.password.text = currentSetting.password;
    self.channel.text = currentSetting.channel;
    self.encryptionType.text = currentSetting.encryptionType;
    self.security.text = currentSetting.security;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setWirelessSettingsHandler:(id)sender{
    //TODO: Option to set wireless settings
    NSLog(@"Set settings");
}

@end
