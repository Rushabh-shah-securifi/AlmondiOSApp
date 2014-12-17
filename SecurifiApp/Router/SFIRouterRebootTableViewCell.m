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

@implementation SFIRouterRebootTableViewCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];

    SFICardView *cardView = self.cardView;

    [cardView addTopBorder:self.backgroundColor];
    [cardView addTitleAndButton:@"Reboot the router?" target:self action:@selector(onRebootAction:) buttonTitle:@"Yes"];
    [cardView addSummary:@[
            @"It will take at least 2 minutes for the router",
            @"to reboot. Please refresh after sometime."
    ]];
}

- (void)onRebootAction:(id)sender {
    [self.delegate onRebootRouterActionCalled];
}

@end
