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

@interface SFIRouterSettingsTableViewController () <SFIRouterTableViewActions, TableHeaderViewDelegate>
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic) BOOL disposed;
@property(nonatomic) BOOL isSharing;
@property(nonatomic) SFIWirelessSetting *currentSetting;
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
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    
    self.navigationItem.title = [CommonMethods getShortAlmondName:toolkit.currentAlmond.almondplusName];
    
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
    [self hideHUD];
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onAlmondRouterCommandResponse:) name:NOTIFICATION_ROUTER_RESPONSE_CONTROLLER_NOTIFIER object:nil];
    
//    [center addObserver:self selector:@selector(onGenericNotificationCallback:) name:GENERIC_COMMAND_CLOUD_NOTIFIER object:nil];
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
    return self.wirelessSettings.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 300;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    return 300;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *const cell_id = @"wireless_settings";
    
    SFIRouterSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];

    if (cell == nil) {
        cell = [[SFIRouterSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    [cell markReuse];

    SFIWirelessSetting *setting = [self tryGetWirelessSettingsForTableRow:indexPath.row];

    cell.cardView.backgroundColor = setting.enabled ? [[SFIColors blueColor] color] : [UIColor lightGrayColor];
    cell.wirelessSetting = setting;
    cell.enableRouterWirelessControl = self.enableRouterWirelessControl;
    cell.isREMode = self.isREMode;
    cell.delegate = self;

    return cell;
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
- (void)onAlmondRouterCommandResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    SFIGenericRouterCommand *response = (SFIGenericRouterCommand *) [data valueForKey:@"data"];
    [self processRouterCommandResponse:response];
}

- (void)processRouterCommandResponse:(SFIGenericRouterCommand *)genericRouterCommand {
    NSLog(@"generic router command: %@", genericRouterCommand);
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self || self.disposed) {
            return;
        }
        if(self.isSharing){
           [self shareWiFi:self.currentSetting.ssid password:[self getPassword:genericRouterCommand]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.HUD hide:YES];
            });
            self.isSharing = NO;
            return;//
        }
        else if(genericRouterCommand.commandSuccess == NO){
            if([genericRouterCommand.responseMessage.lowercaseString isEqualToString:@"slave in offline"]){
                [self showAlert:@"" msg:@"Unable to change settings in one of the Almond.\nWould you like to continue?" cancel:@"No" other:@"Yes" tag:1];
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

- (NSString *)getPassword:(SFIGenericRouterCommand *)genericCmd{
    NSString *encryptedPass = @"";
    for(SFIWirelessSetting *setting in genericCmd.command){
        if([setting.type isEqualToString:self.currentSetting.type]){
            encryptedPass = setting.password;
        }
    }
    
    NSData *payload = [[NSData alloc] initWithBase64EncodedString:encryptedPass options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [payload securifiDecryptPasswordForAlmond:[SecurifiToolkit sharedInstance].currentAlmond.almondplusMAC almondUptime:genericCmd.uptime];
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
            setting.type = newSettingObj.type;
            setting.ssid = newSettingObj.ssid;
            setting.enabled = newSettingObj.enabled;
            setting.password = newSettingObj.password;
            break;
        }
    }
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
    SFIWirelessSetting *copy = [setting copy];
    copy.enabled = isEnabled;
    [self onUpdateWirelessSettings:copy isTypeEnable:YES];
}

- (void)onShareBtnTapDelegate:(SFIWirelessSetting *)settings{
    NSLog(@"onShareBtnTapDelegate");
    self.isSharing = YES;
    [self onUpdateWirelessSettings:settings isTypeEnable:NO];
}

- (void)onChangeDeviceSSID:(SFIWirelessSetting *)setting newSSID:(NSString *)ssid {
    SFIWirelessSetting *copy = [setting copy];
    copy.ssid = ssid;
    [self onUpdateWirelessSettings:copy isTypeEnable:NO];
}

- (void)onEnableWirelessAccessForDevice:(NSString *)deviceMAC allow:(BOOL)isAllowed {
}

- (void)onUpdateWirelessSettings:(SFIWirelessSetting *)copy isTypeEnable:(BOOL)isTypeEnable{
    NSLog(@"******onUpdateWirelessSettings*******");
    self.currentSetting = copy;
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }
        [self showUpdatingSettingsHUD];
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        [RouterPayload setWirelessSettings:mii wirelessSettings:copy mac:toolkit.currentAlmond.almondplusMAC isTypeEnable:isTypeEnable forceUpdate:@"false"];
        [self.HUD hide:YES afterDelay:15];
    });
}

- (void)showUpdatingSettingsHUD {
    [self showHUD:NSLocalizedString(@"hud.Updating settings...", @"Updating settings...")];
}

- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
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
    NSLog(@"router settings clicked index");
    if (buttonIndex == [alertView cancelButtonIndex]){
        
    }else{
        [self showUpdatingSettingsHUD];
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        [RouterPayload setWirelessSettings:mii wirelessSettings:self.currentSetting mac:toolkit.currentAlmond.almondplusMAC isTypeEnable:NO forceUpdate:@"true"];
        [self.HUD hide:YES afterDelay:15];
    }
}

@end
