//
//  SFIWiFiClientsListViewController.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 21.07.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//
typedef NS_ENUM(NSInteger, Properties) {
    nameIndexPathRow,
    typeIndexPathRow,
    manufacturerIndexPathRow,
    macAddressIndexPathRow,
    iPAddressIndexPathRow,
    rssiIndexPathRow,
    connectionIndexPathRow,
    allowOnNetworkIndexPathRow,
    usePresenceSensorIndexPathRow,
    notifyMeIndexPathRow,
    timeoutIndexPathRow,
    lastActiveTimeIndexPathRow,
    historyIndexPathRow,
    removeButtonIndexPathRow,
};

#import <UIKit/UIKit.h>

@interface SFIWiFiClientsListViewController : UIViewController

@property(nonatomic, strong) NSMutableArray *connectedDevices;

@end
