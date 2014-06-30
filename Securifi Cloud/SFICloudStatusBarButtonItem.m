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

    self = [super initWithCustomView:_imageView];
    if (self) {
        _state = initialState;
    }

    return self;
}

- (void)markState:(SFICloudStatusState)newState {
    self.imageView.image = [SFICloudStatusBarButtonItem imageForState:newState];
    _state = newState;
}

+ (UIImage *)imageForState:(SFICloudStatusState)state {
    switch (state) {
        case SFICloudStatusStateDisconnected:
            return [UIImage imageNamed:@"connection_status_01.png"];
        case SFICloudStatusStateConnecting:
            return [UIImage imageNamed:@"connection_status_02.png"];
        case SFICloudStatusStateConnected:
            return [UIImage imageNamed:@"connection_status_03.png"];
        case SFICloudStatusStateAlmondOffline:
            return [UIImage imageNamed:@"connection_status_04.png"];
        default: 
            return nil;
    }
}

@end