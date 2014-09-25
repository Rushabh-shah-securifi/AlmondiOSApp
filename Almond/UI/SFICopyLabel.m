//
//  SFICopyLabel.h
//
//  Created by sinclair on 9/24/14.
//
#import "SFICopyLabel.h"


@implementation SFICopyLabel

#pragma mark Initialization

- (void)attachTapHandler {
    [self setUserInteractionEnabled:YES];

    UIGestureRecognizer *touchy = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:touchy];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self attachTapHandler];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self attachTapHandler];
}

#pragma mark Clipboard

- (void)copy:(id)sender {
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:self.text];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)handleTap:(UIGestureRecognizer *)recognizer {
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

@end