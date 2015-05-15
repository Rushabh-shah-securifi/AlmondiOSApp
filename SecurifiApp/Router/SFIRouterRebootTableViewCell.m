//
//  SFIRouterRebootTableViewCell.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/11/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFIRouterRebootTableViewCell.h"
#import "SFICardView.h"
#import "SFIRouterTableViewActions.h"

@interface SFIRouterRebootTableViewCell ()
@property BOOL layoutCalled;
@end

@implementation SFIRouterRebootTableViewCell

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
    [cardView addTitleAndButton:@"Reboot the router?" target:self action:@selector(onSendAction:) buttonTitle:@"Yes"];
    [cardView addSummary:@[
            @"It will take at least 2 minutes for the router",
            @"to reboot. Please refresh after sometime."
    ]];

    [cardView freezeLayout];
}

- (void)onRebootAction:(id)sender {
    [self.delegate onRebootRouterActionCalled];
}

@end
