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
#import "UIImage+ResizeMagick.h"

#define vertical_grayline_width     7.0


@interface SFINotificationTableViewCell ()
@property(nonatomic) BOOL reset;
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UITextField *messageTextField;
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
    CGFloat date_width = 80;
    CGFloat circle_width = 55;
    CGFloat padding = 10;

    CGRect rect;

    rect = CGRectMake(padding, 2*padding, date_width, 30);
    self.dateLabel = [[UILabel alloc] initWithFrame:rect];

    // Draw a vertical gray line centered on the circle
    //
    CGFloat line_width = vertical_grayline_width;
    CGFloat line_center_x =  (circle_width - line_width) / 2;
    rect = CGRectMake(date_width + padding + line_center_x, -1, line_width, cell_height);
    UIImageView *verticalLine = [[UIImageView alloc] initWithFrame:rect];
    verticalLine.image = [self getVerticalGrayLineImage];
    //
    // Then draw the circle on top
    CGFloat y =  (cell_height - circle_width) / 2; // center in the cell
    rect = CGRectMake(90, y, circle_width, circle_width);
    self.circleView = [[CircleView alloc] initWithFrame:rect];
    //
    // Then draw the sensor icon on top of the circle
    rect = CGRectMake(0, 0, circle_width, circle_width);
    rect = CGRectInset(rect, 10, 10);
    self.iconView = [[UIImageView alloc] initWithFrame:rect];
    [self.circleView addSubview:self.iconView];

    CGFloat message_x = date_width + padding + circle_width + padding;
    rect = CGRectMake(message_x, 5, cell_width - message_x - padding, 50);
    self.messageTextField = [[UITextField alloc] initWithFrame:rect];
    self.messageTextField.userInteractionEnabled = NO;

    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:verticalLine];
    [self.contentView addSubview:self.circleView];
    [self.contentView addSubview:self.messageTextField];

    SFINotification *notification = self.notification;
    [self setDateLabelText:notification];
    [self setIcon:notification];
    [self setMessageLabelText:notification];
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

- (UIImage *)getVerticalGrayLineImage {
    CGFloat height = CGRectGetHeight(self.bounds);
    UIImage *image = [UIImage imageNamed:@"notification_gray_line"];
    return [image resizedImageByMagick:[NSString stringWithFormat:@"%fx%f", vertical_grayline_width, height + 2]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setDateLabelText:(SFINotification *)notification {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:notification.time];
    self.dateLabel.text = [formatter stringFromDate:date];
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
    NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:notification.value attributes:attr];

    NSMutableAttributedString *container = [NSMutableAttributedString new];
    [container appendAttributedString:nameStr];
    [container appendAttributedString:eventStr];

    self.messageTextField.attributedText = container;
}

- (void)setIcon:(SFINotification *)notification {
    UIImage *image = [UIImage imageNamed:@"01_switch_on"];
    image = [image resizedImageByMagick:@"45x45#"]; // scale and crop to exactly that size, original aspect ratio preserved
    self.iconView.image = image;
}

@end
