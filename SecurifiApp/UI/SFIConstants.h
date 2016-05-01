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

#define DEVICE_UNKNOWN_IMAGE 						    @"default_device"
#define DEVICE_RELOAD_IMAGE 						    @"00_reload_icon"
#define DEVICE_UPDATING_IMAGE 						    @"00_wait_icon"

#define DT1_BINARY_SWITCH_TRUE 							@"switch_on"
#define DT1_BINARY_SWITCH_FALSE 						@"switch_off"
#define DT2_MULTILEVEL_SWITCH_TRUE 						@"switch_on"
#define DT2_MULTILEVEL_SWITCH_FALSE 					@"switch_off"
#define DT3_BINARY_SENSOR_TRUE 						    @"door_on"
#define DT3_BINARY_SENSOR_FALSE 						@"door_off"
#define DT4_LEVEL_CONTROL_TRUE 						    @"dimmer"
#define DT4_LEVEL_CONTROL_FALSE 						@"switch_off"
#define DT5_DOOR_LOCK_LOCKED                            @"lock_close"
#define DT5_DOOR_LOCK_UNLOCKED                          @"lock_open"
#define DT6_ALARM_TRUE 						            @"alarm_on"
#define DT6_ALARM_FALSE 						        @"alarm_off"

#define D10_STANDARD_CIE_TRUE 						    @"motion_on"
#define D10_STANDARD_CIE_FALSE 						    @"motion_off"
#define DT11_MOTION_SENSOR_TRUE 						@"motion_on"
#define DT11_MOTION_SENSOR_FALSE 						@"motion_off"
#define DT12_CONTACT_SWITCH_TRUE 						@"door_on"
#define DT12_CONTACT_SWITCH_FALSE 						@"door_off"
#define DT13_FIRE_SENSOR_TRUE 						    @"13_fire_yes"
#define DT13_FIRE_SENSOR_FALSE 						    @"13_fire_no"
#define DT14_WATER_SENSOR_TRUE 						    @"14_water_drop_yes"
#define DT14_WATER_SENSOR_FALSE 						@"14_water_drop_no"
#define DT15_GAS_SENSOR_TRUE 						    @"fire_on"
#define DT15_GAS_SENSOR_FALSE 						    @"fire_off"
#define DT17_VIBRATION_SENSOR_TRUE 						@"vibration_on"
#define DT17_VIBRATION_SENSOR_FALSE 					@"vibration_off"
#define DT19_KEYFOB_TRUE 						        @"keyfob_on"
#define DT19_KEYFOB_FALSE 						        @"keyfob_off"

#define DT21_STANDARD_WARNING_DEVICE_TRUE 				@"alarm_on"
#define DT21_STANDARD_WARNING_DEVICE_FALSE  		    @"alarm_off"
#define DT22_AC_SWITCH_TRUE 						    @"ac_switch_on"
#define DT22_AC_SWITCH_FALSE 						    @"ac_switch_off"
#define DT23_DC_SWITCH_TRUE 						    @"ac_switch_on"
#define DT23_DC_SWITCH_FALSE 						    @"ac_switch_off"
#define DT25_LIGHT_SENSOR_TRUE 						    @"light_on"
#define DT25_LIGHT_SENSOR_FALSE 						@"light_off"
#define DT26_WINDOW_COVERING_TRUE 						@"window"
#define DT26_WINDOW_COVERING_FALSE 						@"window"

#define DT34_SHADE_TRUE 						        @"34_shade_open"
#define DT34_SHADE_FALSE 						        @"34_shade_closed"
#define DT36_SMOKE_DETECTOR_TRUE 						@"smoke_on"
#define DT36_SMOKE_DETECTOR_FALSE 						@"smoke_off"
#define DT37_FLOOD_TRUE 						        @"water_on"
#define DT37_FLOOD_FALSE 						        @"water_off"
#define DT38_SHOCK_TRUE 						        @"vibration_on"
#define DT38_SHOCK_FALSE 						        @"vibration_off"
#define DT39_DOOR_SENSOR_OPEN                           @"door_on"
#define DT39_DOOR_SENSOR_CLOSED                         @"door_off"

#define DT40_MOISTURE_TRUE 						        @"water_off"
#define DT40_MOISTURE_FALSE 						    @"water_on"
#define DT41_MOTION_SENSOR_TRUE 						@"motion_on"
#define DT41_MOTION_SENSOR_FALSE 						@"motion_off"
#define DT42_ALARM_TRUE 						        @"alarm_on"
#define DT42_ALARM_FALSE 						        @"alarm_off"
#define DT45_BINARY_POWER_TRUE 						    @"ac_switch_on"
#define DT45_BINARY_POWER_FALSE 						@"ac_switch_off"
#define DT48_HUE_LAMP_TRUE 						        @"light_on"
#define DT48_HUE_LAMP_FALSE 						    @"light_off"

#define DT50_SECURIFI_SMART_SWITCH_TRUE                 @"ac_switch_on"
#define DT50_SECURIFI_SMART_SWITCH_FALSE                @"ac_switch_off"

#define DT53_GARAGE_SENSOR_CLOSED                       @"garage_close"
#define DT53_GARAGE_SENSOR_DOWN                         @"icon_garage_door_down"
#define DT53_GARAGE_SENSOR_OPEN                         @"garage_open"
#define DT53_GARAGE_SENSOR_STOPPED                      @"53_garage_door_stopped"
#define DT53_GARAGE_SENSOR_UP                           @"icon_garage_door_up"
@end
