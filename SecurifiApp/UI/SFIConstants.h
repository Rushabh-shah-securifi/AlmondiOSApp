//
//  SFIConstants.h
//  SecurifiUI
//
//  Created by Priya Yerunkar  on 11/10/13.
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIConstants : NSObject

#define SENSOR_ROW_HEIGHT       90
#define EXPANDED_ROW_HEIGHT     235
#define LEFT_LABEL_WIDTH        100

#define DEVICE_UNKNOWN_IMAGE 						    @"00_default_device"
#define DEVICE_RELOAD_IMAGE 						    @"00_reload_icon"
#define DEVICE_UPDATING_IMAGE 						    @"00_wait_icon"

#define DT1_BINARY_SWITCH_TRUE 							@"01_switch_on"
#define DT1_BINARY_SWITCH_FALSE 						@"01_switch_off"
#define DT2_MULTILEVEL_SWITCH_TRUE 						@"02_switch_on"
#define DT2_MULTILEVEL_SWITCH_FALSE 					@"02_switch_off"
#define DT3_BINARY_SENSOR_TRUE 						    @"03_door_open"
#define DT3_BINARY_SENSOR_FALSE 						@"03_door_closed"
#define DT4_LEVEL_CONTROL_TRUE 						    @"04_dimmer"
#define DT4_LEVEL_CONTROL_FALSE 						@"04_switch_off"
#define DT5_DOOR_LOCK_LOCKED                            @"05_door_lock_locked"
#define DT5_DOOR_LOCK_UNLOCKED                          @"05_door_lock_unlocked"
#define DT6_ALARM_TRUE 						            @"06_alarm_on"
#define DT6_ALARM_FALSE 						        @"06_alarm_off"

#define D10_STANDARD_CIE_TRUE 						    @"10_motion_true"
#define D10_STANDARD_CIE_FALSE 						    @"10_motion_false"
#define DT11_MOTION_SENSOR_TRUE 						@"11_motion_true"
#define DT11_MOTION_SENSOR_FALSE 						@"11_motion_false"
#define DT12_CONTACT_SWITCH_TRUE 						@"12_door_open"
#define DT12_CONTACT_SWITCH_FALSE 						@"12_door_closed"
#define DT13_FIRE_SENSOR_TRUE 						    @"13_fire_yes"
#define DT13_FIRE_SENSOR_FALSE 						    @"13_fire_no"
#define DT14_WATER_SENSOR_TRUE 						    @"14_water_drop_yes"
#define DT14_WATER_SENSOR_FALSE 						@"14_water_drop_no"
#define DT15_GAS_SENSOR_TRUE 						    @"15_fire_yes"
#define DT15_GAS_SENSOR_FALSE 						    @"15_fire_no"
#define DT17_VIBRATION_SENSOR_TRUE 						@"17_vibration_yes"
#define DT17_VIBRATION_SENSOR_FALSE 					@"17_vibration_no"
#define DT19_KEYFOB_TRUE 						        @"19_key_fob_armed"
#define DT19_KEYFOB_FALSE 						        @"19_key_fob_disarmed"

#define DT21_STANDARD_WARNING_DEVICE_TRUE 				@"20_alarm_yes"
#define DT21_STANDARD_WARNING_DEVICE_FALSE  		    @"20_alarm_no"
#define DT22_AC_SWITCH_TRUE 						    @"22_metering_on"
#define DT22_AC_SWITCH_FALSE 						    @"22_metering_off"
#define DT23_DC_SWITCH_TRUE 						    @"23_metering_on"
#define DT23_DC_SWITCH_FALSE 						    @"23_metering_off."
#define DT25_LIGHT_SENSOR_TRUE 						    @"25_bulb_on"
#define DT25_LIGHT_SENSOR_FALSE 						@"25_bulb_off"
#define DT26_WINDOW_COVERING_TRUE 						@"26_window_open"
#define DT26_WINDOW_COVERING_FALSE 						@"26_window_closed"

#define DT34_SHADE_TRUE 						        @"34_shade_open"
#define DT34_SHADE_FALSE 						        @"34_shade_closed"
#define DT36_SMOKE_DETECTOR_TRUE 						@"36_smoke_yes"
#define DT36_SMOKE_DETECTOR_FALSE 						@"36_smoke_no"
#define DT37_FLOOD_TRUE 						        @"37_water_drop_yes"
#define DT37_FLOOD_FALSE 						        @"37_water_drop_no"
#define DT38_SHOCK_TRUE 						        @"38_vibration_yes"
#define DT38_SHOCK_FALSE 						        @"38_vibration_no"
#define DT39_DOOR_SENSOR_OPEN                           @"39_door_open"
#define DT39_DOOR_SENSOR_CLOSED                         @"39_door_closed"

#define DT40_MOISTURE_TRUE 						        @"40_water_drop_no"
#define DT40_MOISTURE_FALSE 						    @"40_water_drop_yes"
#define DT41_MOTION_SENSOR_TRUE 						@"41_motion_true"
#define DT41_MOTION_SENSOR_FALSE 						@"41_motion_false"
#define DT42_ALARM_TRUE 						        @"42_alarm_yes"
#define DT42_ALARM_FALSE 						        @"42_alarm_no"
#define DT45_BINARY_POWER_TRUE 						    @"45_metering_on"
#define DT45_BINARY_POWER_FALSE 						@"45_metering_off"
#define DT48_HUE_LAMP_TRUE 						        @"48_hue_bulb_on"
#define DT48_HUE_LAMP_FALSE 						    @"48_hue_bulb_off"

#define DT50_SECURIFI_SMART_SWITCH_TRUE                 @"50_metering_on"
#define DT50_SECURIFI_SMART_SWITCH_FALSE                @"50_metering_off"

#define DT53_GARAGE_SENSOR_CLOSED                       @"53_garage_door_closed"
#define DT53_GARAGE_SENSOR_DOWN                         @"53_garage_door_down"
#define DT53_GARAGE_SENSOR_OPEN                         @"53_garage_door_open"
#define DT53_GARAGE_SENSOR_STOPPED                      @"53_garage_door_stopped"
#define DT53_GARAGE_SENSOR_UP                           @"53_garage_door_up"
@end
