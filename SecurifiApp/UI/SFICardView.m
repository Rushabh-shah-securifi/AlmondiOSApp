//
//  SFICardView.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/5/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFICardView.h"
#import "UIFont+Securifi.h"
#import "UIView+Borders.h"
#import "SFIHighlightedButton.h"
#import "Colours.h"
#import "SFICopyLabel.h"

@interface SFICardView ()
@property(nonatomic, readonly) CGFloat baseYCoordinate;
@property(nonatomic) UIColor *textColor;
@property(nonatomic) UIFont *headlineFont;
@property(nonatomic) UIFont *summaryFont;
@property(nonatomic) UIFont *bodyFont;
@property(nonatomic, weak) CALayer *topBorder;
@property(nonatomic, weak) CALayer *leftBorder;
@property(nonatomic, weak) UIImageView *cardIconView;
@property(nonatomic, weak) UIButton *settingsButton;
@end

@implementation SFICardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _baseYCoordinate = 10;
        self.rightOffset = SFICardView_right_offset_normal;
        self.textColor = [UIColor whiteColor];
        self.headlineFont = [UIFont standardHeadingBoldFont];
        self.summaryFont = [UIFont standardUILabelFont];
        self.bodyFont = [UIFont standardUITextFieldFont];
    }

    return self;
}

- (void)freezeLayout {
    _frozen = YES;
}

- (void)useSmallSummaryFont {
    self.summaryFont = [[UIFont standardUILabelFont] fontWithSize:10];
}

- (void)markYOffset:(unsigned int)val {
    _baseYCoordinate += (CGFloat) val;
}

- (void)markYOffsetUsingRect:(CGRect)rect addAdditional:(unsigned int)add {
    _baseYCoordinate += CGRectGetHeight(rect) + (CGFloat) add;
}

- (CGFloat)computedLayoutHeight {
    return self.baseYCoordinate;
}

- (void)addTopBorder:(UIColor *)color {
    if (self.topBorder == nil) {
        self.topBorder = [self createTopBorderWithHeight:1.5 andColor:color];
    }
    [self.layer addSublayer:self.topBorder];
}

- (void)addLeftBorder:(UIColor *)color {
    if (self.leftBorder == nil) {
        self.leftBorder = [self createLeftBorderWithWidth:1.5 andColor:color];
    }
    [self.layer addSublayer:self.leftBorder];
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

- (void)setCardIcon:(UIImage *)image {
    if (self.cardIconView == nil) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        view.image = image;
        [self addSubview:view];
        self.cardIconView = view;
    }
    else {
        self.cardIconView.image = image;
    }
}

- (void)setCardIcon:(UIImage *)image target:(id)target action:(SEL)action {
    [self setCardIcon:image];

    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = self.cardIconView.frame;
    settingsButton.backgroundColor = [UIColor clearColor];
    [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:settingsButton];
}

- (UILabel*)addHeader:(NSString *)title {
    UILabel *label = [self makeLabel:title font:self.headlineFont alignment:NSTextAlignmentCenter];
    [self addSubview:label];
    [self markYOffsetUsingRect:label.frame addAdditional:0];

    return label;
}

- (UILabel *)addTitle:(NSString *)title {
    UILabel *label = [self makeTitleLabel:title];
    [self addSubview:label];
    [self markYOffsetUsingRect:label.frame addAdditional:0];
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

    UILabel *label = [self makeMultiLineLabel:msg font:self.summaryFont alignment:NSTextAlignmentLeft numberOfLines:(int)lineCount rightOffset:self.rightOffset];
    [self addSubview:label];
    [self markYOffsetUsingRect:label.frame addAdditional:0];

    return label;
}

- (void)addNameLabel:(NSString*)name valueLabel:(NSString *)value {
    UILabel *label;

    UIFont *font = self.bodyFont;

    label = [self makeLabel:name font:font alignment:NSTextAlignmentLeft];
    [self addSubview:label];

    label = [self makeLabel:value font:font alignment:NSTextAlignmentRight];
    [self addSubview:label];

    [self markYOffsetUsingRect:label.frame addAdditional:5];
}

- (void)addNameLabel:(NSString*)name valueTextField:(NSString *)value delegate:(id<UITextFieldDelegate>)delegate tag:(NSInteger)tag {
    UIFont *font = self.bodyFont;

    UILabel *label = [self makeLabel:name font:font alignment:NSTextAlignmentLeft];
    [self addSubview:label];

    UITextField *field = [self makeTextField:value];
    field.delegate = delegate;
    field.tag = tag;
    [self addSubview:field];

    [self markYOffsetUsingRect:field.frame addAdditional:5];
}

- (UITextField *)makeTextField:(NSString *)text  {
    UIColor *color = [self.backgroundColor blackOrWhiteContrastingColor];

    UITextField *field = [[UITextField alloc] initWithFrame:[self makeFieldValueRect:120]];
    field.text = text;
    field.textAlignment = NSTextAlignmentRight;
    field.textColor = color;
    field.font = self.bodyFont;
    field.returnKeyType = UIReturnKeyDone;

    [field addBottomBorderWithHeight:0.5 andColor:color];

    return field;
}

