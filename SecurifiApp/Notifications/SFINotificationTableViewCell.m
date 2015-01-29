//
//  SFINotificationTableViewCell.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/19/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFINotificationTableViewCell.h"
#import "UIFont+Securifi.h"

@interface SFINotificationTableViewCell ()
@property(nonatomic, strong) UILabel *dateLabel;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *messageLabel;
@end

@implementation SFINotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect rect;

        rect = CGRectMake(10, 10, 100, 30);
        self.dateLabel = [[UILabel alloc] initWithFrame:rect];

        rect = CGRectMake(110, 0, 50, 50);
        self.iconView = [[UIImageView alloc] initWithFrame:rect];

        rect = CGRectMake(110 + 50 + 10, 0, 200, 50);
        self.messageLabel = [[UILabel alloc] initWithFrame:rect];
        self.messageLabel.numberOfLines = 0;

        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.messageLabel];
    }

    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setNotification:(SFINotification *)notification {
    _notification = notification;

    [self setDateLabelText:notification];
    [self setIcon:notification];
    [self setMessageLabelText:notification];
}

- (void)setDateLabelText:(SFINotification *)notification {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;

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

    self.messageLabel.attributedText = container;
}

- (void)setIcon:(SFINotification *)notification {

}

@end
