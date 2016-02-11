//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Colours/Colours.h>
#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"
#import "ValueFormatter.h"
#import "SFIConstants.h"
#import "SFIDeviceIndex.h"


@implementation SensorIndexSupport

- (NSArray *)resolve:(SFIDeviceType)device index:(SFIDevicePropertyType)type {
    switch (device) {
        case SFIDeviceType_REBOOT_ALMOND:{
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.matchData = @"reboot";
            s1.iconName = DT1_BINARY_SWITCH_FALSE;
            s1.displayText=@"reboot Almond";
            s1.notificationText = @"";
            s1.eventType = @"AlmondModeUpdated";
            return @[s1];
        }
        case SFIDeviceType_BinarySwitch_0:{
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.matchData = @"home";
            s1.iconName = @"home_icon";
            s1.displayText=@"Home";
            s1.notificationText = @"";
            s1.eventType = @"AlmondModeUpdated";
            
            IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
            s2.matchData = @"away";
            s2.iconName = @"away_icon";
            s2.displayText=@"Away";
            s2.notificationText = @"";
            s2.eventType = @"AlmondModeUpdated";
            return @[s1, s2];
        }
            break;
        case SFIDeviceType_WIFIClient:{
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.matchData = @"";
            s1.iconName = @"device-joining";
            s1.displayText=@"JOIN";
            s1.notificationText = @"";
            s1.eventType = @"ClientJoined";
            
            IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
            s2.matchData = @"";
            s2.iconName = @"device-leaving";
            s2.displayText=@"LEAVE";
            s2.notificationText = @"";
            s2.eventType = @"ClientLeft";
            
            return @[s1, s2];
            
        }
        case SFIDeviceType_UnknownDevice_0:
            break;
            
        case SFIDeviceType_BinarySwitch_1: {
            /*
             <Index
             id="1"
             name="SWITCH BINARY"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/off"
             icon="@drawable/switch_off"
             notificationText="@string/notification_switch_off"
             toggleValue="true"  />
             <Value
             data="true"
             displayText="@string/on"
             icon="@drawable/switch_on"
             notificationText="@string/notification_switch_on"
             toggleValue="false" />
             </Index>
             
             */
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT1_BINARY_SWITCH_FALSE;
                s1.displayText=@"OFF";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT1_BINARY_SWITCH_TRUE;
                s2.displayText=@"ON";
                s2.notificationText = NSLocalizedString(@" is turned On.", @" is turned On.");
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_MultiLevelSwitch_2: {
            /*
             <Index
             id="1"
             name="SWITCH MULTILEVEL"
             type="STATE">
             <Value
             data="0"
             displayText="@string/off"
             icon="@drawable/switch_off"
             notificationText="@string/notification_switch_off"
             toggleValue="99" />
             <Value icon="@drawable/dimmer" toggleValue="0" >
             <ValueFormatter
             action="formatString"
             prefix="@string/dimmable"
             notificationPrefix="@string/notification_dimmable"
             suffix="%" />
             </Value>
             </Index>
             */
            if (type == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = DT2_MULTILEVEL_SWITCH_FALSE;
                s1.displayText=@"OFF";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0";
                s2.matchType = MatchType_not_equals;
                s2.iconName = @"multilevel_switch_on";
                s2.displayText=@"DIM";
                s2.layoutType=@"dimButton";
                s2.minValue = 0;
                s2.maxValue = 255;
                s2.notificationText = @"";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@" is dimmed to", @" is dimmed to ");
                s2.valueFormatter.suffix = @"%";
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"100";
                s3.iconName = DT2_MULTILEVEL_SWITCH_TRUE;
                s3.displayText = @"ON";
                s3.notificationText = NSLocalizedString(@" is turned On.", @" is turned On.");
                
                
                return @[s2,s1,s3];
            }
            
            break;
        }
            
        case SFIDeviceType_BinarySensor_3: {
            /*
             <Sensor
             name="Z-wave Door Sensor"
             deviceType="3"
             isActuator="false"
             defaultIcon="@drawable/door_off">
             <Index
             id="1"
             name="SENSOR BINARY"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/door_off"
             icon="@drawable/door_off"
             notificationText="@string/notification_door_off" />
             <Value
             data="true"
             displayText="@string/door_on"
             icon="@drawable/door_on"
             notificationText="@string/notification_door_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_SENSOR_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT3_BINARY_SENSOR_FALSE;
                s1.displayText = @"CLOSED";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.displayText=@"ON";
                s2.displayText = @"OPEN";
                s2.matchType = MatchType_not_equals;
                s2.iconName = DT3_BINARY_SENSOR_TRUE;
                s2.notificationText = NSLocalizedString(@" is Opened.", @" is Opened.");
                
                return @[s1, s2];
            }
            
            break;
        }
        case SFIDeviceType_MultiLevelOnOff_4: {
            /*
             <Sensor
             name="OnOffMultilevelSwitch"
             deviceType="4"
             isActuator="true"
             defaultIcon="@drawable/switch_off" >
             <Index
             id="2"
             name="SWITCH BINARY"
             type="STATE">
             <Value
             data="false"
             displayText="@string/off"
             icon="@drawable/switch_off"
             notificationText="@string/notification_switch_off"
             toggleValue="true"/>
             <Value
             data="true"
             displayText="@string/on"
             icon="@drawable/dimmer"
             notificationText="@string/notification_switch_on"
             toggleValue="false"
             />
             </Index>
             <Index
             id="1"
             name="SWITCH MULTILEVEL"
             type="PRIMARY ATTRIBUTE" >
             <Value>
             <ValueFormatter
             action="division"
             factor="0.39"
             prefix="@string/dimmable_percentage"
             notificationPrefix="@string/notification_dimmable"
             suffix="%" />
             </Value>
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT4_LEVEL_CONTROL_FALSE;
                s1.displayText=@"OFF";
                s1.notificationText = NSLocalizedString(@" turned Off.", @" turned Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT4_LEVEL_CONTROL_TRUE;
                s2.displayText=@"ON";
                s2.notificationText = NSLocalizedString(@" turned On.", @" turned On.");
                
                return @[s1, s2];
            }
            else if (type == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"50";
                s1.valueFormatter.action = ValueFormatterAction_scale;
                s1.layoutType=@"dimButton";
                s1.iconName = @"multilevel_switch_on";
                s1.displayText=@"DIM";
                s1.minValue = 0;
                s1.maxValue = 100;
                s1.valueFormatter.maxValue = 255;
                s1.valueFormatter.scaledMaxValue = 100;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is dimmed to ", @" is dimmed to ");
                s1.valueFormatter.suffix = @"%";
                
                return @[s1];
            }
            
            break;
        }
            
        case SFIDeviceType_DoorLock_5: {
            /*
             <Sensor
             name="Z-wave DoorLock"
             deviceType="5"
             isActuator="true"
             defaultIcon="@drawable/doorlock_off">
             <Index
             id="1"
             name="LOCK_STATE"
             type="STATE" >
             <Value
             data="0"
             displayText="@string/doorlock_off"
             icon="@drawable/doorlock_off"
             notificationText="@string/notification_doorlock_off"
             toggleValue="255" />
             <Value
             data="255"
             displayText="@string/doorlock_on"
             icon="@drawable/doorlock_on"
             notificationText="@string/notification_doorlock_on"
             toggleValue="0" />
             </Index>
             </Sensor>
             */
            
            if (type == SFIDevicePropertyType_LOCK_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = DT5_DOOR_LOCK_UNLOCKED;
                s1.displayText=@"UNLOCKED";
                s1.notificationText = NSLocalizedString(@" is Unlocked.", @" is Unlocked.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.displayText=@"LOCKED";
                s2.iconName = DT5_DOOR_LOCK_LOCKED;
                s2.notificationText = NSLocalizedString(@" is Locked.", @" is Locked.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_Alarm_6: {
            /*
             <Sensor
             name="Alarm"
             deviceType="6"
             isActuator="true"
             defaultIcon="@drawable/alarm_off">
             <Index
             id="1"
             name="BASIC"
             type="STATE" >
             <Value
             data="255"
             displayText="@string/off"
             icon="@drawable/alarm_off"
             notificationText="@string/notification_alarm_off"
             toggleValue="0"/>
             <Value
             data="0"
             displayText="@string/alarm_on"
             icon="@drawable/alarm_on"
             notificationText="@string/notification_alarm_on"
             toggleValue="255" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_BASIC) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = DT6_ALARM_TRUE;
                s1.displayText=@"RINGING";
                s1.notificationText = NSLocalizedString(@" is Silent.", @" is Silent.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.displayText=@"SILENT";
                s2.iconName =DT6_ALARM_FALSE;
                s2.notificationText = NSLocalizedString(@" is Ringing.", @" is Ringing.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_Thermostat_7: {
            /*
             <Sensor
             name="Themostat"
             deviceType="7"
             isActuator="false"
             defaultIcon="@drawable/thermostat">
             <Index
             id="1"
             name="SENSOR MULTILEVEL"
             type="STATE" >
             <Value>
             <ValueFormatter notificationPrefix="@string/thermostat_temp" suffix="\u00B0F"/>
             </Value>
             </Index>
             <Index
             id="2"
             name="THERMOSTAT OPERATING STATE"
             type="PRIMARY ATTRIBUTE" >
             <Value>
             <ValueFormatter notificationPrefix="@string/thermostat_state" />
             </Value>
             </Index>
             <Index
             id="3"
             name="THERMOSTAT SETPOINT COOLING"
             type="DETAIL INDEX" >
             <Value>
             <ValueFormatter notificationPrefix="@string/thermostat_cool" />
             </Value>
             </Index>
             <Index
             id="4"
             name="THERMOSTAT SETPOINT HEATING"
             type="DETAIL INDEX" >
             <Value>
             <ValueFormatter notificationPrefix="@string/thermostat_heat" />
             </Value>
             </Index>
             <Index
             id="5"
             name="THERMOSTAT MODE"
             type="DETAIL INDEX" >
             <Value>
             <ValueFormatter notificationPrefix="@string/thermostat_mode" />
             </Value>
             </Index>
             <Index
             id="6"
             name="THERMOSTAT FAN MODE"
             type="DETAIL INDEX" >
             <Value icon="@drawable/icon_fan" >
             <ValueFormatter notificationPrefix="@string/thermostat_fanMode" />
             </Value>
             </Index>
             <Index
             id="7"
             name="THERMOSTAT FAN STATE"
             type="DETAIL INDEX" >
             <Value icon="@drawable/icon_fan">
             <ValueFormatter notificationPrefix="@string/thermostat_fanState" />
             </Value>
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_SENSOR_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.iconName = @"target_temperature";
                s1.displayText = @"TEMPERATURE";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Heating";
                s1.displayText=@"";
                s1.iconName = @"n_07_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is ", @" is ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.displayText=@"COOL";
                s1.iconName = @"n_07_thermostat";
                s1.layoutType=@"dimButton";
                s1.displayText = @"COOL-";
                s1.minValue = 35;
                s1.maxValue = 95;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is cooling down to ", @" is cooling down to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.layoutType=@"dimButton";
                s1.iconName = @"n_07_thermostat";
                s1.displayText = @"HEAT-";
                s1.minValue = 35;
                s1.maxValue = 95;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is heating up to ", @" is heating up to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_MODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Auto";
                s1.displayText=@"AUTO";
                s1.iconName = @"imgAuto";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to ", @" is set to ");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_any;
                s2.matchData = @"Heat";
                s2.displayText = @"HEAT";
                s2.iconName = @"imgHeat";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to ", @" is set to ");
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_any;
                s3.matchData = @"Cool";
                s3.iconName = @"imgCool";
                s3.displayText = @"COOL";
                s3.valueFormatter.action = ValueFormatterAction_formatString;
                s3.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to ", @" is set to ");
                
                IndexValueSupport *s4 = [[IndexValueSupport alloc] initWithValueType:type];
                s4.matchType = MatchType_any;
                s4.matchData = @"Off";
                s4.iconName = @"imgOff";
                s4.displayText = @"OFF";
                s4.valueFormatter.action = ValueFormatterAction_formatString;
                s4.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to ", @" is set to ");
                
                return @[s1,s2,s3,s4];
                
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_FAN_MODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Auto Low";
                s1.iconName = @"imgFanOn";
                s1.displayText=@"AUTO";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" Fan is set to ", @" Fan is set to ");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_any;
                s2.matchData = @"On Low";
                s2.iconName = @"imgFanOff";
                s2.displayText = @"ON LOW";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@" Fan is set to ", @" Fan is set to ");
                
                return @[s1,s2];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_FAN_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"On";
                s1.iconName = @"imgFanOn";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" Fan is ", @" Fan is ");
                return @[s1];
            }
            if (type == SFIDevicePropertyType_HUMIDITY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"humidity";
                s1.displayText = nil;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" humidity is ", @" humidity is ");
                return @[s1];
            }
            
            break;
        }
            
        case SFIDeviceType_Controller_8:
            break;
        case SFIDeviceType_SceneController_9:
            break;
        case SFIDeviceType_StandardCIE_10: {
            /*
             <Sensor
             name="UnKnown Sensor"
             deviceType="10"
             isActuator="false"
             defaultIcon="@drawable/switch_off"  >
             <Index
             id="1"
             name="STATE"
             type="STATE">
             <Value
             data="false"
             displayText="@string/value_false"
             icon="@drawable/switch_off"
             notificationText="@string/notification_switch_off" />
             <Value
             data="true"
             displayText="@string/value_true"
             icon="@drawable/switch_on"
             notificationText="@string/notification_switch_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = D10_STANDARD_CIE_FALSE;
                s1.displayText =@"FALSE";
                s1.notificationText = NSLocalizedString(@" turned Off.", @" turned Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = D10_STANDARD_CIE_TRUE;
                s2.displayText = @"TRUE";
                s2.notificationText = NSLocalizedString(@" turned On.", @" turned On.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_MotionSensor_11: {
            /*
             <Sensor
             name="Motion Sensor"
             deviceType="11"
             isActuator="false"
             defaultIcon="@drawable/motion_off">
             <Index
             id="1"
             name="STATE"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/motion_off"
             icon="@drawable/motion_off"
             notificationText="@string/notification_motion_off" />
             <Value
             data="true"
             displayText="@string/motion_on"
             icon="@drawable/motion_on"
             notificationText="@string/notification_motion_on" />
             </Index>
             </Sensor>
             */
            
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT11_MOTION_SENSOR_FALSE;
                s1.displayText=@"NO\nMOTION";
                s1.notificationText = NSLocalizedString(@"'s motion stopped.", @"'s motion stopped.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT11_MOTION_SENSOR_TRUE;
                s2.displayText=@"MOTION\nDETECTED";
                s2.notificationText = NSLocalizedString(@" detected motion.", @" detected motion.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_ContactSwitch_12: {
            /*
             <Sensor
             name="Door Sensor"
             deviceType="12"
             isActuator="false"
             defaultIcon="@drawable/door_off" >
             <Index
             id="1"
             name="STATE"
             type="STATE">
             <Value
             data="false"
             displayText="@string/door_off"
             icon="@drawable/door_off"
             notificationText="@string/notification_door_off" />
             <Value
             data="true"
             displayText="@string/door_on"
             icon="@drawable/door_on"
             notificationText="@string/notification_door_on" />
             
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT12_CONTACT_SWITCH_FALSE;
                s1.displayText=@"CLOSED";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT12_CONTACT_SWITCH_TRUE;
                s2.displayText=@"OPENED";
                s2.notificationText = NSLocalizedString(@" is Opened.", @" is Opened.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_FireSensor_13: {
            /*
             <Sensor
             name="Fire Sensor"
             deviceType="13"
             isActuator="false"
             defaultIcon="@drawable/fire_off" >
             <Index
             id="1"
             name="STATE"
             type="STATE">
             <Value
             data="false"
             displayText="@string/ok"
             icon="@drawable/fire_off"
             notificationText="@string/notification_fire_off" />
             <Value
             data="true"
             displayText="@string/fire_on"
             icon="@drawable/fire_on"
             notificationText="@string/notification_fire_on" />
             </Index>
             </Sensor>
             */
            
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT13_FIRE_SENSOR_FALSE;
                s1.displayText=@"NO\nSMOKE";
                s1.notificationText = NSLocalizedString(@"'s Fire is gone.", @"'s Fire is gone.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT13_FIRE_SENSOR_TRUE;
                s2.displayText=@"SMOKE";
                s2.notificationText = NSLocalizedString(@" detected Fire.", @" detected Fire.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_WaterSensor_14: {
            /*
             <Sensor
             name="Water Sensor"
             deviceType="14"
             isActuator="false"
             defaultIcon="@drawable/water_off" >
             <Index
             id="1"
             name="STATE"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/ok"
             icon="@drawable/water_off"
             notificationText="@string/notification_water_off" />
             <Value
             data="true"
             displayText="@string/water_on"
             icon="@drawable/water_on"
             notificationText="@string/notification_water_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT14_WATER_SENSOR_FALSE;
                s1.displayText=@"NO\nWATER";
                s1.notificationText = NSLocalizedString(@" stopped leaking.", @" stopped leaking.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT14_WATER_SENSOR_TRUE;
                s2.displayText=@"WATER";
                s2.notificationText = NSLocalizedString(@" detected water.", @" detected water.");
                
                return @[s1, s2];
            }
            
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"target_temperature";
                s1.displayText=@"TEMPERATURE";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = NSLocalizedString(@"\u00B0 Farenheit", @"\u00B0 Farenheit");
                
                return @[s1];
            }
            
            
            break;
        }
            
        case SFIDeviceType_GasSensor_15: {
            /*
             <Sensor
             name="Gas Sensor"
             deviceType="15"
             isActuator="false"
             defaultIcon="@drawable/fire_off" >
             <Index
             id="1"
             name="STATE"
             type="STATE">
             <Value
             data="false"
             displayText="@string/ok"
             icon="@drawable/fire_off"
             notificationText="@string/notification_gas_off" />
             <Value
             data="true"
             displayText="@string/gas_on"
             icon="@drawable/fire_on"
             notificationText="@string/notification_gas_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT15_GAS_SENSOR_FALSE;
                s1.displayText=@"NO\nSMOKE";
                s1.notificationText = NSLocalizedString(@"'s Gas is gone.", @"'s Gas is gone.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT15_GAS_SENSOR_TRUE;
                s2.displayText=@"SMOKE";
                s2.notificationText = NSLocalizedString(@" detected Gas.", @" detected Gas.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_PersonalEmergencyDevice_16: {
            /*
             <Sensor
             name="UnKnown Sensor"
             deviceType="16"
             isActuator="false"
             defaultIcon="@drawable/switch_off"  >
             <Index
             id="1"
             name="STATE"
             type="STATE">
             <Value
             data="false"
             displayText="@string/value_false"
             icon="@drawable/switch_off"
             notificationText="@string/notification_switch_off" />
             <Value
             data="true"
             displayText="@string/value_true"
             icon="@drawable/switch_on"
             notificationText="@string/notification_switch_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"16_vibration_yes";
                s1.notificationText = NSLocalizedString(@" turned Off.", @" turned Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"16_vibration_no";
                s2.notificationText = NSLocalizedString(@" turned On.", @" turned On.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_VibrationOrMovementSensor_17: {
            /*
             <Sensor
             name="Vibration Sensor"
             deviceType="17"
             isActuator="false"
             defaultIcon="@drawable/vibration_off">
             <Index
             id="1"
             name="STATE"
             type="STATE">
             <Value
             data="false"
             displayText="@string/vibration_off"
             icon="@drawable/vibration_off"
             notificationText="@string/notification_vibration_off" />
             <Value
             data="true"
             displayText="@string/vibration_on"
             icon="@drawable/vibration_on"
             notificationText="@string/notification_vibration_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT17_VIBRATION_SENSOR_FALSE;
                s1.displayText=@"NO\nVIBRATION";
                s1.notificationText = NSLocalizedString(@"'s vibration stopped.", @"'s vibration stopped.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT17_VIBRATION_SENSOR_TRUE;
                s2.displayText=@"VIBRATION";
                s2.notificationText = NSLocalizedString(@" detected Vibration.", @" detected Vibration.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_RemoteControl_18: {
            /*
             <Sensor
             name="UnKnown Sensor"
             deviceType="18"
             isActuator="false"
             defaultIcon="@drawable/switch_off" >
             <Index
             id="1"
             name="STATE"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/value_false"
             icon="@drawable/switch_off"
             notificationText="@string/notification_switch_off" />
             <Value
             data="true"
             displayText="@string/value_true"
             icon="@drawable/switch_on"
             notificationText="@string/notification_switch_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"18_vibration_no";
                s1.displayText=@"NO\nVIBRATION";
                
                s1.notificationText = NSLocalizedString(@" turned Off.", @" turned Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"18_vibration_yes";
                
                s2.displayText=@"VIBRATION";
                s2.notificationText = NSLocalizedString(@" turned On.", @" turned On.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_KeyFob_19: {
            /*
             <Sensor
             name="KeyFob"
             deviceType="19"
             isActuator="false"
             defaultIcon="@drawable/keyfob_off">
             <Index
             id="1"
             name="ARMMODE"
             type="STATE" >
             <Value
             data="0"
             displayText="@string/keyfob_disarmed"
             icon="@drawable/keyfob_off"
             notificationText="@string/notification_keyfob_disarmed" />
             <Value
             data="2"
             displayText="@string/keyfob_permiter_armed"
             icon="@drawable/keyfob_on"
             notificationText="@string/notification_keyfob_permiter_armed" />
             <Value
             data="3"
             displayText="@string/keyfob_armed"
             icon="@drawable/keyfob_on"
             notificationText="@string/notification_keyfob_armed" />
             </Index>
             </Sensor>
             */
            
            if (type == SFIDevicePropertyType_ARMMODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = DT19_KEYFOB_FALSE;
                s1.displayText=@"DISARMED";
                s1.notificationText = NSLocalizedString(@" is Disarmed.", @" is Disarmed.");
                
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"2";
                s2.iconName = @"19_arm_perimeter";
                s2.displayText=@"PERIMETER\nARMED";
                s2.notificationText = NSLocalizedString(@" is Perimeter Armed.", @" is Perimeter Armed.");
                
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"3";
                s3.iconName = DT19_KEYFOB_TRUE;
                s3.displayText=@"ARMED";
                s3.notificationText = NSLocalizedString(@" is Armed.", @" is Armed.");
                
                
                return @[s1, s2, s3];
            }
            
            if (type == SFIDevicePropertyType_PANIC_ALARM) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"true";
                s1.iconName = @"19_panic";
                s1.displayText=@"PANIC";
                s1.notificationText = @" is on panic";
                
                return @[s1];
            }
            
            if(type == SFIDevicePropertyType_EMER_ALARM){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"true";
                s1.iconName = @"19_emergency";
                s1.displayText=@"EMERGENCY";
                s1.notificationText = @" is on emergency";
                
                return @[s1];
            }
            
            
            break;
        }
            
        case SFIDeviceType_Keypad_20: {
            //todo this device id is reassigned!
            /*
             <Sensor
             name="UnKnown Sensor"
             deviceType="20"
             isActuator="false"
             defaultIcon="@drawable/switch_off" >
             <Index
             id="1"
             name="STATE"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/value_false"
             icon="@drawable/switch_off"
             notificationText="@string/notification_switch_off" />
             <Value
             data="true"
             displayText="@string/value_true"
             icon="@drawable/switch_on"
             notificationText="@string/notification_switch_on" />
             </Index>
             </Sensor>
             */
            
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"20_switch_off";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName =  @"20_switch_on";;
                s2.notificationText = NSLocalizedString(@" is turned On.", @" is turned On.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_StandardWarningDevice_21: {
            /*
             <Sensor
             name="Alarm"
             deviceType="21"
             isActuator="true"
             defaultIcon="@drawable/alarm_off">
             <Index
             id="1"
             name="ALARM_STATE"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/off"
             icon="@drawable/alarm_off"
             notificationText="@string/notification_alarm_off"
             toggleValue="true" />
             <Value
             data="true"
             displayText="@string/alarm_on"
             icon="@drawable/alarm_on"
             notificationText="@string/notification_alarm_on"
             toggleValue="false"/>
             </Index>
             </Sensor>
             */
            
            if (type == SFIDevicePropertyType_ALARM_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.displayText=@"SILENT";
                s1.iconName = DT21_STANDARD_WARNING_DEVICE_FALSE;
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");
                s1.layoutType = nil;
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"1";
                s2.matchType = MatchType_equals;
                s2.layoutType=@"textButton";
                s2.iconName = DT21_STANDARD_WARNING_DEVICE_TRUE;
                s2.displayText=@"ALARM";
                s2.minValue = 0;
                s2.maxValue = 65535;
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@" is turned on for ", @" is turned on for ");
               // s2.valueFormatter.suffix = NSLocalizedString(@" seconds", @" seconds");
                s2.valueFormatter.suffix = @"sec";
                

                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"65535";
                s3.displayText=@"RINGING";
                s3.matchType = MatchType_not_equals;
                s3.iconName = DT21_STANDARD_WARNING_DEVICE_TRUE;
                s3.valueFormatter.action = ValueFormatterAction_formatString;
                s3.valueFormatter.notificationPrefix = NSLocalizedString(@" is turned on for ", @" is turned on for ");
                s3.valueFormatter.suffix = NSLocalizedString(@" seconds", @" seconds");
                s3.layoutType = nil;
                return @[s2, s1, s3];
            }
            
            break;
        }
            
        case SFIDeviceType_SmartACSwitch_22: {
            /*
             <Sensor
             name="AC Switch"
             deviceType="22"
             isActuator="true"
             defaultIcon="@drawable/ac_switch_off" >
             <Index
             id="1"
             name="SWITCH BINARY"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/off"
             icon="@drawable/ac_switch_off"
             notificationText="@string/notification_switch_off"
             toggleValue="true" />
             <Value
             data="true"
             displayText="@string/on"
             icon="@drawable/ac_switch_on"
             notificationText="@string/notification_switch_on"
             toggleValue="false" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT22_AC_SWITCH_FALSE;
                s1.displayText=@"OFF";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT22_AC_SWITCH_TRUE;
                s2.displayText=@"ON";
                s2.notificationText = NSLocalizedString(@" is turned On.", @" is turned On.");
                
                return @[s1, s2];
            }
            
            // Add a catch-all:
            // For now, because the cloud and Almond router are not sophisticated enough, we have to suppress
            // all notifications except for index 1
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.notificationIgnoreIndex = YES;
            s1.matchType = MatchType_any;
            return @[s1];
        }
            
        case SFIDeviceType_SmartDCSwitch_23: {
            /*
             
             */
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT23_DC_SWITCH_FALSE;
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");;
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT23_DC_SWITCH_TRUE;
                s2.notificationText = NSLocalizedString(@" is turned On.", @" is turned On.");
                
                return @[s1, s2];
            }
            
            // Add a catch-all:
            // For now, because the cloud and Almond router are not sophisticated enough, we have to suppress
            // all notifications except for index 1
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.notificationIgnoreIndex = YES;
            s1.matchType = MatchType_any;
            return @[s1];
        }
            
        case SFIDeviceType_OccupancySensor_24: {
            if (type == SFIDevicePropertyType_OCCUPANCY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"41_motion_false";
                s1.displayText=@"NO MOTION";
                s1.notificationText = NSLocalizedString(@": no presence detected.", @": no presence detected.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"41_motion_true";
                s2.displayText=@"MOTION";
                s2.notificationText = NSLocalizedString(@": presence detected.", @": presence detected.");
                
                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.layoutType=@"dimButton";
                s1.iconName = @"n_07_thermostat";
                s1.displayText=@"TEMPERATURE";
                s1.minValue = 0;
                s1.maxValue = 122;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = NSLocalizedString(@"\u00B0F", @"\u00B0F");
                
                return @[s1];
            }
            if (type == SFIDevicePropertyType_HUMIDITY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.layoutType=@"dimButton";
                s1.iconName = @"humidity";
                s1.minValue = 0;
                s1.maxValue = 100;
                s1.displayText=@"HUMIDTY";
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s humidiy changed to ", @"'s humidiy changed to ");
                s1.valueFormatter.suffix = @"%";
                
                return @[s1];
            }
            
            break;
        }
            
        case SFIDeviceType_LightSensor_25: {
            /*
             <Sensor
             name="Light Sensor"
             deviceType="25"
             isActuator="false"
             defaultIcon="@drawable/light_off">
             <Index
             id="1"
             name="ILLUMINANCE"
             type="STATE" >
             <Value
             data="0 lux"
             displayText="0 lux"
             icon="@drawable/light_off" >
             <ValueFormatter
             action="formatString"
             prefix="@string/light_prefix"
             notificationPrefix="@string/notification_light_prefix" />
             </Value>
             <Value icon="@drawable/light_on" >
             <ValueFormatter
             action="formatString"
             prefix="@string/light_prefix"
             notificationPrefix="@string/notification_light_prefix" />
             </Value>
             </Index>
             </Sensor>
             */
            
            if (type == SFIDevicePropertyType_ILLUMINANCE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0 lux";
                s1.matchType = MatchType_equals;
                s1.layoutType=@"dimButton";
                s1.iconName = @"energy";
                s1.displayText=@"LUX";
                s1.minValue = 0;
                s1.maxValue = 3000;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s light reading changed to ", @"'s light reading changed to ");
                s1.valueFormatter.suffix = @"%";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0 lux";
                s2.matchType = MatchType_not_equals;
                s2.layoutType=@"dimButton";
                s2.iconName = @"25_bulb_on";
                s2.displayText=@"LUX";
                s2.minValue = 0;
                s2.maxValue = 3000;
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@"'s light reading changed to ", @"'s light reading changed to ");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_WindowCovering_26: {
            /*
             <Sensor
             name="Window Covering"
             deviceType="26"
             isActuator="false"
             defaultIcon="@drawable/door_off" >
             <Index
             id="1"
             name="STATE"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/door_off"
             icon="@drawable/window"
             notificationText="@string/notification_door_off" />
             <Value
             data="true"
             displayText="@string/door_on"
             icon="@drawable/window"
             notificationText="@string/notification_door_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT26_WINDOW_COVERING_FALSE;
                s1.displayText=@"CLOSED";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT26_WINDOW_COVERING_TRUE;
                s2.displayText=@"OPEN";
                s2.notificationText = NSLocalizedString(@" is Opened.", @" is Opened.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_TemperatureSensor_27: {
            /*
             <Sensor
             name="Temperature Sensor"
             deviceType="27"
             isActuator="false"
             defaultIcon="@drawable/thermostat">
             <Index
             id="1"
             name="TEMPERATURE"
             type="STATE"
             iconType="text">
             <Value>
             <ValueFormatter
             action="formatString"
             notificationPrefix="@string/thermostat_temp" />
             </Value>
             </Index>
             <Index
             id="2"
             name="HUMIDITY"
             type="PRIMARY ATTRIBUTE">
             <Value>
             <ValueFormatter
             action="formatString"
             prefix="@string/humidity"
             notificationPrefix="@string/notification_humidity_prefix" />
             </Value>
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.layoutType=@"dimButton";
                s1.iconName = @"n_07_thermostat";
                s1.displayText=@"TEMPERATURE";
                s1.minValue = 0;
                s1.maxValue = 100;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = NSLocalizedString(@"\u00B0F", @"\u00B0F");
                
                return @[s1];
            }
            
            
            if (type == SFIDevicePropertyType_HUMIDITY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.layoutType=@"dimButton";
                s1.iconName = @"humidity";
                s1.displayText=@"HUMIDTY";
                s1.minValue = 0;
                s1.maxValue = 100;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s humidiy changed to ", @"'s humidiy changed to ");
                s1.valueFormatter.suffix = @"%";
                
                return @[s1];
            }
            
            break;
        }
            
        case SFIDeviceType_ZigbeeDoorLock_28: {
            /*
             <Sensor
             name="ZigbeeDoorLock"
             deviceType="28"
             isActuator="true"
             defaultIcon="@drawable/doorlock_off">
             <Index
             id="1"
             name="LOCK_STATE"
             type="STATE" >
             <Value
             data="0"
             displayText="@string/doorlock_partial"
             icon="@drawable/doorlock_off"
             notificationText="@string/notification_doorlock_partial"
             />
             <Value
             data="1"
             displayText="@string/doorlock_on"
             icon="@drawable/doorlock_on"
             notificationText="@string/notification_doorlock_on"
             toggleValue="false" />
             <Value
             data="2"
             displayText="@string/doorlock_off"
             icon="@drawable/doorlock_off"
             notificationText="@string/notification_doorlock_off"
             toggleValue="false" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_LOCK_STATE) {
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"1";
                s2.displayText=@"LOCKED";
                s2.iconName = @"05_door_lock_locked";//md01 was @"28_door_lock_locked";
                s2.notificationText = NSLocalizedString(@" is Locked.", @" is Locked.");
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"2";
                s3.displayText=@"UNLOCKED";
                s3.iconName = @"05_door_lock_unlocked";//md01 was @"28_door_lock_unlocked";
                s3.notificationText = NSLocalizedString(@" is Unlocked.", @" is Unlocked.");
                
                return @[s2, s3];
            }
            
            //no such device property for 28
            if (type == SFIDevicePropertyType_USER_CODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = nil;
                s1.iconName = @"28_door_lock_locked";
                s1.displayText=@"IR CODE";
                s1.notificationText = NSLocalizedString(@"'s pin code changed.", @"'s pin code changed.");
                
                return @[s1];
            }
            
            break;
        }
            
        case SFIDeviceType_ColorControl_29:
            break;
        case SFIDeviceType_PressureSensor_30:
            break;
        case SFIDeviceType_FlowSensor_31:
            break;
        case SFIDeviceType_ColorDimmableLight_32:
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"48_hue_bulb_off";
                s1.displayText=@"OFF";
                s1.notificationText = NSLocalizedString(@" is switched Off.", @" is switched Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"48_hue_bulb_on";
                s2.displayText=@"ON";
                s2.notificationText = NSLocalizedString(@" is switched On.", @" is switched On.");
                
                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_CURRENT_HUE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.valueTransformer = ^NSString *(NSString *value) {
                    if (!value) {
                        return @"";
                    }
                    
                    float hue = [value floatValue];
                    hue = hue / 65535;
                    
                    UIColor *color = [UIColor colorWithHue:hue saturation:100 brightness:100 alpha:1.0];
                    return [color.hexString uppercaseString];
                };
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.layoutType=@"dimButton";
                s1.displayText=@"HUE\nCOLOR";
                s1.minValue = 0;
                s1.maxValue = 255;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" hue color changed to ", @" hue color changed to ");
                return @[s1];
            }
            if (type == SFIDevicePropertyType_CURRENT_SATURATION) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.displayText=@"SATURATION";
                s1.layoutType = @"dimButton";
                s1.minValue = 0;
                s1.maxValue = 255;
                s1.valueFormatter.maxValue = 254;
                s1.valueFormatter.scaledMaxValue = 100;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" saturation changed to ", @" saturation changed to ");
                s1.valueFormatter.suffix = @"%";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.displayText=@"BRIGHTNESS";
                s1.layoutType = @"dimButton";
                s1.minValue = 0;
                s1.maxValue = 255;
                s1.valueFormatter.maxValue = 255;
                s1.valueFormatter.scaledMaxValue = 100;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" brightness changed to ", @" brightness changed to ");
                s1.valueFormatter.suffix = @"%";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_COLOR_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.layoutType=@"dimButton";
                s1.iconName = @"n_07_thermostat";
                s1.displayText=@"TEMPERATURE";
                s1.minValue = 1000;
                s1.maxValue = 9000;
                s1.notificationText = NSLocalizedString(@"'s color temperature changed to .", @"'s color temperature changed to .");
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s color temperature changed to ", @"'s color temperature changed to ");
                s1.valueFormatter.suffix = @"Kelvin";
                return @[s1];
            }
            
            break;
        case SFIDeviceType_HAPump_33:
            break;
        case SFIDeviceType_Shade_34:
            break;
            
        case SFIDeviceType_SmokeDetector_36: {
            /*
             <Sensor
             name="Z-wave Smoke Sensor"
             deviceType="36"
             isActuator="false"
             defaultIcon="@drawable/fire_off">
             <Index
             id="1"
             name="BASIC"
             type="STATE" >
             <Value
             data="0"
             displayText="@string/ok"
             icon="@drawable/fire_off"
             notificationText="@string/notification_smoke_off" />
             <Value
             data="255"
             displayText="@string/smoke_on"
             icon="@drawable/fire_on"
             notificationText="@string/notification_smoke_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_BASIC) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = DT36_SMOKE_DETECTOR_FALSE;
                s1.displayText=@"NO SMOKE";
                s1.notificationText = NSLocalizedString(@"'s Smoke is gone.", @"'s Smoke is gone.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.iconName = DT36_SMOKE_DETECTOR_TRUE;
                s2.displayText=@"SMOKE";
                s2.notificationText = NSLocalizedString(@" detected Smoke.", @" detected Smoke.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_FloodSensor_37: {
            /*
             <Sensor
             name="Z-wave Water Sensor"
             deviceType="37"
             isActuator="false"
             defaultIcon="@drawable/water_off" >
             <Index
             id="1"
             name="BASIC"
             type="STATE" >
             <Value
             data="0"
             displayText="@string/ok"
             icon="@drawable/water_off"
             notificationText="@string/notification_water_off" />
             <Value
             data="255"
             displayText="@string/water_on"
             icon="@drawable/water_on"
             notificationText="@string/notification_water_on" />
             </Index>
             </Sensor>
             */
            
            if (type == SFIDevicePropertyType_BASIC) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = DT37_FLOOD_FALSE;
                s1.displayText=@"NO\nWATER";
                s1.notificationText = NSLocalizedString(@" stopped leaking.", @" stopped leaking.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.displayText=@"WATER";
                s2.iconName = DT37_FLOOD_TRUE;
                s2.notificationText = NSLocalizedString(@" detected water.", @" detected water.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_ShockSensor_38: {
            /*
             <Sensor
             name="Vibration Sensor"
             deviceType="38"
             isActuator="false"
             defaultIcon="@drawable/vibration_off" >
             <Index
             id="1"
             name="SENSOR BINARY"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/vibration_off"
             icon="@drawable/vibration_off"
             notificationText="@string/notification_vibration_off" />
             <Value
             data="true"
             displayText="@string/vibration_on"
             icon="@drawable/vibration_on"
             notificationText="@string/notification_vibration_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_SENSOR_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName =DT38_SHOCK_FALSE;
                s1.displayText=@"NO\nVIBRATION";
                s1.notificationText = NSLocalizedString(@"'s vibration stopped.", @"'s vibration stopped.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT38_SHOCK_TRUE;
                s2.displayText=@"VIBRATION";
                s2.notificationText = NSLocalizedString(@" detected Vibration.", @" detected Vibration.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_DoorSensor_39: {
            /*
             <Sensor
             name="Door Sensor"
             deviceType="39"
             isActuator="false"
             defaultIcon="@drawable/door_off" >
             <Index
             id="1"
             name="SENSOR BINARY"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/door_off"
             icon="@drawable/door_off"
             notificationText="@string/notification_door_off" />
             <Value
             data="true"
             displayText="@string/door_on"
             icon="@drawable/door_on"
             notificationText="@string/notification_door_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_SENSOR_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT39_DOOR_SENSOR_CLOSED;
                s1.displayText=@"CLOSED";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT39_DOOR_SENSOR_OPEN;
                s2.displayText=@"OPEN";
                s2.notificationText = NSLocalizedString(@" is Opened.", @" is Opened.");
                
                return @[s1, s2];
            }
        }
            break;
        case SFIDeviceType_MoistureSensor_40: {
            /*
             <Sensor
             name="Moisture Sensor"
             deviceType="40"
             isActuator="false"
             defaultIcon="@drawable/water_off"  >
             <Index
             id="1"
             name="BASIC"
             type="STATE" >
             <Value
             data="0"
             displayText="@string/ok"
             icon="@drawable/water_off"
             notificationText="@string/notification_water_off" />
             <Value
             data="255"
             displayText="@string/water_on"
             icon="@drawable/water_on"
             notificationText="@string/notification_water_on" />
             </Index>
             <Index
             id="2"
             name="TEMPERATURE"
             type="PRIMARY ATTRIBUTE" >
             <Value>
             <ValueFormatter
             action="formatString"
             prefix="@string/temperature_prefix"
             notificationPrefix="@string/thermostat_temp"/>
             </Value>
             </Index>
             </Sensor>
             */
            
            if (type == SFIDevicePropertyType_BASIC) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"0";
                s1.iconName = DT40_MOISTURE_TRUE;
                s1.displayText=@"NO\nWATER";
                s1.notificationText = NSLocalizedString(@" stopped leaking.", @" stopped leaking.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"255";
                s2.displayText=@"WATER";
                s2.iconName = DT40_MOISTURE_FALSE;
                s2.notificationText = NSLocalizedString(@" detected water.", @" detected water.");
                
                return @[s1, s2];
            }
            
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.layoutType=@"dimButton";
                s1.iconName = @"n_07_thermostat";
                s1.displayText=@"TEMPERATURE";
                s1.minValue = 0;
                s1.maxValue = 100;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = NSLocalizedString(@"\u00B0F", @"\u00B0F");
                
                return @[s1];
            }
            
            
            break;
        }
            
        case SFIDeviceType_MovementSensor_41: {
            /*
             <Sensor
             name="Motion Sensor"
             deviceType="41"
             isActuator="false"
             defaultIcon="@drawable/motion_off" >
             <Index
             id="1"
             name="SENSOR BINARY"
             type="STATE">
             <Value
             data="false"
             displayText="@string/motion_off"
             icon="@drawable/motion_off"
             notificationText="@string/notification_motion_off" />
             <Value
             data="true"
             displayText="@string/motion_on"
             icon="@drawable/motion_on"
             notificationText="@string/notification_motion_on" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_SENSOR_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT41_MOTION_SENSOR_FALSE;
                s1.displayText=@"MOVEMENT\nOFF";
                s1.notificationText = NSLocalizedString(@"'s motion stopped.", @"'s motion stopped.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT41_MOTION_SENSOR_TRUE;
                s2.displayText=@"MOVEMENT\nON";
                s2.notificationText = NSLocalizedString(@" detected motion.", @" detected motion.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_Siren_42: {
            /*
             <Sensor
             name="Alarm"
             deviceType="42"
             isActuator="true"
             defaultIcon="@drawable/alarm_off">
             <Index
             id="1"
             name="SWITCH BINARY"
             type="STATE">
             <Value
             data="false"
             displayText="@string/off"
             icon="@drawable/alarm_off"
             notificationText="@string/notification_alarm_off"
             toggleValue="true" />
             <Value
             data="true"
             displayText="@string/alarm_on"
             icon="@drawable/alarm_on"
             notificationText="@string/notification_alarm_on"
             toggleValue="false" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_SENSOR_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT42_ALARM_FALSE;
                s1.displayText=@"OFF";
                s1.notificationText = @" is Silent.";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.displayText=@"ON";
                s2.iconName = DT42_ALARM_TRUE;
                s2.notificationText = @" is Ringing.";
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_MultiSwitch_43:
            if (type == SFIDevicePropertyType_SWITCH_BINARY1) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.displayText=@"SWITCH1\nOFF";
                s1.iconName = @"01_switch_off";//md01 was @"44_switch_off";
                s1.notificationText = NSLocalizedString(@" is switched Off.", @" is switched Off.");
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.displayText=@"SWITCH1\nON";
                s2.iconName = @"01_switch_on";//md01 was @"44_switch_on";
                s2.notificationText = NSLocalizedString(@" is switched On.", @" is switched On.");
                
                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_SWITCH_BINARY2) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.displayText=@"SWITCH2\nOFF";
                s1.iconName = @"01_switch_off";//md01 was @"44_switch_off";
                s1.notificationText = NSLocalizedString(@" is switched Off.", @" is switched Off.");
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.displayText=@"SWITCH2\nON";
                s2.iconName = @"01_switch_on";//md01 was @"44_switch_on";
                s2.notificationText = NSLocalizedString(@" is switched On.", @" is switched On.");
                
                return @[s1, s2];
            }
            break;
            
        case SFIDeviceType_UnknownOnOffModule_44: {
            /*
             <Sensor
             name="UnKnown Sensor"
             deviceType="44"
             isActuator="true"
             defaultIcon="@drawable/switch_off">
             <Index
             id="1"
             name="SWITCH BINARY"
             type="STATE">
             <Value
             data="false"
             displayText="@string/value_false"
             icon="@drawable/switch_off"
             notificationText="@string/notification_switch_off"
             toggleValue="true"/>
             <Value
             data="true"
             displayText="@string/value_true"
             icon="@drawable/switch_on"
             notificationText="@string/notification_switch_on"
             toggleValue="false" />
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.displayText=@"OFF";
                s1.iconName = @"01_switch_off";//md01 was @"44_switch_off";
                s1.notificationText = NSLocalizedString(@" is switched Off.", @" is switched Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.displayText=@"ON";
                s2.iconName = @"01_switch_on";//md01 was @"44_switch_on";
                s2.notificationText = NSLocalizedString(@" is switched On.", @" is switched On.");
                
                return @[s1, s2];
            }
            
            if (type == SFIDevicePropertyType_SWITCH_BINARY2) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"01_switch_off";//md01 was @"44_switch_off";
                s1.notificationText = NSLocalizedString(@" is switched Off.", @" is switched Off.");
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"01_switch_on";//md01 was @"44_switch_on";
                s2.notificationText = NSLocalizedString(@" is switched On.", @" is switched On.");
                
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_BinaryPowerSwitch_45: {
            /*
             <Sensor
             name="Binary Power Switch"
             deviceType="45"
             isActuator="true"
             defaultIcon="@drawable/ac_switch_off">
             <Index
             id="1"
             name="SWITCH BINARY"
             type="STATE" >
             <Value
             data="false"
             displayText="@string/off"
             icon="@drawable/ac_switch_off"
             notificationText="@string/notification_switch_off"
             toggleValue="true" />
             <Value
             data="true"
             displayText="@string/on"
             icon="@drawable/ac_switch_on"
             notificationText="@string/notification_switch_on"
             toggleValue="false" />
             </Index>
             <Index
             id="2"
             name="POWER"
             type="PRIMARY ATTRIBUTE">
             <Value>
             <ValueFormatter
             action="formatString"
             prefix="@string/power_prefix"
             notificationPrefix="@string/notification_power_prefix"
             />
             </Value>
             </Index>
             </Sensor>
             */
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT45_BINARY_POWER_FALSE;
                s1.displayText=@"OFF";
                s1.notificationText = NSLocalizedString(@" is switched Off.", @" is switched Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = DT45_BINARY_POWER_TRUE;
                s2.displayText=@"ON";
                s2.notificationText = NSLocalizedString(@" is switched On.", @" is switched On.");
                
                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_POWER) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.layoutType=@"dimButton";
                s1.iconName = @"energy";
                s1.displayText=@"POWER";
                s1.minValue = 0;
                s1.maxValue = 9999;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s power reading changed to ", @"'s power reading changed to ");
                s1.valueFormatter.suffix = @"W";
                return @[s1];
            }
            
            break;
        }
            
        case SFIDeviceType_SetPointThermostat_46: {
            if (type == SFIDevicePropertyType_THERMOSTAT_SETPOINT) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.displayText = @"SET THERMOSTAT";
                s1.layoutType = @"dimButton";
                s1.iconName = @"target_temperature";
                s1.minValue = 40;
                s1.maxValue = 104;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature set point changed to ", @"'s temperature set point changed to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"35";
                s1.displayText=@"TEMPERATURE";
                s1.iconName = @"n_07_thermostat";
                s1.layoutType=@"dimButton";
                s1.minValue = 32;
                s1.maxValue = 122;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = NSLocalizedString(@"\u00B0F", @"\u00B0F");
                return @[s1];
            }
            
            break;
        }
            
        case SFIDeviceType_HueLamp_48:{
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"48_hue_bulb_off";
                s1.displayText=@"OFF";
                s1.notificationText = NSLocalizedString(@" is switched Off.", @" is switched Off.");
                
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.displayText=@"ON";
                s2.iconName = @"48_hue_bulb_on";
                s2.notificationText = NSLocalizedString(@" is switched On.", @" is switched On.");
                
                
                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_COLOR_HUE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.iconName = DT25_LIGHT_SENSOR_TRUE;
                s1.displayText=@"HUE";
                s1.layoutType = @"dimButton";
                s1.valueTransformer = ^NSString *(NSString *value) {
                    if (!value) {
                        return @"";
                    }
                    
                    float hue = [value floatValue];
                    hue = hue / 65535;
                    
                    UIColor *color = [UIColor colorWithHue:hue saturation:100 brightness:100 alpha:1.0];
                    //                    NSDictionary *attr = @{
                    //                            NSBackgroundColorAttributeName : color,
                    //                    }
                    //                    NSAttributedString *a = [[NSAttributedString alloc] initWithString:@"\u25a1" attributes:attr];
                    
                    return [color.hexString uppercaseString];
                };
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" hue color changed to ", @" hue color changed to ");
                s1.valueFormatter.suffix = @" Color";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_SATURATION) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.iconName = @"saturation_icon";
                s1.displayText=@"SATURATION";
                s1.layoutType = @"dimButton";
                s1.valueFormatter.maxValue = 255;
                s1.valueFormatter.scaledMaxValue = 100;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" saturation changed to ", @" saturation changed to ");
                s1.valueFormatter.suffix = @"%";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_BRIGHTNESS) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.iconName = @"brightness-icon";
                s1.displayText=@"BRIGHTNESS";
                s1.layoutType = @"dimButton";
                s1.valueFormatter.maxValue = 255;
                s1.valueFormatter.scaledMaxValue = 100;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" brightness changed to ", @" brightness changed to ");
                s1.valueFormatter.suffix = @"%";
                return @[s1];
            }
            
            break;
        }
            
        case SFIDeviceType_MultiSensor_49: {
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"11_motion_false";
                s1.displayText =@"NO MOTION";
                s1.notificationText = NSLocalizedString(@"'s motion stopped.", @"'s motion stopped.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"11_motion_true";
                s2.displayText = @"MOTION\nDETECTED";
                s2.notificationText = NSLocalizedString(@" detected motion.", @" detected motion.");
                
                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_ILLUMINANCE) {
//                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
//                s1.matchType = MatchType_equals;
//                s1.matchData = @"lux";
//                s1.layoutType=@"dimButton";
//                s1.iconName = DT25_LIGHT_SENSOR_TRUE;
//                s1.displayText=@"";
//                s1.minValue = 0;
//                s1.maxValue = 100;
//                s1.valueFormatter.action = ValueFormatterAction_formatString;
//                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s light reading changed to ", @"'s light reading changed to ");
//                s1.valueFormatter.suffix = @"%";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0";
                s2.layoutType=@"dimButton";
                s2.matchType = MatchType_not_equals;
                s2.iconName = DT25_LIGHT_SENSOR_TRUE;
                s2.displayText=@"ILLUMINANCE";
                s2.minValue = 0;
                s2.maxValue = 100;
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@"'s light reading changed to ", @"'s light reading changed to ");
                s2.valueFormatter.suffix = @"%";
                return @[s2];
                
            }
            if (type == SFIDevicePropertyType_ILLUMINANCE_PERCENT) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0 %";
                s1.matchType = MatchType_equals;
                s1.iconName = @"25_bulb_off";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s light reading changed to ", @"'s light reading changed to ");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0 %";
                s2.matchType = MatchType_not_equals;
                s2.iconName = @"25_bulb_on";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@"'s light reading changed to ", @"'s light reading changed to ");
                
                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"35";
                s1.displayText=@"TEMPERATURE";
                s1.layoutType=@"dimButton";
                s1.iconName = @"n_07_thermostat";
                s1.minValue = 0;
                s1.maxValue = 104;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = NSLocalizedString(@"\u00B0F", @"\u00B0F");
                
                return @[s1];
            }
            
            if (type == SFIDevicePropertyType_HUMIDITY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.layoutType=@"dimButton";
                s1.iconName = @"humidity";
                s1.displayText=@"HUMIDTY";
                s1.minValue = 0;
                s1.maxValue = 100;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s humidiy changed to ", @"'s humidiy changed to ");
                s1.valueFormatter.suffix = @"%";
                
                return @[s1];
            }
            break;
        }
            
        case SFIDeviceType_SecurifiSmartSwitch_50: {
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = DT50_SECURIFI_SMART_SWITCH_FALSE;
                s1.displayText=@"OFF";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.displayText=@"ON";
                s2.iconName = DT50_SECURIFI_SMART_SWITCH_TRUE;
                s2.notificationText = NSLocalizedString(@" is turned On.", @" is turned On.");
                
                return @[s1, s2];
            }
            
            // Add a catch-all:
            // For now, because the cloud and Almond router are not sophisticated enough, we have to suppress
            // all notifications except for index 1
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.notificationIgnoreIndex = YES;
            s1.matchType = MatchType_any;
            return @[s1];
            
            break;
        }
            
        case SFIDeviceType_RollerShutter_52:{
            if (type == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = DT53_GARAGE_SENSOR_CLOSED;
                s1.displayText=@"CLOSED";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");
                
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"99";
                s2.displayText=@"OPEN";
                s2.iconName = DT53_GARAGE_SENSOR_OPEN;
                s2.notificationText = NSLocalizedString(@" is Open.", @" is Open.");
                
                return @[s1, s2];
                
            }
            
            if (type == SFIDevicePropertyType_UP_DOWN) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"99";
                s1.displayText=@"UP";
                s1.iconName = DT53_GARAGE_SENSOR_UP;
                s1.notificationText = NSLocalizedString(@" is Opening.", @" is Opening.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0";
                s2.displayText=@"DOWN";
                s2.iconName = DT53_GARAGE_SENSOR_DOWN;
                s2.notificationText = NSLocalizedString(@" is Closing.", @" is Closing.");
                
                return @[s1,s2];
            }
            
            if (type == SFIDevicePropertyType_STOP) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.displayText=@"STOP";
                s1.iconName = DT53_GARAGE_SENSOR_STOPPED;
                s1.notificationText = NSLocalizedString(@" is Stopped.", @" is Stopped.");
                
                return @[s1];
            }
            break;
        }
        case SFIDeviceType_GarageDoorOpener_53: {
            /*
             0	we can set 0 (to close) and 255(to open) only	Closed
             252		closing
             253		Stopped
             254		Opening
             255		Open
             */
            if (type == SFIDevicePropertyType_BARRIER_OPERATOR) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = DT53_GARAGE_SENSOR_CLOSED;
                s1.displayText=@"CLOSED";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"252";
                s2.displayText=@"CLOSING";
                s2.iconName = DT53_GARAGE_SENSOR_DOWN;
                s2.notificationText = NSLocalizedString(@" is Closing.", @" is Closing.");
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"253";
                s3.displayText=@"STOPPED";
                s3.iconName = DT53_GARAGE_SENSOR_STOPPED;
                s3.notificationText = NSLocalizedString(@" is Stopped.", @" is Stopped.");
                
                IndexValueSupport *s4 = [[IndexValueSupport alloc] initWithValueType:type];
                s4.matchData = @"254";
                s4.displayText=@"OPENING";
                s4.iconName = DT53_GARAGE_SENSOR_UP;
                s4.notificationText = NSLocalizedString(@" is Opening.", @" is Opening.");
                
                IndexValueSupport *s5 = [[IndexValueSupport alloc] initWithValueType:type];
                s5.matchData = @"255";
                s5.displayText=@"OPEN";
                s5.iconName = DT53_GARAGE_SENSOR_OPEN;
                s5.notificationText = NSLocalizedString(@" is Open.", @" is Open.");
                
                return @[s1, s2, s3, s4, s5];
            }
            break;
        }
            
        case SFIDeviceType_ZWtoACIRExtender_54:{
            if (type == SFIDevicePropertyType_SENSOR_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.displayText=@"TEMPERATURE";
                s1.matchData = @"70";
                s1.iconName = @"target_temperature";
                s1.minValue=32;
                s1.maxValue=104;
                s1.layoutType=@"dimButton";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if(type == SFIDevicePropertyType_AC_MODE){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Auto";
                s1.displayText=@"AUTO";
                s1.iconName = @"imgAuto";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @" is set to ";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_any;
                s2.matchData = @"Heat";
                s2.displayText = @"HEAT";
                s2.iconName = @"imgHeat";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = @" is set to ";
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_any;
                s3.matchData = @"Cool";
                s3.iconName = @"imgCool";
                s3.displayText = @"COOL";
                s3.valueFormatter.action = ValueFormatterAction_formatString;
                s3.valueFormatter.notificationPrefix = @" is set to ";
                
                return @[s1,s2,s3];
                
            }
            if(type == SFIDevicePropertyType_AC_SETPOINT_HEATING){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.displayText = @"HEATING\nTEMP.";
                s1.layoutType=@"dimButton";
                s1.iconName = @"target_temperature";
                s1.minValue = 61;
                s1.maxValue = 86;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix =@" is heating up to ";
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
                
            }
            
            if (type == SFIDevicePropertyType_AC_SETPOINT_COOLING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.displayText = @"COOLING\nTEMP.";
                s1.layoutType = @"dimButton";
                s1.iconName = @"target_temperature";
                s1.minValue = 61;
                s1.maxValue = 86;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix =@" is cooling down to ";
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            
            if (type == SFIDevicePropertyType_AC_FAN_MODE) { // to do, icons
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Auto";
                s1.iconName = @"54_fan_auto";
                s1.displayText=@"AUTO";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @"Fan is set to ";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_any;
                s2.matchData = @"On Low";
                s2.iconName = @"54_fan_low";
                s2.displayText = @"ON LOW";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = @" Fan is set to ";
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_any;
                s3.matchData = @"Medium";
                s3.iconName = @"54_fan_medium";
                s3.displayText = @"MEDIUM";
                s3.valueFormatter.action = ValueFormatterAction_formatString;
                s3.valueFormatter.notificationPrefix = @" Fan is set to ";
                
                IndexValueSupport *s4 = [[IndexValueSupport alloc] initWithValueType:type];
                s4.matchType = MatchType_any;
                s4.matchData = @"On High";
                s4.iconName = @"54_fan_high";
                s4.displayText = @"ON HIGH";
                s4.valueFormatter.action = ValueFormatterAction_formatString;
                s4.valueFormatter.notificationPrefix = @" Fan is set to ";
                
                return @[s1,s2,s3,s4];
            }
            
            if (type == SFIDevicePropertyType_UNITS) { //to do
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"50";
                s1.iconName = @"";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.displayText=@"UNITS";
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                
                return @[s1];
            }
            
            if (type == SFIDevicePropertyType_AC_SWING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"0";
                s1.iconName = @"54_swingon";
                s1.displayText=@"SWING ON";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @" AC is set to ";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_any;
                s2.matchData = @"1";
                s2.iconName = @"54_swingoff";
                s2.displayText = @"SWING OFF";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = @" AC is set to ";
                
                return @[s1,s2];
            }
            
            
            if (type == SFIDevicePropertyType_BASIC) { //to do, icons
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"0";
                s1.iconName = DT1_BINARY_SWITCH_FALSE;
                s1.displayText=@"OFF";
                s1.notificationText = @" is set to OFF";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"255";
                s2.displayText=@"ON";
                s2.iconName = DT1_BINARY_SWITCH_TRUE;
                s2.notificationText = @" is set to ON";
                
                return @[s1, s2];
            }
            
            if (type == SFIDevicePropertyType_IR_CODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"05_door_lock_locked";
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s IR code changed.", @"'s IR code changed.");
                
                return @[s1];
            }
            
            if (type == SFIDevicePropertyType_CONFIGURATION) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"05_door_lock_locked";
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s configuration changed.", @"'s configuration changed.");
                
                return @[s1];
            }
            
            
            
            break;
        }
            
        case SFIDeviceType_MultiSoundSiren_55:{
            if(type == SFIDevicePropertyType_SWITCH_MULTILEVEL){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = @"42_alarm_no"; //temp
                s1.displayText=@"STOP";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"1";
                s2.displayText=@"EMERGENCY";
                s2.iconName = @"55_multisoundsiren_icon";
                s2.notificationText = NSLocalizedString(@" is Closing.", @" is Closing.");
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"2";
                s3.displayText=@"FIRE";
                s3.iconName = @"55_multisoundsiren_icon";
                s3.notificationText = NSLocalizedString(@" is Stopped.", @" is Stopped.");
                
                IndexValueSupport *s4 = [[IndexValueSupport alloc] initWithValueType:type];
                s4.matchData = @"3";
                s4.displayText=@"AMBULANCE";
                s4.iconName = @"55_multisoundsiren_icon";
                s4.notificationText = NSLocalizedString(@" is Opening.", @" is Opening.");
                
                IndexValueSupport *s5 = [[IndexValueSupport alloc] initWithValueType:type];
                s5.matchData = @"4";
                s5.displayText=@"POLICE";
                s5.iconName = @"55_multisoundsiren_icon";
                s5.notificationText = NSLocalizedString(@" is Open.", @" is Open.");
                
                IndexValueSupport *s6 = [[IndexValueSupport alloc] initWithValueType:type];
                s6.matchData = @"5";
                s6.displayText=@"DOOR CHIME";
                s6.iconName = @"55_multisoundsiren_icon";
                s6.notificationText = NSLocalizedString(@" is Open.", @" is Open.");
                
                IndexValueSupport *s7 = [[IndexValueSupport alloc] initWithValueType:type];
                s7.matchData = @"6";
                s7.displayText=@"BEEP";
                s7.iconName = @"55_multisoundsiren_icon";
                s7.notificationText = NSLocalizedString(@" is Open.", @" is Open.");
                
                return @[s1, s2, s3, s4, s5, s6, s7];
            }
            break;
        }
            
        case SFIDeviceType_EnergyReader_56:{
            
            if(type == SFIDevicePropertyType_POWER){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.layoutType=@"dimButton";
                s1.iconName = @"56_energy_reader";
                s1.displayText=@"POWER";
                s1.minValue = 0;
                s1.maxValue = 9999;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s power reading changed to ", @"'s power reading changed to ");
                s1.valueFormatter.suffix = @"W";
                return @[s1];
                
            }
            if(type == SFIDevicePropertyType_ENERGY){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.layoutType=@"dimButton";
                s1.iconName = @"56_energy_reader";
                s1.displayText=@"ENERGY";
                s1.minValue = 0;
                s1.maxValue = 9999;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s power reading changed to ", @"'s power reading changed to ");
                s1.valueFormatter.suffix = @"kWh";
                return @[s1];
                
            }
            if(type == SFIDevicePropertyType_CLAMP1_POWER){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.layoutType=@"dimButton";
                s1.iconName = @"56_energy_reader";
                s1.displayText=@"CLAMP1_POWER";
                s1.minValue = 0;
                s1.maxValue = 9999;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s power reading changed to ", @"'s power reading changed to ");
                s1.valueFormatter.suffix = @"W";
                return @[s1];
                
            }
            if(type == SFIDevicePropertyType_CLAMP1_ENERGY){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.layoutType=@"dimButton";
                s1.iconName = @"56_energy_reader";
                s1.displayText=@"CLAMP1_ENERGY";
                s1.minValue = 0;
                s1.maxValue = 9999;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s power reading changed to ", @"'s power reading changed to ");
                s1.valueFormatter.suffix = @"kWh";
                return @[s1];
                
            }
            if(type == SFIDevicePropertyType_CLAMP2_POWER){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.layoutType=@"dimButton";
                s1.iconName = @"56_energy_reader";
                s1.displayText=@"CLAMP2_POWER";
                s1.minValue = 0;
                s1.maxValue = 9999;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s power reading changed to ", @"'s power reading changed to ");
                s1.valueFormatter.suffix = @"Watts";
                return @[s1];
                
            }
            if(type == SFIDevicePropertyType_CLAMP2_ENERGY){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.layoutType=@"dimButton";
                s1.iconName = @"56_energy_reader";
                s1.displayText=@"CLAMP2_ENERGY";
                s1.minValue = 0;
                s1.maxValue = 9999;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s power reading changed to ", @"'s power reading changed to ");
                s1.valueFormatter.suffix = @"kWh";
                return @[s1];
                
            }
            
            break;
        }
            
            
            
        case SFIDeviceType_NestThermostat_57: {
            
            if (type == SFIDevicePropertyType_NEST_THERMOSTAT_MODE) {
                
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"heat";
                s1.displayText=@"HEAT";
                s1.iconName = @"imgHeat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s mode set to", @"'s mode set to");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_any;
                s2.matchData = @"cool";
                s2.displayText = @"COOL";
                s2.iconName = @"imgCool";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@"'s mode set to", @"'s mode set to");
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_any;
                s3.matchData = @"heat-cool";
                s3.iconName = @"imgAuto";
                s3.displayText = @"HEAT-COOL";
                s3.valueFormatter.action = ValueFormatterAction_formatString;
                s3.valueFormatter.notificationPrefix = NSLocalizedString(@"'s mode set to", @"'s mode set to");
                
                IndexValueSupport *s4 = [[IndexValueSupport alloc] initWithValueType:type];
                s4.matchType = MatchType_any;
                s4.matchData = @"off";
                s4.iconName = @"imgOff";
                s4.displayText = @"OFF";
                s4.valueFormatter.action = ValueFormatterAction_formatString;
                s4.valueFormatter.notificationPrefix = NSLocalizedString(@"'s mode set to", @"'s mode set to");
                
                return @[s1,s2,s3,s4];
            }
            
            if (type == SFIDevicePropertyType_THERMOSTAT_TARGET) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.layoutType = @"dimButton";
                s1.iconName = @"target_temperature";
                s1.displayText = @"TARGET ";
                s1.minValue = 50;
                s1.maxValue = 90;
                s1.notificationText = @"";
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"target temperature is", @"target temperature is");
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            
            if (type == SFIDevicePropertyType_HUMIDITY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.layoutType=@"dimButton";
                s1.iconName = @"humidity";
                s1.displayText=@"HUMIDTY";
                s1.minValue = 0;
                s1.maxValue = 100;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s humidiy changed to ", @"'s humidiy changed to ");
                s1.valueFormatter.suffix = @"%";
                
                return @[s1];
            }
            
            if (type == SFIDevicePropertyType_THERMOSTAT_RANGE_LOW) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.layoutType = @"dimButton";
                s1.iconName = @"n_07_thermostat";
                s1.displayText = @"RANGE LOW";
                s1.minValue = 50;
                s1.maxValue = 87;
                s1.notificationText = NSLocalizedString(@" is cooling down to ", @" is cooling down to ");
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is cooling down to ", @" is cooling down to ");
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            
            if (type == SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.layoutType = @"dimButton";
                s1.iconName = @"n_07_thermostat";
                s1.displayText = @"RANGE HIGH";
                s1.minValue = 53;
                s1.maxValue = 90;
                s1.notificationText = NSLocalizedString(@" is heating up to ", @" is heating up to ");
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is heating up to ", @" is heating up to ");
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            
            if (type == SFIDevicePropertyType_AWAY_MODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"home";
                s1.iconName = @"home_icon";
                s1.displayText = @"HOME";
                s1.notificationText = NSLocalizedString(@"HOME", @"HOME");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"away";
                s2.iconName = @"away_icon";
                s2.displayText = @"AWAY";
                s2.notificationText = NSLocalizedString(@"AWAY", @"AWAY");
                
                //                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                //                s3.matchData = @"Auto Away";
                //                s3.iconName = @"away_icon";
                //                s3.displayText = @"AUTO AWAY";
                //                s3.notificationText = @"";
                //
                //                IndexValueSupport *s4 = [[IndexValueSupport alloc] initWithValueType:type];
                //                s4.matchData = @"Unknown";
                //                s4.iconName = @"55_away_mode_away";
                //                s4.displayText = @"UNKNOWN";
                //                s4.notificationText = @"";
                
                
                return @[s1, s2];
            }
            
            if (type == SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"true";
                s1.iconName = @"imgFanOn";
                s1.displayText = @"FAN ON";
                s1.notificationText = NSLocalizedString(@"'s Fan Started", @"'s Fan Started");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"false";
                s2.iconName = @"imgFanOff";
                s2.displayText = @"FAN OFF";
                s2.notificationText = NSLocalizedString(@"'s Fan Stopped", @"'s Fan Stopped");
                
                return @[s1, s2];
            }
            
            if (type == SFIDevicePropertyType_CURRENT_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"35";
                s1.displayText=@"TEMP ";
                s1.layoutType=@"dimButton";
                s1.iconName = @"n_07_thermostat";
                s1.minValue = -4;
                s1.maxValue = 140;
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = NSLocalizedString(@"\u00B0F", @"\u00B0F");
                
                return @[s1];
            }
            
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.iconName = @"target_temperature";
                s1.notificationText = NSLocalizedString(@"Temperature", @"Temperature");
                return @[s1];
            }
            
            if(type == SFIDevicePropertyType_HVAC_STATE){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"heating";
                s1.displayText = @"Heating";
                s1.iconName = @"imgHeat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to ", @" is set to ");
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_any;
                s2.matchData = @"cooling";
                s2.iconName = @"imgCool";
                s2.displayText = @"COOLING";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to ", @" is set to ");
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_any;
                s3.matchData = @"off";
                s3.iconName = @"imgOff";
                s3.displayText = @"OFF";
                s3.valueFormatter.action = ValueFormatterAction_formatString;
                s3.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to ", @" is set to ");
                
                return @[s1,s2,s3];
                
            }
            if(type == SFIDevicePropertyType_ISONLINE){
                
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"true";
                s1.iconName = DT1_BINARY_SWITCH_TRUE;
                s1.displayText=@"Online";
                s1.notificationText = @" is offline";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"false";
                s2.displayText=@"Offline";
                s2.iconName = DT1_BINARY_SWITCH_FALSE;
                s2.notificationText = @" is now online";
                
                return @[s1, s2];
            }
            
            if (type == SFIDevicePropertyType_IS_USING_EMERGENCY_HEAT) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"true";
                s1.iconName = @"target_temperature";
                s1.notificationText = @" is using Emergency Heat";
                
                return @[s1];
            }
            
            if (type == SFIDevicePropertyType_RESPONSE_CODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"-1";
                s1.iconName = @"tamper";
                s1.notificationText = @" Wrong mode selected";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"-2";
                s2.iconName = @"tamper";
                s2.notificationText = @" Cannot change temperature in Away mode";
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_equals;
                s3.matchData = @"-3";
                s3.iconName = @"tamper";
                s3.notificationText = @" Device is Offline";
                
                IndexValueSupport *s4 = [[IndexValueSupport alloc] initWithValueType:type];
                s4.matchType = MatchType_equals;
                s4.matchData = @"-4";
                s4.iconName = @"tamper";
                s4.notificationText = @" Cannot set fan in Away mode";
                
                IndexValueSupport *s5 = [[IndexValueSupport alloc] initWithValueType:type];
                s5.matchType = MatchType_equals;
                s5.matchData = @"-5";
                s5.iconName = @"tamper";
                s5.notificationText = @" Low temperature can't be more than high temperature";
                
                IndexValueSupport *s6 = [[IndexValueSupport alloc] initWithValueType:type];
                s6.matchType = MatchType_equals;
                s6.matchData = @"-6";
                s6.iconName = @"tamper";
                s6.notificationText = @" Couldn't change HVAC mode as thermostat lock is enabled";
                
                IndexValueSupport *s7 = [[IndexValueSupport alloc] initWithValueType:type];
                s7.matchType = MatchType_equals;
                s7.matchData = @"-7";
                s7.iconName = @"tamper";
                s7.notificationText = @" Cannot set c and f temperatures simultaneously";
                
                IndexValueSupport *s8 = [[IndexValueSupport alloc] initWithValueType:type];
                s8.matchType = MatchType_equals;
                s8.matchData = @"-8";
                s8.iconName = @"tamper";
                s8.notificationText = @" Cannot set target temperature closer than N degrees C/F";
                
                IndexValueSupport *s9 = [[IndexValueSupport alloc] initWithValueType:type];
                s9.matchType = MatchType_equals;
                s9.matchData = @"-9";
                s9.iconName = @"tamper";
                s9.notificationText = @" Target temperature is lower than the range";
                
                IndexValueSupport *s10 = [[IndexValueSupport alloc] initWithValueType:type];
                s10.matchType = MatchType_equals;
                s10.matchData = @"-10";
                s10.iconName = @"tamper";
                s10.notificationText = @" Target temperature is higher than the range";
                
                IndexValueSupport *s11 = [[IndexValueSupport alloc] initWithValueType:type];
                s11.matchType = MatchType_equals;
                s11.matchData = @"-11";
                s11.iconName = @"tamper";
                s11.notificationText = @" Couldn't set target temperature, value is lower than lock temp";
                
                IndexValueSupport *s12 = [[IndexValueSupport alloc] initWithValueType:type];
                s12.matchType = MatchType_equals;
                s12.matchData = @"-12";
                s12.iconName = @"tamper";
                s12.notificationText = @" Couldn't set target temperature, value is higher than lock temp";
                
                IndexValueSupport *s13 = [[IndexValueSupport alloc] initWithValueType:type];
                s13.matchType = MatchType_equals;
                s13.matchData = @"-13";
                s13.iconName = @"tamper";
                s13.notificationText = @" Cannot change HVAC mode during energy-saving events";
                
                IndexValueSupport *s14 = [[IndexValueSupport alloc] initWithValueType:type];
                s14.matchType = MatchType_equals;
                s14.matchData = @"-14";
                s14.iconName = @"tamper";
                s14.notificationText = @" Cannot change HVAC mode";
                
                IndexValueSupport *s15 = [[IndexValueSupport alloc] initWithValueType:type];
                s15.matchType = MatchType_equals;
                s15.matchData = @"-15";
                s15.iconName = @"tamper";
                s15.notificationText = @" Invalid HVAC mode";
                
                IndexValueSupport *s16 = [[IndexValueSupport alloc] initWithValueType:type];
                s16.matchType = MatchType_equals;
                s16.matchData = @"-16";
                s16.iconName = @"tamper";
                s16.notificationText = @" Cannot activate fan during smoke/co safety shutoff";
                
                IndexValueSupport *s17 = [[IndexValueSupport alloc] initWithValueType:type];
                s17.matchType = MatchType_equals;
                s17.matchData = @"-17";
                s17.iconName = @"tamper";
                s17.notificationText = @" Fan timer is not set";
                
                IndexValueSupport *s18 = [[IndexValueSupport alloc] initWithValueType:type];
                s18.matchType = MatchType_equals;
                s18.matchData = @"-18";
                s18.iconName = @"tamper";
                s18.notificationText = @" Emergency Heat is On";
                
                IndexValueSupport *s19 = [[IndexValueSupport alloc] initWithValueType:type];
                s19.matchType = MatchType_equals;
                s19.matchData = @"503";
                s19.iconName = @"tamper";
                s19.notificationText = @" Nest service is unavailable";
                
                IndexValueSupport *s20 = [[IndexValueSupport alloc] initWithValueType:type];
                s20.matchType = MatchType_equals;
                s20.matchData = @"429";
                s20.iconName = @"tamper";
                s20.notificationText = @" Too many requests";
                
                return @[s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20];
            }
            
            break;
        }
        case SFIDeviceType_NestSmokeDetector_58: {
            if (type == SFIDevicePropertyType_RESPONSE_CODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"-1";
                s1.iconName = @"tamper";
                s1.notificationText = @" Wrong mode selected";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"-2";
                s2.iconName = @"tamper";
                s2.notificationText = @" Cannot change temperature in Away mode";
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_equals;
                s3.matchData = @"-3";
                s3.iconName = @"tamper";
                s3.notificationText = @" Device is Offline";
                
                IndexValueSupport *s4 = [[IndexValueSupport alloc] initWithValueType:type];
                s4.matchType = MatchType_equals;
                s4.matchData = @"-4";
                s4.iconName = @"tamper";
                s4.notificationText = @" Cannot set fan in Away mode";
                
                IndexValueSupport *s5 = [[IndexValueSupport alloc] initWithValueType:type];
                s5.matchType = MatchType_equals;
                s5.matchData = @"-5";
                s5.iconName = @"tamper";
                s5.notificationText = @" Low temperature can't be more than high temperature";
                
                IndexValueSupport *s6 = [[IndexValueSupport alloc] initWithValueType:type];
                s6.matchType = MatchType_equals;
                s6.matchData = @"-6";
                s6.iconName = @"tamper";
                s6.notificationText = @" Couldn't change HVAC mode as thermostat lock is enabled";
                
                IndexValueSupport *s7 = [[IndexValueSupport alloc] initWithValueType:type];
                s7.matchType = MatchType_equals;
                s7.matchData = @"-7";
                s7.iconName = @"tamper";
                s7.notificationText = @" Cannot set c and f temperatures simultaneously";
                
                IndexValueSupport *s8 = [[IndexValueSupport alloc] initWithValueType:type];
                s8.matchType = MatchType_equals;
                s8.matchData = @"-8";
                s8.iconName = @"tamper";
                s8.notificationText = @" Cannot set target temperature closer than N degrees C/F";
                
                IndexValueSupport *s9 = [[IndexValueSupport alloc] initWithValueType:type];
                s9.matchType = MatchType_equals;
                s9.matchData = @"-9";
                s9.iconName = @"tamper";
                s9.notificationText = @" Target temperature is lower than the range";
                
                IndexValueSupport *s10 = [[IndexValueSupport alloc] initWithValueType:type];
                s10.matchType = MatchType_equals;
                s10.matchData = @"-10";
                s10.iconName = @"tamper";
                s10.notificationText = @" Target temperature is higher than the range";
                
                IndexValueSupport *s11 = [[IndexValueSupport alloc] initWithValueType:type];
                s11.matchType = MatchType_equals;
                s11.matchData = @"-11";
                s11.iconName = @"tamper";
                s11.notificationText = @" Couldn't set target temperature, value is lower than lock temp";
                
                IndexValueSupport *s12 = [[IndexValueSupport alloc] initWithValueType:type];
                s12.matchType = MatchType_equals;
                s12.matchData = @"-12";
                s12.iconName = @"tamper";
                s12.notificationText = @" Couldn't set target temperature, value is higher than lock temp";
                
                IndexValueSupport *s13 = [[IndexValueSupport alloc] initWithValueType:type];
                s13.matchType = MatchType_equals;
                s13.matchData = @"-13";
                s13.iconName = @"tamper";
                s13.notificationText = @" Cannot change HVAC mode during energy-saving events";
                
                IndexValueSupport *s14 = [[IndexValueSupport alloc] initWithValueType:type];
                s14.matchType = MatchType_equals;
                s14.matchData = @"-14";
                s14.iconName = @"tamper";
                s14.notificationText = @" Cannot change HVAC mode";
                
                IndexValueSupport *s15 = [[IndexValueSupport alloc] initWithValueType:type];
                s15.matchType = MatchType_equals;
                s15.matchData = @"-15";
                s15.iconName = @"tamper";
                s15.notificationText = @" Invalid HVAC mode";
                
                IndexValueSupport *s16 = [[IndexValueSupport alloc] initWithValueType:type];
                s16.matchType = MatchType_equals;
                s16.matchData = @"-16";
                s16.iconName = @"tamper";
                s16.notificationText = @" Cannot activate fan during smoke/co safety shutoff";
                
                IndexValueSupport *s17 = [[IndexValueSupport alloc] initWithValueType:type];
                s17.matchType = MatchType_equals;
                s17.matchData = @"-17";
                s17.iconName = @"tamper";
                s17.notificationText = @" Fan timer is not set";
                
                IndexValueSupport *s18 = [[IndexValueSupport alloc] initWithValueType:type];
                s18.matchType = MatchType_equals;
                s18.matchData = @"-18";
                s18.iconName = @"tamper";
                s18.notificationText = @" Emergency Heat is On";
                
                IndexValueSupport *s19 = [[IndexValueSupport alloc] initWithValueType:type];
                s19.matchType = MatchType_equals;
                s19.matchData = @"503";
                s19.iconName = @"tamper";
                s19.notificationText = @" Nest service is unavailable";
                
                IndexValueSupport *s20 = [[IndexValueSupport alloc] initWithValueType:type];
                s20.matchType = MatchType_equals;
                s20.matchData = @"429";
                s20.iconName = @"tamper";
                s20.notificationText = @" Too many requests";
                
                return @[s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20];
            }
            
            if (type == SFIDevicePropertyType_CO_ALARM_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"warning";
                s1.iconName = @"56_nest_58_icon";
                s1.notificationText = @": CO Warning";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"emergency";
                s2.iconName = @"56_nest_58_icon";
                s2.notificationText = @": CO Emergency";
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_equals;
                s3.matchData = @"ok";
                s3.iconName = @"56_nest_58_icon";
                s3.notificationText = @" CO is not detected";
                
                
                return @[s1, s2, s3];
            }
            
            if(type == SFIDevicePropertyType_SMOKE_ALARM_STATE){
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"warning";
                s1.iconName = @"56_nest_58_icon";
                s1.notificationText = @": Smoke Warning";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"emergency";
                s2.iconName = @"56_nest_58_icon";
                s2.notificationText = @": Smoke Emergency";
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_equals;
                s3.matchData = @"ok";
                s3.iconName = @"56_nest_58_icon";
                s3.notificationText = @" Smoke is not detected";
                
                return @[s1, s2, s3];
            }
            
            if(type == SFIDevicePropertyType_ISONLINE){
                
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"true";
                s1.displayText=@"Online";
                s1.iconName = DT1_BINARY_SWITCH_TRUE;
                s1.notificationText = @" is offline";
                
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"false";
                s2.displayText=@"Offline";
                s2.iconName = DT1_BINARY_SWITCH_FALSE;
                s2.notificationText = @" is now online";
                return @[s1, s2];
            }
            
            break;
        }
            
        case SFIDeviceType_BuiltInSiren_60: {
            
            if (type == SFIDevicePropertyType_ALARM_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName =@"42_alarm_no";
                s1.notificationText = @" is Silent.";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"42_alarm_yes";
                s2.notificationText = @" is Ringing.";
                return @[s1, s2];
            }
            
            if (type == SFIDevicePropertyType_TONE_SELECTED) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"1";
                s1.iconName = @"42_alarm_yes";
                s1.valueFormatter.notificationPrefix = @"tone 1";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"2";
                s2.iconName = @"42_alarm_yes";
                s2.valueFormatter.notificationPrefix = @"tone 2";
                
                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_equals;
                s3.matchData = @"3";
                s3.iconName = @"42_alarm_yes";
                s3.valueFormatter.notificationPrefix = @"tone 3";
                return @[s1, s2, s3];
            }
            
            break;
            
        }
            
        case SFIDeviceType_count:
            break;
            
    }
    
    NSLog(@"between switches");
    // Applicable to any device
    switch (type) {
        case SFIDevicePropertyType_BATTERY: {
            
            //            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            //            s1.matchType = MatchType_equals;
            //            s1.matchData = @"0";
            //            s1.iconName = @"battery_ok";
            //            s1.notificationText = @"'s Battery is OK.";
            
            IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
            s2.matchType = MatchType_not_equals;
            s2.matchData = @"0";
            s2.displayText=@"BATTERY";
            s2.layoutType = @"dimButton";
            s2.iconName = @"low_battery";
            s2.minValue = 0;
            s2.maxValue = 100;
            s2.notificationText = NSLocalizedString(@"'s Battery is Low.", @"'s Battery is Low.");
            s2.valueFormatter.suffix = @"%";
            return @[s2];
        }
            
        case SFIDevicePropertyType_LOW_BATTERY: {
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.matchType = MatchType_equals;
            s1.matchData = @"true";
            s1.iconName = @"low_battery";
            s1.displayText=@"BATTERY\nLOW";
            s1.notificationText = NSLocalizedString(@"'s Battery is Low.", @"'s Battery is Low.");
            return @[s1];
        }
            
        case SFIDevicePropertyType_TAMPER: {
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.matchType = MatchType_equals;
            s1.matchData = @"true";
            s1.iconName = @"n_tamper";
            s1.displayText=@"TAMPER";
            s1.notificationText = NSLocalizedString(@" has been Tampered.", @" has been Tampered.");
            
            //            IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
            //            s2.matchType = MatchType_equals;
            //            s2.matchData = @"false";
            //            s2.iconName = @"n_tamper";
            //            s2.notificationText = NSLocalizedString(@" is reset from Tampered.", @" is reset from Tampered.");
            
            return @[s1];
        }
        default: {
            return [NSArray array];
        }
    }
}

