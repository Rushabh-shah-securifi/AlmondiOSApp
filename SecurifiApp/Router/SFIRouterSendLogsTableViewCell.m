//
// Created by Matthew Sinclair-Day on 5/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIRouterSendLogsTableViewCell.h"
#import "SFIRouterTableViewActions.h"
#import "SFICardView.h"


@interface SFIRouterSendLogsTableViewCell () <UITextFieldDelegate>
@property(nonatomic) BOOL layoutCalled;
@end

@implementation SFIRouterSendLogsTableViewCell

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
    [cardView addTextField:@"Describe your problem here" delegate:self tag:0 target:self action:@selector(onSendAction:) buttonTitle:@"Send"];

    [cardView freezeLayout];
}

- (void)onSendAction:(id)sender {
    [self.delegate onSendLogsActionCalled:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end