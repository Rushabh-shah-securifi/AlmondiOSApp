//
//  SFIHighlightedButton.h
//
//  Created by sinclair on 6/25/14.
//
#import "SFIHighlightedButton.h"


@implementation SFIHighlightedButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.highlightedBackgroundColor = [UIColor blackColor];
        self.normalBackgroundColor = [UIColor whiteColor];
    }

    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.backgroundColor = self.highlightedBackgroundColor;
    }
    else {
        self.backgroundColor = self.normalBackgroundColor;
    }
    [super setHighlighted:highlighted];
}

@end