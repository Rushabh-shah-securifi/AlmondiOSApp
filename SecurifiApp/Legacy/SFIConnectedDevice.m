//
//  SFIConnectedDevice.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIConnectedDevice.h"

@implementation SFIConnectedDevice


-(NSString*)iconName{
    if ([[self.deviceType lowercaseString] isEqualToString:@"tv"]) {
        return @"icon_appleTV";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"other"]) {
        return @"icon_help";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"mac"]) {
        return @"icon_pc";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"hub"]) {
        return @"icon_hubrouter";
    }

    if ([[self.deviceType lowercaseString] isEqualToString:@"router_switch"]) {
        return @"icon_hubrouter";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"tablet"]) {
        return @"icon_iphone";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"android stick"]) {
        return @"icon_android_stick";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"chromecast"]) {
        return @"icon_chrome_cast";
    }

    if ([[self.deviceType lowercaseString] isEqualToString:@"nest"]) {
        return @"icon_nest_google";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"printer"]) {
        return @"icon_printer";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"pc"]) {
        return @"icon_pc";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"laptop"]) {
        return @"icon_laptop";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"smartphone"]) {
        return @"icon_smartphone";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"iphone"]) {
        return @"icon_iphone";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"ipad"]) {
        return @"icon_iPad";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"ipod"]) {
        return @"icon_iPod";
    }
    if ([[self.deviceType lowercaseString] isEqualToString:@"appletv"]) {
        return @"icon_appleTV";
    }
    return @"";
}
@end
