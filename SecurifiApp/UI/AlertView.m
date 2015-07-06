//
// Created by Matthew Sinclair-Day on 7/6/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "AlertView.h"
#import <PureLayout/PureLayout.h>


@interface AlertView ()
@property(nonatomic) BOOL didSetupConstraints;
@end

@implementation AlertView

- (void)layoutSubviews {
    [super layoutSubviews];

    for (UIView *view in self.subviews.copy) {
        [view removeFromSuperview];
    }

    UILabel *message_label = [UILabel new];
    message_label.numberOfLines = 0;
    message_label.backgroundColor = [UIColor greenColor];
    message_label.textAlignment = NSTextAlignmentCenter;
    message_label.text = self.message;

    [self addSubview:message_label];

    for (NSString *option in self.options) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor greenColor];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitle:option forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:button];
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor greenColor];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onCancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:button];

    [self addConstraints];
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
    [views autoSetViewsDimension:ALDimensionHeight toSize:30.0];
    [views autoMatchViewsDimension:ALDimensionWidth];

    UIView *message_view = views.firstObject;
    [message_view autoPinEdgeToSuperviewEdge:ALEdgeTop];

    UIView *previousView = nil;
    for (UIView *view in views) {
        [view autoPinEdgeToSuperviewMargin:ALEdgeLeading];
        [view autoPinEdgeToSuperviewMargin:ALEdgeTrailing];

        if (previousView) {
            [view autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousView];
        }
        previousView = view;
    }
}


- (void)onOptionButtonPressed:(id)sender {
    UIButton *button = sender;
    NSString *title = button.currentTitle;

    NSInteger index = 0;
    for (NSString *option in self.options) {
        if ([option isEqualToString:title]) {
            [self.delegate alertView:self didSelectOption:index];
            break;
        }
        index++;
    }

}

- (void)onCancelButtonPressed:(id)sender {
    [self.delegate alertViewDidCancel:self];
}

@end