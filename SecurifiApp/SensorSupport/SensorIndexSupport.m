//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"
#import "ValueFormatter.h"


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
                s1.notificationText = @" is turned Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"01_switch_on";
                s2.notificationText = @" is turned On.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" is turned Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0";
                s2.matchType = MatchType_not_equals;
                s2.iconName = @"02_dimmer";
                s2.notificationText = @"";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = @" is dimmed to ";
                s2.valueFormatter.suffix = @"%";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" is Closed.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.matchType = MatchType_not_equals;
                s2.iconName = @"03_door_opened";
                s2.notificationText = @" is Opened.";

                return @[s1, s2];
            }

            break;
        };
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
                s1.notificationText = @" turned Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"04_dimmer";
                s2.notificationText = @" turned On.";

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
                s1.valueFormatter.notificationPrefix = @" is dimmed to ";
                s1.valueFormatter.suffix = @"%";

                return @[s1];
            }

            break;
        };

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
                s1.notificationText = @" is Unlocked.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.iconName = @"05_door_lock_locked";
                s2.notificationText = @" is Locked.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.matchData = @"255";
                s1.iconName = @"06_alarm_off";
                s1.notificationText = @" is Silent.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0";
                s2.iconName = @"06_alarm_on";
                s2.notificationText = @" is Ringing.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.iconName = @"07_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @"'s temperature changed to ";
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Heating";
                s1.iconName = @"07_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @" is ";
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.iconName = @"07_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @" is cooling down to ";
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"70";
                s1.iconName = @"07_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @" is heating up to ";
                s1.valueFormatter.suffix = @"\u00B0F";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_MODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Auto";
                s1.iconName = @"07_thermostat_fan";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @" is set to ";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_FAN_MODE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"Auto";
                s1.iconName = @"07_thermostat_fan";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @" Fan is set to ";
                return @[s1];
            }
            if (type == SFIDevicePropertyType_THERMOSTAT_FAN_STATE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"On";
                s1.iconName = @"07_thermostat_fan";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @" Fan is ";
                return @[s1];
            }

            break;
        };

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
                s1.notificationText = @" turned Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"10_switch_on";
                s2.notificationText = @" turned On.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @"'s motion stopped.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"11_motion_true";
                s2.notificationText = @" detected motion.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" is Closed.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"12_door_opened";
                s2.notificationText = @" is Opened.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @"'s Fire is gone.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"13_smoke_yes";
                s2.notificationText = @" detected Fire.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" stopped leaking.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"14_water_drop_yes";
                s2.notificationText = @" detected water.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @"'s Gas is gone.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"15_smoke_yes";
                s2.notificationText = @" detected Gas.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" turned Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"16_vibration_no";
                s2.notificationText = @" turned On.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @"'s vibration stopped.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"17_vibration_yes";
                s2.notificationText = @" detected Vibration.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" turned Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"18_vibration_yes";
                s2.notificationText = @" turned On.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" is Disarmed.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"2";
                s2.iconName = @"19_keyfob_perimeter_armed";
                s2.notificationText = @" is Perimeter Armed.";

                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"3";
                s3.iconName = @"19_key_fob_armed";
                s3.notificationText = @" is Armed.";

                return @[s1, s2, s3];
            }

            break;
        };

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
                s1.notificationText = @" is turned Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"20_switch_on";
                s2.notificationText = @" is turned On.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.matchData = @"false";
                s1.iconName = @"21_alarm_off";
                s1.notificationText = @" is Silent.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"21_alarm_on";
                s2.notificationText = @" is Ringing.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" is turned Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"22_metering_on";
                s2.notificationText = @" is turned On.";

                return @[s1, s2];
            }

            break;
        };

        case SFIDeviceType_SmartDCSwitch_23: {
            /*

             */
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"23_metering_off";
                s1.notificationText = @" is turned Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"23_metering_on";
                s2.notificationText = @" is turned On.";

                return @[s1, s2];
            }

            break;
        };

        case SFIDeviceType_OccupancySensor_24:
            break;

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
                s1.valueFormatter.notificationPrefix = @"'s light reading changed to ";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"0 lux";
                s2.matchType = MatchType_not_equals;
                s2.iconName = @"25_bulb_on";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = @"'s light reading changed to ";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" is Closed.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"false";
                s2.iconName = @"26_window_open";
                s2.notificationText = @" is Opened.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.matchData = @"false";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @"'s temperature changed to ";

                return @[s1];
            }
            if (type == SFIDevicePropertyType_HUMIDITY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.iconName = @"27_thermostat";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @"'s humidiy changed to ";

                return @[s1];
            }

            break;
        };

        case SFIDeviceType_SimpleMetering_28: {
            //todo this type has been reassigned!!
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
                s1.iconName = @"28_door_lock_locked";
                s1.notificationText = @" is not fully Locked.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"1";
                s2.iconName = @"28_door_lock_locked";
                s2.notificationText = @" is Locked.";

                IndexValueSupport *s3 = [[IndexValueSupport alloc] initWithValueType:type];
                s3.matchData = @"2";
                s3.iconName = @"28_door_lock_unlocked";
                s3.notificationText = @" is Unlocked.";

                return @[s1, s2, s3];
            }

            break;
        };

        case SFIDeviceType_ColorControl_29:
            break;
        case SFIDeviceType_PressureSensor_30:
            break;
        case SFIDeviceType_FlowSensor_31:
            break;
        case SFIDeviceType_ColorDimmableLight_32:
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
                s1.notificationText = @"'s Smoke is gone.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.iconName = @"36_smoke_yes";
                s2.notificationText = @" detected Smoke.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" stopped leaking.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"255";
                s2.iconName = @"37_water_drop_yes";
                s2.notificationText = @" detected water.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @"'s vibration stopped.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"38_vibration_yes";
                s2.notificationText = @" detected Vibration.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" is Closed.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"39_door_opened";
                s2.notificationText = @" is Opened.";

                return @[s1, s2];
            }
        };
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
                s1.iconName = @"40_water_drop_no";
                s1.notificationText = @" stopped leaking.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchType = MatchType_equals;
                s2.matchData = @"255";
                s2.iconName = @"40_water_drop_yes";
                s2.notificationText = @" detected water.";

                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_TEMPERATURE) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = nil;
                s1.iconName = @"40_water_drop_off";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationText = @"'s temperature changed to ";

                return @[s1];
            }

            break;
        };

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
                s1.notificationText = @"'s motion stopped.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"41_motion_true";
                s2.notificationText = @" detected motion.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.iconName = @"42_alarm_off";
                s1.notificationText = @" is Silent.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"42_alarm_on";
                s2.notificationText = @" is Ringing.";

                return @[s1, s2];
            }

            break;
        };

        case SFIDeviceType_MultiSwitch_43:
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
                s1.iconName = @"44_switch_off";
                s1.notificationText = @" is switched Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"44_switch_on";
                s2.notificationText = @" is switched On.";

                return @[s1, s2];
            }

            break;
        };

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
                s1.notificationText = @" is switched Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"45_metering_on";
                s2.notificationText = @" is switched On.";

                return @[s1, s2];
            }
            if (type == SFIDevicePropertyType_POWER) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchType = MatchType_any;
                s1.matchData = @"40";
                s1.iconName = @"45_metering_off";
                s1.valueFormatter.action = ValueFormatterAction_formatString;
                s1.valueFormatter.notificationPrefix = @"'s power reading changed to ";

                return @[s1];
            }

            break;
        };

        case SFIDeviceType_HueLamp_48:
            break;

        case SFIDeviceType_SecurifiSmartSwitch_50: {
            if (type == SFIDevicePropertyType_SWITCH_BINARY) {
                IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
                s1.matchData = @"false";
                s1.iconName = @"50_metering_off";
                s1.notificationText = @" is turned Off.";

                IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
                s2.matchData = @"true";
                s2.iconName = @"50_metering_on";
                s2.notificationText = @" is turned On.";

                return @[s1, s2];
            }

            break;
        };
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
            s2.notificationText = @"'s Battery is Low.";

            return @[s2];
        };

        case SFIDevicePropertyType_LOW_BATTERY: {
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.matchType = MatchType_equals;
            s1.matchData = @"true";
            s1.iconName = @"battery_low";
            s1.notificationText = @"'s Battery is Low.";

            return @[s1];
        };

        case SFIDevicePropertyType_TAMPER: {
            IndexValueSupport *s1 = [[IndexValueSupport alloc] initWithValueType:type];
            s1.matchType = MatchType_equals;
            s1.matchData = @"true";
            s1.iconName = @"tamper";
            s1.notificationText = @" has been Tampered.";

            IndexValueSupport *s2 = [[IndexValueSupport alloc] initWithValueType:type];
            s2.matchType = MatchType_equals;
            s2.matchData = @"false";
            s2.iconName = @"tamper";
            s2.notificationText = @" is reset from Tampered.";

            return @[s1, s2];
        };

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


@end