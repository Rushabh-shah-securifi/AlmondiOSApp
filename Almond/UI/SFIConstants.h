//
//  SFIConstants.h
//  SecurifiUI
//
//  Created by Priya Yerunkar  on 11/10/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIConstants : NSObject
#define SENSOR_ROW_HEIGHT 90
#define EXPANDED_ROW_HEIGHT 230
#define WIRELESS_USER_ROW_HEIGHT 100
#define LEFT_LABEL_WIDTH 80


#define DT1_BINARY_SWITCH_TRUE @"switch_on.png"
#define DT1_BINARY_SWITCH_FALSE @"switch_off.png"
#define DT2_MULTILEVEL_SWITCH_TRUE @"dimmer.png"
#define DT2_MULTILEVEL_SWITCH_FALSE @"switch_off.png"
#define DT3_BINARY_SENSOR_TRUE @"door_on.png"
#define DT3_BINARY_SENSOR_FALSE @"door_off.png"
#define DT4_LEVEL_CONTROL_TRUE @"dimmer.png"
#define DT4_LEVEL_CONTROL_FALSE @"switch_off.png"
#define DT5_DOOR_LOCK_TRUE @"door_lock_1.png"
#define DT5_DOOR_LOCK_FALSE @"door_lock_2.png"
#define DT6_ALARM_TRUE @"alarm_2.png"
#define DT6_ALARM_FALSE @"alarm_1.png"
#define DT11_MOTION_SENSOR_TRUE @"motion_sensor_true.png"
#define DT11_MOTION_SENSOR_FALSE @"motion_sensor_false.png"
#define DT12_CONTACT_SWITCH_TRUE @"door_on.png"
#define DT12_CONTACT_SWITCH_FALSE @"door_off.png"
#define DT13_FIRE_SENSOR_TRUE @"fire_02.png"
#define DT13_FIRE_SENSOR_FALSE @"fire_01.png"
#define DT14_WATER_SENSOR_TRUE @"water_drop2.png"
#define DT14_WATER_SENSOR_FALSE @"water_drop1.png"
#define DT15_GAS_SENSOR_TRUE @"fire_02.png"
#define DT15_GAS_SENSOR_FALSE @"fire_01.png"
#define DT17_VIBRATION_SENSOR_TRUE @"vibration_sensor_2.png"
#define DT17_VIBRATION_SENSOR_FALSE @"vibration_sensor_1.png"
#define DT19_KEYFOB_TRUE @"19_key_fob_1.png"
#define DT19_KEYFOB_FALSE @"19_key_fob_2.png"

#define DT20_KEYPAD_TRUE @"19_key_fob_1.png"
#define DT20_KEYPAD_FALSE @"19_key_fob_2.png"

#define DT21_STANDARD_WARNING_DEVICE_TRUE @"19_key_fob_1.png"
#define DT21_STANDARD_WARNING_DEVICE_FALSE  @"19_key_fob_2.png"

#define DT22_AC_SWITCH_TRUE @"metering_2.png"
#define DT22_AC_SWITCH_FALSE @"metering_1.png"
#define DT23_DC_SWITCH_TRUE @"metering_2.png"
#define DT23_DC_SWITCH_FALSE @"metering_1.png"
#define DT26_WINDOW_COVERING_TRUE @"window_106x140.png"
#define DT26_WINDOW_COVERING_FALSE @"window_106x140.png"
//#define DT27_TEMP_SENSOR_TRUE @"door_on.png"
//#define DT27_TEMP_SENSOR_FALSE @"door_off.png"
#define DT34_SHADE_TRUE @"shade_106x140.png"
#define DT34_SHADE_FALSE @"shade_106x140.png"
#define DT36_SMOKE_DETECTOR_TRUE @"water_drop2.png"
#define DT36_SMOKE_DETECTOR_FALSE @"water_drop1.png"
#define DT37_FLOOD_TRUE @"water_drop2.png"
#define DT37_FLOOD_FALSE @"water_drop1.png"
#define DT38_SHOCK_TRUE @"vibration_sensor_2.png"
#define DT38_SHOCK_FALSE @"vibration_sensor_1.png"
#define DT39_DOOR_SENSOR_TRUE @"door_off.png"
#define DT39_DOOR_SENSOR_FALSE @"door_on.png"

#define DEVICE_TAMPERED @"Device has been tampered with."
#define BATTERY_IS_LOW @"Alert! Battery is low."

+ (void)dismissKeyboard;
@end
