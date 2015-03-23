//
// Created by Matthew Sinclair-Day on 3/17/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "ScoreboardDebugLoggerViewController.h"
#import "DebugLogger.h"


@interface ScoreboardDebugLoggerViewController ()
@property(nonatomic, readonly) UITextView *textView;
@end

@implementation ScoreboardDebugLoggerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITextView *view = [[UITextView alloc] initWithFrame:self.view.frame];
    view.showsVerticalScrollIndicator = YES;
    view.editable = NO;
    view.userInteractionEnabled = YES;
    view.opaque = YES;

    _textView = view;
    [self.view addSubview:view];

    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onDeleteLog)];
    self.navigationItem.rightBarButtonItem = delete;

    [self loadLogEntries];
}

- (void)loadLogEntries {
    DebugLogger *logger = [DebugLogger sharedInstance];
    self.textView.text = logger.logEntries;
}

- (void)onDeleteLog {
    DebugLogger *logger = [DebugLogger sharedInstance];
    [logger clear];
    [self loadLogEntries];
}

@end