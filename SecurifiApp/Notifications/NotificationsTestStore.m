//
// Created by Matthew Sinclair-Day on 2/23/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "NotificationsTestStore.h"
#import "SensorIndexSupport.h"
#import "IndexValueSupport.h"


@interface NotificationsTestStore ()
@property(nonatomic) NSArray *buckets;
@property(nonatomic) NSDictionary *notifications;
@end

@implementation NotificationsTestStore

- (NSUInteger)countUnviewedNotifications {
    return 0;
}

- (NSUInteger)countNotificationsForBucket:(NSDate *)bucket {
    NSArray *notifications = [self notificationsForBucket:bucket];
    return notifications.count;
}

- (NSArray *)fetchDateBuckets:(NSUInteger)limit {
    return self.buckets;
}

- (void)ensureFetchNotifications {
    // no op
}

- (SFINotification *)fetchNotificationForBucket:(NSDate *)bucket index:(NSUInteger)pos {
    NSArray *notifications = [self notificationsForBucket:bucket];
    if (pos > notifications.count) {
        return nil;
    }
    return notifications[pos];
}

- (void)markViewed:(SFINotification *)notification {
    // no op
}

- (void)markAllViewedTo:(SFINotification *)notification {
    // no op
}

- (void)markDeleted:(SFINotification *)notification {
    NSMutableDictionary *new_d = [NSMutableDictionary dictionary];

    for (NSDate *bucket in self.buckets) {
        NSMutableArray *new_n = [NSMutableArray array];

        NSArray *notifications = [self notificationsForBucket:bucket];
        for (SFINotification *n in notifications) {
            if (n.notificationId != notification.notificationId) {
                [new_n addObject:n];
            }
        }

        new_d[bucket] = new_n;
    }

    self.notifications = new_d;
}

- (void)deleteAllNotifications {
    // do nothing
}

- (NSArray *)notificationsForBucket:(NSDate *)bucket {
    NSArray *notifications = self.notifications[bucket];
    return notifications;
}

- (void)setup {
    NSDate *bucket = [NSDate date];
    self.buckets = @[bucket];

    long n_id = 0;

    NSMutableArray *notifications = [NSMutableArray new];
    for (unsigned int index = 0; index <= SFIDeviceType_count; index++) {
        SFIDeviceType type = (SFIDeviceType) index;

        SensorIndexSupport *support = [SensorIndexSupport new];
        NSArray *indexes = [support indexesFor:type];

        NSArray *array = [self makeNotificationsFor:indexes type:type notificationId:n_id];
        [notifications addObjectsFromArray:array];

        n_id += array.count;
    }

    self.notifications = @{bucket : notifications};
}

- (NSArray *)makeNotificationsFor:(NSArray *)indexes type:(SFIDeviceType)deviceType notificationId:(long)n_id {
    NSMutableArray *notifications = [NSMutableArray new];

    for (IndexValueSupport *support in indexes) {
        NSString *data;
        switch (support.matchType) {
            case MatchType_equals:
                data = support.matchData;
                break;
            case MatchType_not_equals:
                data = [support.matchData stringByAppendingString:@"-"];
                break;
            case MatchType_any:
                data = support.matchData;
                break;
        }

        n_id++;

        SFINotification *obj = [SFINotification new];
        obj.notificationId = n_id;
        obj.almondMAC = self.almondMac;
        obj.value = data;
        obj.valueType = support.valueType;
        obj.viewed = NO;
        obj.deviceType = deviceType;
        obj.deviceId = 1;
        obj.deviceName = securifi_nameToDeviceType(deviceType);

        [notifications addObject:obj];
    }

    return notifications;
}

@end