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
    macAddressIndexPathRow,
    iPAddressIndexPathRow,
    connectionIndexPathRow,
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
