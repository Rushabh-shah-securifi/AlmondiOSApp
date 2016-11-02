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
#import "CommonMethods.h"

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
@property(nonatomic) NSHashTable *enabledDisableControls;
@end

@implementation SFICardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _baseYCoordinate = 10;
        self.rightOffset = SFICardView_right_offset_normal;
        self.textColor = [UIColor whiteColor];
        self.headlineFont = [UIFont standardHeadingBoldFont];
        self.summaryFont = [UIFont securifiBoldFontLarge];
        self.bodyFont = [UIFont securifiBoldFontLarge];
        _enableActionButtons = YES;
        _enabledDisableControls = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }

    return self;
}

- (void)freezeLayout {
    _layoutFrozen = YES;
}

- (void)setEnableActionButtons:(BOOL)enabled {
    _enableActionButtons = enabled;
    [self enableManagedControl:enabled];
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
    imgLine.image = [UIImage imageNamed:@"line"];
    imgLine.alpha = 0.6;
    [self addSubview:imgLine];
    [self markYOffset:5];
}

- (void)addShortLine {
    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.baseYCoordinate, self.frame.size.width - 20, 1)];
    imgLine.image = [UIImage imageNamed:@"line"];
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
    [self addManagedControl:settingsButton];
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
    NSLog(@"cardview summary msg = %@",msg);
    NSUInteger lineCount = [SFICardView getLineCount:msgs];
    lineCount = (lineCount == 0) ? 1 : lineCount + 1;

    UILabel *label = [self makeMultiLineLabel:msg font:self.summaryFont alignment:NSTextAlignmentLeft numberOfLines:(int)lineCount rightOffset:self.rightOffset];
    [self addSubview:label];
    [self markYOffsetUsingRect:label.frame addAdditional:0];
    return label;
}

+ (NSInteger)getLineCount:(NSArray*)msgs{
    int lines = 0;
    for(NSString *msg in msgs){
        if(msg.length > 21){ //after 21 chars msg goes to 2 lines
            lines += 2;
        }else{
            lines++;
        }
    }
    return lines;
}

- (UILabel *)addLongSummary:(NSString*)msg {
    UILabel *label = [self makeMultiLineLabel:msg font:self.summaryFont alignment:NSTextAlignmentLeft numberOfLines:6 rightOffset:self.rightOffset];
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

- (void)addTextFieldPlaceHolder:(NSString *)placeHolder placeHolderColor:(UIColor *)placeHolderColor delegate:(id <UITextFieldDelegate>)delegate tag:(NSInteger)tag target:(id)target action:(SEL)action buttonTitle:(NSString *)buttonTitle {
    CGFloat right_offset = [self standardRightOffset:SFICardView_right_offset_inset];
    CGFloat left_offset = 10;
    CGFloat width = CGRectGetWidth(self.frame) - right_offset - left_offset;
    CGRect frame = CGRectMake(left_offset, self.baseYCoordinate, width, 30);

    UITextField *field = [self makeTextField:nil frame:frame];
    field.delegate = delegate;
    field.tag = tag;
    field.textAlignment = NSTextAlignmentLeft;

    if (!placeHolder || !placeHolderColor) {
        field.placeholder = placeHolder;
    }
    else {
        field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{ NSForegroundColorAttributeName : placeHolderColor}];
    }

    [self addSubview:field];

    UIButton *button = [self makeButton:target action:action buttonTitle:buttonTitle];
    [self addSubview:button];
    [self addManagedControl:button];

    [self markYOffsetUsingRect:button.frame addAdditional:0];
}

- (void)addNameLabel:(NSString*)name valueTextField:(NSString *)value delegate:(id<UITextFieldDelegate>)delegate tag:(NSInteger)tag {
    UIFont *font = self.bodyFont;

    UILabel *label = [self makeLabel:name font:font alignment:NSTextAlignmentLeft];
    [self addSubview:label];

    UITextField *field = [self makeTextField:value frame:[self makeFieldValueRect:120]];
    field.delegate = delegate;
    field.tag = tag;
    [self addSubview:field];

    [self markYOffsetUsingRect:field.frame addAdditional:5];
}

