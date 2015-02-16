//
//  SFICloudStatusBarButtonItem.h
//
//  Created by sinclair on 6/22/14.
//
#import <Foundation/Foundation.h>

@class SFICloudStatusBarButtonItem;

typedef NS_ENUM(NSUInteger, SFICloudStatusState) {
    SFICloudStatusStateDisconnected = 1,
    SFICloudStatusStateConnecting,
    SFICloudStatusStateConnected,
    SFICloudStatusStateAlmondOffline,
    SFICloudStatusStateAtHome,
    SFICloudStatusStateAway,
};

@interface SFICloudStatusBarButtonItem : UIBarButtonItem

@property(nonatomic, readonly) SFICloudStatusState state;

- (instancetype)initWithTarget:(id)target action:(SEL)action;

- (void)markState:(SFICloudStatusState)newState;

@end