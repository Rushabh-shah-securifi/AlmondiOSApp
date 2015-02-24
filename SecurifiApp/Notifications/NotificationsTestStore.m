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

- (NSArray *)fetchNotifications:(NSUInteger)limit {
    return nil;
}

- (NSArray *)fetchNotificationsForBucket:(NSDate *)bucket start:(NSUInteger)start limit:(NSUInteger)limit {
    NSArray *notifications = [self notificationsForBucket:bucket];
    if (start >= notifications.count) {
        return @[];
    }

    if (limit > notifications.count) {
        limit = notifications.count;
    }

    NSRange range = NSMakeRange(start, limit);
    return [notifications subarrayWithRange:range];
}

- (SFINotification *)fetchNotificationForBucket:(NSDate *)bucket index:(NSUInteger)pos {
    NSArray *notifications = [self notificationsForBucket:bucket];
    if (pos > notifications.count) {
        return nil;
    }
    return notifications[pos];
}

- (void)markViewed:(SFINotification *)notification {

}

- (NSArray *)notificationsForBucket:(NSDate *)bucket {
    NSArray *notifications = self.notifications[bucket];
    return notifications;
}

- (void)setup {
    NSDate *bucket = [NSDate date];
    self.buckets = @[bucket];

    NSMutableArray *notifications = [NSMutableArray new];
    for (unsigned int index = 0; index <= SFIDeviceType_count; index++) {
        SFIDeviceType type = (SFIDeviceType) index;

        SensorIndexSupport *support = [SensorIndexSupport new];
        NSArray *indexes = [support indexesFor:type];

        NSArray *array = [self makeNotificationsFor:indexes type:type];
        [notifications addObjectsFromArray:array];
    }

    self.notifications = @{bucket : notifications};
}

- (NSArray *)makeNotificationsFor:(NSArray *)indexes type:(SFIDeviceType)type {
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

        SFINotification *obj = [SFINotification new];
        obj.almondMAC = self.almondMac;
        obj.value = data;
        obj.valueType = support.valueType;
        obj.viewed = NO;
        obj.deviceType = type;
        obj.deviceId = 1;
        obj.deviceName = [SFIDevice nameForType:type];

        [notifications addObject:obj];
    }

    return notifications;
}

@end