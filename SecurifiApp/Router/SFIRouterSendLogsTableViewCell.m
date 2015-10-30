//
// Created by Matthew Sinclair-Day on 5/15/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIRouterSendLogsTableViewCell.h"
#import "SFIRouterTableViewActions.h"
#import "SFICardView.h"


@interface SFIRouterSendLogsTableViewCell () <UITextFieldDelegate>
@property(nonatomic) BOOL layoutCalled;
@property(nonatomic) NSString *problemDescription;
@end

@implementation SFIRouterSendLogsTableViewCell

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

    switch (self.mode) {
        case SFIRouterTableViewActionsMode_unknown:
        case SFIRouterTableViewActionsMode_enterReason: {
            [cardView markYOffset:20];
            [cardView addTextFieldPlaceHolder:NSLocalizedString(@"router.log-textfield-placeholder.Describe your problem here", @"Describe your problem here") placeHolderColor:[UIColor whiteColor] delegate:self tag:0 target:self action:@selector(onSendAction:) buttonTitle:@"Send"];
            [cardView markYOffset:20];

            NSString *msg = NSLocalizedString(@"router.log-advisory message", @"Along with your message, this will send Almond debug information and logs to our cloud....");
            [cardView addLongSummary:msg];

            break;
        };

        case SFIRouterTableViewActionsMode_commandSuccess: {
            [cardView markYOffset:20];
            [cardView addSummary:@[NSLocalizedString(@"router.log-send-success.summary.Thanks for sending logs", @"Thanks for sending logs")]];
            break;

        };
        case SFIRouterTableViewActionsMode_commandError: {
            [cardView markYOffset:20];
            [cardView addSummary:@[NSLocalizedString(@"router.log-send-error.There was an error sending logs", @"There was an error sending logs")]];
            break;
        };
        case SFIRouterTableViewActionsMode_firmwareNotSupported: {
            [cardView markYOffset:20];
            [cardView addSummary:@[NSLocalizedString(@"router.log-firmware-not-supported.Please update your router's firmware", @"Please update your router's firmware"), NSLocalizedString(@"router.log-firmware-not-supported.in order to activate this functionality", @"in order to activate this functionality")]];
            break;
        };
    }

    [cardView freezeLayout];
}

#pragma mark - Action callbacks

- (void)onSendAction:(id)sender {
    [self.delegate onSendLogsActionCalled:self.problemDescription];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.problemDescription = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end