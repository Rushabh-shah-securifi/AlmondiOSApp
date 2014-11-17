//
//  SFIWirelessTableViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 14/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIOptionViewController.h"

@protocol wirelessSettingDelegate;

@interface SFIWirelessTableViewController : UITableViewController <UITextFieldDelegate, wirelessOptionDelegate>
@property (nonatomic, retain)  UITextField *ssid;
@property (nonatomic, retain)  UITextField *password;
@property (nonatomic, retain)  UITextField *wirelessMode;
@property (nonatomic, retain)  UILabel *lblWirelessMode;
@property (nonatomic, retain)  UILabel *lblChannel;
@property (nonatomic, retain)  UILabel *lblEncryption;
@property (nonatomic, retain)  UILabel *lblSecurity;
@property (nonatomic, retain)SFIWirelessSetting *currentSetting;
@property unsigned int mobileInternalIndex;
@property unsigned int optionType;
@property (nonatomic, retain) NSMutableDictionary *countryChannelMap;
@property (nonatomic, retain) NSMutableDictionary *encryptionSecurityMap;
@property (nonatomic, retain) NSMutableDictionary *wirelessModeIntergerMap;
@property (nonatomic, assign) id<wirelessSettingDelegate> selectedValueDelegate;
- (IBAction)setWirelessSettingHandler:(id)sender;
@end

@protocol wirelessSettingDelegate
@optional
-(void)refreshedList:(NSArray *)deviceList;

@end
