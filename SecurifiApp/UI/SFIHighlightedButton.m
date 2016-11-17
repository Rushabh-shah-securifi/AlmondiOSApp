//
//  SFIHighlightedButton.h
//
//  Created by sinclair on 6/25/14.
//
#import "SFIHighlightedButton.h"
#import "UIFont+Securifi.h"


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
- (SFIHighlightedButton *)addButton:(NSString *)buttonName button:(SFIHighlightedButton *)button color:(UIColor *)color{
    UIFont *heavy_font = [UIFont securifiBoldFontLarge];
    
    CGSize stringBoundingBox = [buttonName sizeWithAttributes:@{NSFontAttributeName : heavy_font}];
    
    int button_width = (int) (stringBoundingBox.width + 20);
    if (button_width < 60) {
        button_width = 60;
    }
    
    int right_margin = 10;
    
    button.titleLabel.font = heavy_font;
    UIColor *whiteColor = [UIColor whiteColor];
    UIColor *normalColor = color;
    UIColor *highlightColor = whiteColor;
    button.normalBackgroundColor = normalColor;
    button.highlightedBackgroundColor = highlightColor;
    [button setTitle:buttonName forState:UIControlStateNormal];
    [button setTitleColor:whiteColor forState:UIControlStateNormal];
    [button setTitleColor:normalColor forState:UIControlStateHighlighted];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = whiteColor.CGColor;
    
    return button;
    
}


@end