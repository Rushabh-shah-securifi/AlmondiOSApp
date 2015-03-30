//
// Created by Matthew Sinclair-Day on 3/30/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "ScoreboardTextEditorViewController.h"


@interface ScoreboardTextEditorViewController () <UITextViewDelegate>
@property(nonatomic, strong) UITextView *textView;
@end

@implementation ScoreboardTextEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
    textView.text = self.text;
    [self.view addSubview:textView];
    
    self.textView = textView;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate scoreboardTextEditorDidChangeText:self.textView.text];
}

@end