//
//  SFIRouterViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

@interface SFIRouterViewController : UIViewController <UIActionSheetDelegate>
{
    //PY 301013 - Generic Command Request
    NSMutableData *genericData;
    NSString *genericString;
}
@property unsigned int mobileInternalIndex;
@property BOOL isPartial;
@property NSString *currentMAC;

//PY 301013 - Generic Command Request
@property unsigned int expectedGenericDataLength,totalGenericDataReceivedLength, command;

- (IBAction)rebootButtonHandler:(id)sender;
- (IBAction)getConnectedDeviceHandler:(id)sender;
- (IBAction)getBlockedDeviceHandler:(id)sender;
- (IBAction)getBlockedContentHandler:(id)sender;
- (IBAction)getWirelessSettingsHandler:(id)sender;
- (IBAction)setBlockedDeviceHandler:(id)sender;
- (IBAction)setBlockedContentHandler:(id)sender;

- (IBAction)revealMenu:(id)sender;
@end

