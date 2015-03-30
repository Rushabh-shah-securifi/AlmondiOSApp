//
//  SFIRouterDevicesTableViewCell.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/11/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFIRouterDevicesTableViewCell.h"
#import "SFICardView.h"
#import "SFIRouterTableViewActions.h"

@interface SFIRouterDevicesTableViewCell ()
@property BOOL layoutCalled;
@end

@implementation SFIRouterDevicesTableViewCell

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
    if (cardView.isFrozen) {
        return;
    }

    [cardView addTopBorder:self.backgroundColor];

    // Place visual indicator of "blocked" or "connected" status
    UIImage *image = [self getCardIcon];
    [cardView setCardIcon:image target:self action:@selector(onToggleBlockDevice:)];

    // Embed a card to the right of the icon
    CGRect frame = CGRectMake(80, 0, CGRectGetWidth(self.frame) - 80, CGRectGetHeight(self.frame));
    SFICardView *infoCard = [[SFICardView alloc] initWithFrame:frame];
    [infoCard useSmallSummaryFont];
    //
    // Place a white border between the icon and this card
    [infoCard addLeftBorder:self.backgroundColor];
    //
    // Describe the status of the device
    if (self.allowedDevice) {
        [infoCard addSummary:@[
                [NSString stringWithFormat:@"Connected as %@", self.name],
                [NSString stringWithFormat:@"MAC address is %@", self.deviceMAC],
                [NSString stringWithFormat:@"IP address is %@", self.deviceIP],
        ]];
    }
    else {
        // only MAC address is available
        [infoCard addSummary:@[
                [NSString stringWithFormat:@"MAC address is %@", self.deviceMAC],
        ]];
    }

    [cardView addSubview:infoCard];

    [cardView freezeLayout];
}

- (void)onToggleBlockDevice:(id)sender {
    [self.delegate onEnableWirelessAccessForDevice:self.deviceMAC allow:!self.allowedDevice];
}

- (UIImage *)getCardIcon {
    if (self.allowedDevice) {
        return [UIImage imageNamed:@"connected_user.png"];
    }
    else {
        return [UIImage imageNamed:@"blocked_user.png"];
    }
}

@end
