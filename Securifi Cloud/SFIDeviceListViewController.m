//
//  SFIDeviceListViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIDeviceListViewController.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "AlmondPlusConstants.h"
#import "SFIDeviceDetailViewController.h"
#import "SFIOfflineDataManager.h"
#import "SNLog.h"

@implementation SFIDeviceListViewController
@synthesize deviceList;
@synthesize currentMAC;
@synthesize deviceValueList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    SNFileLogger *logger = [[SNFileLogger alloc] init];
//    [[SNLog logManager] addLogStrategy:logger];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.currentMAC = [prefs objectForKey:CURRENT_ALMOND_MAC];
    self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
    self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
    self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(DeviceDataCloudResponseCallback:)
                                                 name:DEVICE_DATA_CLOUD_NOTIFIER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(HashResponseCallback:)
                                                 name:HASH_NOTIFIER
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DEVICE_DATA_CLOUD_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HASH_NOTIFIER
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Command Handlers

- (void)DeviceDataCloudResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *) [notifier userInfo];

    if (data != nil) {
        DeviceListResponse *obj = [[DeviceListResponse alloc] init];
        obj = (DeviceListResponse *) [data valueForKey:@"data"];
        BOOL isCurrentMAC = FALSE;
        NSString *cloudMAC = obj.almondMAC;
        [SNLog Log:@"Method Name: %s Current MAC ==> @%@ Cloud MAC ==> @%@", __PRETTY_FUNCTION__, currentMAC, cloudMAC];
        if ([cloudMAC isEqualToString:self.currentMAC]) {
            self.deviceList = obj.deviceList;
            isCurrentMAC = TRUE;
        }

        [self getDeviceHash];

        //Run in background
//        dispatch_queue_t queue = dispatch_queue_create("com.securifi.almondplus", NULL);
//        dispatch_async(queue, ^{
//            [self getDeviceHash];
//        });

        //Update UI
        if (isCurrentMAC) {
            [self.tableView reloadData];
        }

    }
}

- (void)getDeviceHash {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];

    DeviceDataHashRequest *deviceHashCommand = [[DeviceDataHashRequest alloc] init];
    deviceHashCommand.almondMAC = self.currentMAC;

    cloudCommand.commandType = DEVICEDATA_HASH;
    cloudCommand.command = deviceHashCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- DeviceHash Command", __PRETTY_FUNCTION__];


        NSError *error = nil;
        id ret = [[SecurifiToolkit sharedInstance] sendtoCloud:cloudCommand error:&error];

        if (ret == nil) {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__, [error localizedDescription]];
        }

        [SNLog Log:@"Method Name: %s After Writing to socket -- DeviceHash Command", __PRETTY_FUNCTION__];
    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__, exception.reason];
    }

    cloudCommand = nil;
    deviceHashCommand = nil;

}


- (void)HashResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *) [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %sReceived HASH", __PRETTY_FUNCTION__];
        NSString *currentHash;

        DeviceDataHashResponse *obj = [[DeviceDataHashResponse alloc] init];
        obj = (DeviceDataHashResponse *) [data valueForKey:@"data"];

        if (obj.isSuccessful) {
            //Hash Update
            currentHash = obj.almondHash;
            [SNLog Log:@"Method Name: %s Current Hash ==> @%@ ", __PRETTY_FUNCTION__, currentHash];
            if (![currentHash isEqualToString:@""] && currentHash != nil) {
                [SFIOfflineDataManager writeHashList:currentHash currentMAC:self.currentMAC];
            }
            else {
                NSString *reason = obj.reason;
                [SNLog Log:@"Method Name: %s Reason ==> @%@ ", __PRETTY_FUNCTION__, reason];
                //TODO: Display reason to user
            }

        }

    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    //Empty List
    if (self.deviceList == nil) {
        return 185;
    }
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    //Empty list
    if (self.deviceList == nil) {
        return 1;
    }
    return [self.deviceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    if (self.deviceList == nil) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 5;
        cell.textLabel.textColor = [UIColor brownColor];
        cell.textLabel.text = @"You currently have no devices associate with your almond. Please associate some devices from Almond.";
        //whatever else to configure your one cell you're going to return
        return cell;
    }


    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    SFIDevice *currentDevice = [self.deviceList objectAtIndex:indexPath.row];
    cell.textLabel.text = currentDevice.deviceName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Device Type: %d", currentDevice.deviceType];//[@(currentDevice.deviceType) stringValue];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Get latest value from offline storage
    self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
    self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
    SFIDevice *currentDevice = [self.deviceList objectAtIndex:indexPath.row];
    int currentDeviceId = currentDevice.deviceID;
    int deviceValueID;
    //Pass current device info in map
    [SNLog Log:@"Method Name: %s Selected Device ID is @%d", __PRETTY_FUNCTION__, currentDeviceId];
    for (
            SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        deviceValueID = currentDeviceValue.deviceID;
        if (currentDeviceId == deviceValueID) {
            [SNLog Log:@"Method Name: %s ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__, deviceValueID];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            SFIDeviceDetailViewController *deviceDetailView = (SFIDeviceDetailViewController *) [storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceDetailViewController"];
            //TODO: Remove later - when stored in file
            // SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*)mainView;
            deviceDetailView.deviceValue = currentDeviceValue;
            deviceDetailView.currentDeviceType = currentDevice.deviceType;
            deviceDetailView.currentDeviceName = currentDevice.deviceName;
            [self.navigationController pushViewController:deviceDetailView animated:YES];
            break;
        }

    }

}


@end
