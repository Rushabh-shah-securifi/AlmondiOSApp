//
// Created by Matthew Sinclair-Day on 2/10/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFINotificationStatusBarButtonItem.h"
#import "CircleLabel.h"
#import "Colours.h"
#import "UIFont+Securifi.h"


@interface SFINotificationStatusBarButtonItem ()
@property(nonatomic, readonly) UIButton *countButton;
@property(nonatomic, readonly) CircleLabel *countLabel;
@end

@implementation SFINotificationStatusBarButtonItem

- (instancetype)initWithStandard {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 25);

    self = [super initWithCustomView:button];
    if (self) {
        _countButton = button;
        _countLabel = [self makeCountLabel];
        self.countLabel.alpha = 0;
        [self.countButton addSubview:self.countLabel];
        [self setImageForNotificationCount:0];
        self.isDashBoard = NO;
    }

    return self;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [self initWithStandard];
    if (self) {
        [self.countButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [self.countLabel setTarget:target touchAction:action];
        self.isDashBoard = NO;
    }
    return self;
}

- (void)markNotificationCount:(NSUInteger)newCount {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self setImageForNotificationCount:newCount];
    });
}

- (void)setImageForNotificationCount:(NSUInteger)count {
    CircleLabel *label = self.countLabel;
    if (count == 0) {
        label.text = nil;
    }
    else if (count > 999) {
        label.text = @"999";
    }
    else {
        label.text = [NSString stringWithFormat:@"%lu", (unsigned long) count];
    }

    label.alpha = (count == 0) ? 0 : 1;

    UIImage *image = [self iconForNotificationCount:count];
    [self.countButton setImage:image forState:UIControlStateNormal];
}

- (CircleLabel *)makeCountLabel {
    CGRect frame = CGRectMake(22, 1, 25, 25);
    CircleLabel *label = [[CircleLabel alloc] initWithFrame:frame];
    label.cornerRadius = 12.5;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont standardUILabelFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = /*orange*/[UIColor colorFromHexString:@"ff8500"];
    return label;
}

- (UIImage *)iconForNotificationCount:(NSUInteger)count {
    if (count == 0) {
        return [UIImage imageNamed:self.isDashBoard?@"notification_home":@"bell_empty"];
    }
    else {
        return [UIImage imageNamed:self.isDashBoard?@"bell_icon_White":@"bell_icon_tilted"];
    }
}
-(void)setMiddleButtonIcon:(UILabel *)label
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 25);
    
}

@end