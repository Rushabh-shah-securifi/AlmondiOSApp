//
//  SFIParser.m
//  TestApp
//
//  Created by Priya Yerunkar on 16/08/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "SFIParser.h"
#import "AlmondPlusConstants.h"

@implementation SFIParser

@synthesize currentNodeContent, currentSensor, parser, sensors;
@synthesize currentKnownValue, knownValues;
@synthesize genericCommandResponse;
@synthesize connectedDevices, connectedDevicesArray, currentConnectedDevice, routerReboot;
@synthesize blockedDevices, blockedDevicesArray, currentBlockedDevice;
@synthesize blockedContent, blockedContentArray, currentBlockedContent;
@synthesize currentWirelessSetting, wirelessSettings, wirelessSettingsArray;
@synthesize routerSummary, currentWirelessSummary, wirelessSummaryArray;

//TODO: Remove - Dummy
- (NSMutableArray *)loadDataFromXML:(NSString *)xmlFileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:xmlFileName ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    sensors = [[NSMutableArray alloc] init];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    return sensors;
}

- (SFIGenericRouterCommand *)loadDataFromString:(NSString *)xmlString {
    NSData *data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:data];
    genericCommandResponse = [[SFIGenericRouterCommand alloc] init];
    [xmlparser setDelegate:self];
    [xmlparser parse];
    return genericCommandResponse;
}

- (void)parser:(NSXMLParser *)xmlParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    currentNodeContent = [NSMutableString string];

    if ([elementName isEqualToString:REBOOT]) {
        routerReboot = [[SFIRouterReboot alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_REBOOT;
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICES]) {
        connectedDevices = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_CONNECTED_DEVICES;
        [connectedDevices setDeviceCount:[[attributeDict valueForKey:COUNT] unsignedIntValue]];
        self.connectedDevicesArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICE]) {
        self.currentConnectedDevice = [[SFIConnectedDevice alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_MACS]) {
        blockedDevices = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_BLOCKED_MACS;
        [blockedDevices setDeviceCount:[[attributeDict valueForKey:COUNT] unsignedIntValue]];
        self.blockedDevicesArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_MAC]) {
        self.currentBlockedDevice = [[SFIBlockedDevice alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT]) {
        blockedContent = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_BLOCKED_CONTENT;
        [blockedDevices setDeviceCount:[[attributeDict valueForKey:COUNT] unsignedIntValue]];
        self.blockedContentArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_TEXT]) {
        self.currentBlockedContent = [[SFIBlockedContent alloc] init];
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS]) {
        wirelessSettings = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_WIRELESS_SETTINGS;
        [wirelessSettings setDeviceCount:[[attributeDict valueForKey:COUNT] unsignedIntValue]];
        self.wirelessSettingsArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:WIRELESS_SETTING]) {
        if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SETTINGS) {
            self.currentWirelessSetting = [[SFIWirelessSetting alloc] init];
            [self.currentWirelessSetting setIndex:[[attributeDict valueForKey:INDEX] intValue]];
        }
        else if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
            self.currentWirelessSummary = [[SFIWirelessSummary alloc] init];
            [self.currentWirelessSummary setWirelessIndex:[[attributeDict valueForKey:INDEX] intValue]];
            DLog(@"Enabled: %@", [attributeDict valueForKey:ENABLED]);
            if ([[attributeDict valueForKey:ENABLED] isEqualToString:@"true"]) {
                [self.currentWirelessSummary setEnabledStatus:@"enabled"];
            }
            else {
                [self.currentWirelessSummary setEnabledStatus:@"disabled"];
            }
        }
    }
    else if ([elementName isEqualToString:ROUTER_SUMMARY]) {
        routerSummary = [[SFIRouterSummary alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_WIRELESS_SUMMARY;
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS_SUMMARY]) {
        [routerSummary setWirelessSettingsCount:[[attributeDict valueForKey:COUNT] intValue]];
        self.wirelessSummaryArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICES_SUMMARY]) {
        [routerSummary setConnectedDeviceCount:[[attributeDict valueForKey:COUNT] intValue]];
    }
    else if ([elementName isEqualToString:BLOCKED_MAC_SUMMARY]) {
        [routerSummary setBlockedMACCount:[[attributeDict valueForKey:COUNT] intValue]];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT_SUMMARY]) {
        [routerSummary setBlockedContentCount:[[attributeDict valueForKey:COUNT] intValue]];
    }
}

