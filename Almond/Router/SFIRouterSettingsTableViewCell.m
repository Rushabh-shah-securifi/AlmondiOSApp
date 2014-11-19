//
//  SFIRouterSettingsTableViewCell.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/10/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFIRouterSettingsTableViewCell.h"
#import "SFIWirelessSetting.h"
#import "SFICardView.h"
#import "SFIRouterTableViewActions.h"

@interface SFIRouterSettingsTableViewCell () <UITextFieldDelegate>
@end

@implementation SFIRouterSettingsTableViewCell

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
    SFIWirelessSetting *setting = self.wirelessSetting;

    [cardView addTopBorder:self.backgroundColor];
    [cardView addTitleAndOnOffSwitch:setting.ssid target:self action:@selector(onActivateDeactivate:) on:self.enabledDevice];
    [cardView addLine];
    [cardView addNameLabel:@"SSID" valueTextField:setting.ssid delegate:self tag:0];
    [cardView addShortLine];
    [cardView addNameLabel:@"Channel" valueLabel:[NSString stringWithFormat:@"%d", setting.channel]];
    [cardView addShortLine];
    [cardView addNameLabel:@"Wireless Mode" valueLabel:setting.wirelessMode];
    [cardView addShortLine];
    [cardView addNameLabel:@"Security" valueLabel:setting.security];
    [cardView addShortLine];
    [cardView addNameLabel:@"Encryption" valueLabel:setting.encryptionType];
    [cardView addShortLine];
    [cardView addNameLabel:@"Country Region" valueLabel:[NSString stringWithFormat:@"%d", setting.countryRegion]];
    [cardView addShortLine];
}

#pragma mark - UISwitch actions

- (void)onActivateDeactivate:(id)sender {
    UISwitch *ctrl = sender;
    [self.delegate onEnableDevice:self.wirelessSetting enabled:ctrl.on];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.delegate willBeginEditing];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField selectAll:self];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.delegate onChangeDeviceSSID:self.wirelessSetting newSSID:textField.text];
    [self.delegate didEndEditing];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
