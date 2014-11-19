//
//  SFIGenericRouterCommand.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 30/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, SFIGenericRouterCommandType) {
    SFIGenericRouterCommandType_REBOOT                  = 1,
    SFIGenericRouterCommandType_CONNECTED_DEVICES       = 2,
    SFIGenericRouterCommandType_BLOCKED_MACS            = 3,
    SFIGenericRouterCommandType_BLOCKED_CONTENT         = 5,
    SFIGenericRouterCommandType_WIRELESS_SETTINGS       = 7,
    SFIGenericRouterCommandType_WIRELESS_SUMMARY        = 9,
};

@interface SFIGenericRouterCommand : NSObject
@property id command;
@property SFIGenericRouterCommandType commandType;
@end
