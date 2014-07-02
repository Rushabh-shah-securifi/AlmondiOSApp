//
//  SFICloudStatusBarButtonItem.h
//
//  Created by sinclair on 6/22/14.
//
#import "SFICloudStatusBarButtonItem.h"

@interface SFICloudStatusBarButtonItem ()
@property(nonatomic, readonly) UIImageView *imageView;
@end

@implementation SFICloudStatusBarButtonItem

- (id)initWithStandard {
    enum SFICloudStatusState initialState = SFICloudStatusStateConnected;

    UIImage *image = [SFICloudStatusBarButtonItem imageForState:initialState];
    _imageView = [[UIImageView alloc] initWithImage:image];
    _imageView.tintColor = [SFICloudStatusBarButtonItem tintForState:initialState];

    self = [super initWithCustomView:_imageView];
    if (self) {
        _state = initialState;
    }

    return self;
}

- (void)markState:(SFICloudStatusState)newState {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.imageView.image = [SFICloudStatusBarButtonItem imageForState:newState];
        self.imageView.tintColor = [SFICloudStatusBarButtonItem tintForState:newState];
        _state = newState;
    });
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
        default: 
            return nil;
    }

    UIImage *image = [UIImage imageNamed:name];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (UIColor *)tintForState:(SFICloudStatusState)state {
    switch (state) {
        case SFICloudStatusStateConnected:
            return [UIColor colorWithRed:0.0 green:(CGFloat) (175.0 / 255.0) blue:(CGFloat) (0.0 / 255.0) alpha:1]; // Green
        case SFICloudStatusStateDisconnected:
        case SFICloudStatusStateConnecting:
        case SFICloudStatusStateAlmondOffline:
            return [UIColor blackColor];
        default:
            return nil;
    }
}

@end