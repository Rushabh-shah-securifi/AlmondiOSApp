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
    SFICloudStatusStateConnectionError,
    SFICloudStatusStateLocalConnection,
    SFICloudStatusStateLocalConnectionOffline,
    SFICloudStatusStateCloudConnectionNotSupported,
    SFICloudStatusStateLocalConnectionNotSupported,
};

@interface SFICloudStatusBarButtonItem : UIBarButtonItem

@property(nonatomic, readonly) SFICloudStatusState state;

@property(nonatomic) BOOL isDashBoard;

- (instancetype)initWithTarget:(id)target action:(SEL)action enableLocalNetworking:(BOOL)enableLocal isDashBoard:(BOOL)isDashboard;

- (void)markState:(SFICloudStatusState)newState;

- (void)modeUpdate:(UIImage *)image color:(UIColor *)color mode:(NSString *)mode;
@end