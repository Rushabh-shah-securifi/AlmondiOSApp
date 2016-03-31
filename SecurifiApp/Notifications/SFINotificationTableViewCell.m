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

typedef NS_ENUM(unsigned int, SFINotificationTableViewCellDebugMode) {
    SFINotificationTableViewCellDebugMode_normal,
    SFINotificationTableViewCellDebugMode_details,
    SFINotificationTableViewCellDebugMode_external_id,
};

@interface SFINotificationTableViewCell ()
@property(nonatomic) BOOL reset;
@property(nonatomic, strong) UITextField *dateLabel;
@property(nonatomic, strong) UIView *verticalLine;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UITextView *messageTextField;
@property(nonatomic, strong) CircleView *circleView;
@property(nonatomic, strong, readonly) SensorSupport *sensorSupport;
@property(nonatomic) SFINotificationTableViewCellDebugMode debugMessageMode;
@end

@implementation SFINotificationTableViewCell

- (void)dealloc {
    [self removeTextViewObserver];
}

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
    //
    UITextView *textView = [[UITextView alloc] initWithFrame:rect];
    self.messageTextField = textView;
    // allow copy but not edit/paste
    textView.userInteractionEnabled = YES;
    textView.editable = NO;
    // remove left margin
    textView.textContainer.lineFragmentPadding = 0;
    textView.textContainerInset = UIEdgeInsetsZero;
    // vertically center the content
    [textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
    //
    if (self.enableDebugMode) {
        // tapping on label will change text to show Notification external ID
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDebugMessageTap)];
        recognizer.numberOfTapsRequired = 1;
        [textView addGestureRecognizer:recognizer];
    }
    //
    // auto resize text to fit view bounds
    CGFloat fontSize = 25.0;
    textView.font = [textView.font fontWithSize:fontSize];
    //
    while (textView.contentSize.height > textView.frame.size.height && fontSize > 8.0) {
        fontSize -= 1.0;
        textView.font = [textView.font fontWithSize:fontSize];
    }
    
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.verticalLine];
    [self.contentView addSubview:self.circleView];
    [self.contentView addSubview:self.messageTextField];
    
    SFINotification *notification = self.notification;
    _sensorSupport = [SensorSupport new];
    [_sensorSupport resolveNotification:notification.deviceType index:notification.valueType value:notification.value];
    
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
    [self removeTextViewObserver];
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)removeTextViewObserver {
    [self.messageTextField removeObserver:self forKeyPath:@"contentSize"];
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
    UIFont *bold_font = [UIFont securifiBoldFont];
    UIFont *normal_font = [UIFont securifiNormalFont];
    
    NSDictionary *attr;
    
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor blackColor],
             };
        NSString *deviceName = notification.deviceName;
    //md01<<<
    if (self.notification.deviceType==SFIDeviceType_WIFIClient) {
        NSArray * properties = [self.notification.deviceName componentsSeparatedByString:@"|"];
        deviceName = properties[0];
    }
    
    //md01>>>
    // debug logging
    if (self.enableDebugMode) {
        deviceName = [NSString stringWithFormat:@"(%ld) %@", (long) self.debugCellIndexNumber, deviceName];
    }
    
    NSAttributedString *nameStr = [[NSAttributedString alloc] initWithString:deviceName attributes:attr];
    
    attr = @{
             NSFontAttributeName : bold_font,
             NSForegroundColorAttributeName : [UIColor lightGrayColor],
             };
    
    NSString *message;
    
    NSMutableAttributedString *mutableAttributedString = nil;
    switch (self.debugMessageMode) {
        case SFINotificationTableViewCellDebugMode_normal: {
            message = self.sensorSupport.notificationText;
            //md01<<<
            
            if (self.notification.deviceType==SFIDeviceType_WIFIClient) {
                NSArray * properties = [self.notification.deviceName componentsSeparatedByString:@"|"];
                message = properties[3];
                
                NSRange nameRangeInMessage = [message rangeOfString:deviceName];
                if (nameRangeInMessage.location != NSNotFound) {
                    mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:message attributes:attr];
           
                    [mutableAttributedString addAttribute:NSFontAttributeName value:bold_font range:nameRangeInMessage];
                    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:nameRangeInMessage];
                    
                }
                
            }
            //md01>>>
           
            break;
        }
            
        case SFINotificationTableViewCellDebugMode_details: {
            NSString *indexName = [SFIDeviceKnownValues propertyTypeToName:notification.valueType];
            message = [NSString stringWithFormat:@" device_type:%d, device_id:%d, index:%d, index_value:%@, index_type:%@",
                       notification.deviceType, notification.deviceId, notification.valueIndex, notification.value, indexName];
            
            break;
        };
        case SFINotificationTableViewCellDebugMode_external_id: {
            message = [NSString stringWithFormat:@" cloud_id:%@", notification.externalId];
            
            break;
        };
    }
    if (message == nil) {
        message = @"";
    }
    
    
    if (!mutableAttributedString) {
        NSAttributedString *eventStr = [[NSAttributedString alloc] initWithString:message attributes:attr];
        NSMutableAttributedString *container = [NSMutableAttributedString new];
        [container appendAttributedString:nameStr];
        [container appendAttributedString:eventStr];
        
        self.messageTextField.attributedText = container;    
    }else{
        self.messageTextField.attributedText = mutableAttributedString;
    }
}

- (void)setIcon {
    //md01<<<
    if (self.notification.deviceType==SFIDeviceType_WIFIClient) {
        NSArray * properties = [self.notification.deviceName componentsSeparatedByString:@"|"];
        Client *device = [Client new];
        device.deviceType = @"other";
        
        self.iconView.image = [UIImage imageNamed:[device iconName]];
        return;
    }
    //md01>>>
    self.iconView.image = self.sensorSupport.notificationImage;
    self.iconView.tintColor = [UIColor whiteColor];
}

// center the message text inside the view
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *textView = object;
    
    CGFloat boundsHeight = CGRectGetHeight(textView.bounds);
    CGFloat contentHeight = textView.contentSize.height;
    
    CGFloat topOffset = (CGFloat) ((boundsHeight - contentHeight * textView.zoomScale) / 2.0);
    if (topOffset < 0) {
        topOffset = 0;
    }
    
    textView.contentOffset = CGPointMake(0, -topOffset);
}

- (void)onDebugMessageTap {
    dispatch_async(dispatch_get_main_queue(), ^() {
        SFINotificationTableViewCellDebugMode nextMode = (self.debugMessageMode + 1) % 3;
        self.debugMessageMode = nextMode;
        [self setMessageLabelText:self.notification];
    });
}

@end