- (UITextField *)makeTextField:(NSString *)text frame:(CGRect)frame {
    UIColor *color = [self.backgroundColor blackOrWhiteContrastingColor];

    UITextField *field = [[UITextField alloc] initWithFrame:frame];
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
    CGRect frame = CGRectMake(width - 40, 30, 23, 23);

   // UIImage *image = [UIImage imageNamed:@"icon_config"];

    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.frame = frame;
    settingsButton.backgroundColor = [UIColor clearColor];
    [settingsButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [settingsButton setImage:[UIImage imageNamed:@"icon_config"] forState:UIControlStateNormal];

    self.settingsButton = settingsButton;
    [self setEditIconEditing:editing];
    [self addSubview:settingsButton];
    [self addManagedControl:settingsButton];

    UIButton *settingsButtonCell = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButtonCell.frame = CGRectMake(width - 80, 5, 80, 80);
    settingsButtonCell.backgroundColor = [UIColor clearColor];
    [settingsButtonCell addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:settingsButtonCell];
    [self addManagedControl:settingsButtonCell];
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
    const CGFloat width = CGRectGetWidth(self.frame);
    const CGFloat button_width = 60;
    const CGFloat right_padding = 10;

    CGRect frame = CGRectMake(width - (button_width + right_padding), self.baseYCoordinate, button_width, 30);

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
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = whiteColor.CGColor;

    // size the button to fit the text and add padding to the button
    [button sizeToFit];
    frame = CGRectInset(button.frame, -right_padding, 0);

    // then ensure right border is flush right with specified padding
    CGFloat max_x = CGRectGetMaxX(frame);
    if (max_x >= width) {
        frame = CGRectOffset(frame, -(max_x - width + right_padding), 0);
    }
    else if ((width - max_x) < right_padding) {
        frame = CGRectOffset(frame, -(right_padding - width - max_x), 0);
    }
    else if ((width - max_x) > right_padding) {
        frame = CGRectOffset(frame, (width - max_x - right_padding), 0);
    }

    button.frame = frame;

    return button;
}

- (void)addTitleAndOnOffSwitch:(NSString *)title target:(id)target action:(SEL)action shareAction:(SEL)shareAction on:(BOOL)isSwitchOn {
    UILabel *label = [self makeTitleLabel:title];
    [self addSubview:label];

    UIButton *button = [self makeShareLinkButton:target action:shareAction];
    [self addSubview:button];
    
    UISwitch *ctrl = [self makeOnOffSwitch:target action:action on:isSwitchOn];
    [self addSubview:ctrl];
    [self addManagedControl:ctrl];

    [self markYOffsetUsingRect:label.frame addAdditional:15];
}

- (UIButton *)makeShareLinkButton:(id)target action:(SEL)action{
    CGFloat width = CGRectGetWidth(self.frame);
    CGRect frame = CGRectMake(width - 160, self.baseYCoordinate, 80, 31);
    
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    btn.backgroundColor = [UIColor grayColor];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.image = [CommonMethods imageNamed:@"share" withColor:[UIColor whiteColor]];
    imgView.center = CGPointMake(CGRectGetMidX(imgView.bounds), CGRectGetMidY(btn.bounds));
    [btn addSubview:imgView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 50, 30)];
    [CommonMethods setLableProperties:label text:@"Share" textColor:[UIColor whiteColor] fontName:@"Avenir-Roman" fontSize:16 alignment:NSTextAlignmentCenter];
    [btn addSubview:label];
    
    return btn;
}

- (void)onShareBtnTap:(id)sender{
    NSLog(@"on share btn tap");
}
- (void)addTitleAndButton:(NSString *)title target:(id)target action:(SEL)action buttonTitle:(NSString *)buttonTitle {
    UILabel *label = [self makeTitleLabel:title];
    [self addSubview:label];

    UIButton *button = [self makeButton:target action:action buttonTitle:buttonTitle];
    [self addSubview:button];
    [self addManagedControl:button];

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
    CGFloat offset = [self standardRightOffset:rightOffset];

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

#pragma mark - Manged controls (enable and disable)

- (void)addManagedControl:(UIView*) view {
    [self.enabledDisableControls addObject:view];
}

- (void)enableManagedControl:(BOOL)enabled {
    for (UIControl *control in self.enabledDisableControls) {
        control.enabled = enabled;
    }
}

- (CGFloat)standardRightOffset:(SFICardView_right_offset)rightOffset {
    CGFloat offset = (rightOffset == SFICardView_right_offset_normal) ? 30 : 75;
    return offset;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
