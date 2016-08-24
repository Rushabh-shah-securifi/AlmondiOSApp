//
//  HelpViewController.m
//  SecurifiApp
//
//  Created by Masood on 8/23/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HelpViewController.h"
#import "SWRevealViewController.h"
#import "HelpScreens.h"

@interface HelpViewController ()<HelpScreensDelegate>
@property(nonatomic) HelpScreens *helpScreens;
@end

@implementation HelpViewController

- (void)viewDidLoad {
    NSLog(@"viewdidload");
    [super viewDidLoad];
    
    [self initializeHelpScreens];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark help screens
-(void)initializeHelpScreens{
    self.helpScreens = [[HelpScreens alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height)];
    self.helpScreens.delegate = self;
    self.helpScreens.isOnMainScreen = NO;
    [self.helpScreens expandView];
    
    self.helpScreens.backgroundColor = [UIColor grayColor];
    [self.helpScreens addHelpItem:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-20)];
    
    self.helpScreens.startScreen = self.startScreen;
    [self.helpScreens initailizeFirstScreen];
    [self.view addSubview:self.helpScreens];
}

#pragma mark helpscreen delegate methods
- (void)resetViewDelegate{
    [self.helpScreens removeFromSuperview];
    self.helpScreens = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSkipTapDelegate{
    
}


@end
