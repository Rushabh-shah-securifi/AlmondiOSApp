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
#import "UIViewController+Securifi.h"

#define MIN_PASS_LENGTH 8
#define MAX_PASS_LENGTH 31

#define MAX_SSID_LENGTH 32

#define SSID_FIELD 0
#define PASSWORD_FIELD 1

@interface SFIRouterSettingsTableViewCell () <UITextFieldDelegate>
@property BOOL layoutCalled;
@property (nonatomic) UITextField *secureField;
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
    BOOL isCopy2GEnabled = [SecurifiToolkit sharedInstance].almondProperty.keepSameSSID.boolValue;
    
    [cardView addTopBorder:self.backgroundColor];
    
    if([SFIWirelessSetting is5G:setting.type] && [SFIWirelessSetting supportsCopy2g:self.firmware]){
        [cardView addTitleAndCopySwitch:@"Copy 2G Settings" target:self action:@selector(onCopy2g:) on:isCopy2GEnabled];
        [cardView addLine];
    }
    
    //switch - if([self isInREMode] || [self isGuestAndAP] || [self hasSlavesAndNotGuest] || [self is5GAndCopyEnabled])
    if([self isInREMode] || [self isGuestAndAP] || [self hasSlavesAndNotGuest]){
        [cardView addTitleAndShare:setting.ssid target:self shareAction:@selector(onShareBtnTap:) on:setting.enabled];
    }
    else{
        [cardView addTitleAndOnOffSwitch:setting.ssid target:self action:@selector(onActivateDeactivate:) shareAction:@selector(onShareBtnTap:) on:setting.enabled];
    }
    [cardView addLine];
    
    //ssid - if([self isInREMode] || [self isGuestAndAP] || [self is5GAndCopyEnabled])
    if([self isInREMode] || [self isGuestAndAP] || [self supportsCopy2GAndCopyEnabled] || !setting.enabled){
        [cardView addNameLabel:NSLocalizedString(@"router.settings.label.SSID", @"SSID") valueLabel:setting.ssid];
    }
    else{
        [cardView addNameLabel:NSLocalizedString(@"router.settings.label.SSID", @"SSID") valueTextField:setting.ssid delegate:self tag:SSID_FIELD];
    }
    [cardView addLine];
    
    //password
    self.secureField = [UITextField new];
    if(setting.password != nil){
        
        if([self isInREMode] || [self isGuestAndAP] || [self supportsCopy2GAndCopyEnabled] || !setting.enabled){
            [cardView addPasswordLabel:@"Password" valueLabel:setting.password];
        }
        else{
            [cardView addPasswordLabel:@"Password" field:self.secureField valueTextField:setting.password delegate:self target:self action:@selector(onShowTap:) tag:PASSWORD_FIELD];
        }
        [cardView addShortLine];
    }
    
    [cardView addNameLabel:@"Type" valueLabel:NSLocalizedString(setting.type,@"")];
    [cardView addShortLine];
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

