//
//  SFIRouterSettingsTableViewController.m
//  Securifi Cloud
//
//  Created by Matthew Sinclair-Day on 2015/08/09
//  Copyright (c) 2015 Securifi. All rights reserved.
//

#import "SFIRouterSettingsTableViewController.h"
#import "SFIColors.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SFICardView.h"
#import "SFICardTableViewCell.h"
#import "SFIRouterSettingsTableViewCell.h"
#import "SFIRouterTableViewActions.h"
#import "TableHeaderView.h"
#import "UIFont+Securifi.h"
#import "Analytics.h"
#import "RouterPayload.h"
#import "UIViewController+Securifi.h"
#import "CommonMethods.h"
#import "NSData+Securifi.h"
#import "AlmondManagement.h"

#define SLAVE_OFFLINE_TAG       1
#define ENABLE_TYPE_TAG         2
#define SAME_SSIDS_PASS         3
#define COPY_PASS               4
#define ASCII_HEX_PASS_ALERT    5

@interface SFIRouterSettingsTableViewController () <SFIRouterTableViewActions, TableHeaderViewDelegate>
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic) BOOL disposed;
@property(nonatomic) BOOL isSharing;
@property(nonatomic) BOOL isEnabled;
@property(nonatomic) int keyType;
@property(nonatomic) SFIWirelessSetting *currentSetting;
@property(nonatomic) BOOL copyPass;
@end

@implementation SFIRouterSettingsTableViewController
int mii;
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont standardNavigationTitleFont]
    };
   
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    
    self.navigationItem.title = [CommonMethods getShortAlmondName:[AlmondManagement currentAlmond].almondplusName];
    
//    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
//    self.navigationItem.rightBarButtonItem = done;

    [[Analytics sharedInstance] markRouterSettingsScreen];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self initializeNotifications];
    mii = arc4random()%10000;
}

- (void)onDone {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
//    [self hideHUD];
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onAlmondRouterCommandResponse:) name:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onAlmondPropertyResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil]; //1064 response
    [center addObserver:self selector:@selector(onDynamicAlmondPropertyResponse:) name:NOTIFICATION_ALMOND_PROPERTIES_PARSED object:nil];
}

- (void)hideHUD{
    [self.HUD hide:NO];
    [self.HUD removeFromSuperview];
    _HUD = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"self.wirelessSettings.count %ld",self.wirelessSettings.count);
    return self.wirelessSettings.count; //For copy 2g settings
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 340;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SFIWirelessSetting *setting = [self tryGetWirelessSettingsForTableRow:indexPath.row];
    if([SFIWirelessSetting is5G:setting.type] && [SFIWirelessSetting supportsCopy2g:self.firmware]){
        if(setting.password)
            return 430;
        else
            return 390;
    }
    else{
        if(setting.password)
            return 380;
        else
            return 340;
    }
        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *const cell_id = @"wireless_settings";
    
    SFIRouterSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];

    if (cell == nil) {
        cell = [[SFIRouterSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    [cell markReuse];

    SFIWirelessSetting *setting = [self tryGetWirelessSettingsForTableRow:indexPath.row];

    cell.cardView.backgroundColor = [self getCellColor:setting];
    NSLog(@"setting type = %@",setting.type);
    cell.wirelessSetting = setting;
    cell.hasSlaves = self.hasSlaves;
    cell.mode = self.mode;
    cell.delegate = self;
    cell.firmware = self.firmware;
    return cell;
}

-(UIColor *)getCellColor:(SFIWirelessSetting *)setting{
    if([SFIWirelessSetting is5G:setting.type] && [SFIWirelessSetting supportsCopy2g:self.firmware]) {
        return [SecurifiToolkit sharedInstance].almondProperty.keepSameSSID.boolValue? [UIColor lightGrayColor] :[[SFIColors blueColor] color];
    }else{
        return setting.enabled ? [[SFIColors blueColor] color] : [UIColor lightGrayColor];
    }
}

- (SFIWirelessSetting *)tryGetWirelessSettingsForTableRow:(NSInteger)row {
    NSArray *settings = self.wirelessSettings;

    if (row < 0) {
        return nil;
    }
    if (row >= settings.count) {
        return nil;
    }

    return settings[(NSUInteger) row];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

#pragma mark - Cloud command senders and handlers
-(void)onAlmondPropertyResponse:(id)sender{
    NSLog(@"onAlmondPropertyResponse");
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    NSDictionary *payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    
    if(isSuccessful){
        
    }else{
        [self showToast:@"Sorry! Could not update"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.HUD hide:YES];
        });
    }
}

- (void)onDynamicAlmondPropertyResponse:(id)sender{
    NSLog(@"onDynamicAlmondPropertyResponse");
    //don't reload the dictionary will have old values
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
    
    [self showToast:@"Successfully Updated!"];
    if([SecurifiToolkit sharedInstance].almondProperty.keepSameSSID.boolValue)
        [self set2GSSIDTo5G];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)set2GSSIDTo5G{
//    BOOL isCopyEnabled = [SecurifiToolkit sharedInstance].almondProperty.keepSameSSID.boolValue;
    for(SFIWirelessSetting *setting in self.wirelessSettings){
        if([setting.type isEqualToString:@"5G"])
            setting.ssid = [self getSSID:@"2G"];
    }
}

- (NSString *)getSSID:(NSString *)type{
    for(SFIWirelessSetting *setting in self.wirelessSettings){
        if([setting.type isEqualToString:type])
            return setting.ssid;
    }
    return nil;
}

- (NSString *)getPassword:(NSString *)type{
    for(SFIWirelessSetting *setting in self.wirelessSettings){
        if([setting.type isEqualToString:type])
            return setting.password;
    }
    return nil;
}

- (void)onAlmondRouterCommandResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    SFIGenericRouterCommand *response = (SFIGenericRouterCommand *) [data valueForKey:@"data"];
    if(response.commandType != SFIGenericRouterCommandType_WIRELESS_SETTINGS)
        return;
    [self processRouterCommandResponse:response];
}

