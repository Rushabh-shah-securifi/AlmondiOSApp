//
//  NotificationAccessAndRefreshCommands.m
//  SecurifiApp
//
//  Created by Masood on 10/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "Securifitoolkit.h"
#import "ConnectionStatus.h"
#import "NotificationListRequest.h"
#import "Network.h"
#import "NetworkState.h"
#import "NotificationClearCountRequest.h"
#import "NotificationAccessAndRefreshCommands.h"

@implementation NotificationAccessAndRefreshCommands

+(NSInteger)countUnviewedNotifications {
    if (![SecurifiToolkit sharedInstance].config.enableNotifications) {
        return 0;
    }
    return [[SecurifiToolkit sharedInstance].notificationsStore countUnviewedNotifications];
}

+ (id <SFINotificationStore>)newNotificationStore {
    return [[SecurifiToolkit sharedInstance].notificationsDb newNotificationStore];
}

+ (BOOL)copyNotificationStoreTo:(NSString *)filePath {
    if (![SecurifiToolkit sharedInstance].config.enableNotifications) {
        return NO;
    }
    return [[SecurifiToolkit sharedInstance].notificationsDb copyDatabaseTo:filePath];
}

// this method sends a request to fetch the latest notifications;
// it does not handle the case of fetching older ones
+ (void)tryRefreshNotifications {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    if (!toolkit.config.enableNotifications || toolkit.currentConnectionMode== SFIAlmondConnectionMode_local) {
        return;
    }
    
    if (![ConnectionStatus isCloudLoggedIn]) {
        return;
    }
    NSLog(@"internalAsyncFetchNotifications");
    [self internalAsyncFetchNotifications:nil];
}

// sends a command to clear the notification count
+ (void)tryClearNotificationCount {
    if (![SecurifiToolkit sharedInstance].config.enableNotifications) {
        return;
    }
    
    NetworkPrecondition precondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
        enum ExpirableCommandType type = ExpirableCommandType_notificationClearCountRequest;
        NSString *aNamespace = @"notification";
        
        GenericCommand *storedCmd = [aNetwork.networkState expirableRequest:type namespace:aNamespace];
        if (storedCmd) {
            // clear the lock after execution; next command invocation will be allowed
            [aNetwork.networkState clearExpirableRequest:type namespace:aNamespace];
            // give the request 5 seconds to complete
            return storedCmd.isExpired;
        }
        else {
            [aNetwork.networkState markExpirableRequest:type namespace:aNamespace genericCommand:aCmd];
            return YES;
        }
    };
    
    // reset count internally
    [self setNotificationsBadgeCount:0];
    
    // send the command to the cloud
    NotificationClearCountRequest *req = [NotificationClearCountRequest new];
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = req.commandType;
    cmd.command = req;
    cmd.networkPrecondition = precondition;
    
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:cmd];
}

+ (NSInteger)notificationsBadgeCount {
    if (![SecurifiToolkit sharedInstance].config.enableNotifications) {
        return 0;
    }
    return [SecurifiToolkit sharedInstance].notificationsDb.badgeCount;
}

+ (void)setNotificationsBadgeCount:(NSInteger)count {
    if (![SecurifiToolkit sharedInstance].config.enableNotifications) {
        return;
    }
    
    if (![ConnectionStatus isCloudLoggedIn]) {
        return;
    }
    
    [[SecurifiToolkit sharedInstance].notificationsDb storeBadgeCount:count];
    [[SecurifiToolkit sharedInstance] postNotification:kSFINotificationBadgeCountDidChange data:nil];
}

// Sends a request for notifications
// pagestate can be nil or a defined page state. The page state also becomes an correlation ID that is parroted back in the
// response. This allows the system to track responses and ensure page states are always serviced, even across app sessions.
+ (void)internalAsyncFetchNotifications:(NSString *)pageState {
    if (![SecurifiToolkit sharedInstance].config.enableNotifications) {
        return;
    }
    
    NotificationListRequest *req = [NotificationListRequest new];
    req.pageState = pageState;
    req.requestId = pageState;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_NOTIFICATIONS_SYNC_REQUEST;
    cmd.command = req;
    
    // nil indicates request is for "refresh; get latest" request
    if (pageState == nil) {
        cmd.networkPrecondition = ^BOOL(Network *aNetwork, GenericCommand *aCmd) {
            GenericCommand *storedCmd = [aNetwork.networkState expirableRequest:ExpirableCommandType_notificationListRequest namespace:@"notification"];
            if (!storedCmd) {
                [aNetwork.networkState markExpirableRequest:ExpirableCommandType_notificationListRequest namespace:@"notification" genericCommand:aCmd];
                return YES;
            }
            // give the request 5 seconds to complete
            return storedCmd.isExpired;
        };
    }
    
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:cmd];
}

@end