- (void)addEditIconTarget:(id)target action:(SEL)action editing:(BOOL)editing {
    if (self.settingsButton != nil) {
        return;
    }

    CGFloat width = CGRectGetWidth(self.frame);
    CGRect frame = CGRectMake(width - 40, 37, 23, 23);

    UIImage *image = [UIImage imageNamed:@"icon_config.png"];

    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = frame;
    settingsButton.backgroundColor = [UIColor clearColor];
    [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setImage:image forState:UIControlStateNormal];

    self.settingsButton = settingsButton;
    [self setEditIconEditing:editing];
    [self addSubview:settingsButton];

    UIButton *settingsButtonCell = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButtonCell.frame = CGRectMake(width - 80, 5, 80, 80);
    settingsButtonCell.backgroundColor = [UIColor clearColor];
    [settingsButtonCell addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingsButtonCell];
}

- (void)setEditIconEditing:(BOOL)editing {
    self.settingsButton.alpha = (CGFloat) (editing ? 1.0 : 0.5); // change color of image when expanded
}

- (UISwitch*)makeOnOffSwitch:(id)target action:(SEL)action on:(BOOL)isOn {
    CGFloat width = CGRectGetWidth(self.frame);
    CGRect frame = CGRectMake(width - 60, self.baseYCoordinate, 60, 23);

    UISwitch *control = [[UISwitch alloc] initWithFrame:frame];
    control.on = isOn;
    [control addTarget:target action:action forControlEvents:UIControlEventValueChanged];

    return control;
}

- (UIButton*)makeButton:(id)target action:(SEL)action buttonTitle:(NSString *)buttonTitle {
    CGFloat width = CGRectGetWidth(self.frame);
    CGRect frame = CGRectMake(width - 70, self.baseYCoordinate, 60, 30);

    UIFont *heavy_font = [UIFont securifiBoldFont];
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *normalColor = self.backgroundColor;
    UIColor *highlightColor = whiteColor;

    SFIHighlightedButton *button = [[SFIHighlightedButton alloc] initWithFrame:frame];
    button.normalBackgroundColor = normalColor;
    button.highlightedBackgroundColor = highlightColor;
    button.titleLabel.font = heavy_font;
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button setTitleColor:whiteColor forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchDown];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = whiteColor.CGColor;

    return button;
}

- (void)addTitleAndOnOffSwitch:(NSString *)title target:(id)target action:(SEL)action on:(BOOL)isSwitchOn {
    UILabel *label = [self makeTitleLabel:title];
    [self addSubview:label];

    UISwitch *ctrl = [self makeOnOffSwitch:target action:action on:isSwitchOn];
    [self addSubview:ctrl];

    [self markYOffsetUsingRect:label.frame addAdditional:15];
}

- (void)addTitleAndButton:(NSString *)title target:(id)target action:(SEL)action buttonTitle:(NSString *)buttonTitle {
    UILabel *label = [self makeTitleLabel:title];
    [self addSubview:label];

    UIButton *button = [self makeButton:target action:action buttonTitle:buttonTitle];
    [self addSubview:button];

    [self markYOffsetUsingRect:button.frame addAdditional:0];
}

- (UILabel *)makeTitleLabel:(NSString *)title {
    return [self makeMultiLineLabel:title font:self.headlineFont alignment:NSTextAlignmentLeft numberOfLines:1 rightOffset:SFICardView_right_offset_inset];
}

- (UILabel *)makeLabel:(NSString *)title font:(UIFont*)textFont alignment:(enum NSTextAlignment)alignment {
    return [self makeMultiLineLabel:title font:textFont alignment:alignment numberOfLines:1 rightOffset:SFICardView_right_offset_normal];
}

- (UILabel *)makeMultiLineLabel:(NSString *)title font:(UIFont*)textFont alignment:(enum NSTextAlignment)alignment numberOfLines:(int)lineCount rightOffset:(SFICardView_right_offset)rightOffset {
    // offsets leaves room for the "edit" icon on the right side of the card or other rules
    int offset = (rightOffset == SFICardView_right_offset_normal) ? 30 : 75;

    CGFloat width = CGRectGetWidth(self.frame) - offset;
    CGFloat height = textFont.pointSize * lineCount;
    height += textFont.pointSize; // padding
    CGRect frame = CGRectMake(10, self.baseYCoordinate, width, height);

    SFICopyLabel *label = [[SFICopyLabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.textColor;
    label.font = textFont;
    label.text = title;
    label.textAlignment = alignment;
    label.numberOfLines = lineCount;

    return label;
}

- (CGRect)makeFieldValueRect:(int)leftOffset {
    return CGRectMake(leftOffset - 10, self.baseYCoordinate, self.frame.size.width - leftOffset - 10, 30);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
