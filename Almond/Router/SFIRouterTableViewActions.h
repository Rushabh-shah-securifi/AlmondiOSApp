//
//  SFIRouterTableViewActions.h
//
//  Created by sinclair on 11/11/14.
//
#import <Foundation/Foundation.h>

@class SFIWirelessSetting;

// Delegate protocol adopted by the SFIRouterTableViewController and used to communicate UI actions from the table view cells.
@protocol SFIRouterTableViewActions <NSObject>

- (void)onRebootRouterActionCalled;

- (void)onEnableDevice:(SFIWirelessSetting *)summary enabled:(BOOL)isEnabled;

- (void)onChangeDeviceSSID:(SFIWirelessSetting *)summary newSSID:(NSString*)ssid;

// NO == block device
- (void)onEnableWirelessAccessForDevice:(NSString*)deviceMAC allow:(BOOL)isAllowed;

@end