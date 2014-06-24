//
//  InitialSlidingViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "InitialSlidingViewController.h"
#import "SNLog.h"
#import "MBProgressHUD.h"

@interface InitialSlidingViewController ()
@property(nonatomic, readonly) MBProgressHUD *HUD;
@end

@implementation InitialSlidingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.dimBackground = YES;
    [self.view addSubview:_HUD];

    UIStoryboard *storyboard;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    }

    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabTop"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    UITabBarController *ctrl = (UITabBarController *) self.topViewController;
//    ctrl.tabBar.tintColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kSFIReachabilityChangedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSFIReachabilityChangedNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - Event handlers

- (void)reachabilityDidChange:(NSNotification *)notification {
    if ([[SFIReachabilityManager sharedManager] isReachable]) {
        NSLog(@"Reachable - SLIDE");
        self.HUD.labelText = @"Reconnecting...";
        [self.HUD hide:YES afterDelay:1];
    }
    else {
        NSLog(@"Unreachable");
    }
}

@end
