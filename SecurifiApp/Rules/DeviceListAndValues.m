//
//  DeviceListAndValues.m
//  Tableviewcellpratic
//
//  Created by Masood on 29/10/15.
//  Copyright © 2015 Securifi-Mac2. All rights reserved.
//

#import "DeviceListAndValues.h"
#import "SecurifiToolkit/SFIDeviceKnownValues.h"
#import "SecurifiToolkit/SFIDeviceValue.h"
#import "SecurifiToolkit/SFIDevice.h"


@implementation DeviceListAndValues

-(SFIDevice *) storeDeviceData:(unsigned int)deviceType_dummy deviceType:(int)devicetype deviceID:(int)deviceid OZWNode:(NSString *)ozwnode
                   zigBeeEUI64:(NSString *) zigbeeeui64 zigBeeShortID:(NSString*)zigbeeshortid associationTimestamp:(NSString*)associationtimestamp
              deviceTechnology:(int)devicetechnology notificationMode:(int)notificationmode almondMAC:(NSString*)almondmac
             allowNotification:(NSString*)allownotification location:(NSString*)location valueCount:(int)valuecount
                deviceFunction:(NSString*)devicefunction deviceTypeName:(NSString*)devicetypename friendlyDeviceType:(NSString*)friendlydevicetype deviceName:(NSString*)devicename


{
    SFIDevice *device=[[SFIDevice alloc]init];
    
    device.deviceType=devicetype;
    device.deviceID=deviceid;
    device.OZWNode=ozwnode;
    device.zigBeeEUI64=zigbeeeui64;
    device.zigBeeShortID=zigbeeshortid;
    device.associationTimestamp=associationtimestamp;
    device.deviceTechnology=devicetechnology;
    device.notificationMode=notificationmode;
    device.almondMAC=almondmac;
    device.allowNotification=allownotification;
    device.location=location;
    device.valueCount=valuecount;
    device.deviceFunction=devicefunction;
    device.deviceTypeName=devicetypename;
    device.friendlyDeviceType=friendlydevicetype;
    device.deviceName=devicename;
    
    return device;
}



