//
//  SFIWirelessSettings.h
//  Securifi Cloud
//
//  Created by Securifi-Mac2 on 13/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIWirelessSetting : NSObject
//<AlmondWirelessSettings index="1">
//<SSID>AlmondNetwork</SSID>
//<Password>1234567890</Password>
//<Channel>1</Channel>
//<EncryptionType>AES</EncryptionType>
//<Security>WPA2PSK</Security>
//<WirelessMode>802.11bgn</WirelessMode>
//<CountryRegion>0</CountryRegion>
//</AlmondWirelessSettings>
@property int index;
@property (nonatomic, retain) NSString* ssid;
@property (nonatomic, retain) NSString* password;
@property int channel;
@property (nonatomic, retain) NSString* encryptionType;
@property (nonatomic, retain) NSString* security;
@property (nonatomic, retain) NSString* wirelessMode;
@property int wirelessModeCode;
@property int countryRegion;
@end
