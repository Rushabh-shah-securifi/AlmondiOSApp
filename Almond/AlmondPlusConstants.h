//
//  Header.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 17/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#ifndef Securifi_Cloud_Header_h
#define Securifi_Cloud_Header_h

#define CLOUD_CONNECTION_TIMEOUT    20
#define CLOUD_CONNECTION_RETRY      5

// UI Notifications
#define UI_ON_PRESENT_LOGOUT_ALL            @"UI_ON_PRESENT_LOGOUT_ALL"
#define UI_ON_PRESENT_ACCOUNTS              @"UI_ON_PRESENT_ACCOUNTS"


#define CURRENT_ALMOND_MAC  @"AlmondMAC"
#define CURRENT_ALMOND_MAC_NAME  @"AlmondMACName"
#define ALMONDLIST_FILENAME @"almondlist"
#define HASH_FILENAME @"hashlist"
#define DEVICELIST_FILENAME  @"devicelist"
#define DEVICEVALUE_FILENAME @"devicevalue"
#define LOG_FILE_NAME  @"AlmondPlusLog.log"
#define SDK_LOG_FILE_NAME  @"AlmondPlusSDKLog.log"
#define COLORS @"colors"
#define COLORCODE @"ColorCode"
#define ALMONDLIST @"AlmondList"
#define SETTINGS_LIST @"Settings"

#define APPLICATION_ID @"1001"
#define REBOOT_COMMAND @"<root><Reboot>1</Reboot></root>"
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
#define GET_BLOCKED_CONTENT_COMMAND @"<root><AlmondBlockedContent action=\"get\">1</AlmondBlockedContent></root>"
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
#define SET @"set"
#define ADD @"add"
#define SET_WIRELESS_SETTINGS_COMMAND @"<root><AlmondWirelessSettings action=\"set\" count=\"%d\"><WirelessSetting index=\"%d\"><SSID>%@</SSID><Password>%@</Password><Channel>%d</Channel><EncryptionType>%@</EncryptionType><Security>%@</Security><WirelessMode>%d</WirelessMode></WirelessSetting></AlmondWirelessSettings></root>"

//PY 271113 - Router Summary
#define GET_WIRELESS_SUMMARY_COMMAND @"<root><AlmondRouterSummary action=\"get\">1</AlmondRouterSummary></root>"

#define ROUTER_SUMMARY @"AlmondRouterSummary"
#define ENABLED @"enabled"
#define ROUTER_UPTIME @"RouterUptime"
#define WIRELESS_SETTINGS_SUMMARY @"AlmondWirelessSettingsSummary"
#define CONNECTED_DEVICES_SUMMARY @"AlmondConnectedDevicesSummary"
#define BLOCKED_MAC_SUMMARY @"AlmondBlockedMACSummary"
#define BLOCKED_CONTENT_SUMMARY @"AlmondBlockedContentSummary"

#define STATE @"STATE"
#define TAMPER @"TAMPER"
#define LOW_BATTERY @"LOW BATTERY"
#define CLOUD_OFFLINE @"Cloud is offline. Please retry later."

#define HELP_URL @"https://connect.securifi.com/help"

#endif
