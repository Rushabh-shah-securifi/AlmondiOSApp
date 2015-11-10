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
                s1.iconName = @"01_switch_off";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"01_switch_on";
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
                s1.iconName = @"01_switch_off";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0";
                s2.matchType = MatchType_not_equals;
                s2.iconName = @"02_dimmer";
                s2.notificationText = @"";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@" is dimmed to ", @" is dimmed to ");
                s2.valueFormatter.suffix = @"%";

                return @[s1, s2];
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
                s1.iconName = @"03_door_closed";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.matchType = MatchType_not_equals;
                s2.iconName = @"03_door_opened";
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
                s1.iconName = @"04_switch_off";
                s1.notificationText = NSLocalizedString(@" turned Off.", @" turned Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"04_dimmer";
                s2.notificationText = NSLocalizedString(@" turned On.", @" turned On.");

                return @[s1, s2];
            }
            else if (type == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"50";
                s1.iconName = @"04_dimmer";
                s1.valueFormatter.action = ValueFormatterAction_scale;
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
                s1.iconName = @"05_door_lock_unlocked";
                s1.notificationText = NSLocalizedString(@" is Unlocked.", @" is Unlocked.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.iconName = @"05_door_lock_locked";
                s2.notificationText = NSLocalizedString(@" is Locked.", @" is Locked.");

                return @[s1, s2];
            }

            if (type == SFIDevicePropertyType_USER_CODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = nil;
                s1.iconName = @"05_door_lock_locked";
                s1.notificationText = NSLocalizedString(@"'s pin code changed.", @"'s pin code changed.");


                return @[s1];
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
                s1.iconName = @"06_alarm_off";
                s1.notificationText = NSLocalizedString(@" is Silent.", @" is Silent.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.iconName = @"06_alarm_on";
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
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Heating";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is ", @" is ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is cooling down to ", @" is cooling down to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is heating up to ", @" is heating up to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_MODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Auto";
                s1.iconName = @"07_thermostat_fan";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to ", @" is set to ");
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_FAN_MODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Auto";
                s1.iconName = @"07_thermostat_fan";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" Fan is set to ", @" Fan is set to ");
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_FAN_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"On";
                s1.iconName = @"07_thermostat_fan";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" Fan is ", @" Fan is ");
                return @[s1];
            }
            if (type == SFIDevicePropertyType_HUMIDITY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"27_thermostat";
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
                s1.iconName = @"10_switch_off";
                s1.notificationText = NSLocalizedString(@" turned Off.", @" turned Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"10_switch_on";
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
                s1.iconName = @"11_motion_false";
                s1.notificationText = NSLocalizedString(@"'s motion stopped.", @"'s motion stopped.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"11_motion_true";
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
                s1.iconName = @"12_door_closed";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"12_door_opened";
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
                s1.iconName = @"13_smoke_no";
                s1.notificationText = NSLocalizedString(@"'s Fire is gone.", @"'s Fire is gone.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"13_smoke_yes";
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
                s1.iconName = @"14_water_drop_no";
                s1.notificationText = NSLocalizedString(@" stopped leaking.", @" stopped leaking.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"14_water_drop_yes";
                s2.notificationText = NSLocalizedString(@" detected water.", @" detected water.");

                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"27_thermostat";
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
                s1.iconName = @"15_smoke_no";
                s1.notificationText = NSLocalizedString(@"'s Gas is gone.", @"'s Gas is gone.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"15_smoke_yes";
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
                s1.iconName = @"17_vibration_no";
                s1.notificationText = NSLocalizedString(@"'s vibration stopped.", @"'s vibration stopped.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"17_vibration_yes";
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
                s1.notificationText = NSLocalizedString(@" turned Off.", @" turned Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"18_vibration_yes";
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
                s1.iconName = @"19_key_fob_disarmed";
                s1.notificationText = NSLocalizedString(@" is Disarmed.", @" is Disarmed.");


                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"2";
                s2.iconName = @"19_key_fob_armed";
                s2.notificationText = NSLocalizedString(@" is Perimeter Armed.", @" is Perimeter Armed.");


                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"3";
                s3.iconName = @"19_key_fob_armed";
                s3.notificationText = NSLocalizedString(@" is Armed.", @" is Armed.");


                return @[s1, s2, s3];
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
                s2.iconName = @"20_switch_on";
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
                s1.iconName = @"21_alarm_off";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"1";
                s2.matchType = MatchType_equals;
                s2.iconName = @"21_alarm_on";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@" is turned on for ", @" is turned on for ");
                s2.valueFormatter.suffix = NSLocalizedString(@" second", @" second");

                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"1";
                s3.matchType = MatchType_not_equals;
                s3.iconName = @"21_alarm_on";
                s3.valueFormatter.action = ValueFormatterAction_formatString;
                s3.valueFormatter.notificationPrefix = NSLocalizedString(@" is turned on for ", @" is turned on for ");
                s3.valueFormatter.suffix = NSLocalizedString(@" seconds", @" seconds");

                return @[s1, s2, s3];
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
                s1.iconName = @"22_metering_off";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"22_metering_on";
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
                s1.iconName = @"23_metering_off";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");;

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"23_metering_on";
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
                s1.notificationText = NSLocalizedString(@": no presence detected.", @": no presence detected.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"41_motion_true";
                s2.notificationText = NSLocalizedString(@": presence detected.", @": presence detected.");

                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"50";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = NSLocalizedString(@"\u00B0 Farenheit", @"\u00B0 Farenheit");

                return @[s1];
            }
            if (type == SFIDevicePropertyType_HUMIDITY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"48";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
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
                s1.iconName = @"25_bulb_off";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s light reading changed to ", @"'s light reading changed to ");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0 lux";
                s2.matchType = MatchType_not_equals;
                s2.iconName = @"25_bulb_on";
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
                s1.iconName = @"26_window_closed";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"false";
                s2.iconName = @"26_window_open";
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
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");

                return @[s1];
            }
            if (type == SFIDevicePropertyType_HUMIDITY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s humidiy changed to ", @"'s humidiy changed to ");

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
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = @"05_door_lock_unlocked";//md01 was @"28_door_lock_locked";
                s1.notificationText = NSLocalizedString(@" is not fully Locked.", @" is not fully Locked.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"1";
                s2.iconName = @"05_door_lock_locked";//md01 was @"28_door_lock_locked";
                s2.notificationText = NSLocalizedString(@" is Locked.", @" is Locked.");

                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"2";
                s3.iconName = @"05_door_lock_unlocked";//md01 was @"28_door_lock_unlocked";
                s3.notificationText = NSLocalizedString(@" is Unlocked.", @" is Unlocked.");

                return @[s1, s2, s3];
            }

            if (type == SFIDevicePropertyType_USER_CODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = nil;
                s1.iconName = @"28_door_lock_locked";
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
                s1.notificationText = NSLocalizedString(@" is switched Off.", @" is switched Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"48_hue_bulb_on";
                s2.notificationText = NSLocalizedString(@" is switched On.", @" is switched On.");

                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_CURRENT_HUE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"48_hue_bulb_on";
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
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" hue color changed to ", @" hue color changed to ");
                return @[s1];
            }
            if (type == SFIDevicePropertyType_CURRENT_SATURATION) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"48_hue_bulb_on";
                s1.valueFormatter.maxValue = 254;
                s1.valueFormatter.scaledMaxValue = 100;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" saturation changed to ", @" saturation changed to ");
                s1.valueFormatter.suffix = @"%";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"48_hue_bulb_on";
                s1.valueFormatter.maxValue = 255;
                s1.valueFormatter.scaledMaxValue = 100;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" brightness changed to ", @" brightness changed to ");
                s1.valueFormatter.suffix = @"%";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_COLOR_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"48_hue_bulb_on";
                s1.notificationText = NSLocalizedString(@"'s color temperature changed to .", @"'s color temperature changed to .");
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s color temperature changed to ", @"'s color temperature changed to ");
                s1.valueFormatter.suffix = @"Kelvin";//remain
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
                s1.iconName = @"36_smoke_no";
                s1.notificationText = NSLocalizedString(@"'s Smoke is gone.", @"'s Smoke is gone.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.iconName = @"36_smoke_yes";
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
                s1.iconName = @"37_water_drop_no";
                s1.notificationText = NSLocalizedString(@" stopped leaking.", @" stopped leaking.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.iconName = @"37_water_drop_yes";
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
                s1.iconName = @"38_vibration_no";
                s1.notificationText = NSLocalizedString(@"'s vibration stopped.", @"'s vibration stopped.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"38_vibration_yes";
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
                s1.iconName = @"39_door_closed";
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"39_door_opened";
                s2.notificationText = NSLocalizedString(@" is Opened.", @" is Opened.");

                return @[s1, s2];
            }
            break;
        }
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
                s1.iconName = @"40_water_drop_no";
                s1.notificationText = NSLocalizedString(@" stopped leaking.", @" stopped leaking.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"255";
                s2.iconName = @"40_water_drop_yes";
                s2.notificationText = NSLocalizedString(@" detected water.", @" detected water.");

                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = nil;
                s1.iconName = @"40_water_drop_off";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationText = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");

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
                s1.iconName = @"41_motion_false";
                s1.notificationText = NSLocalizedString(@"'s motion stopped.", @"'s motion stopped.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"41_motion_true";
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
                s1.iconName = @"42_alarm_no";
                s1.notificationText = @" is Silent.";
                
                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"42_alarm_yes";
                s2.notificationText = @" is Ringing.";
                return @[s1, s2];
            }

            break;
        }

        case SFIDeviceType_MultiSwitch_43:
            if (type == SFIDevicePropertyType_SWITCH_BINARY1) {
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
                s1.iconName = @"45_metering_off";
                s1.notificationText = NSLocalizedString(@" is switched Off.", @" is switched Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"45_metering_on";
                s2.notificationText = NSLocalizedString(@" is switched On.", @" is switched On.");

                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_POWER) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.iconName = @"45_metering_off";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s power reading changed to ", @"'s power reading changed to ");

                return @[s1];
            }

            break;
        }

        case SFIDeviceType_SetPointThermostat_46: {
            if (type == SFIDevicePropertyType_THERMOSTAT_SETPOINT) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature set point changed to ", @"'s temperature set point changed to ");

                return @[s1];
            }
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");

                return @[s1];
            }

            break;
        }

        case SFIDeviceType_HueLamp_48:
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"48_hue_bulb_off";
                s1.notificationText = NSLocalizedString(@" is switched Off.", @" is switched Off.");


                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"48_hue_bulb_on";
                s2.notificationText = NSLocalizedString(@" is switched On.", @" is switched On.");


                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_COLOR_HUE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"48_hue_bulb_on";
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
                return @[s1];
            }
            if (type == SFIDevicePropertyType_SATURATION) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"48_hue_bulb_on";
                s1.valueFormatter.maxValue = 255;
                s1.valueFormatter.scaledMaxValue = 100;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" saturation changed to ", @" saturation changed to ");
                s1.valueFormatter.suffix = @"%";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"48_hue_bulb_on";
                s1.valueFormatter.maxValue = 255;
                s1.valueFormatter.scaledMaxValue = 100;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" brightness changed to ", @" brightness changed to ");
                s1.valueFormatter.suffix = @"%";
                return @[s1];
            }

            break;

        case SFIDeviceType_SecurifiSmartSwitch_50: {
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"50_metering_off";
                s1.notificationText = NSLocalizedString(@" is turned Off.", @" is turned Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"50_metering_on";
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
                s1.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"252";
                s2.iconName = DT53_GARAGE_SENSOR_DOWN;
                s2.notificationText = NSLocalizedString(@" is Closing.", @" is Closing.");

                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"253";
                s3.iconName = DT53_GARAGE_SENSOR_STOPPED;
                s3.notificationText = NSLocalizedString(@" is Stopped.", @" is Stopped.");

                IndexValueSupport *s4 = [[IndexValueSupport alloc] initWithValueType:type];
                s4.matchData = @"254";
                s4.iconName = DT53_GARAGE_SENSOR_UP;
                s4.notificationText = NSLocalizedString(@" is Opening.", @" is Opening.");

                IndexValueSupport *s5 = [[IndexValueSupport alloc] initWithValueType:type];
                s5.matchData = @"255";
                s5.iconName = DT53_GARAGE_SENSOR_OPEN;
                s5.notificationText = NSLocalizedString(@" is Open.", @" is Open.");

                return @[s1, s2, s3, s4, s5];
            }
            case SFIDeviceType_NestThermostat_57: {
                if (type == SFIDevicePropertyType_NEST_THERMOSTAT_FAN_STATE) {
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchData = @"true";
                    s1.iconName = @"07_thermostat_fan";
                    s1.notificationText = NSLocalizedString(@"'s Fan Started", @"'s Fan Started");

                    IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                    s2.matchData = @"false";
                    s2.iconName = @"07_thermostat_fan";
                    s2.notificationText = NSLocalizedString(@"'s Fan Stopped", @"'s Fan Stopped");
                    return @[s1, s2];
                }
                if (type == SFIDevicePropertyType_AWAY_MODE) {
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchData = @"home";
                    s1.iconName = @"55_away_mode_home";
                    s1.notificationText = NSLocalizedString(@"HOME", @"HOME");

                    IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                    s2.matchData = @"away";
                    s2.iconName = @"55_away_mode_away";
                    s2.notificationText = NSLocalizedString(@"AWAY", @"AWAY");
                    return @[s1, s2];
                }
                if (type == SFIDevicePropertyType_THERMOSTAT_TARGET) {
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchType = MatchType_any;
                    s1.matchData = @"70";
                    s1.iconName = @"27_thermostat";
                    s1.notificationText = @"";
                    s1.valueFormatter.notificationPrefix = NSLocalizedString(@"target temperature is", @"target temperature is");
                    s1.valueFormatter.action = ValueFormatterAction_formatString;
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
                if (type == SFIDevicePropertyType_THERMOSTAT_RANGE_LOW) {
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchType = MatchType_any;
                    s1.matchData = @"70";
                    s1.iconName = @"27_thermostat";
                    s1.notificationText = NSLocalizedString(@" is cooling down to ", @" is cooling down to ");
                    s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is cooling down to ", @" is cooling down to ");
                    s1.valueFormatter.action = ValueFormatterAction_formatString;
                    return @[s1];
                }

                if (type == SFIDevicePropertyType_THERMOSTAT_RANGE_HIGH) {
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchType = MatchType_any;
                    s1.matchData = @"70";
                    s1.iconName = @"27_thermostat";
                    s1.notificationText = NSLocalizedString(@" is heating up to ", @" is heating up to ");
                    s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is heating up to ", @" is heating up to ");
                    s1.valueFormatter.action = ValueFormatterAction_formatString;
                    return @[s1];
                }

                if (type == SFIDevicePropertyType_TEMPERATURE) {
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchType = MatchType_any;
                    s1.matchData = @"70";
                    s1.iconName = @"27_thermostat";
                    s1.notificationText = NSLocalizedString(@"Temperature", @"Temperature");
                    return @[s1];
                }
               
                if (type == SFIDevicePropertyType_NEST_THERMOSTAT_MODE) {
                    
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchType = MatchType_any;
                    s1.matchData = @"Heat";
                    s1.iconName = @"27_thermostat";
                    s1.valueFormatter.action = ValueFormatterAction_formatString;
                    s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s mode set to", @"'s mode set to");
                    
                    return @[s1];
                    
                }
                
                if(type == SFIDevicePropertyType_HVAC_STATE){
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchType = MatchType_any;
                    s1.matchData = @"Heating";
                    s1.iconName = @"27_thermostat";
                    s1.valueFormatter.action = ValueFormatterAction_formatString;
                    s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to ", @" is set to ");
                    return @[s1];
                    
                }
                if(type == SFIDevicePropertyType_ISONLINE){
                    
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchType = MatchType_equals;
                    s1.matchData = @"true";
                    s1.iconName = @"27_thermostat";
                    s1.notificationText = @" is offline";
                    
                    IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                    s2.matchType = MatchType_equals;
                    s2.matchData = @"false";
                    s2.iconName = @"27_thermostat";
                    s2.notificationText = @" is now online";
                    
                    return @[s1, s2];
                }

                if (type == SFIDevicePropertyType_HUMIDITY) {
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchType = MatchType_any;
                    s1.matchData = @"40";
                    s1.iconName = @"27_thermostat";
                    s1.valueFormatter.action = ValueFormatterAction_formatString;
                    s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s humidiy changed to ", @"'s humidiy changed to ");
                    
                    return @[s1];
                }

                if (type == SFIDevicePropertyType_IS_USING_EMERGENCY_HEAT) {
                    IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                    s1.matchType = MatchType_equals;
                    s1.matchData = @"true";
                    s1.iconName = @"27_thermostat";
                    s1.notificationText = @" is using Emergency Heat";
                    
                    return @[s1];
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
                    s1.iconName = @"56_nest_58_icon";
                    s1.notificationText = @" is offline";
                    
                    IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                    s2.matchType = MatchType_equals;
                    s2.matchData = @"false";
                    s2.iconName = @"56_nest_58_icon";
                    s2.notificationText = @" is now online";
                    
                    return @[s1, s2];
                }
                
                break;
            }
        }
        case SFIDeviceType_BinarySwitch_0: {

            break;
        }
        case SFIDeviceType_MultiSensor_49: {
            if (type == SFIDevicePropertyType_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"11_motion_false";
                s1.notificationText = NSLocalizedString(@"'s motion stopped.", @"'s motion stopped.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"11_motion_true";
                s2.notificationText = NSLocalizedString(@" detected motion.", @" detected motion.");

                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_ILLUMINANCE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0 lux";
                s1.matchType = MatchType_equals;
                s1.iconName = @"25_bulb_off";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s light reading changed to ", @"'s light reading changed to ");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0 lux";
                s2.matchType = MatchType_not_equals;
                s2.iconName = @"25_bulb_on";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@"'s light reading changed to ", @"'s light reading changed to ");

                return @[s1, s2];
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
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");

                return @[s1];
            }
            if (type == SFIDevicePropertyType_HUMIDITY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s humidiy changed to ", @"'s humidiy changed to ");

                return @[s1];
            }

            break;
        }
        case SFIDeviceType_51:
            break;

        case SFIDeviceType_RollerShutter_52: {
            if (type == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = DT53_GARAGE_SENSOR_OPEN;
                s1.notificationText = NSLocalizedString(@" is Open.", @" is Open.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"99";
                s2.iconName = DT53_GARAGE_SENSOR_CLOSED;
                s2.notificationText = NSLocalizedString(@" is Closed.", @" is Closed.");

                return @[s1, s2];
            }

            if (type == SFIDevicePropertyType_UP_DOWN) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"0";
                s1.iconName = DT53_GARAGE_SENSOR_DOWN;
                s1.notificationText = NSLocalizedString(@" is Down.", @" is Down.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"99";
                s2.iconName = DT53_GARAGE_SENSOR_UP;
                s2.notificationText = NSLocalizedString(@" is Up.", @" is Up.");

                return @[s1, s2];
            }

            if (type == SFIDevicePropertyType_STOP) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"true";
                s1.iconName = DT53_GARAGE_SENSOR_STOPPED;
                s1.notificationText = NSLocalizedString(@" is Stopped.", @" is Stopped.");

                return @[s1];
            }

            break;
        }
        case SFIDeviceType_ZWtoACIRExtender_54: {
            if (type == SFIDevicePropertyType_SENSOR_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s temperature changed to ", @"'s temperature changed to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }

            if (type == SFIDevicePropertyType_AC_MODE) {

            }

            if (type == SFIDevicePropertyType_AC_SETPOINT_HEATING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is heating up to ", @" is heating up to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }

            if (type == SFIDevicePropertyType_AC_SETPOINT_COOLING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is cooling down to ", @" is cooling down to ");
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }

            if (type == SFIDevicePropertyType_AC_FAN_MODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Auto";
                s1.iconName = @"07_thermostat_fan";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" Fan is set to ", @" Fan is set to ");
                return @[s1];
            }

            if (type == SFIDevicePropertyType_UNITS) {

            }

            if (type == SFIDevicePropertyType_AC_SWING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"0";
                s1.iconName = @"01_switch_off";
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" Fan Swing is Off", @" Fan Swing is Off");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"1";
                s2.iconName = @"01_switch_on";
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@" Fan Swing is On", @" Fan Swing is On");

                return @[s1, s2];
            }

            if (type == SFIDevicePropertyType_BASIC) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"0";
                s1.iconName = @"01_switch_off";
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is turned Off.", @" is turned Off.");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"1";
                s2.iconName = @"01_switch_on";
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@" is turned On.", @" is turned On.");

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

        case SFIDeviceType_MultiSoundSiren_55: {
            if (type == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_equals;
                s1.matchData = @"0";
                s1.iconName = @"42_alarm_no";
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@" is Silent", @" is Silent");

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"1";
                s2.iconName = @"42_alarm_yes";
                s2.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to Emergency", @" is set to Emergency");

                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchType = MatchType_equals;
                s3.matchData = @"2";
                s3.iconName = @"42_alarm_yes";
                s3.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to Fire", @" is set to Fire");

                IndexValueSupport *s4 = [[IndexValueSupport alloc] initWithValueType:type];
                s4.matchType = MatchType_equals;
                s4.matchData = @"3";
                s4.iconName = @"42_alarm_yes";
                s4.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to Ambulance", @" is set to Ambulance");

                IndexValueSupport *s5 = [[IndexValueSupport alloc] initWithValueType:type];
                s5.matchType = MatchType_equals;
                s5.matchData = @"4";
                s5.iconName = @"42_alarm_yes";
                s5.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to Police", @" is set to Police");

                IndexValueSupport *s6 = [[IndexValueSupport alloc] initWithValueType:type];
                s6.matchType = MatchType_equals;
                s6.matchData = @"5";
                s6.iconName = @"42_alarm_yes";
                s6.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to Door Chime", @" is set to Door Chime");

                IndexValueSupport *s7 = [[IndexValueSupport alloc] initWithValueType:type];
                s7.matchType = MatchType_equals;
                s7.matchData = @"6";
                s7.iconName = @"42_alarm_yes";
                s7.valueFormatter.notificationPrefix = NSLocalizedString(@" is set to Beep", @" is set to Beep");

                return @[s1, s2, s3, s4, s5, s6, s7];
            }
            break;
        }

        case SFIDeviceType_EnergyReader_56: {
            if (type == SFIDevicePropertyType_POWER) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.iconName = @"56_energy_reader";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s power reading changed to ", @"'s power reading changed to ");

                return @[s1];
            }

            if (type == SFIDevicePropertyType_ENERGY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.iconName = @"56_energy_reader";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s energy reading is ", @"'s energy reading is ");

                return @[s1];
            }

            if (type == SFIDevicePropertyType_CLAMP1_POWER) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.iconName = @"56_energy_reader";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s Clamp 1 power reading is ", @"'s power reading is ");

                return @[s1];
            }
            if (type == SFIDevicePropertyType_CLAMP2_POWER) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.iconName = @"56_energy_reader";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s Clamp 2 power reading is ", @"'s power reading is ");

                return @[s1];
            }

            if (type == SFIDevicePropertyType_CLAMP1_ENERGY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.iconName = @"56_energy_reader";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s Clamp 1 energy reading is ", @"'s energy reading is ");

                return @[s1];
            }
            if (type == SFIDevicePropertyType_CLAMP2_ENERGY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.iconName = @"56_energy_reader";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = NSLocalizedString(@"'s Clamp 2 energy reading is ", @"'s energy reading is ");

                return @[s1];
            }

            break;
        }

        case SFIDeviceType_WIFIClient:
            break;

        case SFIDeviceType_count:
            break;
    }

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
            s2.iconName = @"battery_low";
            s2.notificationText = NSLocalizedString(@"'s Battery is Low.", @"'s Battery is Low.");

            return @[s2];
        }

        case SFIDevicePropertyType_LOW_BATTERY: {
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.matchType = MatchType_equals;
            s1.matchData = @"true";
            s1.iconName = @"battery_low";
            s1.notificationText = NSLocalizedString(@"'s Battery is Low.", @"'s Battery is Low.");

            return @[s1];
        }

        case SFIDevicePropertyType_TAMPER: {
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.matchType = MatchType_equals;
            s1.matchData = @"true";
            s1.iconName = @"tamper";
            s1.notificationText = NSLocalizedString(@" has been Tampered.", @" has been Tampered.");

            IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
            s2.matchType = MatchType_equals;
            s2.matchData = @"false";
            s2.iconName = @"tamper";
            s2.notificationText = NSLocalizedString(@" is reset from Tampered.", @" is reset from Tampered.");

            return @[s1, s2];
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

        case SFIDeviceType_BinarySwitch_1: {

            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 1;
            return @[deviceIndex1];
        }

        case SFIDeviceType_MultiLevelSwitch_2: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex1.indexID = 1;
            return @[deviceIndex1];
        }

        case SFIDeviceType_BinarySensor_3: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexID = 1;
            return @[deviceIndex1];
        }
        case SFIDeviceType_MultiLevelOnOff_4: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 2;

            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex2.indexID = 1;

            return @[deviceIndex1, deviceIndex2];
        }

        case SFIDeviceType_DoorLock_5: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_LOCK_STATE];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_LOCK_STATE];
            deviceIndex1.indexID = 1;
            //            SFIDeviceIndex * deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_USER_CODE];
            //            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_USER_CODE];

            return @[deviceIndex1];//,deviceIndex2
        }

        case SFIDeviceType_Alarm_6: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_BASIC];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_BASIC];
            deviceIndex1.indexID = 1;
            return @[deviceIndex1];
        }

        case SFIDeviceType_StandardWarningDevice_21: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_ALARM_STATE];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_ALARM_STATE];
            deviceIndex1.indexID = 1;
            return @[deviceIndex1];
        }

        case SFIDeviceType_SmartACSwitch_22: {

            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 1;
            return @[deviceIndex1];
        }

        case SFIDeviceType_ZigbeeDoorLock_28: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_LOCK_STATE];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_LOCK_STATE];
            deviceIndex1.indexID = 1;

            //            SFIDeviceIndex * deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_USER_CODE];
            //            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_USER_CODE];
            //             deviceIndex1.indexID = 2;
            //
            return @[deviceIndex1];
        }
        case SFIDeviceType_Siren_42: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SENSOR_BINARY];
            deviceIndex1.indexID = 1;
            return @[deviceIndex1];
        }

        case SFIDeviceType_UnknownOnOffModule_44: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 1;
            return @[deviceIndex1];
        }

        case SFIDeviceType_BinaryPowerSwitch_45: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 1;

            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_POWER];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_POWER];
            deviceIndex2.indexID = 2;

            return @[deviceIndex1, deviceIndex2];
        }

        case SFIDeviceType_HueLamp_48: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 2;

            SFIDeviceIndex *deviceIndex2 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_COLOR_HUE];
            deviceIndex2.indexValues = [self resolve:device index:SFIDevicePropertyType_COLOR_HUE];
            deviceIndex1.indexID = 3;

            SFIDeviceIndex *deviceIndex3 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SATURATION];
            deviceIndex3.indexValues = [self resolve:device index:SFIDevicePropertyType_SATURATION];
            deviceIndex1.indexID = 4;

            SFIDeviceIndex *deviceIndex4 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex4.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_MULTILEVEL];
            deviceIndex1.indexID = 5;

            return @[deviceIndex1, deviceIndex2, deviceIndex3, deviceIndex4];
        }
        case SFIDeviceType_SecurifiSmartSwitch_50: {
            SFIDeviceIndex *deviceIndex1 = [[SFIDeviceIndex alloc] initWithValueType:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexValues = [self resolve:device index:SFIDevicePropertyType_SWITCH_BINARY];
            deviceIndex1.indexID = 1;
            return @[deviceIndex1];
        }

        default: {
            //            NSLog(@"Something wrong");
            return [NSArray array];
        }
    }


}


@end