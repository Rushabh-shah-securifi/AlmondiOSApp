//
//  SFIWirelessViewController.h
//  Securifi Cloud
//
//  Created by Securifi-Mac2 on 14/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol wirelessSettingsDelegate;

@interface SFIWirelessViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ssid;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *channel;
@property (weak, nonatomic) IBOutlet UITextField *encryptionType;
@property (weak, nonatomic) IBOutlet UITextField *security;
@property (weak, nonatomic) IBOutlet UITextField *wirelessMode;
@property (nonatomic, retain)SFIWirelessSetting *currentSetting;
@property unsigned int mobileInternalIndex;

@property (nonatomic, assign) id<wirelessSettingsDelegate> selectedValueDelegate;
- (IBAction)setWirelessSettingsHandler:(id)sender;
@end

@protocol wirelessSettingsDelegate
@optional
-(void)refreshedList:(NSArray *)deviceList;

@end