-(NSMutableArray*)addDevice{
    SFIDevice *deviceswitch_1=[[SFIDevice alloc]init];
    deviceswitch_1 =[self storeDeviceData:1234 deviceType:SFIDeviceType_BinarySwitch_1 deviceID:1 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Binary Switch" friendlyDeviceType:@"zeewave" deviceName:@"Switch Binary" ];
    
    
    SFIDevice *switchMultiLevel_2=[[SFIDevice alloc]init];
    switchMultiLevel_2 =[self storeDeviceData:1234 deviceType:SFIDeviceType_MultiLevelSwitch_2 deviceID:2 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Multilevel Switch" friendlyDeviceType:@"zeewave" deviceName:@"switchMultiLevel" ];
    
    
    SFIDevice *binarySensor_3=[[SFIDevice alloc]init];
    binarySensor_3 =[self storeDeviceData:1234 deviceType:SFIDeviceType_BinarySensor_3 deviceID:3 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Z-wave Door Sensor" friendlyDeviceType:@"zeewave" deviceName:@"binarySensor_3" ];
    
    
    SFIDevice *MultiLevelOnOff_4=[[SFIDevice alloc]init];
    MultiLevelOnOff_4 = [self storeDeviceData:1234 deviceType:SFIDeviceType_MultiLevelOnOff_4 deviceID:4 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:2  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:2 deviceFunction:@"switch" deviceTypeName:@"OnOff Multilevel Switch" friendlyDeviceType:@"BinarySwitch" deviceName:@"OnOffMultilevelSwitch" ];
    
    SFIDevice *doorLock_5=[[SFIDevice alloc]init];
    doorLock_5 =[self storeDeviceData:1234 deviceType:SFIDeviceType_DoorLock_5 deviceID:5 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Z-wave DoorLock" friendlyDeviceType:@"zeewave" deviceName:@"doorLock_5" ];
    
    SFIDevice *Alarm_6=[[SFIDevice alloc]init];
    Alarm_6 =[self storeDeviceData:1234 deviceType:SFIDeviceType_Alarm_6 deviceID:6 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Alarm" friendlyDeviceType:@"zeewave" deviceName:@"Alarm_6" ];
    
    
    SFIDevice *thermostat_07=[[SFIDevice alloc]init];
    thermostat_07 =[self storeDeviceData:1234 deviceType:SFIDeviceType_Thermostat_7 deviceID:7 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Themostat" friendlyDeviceType:@"zeewave" deviceName:@"thermostat_07" ];
    
    SFIDevice *standardCIE_10=[[SFIDevice alloc]init];
    standardCIE_10 =[self storeDeviceData:1234 deviceType:SFIDeviceType_StandardCIE_10 deviceID:10 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"UnKnown Sensor" friendlyDeviceType:@"zeewave" deviceName:@"standardCIE_10" ];
    
    SFIDevice *motionSensor_11=[[SFIDevice alloc]init];
    motionSensor_11 =[self storeDeviceData:1234 deviceType:SFIDeviceType_MotionSensor_11 deviceID:11 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Motion Sensor" friendlyDeviceType:@"zeewave" deviceName:@"motionSensor_11" ];
    
    SFIDevice *contactSwitch_12=[[SFIDevice alloc]init];
    contactSwitch_12 =[self storeDeviceData:1234 deviceType:SFIDeviceType_ContactSwitch_12 deviceID:12 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Door Sensor" friendlyDeviceType:@"zeewave" deviceName:@"contactSwitch_12" ];
    
    SFIDevice *fireSensor_13=[[SFIDevice alloc]init];
    fireSensor_13 =[self storeDeviceData:1234 deviceType:SFIDeviceType_FireSensor_13 deviceID:13 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Fire Sensor" friendlyDeviceType:@"zeewave" deviceName:@"fireSensor_13" ];
    
    SFIDevice *waterSensor_14=[[SFIDevice alloc]init];
    waterSensor_14 =[self storeDeviceData:1234 deviceType:SFIDeviceType_WaterSensor_14 deviceID:14 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Water Sensor" friendlyDeviceType:@"zeewave" deviceName:@"waterSensor_14" ];
    
    SFIDevice *gasSensor_15=[[SFIDevice alloc]init];
    gasSensor_15 =[self storeDeviceData:1234 deviceType:SFIDeviceType_GasSensor_15 deviceID:15 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Gas Sensor" friendlyDeviceType:@"zeewave" deviceName:@"gasSensor_15" ];
    
    
    SFIDevice *keyFob_19=[[SFIDevice alloc]init];
    keyFob_19 =[self storeDeviceData:1234 deviceType:SFIDeviceType_KeyFob_19 deviceID:19 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"KeyFob" friendlyDeviceType:@"zeewave" deviceName:@"keyFob_19" ];
    
    
    SFIDevice *standardWarningDevice_21=[[SFIDevice alloc]init];
    standardWarningDevice_21 =[self storeDeviceData:1234 deviceType:SFIDeviceType_StandardWarningDevice_21 deviceID:21 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Alarm" friendlyDeviceType:@"zeewave" deviceName:@"standardWarningDevice_21" ];
    
    SFIDevice *smartACSwitch_22=[[SFIDevice alloc]init];
    smartACSwitch_22 =[self storeDeviceData:1234 deviceType:SFIDeviceType_SmartACSwitch_22 deviceID:22 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"AC Switch" friendlyDeviceType:@"zeewave" deviceName:@"smartACSwitch_22" ];
    
    
    SFIDevice *occupancySensor_24=[[SFIDevice alloc]init];
    occupancySensor_24 =[self storeDeviceData:1234 deviceType:SFIDeviceType_OccupancySensor_24 deviceID:24 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Occupancy Sensor" friendlyDeviceType:@"zeewave" deviceName:@"occupancySensor_24" ];
    
    
    SFIDevice *lightSensor_25=[[SFIDevice alloc]init];
    lightSensor_25 =[self storeDeviceData:1234 deviceType:SFIDeviceType_LightSensor_25 deviceID:25 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Light Sensor" friendlyDeviceType:@"zeewave" deviceName:@"lightSensor_25" ];
    
    SFIDevice *windowCovering_26=[[SFIDevice alloc]init];
    windowCovering_26 =[self storeDeviceData:1234 deviceType:SFIDeviceType_WindowCovering_26 deviceID:26 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Window Covering" friendlyDeviceType:@"zeewave" deviceName:@"windowCovering_26" ];
    
    SFIDevice *temperatureSensor_27=[[SFIDevice alloc]init];
    temperatureSensor_27 =[self storeDeviceData:1234 deviceType:SFIDeviceType_TemperatureSensor_27 deviceID:27 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Temperature Sensor" friendlyDeviceType:@"zeewave" deviceName:@"temperatureSensor_27" ];
    
    SFIDevice *zigbeeDoorLock_28=[[SFIDevice alloc]init];
    zigbeeDoorLock_28 =[self storeDeviceData:1234 deviceType:SFIDeviceType_ZigbeeDoorLock_28 deviceID:28 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"ZigbeeDoor Lock" friendlyDeviceType:@"zeewave" deviceName:@"zigbeeDoorLock_28" ];
    
    SFIDevice *colorControl_29=[[SFIDevice alloc]init];
    colorControl_29 =[self storeDeviceData:1234 deviceType:SFIDeviceType_ColorControl_29 deviceID:29 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"ZigBee Temperature Sensor" friendlyDeviceType:@"zeewave" deviceName:@"colorControl_29" ];
    
    
    SFIDevice *colorDimmedLight_32=[[SFIDevice alloc]init];
    colorDimmedLight_32 =[self storeDeviceData:1234 deviceType:SFIDeviceType_ColorDimmableLight_32 deviceID:32 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"ColorDimmable Light" friendlyDeviceType:@"zeewave" deviceName:@"colorDimmedLight_32" ];
    
    SFIDevice *smaokeDetector_36=[[SFIDevice alloc]init];
    smaokeDetector_36 =[self storeDeviceData:1234 deviceType:SFIDeviceType_SmokeDetector_36 deviceID:36 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Z-wave Smoke Sensor" friendlyDeviceType:@"zeewave" deviceName:@"smaokeDetector_36" ];
    
    SFIDevice *floodSensor_37=[[SFIDevice alloc]init];
    floodSensor_37 =[self storeDeviceData:1234 deviceType:SFIDeviceType_FloodSensor_37 deviceID:37 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Z-wave Water Sensor" friendlyDeviceType:@"zeewave" deviceName:@"floodSensor_37" ];
    
    SFIDevice *shockSensor_38=[[SFIDevice alloc]init];
    shockSensor_38 =[self storeDeviceData:1234 deviceType:SFIDeviceType_ShockSensor_38 deviceID:38 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Vibration Sensor" friendlyDeviceType:@"zeewave" deviceName:@"shockSensor_38" ];
    
    SFIDevice *doorSensor_39=[[SFIDevice alloc]init];
    doorSensor_39 =[self storeDeviceData:1234 deviceType:SFIDeviceType_DoorSensor_39 deviceID:39 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Door Sensor" friendlyDeviceType:@"zeewave" deviceName:@"doorSensor_39" ];
    
    SFIDevice *moistureSensor_40=[[SFIDevice alloc]init];
    moistureSensor_40 =[self storeDeviceData:1234 deviceType:SFIDeviceType_MoistureSensor_40 deviceID:40 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Moisture Sensor" friendlyDeviceType:@"zeewave" deviceName:@"moistureSensor_40" ];
    
    SFIDevice *movementSensor_41=[[SFIDevice alloc]init];
    movementSensor_41 =[self storeDeviceData:1234 deviceType:SFIDeviceType_MovementSensor_41 deviceID:41 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Motion Sensor" friendlyDeviceType:@"zeewave" deviceName:@"movementSensor_41" ];
    
    
    SFIDevice *siren_42=[[SFIDevice alloc]init];
    siren_42 =[self storeDeviceData:1234 deviceType:SFIDeviceType_Siren_42 deviceID:42 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Alarm" friendlyDeviceType:@"zeewave" deviceName:@"siren_42" ];
    
    SFIDevice *unknownOnOffModule_44=[[SFIDevice alloc]init];
    unknownOnOffModule_44 =[self storeDeviceData:1234 deviceType:SFIDeviceType_UnknownOnOffModule_44 deviceID:44 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"UnKnown Sensor" friendlyDeviceType:@"zeewave" deviceName:@"unknownOnOffModule_44" ];
    
    SFIDevice *binaryPowerSwitch_45=[[SFIDevice alloc]init];
    binaryPowerSwitch_45 =[self storeDeviceData:1234 deviceType:SFIDeviceType_BinaryPowerSwitch_45 deviceID:45 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Binary Power Switch" friendlyDeviceType:@"zeewave" deviceName:@"binaryPowerSwitch_45" ];
    
    SFIDevice *setPointThermostat_46=[[SFIDevice alloc]init];
    setPointThermostat_46 =[self storeDeviceData:1234 deviceType:SFIDeviceType_SetPointThermostat_46 deviceID:46 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"SetPoint Thermostat" friendlyDeviceType:@"zeewave" deviceName:@"setPointThermostat_46" ];
    
    SFIDevice *hueLamp_48=[[SFIDevice alloc]init];
    hueLamp_48 =[self storeDeviceData:1234 deviceType:SFIDeviceType_HueLamp_48 deviceID:48 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Hue Lamp" friendlyDeviceType:@"zeewave" deviceName:@"hueLamp_48" ];
    
    SFIDevice *MultiSensor_49=[[SFIDevice alloc]init];
    MultiSensor_49 =[self storeDeviceData:1234 deviceType:SFIDeviceType_MultiSensor_49 deviceID:49 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"MultiSensor" friendlyDeviceType:@"zeewave" deviceName:@"MultiSensor_49" ];
    

    SFIDevice *securifiSmartSwitch_50=[[SFIDevice alloc]init];
    securifiSmartSwitch_50 =[self storeDeviceData:1234 deviceType:SFIDeviceType_SecurifiSmartSwitch_50 deviceID:50 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Peanut Switch" friendlyDeviceType:@"zeewave" deviceName:@"securifiSmartSwitch_50" ];
    
    SFIDevice *rollerShutter_52= [[SFIDevice alloc]init];
    rollerShutter_52 = [self storeDeviceData:1234 deviceType:SFIDeviceType_RollerShutter_52 deviceID:52 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"RollerShutter" friendlyDeviceType:@"zeewave" deviceName:@"rollerShutter_52" ];
    
    SFIDevice *garageDoorOpener_53=[[SFIDevice alloc]init];
    garageDoorOpener_53 =[self storeDeviceData:1234 deviceType:SFIDeviceType_GarageDoorOpener_53 deviceID:53 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"Garage Door Opener" friendlyDeviceType:@"zeewave" deviceName:@"garageDoorOpener_53" ];
    
    SFIDevice *ZWtoACIRExtender_54 =[[SFIDevice alloc]init];
    ZWtoACIRExtender_54=[self storeDeviceData:1234 deviceType:SFIDeviceType_ZWtoACIRExtender_54 deviceID:54 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"ZWtoACIRExtender" friendlyDeviceType:@"zeewave" deviceName:@"ZWtoACIRExtender_54" ];
    
    SFIDevice *multisoundSiren_55 =[[SFIDevice alloc]init];
    multisoundSiren_55=[self storeDeviceData:1234 deviceType:SFIDeviceType_MultiSoundSiren_55 deviceID:55 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"MultiSiren" friendlyDeviceType:@"zeewave" deviceName:@"multiSoundSiren" ];
    
    
    SFIDevice *EnergyReader_56 =[[SFIDevice alloc]init];
    EnergyReader_56=[self storeDeviceData:1234 deviceType:SFIDeviceType_EnergyReader_56 deviceID:56 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"EnergyReader" friendlyDeviceType:@"zeewave" deviceName:@"EnergyReader_56" ];
    
    SFIDevice *NestThermostat_57 =[[SFIDevice alloc]init];
    NestThermostat_57=[self storeDeviceData:1234 deviceType:SFIDeviceType_NestThermostat_57 deviceID:57 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"NestThermostat" friendlyDeviceType:@"zeewave" deviceName:@"NestThermostat_57" ];
    
    SFIDevice *NestSmokeDetector_58 =[[SFIDevice alloc]init];
    NestSmokeDetector_58=[self storeDeviceData:1234 deviceType:SFIDeviceType_NestSmokeDetector_58 deviceID:58 OZWNode:@"OZWNode" zigBeeEUI64:@"zigBeeEUI64" zigBeeShortID:@"32" associationTimestamp:@"21" deviceTechnology:1  notificationMode:1  almondMAC:@"251176217041064"  allowNotification:@"yes" location:@"home" valueCount:1 deviceFunction:@"switch" deviceTypeName:@"NestSmokeDetector" friendlyDeviceType:@"zeewave" deviceName:@"NestSmokeDetector_58" ];
    
    NSMutableArray *deviceListArray = [[NSMutableArray alloc] init];
    [deviceListArray addObject:deviceswitch_1];
    [deviceListArray addObject:switchMultiLevel_2];
    [deviceListArray addObject:binarySensor_3];
    [deviceListArray addObject:MultiLevelOnOff_4];
    [deviceListArray addObject:doorLock_5];

    [deviceListArray addObject:Alarm_6];
    [deviceListArray addObject:thermostat_07];
    [deviceListArray addObject:standardCIE_10];
    [deviceListArray addObject:motionSensor_11];
    [deviceListArray addObject:contactSwitch_12];

    [deviceListArray addObject:fireSensor_13];
    [deviceListArray addObject:waterSensor_14];
    [deviceListArray addObject:gasSensor_15];
    [deviceListArray addObject:keyFob_19];
    [deviceListArray addObject:standardWarningDevice_21];

    [deviceListArray addObject:smartACSwitch_22];
    [deviceListArray addObject:occupancySensor_24];
    [deviceListArray addObject:lightSensor_25];
    [deviceListArray addObject:windowCovering_26];
    [deviceListArray addObject:temperatureSensor_27];

    
    [deviceListArray addObject:zigbeeDoorLock_28];
//    [deviceListArray addObject:colorDimmedLight_32];
    [deviceListArray addObject:smaokeDetector_36];
    [deviceListArray addObject:floodSensor_37];
    [deviceListArray addObject:shockSensor_38];

    [deviceListArray addObject:doorSensor_39];
//    [deviceListArray addObject:moistureSensor_40];
    [deviceListArray addObject:movementSensor_41];
    [deviceListArray addObject:siren_42];
    [deviceListArray addObject:unknownOnOffModule_44];

    [deviceListArray addObject:binaryPowerSwitch_45];
    [deviceListArray addObject:setPointThermostat_46];
    [deviceListArray addObject:hueLamp_48];
    [deviceListArray addObject:MultiSensor_49];
    [deviceListArray addObject:securifiSmartSwitch_50];
    
    [deviceListArray addObject:rollerShutter_52];
    [deviceListArray addObject:garageDoorOpener_53];
    [deviceListArray addObject:ZWtoACIRExtender_54];
    [deviceListArray addObject:multisoundSiren_55];
    [deviceListArray addObject:EnergyReader_56];
    [deviceListArray addObject:NestThermostat_57];
    
    return deviceListArray;
}

-(SFIDeviceKnownValues *) createKnownValuesWithIndex:(int)index PropertyType_:(int)propertytype valuetype_:(NSString *)valuetype valuename_:(NSString *)valuename value_:(NSString *)value
{
    SFIDeviceKnownValues *knownvalues=[[SFIDeviceKnownValues alloc]init];
    knownvalues.index=index;
    knownvalues.propertyType=propertytype;
    knownvalues.valueType=valuetype;
    knownvalues.valueName=valuename;
    knownvalues.value=value;
    
    return knownvalues;
    
}

-(SFIDeviceValue *)createDeviceValue:(unsigned int)valueCount deviceID:(unsigned int)deviceid isPresent:(BOOL)ispresent knownValueArray:(NSArray *)knownvaluearray{
    SFIDeviceValue *devicevalue=[[SFIDeviceValue alloc]init];
    devicevalue.valueCount=valueCount;
    devicevalue.deviceID=deviceid;
    devicevalue.isPresent=ispresent;
    [devicevalue replaceKnownDeviceValues:knownvaluearray];
    return devicevalue;
}
-(NSMutableArray*)addDeviceValues{
    //switch binary 1
    SFIDeviceKnownValues *switchbinary1=[[SFIDeviceKnownValues alloc]init];
    switchbinary1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    NSArray *switchbinaryValuesArray=[[NSArray alloc]initWithObjects:switchbinary1,nil];
    SFIDeviceValue *switchbinaryDeviceValue=[[SFIDeviceValue alloc]init];
    switchbinaryDeviceValue=[self createDeviceValue:1 deviceID:1 isPresent:NO knownValueArray:switchbinaryValuesArray];
    
    //switch multilevel 2
    SFIDeviceKnownValues *knownvalues1=[[SFIDeviceKnownValues alloc]init];
    knownvalues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVEL" value_:[NSString stringWithFormat:@"%d",2]];
    NSArray *knownvaluearray=[[NSArray alloc]initWithObjects:knownvalues1, nil];
    SFIDeviceValue *switchMultilevelDeviceValue = [self createDeviceValue:(unsigned int)1 deviceID:(unsigned int)2 isPresent:(BOOL)NO knownValueArray:knownvaluearray];
    
    //sensor binary 3
    SFIDeviceKnownValues *knownvalues2=[[SFIDeviceKnownValues alloc]init];
    knownvalues2 =[self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"true"];
    NSArray *knownvaluearray2=[[NSArray alloc]initWithObjects:knownvalues2 ,nil];
    SFIDeviceValue *sensorBinaryDeviceValue = [self createDeviceValue:1 deviceID:3 isPresent:(BOOL)NO knownValueArray:knownvaluearray2];
    
    //MultiLevelOnOff_4
    SFIDeviceKnownValues *multilevelOnOff1=[[SFIDeviceKnownValues alloc]init];
    switchbinary1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    SFIDeviceKnownValues *multilevelOnOff2=[[SFIDeviceKnownValues alloc]init];
    knownvalues1 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVEL" value_:[NSString stringWithFormat:@"%d",2]];
    NSArray *multiLevelOnOffArray =[[NSArray alloc]initWithObjects: multilevelOnOff1,multilevelOnOff2,nil];
    SFIDeviceValue *multilevelDeviceValue=[self createDeviceValue:2 deviceID:4 isPresent:NO knownValueArray:multiLevelOnOffArray];
    
    //doorLock_5
    SFIDeviceKnownValues *doorLockKnownValues1=[[SFIDeviceKnownValues alloc]init];
    doorLockKnownValues1 =[self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_LOCK_STATE valuetype_:@"STATE" valuename_:@"LOCK_STATE" value_:@"2"];
    SFIDeviceKnownValues *doorLockKnownValues2=[[SFIDeviceKnownValues alloc]init];
    doorLockKnownValues2 =[self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_USER_CODE valuetype_:@"STATE" valuename_:@"LOCK_STATE" value_:@"2"];
    NSArray *doorLockKnownValuesArray=[[NSArray alloc]initWithObjects:doorLockKnownValues1,doorLockKnownValues2 ,nil];
    SFIDeviceValue *doorLockDeviceValue=[self createDeviceValue:2 deviceID:5 isPresent:NO knownValueArray:doorLockKnownValuesArray];
    
    //alarm_6
    SFIDeviceKnownValues *alarmKnownValues1=[[SFIDeviceKnownValues alloc]init];
    alarmKnownValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"RINGING" value_:@"true"];
    SFIDeviceKnownValues *alarmKnownValues2=[[SFIDeviceKnownValues alloc]init];
    alarmKnownValues2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *alarmKnownValuesArray=[[NSArray alloc]initWithObjects:alarmKnownValues1,alarmKnownValues2, nil];
    SFIDeviceValue *alarmDeviceValue=[self createDeviceValue:(int)[alarmKnownValuesArray count] deviceID:6 isPresent:NO knownValueArray:alarmKnownValuesArray];
    
    //device 7 thermostat
    
    SFIDeviceKnownValues *thermoKnowsvalues3=[[SFIDeviceKnownValues alloc]init];
    thermoKnowsvalues3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT SETPOINT COOLING" value_:@"70"];
    SFIDeviceKnownValues *thermoKnowsvalues4=[[SFIDeviceKnownValues alloc]init];
    thermoKnowsvalues4 = [self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT" value_:@"57"];
    SFIDeviceKnownValues *thermoKnowsvalues5=[[SFIDeviceKnownValues alloc]init];
    thermoKnowsvalues5 =[self createKnownValuesWithIndex:5 PropertyType_:SFIDevicePropertyType_THERMOSTAT_MODE valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT" value_:@"Auto"];
    SFIDeviceKnownValues *thermoKnowsvalues7=[[SFIDeviceKnownValues alloc]init];
    thermoKnowsvalues7 = [self createKnownValuesWithIndex:7 PropertyType_:SFIDevicePropertyType_THERMOSTAT_FAN_STATE valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT FAN STAT" value_:@"On"];
    NSArray *thermostatKnowsValuesArray =[[NSArray alloc]initWithObjects: thermoKnowsvalues3,thermoKnowsvalues4,thermoKnowsvalues5,thermoKnowsvalues7,nil];
    SFIDeviceValue *thermodevicevalue=[self createDeviceValue:4 deviceID:7 isPresent:NO knownValueArray:thermostatKnowsValuesArray];
    
    //8,9 is not there
    //standardCIE_10
    
    SFIDeviceKnownValues *standardCIE1=[[SFIDeviceKnownValues alloc]init];
    standardCIE1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *standardCIE2=[[SFIDeviceKnownValues alloc]init];
    standardCIE2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_LOW_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *standardCIE3=[[SFIDeviceKnownValues alloc]init];
    standardCIE3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_TAMPER valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];

    NSArray *standardCIEArray=[[NSArray alloc]initWithObjects:standardCIE1,standardCIE2,standardCIE3, nil];
    SFIDeviceValue *standardCIEValue=[self createDeviceValue:1 deviceID:10 isPresent:NO knownValueArray:standardCIEArray];
    
    //motionSensor_11
    
    SFIDeviceKnownValues *motionSensor1=[[SFIDeviceKnownValues alloc]init];
    SFIDeviceKnownValues *motionSensor2=[[SFIDeviceKnownValues alloc]init];
    SFIDeviceKnownValues *motionSensor3=[[SFIDeviceKnownValues alloc]init];
    motionSensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    motionSensor2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_LOW_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    motionSensor3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_TAMPER valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *motionSensorArray=[[NSArray alloc]initWithObjects:motionSensor1,motionSensor2, motionSensor3,nil];
    SFIDeviceValue *motionSensorValue=[self createDeviceValue:3 deviceID:11 isPresent:NO knownValueArray:motionSensorArray];
    
    //contactSwitch_12
    
    SFIDeviceKnownValues *contactSwitch1=[[SFIDeviceKnownValues alloc]init];
    SFIDeviceKnownValues *contactSwitch2=[[SFIDeviceKnownValues alloc]init];
    SFIDeviceKnownValues *contactSwitch3=[[SFIDeviceKnownValues alloc]init];
    
    contactSwitch1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    contactSwitch2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_LOW_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    contactSwitch3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_TAMPER valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *contactSwitchArray=[[NSArray alloc]initWithObjects:contactSwitch1,contactSwitch2,contactSwitch3, nil];
    SFIDeviceValue *contactSwitchValue=[self createDeviceValue:3 deviceID:12 isPresent:NO knownValueArray:contactSwitchArray];
    
    //firesensor13
    
    SFIDeviceKnownValues *firesensor1=[[SFIDeviceKnownValues alloc]init];
    firesensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *firesensor2=[[SFIDeviceKnownValues alloc]init];
    firesensor2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_LOW_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *firesensor3=[[SFIDeviceKnownValues alloc]init];
    firesensor3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_TAMPER valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    
    NSArray *firesensorArray=[[NSArray alloc]initWithObjects:firesensor1,firesensor2,firesensor3, nil];
    SFIDeviceValue *firesensorValue=[self createDeviceValue:3 deviceID:13 isPresent:NO knownValueArray:firesensorArray];
    
    //waterSensor14
    
    SFIDeviceKnownValues *waterSensor1=[[SFIDeviceKnownValues alloc]init];
    waterSensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *waterSensor2=[[SFIDeviceKnownValues alloc]init];
    waterSensor2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_LOW_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *waterSensor3=[[SFIDeviceKnownValues alloc]init];
    waterSensor3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_TAMPER valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *waterSensorArray=[[NSArray alloc]initWithObjects:waterSensor1,waterSensor2,waterSensor3 ,nil];
    SFIDeviceValue *waterSensorValue=[self createDeviceValue:3 deviceID:14 isPresent:NO knownValueArray:waterSensorArray];
    
    //gasSensor15
    
    SFIDeviceKnownValues *gasSensor1=[[SFIDeviceKnownValues alloc]init];
    gasSensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *gasSensor2=[[SFIDeviceKnownValues alloc]init];
    gasSensor2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_LOW_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *gasSensor3=[[SFIDeviceKnownValues alloc]init];
    gasSensor3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_TAMPER valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *gasSensorArray=[[NSArray alloc]initWithObjects:gasSensor1, gasSensor2,gasSensor3,nil];
    SFIDeviceValue *gasSensorValue=[self createDeviceValue:3 deviceID:15 isPresent:NO knownValueArray:gasSensorArray];
    
    //16,17,18 is not there
    //keyfob_19
    SFIDeviceKnownValues *KeyfobKnownValues=[[SFIDeviceKnownValues alloc]init];
    KeyfobKnownValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_ARMMODE valuetype_:@"STATE" valuename_:@"ARMMODE" value_:@"2"];

    SFIDeviceKnownValues *KeyfobKnownValue2 = [[SFIDeviceKnownValues alloc]init];
    KeyfobKnownValue2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_PANIC_ALARM valuetype_:@"ALARM_STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *KeyfobKnownValue3 = [[SFIDeviceKnownValues alloc]init];
    KeyfobKnownValue3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_EMER_ALARM valuetype_:@"ALARM_STATE" valuename_:@"STATE" value_:@"true"];

    NSArray *keyFobKnownValuesArray=[[NSArray alloc]initWithObjects:KeyfobKnownValues,KeyfobKnownValue2,KeyfobKnownValue3, nil];
    SFIDeviceValue *keyFobDeviceValue=[self createDeviceValue:(int)[keyFobKnownValuesArray count] deviceID:19 isPresent:YES knownValueArray:keyFobKnownValuesArray];
    
    //standardwarning_21
    SFIDeviceKnownValues *WarningdeviceValues=[[SFIDeviceKnownValues alloc]init];
    WarningdeviceValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_ALARM_STATE valuetype_:@"ALARM_STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *WarningdeviceValues2=[[SFIDeviceKnownValues alloc]init];
    WarningdeviceValues2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_LOW_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *WarningdeviceValues3=[[SFIDeviceKnownValues alloc]init];
    WarningdeviceValues3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_TAMPER valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *warningdeviceValuesArray=[[NSArray alloc]initWithObjects:WarningdeviceValues, WarningdeviceValues2,WarningdeviceValues3,nil];
    SFIDeviceValue *warningDeviceValue=[self createDeviceValue:3 deviceID:21 isPresent:NO knownValueArray:warningdeviceValuesArray];
    
    //smartACswitch_22
    SFIDeviceKnownValues *SmartAcdeviceValues=[[SFIDeviceKnownValues alloc]init];
    SmartAcdeviceValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    NSArray *SmartACdeviceValuesArray=[[NSArray alloc]initWithObjects:SmartAcdeviceValues, nil];
    SFIDeviceValue *SmartACDeviceValue=[self createDeviceValue:1 deviceID:22 isPresent:NO knownValueArray:SmartACdeviceValuesArray];
    
    //23 is not there
    //occupancySensor_24
    SFIDeviceKnownValues *occupancydevicevalues1=[[SFIDeviceKnownValues alloc]init];
    occupancydevicevalues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_OCCUPANCY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    SFIDeviceKnownValues *occupancydevicevalues2=[[SFIDeviceKnownValues alloc]init];
    occupancydevicevalues2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"20"];
    SFIDeviceKnownValues *occupancydevicevalues3=[[SFIDeviceKnownValues alloc]init];
    occupancydevicevalues3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_HUMIDITY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"28"];
    SFIDeviceKnownValues *occupancydevicevalues4=[[SFIDeviceKnownValues alloc]init];
    occupancydevicevalues4 = [self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_LOW_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *OccupancyValuesArray=[[NSArray alloc]initWithObjects:occupancydevicevalues1, occupancydevicevalues2,occupancydevicevalues3,occupancydevicevalues4,nil];
    SFIDeviceValue *occupancydevicevalue=[self createDeviceValue:4 deviceID:24 isPresent:NO knownValueArray:OccupancyValuesArray];
    
    //light sensor_25
    
    SFIDeviceKnownValues *lightsensorValues=[[SFIDeviceKnownValues alloc]init];
    lightsensorValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_ILLUMINANCE valuetype_:@"STATE" valuename_:@"ILLUMINANCE" value_:@"true"];
    SFIDeviceKnownValues *lightsensorValues2=[[SFIDeviceKnownValues alloc]init];
    lightsensorValues2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *lightsensordeviceValuesArray=[[NSArray alloc]initWithObjects:lightsensorValues, lightsensorValues2,nil];
    SFIDeviceValue *lightsensorDeviceValue=[[SFIDeviceValue alloc]init];
    lightsensorDeviceValue=[self createDeviceValue:2 deviceID:25 isPresent:NO knownValueArray:lightsensordeviceValuesArray];
    
    //windowcovering_26
    
    SFIDeviceKnownValues *windowcovering=[[SFIDeviceKnownValues alloc]init];
    windowcovering = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *windowcoverdeviceValuesArray=[[NSArray alloc]initWithObjects:windowcovering, nil];
    SFIDeviceValue *windowcoverDeviceValue=[[SFIDeviceValue alloc]init];
    windowcoverDeviceValue=[self createDeviceValue:1 deviceID:26 isPresent:NO knownValueArray:windowcoverdeviceValuesArray];
    
    //temperature sensor27
    
    SFIDeviceKnownValues *temperaturesensor1=[[SFIDeviceKnownValues alloc]init];
    temperaturesensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"STATE" valuename_:@"TEMPERATURE" value_:@"20"];
    SFIDeviceKnownValues *temperaturesensor2=[[SFIDeviceKnownValues alloc]init];
    temperaturesensor2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_HUMIDITY valuetype_:@"PRIMARY ATTRIBUTE" valuename_:@"HUMIDITY" value_:@"42"];
    SFIDeviceKnownValues *temperaturesensor3=[[SFIDeviceKnownValues alloc]init];
    temperaturesensor3 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *temperaturesensordeviceValuesArray=[[NSArray alloc]initWithObjects:temperaturesensor1, temperaturesensor2,temperaturesensor3,nil];
    SFIDeviceValue *temperaturesensorDeviceValue=[self createDeviceValue:3 deviceID:27 isPresent:NO knownValueArray:temperaturesensordeviceValuesArray];
    
    //zigbee door lock28
    
    SFIDeviceKnownValues *zigbeedoorlock1=[[SFIDeviceKnownValues alloc]init];
    zigbeedoorlock1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_LOCK_STATE valuetype_:@"STATE" valuename_:@"LOCK_STATE" value_:@"0"];
    SFIDeviceKnownValues *zigbeedoorlock2=[[SFIDeviceKnownValues alloc]init];
    zigbeedoorlock2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_USER_CODE valuetype_:@"STATE" valuename_:@"LOCK_STATE" value_:nil];
    NSArray *zigbeedeviceValuesArray=[[NSArray alloc]initWithObjects:zigbeedoorlock1, zigbeedoorlock2,nil];
    SFIDeviceValue *zigbeeDeviceValue=[self createDeviceValue:2 deviceID:28 isPresent:NO knownValueArray:zigbeedeviceValuesArray];
    
    //29,30,31 is not there
    //colorDimControl 32
    
    SFIDeviceKnownValues *colorDimControl1=[[SFIDeviceKnownValues alloc]init];
    colorDimControl1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    SFIDeviceKnownValues *colorDimControl2=[[SFIDeviceKnownValues alloc]init];
    colorDimControl2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_CURRENT_HUE valuetype_:@"STATE" valuename_:@"HUE" value_:@"20"];
    SFIDeviceKnownValues *colorDimControl3=[[SFIDeviceKnownValues alloc]init];
    colorDimControl3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVEL" value_:@"90"];
    SFIDeviceKnownValues *colorDimControl4=[[SFIDeviceKnownValues alloc]init];
    colorDimControl4 = [self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_COLOR_TEMPERATURE valuetype_:@"STATE" valuename_:@"COLOR_TEMPERATURE" value_:@"34"];
    SFIDeviceKnownValues *colorDimControl5=[[SFIDeviceKnownValues alloc]init];
    colorDimControl5 = [self createKnownValuesWithIndex:5 PropertyType_:SFIDevicePropertyType_CURRENT_SATURATION valuetype_:@"STATE" valuename_:@"COLOR_TEMPERATURE" value_:@"34"];
    NSArray *colorDimControlValuesArray=[[NSArray alloc]initWithObjects:colorDimControl1,colorDimControl2, colorDimControl3,colorDimControl4,colorDimControl5,nil];
    SFIDeviceValue *colorDimControlDeviceValue=[self createDeviceValue:(int)[colorDimControlValuesArray count] deviceID:32 isPresent:NO knownValueArray:colorDimControlValuesArray];
    
    //smoke dector_36
    
    SFIDeviceKnownValues *smokedetector=[[SFIDeviceKnownValues alloc]init];
    smokedetector = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"BASIC" value_:@"20"];
    SFIDeviceKnownValues *smokedetector2=[[SFIDeviceKnownValues alloc]init];
    smokedetector2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *smaokedectorValuesArray=[[NSArray alloc]initWithObjects:smokedetector,smokedetector2,nil];
    SFIDeviceValue *smokedectorDeviceValue=[self createDeviceValue:2 deviceID:36 isPresent:NO knownValueArray:smaokedectorValuesArray];
    
    //flood dector_37
    SFIDeviceKnownValues *floodsensor=[[SFIDeviceKnownValues alloc]init];
    floodsensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"BASIC" value_:@"20"];
    SFIDeviceKnownValues *floodsensor1=[[SFIDeviceKnownValues alloc]init];
    floodsensor1 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"BASIC" value_:@"20"];
    NSArray *floodsensorValuesArray=[[NSArray alloc]initWithObjects:floodsensor,floodsensor1,nil];
    
    SFIDeviceValue *floodsensorDeviceValue=[self createDeviceValue:2 deviceID:37 isPresent:NO knownValueArray:floodsensorValuesArray];
    
    //shockSensor_38
    
    SFIDeviceKnownValues *shocksensor=[[SFIDeviceKnownValues alloc]init];
    shocksensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"false"];
    SFIDeviceKnownValues *shocksensor1=[[SFIDeviceKnownValues alloc]init];
    shocksensor1 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"false"];
    NSArray *shocksensorValuesArray=[[NSArray alloc]initWithObjects:shocksensor,shocksensor1,nil];
    SFIDeviceValue *shocksensorDeviceValue=[self createDeviceValue:2 deviceID:38 isPresent:NO knownValueArray:shocksensorValuesArray];
    
    //door sensor_39
    
    SFIDeviceKnownValues *doorsensor=[[SFIDeviceKnownValues alloc]init];
    doorsensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"false"];
    SFIDeviceKnownValues *doorsensor1=[[SFIDeviceKnownValues alloc]init];
    doorsensor1 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"false"];
    NSArray *doorsensorValuesArray=[[NSArray alloc]initWithObjects:doorsensor,doorsensor1,nil];
    SFIDeviceValue *doorsensorDeviceValue=[self createDeviceValue:2 deviceID:39 isPresent:NO knownValueArray:doorsensorValuesArray];
    
    //moisture sensor_40
    
    SFIDeviceKnownValues *moisturesensor=[[SFIDeviceKnownValues alloc]init];
    moisturesensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"BASIC" value_:@"10"];
    SFIDeviceKnownValues *moisturesensor1=[[SFIDeviceKnownValues alloc]init];
    moisturesensor1 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"PRIMARY ATTRIBUTE" valuename_:@"TEMPERATURE" value_:@"20"];
    SFIDeviceKnownValues *moisturesensor2=[[SFIDeviceKnownValues alloc]init];
    moisturesensor2 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"false"];
    
    NSArray *moisturesensorValuesArray=[[NSArray alloc]initWithObjects:moisturesensor,moisturesensor1,nil];
    SFIDeviceValue *moisturesensorDeviceValue=[self createDeviceValue:3 deviceID:40 isPresent:NO knownValueArray:moisturesensorValuesArray];
    
    //motion sensor_41
    
    SFIDeviceKnownValues *motionsensor=[[SFIDeviceKnownValues alloc]init];
    motionsensor = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SENSOR BINARY" value_:@"false"];
    SFIDeviceKnownValues *motionsensor1=[[SFIDeviceKnownValues alloc]init];
    motionSensor1 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"STATE" valuename_:@"TEMPERATURE" value_:@"false"];
    SFIDeviceKnownValues *motionsensor2=[[SFIDeviceKnownValues alloc]init];
    motionSensor2 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"TEMPERATURE" value_:@"false"];
    NSArray *motionsensorValuesArray=[[NSArray alloc]initWithObjects:motionsensor,motionsensor1,motionSensor2,nil];
    SFIDeviceValue *motionsensorDeviceValue=[self createDeviceValue:3 deviceID:41 isPresent:NO knownValueArray:motionsensorValuesArray];
    
    //siren_42
    
    SFIDeviceKnownValues *siren=[[SFIDeviceKnownValues alloc]init];
    siren = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"false"];
    SFIDeviceKnownValues *siren1=[[SFIDeviceKnownValues alloc]init];
    siren1 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"false"];
    NSArray *sirenValuesArray=[[NSArray alloc]initWithObjects:siren,siren1,nil];
    SFIDeviceValue *sirenDeviceValue=[self createDeviceValue:2 deviceID:42 isPresent:NO knownValueArray:sirenValuesArray];
    
    //43 is not there
    //unknownonOffModule_44
    
    SFIDeviceKnownValues *unknownonOffModule=[[SFIDeviceKnownValues alloc]init];
    unknownonOffModule = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SENSOR_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"false"];
    NSArray *unknownonOffModuleArray=[[NSArray alloc]initWithObjects:unknownonOffModule,nil];
    SFIDeviceValue *unknownonOffModuleValue=[self createDeviceValue:1 deviceID:44 isPresent:NO knownValueArray:unknownonOffModuleArray];
    
    //binary power switch_45
    
    SFIDeviceKnownValues *PowerswitchValues=[[SFIDeviceKnownValues alloc]init];
    PowerswitchValues = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    SFIDeviceKnownValues *PowerswitchValues1=[[SFIDeviceKnownValues alloc]init];
    PowerswitchValues1 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_POWER valuetype_:@"POWER" valuename_:@"PRIMARY ATTRIBUTE" value_:@"10"];
    NSArray *powerswitchValuesArray=[[NSArray alloc]initWithObjects:PowerswitchValues,PowerswitchValues1, nil];
    SFIDeviceValue *powerswitchDeviceValue=[[SFIDeviceValue alloc]init];
    powerswitchDeviceValue=[self createDeviceValue:2 deviceID:45 isPresent:NO knownValueArray:powerswitchValuesArray];
    
    //setpointTharmostat_46
    
    SFIDeviceKnownValues *setPointTharmostat=[[SFIDeviceKnownValues alloc]init];
    setPointTharmostat = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING valuetype_:@"DETAIL INDEX" valuename_:@"THERMOSTAT SETPOINT COOLING" value_:@"70"];
    SFIDeviceKnownValues *setPointTharmostat1=[[SFIDeviceKnownValues alloc]init];
    setPointTharmostat1 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"STATE" valuename_:@"TEMPERATURE" value_:@"20"];
    SFIDeviceKnownValues *setPointTharmostat2=[[SFIDeviceKnownValues alloc]init];
    setPointTharmostat2 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    NSArray *setPointTharmostatArray=[[NSArray alloc]initWithObjects:setPointTharmostat,setPointTharmostat1, setPointTharmostat2,nil];
    SFIDeviceValue *setPointTharmostatDeviceValue=[[SFIDeviceValue alloc]init];
    setPointTharmostatDeviceValue=[self createDeviceValue:3 deviceID:46 isPresent:NO knownValueArray:setPointTharmostatArray];
    
    //hue lamp_48
    
    SFIDeviceKnownValues *huelampValues1=[[SFIDeviceKnownValues alloc]init];
    huelampValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    SFIDeviceKnownValues *huelampValues2=[[SFIDeviceKnownValues alloc]init];
    huelampValues2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_COLOR_HUE valuetype_:@"POWER" valuename_:@"HUE" value_:@"0"];
    SFIDeviceKnownValues *huelampValues3=[[SFIDeviceKnownValues alloc]init];
    huelampValues3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_SATURATION valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    SFIDeviceKnownValues *huelampValues4=[[SFIDeviceKnownValues alloc]init];
    huelampValues4 = [self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_BRIGHTNESS valuetype_:@"POWER" valuename_:@"PRIMARY ATTRIBUTE" value_:@"0"];
    NSArray *hueValuesArray=[[NSArray alloc]initWithObjects:huelampValues1,huelampValues2,huelampValues3,huelampValues4, nil];
    SFIDeviceValue *huebulbDeviceValue=[[SFIDeviceValue alloc]init];
    huebulbDeviceValue=[self createDeviceValue:4 deviceID:48 isPresent:NO knownValueArray:hueValuesArray];
    
    //MultiSensor_49
    SFIDeviceKnownValues *multiSensor1=[[SFIDeviceKnownValues alloc]init];
    multiSensor1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *multiSensor2=[[SFIDeviceKnownValues alloc]init];
    multiSensor2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *multiSensor3=[[SFIDeviceKnownValues alloc]init];
    multiSensor3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_ILLUMINANCE valuetype_:@"STATE" valuename_:@"ILLUMINANCE" value_:@"true"];
    
    SFIDeviceKnownValues *multiSensor4=[[SFIDeviceKnownValues alloc]init];
    multiSensor4 = [self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_TEMPERATURE valuetype_:@"PRIMARY ATTRIBUTE" valuename_:@"TEMPERATURE" value_:@"20"];
    
    SFIDeviceKnownValues *multiSensor5=[[SFIDeviceKnownValues alloc]init];
    multiSensor5 = [self createKnownValuesWithIndex:5 PropertyType_:SFIDevicePropertyType_HUMIDITY valuetype_:@"PRIMARY ATTRIBUTE" valuename_:@"HUMIDITY" value_:@"42"];
    NSArray *multiSensorValuesArray=[[NSArray alloc]initWithObjects:multiSensor1,multiSensor2,multiSensor3,multiSensor4,multiSensor5, nil];
    
    SFIDeviceValue *multiSensorDeviceValue=[[SFIDeviceValue alloc]init];
    multiSensorDeviceValue=[self createDeviceValue:5 deviceID:49 isPresent:NO knownValueArray:multiSensorValuesArray];

    
    //securifi smartswitch_50
    SFIDeviceKnownValues *SFIswitchValues1=[[SFIDeviceKnownValues alloc]init];
    SFIswitchValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_BINARY valuetype_:@"STATE" valuename_:@"SWITCH BINARY" value_:@"true"];
    NSArray *SFIswitchValuesArray=[[NSArray alloc]initWithObjects:SFIswitchValues1,nil];
    SFIDeviceValue *SFIswitchDeviceValue=[[SFIDeviceValue alloc]init];
    SFIswitchDeviceValue=[self createDeviceValue:1 deviceID:50 isPresent:NO knownValueArray:SFIswitchValuesArray];
    
    //RollerShutter_52
    SFIDeviceKnownValues *rollerShutter=[[SFIDeviceKnownValues alloc]init];
    rollerShutter = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVEL" value_:@"90"];
    SFIDeviceKnownValues *rollerShutter2=[[SFIDeviceKnownValues alloc]init];
    rollerShutter2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_UP_DOWN valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVEL" value_:@"90"];
    SFIDeviceKnownValues *rollerShutter3=[[SFIDeviceKnownValues alloc]init];
    rollerShutter3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_STOP valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVEL" value_:@"90"];

    
    NSArray *rollerShutterValuesArray=[[NSArray alloc]initWithObjects:rollerShutter,rollerShutter2, rollerShutter3, nil];
    SFIDeviceValue *rollerShutterDeviceValue=[[SFIDeviceValue alloc]init];
    rollerShutterDeviceValue=[self createDeviceValue:3 deviceID:52 isPresent:NO knownValueArray:rollerShutterValuesArray];

    //garage door opener_53
    SFIDeviceKnownValues *garagedooropenerValues1=[[SFIDeviceKnownValues alloc]init];
    garagedooropenerValues1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BARRIER_OPERATOR valuetype_:@"STATE" valuename_:@"BARRIER OPERATOR" value_:@"true"];
    NSArray *garageopenerValuesArray=[[NSArray alloc]initWithObjects:garagedooropenerValues1,nil];
    SFIDeviceValue *garagedooropenerDeviceValue=[[SFIDeviceValue alloc]init];
    garagedooropenerDeviceValue=[self createDeviceValue:1 deviceID:53 isPresent:NO knownValueArray:garageopenerValuesArray];
    
    //ZWtoACIRExtender_54
    SFIDeviceKnownValues *ZWtoACIRExtender1=[[SFIDeviceKnownValues alloc]init];
    ZWtoACIRExtender1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_AC_MODE valuetype_:@"STATE" valuename_:@"BARRIER OPERATOR" value_:@"true"];
    
    SFIDeviceKnownValues *ZWtoACIRExtender2=[[SFIDeviceKnownValues alloc]init];
    ZWtoACIRExtender2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_AC_SETPOINT_HEATING valuetype_:@"STATE" valuename_:@"DETAIL INDEX" value_:@"true"];
    
    SFIDeviceKnownValues *ZWtoACIRExtender3=[[SFIDeviceKnownValues alloc]init];
    ZWtoACIRExtender3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_AC_SETPOINT_COOLING valuetype_:@"DETAIL INDEX" valuename_:@"BARRIER OPERATOR" value_:@"true"];
    
    SFIDeviceKnownValues *ZWtoACIRExtender4=[[SFIDeviceKnownValues alloc]init];
    ZWtoACIRExtender4 = [self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_AC_FAN_MODE valuetype_:@"STATE" valuename_:@"BARRIER OPERATOR" value_:@"true"];
    
    SFIDeviceKnownValues *ZWtoACIRExtender5=[[SFIDeviceKnownValues alloc]init];
    ZWtoACIRExtender5 = [self createKnownValuesWithIndex:5 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
//    SFIDeviceKnownValues *ZWtoACIRExtender6=[[SFIDeviceKnownValues alloc]init];
//    ZWtoACIRExtender6 = [self createKnownValuesWithIndex:6 PropertyType_:SFIDevicePropertyType_UNITS valuetype_:@"STATE" valuename_:@"BARRIER OPERATOR" value_:@"true"];
    
    SFIDeviceKnownValues *ZWtoACIRExtender7=[[SFIDeviceKnownValues alloc]init];
    ZWtoACIRExtender7 = [self createKnownValuesWithIndex:7 PropertyType_:SFIDevicePropertyType_AC_SWING valuetype_:@"STATE" valuename_:@"BARRIER OPERATOR" value_:@"true"];
    
    SFIDeviceKnownValues *ZWtoACIRExtender8=[[SFIDeviceKnownValues alloc]init];
    ZWtoACIRExtender8 = [self createKnownValuesWithIndex:8 PropertyType_:SFIDevicePropertyType_BASIC valuetype_:@"STATE" valuename_:@"BARRIER OPERATOR" value_:@"true"];
    
    NSArray *ZWtoACIRExtenderValueArray=[[NSArray alloc]initWithObjects:ZWtoACIRExtender1,ZWtoACIRExtender2,ZWtoACIRExtender3,ZWtoACIRExtender4,ZWtoACIRExtender5,ZWtoACIRExtender7, ZWtoACIRExtender8, nil];
    
    SFIDeviceValue *ZWtoACIRExtenderDeviceValue=[[SFIDeviceValue alloc]init];
    ZWtoACIRExtenderDeviceValue=[self createDeviceValue:8 deviceID:54 isPresent:NO knownValueArray:ZWtoACIRExtenderValueArray];

    //multiSoundSiren_55
    SFIDeviceKnownValues *multiSoundSiren1=[[SFIDeviceKnownValues alloc]init];
    multiSoundSiren1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetype_:@"STATE" valuename_:@"SWITCH MULTILEVEL" value_:[NSString stringWithFormat:@"%d",2]];
    
    NSArray *multiSoundSirenValueArray=[[NSArray alloc]initWithObjects:multiSoundSiren1, nil];
    SFIDeviceValue *multiSoundSirenDeviceValue=[[SFIDeviceValue alloc]init];
    multiSoundSirenDeviceValue=[self createDeviceValue:1 deviceID:55 isPresent:NO knownValueArray:multiSoundSirenValueArray];
    
    
    //EnergyReader_56
    SFIDeviceKnownValues *EnergyReader=[[SFIDeviceKnownValues alloc]init];
    EnergyReader = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *EnergyReader1=[[SFIDeviceKnownValues alloc]init];
    EnergyReader1 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_POWER valuetype_:@"POWER" valuename_:@"PRIMARY ATTRIBUTE" value_:@"10"];
    SFIDeviceKnownValues *EnergyReader2=[[SFIDeviceKnownValues alloc]init];
    EnergyReader2 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_ENERGY valuetype_:@"ENERGY" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *EnergyReader3=[[SFIDeviceKnownValues alloc]init];
    EnergyReader3 = [self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_CLAMP1_POWER valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *EnergyReader4=[[SFIDeviceKnownValues alloc]init];
    EnergyReader4 = [self createKnownValuesWithIndex:5 PropertyType_:SFIDevicePropertyType_CLAMP1_ENERGY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *EnergyReader5=[[SFIDeviceKnownValues alloc]init];
    EnergyReader5 = [self createKnownValuesWithIndex:6 PropertyType_:SFIDevicePropertyType_CLAMP2_POWER valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *EnergyReader6=[[SFIDeviceKnownValues alloc]init];
    EnergyReader6 = [self createKnownValuesWithIndex:7 PropertyType_:SFIDevicePropertyType_CLAMP2_ENERGY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *EnergyReaderValueArray=[[NSArray alloc]initWithObjects:EnergyReader,EnergyReader1,EnergyReader2,EnergyReader3,EnergyReader4,EnergyReader5,EnergyReader6,nil];
    
    SFIDeviceValue *EnergyReaderDeviceValue=[[SFIDeviceValue alloc]init];
    EnergyReaderDeviceValue=[self createDeviceValue:7 deviceID:56 isPresent:NO knownValueArray:EnergyReaderValueArray];
    
    //NestTharmostat_57
    SFIDeviceKnownValues *nestTharmostat1=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_NEST_THERMOSTAT_MODE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *nestTharmostat2=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_THERMOSTAT_TARGET valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *nestTharmostat3=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_HUMIDITY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *nestTharmostat4=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat4 = [self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_THERMOSTAT_RANGE_LOW valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *nestTharmostat5=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat5 = [self createKnownValuesWithIndex:5 PropertyType_:SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *nestTharmostat6=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat6= [self createKnownValuesWithIndex:6 PropertyType_:SFIDevicePropertyType_AWAY_MODE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *nestTharmostat7=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat7 = [self createKnownValuesWithIndex:7 PropertyType_:SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *nestTharmostat8=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat8 = [self createKnownValuesWithIndex:8 PropertyType_:SFIDevicePropertyType_CURRENT_TEMPERATURE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *nestTharmostat12=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat12 = [self createKnownValuesWithIndex:12 PropertyType_:SFIDevicePropertyType_CAN_COOL valuetype_:@"STATE" valuename_:@"STATE" value_:@"false"];
    
    SFIDeviceKnownValues *nestTharmostat13=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat13 = [self createKnownValuesWithIndex:13 PropertyType_:SFIDevicePropertyType_CAN_HEAT valuetype_:@"STATE" valuename_:@"STATE" value_:@"false"];
    
    SFIDeviceKnownValues *nestTharmostat15=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat15 = [self createKnownValuesWithIndex:15 PropertyType_:SFIDevicePropertyType_HAS_FAN valuetype_:@"STATE" valuename_:@"STATE" value_:@"false"];
    
    SFIDeviceKnownValues *nestTharmostat16=[[SFIDeviceKnownValues alloc]init];
    nestTharmostat16 = [self createKnownValuesWithIndex:16 PropertyType_:SFIDevicePropertyType_HVAC_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    NSArray *nestTharmostatValueArray=[[NSArray alloc]initWithObjects:nestTharmostat1,nestTharmostat2,nestTharmostat3,nestTharmostat4,nestTharmostat5,nestTharmostat6,nestTharmostat7,nestTharmostat8,nestTharmostat12, nestTharmostat13, nestTharmostat15, nestTharmostat16,nil];
    
    SFIDeviceValue *nestTharmostatDeviceValue=[[SFIDeviceValue alloc]init];
    nestTharmostatDeviceValue=[self createDeviceValue:9 deviceID:57 isPresent:NO knownValueArray:nestTharmostatValueArray];

    //NestSmokeDetector_58
    SFIDeviceKnownValues *nestSmokeDetector1=[[SFIDeviceKnownValues alloc]init];
    nestSmokeDetector1 = [self createKnownValuesWithIndex:1 PropertyType_:SFIDevicePropertyType_BATTERY valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *nestSmokeDetector2=[[SFIDeviceKnownValues alloc]init];
    nestSmokeDetector2 = [self createKnownValuesWithIndex:2 PropertyType_:SFIDevicePropertyType_CO_ALARM_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    
    SFIDeviceKnownValues *nestSmokeDetector3=[[SFIDeviceKnownValues alloc]init];
    nestSmokeDetector3 = [self createKnownValuesWithIndex:3 PropertyType_:SFIDevicePropertyType_SMOKE_ALARM_STATE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *nestSmokeDetector4=[[SFIDeviceKnownValues alloc]init];
    nestSmokeDetector4 = [self createKnownValuesWithIndex:4 PropertyType_:SFIDevicePropertyType_ISONLINE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *nestSmokeDetector5=[[SFIDeviceKnownValues alloc]init];
    nestSmokeDetector5 = [self createKnownValuesWithIndex:5 PropertyType_:SFIDevicePropertyType_AWAY_MODE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    SFIDeviceKnownValues *nestSmokeDetector6=[[SFIDeviceKnownValues alloc]init];
    nestSmokeDetector6 = [self createKnownValuesWithIndex:6 PropertyType_:SFIDevicePropertyType_RESPONSE_CODE valuetype_:@"STATE" valuename_:@"STATE" value_:@"true"];
    NSArray *nestSmokeDetectorValueArray=[[NSArray alloc]initWithObjects:nestSmokeDetector1,nestSmokeDetector2,nestSmokeDetector3,nestSmokeDetector4,nestSmokeDetector5,nestSmokeDetector6,nil];
    
    SFIDeviceValue *nestSmokeDetectorDeviceValue=[[SFIDeviceValue alloc]init];
    nestSmokeDetectorDeviceValue=[self createDeviceValue:6 deviceID:58 isPresent:NO knownValueArray:nestSmokeDetectorValueArray];
    

    
    NSMutableArray* deviceValueArray = [[NSMutableArray alloc] init];
    
    [deviceValueArray addObject:switchbinaryDeviceValue];//1
    [deviceValueArray addObject:switchMultilevelDeviceValue];//2
    [deviceValueArray addObject:sensorBinaryDeviceValue];//3
    [deviceValueArray addObject:multilevelDeviceValue];//4
    [deviceValueArray addObject:doorLockDeviceValue];//5

    [deviceValueArray addObject:alarmDeviceValue];//6
    [deviceValueArray addObject:thermodevicevalue];//7
    [deviceValueArray addObject:standardCIEValue];//10
    [deviceValueArray addObject:motionSensorValue];//11
    [deviceValueArray addObject:contactSwitchValue];//12

    [deviceValueArray addObject:firesensorValue];//13
    [deviceValueArray addObject:waterSensorValue];//14
    [deviceValueArray addObject:gasSensorValue];//15
    [deviceValueArray addObject:keyFobDeviceValue];//19
    [deviceValueArray addObject:warningDeviceValue];//21

    [deviceValueArray addObject:SmartACDeviceValue];//22
    [deviceValueArray addObject:occupancydevicevalue];//24
    [deviceValueArray addObject:lightsensorDeviceValue];//25
    [deviceValueArray addObject:windowcoverDeviceValue];//26
    [deviceValueArray addObject:temperaturesensorDeviceValue];//27

    [deviceValueArray addObject:zigbeeDeviceValue];//28
//    [deviceValueArray addObject:colorDimControlDeviceValue];//32
    [deviceValueArray addObject:smokedectorDeviceValue];//36
    [deviceValueArray addObject:floodsensorDeviceValue];//37
    [deviceValueArray addObject:shocksensorDeviceValue];//38

    [deviceValueArray addObject:doorsensorDeviceValue];//39
//    [deviceValueArray addObject:moisturesensorDeviceValue];//40
    [deviceValueArray addObject:motionsensorDeviceValue];//41
    [deviceValueArray addObject:sirenDeviceValue];//42
    [deviceValueArray addObject:unknownonOffModuleValue];//44;
//
    [deviceValueArray addObject:powerswitchDeviceValue];//45
    [deviceValueArray addObject:setPointTharmostatDeviceValue];//46
    [deviceValueArray addObject:huebulbDeviceValue];//48
    [deviceValueArray addObject:multiSensorDeviceValue];//49
    [deviceValueArray addObject:SFIswitchDeviceValue];//50
    [deviceValueArray addObject:rollerShutterDeviceValue];//52
    [deviceValueArray addObject:garagedooropenerDeviceValue];//53
    [deviceValueArray addObject:ZWtoACIRExtenderDeviceValue];//54
//
    [deviceValueArray addObject:multiSoundSirenDeviceValue]; //55
    [deviceValueArray addObject:EnergyReaderDeviceValue];//56
     [deviceValueArray addObject:nestTharmostatDeviceValue];//57
    
    return deviceValueArray;
}


@end
