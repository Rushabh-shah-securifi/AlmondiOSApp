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
    actionsIndexPathRow,
    stopIndexPathRow,
    batteryIndexPathRow,
    clamp1PowerIndexPathRow,
    clamp1EnergyIndexPathRow,
    clamp2PowerIndexPathRow,
    clamp2EnergyIndexPathRow,
    sirenSwitchMultilevelIndexPathRow,
    switch1IndexPathRow,
    switch2IndexPathRow,
    multiSensorTempIndexPathRow,
    acModeIndexPathRow,
    highTemperatureIndexPathRow,
    lowTemperatureIndexPathRow,
    swingIndexPathRow,
    powerIndexPathRow,
    irCodeIndexPathRow,
    configIndexPathRow,
    humidityIndexPathRow,
    luminanceIndexPathRow,
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
@property (strong, nonatomic) NSString *iconImageName;
@property (strong, nonatomic) NSArray *statusTextArray;

@end
