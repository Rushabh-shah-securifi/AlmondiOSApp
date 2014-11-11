//
//  SFIWirelessSettings.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 13/11/13.
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
@property(nonatomic) int index;
@property(nonatomic) NSString *ssid;
@property(nonatomic) NSString *password;
@property(nonatomic) int channel;
@property(nonatomic) NSString *encryptionType;
@property(nonatomic) NSString *security;
@property(nonatomic) NSString *wirelessMode;
@property(nonatomic) int wirelessModeCode;
@property(nonatomic) int countryRegion;
@end
