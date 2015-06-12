//
// Created by Matthew Sinclair-Day on 5/8/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "MessageView.h"
#import "UIFont+Securifi.h"


@interface MessageView ()
@property(nonatomic) BOOL didLayoutSubviews;
@end

@implementation MessageView

+ (instancetype)linkRouterMessage {
    MessageView *view = [[MessageView alloc] initWithFrame:CGRectZero];
    view.headline = NSLocalizedString(@"router.linkalmond-msg.label.Let's link an Almond.", "Let's link \n an Almond.");
    view.message = NSLocalizedString(@"router.linkalmond-msg.label.Start the wizard on your Almond.", "Start the wizard on your Almond, then tap the symbol below.");
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

    rect = CGRectMake(0, 0, width, 100);
    rect = CGRectInset(rect, 25, 0);

    UILabel *headline_label = [[UILabel alloc] initWithFrame:rect];
    headline_label.numberOfLines = 0;
    headline_label.textAlignment = NSTextAlignmentCenter;
    headline_label.text = self.headline;
    headline_label.textColor = gray;
    headline_label.font = [UIFont securifiLightFont:30];
    [self addSubview:headline_label];

    rect = CGRectOffset(rect, 0, 75);

    UILabel *message_label = [[UILabel alloc] initWithFrame:rect];
    message_label.numberOfLines = 0;
    message_label.textAlignment = NSTextAlignmentCenter;
    message_label.text = self.message;
    message_label.textColor = gray;
    message_label.font = [UIFont securifiBoldFontLarge];
    [self addSubview:message_label];

    UIImage *routerImage = [UIImage imageNamed:@"router-icon"];

    CGAffineTransform scale = CGAffineTransformMakeScale(0.5, 0.5);
    const CGSize routerImageSize = CGSizeApplyAffineTransform(routerImage.size, scale);
    const CGFloat image_width = routerImageSize.width;
    const CGFloat image_height = routerImageSize.height;

    rect = CGRectMake((width - image_width) / 2, CGRectGetMaxY(rect), image_width, image_height);
    rect = CGRectOffset(rect, 0, 10);

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    [button setImage:routerImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)onButtonTouch {
    [self.delegate messageViewDidPressButton:self];
}

@end