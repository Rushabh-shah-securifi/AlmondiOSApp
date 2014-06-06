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

-(SFIGenericRouterCommand *)loadDataFromString:(NSString*)xmlString{
    NSData* data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser* xmlparser = [[NSXMLParser alloc] initWithData: data];
    genericCommandResponse = [[SFIGenericRouterCommand alloc]init];
    [xmlparser setDelegate:self];
    [xmlparser parse];
    return genericCommandResponse;
}

- (void) parser:(NSXMLParser *)xmlParser didStartElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentNodeContent = [NSMutableString string];
    //START TODO: Remove - Dummy
    if ([elementname isEqualToString:@"Sensor"])
    {
        currentSensor = [SFISensor alloc];
        currentSensor.type = [attributeDict valueForKey:@"type"];
    }
    if ([elementname isEqualToString:@"ValueVariables"]){
        currentSensor.valueCount = [[attributeDict valueForKey:@"Count"] unsignedIntValue];
        if(currentSensor.valueCount!=0){
            knownValues = [[NSMutableArray alloc]init];
        }
    }
    
    if ([elementname isEqualToString:@"LastKnownValue"])
    {
        currentKnownValue = [SFIDeviceKnownValues alloc];
        currentKnownValue.index = [[attributeDict valueForKey:@"Index"] unsignedIntValue];
        currentKnownValue.valueName = [attributeDict valueForKey:@"Name"];
    }
    //END TODO: Remove - Dummy
    
    if ([elementname isEqualToString:REBOOT])
    {
        routerReboot = [[SFIRouterReboot alloc]init];
        genericCommandResponse.commandType = 1;
    }else if ([elementname isEqualToString:CONNECTED_DEVICES])
    {
        connectedDevices = [[SFIDevicesList alloc]init];
        genericCommandResponse.commandType = 2;
        [connectedDevices setDeviceCount:[[attributeDict valueForKey:COUNT] unsignedIntValue]];
        self.connectedDevicesArray = [[NSMutableArray alloc]init];
    }else if ([elementname isEqualToString:CONNECTED_DEVICE])
    {
        self.currentConnectedDevice = [[SFIConnectedDevice alloc]init];
    }
    //PY 121113 - Blocked Device
    else if ([elementname isEqualToString:BLOCKED_MACS])
    {
        blockedDevices = [[SFIDevicesList alloc]init];
        genericCommandResponse.commandType = 3;
        [blockedDevices setDeviceCount:[[attributeDict valueForKey:COUNT]unsignedIntValue]];
        self.blockedDevicesArray = [[NSMutableArray alloc]init];
    }else if ([elementname isEqualToString:BLOCKED_MAC])
    {
        self.currentBlockedDevice = [[SFIBlockedDevice alloc]init];
    }
    
    //PY 131113 - Blocked Content
    else if ([elementname isEqualToString:BLOCKED_CONTENT])
    {
        blockedContent = [[SFIDevicesList alloc]init];
        genericCommandResponse.commandType = 5;
        [blockedDevices setDeviceCount:[[attributeDict valueForKey:COUNT]unsignedIntValue]];
        self.blockedContentArray = [[NSMutableArray alloc]init];
    }else if ([elementname isEqualToString:BLOCKED_TEXT])
    {
        self.currentBlockedContent = [[SFIBlockedContent alloc]init];
    }
    
    //PY 131113 - Wireless Settings
    else if ([elementname isEqualToString:WIRELESS_SETTINGS])
    {
        wirelessSettings = [[SFIDevicesList alloc]init];
        genericCommandResponse.commandType = 7;
        [wirelessSettings setDeviceCount:[[attributeDict valueForKey:COUNT]unsignedIntValue]];
        self.wirelessSettingsArray = [[NSMutableArray alloc]init];
    }else if ([elementname isEqualToString:WIRELESS_SETTING])
    {
        if(genericCommandResponse.commandType == 7){
            self.currentWirelessSetting = [[SFIWirelessSetting alloc]init];
            [self.currentWirelessSetting setIndex:[[attributeDict valueForKey:INDEX] intValue]];
        }
        //PY 271113 - Router Summary
        else if(genericCommandResponse.commandType == 9){
            self.currentWirelessSummary = [[SFIWirelessSummary alloc]init];
            [self.currentWirelessSummary setWirelessIndex:[[attributeDict valueForKey:INDEX] intValue]];
            NSLog(@"Enabled: %@",[attributeDict valueForKey:ENABLED] );
            if([[attributeDict valueForKey:ENABLED] isEqualToString:@"true"]){
                [self.currentWirelessSummary setEnabledStatus:@"enabled"];
            }else{
                [self.currentWirelessSummary setEnabledStatus:@"disabled"];
                
            }
        }
    }
    //PY 271113 - Router Summary
    else if ([elementname isEqualToString:ROUTER_SUMMARY])
    {
        routerSummary = [[SFIRouterSummary alloc]init];
        genericCommandResponse.commandType = 9;
    }else if ([elementname isEqualToString:WIRELESS_SETTINGS_SUMMARY])
    {
        [routerSummary setWirelessSettingsCount:[[attributeDict valueForKey:COUNT] intValue]];
        self.wirelessSummaryArray = [[NSMutableArray alloc]init];
    }else if ([elementname isEqualToString:CONNECTED_DEVICES_SUMMARY])
    {
        [routerSummary setConnectedDeviceCount:[[attributeDict valueForKey:COUNT] intValue]];
    }else if ([elementname isEqualToString:BLOCKED_MAC_SUMMARY])
    {
        [routerSummary setBlockedMACCount:[[attributeDict valueForKey:COUNT] intValue]];
    }else if ([elementname isEqualToString:BLOCKED_CONTENT_SUMMARY])
    {
        [routerSummary setBlockedContentCount:[[attributeDict valueForKey:COUNT] intValue]];
    }
}

