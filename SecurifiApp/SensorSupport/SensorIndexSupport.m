//
// Created by Matthew Sinclair-Day on 2/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"
#import "ValueFormatter.h"


@implementation SensorIndexSupport

- (NSArray *)push:(SFIDeviceType)device index:(SFIDevicePropertyType)type {
    switch (device) {
        case SFIDeviceType_UnknownDevice_0:break;

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
                IndexValueSupport *s1 = [IndexValueSupport new];
                s1.data = @"false";
                s1.iconName = @"01_switch_off";
                s1.notificationText = @"";

                IndexValueSupport *s2 = [IndexValueSupport new];
                s2.data = @"true";
                s2.iconName = @"01_switch_on";
                s2.notificationText = @"";

                return @[s1, s2];
            }
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
                IndexValueSupport *s1 = [IndexValueSupport new];
                s1.data = @"0";
                s1.iconName = @"01_switch_off";
                s1.notificationText = @"";

                IndexValueSupport *s2 = [IndexValueSupport new];
                s2.data = @"0";
                s2.matchType = MatchType_notequals;
                s2.iconName = @"02_dimmer";
                s2.notificationText = @"";
                s2.valueFormatter.action = ValueFormatterAction_formatString;
                s2.valueFormatter.notificationPrefix = @"";
                s2.valueFormatter.suffix = @"%";

                return @[s1, s2];
            }
        };

        case SFIDeviceType_BinarySensor_3:
        {
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
                IndexValueSupport *s1 = [IndexValueSupport new];
                s1.data = @"false";
                s1.iconName = @"03_door_off";
                s1.notificationText = @"";

                IndexValueSupport *s2 = [IndexValueSupport new];
                s2.data = @"true";
                s2.matchType = MatchType_notequals;
                s2.iconName = @"03_door_on";
                s2.notificationText = @"";

                return @[s1, s2];
            }
        };
        case SFIDeviceType_MultiLevelOnOff_4:
        {
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
                IndexValueSupport *s1 = [IndexValueSupport new];
                s1.data = @"false";
                s1.iconName = @"04_switch_off";
                s1.notificationText = @"";

                IndexValueSupport *s2 = [IndexValueSupport new];
                s2.iconName = @"03_door_on";
                s2.notificationText = @"";

                return @[s1, s2];
            }
            else if (type == SFIDevicePropertyType_SWITCH_MULTILEVEL) {
                IndexValueSupport *s1 = [IndexValueSupport new];
                s1.data = @"false";
                s1.iconName = @"03_door_off";
                s1.notificationText = @"";
                s1.valueFormatter.action = ValueFormatterAction_scale;
                s1.valueFormatter.scaleFactor = 100;
                s1.valueFormatter.notificationPrefix = @"";
                s1.valueFormatter.suffix = @"%";

                return @[s1];
            }
        };

        case SFIDeviceType_DoorLock_5:
            break;
        case SFIDeviceType_Alarm_6:break;
        case SFIDeviceType_Thermostat_7:break;
        case SFIDeviceType_Controller_8:break;
        case SFIDeviceType_SceneController_9:break;
        case SFIDeviceType_StandardCIE_10:break;

        case SFIDeviceType_MotionSensor_11:
        {
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
                IndexValueSupport *s1 = [IndexValueSupport new];
                s1.data = @"false";
                s1.iconName = @"11_motion_off";
                s1.notificationText = @"";

                IndexValueSupport *s2 = [IndexValueSupport new];
                s2.iconName = @"11_motion_on";
                s2.notificationText = @"";

                return @[s1, s2];
            }
        };

        case SFIDeviceType_ContactSwitch_12:break;
        case SFIDeviceType_FireSensor_13:break;
        case SFIDeviceType_WaterSensor_14:break;
        case SFIDeviceType_GasSensor_15:break;
        case SFIDeviceType_PersonalEmergencyDevice_16:break;
        case SFIDeviceType_VibrationOrMovementSensor_17:break;
        case SFIDeviceType_RemoteControl_18:break;
        case SFIDeviceType_KeyFob_19:break;
        case SFIDeviceType_Keypad_20:break;
        case SFIDeviceType_StandardWarningDevice_21:break;
        case SFIDeviceType_SmartACSwitch_22:break;
        case SFIDeviceType_SmartDCSwitch_23:break;
        case SFIDeviceType_OccupancySensor_24:break;
        case SFIDeviceType_LightSensor_25:break;
        case SFIDeviceType_WindowCovering_26:break;
        case SFIDeviceType_TemperatureSensor_27:break;
        case SFIDeviceType_SimpleMetering_28:break;
        case SFIDeviceType_ColorControl_29:break;
        case SFIDeviceType_PressureSensor_30:break;
        case SFIDeviceType_FlowSensor_31:break;
        case SFIDeviceType_ColorDimmableLight_32:break;
        case SFIDeviceType_HAPump_33:break;
        case SFIDeviceType_Shade_34:break;
        case SFIDeviceType_SmokeDetector_36:break;
        case SFIDeviceType_FloodSensor_37:break;
        case SFIDeviceType_ShockSensor_38:break;
        case SFIDeviceType_DoorSensor_39:break;
        case SFIDeviceType_MoistureSensor_40:break;
        case SFIDeviceType_MovementSensor_41:break;
        case SFIDeviceType_Siren_42:break;
        case SFIDeviceType_MultiSwitch_43:break;
        case SFIDeviceType_UnknownOnOffModule_44:break;
        case SFIDeviceType_BinaryPowerSwitch_45:break;
        case SFIDeviceType_HueLamp_48:break;
        case SFIDeviceType_SecurifiSmartSwitch_50:break;
    }

    return [NSArray array];
}

@end