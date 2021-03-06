//
//  SFICloudStatusBarButtonItem.h
//
//  Created by sinclair on 6/22/14.
//
#import "SFICloudStatusBarButtonItem.h"

@interface SFICloudStatusBarButtonItem ()
@property(nonatomic, readonly) UIButton *button;
// When enabled, alternative icons are used when representing Cloud connection state
@property(nonatomic, readonly) BOOL enableLocalNetworking;
@end

@implementation SFICloudStatusBarButtonItem

- (instancetype)initWithTarget:(id)target action:(SEL)action enableLocalNetworking:(BOOL)enableLocal {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 25);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    self = [super initWithCustomView:button];
    if (self) {
        enum SFICloudStatusState initialState = SFICloudStatusStateConnected;

        _state = initialState;
        _button = button;
        _state = initialState;
        _enableLocalNetworking = enableLocal;

        [self setStatusImage:initialState];
    }

    return self;
}

- (void)markState:(SFICloudStatusState)newState {
    dispatch_async(dispatch_get_main_queue(), ^() {
        _state = newState;
        [self setStatusImage:newState];
    });
}

- (void)setStatusImage:(enum SFICloudStatusState)state {
    BOOL localNetworking = self.enableLocalNetworking;

    UIImage *image = [self imageForState:state localNetworkingMode:localNetworking];
    UIColor *color = [self tintForState:state localNetworkMode:localNetworking];

    UIButton *button = self.button;
    button.tintColor = color;
    [button setImage:image forState:UIControlStateNormal];
}

- (UIImage *)imageForState:(SFICloudStatusState)state localNetworkingMode:(BOOL)localNetworkingMode {
    enum UIImageRenderingMode mode = UIImageRenderingModeAlwaysTemplate;
    NSString *name;

    switch (state) {
        case SFICloudStatusStateDisconnected:
            name = localNetworkingMode ? @"connection_cloud_error" : @"connection_status_01";
            if (localNetworkingMode) mode = UIImageRenderingModeAlwaysOriginal;
            break;
        case SFICloudStatusStateConnecting:
            name = @"connection_status_02";
            break;
        case SFICloudStatusStateConnected:
            name = localNetworkingMode ? @"connection_cloud_success" : @"connection_status_03";
            if (localNetworkingMode) mode = UIImageRenderingModeAlwaysOriginal;
            break;
        case SFICloudStatusStateAlmondOffline:
            name = @"connection_status_04";
            break;
        case SFICloudStatusStateAtHome:
            name = @"almond_mode_home";
            break;
        case SFICloudStatusStateAway:
            name = @"almond_mode_away";
            break;
        case SFICloudStatusStateConnectionError:
            name = @"connection_error_icon";
            if (localNetworkingMode) mode = UIImageRenderingModeAlwaysOriginal;
            break;
        case SFICloudStatusStateLocalConnection:
            name = @"connection_local_success";
            mode = UIImageRenderingModeAlwaysOriginal;
            break;
        case SFICloudStatusStateLocalConnectionOffline:
            name = @"connection_local_error";
            mode = UIImageRenderingModeAlwaysOriginal;
            break;
        default:
            return nil;
    }

    UIImage *image = [UIImage imageNamed:name];
    return [image imageWithRenderingMode:mode];
}

- (UIColor *)tintForState:(SFICloudStatusState)state localNetworkMode:(BOOL)localNetworkMode {
    switch (state) {
        case SFICloudStatusStateConnected:
        case SFICloudStatusStateDisconnected:
            return localNetworkMode ? nil : [UIColor blackColor];

        case SFICloudStatusStateConnecting:
        case SFICloudStatusStateAlmondOffline:
        case SFICloudStatusStateAtHome:
        case SFICloudStatusStateAway:
            return [UIColor blackColor];

        case SFICloudStatusStateConnectionError:
        case SFICloudStatusStateLocalConnection:
        case SFICloudStatusStateLocalConnectionOffline:
        default:
            return nil;
    }
}

@end