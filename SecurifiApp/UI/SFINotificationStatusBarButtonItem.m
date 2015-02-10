//
// Created by Matthew Sinclair-Day on 2/10/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFINotificationStatusBarButtonItem.h"
#import "CountLabel.h"
#import "Colours.h"
#import "UIFont+Securifi.h"


@interface SFINotificationStatusBarButtonItem ()
@property(nonatomic, readonly) UIButton *imageView;
@property(nonatomic, readonly) CountLabel *countLabel;
@end

@implementation SFINotificationStatusBarButtonItem

- (id)initWithStandard {
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    view.frame = CGRectMake(0,0,30,25);

    self = [super initWithCustomView:view];
    if (self) {
        _imageView = view;
        _countLabel = [self makeCountLabel];
        [self setImageForNotificationCount:0];
    }

    return self;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [self initWithStandard];
    if (self) {
        [self.imageView addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)markNotificationCount:(NSUInteger)newCount {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self setImageForNotificationCount:newCount];
    });
}

- (void)setImageForNotificationCount:(NSUInteger)count {
    if (count > 99) {
        self.countLabel.text = @"99+";
    }
    else {
        self.countLabel.text = [NSString stringWithFormat:@"%i", count];
    }
    [self.imageView addSubview:self.countLabel];

    UIImage *image = [self iconForNotificationCount:count];
    [self.imageView setImage:image forState:UIControlStateNormal];
}

- (CountLabel *)makeCountLabel {
    CGRect frame = CGRectMake(21,3,20,20);
    CountLabel *label = [[CountLabel alloc] initWithFrame:frame];
    label.cornerRadius = 10.0;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont standardUILabelFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor pastelOrangeColor];
    return label;
}

- (UIImage*)iconForNotificationCount:(NSUInteger)count {
    return [UIImage imageNamed:@"bell_icon_tilted"];
}

@end