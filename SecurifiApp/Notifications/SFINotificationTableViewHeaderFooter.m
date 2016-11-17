//
// Created by Matthew Sinclair-Day on 2/11/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFINotificationTableViewHeaderFooter.h"
#import "Colours.h"
#import "CircleView.h"
#import "UIFont+Securifi.h"


@implementation SFINotificationTableViewHeaderFooter

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat cell_width = CGRectGetWidth(self.bounds);
    CGFloat cell_height = CGRectGetHeight(self.bounds);
    CGFloat date_width = 70;
    CGFloat circle_width = 60; // line it up on the circle drawn in the table cells
    CGFloat small_circle_width = 24;
    CGFloat small_circle_border = 5.0;
    CGFloat padding = 5;
    CGFloat left_padding = 5;
    CGFloat y_padding = 5;

    UIColor *grayColor = [UIColor colorFromHexString:@"dddddd"];

    // Draw the data label for the bucket
    //
    if (self.mode != SFINotificationTableViewHeaderFooter_vertical_line) {
        NSDictionary *attr = @{
                NSFontAttributeName : [UIFont securifiBoldFontLarge],
                NSForegroundColorAttributeName : [UIColor grayColor],
        };
        NSString *str = [self dateLabelString];
        if (!str) {
            str = @"";
        }
        NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:str attributes:attr];

        CGRect rect = CGRectMake(left_padding, y_padding, date_width + (small_circle_width / 2), circle_width);
        UITextField *field = [[UITextField alloc] initWithFrame:rect];
        field.userInteractionEnabled = NO;
        field.attributedText = nameStr; // add text first then adjust alignment
        field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        field.textAlignment = NSTextAlignmentCenter;

        [self addSubview:field];
    }

    if (self.mode != SFINotificationTableViewHeaderFooter_vertical_line) {
        // Then draw the circle on top
        CGFloat x_offset = left_padding + date_width + padding + (circle_width / 2) - (small_circle_width / 2);
        CGFloat y_offset = (cell_height - small_circle_width) / 2; // center in the cell
        CGRect rect = CGRectMake(x_offset, y_offset, small_circle_width, small_circle_width);
        CircleView *circleView = [[CircleView alloc] initWithFrame:rect];
        circleView.fillColor = [UIColor clearColor];
        circleView.edgeColor = grayColor;
        circleView.borderWidth = small_circle_border;

        [self addSubview:circleView];
    }

    {
        CGFloat line_width = 4.0;
        CGFloat line_center_x = (circle_width - line_width) / 2;
        CGFloat x_offset = left_padding + date_width + padding + line_center_x;
        CGFloat y_offset = (cell_height - small_circle_width);
        //
        if (self.mode == SFINotificationTableViewHeaderFooter_vertical_line) {
            // Draw a vertical gray line centered on the circle and going down to the bottom border
            CGRect rect = CGRectMake(x_offset, 0, line_width, cell_height);
            UIView *verticalLine = [[UIView alloc] initWithFrame:rect];
            verticalLine.backgroundColor = grayColor;

            [self addSubview:verticalLine];
        }
        else {
            if (self.mode != SFINotificationTableViewHeaderFooter_footer) {
                // Draw a vertical gray line centered on the circle and going down to the bottom border
                CGRect rect = CGRectMake(x_offset, y_offset - line_width, line_width, cell_height - y_offset + line_width);
                UIView *verticalLine = [[UIView alloc] initWithFrame:rect];
                verticalLine.backgroundColor = grayColor;

                [self addSubview:verticalLine];
            }
            if (self.mode != SFINotificationTableViewHeaderFooter_header) {
                // Draw a vertical gray line centered on the circle and running from the top border to the top of the circle
                CGFloat line_height = cell_height - y_offset + line_width;
                CGRect rect = CGRectMake(x_offset, 0, line_width, line_height);
                UIView *verticalLine = [[UIView alloc] initWithFrame:rect];
                verticalLine.backgroundColor = grayColor;

                [self addSubview:verticalLine];
            }
        }
    }

    // Draw a horizontal gray line centered on the circle and extending to the right edge
    //
    if (self.mode != SFINotificationTableViewHeaderFooter_vertical_line) {
        CGFloat line_width = 1.0;
        CGFloat x_offset = left_padding + date_width + padding + (circle_width / 2) + (small_circle_width / 2) - small_circle_border;
        CGFloat y_offset = (cell_height - small_circle_width) / 2 + (small_circle_width / 2);
        CGRect rect = CGRectMake(x_offset, y_offset, cell_width - x_offset, line_width);
        UIView *horizontalLine = [[UIView alloc] initWithFrame:rect];
        horizontalLine.backgroundColor = grayColor;

        [self addSubview:horizontalLine];
    }
}

- (NSString *)dateLabelString {
    if (self.mode == SFINotificationTableViewHeaderFooter_footer) {
        NSLocalizedString(@"notifications.headerfooter.mode.The End", @"The End");
    }

    NSDate *date = self.bucketDate;

    if ([date isToday]) {
        NSLocalizedString(@"notifications.date.Today", @"Today");
    }

    NSDate *today = [NSDate today];
    NSDate *yesterday = [today dateByAddingDays:-1];

    if ([self.self.bucketDate isEqualToDate:yesterday]) {
        return NSLocalizedString(@"notifications.bucketdate.Yesterday", @"Yesterday");
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM dd";

    return [formatter stringFromDate:date];

}


@end