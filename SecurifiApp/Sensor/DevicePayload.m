//
//  DevicePayload.m
//  SecurifiApp
//
//  Created by Masood on 22/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "DevicePayload.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "NotificationPreferences.h"
#import "Network.h"
#import "NetworkState.h"

@implementation DevicePayload

+ (void)deviceListCommand{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    GenericCommand *genericCmd = [GenericCommand requestSensorDeviceList:toolkit.currentAlmond.almondplusMAC];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
}

+(void)getSensorIndexUpdate:(GenericIndexValue*)genericIndexValue mii:(int)mii{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:UPDATE_DEVICE_INDEX forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:D_ID];
    [payload setValue:@(genericIndexValue.index).stringValue forKey:INDEX];
    [payload setValue:genericIndexValue.genericValue.toggleValue forKey:VALUE];
    [payload setValue:toolkit.currentAlmond.almondplusMAC forKey:ALMONDMAC];
    
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_REQUEST];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
}

//have to combile both methods
+(void)getSensorIndexUpdatePayloadForGenericProperty:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:UPDATE_DEVICE_INDEX forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:D_ID];
    [payload setValue:@(genericIndexValue.index).stringValue forKey:INDEX];
    [payload setValue:value forKey:VALUE];
    
    [payload setValue:toolkit.currentAlmond.almondplusMAC forKey:ALMONDMAC];
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_REQUEST];
    [toolkit asyncSendToNetwork:genericCmd];
}

+(void)getNameLocationChange:(GenericIndexValue*)genericIndexValue mii:(int)mii value:(NSString*)value{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
//    Device *device = [Device getDeviceForID:genericIndexValue.deviceID];
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    DeviceCommandType deviceCmdType = genericIndexValue.genericIndex.commandType;
    [payload setValue:@(mii).stringValue forKey:MOBILE_INTERNAL_INDEX];
    [payload setValue:UPDATE_DEVICE_NAME forKey:@"CommandType"];
    [payload setValue:@(genericIndexValue.deviceID).stringValue forKey:D_ID];
    
    if(deviceCmdType == DeviceCommand_UpdateDeviceName){
        [payload setValue:value forKey:INDEX_NAME];//will replace by @"Name"
    }
    
    else{
        [payload setValue:value forKey:LOCATION];
    }
    
    [payload setValue:toolkit.currentAlmond.almondplusMAC forKey:ALMONDMAC];
    
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_UPDATE_REQUEST];
    [toolkit asyncSendToNetwork:genericCmd];
}

+ (void)sensorDidChangeNotificationSetting:(SFINotificationMode)newMode deviceID:(int)deviceID mii:(int)mii{
    //Send command to set notification
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    Device *device = [Device getDeviceForID:deviceID];
    NSArray *notificationDeviceSettings = [device updateNotificationMode:newMode deviceValue:device.knownValues];
    
    NSString *action = (newMode == SFINotificationMode_off) ? kSFINotificationPreferenceChangeActionDelete : kSFINotificationPreferenceChangeActionAdd;
    
    [self asyncRequestNotificationPreferenceChange:toolkit.currentAlmond.almondplusMAC deviceList:notificationDeviceSettings forAction:action mii:mii];
}

+ (void)asyncRequestNotificationPreferenceChange:(NSString *)almondMAC deviceList:(NSArray *)deviceList forAction:(NSString *)action mii:(int)mii{
    if (almondMAC == nil) {
        NSLog(@"asyncRequestRegisterForNotification : almond MAC is nil");
        return;
    }
    
    NotificationPreferences *req = [NotificationPreferences new];
    req.action = action;
    req.almondMAC = almondMAC;
    req.userID = [[SecurifiToolkit sharedInstance] loginEmail];
    req.preferenceCount = (int) [deviceList count];
    req.notificationDeviceList = deviceList;
    req.internalIndex = @(mii).stringValue;
    // Use this as a state holder so we can get access to the actual NotificationPreferences when processing the response.
    // This is a work-around measure until cloud dynamic updates are working; we keep track of the last mode change request and
    // update internal state on receipt of a confirmation from the cloud; normally, we would rely on the
    // dynamic update to inform us of actual new state.
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        [aNetwork.networkState markExpirableRequest:ExpirableCommandType_notificationPreferencesChangesRequest namespace:@"notification" genericCommand:aCmd];
        return YES;
    };
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATION_PREF_CHANGE_REQUEST;
    cmd.command = req;
    cmd.networkPrecondition = precondition;
    
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:cmd];
}

@end

/*
 {
 "MobileInternalIndex":"<random key>",
 "CommandType":"UpdateDeviceIndex",
 "ID":"3",
 "Index":"1",
 "Value":"false"
 }
 
 */
