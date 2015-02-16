//
//  SFICloudStatusBarButtonItem.h
//
//  Created by sinclair on 6/22/14.
//
#import "SFICloudStatusBarButtonItem.h"

@interface SFICloudStatusBarButtonItem ()
@property(nonatomic, readonly) UIButton *button;
@end

@implementation SFICloudStatusBarButtonItem

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 25);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    self = [super initWithCustomView:button];
    if (self) {
        enum SFICloudStatusState initialState = SFICloudStatusStateConnected;

        _state = initialState;
        _button = button;
        _state = initialState;

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
    UIImage *image = [SFICloudStatusBarButtonItem imageForState:state];

    UIButton *button = self.button;
    button.tintColor = [SFICloudStatusBarButtonItem tintForState:state];
    [button setImage:image forState:UIControlStateNormal];
}

+ (UIImage *)imageForState:(SFICloudStatusState)state {
    NSString *name;

    switch (state) {
        case SFICloudStatusStateDisconnected:
            name = @"connection_status_01.png";
            break;
        case SFICloudStatusStateConnecting:
            name = @"connection_status_02.png";
            break;
        case SFICloudStatusStateConnected:
            name = @"connection_status_03.png";
            break;
        case SFICloudStatusStateAlmondOffline:
            name = @"connection_status_04.png";
            break;
        case SFICloudStatusStateAtHome:
            name = @"connection_status_05.png";
            break;
        case SFICloudStatusStateAway:
            name = @"connection_status_06.png";
            break;
        default:
            return nil;
    }

    UIImage *image = [UIImage imageNamed:name];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIColor *)tintForState:(SFICloudStatusState)state {
    switch (state) {
        case SFICloudStatusStateConnected:
        case SFICloudStatusStateDisconnected:
        case SFICloudStatusStateConnecting:
        case SFICloudStatusStateAlmondOffline:
        case SFICloudStatusStateAtHome:
        case SFICloudStatusStateAway:
            return [UIColor blackColor];
        default:
            return nil;
    }
}

@end