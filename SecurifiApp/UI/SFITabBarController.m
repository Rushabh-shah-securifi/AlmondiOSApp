//
// Created by Matthew Sinclair-Day on 8/20/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFITabBarController.h"


@implementation SFITabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    // set up the tabs
    [self onAlmondConnectionModeDidChange:nil];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self selector:@selector(onAlmondConnectionModeDidChange:) name:kSFIDidChangeAlmondConnectionMode object:nil];
    [center addObserver:self selector:@selector(onAlmondConnectionModeDidChange:) name:kSFIDidChangeCurrentAlmond object:nil];
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:kSFIDidChangeAlmondConnectionMode object:nil];
    [center removeObserver:self name:kSFIDidChangeCurrentAlmond object:nil];
}

- (void)onAlmondConnectionModeDidChange:(NSNotification *)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        SFIAlmondPlus *plus = toolkit.currentAlmond;
        enum SFIAlmondConnectionMode mode = [toolkit connectionModeForAlmond:plus.almondplusMAC];
        switch (mode) {
            case SFIAlmondConnectionMode_cloud:
                self.viewControllers = self.cloudTabs;
                break;
            case SFIAlmondConnectionMode_local:
                self.viewControllers = self.localTabs;
                break;
        }
    });
}


@end