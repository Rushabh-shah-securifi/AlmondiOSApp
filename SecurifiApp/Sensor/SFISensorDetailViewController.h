//
//  SFISensorDetailViewController.h
//  SecurifiApp
//
//  Created by Tigran Aslanyan on 14.08.15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//
typedef NS_ENUM(NSInteger, Properties) {
    nameIndexPathRow,
    locationIndexPathRow,
    stopIndexPathRow,
    batteryIndexPathRow,
    multiSensorTempIndexPathRow,
    acModeIndexPathRow,
    highTemperatureIndexPathRow,
    lowTemperatureIndexPathRow,
    swingIndexPathRow,
    powerIndexPathRow,
    irCodeIndexPathRow,
    configIndexPathRow,
    humidityIndexPathRow,
    awayModeIndexPathRow,
    coLevelIndexPathRow,
    smokeLevelIndexPathRow,
    modeIndexPathRow,
    targetRangeIndexPathRow,
    acFanIndexPathRow,
    fanIndexPathRow,
    notifyMeIndexPathRow,
    deviceHistoryIndexPathRow,
};

#import <UIKit/UIKit.h>

@interface SFISensorDetailViewController : UIViewController

@property(nonatomic) SFIDevice *device;
@property(nonatomic) SFIDeviceValue *deviceValue;
@property(nonatomic) UIColor *cellColor;

@end
