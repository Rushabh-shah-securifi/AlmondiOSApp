//
// Created by Matthew Sinclair-Day on 2/4/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFICardViewSummaryCell.h"
#import "SFICardView.h"


@implementation SFICardViewSummaryCell

- (CGFloat)computedLayoutHeight {
    // if card is already laid out, then use its computed height
    if ([self.cardView superview]) {
        return [super computedLayoutHeight];
    }

    // otherwise, estimate one
    const CGFloat height = self.summaries.count * 30.0f;
    const CGFloat min_height = 100;

    return (height < min_height) ? min_height : height;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    SFICardView *card = self.cardView;
    [card addTitle:self.title];
    [card addSummary:self.summaries];

    if (self.editTarget && self.editSelector) {
        [card addEditIconTarget:self.editTarget action:self.editSelector editing:self.expanded];
    }
}

@end