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

@implementation SFIRouterDevicesTableViewCell

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

    // Place visual indicator of "blocked" or "connected" status
    UIImage *image = [self getCardIcon];
    [cardView setCardIcon:image target:self action:@selector(onToggleBlockDevice:)];

    // Embed a card to the right of the icon
    CGRect frame = CGRectMake(80, 0, CGRectGetWidth(self.frame) - 80, CGRectGetHeight(self.frame));
    SFICardView *infoCard = [[SFICardView alloc] initWithFrame:frame];
    //
    // Place a white border between the icon and this card
    [infoCard addLeftBorder:self.backgroundColor];
    //
    // Describe the status of the device
    if (self.blockedDevice) {
        // only MAC address is available
        [infoCard addSummary:@[
                [NSString stringWithFormat:@"MAC address is %@", self.deviceMAC],
        ]];
    }
    else {
        [infoCard addSummary:@[
                [NSString stringWithFormat:@"Connected as %@", self.name],
                [NSString stringWithFormat:@"MAC address is %@", self.deviceMAC],
                [NSString stringWithFormat:@"IP address is %@", self.deviceIP],
        ]];
    }

    [cardView addSubview:infoCard];
}

- (void)onToggleBlockDevice:(id)sender {
    [self.delegate onEnableWirelessAccessForDevice:self.deviceMAC allow:!self.blockedDevice];
}

- (UIImage *)getCardIcon {
    if (self.blockedDevice) {
        return [UIImage imageNamed:@"blocked_user.png"];
    }
    else {
        return [UIImage imageNamed:@"connected_user.png"];
    }
}

@end
