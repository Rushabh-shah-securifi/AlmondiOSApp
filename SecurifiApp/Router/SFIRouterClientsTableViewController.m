//
//  SFIRouterClientsTableViewController.m
//  Securifi Cloud
//
//  Created by Matthew Sinclair-Day on 2015/08/12
//  Copyright (c) 2015 Securifi. All rights reserved.
//

#import "SFIRouterClientsTableViewController.h"
#import "SFIParser.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SFICardView.h"
#import "SFICardTableViewCell.h"
#import "SFIRouterTableViewActions.h"
#import "TableHeaderView.h"
#import "SFIRouterDevicesTableViewCell.h"
#import "UIColor+Securifi.h"
#import "UIFont+Securifi.h"

@interface SFIRouterClientsTableViewController () <SFIRouterTableViewActions, TableHeaderViewDelegate>
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic) BOOL disposed;

@end

@implementation SFIRouterClientsTableViewController

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
    self.navigationItem.title = self.title;

    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    self.navigationItem.rightBarButtonItem = done;

    [self initializeNotifications];
}

- (void)onDone {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        self.disposed = YES;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];

        [self.HUD hide:NO];
        [self.HUD removeFromSuperview];
        _HUD = nil;
    }
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onAlmondRouterCommandResponse:) name:kSFIDidReceiveGenericAlmondRouterResponse object:nil];
//
//    [center addObserver:self selector:@selector(onGenericResponseCallback:) name:GENERIC_COMMAND_NOTIFIER object:nil];
//    [center addObserver:self selector:@selector(onGenericNotificationCallback:) name:GENERIC_COMMAND_CLOUD_NOTIFIER object:nil];
//    [center addObserver:self selector:@selector(onAlmondRouterCommandResponse:) name:ALMOND_COMMAND_RESPONSE_NOTIFIER object:nil];
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
    return self.connectedClients.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    return 85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *const cell_id = @"device_edit";

    SFIRouterDevicesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFIRouterDevicesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }

    cell.delegate = self;
    [cell markReuse];

    SFICardView *card = cell.cardView;
    card.backgroundColor = [UIColor securifiRouterTileBlueColor];

    SFIConnectedDevice *device = [self tryGetRecord:indexPath.row];
    if (device) {
        cell.allowedDevice = YES;
        cell.deviceIP = device.deviceIP;
        cell.deviceMAC = device.deviceMAC;
        cell.name = device.name;
    }

    return cell;
}

- (SFIConnectedDevice *)tryGetRecord:(NSInteger)row {
    NSArray *clients = self.connectedClients;

    if (row < 0) {
        return nil;
    }
    if (row >= clients.count) {
        return nil;
    }

    return clients[(NSUInteger) row];
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

- (void)onGenericResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    GenericCommandResponse *response = (GenericCommandResponse *) [data valueForKey:@"data"];
    if (!response.isSuccessful) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (!self) {
                return;
            }
            if (self.disposed) {
                return;
            }

            NSString *responseAlmondMac = response.almondMAC;
            if (responseAlmondMac.length > 0 && ![responseAlmondMac isEqualToString:self.almondMac]) {
                // response almond mac value is likely to be null, but when specified we make sure it matches
                // the current almond being shown.
                return;
            }

//            self.isAlmondUnavailable = [response.reason.lowercaseString hasSuffix:@" is offline"]; // almond is offline, homescreen is offline
//            [self syncCheckRouterViewState:RouterViewReloadPolicy_on_state_change];
            [self.HUD hide:YES];
        });

        return;
    }

    SFIGenericRouterCommand *genericRouterCommand = [SFIParser parseRouterResponse:response];
    genericRouterCommand.almondMAC = response.almondMAC;

    [self processRouterCommandResponse:genericRouterCommand];
}

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
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }

        if (self.disposed) {
            return;
        }

        if (![genericRouterCommand.almondMAC isEqualToString:self.almondMac]) {
            return;
        }

        switch (genericRouterCommand.commandType) {
            case SFIGenericRouterCommandType_WIRELESS_SETTINGS: {
                SFIDevicesList *ls = genericRouterCommand.command;
                self.connectedClients = ls.deviceList;

                // settings was null, reload in case they are late arriving and the view is waiting for them
                [self.tableView reloadData];

                break;
            }
            default:
                break;
        }

        [self.HUD hide:YES];
    });
}

- (void)onGenericNotificationCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    GenericCommandResponse *obj = (GenericCommandResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {

        dispatch_async(dispatch_get_main_queue(), ^() {
            if (self.disposed) {
                return;
            }
        });

        return;
    }
    //todo push all of this parsing and manipulation into the parser or SFIGenericRouterCommand!

    NSMutableData *genericData = [[NSMutableData alloc] init];

    NSData *data_decoded = [obj.decodedData mutableCopy];

    [genericData appendData:data_decoded];

    unsigned int expectedDataLength;
    unsigned int commandData;

    [genericData getBytes:&expectedDataLength range:NSMakeRange(0, 4)];
    [genericData getBytes:&commandData range:NSMakeRange(4, 4)];

    //Remove 8 bytes from received command
    [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

    NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
    SFIGenericRouterCommand *command = [[SFIParser alloc] loadDataFromString:decodedString];

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        switch (command.commandType) {
            case SFIGenericRouterCommandType_CONNECTED_DEVICES: {
                SFIDevicesList *ls = command.command;
                self.connectedClients = ls.deviceList;

                [self.HUD hide:YES afterDelay:1];

                // settings was null, reload in case they are late arriving and the view is waiting for them
                [self.tableView reloadData];

                break;
            }

            default:
                [self.HUD hide:YES afterDelay:1];
                break;
        }
    });
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
    [self onUpdateWirelessSettings:copy];
}

- (void)onChangeDeviceSSID:(SFIWirelessSetting *)setting newSSID:(NSString *)ssid {
    SFIWirelessSetting *copy = [setting copy];
    copy.ssid = ssid;
    [self onUpdateWirelessSettings:copy];
}

- (void)onEnableWirelessAccessForDevice:(NSString *)deviceMAC allow:(BOOL)isAllowed {
}

- (void)onUpdateWirelessSettings:(SFIWirelessSetting *)copy {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        [self showUpdatingSettingsHUD];
        [[SecurifiToolkit sharedInstance] asyncUpdateAlmondWirelessSettings:self.almondMac wirelessSettings:copy];
        [self.HUD hide:YES afterDelay:2];
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

- (void)tableHeaderViewDidTapButton:(TableHeaderView *)view {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [UIView animateWithDuration:0.75 animations:^() {
            self.tableView.tableHeaderView = nil;
        }];
    });
}

@end