-(BOOL)siteMapSupportFirmware:(NSString *)almondFiemware{
    if([almondFiemware hasPrefix:@"AL3-"])
        return YES;
    else
        return NO;
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

-(BOOL)hasSlavesAndNotGuest{
    return self.hasSlaves && ![self.wirelessSetting.type.lowercaseString hasPrefix:@"guest"];
}


-(BOOL)supportsCopy2GAndCopyEnabled{
    SFIWirelessSetting *setting = self.wirelessSetting;
    BOOL isCopy2GEnabled = [SecurifiToolkit sharedInstance].almondProperty.keepSameSSID.boolValue;
    return isCopy2GEnabled && [SFIWirelessSetting is5G:setting.type] && [SFIWirelessSetting supportsCopy2g:self.firmware];
}

#pragma mark - UISwitch actions

- (void)onActivateDeactivate:(id)sender {
    UISwitch *ctrl = sender;
    [self.delegate onEnableDevice:self.wirelessSetting enabled:ctrl.on];
}

- (void)onCopy2g:(UISwitch *)ctrl{
    [self.delegate onCopy2GDelegate:ctrl.isOn];
}

- (void)onShowTap:(id)sender{
    UIButton *button = sender;
    button.selected = !button.selected;
    if(button.isSelected){
        [button setTitle:@"Hide" forState:UIControlStateNormal];
        self.secureField.secureTextEntry = NO;
    }else{
        [button setTitle:@"Show" forState:UIControlStateNormal];
        self.secureField.secureTextEntry = YES;
    }
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

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    [textField selectAll:self];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    return [self validateSSIDNameMaxLen:str];
//}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    NSString *str = textField.text;
//    return [self validateSSIDNameMinLen:str] && [self validateSSIDNameMaxLen:str];
//}

-(BOOL) isHex :(NSString*) string {
    for(int i=0; i<string.length ; i++){
        unichar chr = [string characterAtIndex:i];
        if(!( (chr>=48&&chr<=57) || (chr >=65&&chr<=70) || (chr >=97 && chr <= 102) ))
            return false;
    }
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing*****");
    NSString *str = textField.text;
    BOOL valid;
    
    [textField resignFirstResponder];
    self.cardView.enableActionButtons = YES;
    
    if(textField.tag == SSID_FIELD){
        
        if([str isEqualToString:self.wirelessSetting.ssid]){
            return;
        }
        else{
            valid = [self validateSSIDNameMinLen:str] && [self validateSSIDNameMaxLen:str];
        }
        
        if (valid) {
            [self.delegate onChangeDeviceSSID:self.wirelessSetting newSSID:textField.text];
            [self.delegate routerTableCellDidEndEditingValue];
        }
    }
    else if(textField.tag == PASSWORD_FIELD){
        
        if([str isEqualToString:self.wirelessSetting.password])
            return;
        
        else if([self.wirelessSetting.security isEqualToString:@"WEP"]){
            if([self isHex:str]){
                valid = (str.length == 10 || str.length == 26);
            }else{
                valid = (str.length == 5|| str.length == 13);
            }
        }else{
            valid = [self validatePassMinLen:str] && [self validatePassMaxLen:str];
        }
        
        if(valid){
            [self.delegate onPasswordChangeDelegate:self.wirelessSetting newPass:textField.text];
        }else{
            NSString* reason = [NSString stringWithFormat:@"WEP ASCII Key Length must be 5 or 13 charactes. Your Key %@ is 16 %d long. Enter 10 or 26 characters to use a Hex Key", str, str.length];
            [self.delegate showToastDelegate:reason];
            return;
        }
    }
    
    /************/
//    if([str isEqualToString:self.wirelessSetting.ssid])
//        return;
//    
//    BOOL valid;
//    if(textField.tag == SSID_FIELD){
//        valid = [self validateSSIDNameMinLen:str] && [self validateSSIDNameMaxLen:str];
//    }
//    else if(textField.tag == PASSWORD_FIELD){
//        valid = [self validatePassMinLen:str] && [self validatePassMaxLen:str];
//    }
//    
//    if (valid) {
//        [textField resignFirstResponder];
//        if(textField.tag == SSID_FIELD){
//            [self.delegate onChangeDeviceSSID:self.wirelessSetting newSSID:textField.text];
//            [self.delegate routerTableCellDidEndEditingValue];
//        }
//        else if(textField.tag == PASSWORD_FIELD){
//            [self.delegate onPasswordChangeDelegate:self.wirelessSetting newPass:textField.text];
//        }
//        self.cardView.enableActionButtons = YES;
//    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)validatePassMinLen:(NSString *)str {
    // SSID name value must be 1 char or longer
    return str.length >= MIN_PASS_LENGTH;
}

- (BOOL)validatePassMaxLen:(NSString *)str {
    // SSID name value must be 180 chars or fewer
    return str.length <= MAX_PASS_LENGTH;
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
