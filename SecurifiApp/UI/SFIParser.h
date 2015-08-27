//
//  SFIParser.h
//  TestApp
//
//  Created by Priya Yerunkar on 16/08/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFISensor.h"
#import "SFIRouterReboot.h"

@interface SFIParser : NSObject <NSXMLParserDelegate>
@property(nonatomic, retain) NSMutableString *currentNodeContent;
@property(nonatomic, retain) NSMutableArray *sensors;
@property(nonatomic, retain) NSMutableArray *knownValues;
@property(nonatomic, retain) NSXMLParser *parser;
@property(nonatomic, retain) SFIDeviceKnownValues *currentKnownValue;
@property(nonatomic, retain) SFIRouterReboot *routerReboot;
@property(nonatomic, retain) SFIDevicesList *connectedDevices;
@property(nonatomic, retain) NSMutableArray *connectedDevicesArray;
@property(nonatomic, retain) SFIConnectedDevice *currentConnectedDevice;
@property(nonatomic, retain) SFIGenericRouterCommand *genericCommandResponse;

//PY 121113
@property(nonatomic, retain) SFIDevicesList *blockedDevices;
@property(nonatomic, retain) NSMutableArray *blockedDevicesArray;
@property(nonatomic, retain) SFIBlockedDevice *currentBlockedDevice;

//PY 131113
@property(nonatomic, retain) SFIDevicesList *blockedContent;
@property(nonatomic, retain) NSMutableArray *blockedContentArray;
@property(nonatomic, retain) SFIBlockedContent *currentBlockedContent;

@property(nonatomic, retain) SFIDevicesList *wirelessSettings;
@property(nonatomic, retain) NSMutableArray *wirelessSettingsArray;
@property(nonatomic, retain) SFIWirelessSetting *currentWirelessSetting;

//PY 27113 - Router summary
@property(nonatomic, retain) SFIRouterSummary *routerSummary;
@property(nonatomic, retain) NSMutableArray *wirelessSummaryArray;
@property(nonatomic, retain) SFIWirelessSummary *currentWirelessSummary;

+ (SFIGenericRouterCommand *)parseRouterResponse:(GenericCommandResponse *)response;

- (SFIGenericRouterCommand *)loadDataFromString:(NSString *)xmlString;
@end