- (void)processRouterCommandResponse:(SFIGenericRouterCommand *)genericRouterCommand {
    NSLog(@"generic router command: %@", genericRouterCommand);
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self || self.disposed) {
            return;
        }
        if(self.isSharing){
            NSLog(@"genericrouter command: %@", genericRouterCommand.command);
            if(((NSArray *)genericRouterCommand.command).count == 0)//only for al3, when slave is offline
                [self showToast:@"Sorry! Please try after some time."];
            else{
                SFIWirelessSetting *newSettingObj = [(NSArray*)genericRouterCommand.command firstObject];
                NSString *password = newSettingObj.password;
                if(password.length != 0 && password != nil)
                    [self shareWiFi:self.currentSetting.ssid password:password];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.HUD hide:YES];
            });
            self.isSharing = NO;
            return;//
        }
            
        else if(genericRouterCommand.commandSuccess == NO){
            if([genericRouterCommand.responseMessage.lowercaseString isEqualToString:@"slave in offline"]){
                NSString *msg = [NSString stringWithFormat:@"Unable to change settings. Check if \"%@\" Almond(s) is/are active and with in range of other \nAlmond 3 units in your Home WiFi network.", genericRouterCommand.offlineSlaves];
                [self showAlert:@"" msg:msg cancel:@"Ok" other:nil tag:SLAVE_OFFLINE_TAG];
                [self showToast:NSLocalizedString(@"ParseRouterCommand Sorry! unable to update.", @"Sorry! unable to update.")];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.HUD hide:YES];
            });
            return;//
        }
        
        NSLog(@"genericRouterCommand.commandType %d",genericRouterCommand.commandType);
        switch (genericRouterCommand.commandType) {
            case SFIGenericRouterCommandType_WIRELESS_SETTINGS: {
                [self processSettings:genericRouterCommand.command];
                if([SecurifiToolkit sharedInstance].almondProperty.keepSameSSID.boolValue)
                    [self set2GSSIDTo5G];
                
                if(self.copyPass){
                    SFIWirelessSetting *newSettingObj = [(NSArray*)genericRouterCommand.command firstObject];
                    if([newSettingObj.type isEqualToString:@"2G"]){
                        SFIWirelessSetting *setting = [self getSetting:@"5G"];
                        setting.password = _currentSetting.password;
                    }else if([newSettingObj.type isEqualToString:@"5G"]){
                        SFIWirelessSetting *setting = [self getSetting:@"2G"];
                        setting.password = _currentSetting.password;
                    }
                    self.copyPass = NO;
                }
                
                // settings was null, reload in case they are late arriving and the view is waiting for them
                NSLog(@"processRouterCommandResponse reload");
                [self showToast:NSLocalizedString(@"successfully_updated", @"")];//
                [self.tableView reloadData];

                break;
            }
            default:
                break;
        }

        [self.HUD hide:YES];
    });
}


