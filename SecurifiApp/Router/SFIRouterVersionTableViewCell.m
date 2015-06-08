//
// Created by Matthew Sinclair-Day on 6/8/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIRouterVersionTableViewCell.h"
#import "SFICardView.h"
#import "SFIColors.h"
#import "SFIRouterTableViewActions.h"


@interface SFIRouterVersionTableViewCell ()
@property(nonatomic) BOOL layoutCalled;
@end

@implementation SFIRouterVersionTableViewCell

#pragma mark - Layout

- (void)markReuse {
    [super markReuse];
    self.layoutCalled = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.layoutCalled) {
        return;
    }
    self.layoutCalled = YES;

    SFICardView *cardView = self.cardView;
    if (cardView.layoutFrozen) {
        return;
    }

    [cardView addTopBorder:self.backgroundColor];
    [cardView addTitleAndButton:@"Update now?" target:self action:@selector(onUpdateFirmware) buttonTitle:@"Yes"];

    [cardView addSummary:@[
            @"It will take a few minutes to update the software.",
    ]];

    [cardView freezeLayout];
}

#pragma mark - Action callbacks

- (void)onUpdateFirmware {
    [self.delegate onUpdateRouterFirmwareActionCalled];
}

@end