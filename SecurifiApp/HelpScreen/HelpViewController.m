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
#import "Analytics.h"

@interface HelpViewController ()<HelpScreensDelegate>
@property(nonatomic) HelpScreens *helpScreens;
@end

@implementation HelpViewController

- (void)viewDidLoad {
    NSLog(@"viewdidload");
    [super viewDidLoad];
    [self initializeHelpScreens];
    [[Analytics sharedInstance] markHelpDescriptionScreen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark help screens

-(void)initializeHelpScreens{
    if(self.isHelpTopic)
        self.helpScreens = [HelpScreens addHelpTopic:self.view HelpTopicType:self.helpTopic];
    else
        self.helpScreens = [HelpScreens initializeHelpScreen:self.view isOnMainScreen:NO startScreen:self.startScreen];
    
    self.helpScreens.delegate = self;
    [self.view addSubview:self.helpScreens];
}

#pragma mark helpscreen delegate methods
- (void)resetViewDelegate{
//    [self.helpScreens removeFromSuperview];
//    self.helpScreens = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSkipTapDelegate{
    
}


@end