- (void)shareWiFi:(NSString *)ssid password:(NSString *)password{
    NSLog(@"ssid: %@, password: %@", ssid, password);
    NSString *textToShare = [NSString stringWithFormat:@"Wi-Fi: %@ \nPassword: %@", ssid, password];
    NSArray *objectsToShare = @[textToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:activityVC animated:YES completion:nil];
    });
    
}

-(void)processSettings:(NSArray*)newSetting{
    SFIWirelessSetting *newSettingObj = newSetting.firstObject;
    for(SFIWirelessSetting *setting in self.wirelessSettings){
        if([setting.type isEqualToString:newSettingObj.type]){
            switch (self.keyType) {
                case ssid_key:
                    setting.ssid = newSettingObj.ssid;
                    break;
                case enable_key:
                    setting.enabled = newSettingObj.enabled;
                    break;
                case pass_key:
                    setting.password = newSettingObj.password;
                    break;
                default:
                    break;
            }
            break;
        }
    }
    self.keyType = -1;
}

#pragma mark - SFIRouterTableViewActions protocol methods

// coordinate changes in a cell with the overall state of the control to ensure we do not crash.
// specifically, we do not want to expand/collapse a section while a text field is the first responder.
- (void)routerTableCellWillBeginEditingValue {
}

- (void)routerTableCellDidEndEditingValue {
}

- (void)onRebootRouterActionCalled {
}

- (void)onUpdateRouterFirmwareActionCalled {
}

- (void)onSendLogsActionCalled:(NSString *)problemDescription {
}

- (void)onEnableDevice:(SFIWirelessSetting *)setting enabled:(BOOL)isEnabled {
    if([self isGuestNw:setting.type] && ![self isAlmondPlus]){
        self.currentSetting = setting;
        self.isEnabled = isEnabled;
        [self showAlert:[AlmondManagement currentAlmond].almondplusName msg:@"Your Almond will reboot. Do you want to proceed?" cancel:@"No" other:@"Yes" tag:ENABLE_TYPE_TAG];
    }
    else{
        SFIWirelessSetting *copy = [setting copy];
        copy.enabled = isEnabled;
        [self onUpdateWirelessSettings:copy keyType:enable_key];
    }
}

- (BOOL)isAlmondPlus{
    return [self.firmware.lowercaseString hasPrefix:@"ap2"];
}

- (BOOL)isGuestNw:(NSString *)nwType{
    return [nwType.lowercaseString hasPrefix:@"guest"];
}


- (void)onShareBtnTapDelegate:(SFIWirelessSetting *)settings{
    NSLog(@"onShareBtnTapDelegate");
    self.isSharing = YES;
    [self onUpdateWirelessSettings:settings keyType:ssid_key];
}

- (void)onCopy2GDelegate:(BOOL)isEnabled{
    NSString *value = isEnabled? @"true": @"false";
    [self showHudWithTimeoutMsg:@"Please Wait!" time:15];
    [RouterPayload requestAlmondPropertyChange:mii action:@"KeepSameSSID" value:value uptime:nil];
}

- (void)onChangeDeviceSSID:(SFIWirelessSetting *)setting newSSID:(NSString *)ssid {
    SFIWirelessSetting *copy = [setting copy];
    copy.ssid = ssid;
    
    //special case handling
    if([SecurifiToolkit sharedInstance].almondProperty.keepSameSSID.boolValue == NO){
        if([setting.type isEqualToString:@"2G"]){
            if([self checkIF2GAnd5GSSIDsSame:@"5G" newValue:ssid] && ![self checkIF2GAnd5GPasswordsSame]){
                self.currentSetting = copy;
                [self showAlert:@"" msg:NSLocalizedString(@"alert_copy_pass", @"") cancel:@"No" other:@"Yes" tag:COPY_PASS];
                return;
            }
        }else if([setting.type isEqualToString:@"5G"]){
            if([self checkIF2GAnd5GSSIDsSame:@"2G" newValue:ssid] && ![self checkIF2GAnd5GPasswordsSame]){
                self.currentSetting = copy;
                [self showAlert:@"" msg:NSLocalizedString(@"alert_copy_pass", @"") cancel:@"No" other:@"Yes" tag:COPY_PASS];
                return;
            }
        }
    }
    //special case handling
    
    [self onUpdateWirelessSettings:copy keyType:ssid_key];
}

