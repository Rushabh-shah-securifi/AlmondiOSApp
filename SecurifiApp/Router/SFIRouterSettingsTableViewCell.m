//
//  SFIRouterSettingsTableViewCell.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 11/10/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "SFIRouterSettingsTableViewCell.h"
#import "SFICardView.h"
#import "SFIRouterTableViewActions.h"

#define MAX_SSID_LENGTH 32

@interface SFIRouterSettingsTableViewCell () <UITextFieldDelegate>
@property BOOL layoutCalled;
@end

@implementation SFIRouterSettingsTableViewCell

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

    SFIWirelessSetting *setting = self.wirelessSetting;

    [cardView addTopBorder:self.backgroundColor];
    NSLog(@"ssid: %@, mode: %@", setting.ssid, self.mode);
    if([self isInREMode] || [self isGuestAndAP] || !self.enableRouterWirelessControl){
        [cardView addTitleAndShare:setting.ssid target:self shareAction:@selector(onShareBtnTap:) on:setting.enabled];
    }
    else{
        [cardView addTitleAndOnOffSwitch:setting.ssid target:self action:@selector(onActivateDeactivate:) shareAction:@selector(onShareBtnTap:) on:setting.enabled];
    }
    [cardView addLine];
    
    if([self isInREMode] || [self isGuestAndAP]){
        [cardView addNameLabel:NSLocalizedString(@"router.settings.label.SSID", @"SSID") valueLabel:setting.ssid];
    }
    else{
        [cardView addNameLabel:NSLocalizedString(@"router.settings.label.SSID", @"SSID") valueTextField:setting.ssid delegate:self tag:0];
    }
    [cardView addShortLine];
    
    
    
    /*
     if (self.enableRouterWirelessControl && ![self isInREMode]) {
        [cardView addTitleAndOnOffSwitch:setting.ssid target:self action:@selector(onActivateDeactivate:) shareAction:@selector(onShareBtnTap:) on:setting.enabled];
    }
    else {
        [cardView addTitleAndShare:setting.ssid target:self shareAction:@selector(onShareBtnTap:)];
    }
    [cardView addLine];
    NSLog(@"ssid: %@, mode: %@", setting.ssid, self.mode);
    if(setting.enabled && ![self isInREMode])
        [cardView addNameLabel:NSLocalizedString(@"router.settings.label.SSID", @"SSID") valueTextField:setting.ssid delegate:self tag:0];
    else
        [cardView addNameLabel:NSLocalizedString(@"router.settings.label.SSID", @"SSID") valueLabel:setting.ssid];
    [cardView addShortLine];
    */
    [cardView addNameLabel:NSLocalizedString(@"router.settings.label.Channel", @"Channel") valueLabel:[NSString stringWithFormat:@"%d", setting.channel]];
    [cardView addShortLine];
    [cardView addNameLabel:NSLocalizedString(@"router.settings.label.Wireless Mode", @"Wireless Mode") valueLabel:setting.wirelessMode];
    [cardView addShortLine];
    [cardView addNameLabel:NSLocalizedString(@"router.settings.label.Security", @"Security") valueLabel:setting.security];
    [cardView addShortLine];
    [cardView addNameLabel:NSLocalizedString(@"router.settings.label.Encryption",@"Encryption") valueLabel:setting.encryptionType];
    [cardView addShortLine];
    [cardView addNameLabel:NSLocalizedString(@"router.settings.label.Country Region", @"Country Region") valueLabel:setting.countryRegion];
    [cardView addShortLine];

    [cardView freezeLayout];
}

-(BOOL)isInREMode{
    return [self.mode.lowercaseString isEqualToString:@"re"];
}

-(BOOL)isInAPMode{
    return [self.mode.lowercaseString isEqualToString:@"ap"];
}

-(BOOL)isGuestAndAP{
    return [self.wirelessSetting.type.lowercaseString hasPrefix:@"guest"] && [self isInAPMode];
}

#pragma mark - UISwitch actions

- (void)onActivateDeactivate:(id)sender {
    UISwitch *ctrl = sender;
    [self.delegate onEnableDevice:self.wirelessSetting enabled:ctrl.on];
}

#pragma mark - UIButton actions
- (void)onShareBtnTap:(id)sendesr{
    NSLog(@"onShareBtnTap");
    [self.delegate onShareBtnTapDelegate:self.wirelessSetting];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.delegate routerTableCellWillBeginEditingValue];
    self.cardView.enableActionButtons = NO;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    [textField selectAll:self];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return [self validateSSIDNameMaxLen:str];
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    NSString *str = textField.text;
//    return [self validateSSIDNameMinLen:str] && [self validateSSIDNameMaxLen:str];
//}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing*****");
    NSString *str = textField.text;
    if([str isEqualToString:self.wirelessSetting.ssid])
        return;
    BOOL valid = [self validateSSIDNameMinLen:str] && [self validateSSIDNameMaxLen:str];
    if (valid) {
        [textField resignFirstResponder];
        [self.delegate onChangeDeviceSSID:self.wirelessSetting newSSID:textField.text];
        [self.delegate routerTableCellDidEndEditingValue];
        self.cardView.enableActionButtons = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)validateSSIDNameMinLen:(NSString *)str {
    // SSID name value must be 1 char or longer
    return str.length >= 1;
}

- (BOOL)validateSSIDNameMaxLen:(NSString *)str {
    // SSID name value must be 180 chars or fewer
    return str.length <= MAX_SSID_LENGTH;
}

@end