- (void)parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    DLog(@"End Element: %@", elementName);

    if ([elementName isEqualToString:REBOOT]) {
        [routerReboot setReboot:(unsigned int) [currentNodeContent intValue]];
        genericCommandResponse.command = routerReboot;
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICES]) {
        [connectedDevices setDeviceList:self.connectedDevicesArray];
        genericCommandResponse.command = connectedDevices;
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICE]) {
        [self.connectedDevicesArray addObject:self.currentConnectedDevice];
    }
    else if ([elementName isEqualToString:NAME]) {
        self.currentConnectedDevice.name = currentNodeContent;
    }
    else if ([elementName isEqualToString:IP]) {
        self.currentConnectedDevice.deviceIP = currentNodeContent;
    }
    else if ([elementName isEqualToString:MAC]) {
        self.currentConnectedDevice.deviceMAC = currentNodeContent; //[currentNodeContent uppercaseString];
    }
    else if ([elementName isEqualToString:BLOCKED_MAC]) {
        self.currentBlockedDevice.deviceMAC = currentNodeContent;
        [self.blockedDevicesArray addObject:self.currentBlockedDevice];
    }
    else if ([elementName isEqualToString:BLOCKED_MACS]) {
        [blockedDevices setDeviceList:self.blockedDevicesArray];
        genericCommandResponse.command = blockedDevices;
    }
    else if ([elementName isEqualToString:BLOCKED_TEXT]) {
        self.currentBlockedContent.blockedText = currentNodeContent;
        [self.blockedContentArray addObject:self.currentBlockedContent];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT]) {
        [blockedContent setDeviceList:self.blockedContentArray];
        genericCommandResponse.command = blockedContent;
    }
    else if ([elementName isEqualToString:SSID]) {
        if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SETTINGS) {
            self.currentWirelessSetting.ssid = currentNodeContent;
        }
        else if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
            self.currentWirelessSummary.ssid = currentNodeContent;
        }
    }
    else if ([elementName isEqualToString:WIRELESS_PASSWORD]) {
        self.currentWirelessSetting.password = currentNodeContent;
    }
    else if ([elementName isEqualToString:CHANNEL]) {
        self.currentWirelessSetting.channel = [currentNodeContent intValue];
    }
    else if ([elementName isEqualToString:ENCRYPTION_TYPE]) {
        self.currentWirelessSetting.encryptionType = currentNodeContent;
    }
    else if ([elementName isEqualToString:SECURITY]) {
        self.currentWirelessSetting.security = currentNodeContent;
    }
    else if ([elementName isEqualToString:WIRELESS_MODE]) {
        self.currentWirelessSetting.wirelessMode = currentNodeContent;
    }
    else if ([elementName isEqualToString:COUNTRY_REGION]) {
        self.currentWirelessSetting.countryRegion = [currentNodeContent intValue];
    }
    else if ([elementName isEqualToString:WIRELESS_SETTING]) {
        if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SETTINGS) {
            [self.wirelessSettingsArray addObject:self.currentWirelessSetting];
        }//PY 271113 - Router Summary
        else if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
            [self.wirelessSummaryArray addObject:self.currentWirelessSummary];
        }
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS]) {
        [wirelessSettings setDeviceList:self.wirelessSettingsArray];
        genericCommandResponse.command = wirelessSettings;
    }
        //PY 271113 - Router Summary
    else if ([elementName isEqualToString:WIRELESS_SETTINGS_SUMMARY]) {
        [routerSummary setWirelessSummary:self.wirelessSummaryArray];
    }
    else if ([elementName isEqualToString:ROUTER_UPTIME]) {
        [routerSummary setRouterUptime:currentNodeContent];
    }
        //PY 051114 - Router Firmware Version
    else if ([elementName isEqualToString:FIRMWARE_VERSION]) {
        [routerSummary setFirmwareVersion:currentNodeContent];
    }
    else if ([elementName isEqualToString:ROUTER_SUMMARY]) {
        genericCommandResponse.command = routerSummary;
    }
}

- (void)parser:(NSXMLParser *)xmlParser foundCharacters:(NSString *)string {
    currentNodeContent = (NSMutableString *) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
