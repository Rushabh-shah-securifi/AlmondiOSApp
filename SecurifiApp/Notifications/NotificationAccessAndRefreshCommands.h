//
//  NotificationAccessAndRefreshCommands.h
//  SecurifiApp
//
//  Created by Masood on 10/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#ifndef NotificationAccessAndRefreshCommands_h
#define NotificationAccessAndRefreshCommands_h

@interface NotificationAccessAndRefreshCommands : NSObject

+(NSInteger)countUnviewedNotifications;
+ (id <SFINotificationStore>)newNotificationStore;
+ (BOOL)copyNotificationStoreTo:(NSString *)filePath;
+ (void)tryRefreshNotifications;
+ (void)tryClearNotificationCount;
+ (NSInteger)notificationsBadgeCount;
+ (void)setNotificationsBadgeCount:(NSInteger)count;
+ (void)internalAsyncFetchNotifications:(NSString *)pageState;

@end



#endif /* NotificationAccessAndRefreshCommands_h */
