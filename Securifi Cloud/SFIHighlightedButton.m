//
//  SFIHighlightedButton.h
//
//  Created by sinclair on 6/25/14.
//
#import "SFIHighlightedButton.h"


@implementation SFIHighlightedButton

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.backgroundColor = [UIColor blackColor];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
    }
    [super setHighlighted:highlighted];
}

@end