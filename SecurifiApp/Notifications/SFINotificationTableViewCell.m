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
#import "SensorSupport.h"

@interface SFINotificationTableViewCell ()
@property(nonatomic) BOOL reset;
@property(nonatomic, strong) UITextField *dateLabel;
@property(nonatomic, strong) UIView *verticalLine;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UITextView *messageTextField;
@property(nonatomic, strong) CircleView *circleView;
@property(nonatomic, strong, readonly) SensorSupport *sensorSupport;
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
    CGFloat padding = 5;
    CGFloat left_padding = 5;

    UIColor *grayColor = [UIColor colorFromHexString:@"dddddd"];

    CGRect rect;

    rect = CGRectMake(left_padding, 5, date_width, circle_width);
    self.dateLabel = [[UITextField alloc] initWithFrame:rect];
    self.dateLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.dateLabel.userInteractionEnabled = NO;

    // Draw a vertical gray line centered on the circle
    //
    CGFloat line_width = 4.0;
    CGFloat line_center_x = (circle_width - line_width) / 2;
    rect = CGRectMake(left_padding + date_width + padding + line_center_x, 0, line_width, cell_height);
    self.verticalLine = [[UIView alloc] initWithFrame:rect];
    self.verticalLine.backgroundColor = grayColor;
    //
    // Then draw the circle on top
    CGFloat y = (cell_height - circle_width) / 2; // center in the cell
    rect = CGRectMake(left_padding + date_width + padding, y, circle_width, circle_width);
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

    CGFloat message_x = left_padding + date_width + padding + circle_width + padding;
    rect = CGRectMake(message_x, 5, cell_width - message_x - padding, circle_width);
    self.messageTextField = [[UITextView alloc] initWithFrame:rect];
//    self.messageTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.messageTextField.userInteractionEnabled = NO;

    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.verticalLine];
    [self.contentView addSubview:self.circleView];
    [self.contentView addSubview:self.messageTextField];

    SFINotification *notification = self.notification;
    _sensorSupport = [SensorSupport new];
    [_sensorSupport push:notification.deviceType index:notification.valueType value:notification.value];

    [self setDateLabelText:notification];
    [self setIcon];
    [self setMessageLabelText:notification];
}

- (UIColor *)notificationStatusColor {
    /*
    FOR ORANGE : RED : 255 : Green :-133  Blue : 0 (ff8500)
    FOR BLUE : RED : 0 : Green : 164    Blue : 230 (00a4e6)
     */
    return self.notification.viewed ? /*blue */[UIColor colorFromHexString:@"00a4e6"] : /*orange*/[UIColor colorFromHexString:@"ff8500"];
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
    if (notification == nil) {
        self.dateLabel.attributedText = [[NSAttributedString alloc] initWithString:@""];
        return;
    }

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
    self.dateLabel.textAlignment = NSTextAlignmentRight;
}

- (void)setMessageLabelText:(SFINotification *)notification {
    if (notification == nil) {
        self.messageTextField.attributedText = [[NSAttributedString alloc] initWithString:@""];
        return;
    }

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
    NSString *message = self.sensorSupport.notificationText;
    NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:message attributes:attr];

    NSMutableAttributedString *container = [NSMutableAttributedString new];
    [container appendAttributedString:nameStr];
    [container appendAttributedString:eventStr];

    self.messageTextField.attributedText = container;
}

- (void)setIcon {
    self.iconView.image = self.sensorSupport.notificationImage;
}

@end
