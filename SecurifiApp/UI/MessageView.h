//
// Created by Matthew Sinclair-Day on 5/8/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageView;

@protocol MessageViewDelegate

// Called when the button on the view is pressed
- (void)messageViewDidPressButton:(MessageView *)msgView;

@end

// Provides a full-screen view for displaying a message and optional action button.
@interface MessageView : UIView

@property(weak) id <MessageViewDelegate> delegate;
@property(copy) NSString *headline;
@property(copy) NSString *message;

@end