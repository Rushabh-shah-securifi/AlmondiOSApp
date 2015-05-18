//
//  SFIParser.m
//  TestApp
//
//  Created by Priya Yerunkar on 16/08/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "SFIParser.h"
#import "AlmondPlusConstants.h"

#define ROUTER_SEND_LOGS_RESPONSE   @"SendLogsResponse"
#define ROUTER_SEND_LOGS_SUCCESS    @"success"
#define ROUTER_SEND_LOGS_REASON     @"Reason"


@implementation SFIParser

@synthesize currentNodeContent, currentSensor, parser, sensors;
@synthesize currentKnownValue, knownValues;
@synthesize genericCommandResponse;
@synthesize connectedDevices, connectedDevicesArray, currentConnectedDevice, routerReboot;
@synthesize blockedDevices, blockedDevicesArray, currentBlockedDevice;
@synthesize blockedContent, blockedContentArray, currentBlockedContent;
@synthesize currentWirelessSetting, wirelessSettings, wirelessSettingsArray;
@synthesize routerSummary, currentWirelessSummary, wirelessSummaryArray;

+ (SFIGenericRouterCommand *)parseRouterResponse:(GenericCommandResponse *)response {
    //todo push all of this parsing and manipulation into the parser or SFIGenericRouterCommand!

//    DLog(@"Response Data: %@", response.genericData);
//    DLog(@"Decoded Data: %@", response.decodedData);

    NSData *decoded_data = [response.decodedData copy];
//    DLog(@"Data: %@", decoded_data);

    NSMutableData *genericData = [[NSMutableData alloc] init];
    [genericData appendData:decoded_data];

    unsigned int expectedDataLength;
    unsigned int commandData;

    [genericData getBytes:&expectedDataLength range:NSMakeRange(0, 4)];
    [genericData getBytes:&commandData range:NSMakeRange(4, 4)];

    //Remove 8 bytes from received command
    [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

    NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];

    SFIParser *sfiParser = [SFIParser new];
    return [sfiParser loadDataFromString:decodedString];
}

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
        connectedDevices.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.connectedDevicesArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICE]) {
        self.currentConnectedDevice = [[SFIConnectedDevice alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_MACS]) {
        blockedDevices = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_BLOCKED_MACS;
        blockedDevices.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.blockedDevicesArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_MAC]) {
        self.currentBlockedDevice = [[SFIBlockedDevice alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT]) {
        blockedContent = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_BLOCKED_CONTENT;
        blockedDevices.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.blockedContentArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:BLOCKED_TEXT]) {
        self.currentBlockedContent = [[SFIBlockedContent alloc] init];
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS]) {
        wirelessSettings = [[SFIDevicesList alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_WIRELESS_SETTINGS;
        wirelessSettings.deviceCount = (unsigned int) [[attributeDict valueForKey:COUNT] intValue];
        self.wirelessSettingsArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:WIRELESS_SETTING]) {
        if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SETTINGS) {
            self.currentWirelessSetting = [[SFIWirelessSetting alloc] init];
            self.currentWirelessSetting.index = [[attributeDict valueForKey:INDEX] intValue];;
            self.currentWirelessSetting.enabled = [[attributeDict valueForKey:ENABLED] isEqualToString:@"true"];;
        }
        else if (genericCommandResponse.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
            self.currentWirelessSummary = [[SFIWirelessSummary alloc] init];
            self.currentWirelessSummary.wirelessIndex = [[attributeDict valueForKey:INDEX] intValue];;
            self.currentWirelessSummary.enabled = [[attributeDict valueForKey:ENABLED] isEqualToString:@"true"];;
        }
    }
    else if ([elementName isEqualToString:ROUTER_SUMMARY]) {
        routerSummary = [[SFIRouterSummary alloc] init];
        genericCommandResponse.commandType = SFIGenericRouterCommandType_WIRELESS_SUMMARY;
    }
    else if ([elementName isEqualToString:WIRELESS_SETTINGS_SUMMARY]) {
        routerSummary.wirelessSettingsCount = [[attributeDict valueForKey:COUNT] intValue];
        self.wirelessSummaryArray = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:CONNECTED_DEVICES_SUMMARY]) {
        routerSummary.connectedDeviceCount = [[attributeDict valueForKey:COUNT] intValue];
    }
    else if ([elementName isEqualToString:BLOCKED_MAC_SUMMARY]) {
        routerSummary.blockedMACCount = [[attributeDict valueForKey:COUNT] intValue];
    }
    else if ([elementName isEqualToString:BLOCKED_CONTENT_SUMMARY]) {
        routerSummary.blockedContentCount = [[attributeDict valueForKey:COUNT] intValue];
    }
    else if ([elementName isEqualToString:ROUTER_SEND_LOGS_RESPONSE]) {
        genericCommandResponse.commandType = SFIGenericRouterCommandType_SEND_LOGS_RESPONSE;
        genericCommandResponse.commandSuccess = [[attributeDict valueForKey:ROUTER_SEND_LOGS_SUCCESS] isEqualToString:@"true"];
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
        self.currentWirelessSetting.countryRegion = currentNodeContent;
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
        [routerSummary setWirelessSummaries:self.wirelessSummaryArray];
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
    else if ([elementName isEqualToString:ROUTER_SEND_LOGS_REASON]) {
        genericCommandResponse.responseMessage = currentNodeContent;
    }
}

- (void)parser:(NSXMLParser *)xmlParser foundCharacters:(NSString *)string {
    NSString *cleaned = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [currentNodeContent appendString:cleaned];
}

@end