- (NSArray *)indexesFor:(SFIDeviceType)device {
    NSMutableArray *indexes = [NSMutableArray new];
    
    for (unsigned int index = 0; index < SFIDevicePropertyType_count; index++) {
        SFIDevicePropertyType type = (SFIDevicePropertyType) index;
        NSArray *array = [self resolve:device index:type];
        [indexes addObjectsFromArray:array];
    }
    
    return indexes;
}

- (NSArray *)getIndexesFor:(SFIDeviceType)device {
    switch (device) {
        case SFIDeviceType_BinarySwitch_0:{
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] init];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 0;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            return @[deviceIndex1];
        }
        case SFIDeviceType_WIFIClient:{
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] init];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 0;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            return @[deviceIndex1];
        }
        case SFIDeviceType_BinarySwitch_1: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            return @[deviceIndex1];
        }
            
        case SFIDeviceType_MultiLevelSwitch_2: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            return @[deviceIndex1];
        }
            
        case SFIDeviceType_BinarySensor_3: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            return @[deviceIndex1];
        }
        case SFIDeviceType_MultiLevelOnOff_4: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 2;
            deviceIndex1.cellId =1;
            deviceIndex1.isEditableIndex =YES;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex2.indexID = 1;
            deviceIndex2.cellId =1;
            deviceIndex2.isEditableIndex = YES;
            
            return @[deviceIndex2, deviceIndex1];
        }
            
        case SFIDeviceType_DoorLock_5: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_LOCK_STATE];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_LOCK_STATE];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId =1;
            deviceIndex1.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexID = 3;
            deviceIndex2.cellId =2;
            
            return @[deviceIndex1,deviceIndex2];
        }
            
        case SFIDeviceType_Alarm_6: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BASIC];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_BASIC];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 1;
            
            return @[deviceIndex2, deviceIndex1];
        }
            
        case SFIDeviceType_Thermostat_7:{
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING];
            deviceIndex3.indexID=5;
            deviceIndex3.cellId = 1;
            deviceIndex3.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex4=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING];
            deviceIndex4.indexValues=[self resolve:device index:SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING];
            deviceIndex4.indexID=4;
            deviceIndex4.cellId = 1;
            deviceIndex4.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex5=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_THERMOSTAT_MODE];
            deviceIndex5.indexValues=[self resolve:device index:SFIDevicePropertyType_THERMOSTAT_MODE];
            deviceIndex5.indexID=2;
            deviceIndex5.cellId = 2;
            deviceIndex5.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex7=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_THERMOSTAT_FAN_MODE];
            deviceIndex7.indexValues=[self resolve:device index:SFIDevicePropertyType_THERMOSTAT_FAN_MODE];
            deviceIndex7.indexID=6;
            deviceIndex7.cellId = 3;
            deviceIndex7.isEditableIndex = YES;
            
            return @[deviceIndex3, deviceIndex4, deviceIndex5, deviceIndex7];
        }
            
        case SFIDeviceType_StandardCIE_10:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_STATE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_STATE];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 1;
            
            return @[deviceIndex1, deviceIndex2, deviceIndex3];
        }
            
        case SFIDeviceType_MotionSensor_11:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_STATE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_STATE];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 1;
            
            return @[deviceIndex1,deviceIndex2,deviceIndex3];
        }
            
        case SFIDeviceType_ContactSwitch_12:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_STATE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_STATE];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 1;
            
            return @[deviceIndex1,deviceIndex2,deviceIndex3];
        }
        case SFIDeviceType_FireSensor_13:{
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_STATE];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_STATE];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 1;
            
            return @[deviceIndex1,deviceIndex2,deviceIndex3];
        }
        case SFIDeviceType_WaterSensor_14:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_STATE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_STATE];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 1;
            
            return @[deviceIndex1,deviceIndex2,deviceIndex3];
        }
        case SFIDeviceType_GasSensor_15:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_STATE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_STATE];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 1;
            
            return @[deviceIndex1,deviceIndex2,deviceIndex3];
        }
            
        case SFIDeviceType_VibrationOrMovementSensor_17:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_STATE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_STATE];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 1;
            
            return @[deviceIndex1,deviceIndex2,deviceIndex3];
        }
        case SFIDeviceType_KeyFob_19:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_ARMMODE];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_ARMMODE];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_PANIC_ALARM];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_PANIC_ALARM];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 2;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_EMER_ALARM];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_EMER_ALARM];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId=2;
            
            return @[deviceIndex1,deviceIndex2,deviceIndex3];
            
        }
            
        case SFIDeviceType_StandardWarningDevice_21: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_ALARM_STATE];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_ALARM_STATE];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId =2;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_TAMPER];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId=2;
            
            return @[deviceIndex1,deviceIndex2,deviceIndex3];
            
        }
            
        case SFIDeviceType_SmartACSwitch_22: {
            
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            return @[deviceIndex1];
        }
            
        case SFIDeviceType_OccupancySensor_24:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_OCCUPANCY];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_OCCUPANCY];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 2;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_HUMIDITY];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_HUMIDITY];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 1;
            
            SFIDeviceIndex *deviceIndex4=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex4.indexValues=[self resolve:device index:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex4.indexID=4;
            deviceIndex4.cellId = 2;
            
            //            SFIDeviceIndex *deviceIndex5=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TAMPER];
            //            deviceIndex5.indexValues=[self resolve:device index:SFIDevicePropertyType_TAMPER];
            //            deviceIndex1.indexID=5;
            
            return @[deviceIndex1,deviceIndex2,deviceIndex3,deviceIndex4];
            
        }
        case SFIDeviceType_LightSensor_25:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_ILLUMINANCE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_ILLUMINANCE];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_STATE];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            
            return @[deviceIndex1, deviceIndex2];
        }
            
        case SFIDeviceType_WindowCovering_26:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_STATE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_STATE];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            return @[deviceIndex1];
        }
            
        case SFIDeviceType_TemperatureSensor_27:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId =1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_HUMIDITY];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_HUMIDITY];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId =1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_LOW_BATTERY];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 2;
            
            return @[deviceIndex1,deviceIndex2, deviceIndex3];
        }
            
        case SFIDeviceType_ZigbeeDoorLock_28: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_LOCK_STATE];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_LOCK_STATE];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId =1;
            deviceIndex1.isEditableIndex = YES;
            
            return @[deviceIndex1];
        }
            
        case SFIDeviceType_ColorControl_29:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID=1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_CURRENT_HUE];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_CURRENT_HUE];
            deviceIndex2.indexID=2;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_CURRENT_SATURATION];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_SATURATION];
            deviceIndex3.indexID=3;
            
            SFIDeviceIndex *deviceIndex4=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex4.indexValues=[self resolve:device index:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex4.indexID=4;
            
            SFIDeviceIndex *deviceIndex5=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_COLOR_TEMPERATURE];
            deviceIndex5.indexValues=[self resolve:device index:SFIDevicePropertyType_COLOR_TEMPERATURE];
            deviceIndex5.indexID=5;
            return @[deviceIndex1,deviceIndex2,deviceIndex3,deviceIndex4,deviceIndex5];
        }
            //        case SFIDeviceType_ColorDimmableLight_32:{
            //            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            //            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            //            deviceIndex1.cellId = 3;
            //            deviceIndex1.indexID=1;
            //
            //            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_CURRENT_HUE];
            //            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_CURRENT_HUE];
            //            deviceIndex2.indexID=2;
            //            deviceIndex2.cellId = 1;
            //
            //            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_CURRENT_SATURATION];
            //            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_SATURATION];
            //            deviceIndex3.indexID=3;
            //            deviceIndex3.cellId = 1;
            //
            //            SFIDeviceIndex *deviceIndex4=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            //            deviceIndex4.indexValues=[self resolve:device index:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            //            deviceIndex4.indexID=4;
            //            deviceIndex4.cellId = 2;
            //
            //            SFIDeviceIndex *deviceIndex5=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_COLOR_TEMPERATURE];
            //            deviceIndex5.indexValues=[self resolve:device index:SFIDevicePropertyType_COLOR_TEMPERATURE];
            //            deviceIndex5.indexID=5;
            //            deviceIndex5.cellId = 2;
            //
            //            return @[deviceIndex2,deviceIndex3,deviceIndex4,deviceIndex5,deviceIndex1];
            //        }
        case SFIDeviceType_SmokeDetector_36:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_BASIC];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_BASIC];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 1;
            
            return @[deviceIndex2, deviceIndex1];
        }
            
        case SFIDeviceType_FloodSensor_37:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_BASIC];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_BASIC];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 1;
            
            return @[deviceIndex2, deviceIndex1];
        }
        case SFIDeviceType_ShockSensor_38:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 1;
            
            return @[deviceIndex2, deviceIndex1];
            
        }
        case SFIDeviceType_DoorSensor_39:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            return @[deviceIndex2,deviceIndex1];
        }
            
        case SFIDeviceType_MoistureSensor_40: {
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex2.indexID = 1;
            deviceIndex2.cellId = 2;
            
            
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_BASIC];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_BASIC];
            deviceIndex1.indexID=2;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 2;
            
            
            return @[deviceIndex1, deviceIndex2,deviceIndex3];
            
        }
            
        case SFIDeviceType_MovementSensor_41:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 1;
            
            return @[deviceIndex2, deviceIndex1];
        }
            
        case SFIDeviceType_Siren_42: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 1;
            
            return @[deviceIndex2, deviceIndex1];
        }
            
            
        case SFIDeviceType_UnknownOnOffModule_44: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            return @[deviceIndex1];
        }
            
        case SFIDeviceType_BinaryPowerSwitch_45: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_POWER];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_POWER];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 1;
            
            return @[deviceIndex2, deviceIndex1];
        }
            
        case SFIDeviceType_SetPointThermostat_46:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_THERMOSTAT_SETPOINT];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_THERMOSTAT_SETPOINT];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 2;
            deviceIndex1.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 1;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex3.indexID=4;
            deviceIndex3.cellId = 1;
            
            return @[deviceIndex1, deviceIndex2, deviceIndex3];
        }
            
        case SFIDeviceType_HueLamp_48: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 2;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_COLOR_HUE];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_COLOR_HUE];
            deviceIndex2.indexID = 3;
            deviceIndex2.cellId = 2;
            deviceIndex2.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex3 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SATURATION];
            deviceIndex3.indexValues = [self resolve:device index:SFIDevicePropertyType_SATURATION];
            deviceIndex3.indexID = 4;
            deviceIndex3.cellId = 3;
            deviceIndex3.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex4 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BRIGHTNESS];
            deviceIndex4.indexValues = [self resolve:device index:SFIDevicePropertyType_BRIGHTNESS];
            deviceIndex4.indexID = 5;
            deviceIndex4.cellId = 4;
            deviceIndex4.isEditableIndex = YES;
            
            return @[deviceIndex1, deviceIndex2, deviceIndex3, deviceIndex4];
        }
            
        case SFIDeviceType_MultiSensor_49: {
            
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_STATE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_STATE];
            deviceIndex1.indexID=1;
            deviceIndex1.cellId = 3;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 2;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_ILLUMINANCE];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_ILLUMINANCE];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 1;

            SFIDeviceIndex *deviceIndex4=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex4.indexValues=[self resolve:device index:SFIDevicePropertyType_TEMPERATURE];
            deviceIndex4.indexID=4;
            deviceIndex4.cellId =1;
            
            SFIDeviceIndex *deviceIndex5=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_HUMIDITY];
            deviceIndex5.indexValues=[self resolve:device index:SFIDevicePropertyType_HUMIDITY];
            deviceIndex5.indexID=5;
            deviceIndex5.cellId =2;
            
            return @[deviceIndex1, deviceIndex2, deviceIndex3, deviceIndex4, deviceIndex5];
        }
            
        case SFIDeviceType_SecurifiSmartSwitch_50: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            return @[deviceIndex1];
        }
            
        case SFIDeviceType_RollerShutter_52: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex=YES;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_UP_DOWN];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_UP_DOWN];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 1;
            deviceIndex2.isEditableIndex=YES;
            
            
            SFIDeviceIndex *deviceIndex3 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_STOP];
            deviceIndex3.indexValues = [self resolve:device index:SFIDevicePropertyType_STOP];
            deviceIndex3.indexID = 3;
            deviceIndex3.cellId = 2;
            deviceIndex3.isEditableIndex=YES;
            
            return @[deviceIndex1, deviceIndex2, deviceIndex3];
        }
            
        case SFIDeviceType_GarageDoorOpener_53:{
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_BARRIER_OPERATOR];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_BARRIER_OPERATOR];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex=YES;
            return @[deviceIndex1];
        }
        case SFIDeviceType_MultiSwitch_43:{
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY1];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY1];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex=YES;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY2];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY2];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 2;
            deviceIndex2.isEditableIndex=YES;
            
            return @[deviceIndex1,deviceIndex2];
        }
            
        case SFIDeviceType_ZWtoACIRExtender_54:{
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_AC_MODE];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_AC_MODE];
            deviceIndex1.indexID = 2;
            deviceIndex1.cellId = 3;
            deviceIndex1.isEditableIndex=YES;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_AC_SETPOINT_HEATING];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_AC_SETPOINT_HEATING];
            deviceIndex2.indexID=3;
            deviceIndex2.cellId = 2;
             deviceIndex2.isEditableIndex=YES;
            
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_AC_SETPOINT_COOLING];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_AC_SETPOINT_COOLING];
            deviceIndex3.indexID=4;
            deviceIndex3.cellId = 2;
             deviceIndex3.isEditableIndex=YES;
            
            SFIDeviceIndex *deviceIndex4=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_AC_FAN_MODE];
            deviceIndex4.indexValues=[self resolve:device index:SFIDevicePropertyType_AC_FAN_MODE];
            deviceIndex4.indexID=5;
            deviceIndex4.cellId = 4;
             deviceIndex4.isEditableIndex=YES;
            
            SFIDeviceIndex *deviceIndex5 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex5.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex5.indexID = 6;
            deviceIndex5.cellId = 1;
            
            SFIDeviceIndex *deviceIndex9 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SENSOR_MULTILEVEL];
            deviceIndex9.indexValues = [self resolve:device index:SFIDevicePropertyType_SENSOR_MULTILEVEL];
            deviceIndex9.indexID = 1;
            deviceIndex9.cellId = 1;
            
            //            SFIDeviceIndex *deviceIndex6 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_UNITS];
            //            deviceIndex6.indexValues = [self resolve:device index:SFIDevicePropertyType_UNITS];
            //            deviceIndex6.indexID = 7;
            //            deviceIndex6.cellId = 3;
            
            SFIDeviceIndex *deviceIndex7 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_AC_SWING];
            deviceIndex7.indexValues = [self resolve:device index:SFIDevicePropertyType_AC_SWING];
            deviceIndex7.indexID = 8;
            deviceIndex7.cellId = 5;
            deviceIndex7.isEditableIndex=YES;
            
            SFIDeviceIndex *deviceIndex8 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BASIC];
            deviceIndex8.indexValues = [self resolve:device index:SFIDevicePropertyType_BASIC];
            deviceIndex8.indexID = 9;
            deviceIndex8.cellId = 5;
            deviceIndex8.isEditableIndex=YES;
            
            return @[deviceIndex1, deviceIndex2, deviceIndex3, deviceIndex4, deviceIndex5, deviceIndex7, deviceIndex8,deviceIndex9];
        }
            
        case SFIDeviceType_MultiSoundSiren_55:{
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = 1;
            
            return @[deviceIndex1];
        }
            
        case SFIDeviceType_EnergyReader_56:{
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BATTERY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_BATTERY];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_POWER];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_POWER];
            deviceIndex2.indexID=2;
            deviceIndex2.cellId = 1;
            
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_ENERGY];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_ENERGY];
            deviceIndex3.indexID=3;
            deviceIndex3.cellId = 2;
            
            SFIDeviceIndex *deviceIndex4=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_CLAMP1_POWER];
            deviceIndex4.indexValues=[self resolve:device index:SFIDevicePropertyType_CLAMP1_POWER];
            deviceIndex4.indexID=4;
            deviceIndex4.cellId = 2;
            
            SFIDeviceIndex *deviceIndex5 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_CLAMP1_ENERGY];
            deviceIndex5.indexValues = [self resolve:device index:SFIDevicePropertyType_CLAMP1_ENERGY];
            deviceIndex5.indexID = 5;
            deviceIndex5.cellId = 3;
            
            SFIDeviceIndex *deviceIndex6 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_CLAMP2_POWER];
            deviceIndex6.indexValues = [self resolve:device index:SFIDevicePropertyType_CLAMP2_POWER];
            deviceIndex6.indexID = 6;
            deviceIndex6.cellId = 3;
            
            SFIDeviceIndex *deviceIndex7 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_CLAMP2_ENERGY];
            deviceIndex7.indexValues = [self resolve:device index:SFIDevicePropertyType_CLAMP2_ENERGY];
            deviceIndex7.indexID = 7;
            deviceIndex7.cellId = 4;
            
            return @[deviceIndex1, deviceIndex2, deviceIndex3, deviceIndex4, deviceIndex5, deviceIndex6, deviceIndex7];
        }
        
        case SFIDeviceType_NestThermostat_57:{
            
            SFIDeviceIndex *deviceIndex1=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_NEST_THERMOSTAT_MODE];
            deviceIndex1.indexValues=[self resolve:device index:SFIDevicePropertyType_NEST_THERMOSTAT_MODE];
            deviceIndex1.indexID=2;
            deviceIndex1.cellId = 4;
            deviceIndex1.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex2=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_THERMOSTAT_TARGET];
            deviceIndex2.indexValues=[self resolve:device index:SFIDevicePropertyType_THERMOSTAT_TARGET];
            deviceIndex2.indexID=3;
            deviceIndex2.cellId = 3;
            deviceIndex2.isEditableIndex = YES;
            
            SFIDeviceIndex *deviceIndex3=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_HUMIDITY];
            deviceIndex3.indexValues=[self resolve:device index:SFIDevicePropertyType_HUMIDITY];
            deviceIndex3.indexID=4;
            deviceIndex3.cellId = 1;
            
            SFIDeviceIndex *deviceIndex4=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_THERMOSTAT_RANGE_LOW];
            deviceIndex4.indexValues=[self resolve:device index:SFIDevicePropertyType_THERMOSTAT_RANGE_LOW];
            deviceIndex4.indexID=5;
            deviceIndex4.cellId = 2;
            deviceIndex4.isEditableIndex=YES;
            
            SFIDeviceIndex *deviceIndex5=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH];
            deviceIndex5.indexValues=[self resolve:device index:SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH];
            deviceIndex5.indexID=6;
            deviceIndex5.cellId = 2;
            deviceIndex5.isEditableIndex=YES;
            
            SFIDeviceIndex *deviceIndex7=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_ISONLINE];
            deviceIndex7.indexValues=[self resolve:device index:SFIDevicePropertyType_ISONLINE];
            deviceIndex7.indexID=11;
            deviceIndex7.cellId = 5;
            
            SFIDeviceIndex *deviceIndex8=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE];
            deviceIndex8.indexValues=[self resolve:device index:SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE];
            deviceIndex8.indexID=9;
            deviceIndex8.cellId = 5;
            deviceIndex8.isEditableIndex=YES;
            
            SFIDeviceIndex *deviceIndex10=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_CURRENT_TEMPERATURE];
            deviceIndex10.indexValues=[self resolve:device index:SFIDevicePropertyType_CURRENT_TEMPERATURE];
            deviceIndex10.indexID=10;
            deviceIndex10.cellId = 1;
            
            SFIDeviceIndex *deviceIndex16=[[SFIDeviceIndex alloc]initWithValueType:SFIDevicePropertyType_HVAC_STATE];
            deviceIndex16.indexValues=[self resolve:device index:SFIDevicePropertyType_HVAC_STATE];
            deviceIndex16.indexID=16;
            deviceIndex16.cellId = 6;
            
            return @[deviceIndex1, deviceIndex2, deviceIndex3, deviceIndex4, deviceIndex5, deviceIndex7, deviceIndex8, deviceIndex10, deviceIndex16];
        }
        case SFIDeviceType_BuiltInSiren_60: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_ALARM_STATE];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_ALARM_STATE];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            
            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_TONE_SELECTED];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_TONE_SELECTED];
            deviceIndex2.indexID = 2;
            deviceIndex2.cellId = 2;
            deviceIndex2.isEditableIndex = YES;
            
            return @[deviceIndex1, deviceIndex2];
        }
          
            
        case SFIDeviceType_REBOOT_ALMOND: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_REBOOT];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_REBOOT];
            deviceIndex1.indexID = 1;
            deviceIndex1.cellId = 1;
            deviceIndex1.isEditableIndex = YES;
            return @[deviceIndex1];
        }
        default: {
            //            NSLog(@"Something wrong");
            return [NSArray array];
        }
    }
    
    
}

@end
