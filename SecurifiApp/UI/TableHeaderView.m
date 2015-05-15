//
// Created by Matthew Sinclair-Day on 5/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import <Colours/Colours.h>
#import "TableHeaderView.h"
#import "UIFont+Securifi.h"


@implementation TableHeaderView

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect rect;

    rect = CGRectInset(self.frame, 10, 10);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor antiqueWhiteColor];
    label.attributedText = [self messageText];

    [self addSubview:label];

    UIImage *image = [UIImage imageNamed:@"cross_icon"];
    [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    rect = CGRectMake(width - 30, height / 2, 20, 20);

    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [dismissButton setImage:image forState:UIControlStateNormal];
    dismissButton.tintColor = [UIColor lightGrayColor]; // tint the image
    [dismissButton addTarget:self action:@selector(onDismiss) forControlEvents:UIControlEventTouchUpInside];
    dismissButton.frame = rect;

    [self addSubview:dismissButton];
}


#pragma mark - Event handling

- (void)onDismiss {
    [self.delegate tableHeaderViewDidTapButton:self];
}

#pragma mark - String making

- (NSMutableAttributedString *)messageText {
    NSAttributedString *headline = [self headlineString];
    NSAttributedString *message = [self messageString];

    NSMutableAttributedString *str = [NSMutableAttributedString new];
    [str appendAttributedString:headline];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];
    [str appendAttributedString:message];

    return str;
}

- (NSAttributedString *)headlineString {
    NSString *str = self.headline;
    UIFont *font = [UIFont securifiBoldFont:16];
    return [self makeString:str font:font];
}

- (NSAttributedString *)messageString {
    NSString *str = self.message;
    UIFont *font = [UIFont securifiBoldFont];
    return [self makeString:str font:font];
}

- (NSAttributedString *)makeString:(NSString *)str font:(UIFont *)font {
    NSDictionary *attr = @{
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : [UIColor lightGrayColor],
    };

    if (!str) {
        str = @"";
    }

    return [[NSAttributedString alloc] initWithString:str attributes:attr];
}

#pragma mark - Instance factories

+ (instancetype)newAlmondVersionMessage {
    TableHeaderView *view = [TableHeaderView new];
    view.headline = @"Software Update Available";
    view.message = @"Please tap \"Settings\" on your Almond";
    return view;
}

@end