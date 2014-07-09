//
//  SFIConnectedDevicesListViewController.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 30/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFIWirelessViewController.h"
#import "SFIWirelessTableViewController.h"
#import "SFIColors.h"


@interface SFIRouterDevicesListViewController : UITableViewController <wirelessSettingsDelegate, wirelessSettingDelegate>
@property(nonatomic, strong) NSArray *deviceList;
@property int deviceListType;
@property(nonatomic, strong) NSMutableArray *listAvailableColors;
@property(nonatomic, strong) SFIColors *currentColor;
@end
