//
//  SFINotificationTableViewCell.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/19/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFINotificationTableViewCell.h"
#import "UIFont+Securifi.h"
#import "CircleView.h"
#import "Colours.h"

@interface SFINotificationTableViewCell ()
@property(nonatomic) BOOL reset;
@property(nonatomic, strong) UITextField *dateLabel;
@property(nonatomic, strong) UIView *verticalLine;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UITextView *messageTextField;
@property(nonatomic, strong) CircleView *circleView;
@end

@implementation SFINotificationTableViewCell

- (void)layoutSubviews {
    [super layoutSubviews];

    if (!self.reset) {
        return;
    }

    [self clearContentView];

    CGFloat cell_width = CGRectGetWidth(self.bounds);
    CGFloat cell_height = CGRectGetHeight(self.bounds);
    CGFloat date_width = 70;
    CGFloat circle_width = 60;
    CGFloat padding = 10;

    CGRect rect;

    rect = CGRectMake(padding, 5, date_width, circle_width);
    self.dateLabel = [[UITextField alloc] initWithFrame:rect];
    self.dateLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.dateLabel.userInteractionEnabled = NO;

    // Draw a vertical gray line centered on the circle
    //
    CGFloat line_width = 6.0;
    CGFloat line_center_x =  (circle_width - line_width) / 2;
    rect = CGRectMake(date_width + padding + line_center_x, 0, line_width, cell_height);
    self.verticalLine = [[UIView alloc] initWithFrame:rect];
    self.verticalLine.backgroundColor = [UIColor warmGrayColor];
    self.verticalLine.alpha = 0.60;
    //
    // Then draw the circle on top
    CGFloat y =  (cell_height - circle_width) / 2; // center in the cell
    rect = CGRectMake(date_width + padding, y, circle_width, circle_width);
    self.circleView = [[CircleView alloc] initWithFrame:rect];
    UIColor *circleColor = [self notificationStatusColor];
    self.circleView.fillColor = circleColor;
    self.circleView.edgeColor = circleColor;
    //
    // Then draw the sensor icon on top of the circle
    rect = CGRectMake(0, 0, circle_width, circle_width);
    rect = CGRectInset(rect, 15, 15);
    self.iconView = [[UIImageView alloc] initWithFrame:rect];
    self.iconView.tintColor = [UIColor whiteColor];
    [self.circleView addSubview:self.iconView];

    CGFloat message_x = date_width + padding + circle_width + padding;
    rect = CGRectMake(message_x, 5, cell_width - message_x - padding, circle_width);
    self.messageTextField = [[UITextView alloc] initWithFrame:rect];
//    self.messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.messageTextField.userInteractionEnabled = NO;

    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.verticalLine];
    [self.contentView addSubview:self.circleView];
    [self.contentView addSubview:self.messageTextField];

    SFINotification *notification = self.notification;
    [self setDateLabelText:notification];
    [self setIcon:notification];
    [self setMessageLabelText:notification];
}

- (UIColor *)notificationStatusColor {
    return self.notification.viewed ? [UIColor pastelBlueColor] : [UIColor pastelOrangeColor];
}

- (void)clearContentView {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)setNotification:(SFINotification *)notification {
    _notification = notification;
    self.reset = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setDateLabelText:(SFINotification *)notification {
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:notification.time];

    NSDictionary *attr;
    NSString *str;

    attr = @{
            NSFontAttributeName : [UIFont securifiBoldFontLarge],
            NSForegroundColorAttributeName : [UIColor grayColor],
    };
    formatter.dateFormat = @"hh:mm";
    str = [formatter stringFromDate:date];
    NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:str attributes:attr];

    attr = @{
            NSFontAttributeName : [UIFont securifiBoldFontLarge],
            NSForegroundColorAttributeName : [UIColor lightGrayColor],
    };
    formatter.dateFormat = @"a";
    str = [formatter stringFromDate:date];
    NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:str attributes:attr];

    NSMutableAttributedString *container = [NSMutableAttributedString new];
    [container appendAttributedString:nameStr];
    [container appendAttributedString:eventStr];

    self.dateLabel.attributedText = container;
}

- (void)setMessageLabelText:(SFINotification *)notification {
    NSDictionary *attr;

    attr = @{
            NSFontAttributeName : [UIFont securifiBoldFont],
            NSForegroundColorAttributeName : [UIColor blackColor],
    };
    NSString *deviceName = [notification.deviceName stringByAppendingString:@" "]; // add space before appending notification msg
    NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:deviceName attributes:attr];

    attr = @{
            NSFontAttributeName : [UIFont securifiNormalFont],
            NSForegroundColorAttributeName : [UIColor lightGrayColor],
    };
    NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:notification.message attributes:attr];

    NSMutableAttributedString *container = [NSMutableAttributedString new];
    [container appendAttributedString:nameStr];
    [container appendAttributedString:eventStr];

    self.messageTextField.attributedText = container;
}

- (void)setIcon:(SFINotification *)notification {
    UIImage *image = [UIImage imageNamed:@"test"];
//    image = [image resizedImageByMagick:@"13x19#"]; // scale and crop to exactly that size, original aspect ratio preserved
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.iconView.image = image;
}

@end
