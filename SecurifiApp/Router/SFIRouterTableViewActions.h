//
//  SFIRouterTableViewActions.h
//
//  Created by sinclair on 11/11/14.
//
#import <Foundation/Foundation.h>

@class SFIWirelessSetting;

// Delegate protocol adopted by the SFIRouterTableViewController and used to communicate UI actions from the table view cells.
@protocol SFIRouterTableViewActions <NSObject>
@optional
- (void)onRebootRouterActionCalled;

- (void)onUpdateRouterFirmwareActionCalled;

- (void)onSendLogsActionCalled:(NSString*)problemDescription;

- (void)onEnableDevice:(SFIWirelessSetting *)setting enabled:(BOOL)isEnabled;

- (void)onChangeDeviceSSID:(SFIWirelessSetting *)setting newSSID:(NSString*)ssid;

- (void)onShareBtnTapDelegate:(SFIWirelessSetting *)settings;

// NO == block device
- (void)onEnableWirelessAccessForDevice:(NSString*)deviceMAC allow:(BOOL)isAllowed;

- (void)routerTableCellWillBeginEditingValue;

- (void)routerTableCellDidEndEditingValue;

@end
