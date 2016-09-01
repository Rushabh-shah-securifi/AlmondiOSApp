//
// Created by Matthew Sinclair-Day on 5/8/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "MessageView.h"
#import "UIFont+Securifi.h"
#import "SFIColors.h"

@interface MessageView ()
@property(nonatomic) BOOL didLayoutSubviews;
@end

@implementation MessageView

+ (instancetype)linkRouterMessage {
    MessageView *view = [[MessageView alloc] initWithFrame:CGRectZero];
    view.headline = NSLocalizedString(@"router.linkalmond-msg.headline", "Get Started");
    view.message = NSLocalizedString(@"router.linkalmond-msg.message", "To get started, Let's link an Almond.");
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    if (self.didLayoutSubviews) {
        return;
    }
    self.didLayoutSubviews = YES;

    CGFloat width = CGRectGetWidth(self.frame);

    UIColor *gray = [UIColor lightGrayColor];

    CGRect rect;

//    rect = CGRectMake(0, 0, width, 100);
    rect = CGRectMake(25, 100, width - 50, 50);

    UILabel *headline_label = [[UILabel alloc] initWithFrame:rect];
    headline_label.numberOfLines = 0;
    headline_label.textAlignment = NSTextAlignmentCenter;
    headline_label.text = self.headline;
    headline_label.textColor = gray;
    headline_label.font = [UIFont securifiLightFont:30];
//    headline_label.backgroundColor = [UIColor redColor];
    [self addSubview:headline_label];

    rect = CGRectMake(25, CGRectGetMaxY(rect), CGRectGetWidth(rect), 40);

    UILabel *message_label = [[UILabel alloc] initWithFrame:rect];
    message_label.numberOfLines = 0;
    message_label.textAlignment = NSTextAlignmentCenter;
    message_label.text = self.message;
    message_label.textColor = gray;
    message_label.font = [UIFont securifiBoldFontLarge];
//    message_label.backgroundColor = [UIColor yellowColor];
    [self addSubview:message_label];

    UIButton *button = [[UIButton alloc]init];
    button.frame = CGRectMake(10, CGRectGetMaxY(rect) + 30, width-20, 45);
    [button addTarget:self action:@selector(onButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"LINK ALMOND" forState:UIControlStateNormal];
    button.backgroundColor = [SFIColors lightBlueColor];
    button.titleLabel.font = [UIFont standardHeadingFont];
    [self addSubview:button];
}

- (void)onButtonTouch {
    [self.delegate messageViewDidPressButton:self];
}

@end