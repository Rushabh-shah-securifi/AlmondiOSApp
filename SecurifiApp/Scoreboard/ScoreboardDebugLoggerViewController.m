//
// Created by Matthew Sinclair-Day on 3/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "ScoreboardDebugLoggerViewController.h"
#import "DebugLogger.h"


@implementation ScoreboardDebugLoggerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITextView *view = [[UITextView alloc] initWithFrame:self.view.frame];
    view.showsVerticalScrollIndicator = YES;

    DebugLogger *logger = [DebugLogger instance];
    view.text = logger.logEntries;

    [self.view addSubview:view];
}

@end