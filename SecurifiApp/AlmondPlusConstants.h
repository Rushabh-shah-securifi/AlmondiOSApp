//
//  Header.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#ifndef Securifi_Cloud_Header_h
#define Securifi_Cloud_Header_h

#define CLOUD_CONNECTION_RETRY      10

// UI Notifications
#define UI_ON_PRESENT_LOGOUT_ALL            @"UI_ON_PRESENT_LOGOUT_ALL"
#define UI_ON_PRESENT_ACCOUNTS              @"UI_ON_PRESENT_ACCOUNTS"

#define ALMONDLIST_FILENAME @"almondlist"
#define HASH_FILENAME @"hashlist"
#define DEVICELIST_FILENAME  @"devicelist"
#define DEVICEVALUE_FILENAME @"devicevalue"
#define LOG_FILE_NAME  @"AlmondPlusLog.log"
#define SDK_LOG_FILE_NAME  @"AlmondPlusSDKLog.log"

#define ALMONDLIST @"AlmondList"
#define SETTINGS_LIST @"Settings"

#define APPLICATION_ID @"1001"
#define GET_CONNECTED_DEVICE_COMMAND @"<root><AlmondConnectedDevices action=\"get\">1</AlmondConnectedDevices></root>"
#define REBOOT @"Reboot"
#define COUNT @"count"
#define CONNECTED_DEVICES @"AlmondConnectedDevices"
#define CONNECTED_DEVICE @"ConnectedDevice"
#define NAME @"Name"
#define IP @"IP"
#define MAC @"MAC"
#define NO_ALMOND @"NO ALMOND"

//PY 121113
#define GET_BLOCKED_DEVICE_COMMAND @"<root><AlmondBlockedMACs action=\"get\">1</AlmondBlockedMACs></root>"
#define BLOCKED_MACS @"AlmondBlockedMACs"
#define BLOCKED_MAC @"BlockedMAC"

//PY 131113
#define BLOCKED_CONTENT @"AlmondBlockedContent"
#define BLOCKED_TEXT @"BlockedText"

#define GET_WIRELESS_SETTINGS_COMMAND @"<root><AlmondWirelessSettings action=\"get\">1</AlmondWirelessSettings></root>"
#define WIRELESS_SETTINGS @"AlmondWirelessSettings"
#define WIRELESS_SETTING @"WirelessSetting"
#define SSID @"SSID"
#define WIRELESS_PASSWORD @"Password"
#define CHANNEL @"Channel"
#define ENCRYPTION_TYPE @"EncryptionType"
#define SECURITY @"Security"
#define WIRELESS_MODE @"WirelessMode"
#define COUNTRY_REGION @"CountryRegion"
#define INDEX @"index"
#define ACTION @"action"

//PY 271113 - Router Summary
#define GET_WIRELESS_SUMMARY_COMMAND @"<root><AlmondRouterSummary action=\"get\">1</AlmondRouterSummary></root>"

#define ROUTER_SUMMARY @"AlmondRouterSummary"
#define ENABLED @"enabled"
#define ROUTER_UPTIME @"RouterUptime"
#define WIRELESS_SETTINGS_SUMMARY @"AlmondWirelessSettingsSummary"
#define CONNECTED_DEVICES_SUMMARY @"AlmondConnectedDevicesSummary"
#define BLOCKED_MAC_SUMMARY @"AlmondBlockedMACSummary"
#define BLOCKED_CONTENT_SUMMARY @"AlmondBlockedContentSummary"
#define FIRMWARE_VERSION @"FirmwareVersion"

#define ACCOUNT_ACTIVATION_NOTIFICATION @"AccountActivicationNotification"
#define PUSH_NOTIFICATION_TOKEN @"PushNotificationToken"
#define PUSH_NOTIFICATION_STATUS @"PushNotificationStatus"

#endif
