//
//  SFICardView.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/5/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFICardView.h"
#import "UIFont+Securifi.h"

@interface SFICardView ()
@property(nonatomic, readonly) float baseYCoordinate;
@property(nonatomic) UIColor *textColor;
@property(nonatomic) UIFont *headlineFont;
@property(nonatomic) UIFont *summaryFont;
@end

@implementation SFICardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _baseYCoordinate = 10;
        self.textColor = [UIColor whiteColor];
        self.headlineFont = [UIFont standardHeadingBoldFont];
        self.summaryFont = [UIFont standardUILabelFont];
    }

    return self;
}

- (void)markYOffset:(int)val {
    _baseYCoordinate += val;
}

- (void)addLine {
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.baseYCoordinate, self.frame.size.width - 15, 1)];
    imgLine.image = [UIImage imageNamed:@"line.png"];
    imgLine.alpha = 0.6;
    [self addSubview:imgLine];
    [self markYOffset:5];
}

- (void)addShortLine {
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.baseYCoordinate, self.frame.size.width - 20, 1)];
    imgLine.image = [UIImage imageNamed:@"line.png"];
    imgLine.alpha = 0.3;
    [self addSubview:imgLine];
    [self markYOffset:5];
}

- (UILabel*)addHeader:(NSString *)title {
    UILabel *label = [self makeLabel:title font:self.headlineFont alignment:NSTextAlignmentCenter];
    [self addSubview:label];
    [self markYOffset:25];

    return label;
}

- (UILabel *)addTitle:(NSString *)title {
    UILabel *label = [self makeLabel:title font:self.headlineFont alignment:NSTextAlignmentLeft];
    [self addSubview:label];
    [self markYOffset:25];

    return label;
}

- (UILabel *)addSummary:(NSArray *)msgs {
    NSString *msg;
    if (msgs) {
        msg = [msgs componentsJoinedByString:@"\n"];
    }
    else {
        msg = @"";
    }

    NSUInteger lineCount = msgs.count;
    lineCount = (lineCount == 0) ? 1 : lineCount + 1;

    UILabel *label = [self makeMultiLineLabel:msg font:self.summaryFont alignment:NSTextAlignmentLeft numberOfLines:lineCount];
    [self addSubview:label];

    [self markYOffset:lineCount * (int) self.summaryFont.pointSize];

    return label;
}

- (void)addEditIconTarget:(id)target action:(SEL)action editing:(BOOL)editing {
    CGFloat width = self.frame.size.width;
    CGRect frame = CGRectMake(width - 50, 37, 23, 23);

    UIImageView *settingsImage = [[UIImageView alloc] initWithFrame:frame];
    settingsImage.image = [UIImage imageNamed:@"icon_config.png"];
    settingsImage.alpha = (CGFloat) (editing ? 1.0 : 0.5); // change color of image when expanded
    settingsImage.userInteractionEnabled = YES;
    [self addSubview:settingsImage];

    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = settingsImage.bounds;
    settingsButton.backgroundColor = [UIColor clearColor];
    [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [settingsImage addSubview:settingsButton];

    UIButton *settingsButtonCell = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButtonCell.frame = CGRectMake(width - 80, 5, 60, 80);
    settingsButtonCell.backgroundColor = [UIColor clearColor];
    [settingsButtonCell addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingsButtonCell];
}

- (void)addOnOffSwitch:(id)target action:(SEL)action on:(BOOL)isOn {
    CGFloat width = self.frame.size.width;
    CGRect frame = CGRectMake(width - 50, 37, 23, 23);

    UISwitch *control = [[UISwitch alloc] initWithFrame:frame];
    control.on = isOn;
    [control addTarget:target action:action forControlEvents:UIControlEventValueChanged];

    [self addSubview:control];
}

- (UILabel *)makeLabel:(NSString *)title font:(UIFont*)textFont alignment:(enum NSTextAlignment)alignment {
    return [self makeMultiLineLabel:title font:textFont alignment:alignment numberOfLines:1];
}

- (UILabel *)makeMultiLineLabel:(NSString *)title font:(UIFont*)textFont alignment:(enum NSTextAlignment)alignment numberOfLines:(int)lineCount {
    CGFloat width = self.frame.size.width - 30;
    CGFloat height = textFont.pointSize * lineCount;
    CGRect frame = CGRectMake(10, self.baseYCoordinate, width, height);

    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.textColor;
    label.font = textFont;
    label.text = title;
    label.textAlignment = alignment;
    label.numberOfLines = lineCount;

    return label;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
