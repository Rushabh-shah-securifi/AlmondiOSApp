//
//  SFIWirelessUserViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 03/01/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIColors.h"
#import "MBProgressHUD.h"

@interface SFIWirelessUserViewController : UITableViewController

@property(nonatomic, retain) NSString *actionType;
@property(nonatomic, retain) NSMutableArray *listAvailableColors;
@property(nonatomic) NSInteger currentColorIndex;
@property(nonatomic, retain) SFIColors *currentColor;
@property(nonatomic, retain) NSMutableData *genericData;
@property(nonatomic, retain) NSString *genericString;

@property NSTimer *mobileCommandTimer;
@property BOOL isMobileCommandSuccessful;

@property(nonatomic, retain) NSString *currentMAC;
@property unsigned int currentInternalIndex;
@property unsigned int mobileInternalIndex;
@property(nonatomic, retain) NSArray *blockedDevices;
@property(nonatomic, retain) NSArray *connectedDevices;

@property(nonatomic, retain) NSMutableArray *combinedList;
@property(nonatomic, retain) NSMutableArray *addBlockedDeviceList;
@property(nonatomic, retain) NSMutableArray *setBlockedDeviceList;
@property(nonatomic, retain) NSMutableArray *blockedDeviceList;

@property unsigned int expectedGenericDataLength, totalGenericDataReceivedLength, command;
@end
