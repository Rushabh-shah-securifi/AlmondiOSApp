//
// Created by Matthew Sinclair-Day on 8/20/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


// A tab bar controller that automatically places different view tabs depending on the connection mode used by
// the currently selected Almond. To use, add views for cloud and local connections. Do not populate the viewControllers
// property, as this controller will manage that.
@interface SFITabBarController : UITabBarController

// tabs to be shown when an Almond is on cloud connection
@property(nonatomic, strong) NSArray *cloudTabs;

// tabs to be show when an Almond is using local connection
@property(nonatomic, strong) NSArray *localTabs;

@end