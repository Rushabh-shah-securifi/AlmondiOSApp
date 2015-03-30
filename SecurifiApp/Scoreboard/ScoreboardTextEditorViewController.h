//
// Created by Matthew Sinclair-Day on 3/30/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScoreboardTextEditorViewControllerProtocol

- (void)scoreboardTextEditorDidChangeText:(NSString *)newText;

@end


@interface ScoreboardTextEditorViewController : UIViewController

@property(weak) id <ScoreboardTextEditorViewControllerProtocol> delegate;

@property NSString *text;

@end