- (void) parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementname namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"End Element: %@",elementname);
    //START TODO: Remove - Dummy
    if ([elementname isEqualToString:@"Id"])
    {
        currentSensor.sensorId = [currentNodeContent intValue];
    }
    if ([elementname isEqualToString:@"Name"])
    {
        currentSensor.name = currentNodeContent;
    }
    if ([elementname isEqualToString:@"Status"])
    {
        currentSensor.status = [currentNodeContent intValue];
    }
    if ([elementname isEqualToString:@"DeviceType"])
    {
        currentSensor.deviceType = [currentNodeContent intValue];
    }
    if ([elementname isEqualToString:@"LastKnownValue"]){
        currentKnownValue.value = currentNodeContent;
        [knownValues addObject:currentKnownValue];
        //currentKnownValue = nil;
        
    }
    if ([elementname isEqualToString:@"ValueVariables"])
    {
        currentSensor.knownValues = knownValues;
        //knownValues = nil;
    }
    if ([elementname isEqualToString:@"Sensor"])
    {
        [sensors addObject:currentSensor];
        currentSensor = nil;
        currentNodeContent = nil;
    }
    //END TODO: Remove - Dummy
    
    
    if ([elementname isEqualToString:REBOOT])
    {
        [routerReboot setReboot:(unsigned int) [currentNodeContent intValue]];
        genericCommandResponse.command = routerReboot;
    }else if ([elementname isEqualToString:CONNECTED_DEVICES])
    {
        [connectedDevices setDeviceList:self.connectedDevicesArray];
        genericCommandResponse.command = connectedDevices;
    }else if ([elementname isEqualToString:CONNECTED_DEVICE])
    {
        [self.connectedDevicesArray addObject:self.currentConnectedDevice];
    }else if ([elementname isEqualToString:NAME])
    {
        self.currentConnectedDevice.name = currentNodeContent;
    }else if ([elementname isEqualToString:IP])
    {
        self.currentConnectedDevice.deviceIP = currentNodeContent;
    }else if ([elementname isEqualToString:MAC])
    {
        self.currentConnectedDevice.deviceMAC = currentNodeContent; //[currentNodeContent uppercaseString];
    }
    //PY121113 - Blocked Device - GET
    else if ([elementname isEqualToString:BLOCKED_MAC])
    {
        self.currentBlockedDevice.deviceMAC = currentNodeContent;
        [self.blockedDevicesArray addObject:self.currentBlockedDevice];
    }else if ([elementname isEqualToString:BLOCKED_MACS])
    {
        [blockedDevices setDeviceList:self.blockedDevicesArray];
        genericCommandResponse.command = blockedDevices;
    }
    
    //PY131113 - Blocked Content - GET
    else if ([elementname isEqualToString:BLOCKED_TEXT])
    {
        self.currentBlockedContent.blockedText = currentNodeContent;
        [self.blockedContentArray addObject:self.currentBlockedContent];
    }else if ([elementname isEqualToString:BLOCKED_CONTENT])
    {
        [blockedContent setDeviceList:self.blockedContentArray];
        genericCommandResponse.command = blockedContent;
    }
    
    //PY131113 - Wireless Settings - GET
    else if ([elementname isEqualToString:SSID])
    {
        if(genericCommandResponse.commandType == 7){
            self.currentWirelessSetting.ssid = currentNodeContent;
        }//PY 271113 - Router Summary
        else if(genericCommandResponse.commandType == 9){
            self.currentWirelessSummary.ssid = currentNodeContent;
        }
    }else if ([elementname isEqualToString:WIRELESS_PASSWORD])
    {
        self.currentWirelessSetting.password = currentNodeContent;
    }else if ([elementname isEqualToString:CHANNEL])
    {
        self.currentWirelessSetting.channel = [currentNodeContent intValue];
    }else if ([elementname isEqualToString:ENCRYPTION_TYPE])
    {
        self.currentWirelessSetting.encryptionType = currentNodeContent;
    }else if ([elementname isEqualToString:SECURITY])
    {
        self.currentWirelessSetting.security = currentNodeContent;
    }
    else if ([elementname isEqualToString:WIRELESS_MODE])
    {
        self.currentWirelessSetting.wirelessMode = currentNodeContent;
    }
    else if ([elementname isEqualToString:COUNTRY_REGION])
    {
        self.currentWirelessSetting.countryRegion = [currentNodeContent intValue];
    }
    else if ([elementname isEqualToString:WIRELESS_SETTING])
    {
        if(genericCommandResponse.commandType == 7){
            [self.wirelessSettingsArray addObject:self.currentWirelessSetting];
        }//PY 271113 - Router Summary
        else if(genericCommandResponse.commandType == 9){
            [self.wirelessSummaryArray addObject:self.currentWirelessSummary];
        }
    }else if ([elementname isEqualToString:WIRELESS_SETTINGS])
    {
        [wirelessSettings setDeviceList:self.wirelessSettingsArray];
        genericCommandResponse.command = wirelessSettings;
    }
    //PY 271113 - Router Summary
    else if ([elementname isEqualToString:WIRELESS_SETTINGS_SUMMARY])
    {
        [routerSummary setWirelessSettings:self.wirelessSummaryArray];
    }else if ([elementname isEqualToString:ROUTER_UPTIME])
    {
        [routerSummary setRouterUptime:currentNodeContent];
    }else if ([elementname isEqualToString:ROUTER_SUMMARY]){
        genericCommandResponse.command = routerSummary;
    }
}

- (void) parser:(NSXMLParser *)xmlParser foundCharacters:(NSString *)string
{
    currentNodeContent = (NSMutableString *) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