- (BOOL)checkIF2GAnd5GSSIDsSame:(NSString *)type newValue:(NSString *)newValue{
    return [[self getSSID:type] isEqualToString:newValue];
}

- (void)onPasswordChangeDelegate:(SFIWirelessSetting *)setting newPass:(NSString *)newPass{
    SFIWirelessSetting *copy = [setting copy];
    copy.password = newPass;
    if([SecurifiToolkit sharedInstance].almondProperty.keepSameSSID.boolValue == NO){
        
        if([self checkIF2GAnd5GPasswordsSame] && [self checkIF2GAnd5GSSIDsSame]){
            [self showAlert:@"" msg:NSLocalizedString(@"alert_same_ssids_pass", @"") cancel:@"Ok" other:nil tag:SAME_SSIDS_PASS];
            return;
        }
        
    }
    [self onUpdateWirelessSettings:copy keyType:pass_key];
}

- (BOOL)checkIF2GAnd5GPasswordsSame{
    return [[self getPassword:@"2G"] isEqualToString:[self getPassword:@"5G"]];
}

- (BOOL)checkIF2GAnd5GSSIDsSame{
    return [[self getSSID:@"2G"] isEqualToString:[self getSSID:@"5G"]];
}

- (void)onEnableWirelessAccessForDevice:(NSString *)deviceMAC allow:(BOOL)isAllowed {
}

- (void)onUpdateWirelessSettings:(SFIWirelessSetting *)copy keyType:(int)keyType{
    NSLog(@"******onUpdateWirelessSettings*******");
    self.currentSetting = copy;
    self.keyType = keyType;
    [self showHudWithTimeoutMsg:@"Please Wait!" time:15];
    
    [RouterPayload setWirelessSettings:mii wirelessSettings:copy mac:[AlmondManagement currentAlmond].almondplusMAC keyType:keyType forceUpdate:@"false"];
}

- (void)showHudWithTimeoutMsg:(NSString*)hudMsg time:(NSTimeInterval)sec{
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:sec];
    });
}

- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

#pragma mark cell delegate methods
- (void)showToastDelegate:(NSString *)msg{
    [self showToast:msg];
}

- (void)showAlertDelegate:(NSString *)msg{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlert:@"" msg:msg cancel:@"Ok" other:nil tag:ASCII_HEX_PASS_ALERT];
    });
}

#pragma mark - TableHeaderViewDelegate methods

- (void)dismissHeaderView:(TableHeaderView *)view {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [UIView animateWithDuration:0.75 animations:^() {
            self.tableView.tableHeaderView = nil;
        }];
    });
}

#pragma mark alert methods
- (void)showAlert:(NSString *)title msg:(NSString *)msg cancel:(NSString*)cncl other:(NSString *)other tag:(int)tag{
    NSLog(@"controller show alert tag: %d", tag);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cncl otherButtonTitles:other, nil];
    alert.tag = tag;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
}

#pragma mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"router settings clicked index tag: %d", alertView.tag);
    if (buttonIndex == [alertView cancelButtonIndex]){
        if(alertView.tag == ENABLE_TYPE_TAG){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        else if(alertView.tag == COPY_PASS){
            [self showAlert:@"" msg:NSLocalizedString(@"alert_choose_diff_network", @"") cancel:@"Ok" other:nil tag:-1];
        }
        else if(alertView.tag == ASCII_HEX_PASS_ALERT){
            
        }
    }
    else{
        if(alertView.tag == ENABLE_TYPE_TAG){
            SFIWirelessSetting *copy = [self.currentSetting copy];
            copy.enabled = self.isEnabled;
            [self onUpdateWirelessSettings:copy keyType:enable_key];
        }
        else if(alertView.tag == SLAVE_OFFLINE_TAG){
            
        }
        else if(alertView.tag == COPY_PASS){
            //copy 2g pass to 5g
            self.copyPass = YES;
            [self onUpdateWirelessSettings:self.currentSetting keyType:ssid_key];
        }
    }
}

- (SFIWirelessSetting *)getSetting:(NSString *)type{
    for(SFIWirelessSetting *setting in self.wirelessSettings){
        if([setting.type isEqualToString:type])
            return setting;
    }
    return nil;
}

@end
