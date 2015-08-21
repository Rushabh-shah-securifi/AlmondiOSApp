//
// Created by Matthew Sinclair-Day on 7/6/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "AlertView.h"
#import "UIFont+Securifi.h"
#import "AlertViewAction.h"
#import <PureLayout/PureLayout.h>
#import <Colours/Colours.h>


@interface AlertView ()
@property(nonatomic) BOOL didSetupConstraints;
@end

@implementation AlertView

- (void)layoutSubviews {
    for (UIView *view in self.subviews.copy) {
        [view removeFromSuperview];
    }

    UILabel *message_label = [UILabel new];
    message_label.numberOfLines = 0;
    message_label.textAlignment = NSTextAlignmentCenter;
    message_label.text = self.message;
    message_label.textColor = [UIColor lightGrayColor];
    message_label.font = [UIFont standardHeadingBoldFont];

    [self addSubview:message_label];

    UIColor *buttonTextColor = [UIColor infoBlueColor];
    UIColor *buttonPressedColor = [buttonTextColor complementaryColor];

    for (AlertViewAction *action in self.actions) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.enabled = action.enabled;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont standardHeadingBoldFont];
        [button setTitle:action.title forState:UIControlStateNormal];
        [button setTitleColor:buttonTextColor forState:UIControlStateNormal];
        [button setTitleColor:buttonPressedColor forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(onActionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:button];
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont standardHeadingBoldFont];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [button setTitleColor:buttonPressedColor forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(onCancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:button];

    [self addConstraints];

    [super layoutSubviews];
}

- (void)updateConstraints {
    [super updateConstraints];

    if (self.didSetupConstraints) {
        return;
    }
    self.didSetupConstraints = YES;

    [self addConstraints];
}

- (void)addConstraints {
    NSArray *views = self.subviews;

    UIView *message_view = views.firstObject;
    [message_view autoPinEdgeToSuperviewEdge:ALEdgeTop];

    UIView *previousView = nil;
    for (UIView *view in views) {
        [view autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20];
        [view autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:20];

        CGFloat size = (CGFloat) ((view == message_view) ? 100.0 : 40.0);
        [view autoSetDimension:ALDimensionHeight toSize:size];

        if (previousView) {
            [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousView];
        }
        previousView = view;
    }
}


- (void)onActionButtonPressed:(id)sender {
    UIButton *button = sender;
    NSString *title = button.currentTitle;

    for (AlertViewAction *action in self.actions) {
        if ([action.title isEqualToString:title]) {
            [self.delegate alertView:self didSelectAction:action];
            return;
        }
    }
}

- (void)onCancelButtonPressed:(id)sender {
    [self.delegate alertViewDidCancel:self];
}

@end