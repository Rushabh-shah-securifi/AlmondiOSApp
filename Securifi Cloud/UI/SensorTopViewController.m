//
//  SensorTopViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "SensorTopViewController.h"
#import "SensorsViewController.h"
#import "DrawerViewController.h"

@implementation SensorTopViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SensorsViewController *ctrl = [[SensorsViewController alloc] init];
    [self.navigationController pushViewController:ctrl animated:YES];

    if (![self.slidingViewController.underLeftViewController isKindOfClass:[DrawerViewController class]]) {
        self.slidingViewController.underLeftViewController = [DrawerViewController new];
    }
}

@end
