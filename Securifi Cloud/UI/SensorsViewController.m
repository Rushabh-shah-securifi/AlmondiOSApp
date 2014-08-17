//
//  SensorsViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "SensorsViewController.h"
#import "AlmondPlusConstants.h"
#import "SFIConstants.h"
#import "SNLog.h"
#import "SFIColors.h"
#import "SFICloudStatusBarButtonItem.h"
#import "iToast.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import "SFISensorTableViewCell.h"

@interface SensorsViewController () <UITextFieldDelegate>
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *statusBarButton;
@property(nonatomic, readonly) MBProgressHUD *HUD;

@property NSTimer *mobileCommandTimer;
@property NSTimer *sensorChangeCommandTimer;

@property BOOL isMobileCommandSuccessful;
@property BOOL isSensorChangeCommandSuccessful;

@property(nonatomic) unsigned int changeBrightness;
@property(nonatomic) unsigned int baseBrightness;
@property(nonatomic) unsigned int changeHue;
@property(nonatomic) unsigned int changeSaturation;

@property(nonatomic) NSMutableArray *listAvailableColors;
@property(nonatomic) NSInteger currentColorIndex;
@property(nonatomic) SFIColors *currentColor;

@property(nonatomic) NSString *currentMAC;
@property(nonatomic) NSArray *deviceList;
@property(nonatomic) NSArray *deviceValueList;

@property NSString *currentDeviceID;
@property unsigned int currentIndexID;
@property NSString *currentValue;
@property unsigned int currentInternalIndex;

@property BOOL isSliderExpanded;

@property(nonatomic, retain) NSString *currentChangedName;
@property(nonatomic, retain) NSString *currentChangedLocation;

@property BOOL disposed;

@end

@implementation SensorsViewController

#pragma mark - View Related

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };

    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;

    _statusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithStandard];
    self.navigationItem.rightBarButtonItem = _statusBarButton;

    SWRevealViewController *revealController = [self revealViewController];
    UIBarButtonItem *revealButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"drawer.png"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButton;

    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];

    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = @"Loading sensor data";
    _HUD.dimBackground = YES;
    [self.navigationController.view addSubview:_HUD];

    // Pull down to refresh device values
    UIRefreshControl *refresh = [UIRefreshControl new];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Force sensor data refresh" attributes:titleAttributes];
    [refresh addTarget:self action:@selector(onRefreshSensorData:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    // Ensure values have at least an empty list
    self.deviceList = @[];
    self.deviceValueList = @[];

    [self markCloudStatusIcon];
    [self initializeNotifications];
    [self initializeAlmondData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        self.disposed = YES;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];
    }
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(onNetworkDownNotifier:)
                   name:NETWORK_DOWN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkConnectingNotifier:)
                   name:NETWORK_CONNECTING_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkUpNotifier:)
                   name:NETWORK_UP_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onReachabilityDidChange:)
                   name:kSFIReachabilityChangedNotification object:nil];

    [center addObserver:self
               selector:@selector(onMobileCommandResponseCallback:)
                   name:MOBILE_COMMAND_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];

    [center addObserver:self
               selector:@selector(onDeviceListDidChange:)
                   name:kSFIDidChangeDeviceList
                 object:nil];

    [center addObserver:self
               selector:@selector(onDeviceValueListDidChange:)
                   name:kSFIDidChangeDeviceValueList
                 object:nil];

    [center addObserver:self
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
                 object:nil];

    [center addObserver:self
               selector:@selector(onAlmondNameDidChange:)
                   name:kSFIDidChangeAlmondName
                 object:nil];

    [center addObserver:self
               selector:@selector(onSensorChangeCallback:)
                   name:SENSOR_CHANGE_NOTIFIER
                 object:nil];
}

- (void)initializeAlmondData {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];

    NSString *const mac = (plus == nil) ? NO_ALMOND : plus.almondplusMAC;
    self.currentMAC = mac;

    // Reset values
    self.currentDeviceID = nil;
    self.currentIndexID = 0;
    self.currentValue = nil;
    self.currentInternalIndex = 0;
    self.isSliderExpanded = NO;
    self.currentChangedName = nil;
    self.currentChangedLocation = nil;

    if ([self isNoAlmondMAC]) {
        self.navigationItem.title = @"Get Started";
        self.deviceList = @[];
        self.deviceValueList = @[];
    }
    else {
        self.navigationItem.title = plus.almondplusName;
        self.deviceList = [toolkit deviceList:mac];
        self.deviceValueList = [toolkit deviceValuesList:mac];

        if (self.deviceList.count == 0) {
            NSLog(@"Sensors: requesting device list on empty list");
            [self showHudWithTimeout];
            [toolkit asyncRequestDeviceList:mac];
        }
        else if (self.deviceValueList.count == 0) {
            NSLog(@"Sensors: requesting device values on empty list");
            [self showHudWithTimeout];
            [toolkit tryRequestDeviceValueList:mac];
        }
        else if ([toolkit tryRequestDeviceValueList:mac]) {
            [self showHudWithTimeout];
            NSLog(@"Sensors: requesting device values on new connection");
        }

        [self initializeDevices];
        [self initializeColors:plus];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self asyncReloadTable];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%s, Did receive memory warning", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}

- (void)onCurrentAlmondChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self initializeAlmondData];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark HUD mgt

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}

#pragma mark - State

- (BOOL)isDeviceListEmpty {
    // don't show any tiles until there are values for the devices; no values == no way to fetch from almond
    return self.deviceList.count == 0 || self.deviceValueList.count == 0;
}

- (BOOL)isNoAlmondMAC {
    return [self.currentMAC isEqualToString:NO_ALMOND];
}

- (BOOL)isSameAsCurrentMAC:(NSString *)aMac {
    NSString *current = self.currentMAC;
    if (current == nil && aMac == nil) {
        return NO;
    }
    if (current == nil && aMac != nil) {
        return NO;
    }
    if (current != nil && aMac == nil) {
        return NO;
    }
    return [current isEqualToString:aMac];
}

#pragma mark - Reconnection

- (void)onNetworkUpNotifier:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markCloudStatusIcon];
        [self.tableView reloadData];
        [self.HUD hide:NO]; // make sure it is hidden
    });
}

- (void)onNetworkDownNotifier:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self markCloudStatusIcon];
        [self.tableView reloadData];
        [self.HUD hide:NO]; // make sure it is hidden
    });
}

- (void)onNetworkConnectingNotifier:(id)notification {
    [self markCloudStatusIcon];
}

- (void)onReachabilityDidChange:(NSNotification *)notification {
    [self markCloudStatusIcon];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
        [self.HUD hide:NO]; // make sure it is hidden
    });
}

- (void)markCloudStatusIcon {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    if ([toolkit isCloudConnecting]) {
        [self.statusBarButton markState:SFICloudStatusStateConnecting];
    }
    else if ([toolkit isCloudOnline]) {
        [self.statusBarButton markState:SFICloudStatusStateConnected];
    }
    else {
        [self.statusBarButton markState:SFICloudStatusStateAlmondOffline];
    }
}

#pragma mark - Table View

- (void)asyncReloadTable {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isNoAlmondMAC]) {
        return 1;
    }

    if ([self isDeviceListEmpty]) {
        return 1;
    }

    return [self.deviceList count]; //No add symbol for sensors + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC]) {
        return 400;
    }

    if ([self isDeviceListEmpty]) {
        return 400;
    }

    if (indexPath.row == [self.deviceList count]) {
        return SENSOR_ROW_HEIGHT;
    }

    SFIDevice *sensor = [self tryGetDevice:indexPath.row];
    return (CGFloat) [self computeSensorRowHeight:sensor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC]) {
        return [self createNoAlmondCell:tableView];
    }

    if ([self isDeviceListEmpty]) {
        return [self createEmptyCell:tableView];
    }

    return [self createColoredListCell:tableView listRow:(int) indexPath.row];
}

#pragma mark - Table View Cell Helpers

- (UITableViewCell *)createEmptyCell:(UITableView *)tableView {
    static NSString *empty_cell_id = @"EmptyCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:empty_cell_id];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:empty_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, self.tableView.frame.size.width, 30)];
        lblNoSensor.textAlignment = NSTextAlignmentCenter;
        [lblNoSensor setFont:[UIFont fontWithName:@"Avenir-Light" size:20]];
        lblNoSensor.text = @"You don't have any sensors yet.";
        lblNoSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblNoSensor];

        UIImageView *imgRouter = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width / 2 - 50, 95, 86, 60)];
        imgRouter.userInteractionEnabled = NO;
        [imgRouter setImage:[UIImage imageNamed:@"router_1.png"]];
        imgRouter.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:imgRouter];

        UILabel *lblAddSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, self.tableView.frame.size.width, 30)];
        lblAddSensor.textAlignment = NSTextAlignmentCenter;
        [lblAddSensor setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
        lblAddSensor.text = @"Add a sensor from your Almond.";
        lblAddSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblAddSensor];
    }

    return cell;
}

- (UITableViewCell *)createNoAlmondCell:(UITableView *)tableView {
    static NSString *no_almond_cell_id = @"NoAlmondCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:no_almond_cell_id];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:no_almond_cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 400)];
        imageView.userInteractionEnabled = YES;
        imageView.image = [UIImage imageNamed:@"getting_started.png"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = imageView.bounds;
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(onAddAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];

        [imageView addSubview:button];
        [cell addSubview:imageView];
    }

    return cell;
}

- (UITableViewCell *)createColoredListCell:(UITableView *)tableView listRow:(int)indexPathRow {
    int positionIndex = indexPathRow % 15;
    if (positionIndex < 7) {
        self.changeBrightness = self.baseBrightness - (positionIndex * 10);
    }
    else {
        self.changeBrightness = (self.baseBrightness - 70) + ((positionIndex - 7) * 10);
    }

    SFIDevice *currentSensor = [self tryGetDevice:indexPathRow];
    int currentDeviceType = currentSensor.deviceType;

    NSUInteger height = [self computeSensorRowHeight:currentSensor];
    NSString *id = currentSensor.isExpanded ?
            [NSString stringWithFormat:@"SensorExpanded_%d_%ld", currentDeviceType, (unsigned long) height] :
            @"SensorSmall";

    SFISensorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell == nil) {
        cell = [[SFISensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    }
    cell.tag = indexPathRow;
    cell.currentColor = self.currentColor;
    cell.device = currentSensor;

    unsigned int deviceId = currentSensor.deviceID;
    for (SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        if (deviceId == currentDeviceValue.deviceID) {
            cell.deviceValue = currentDeviceValue;
            break;
        }
    }

    [cell markWillReuse];
    return cell;
}

- (UIColor *)makeStandardBlue {
    return [UIColor colorWithHue:(CGFloat) (self.changeHue / 360.0) saturation:(CGFloat) (self.changeSaturation / 100.0) brightness:(CGFloat) (self.changeBrightness / 100.0) alpha:1];
}

- (NSUInteger)computeSensorRowHeight:(SFIDevice *)currentSensor {
    if (!currentSensor.isExpanded) {
        return SENSOR_ROW_HEIGHT;
    }

    switch (currentSensor.deviceType) {
        case 1:
            //Switch - 2 values
            return EXPANDED_ROW_HEIGHT;
            break;
        case 2:
            //Multilevel switch - 3 values
            return 270;
            break;
        case 3:
            //Sensor - 3 values
            return 260;
            break;
        case 4:
            return 270;
            break;
        case 7:
            return 455;
            break;
        case 11:
            if (currentSensor.isTampered) {
                return EXPANDED_ROW_HEIGHT + 50;
            }
            else {
                return EXPANDED_ROW_HEIGHT;
            }
            break;
        case 12:
            if (currentSensor.isTampered) {
                return 270;
            }
            else {
                return 230;
            }
            break;
        case 13:
        case 14:
        case 15:
        case 17:
        case 19:
            if (currentSensor.isTampered) {
                return EXPANDED_ROW_HEIGHT + 50;
            }
            else {
                return EXPANDED_ROW_HEIGHT;
            }
            break;
        case 22:
            //Multilevel switch - 5 values
            return 320;
            break;
        default:
            return EXPANDED_ROW_HEIGHT;
            break;
    }
}

#pragma mark - BVReorderTableViewDelegate methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.deviceList];
//        [self.deviceList removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// This method is called when starting the re-ording process. You insert a blank row object into your
// data source and return the object you want to save for later. This method is only called once.
- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = (NSUInteger) indexPath.row;
    return [self tryGetDevice:row];
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSUInteger row = (NSUInteger) fromIndexPath.row;

    id object = [self tryGetDevice:row];;

    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.deviceList];
    [temp removeObjectAtIndex:row];
    [temp insertObject:object atIndex:(NSUInteger) toIndexPath.row];

    self.deviceList = [NSArray arrayWithArray:temp];
}


#pragma mark - Class Methods

- (void)initializeDevices {
    for (SFIDevice *currentSensor in self.deviceList) {
        SFIDeviceValue *value = [self tryCurrentDeviceValues:currentSensor.deviceID];
        [currentSensor initializeFromValues:value];
    }
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(onSettingClicked:)) {
        return YES;
    }
    if (action == @selector(onDeviceClicked:)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(onSettingClicked:)) {
        UIButton *button = (UIButton *) sender;
        NSUInteger clicked_row = (NSUInteger) button.tag;
        [self onSettingClickedForIndex:clicked_row];
    }
    else if (action == @selector(onDeviceClicked:)) {
        UIButton *button = (UIButton *) sender;
        NSUInteger clicked_row = (NSUInteger) button.tag;
        [self onDeviceClickedForIndex:clicked_row];
    }
    else {
        [super tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
    }
}

- (void)onSettingClicked:(id)sender {
    UIButton *btn = (UIButton *) sender;
    NSUInteger clicked_row = (NSUInteger) btn.tag;
    [self onSettingClickedForIndex:clicked_row];
}

- (void)onSettingClickedForIndex:(NSUInteger)clicked_row {
    //Get the sensor for which setting was clicked
    NSArray *devices = self.deviceList;
    if (clicked_row >= devices.count) {
        return;
    }

    SFIDevice *sensor = devices[clicked_row];

    if (!sensor.isExpanded) {
        //Expand it
        //Remove the long press for reordering when expanded sensor has slider
        //Device type 2 - 4 - 7
        switch (sensor.deviceType) {
            case 2:
            case 4:
            case 7:
                self.isSliderExpanded = TRUE;
                break;

            default:
                break;
        }

        sensor.isExpanded = TRUE;
    }
    else {
        //Enable the long press for reordering
        //Device type 2 - 4 - 7
        switch (sensor.deviceType) {
            case 2:
            case 4:
            case 7:
                self.isSliderExpanded = FALSE;
                break;

            default:
                break;
        }
        sensor.isExpanded = FALSE;
    }

    NSMutableArray *pathes = [NSMutableArray array];
    [pathes addObject:[NSIndexPath indexPathForRow:clicked_row inSection:0]];

    // Ensure other rows are not expanded
    for (NSUInteger index = 0; index < devices.count; index++) {
        if (index != clicked_row) {
            SFIDevice *s = devices[index];
            if (s.isExpanded) {
                s.isExpanded = NO;
                [pathes addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            }
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        // forget uncommitted edits
        self.currentChangedName = nil;
        self.currentChangedLocation = nil;

        if (clicked_row >= self.deviceList.count) {
            // Just in case something gets changed out from underneath
            [self.tableView reloadData];
        }
        else {
            [self.tableView reloadRowsAtIndexPaths:pathes withRowAnimation:UITableViewRowAnimationFade];
        }
    });
}

- (void)onAddAlmondClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"AffiliationNavigationTop"];
    [self presentViewController:mainView animated:YES completion:nil];
}

- (void)onDismissTamper:(id)sender {
    UIButton *button = (UIButton *) sender;

    SFIDevice *sensor = [self tryGetDevice:button.tag];
    if (sensor == nil) {
        return;
    }

    NSArray *currentKnownValues = [self currentKnownValuesForDevice:sensor.deviceID];

    SFIDeviceKnownValues *currentDeviceValue = currentKnownValues[(NSUInteger) sensor.tamperValueIndex];
    currentDeviceValue.value = @"false";

    self.currentDeviceID = [NSString stringWithFormat:@"%d", sensor.deviceID];
    self.currentIndexID = currentDeviceValue.index;
    self.currentValue = currentDeviceValue.value;

    [self sendMobileCommand];
}

- (void)onDeviceClicked:(id)sender {
    UIButton *btn = (UIButton *) sender;
    NSUInteger clicked_row = (NSUInteger) btn.tag;
    [self onDeviceClickedForIndex:clicked_row];
}

- (void)onDeviceClickedForIndex:(NSUInteger)clicked_row {
    SFIDevice *currentSensor = [self tryGetDevice:clicked_row];
    if (currentSensor == nil) {
        return;
    }

    int currentDeviceType = currentSensor.deviceType;
    int currentDeviceId = currentSensor.deviceID;

    NSMutableArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];

    SFIDeviceKnownValues *currentDeviceValue;
    NSString *currentValue;
    NSString *mostImpIndexName;

    switch (currentDeviceType) {
        case 1:
            //Switch
            //Only one value
            currentDeviceValue = currentKnownValues[0];
            currentValue = currentDeviceValue.value;
            currentDeviceValue.isUpdating = true;
            if ([currentValue isEqualToString:@"true"]) {
                // DLog(@"Change to OFF");
                currentDeviceValue.value = @"false";
                //currentSensor.imageName = @"switch_off.png";
                //imgDevice.image = [UIImage imageNamed:@"bulb_on.png"];
                self.currentValue = @"false";
            }
            else if ([currentValue isEqualToString:@"false"]) {
                // DLog(@"Change to ON");
                currentDeviceValue.value = @"true";
                //currentSensor.imageName = @"switch_on.png";
                //imgDevice.frame = CGRectMake(35, 25, 27,42);
                //imgDevice.image = [UIImage imageNamed:@"bulb_off.png"];
                self.currentValue = @"true";
            }
            else {
                return;
            }
            //currentDeviceValue.value = @"Updating sensor data.\nPlease wait.";

            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = 1;

            [self sendMobileCommand];

            [self asyncReloadTable];
            break;
        case 2:
            //Multilevel switch
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.mostImpValueIndex];
            currentValue = currentDeviceValue.value;
            //Do not wait for response from Cloud
            currentDeviceValue.isUpdating = true;
            if ([currentValue isEqualToString:@"0"]) {
                // DLog(@"Change to ON - Set value as 99");
                currentDeviceValue.value = @"99";
                self.currentValue = @"99";
            }
            else {
                // DLog(@"Change to OFF - Set value as 0");
                currentDeviceValue.value = @"0";
                self.currentValue = @"0";
            }
//            }else if([currentValue isEqualToString:@"false"]){
//                // DLog(@"Change to ON");
//                currentDeviceValue.value = @"true";
//                self.currentValue = @"true";
//            }
//            else{
//                return;
//            }

            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            // DLog(@"Index ID %d", self.currentIndexID);
            [self sendMobileCommand];
            [self.tableView reloadData];
            break;
        case 3:
            //Sensor
            mostImpIndexName = currentSensor.mostImpValueName;
            if ([mostImpIndexName isEqualToString:TAMPER]) {
                currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.mostImpValueIndex];
                //Do not wait for response from Cloud
                currentDeviceValue.value = @"false";
                //currentDeviceValue.value = @"Updating sensor data. Please wait.";
                self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
                self.currentIndexID = currentDeviceValue.index;
                self.currentValue = currentDeviceValue.value;
                [self sendMobileCommand];
                [self initializeDevices];
                // [[self view] endEditing:YES];
                [self asyncReloadTable];
            }
            //imgDevice.frame = CGRectMake(25, 20, 40.5,60);
            //imgDevice.image = [UIImage imageNamed:@"door_on.png"];
            break;
        case 4:
            //Level Control
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
            currentValue = currentDeviceValue.value;
            //Do not wait for response from Cloud
            currentDeviceValue.isUpdating = true;
            if ([currentValue isEqualToString:@"true"]) {
                // DLog(@"Change to OFF");
                currentDeviceValue.value = @"false";
                self.currentValue = @"false";
            }
            else if ([currentValue isEqualToString:@"false"]) {
                // DLog(@"Change to ON");
                currentDeviceValue.value = @"true";
                self.currentValue = @"true";
            }
            else {
                return;
            }

            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            // DLog(@"Index ID %d", self.currentIndexID);
            [self sendMobileCommand];
            [self asyncReloadTable];
            break;

        case 22:
            //Sensor
            //            mostImpIndexName = currentSensor.mostImpValueName;
            //            if([mostImpIndexName isEqualToString:TAMPER]){
            currentDeviceValue = currentKnownValues[(NSUInteger) currentSensor.stateIndex];
            currentValue = currentDeviceValue.value;
            //Do not wait for response from Cloud
            currentDeviceValue.isUpdating = true;
            if ([currentValue isEqualToString:@"true"]) {
                // DLog(@"Change to OFF");
                currentDeviceValue.value = @"false";
                self.currentValue = @"false";
            }
            else if ([currentValue isEqualToString:@"false"]) {
                // DLog(@"Change to ON");
                currentDeviceValue.value = @"true";
                self.currentValue = @"true";
            }
            else {
                return;
            }

            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            // DLog(@"Index ID %d", self.currentIndexID);
            [self sendMobileCommand];
            // [[self view] endEditing:YES];
            [self asyncReloadTable];

            //            }
            //imgDevice.frame = CGRectMake(25, 20, 40.5,60);
            //imgDevice.image = [UIImage imageNamed:@"door_on.png"];
            break;
        default:
            //imgDevice.frame = CGRectMake(25, 20, 50,50);
            //imgDevice.image = [UIImage imageNamed:@"dimmer.png"];
            //imgDevice.frame = CGRectMake(25, 12.5, 53,60);
            //imgDevice.image = [UIImage imageNamed:@"door_tamper.png"];
            break;
    }


}

- (void)initializeColors:(SFIAlmondPlus *)plus {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];

    self.listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    int colorCode = plus.colorCodeIndex;
    if (colorCode != 0) {
        self.currentColor = self.listAvailableColors[(NSUInteger) colorCode];
    }
    else {
        self.currentColor = self.listAvailableColors[(NSUInteger) self.currentColorIndex];
    }

    self.baseBrightness = (unsigned int) self.currentColor.brightness;
    self.changeHue = (unsigned int) self.currentColor.hue;
    self.changeSaturation = (unsigned int) self.currentColor.saturation;
}

#pragma mark - Sensor Values

- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDevice:(int)deviceId valueName:(NSString *)aValueName {
    NSArray *currentKnownValues = [self currentKnownValuesForDevice:deviceId];
    for (SFIDeviceKnownValues *value in currentKnownValues) {
        if ([value.valueName isEqualToString:aValueName]) {
            return value;
        }
    }
    return nil;
}

- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDevice:(int)deviceId valuesIndex:(NSInteger)index {
    NSArray *values = [self currentKnownValuesForDevice:deviceId];
    if (index < values.count) {
        return values[(NSUInteger) index];
    }
    return nil;
}

- (SFIDeviceValue *)tryCurrentDeviceValues:(int)deviceId {
    for (SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        if (deviceId == currentDeviceValue.deviceID) {
            return currentDeviceValue;
        }
    }
    return nil;
}

- (NSMutableArray *)currentKnownValuesForDevice:(int)deviceId {
    SFIDeviceValue *value = [self tryCurrentDeviceValues:deviceId];
    if (value) {
        return value.knownValues;
    }
    return nil;
}

#pragma mark - Sliding controls

- (void)sliderTapped:(UIGestureRecognizer *)gestureRecognizer {
    [self onSensorSliderTap:gestureRecognizer valueName:@"SWITCH MULTILEVEL"];
}

- (IBAction)sliderDidEndSliding:(id)sender {
    [self onSensorSliderDidEndSliding:sender valueName:@"SWITCH MULTILEVEL"];
}

- (void)coolingSliderTapped:(UIGestureRecognizer *)gestureRecognizer {
    [self onSensorSliderTap:gestureRecognizer valueName:@"THERMOSTAT SETPOINT COOLING"];
}

- (IBAction)coolingSliderDidEndSliding:(id)sender {
    [self onSensorSliderDidEndSliding:sender valueName:@"THERMOSTAT SETPOINT COOLING"];
}

- (void)heatingSliderTapped:(UIGestureRecognizer *)gestureRecognizer {
    [self onSensorSliderTap:gestureRecognizer valueName:@"THERMOSTAT SETPOINT HEATING"];
}

- (IBAction)heatingSliderDidEndSliding:(id)sender {
    [self onSensorSliderDidEndSliding:sender valueName:@"THERMOSTAT SETPOINT HEATING"];
}

- (void)onSensorSliderTap:(UIGestureRecognizer *)gestureRecognizer valueName:(NSString *)valueName {
    if (self.disposed) {
        return;
    }

    UISlider *slider = (UISlider *) gestureRecognizer.view;
    if (slider.highlighted) {
        return;
    } // tap on thumb, let slider deal with it

    CGPoint pt = [gestureRecognizer locationInView:slider];
    CGFloat percentage = pt.x / slider.bounds.size.width;
    CGFloat delta = percentage * (slider.maximumValue - slider.minimumValue);
    CGFloat value = slider.minimumValue + delta;
    [slider setValue:value animated:YES];

    SFIDevice *currentSensor = [self tryGetDevice:slider.tag];
    if (currentSensor == nil) {
        return;
    }
    int currentDeviceId = currentSensor.deviceID;

    // Update values
    SFIDeviceKnownValues *deviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valueName:valueName];
    deviceValue.value = [NSString stringWithFormat:@"%d", (int) value];

    // Keep track of them
    self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
    self.currentIndexID = deviceValue.index;
    self.currentValue = deviceValue.value;

    // Send them back to the cloud
    [self sendMobileCommand];

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }
        [self initializeDevices];
        [self.tableView reloadData];
    });
}

- (void)onSensorSliderDidEndSliding:(id)sender valueName:(NSString *)valueName {
    if (self.disposed) {
        return;
    }

    UISlider *slider = (UISlider *) sender;
    SFIDevice *currentSensor = [self tryGetDevice:slider.tag];
    if (currentSensor == nil) {
        return;
    }

    int currentDeviceId = currentSensor.deviceID;

    SFIDeviceKnownValues *deviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valueName:valueName];
    deviceValue.value = [NSString stringWithFormat:@"%d", (int) (slider.value)]; //Do not wait for response from Cloud

    self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
    self.currentIndexID = deviceValue.index;
    self.currentValue = deviceValue.value;

    [self sendMobileCommand];

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }
        [self initializeDevices];
        [self.tableView reloadData];
    });
}

#pragma mark - Segment Control Method

- (void)modeSelected:(id)sender {
    [self onUpdateSegmentedControlValue:sender valueName:@"THERMOSTAT MODE"];
}

- (void)fanModeSelected:(id)sender {
    [self onUpdateSegmentedControlValue:sender valueName:@"THERMOSTAT FAN MODE"];
}

- (void)onUpdateSegmentedControlValue:(id)sender valueName:(NSString *)valueName {
    if (self.disposed) {
        return;
    }

    UISegmentedControl *ctrl = (UISegmentedControl *) sender;
    NSString *strModeValue = [ctrl titleForSegmentAtIndex:(NSUInteger) ctrl.selectedSegmentIndex];

    NSInteger index = ctrl.tag;
    SFIDevice *currentSensor = [self tryGetDevice:index];
    int currentDeviceId = currentSensor.deviceID;

    SFIDeviceKnownValues *deviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valueName:valueName];
    deviceValue.value = strModeValue;

    self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
    self.currentIndexID = deviceValue.index;
    self.currentValue = deviceValue.value;
    [self sendMobileCommand];

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }
        [self initializeDevices];
        [self.tableView reloadData];
    });

}

- (SFIDevice *)tryGetDevice:(NSInteger)index {
    NSUInteger uIndex = (NSUInteger) index;

    NSArray *list = self.deviceList;
    if (uIndex < list.count) {
        return list[uIndex];
    }
    return nil;
}

#pragma mark - Keyboard methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[[self view] endEditing:YES];
    // DLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

- (void)sensorNameTextFieldDidChange:(UITextField *)tfName {
    DLog(@"tfName for device: %ld Value: %@", (long) tfName.tag, tfName.text);
    self.currentChangedName = tfName.text;
}

- (void)sensorLocationTextFieldDidChange:(UITextField *)tfLocation {
    DLog(@"tfLocation for device: %ld Value: %@", (long) tfLocation.tag, tfLocation.text);
    self.currentChangedLocation = tfLocation.text;
}

- (void)sensorNameTextFieldFinished:(UITextField *)tfName {
    DLog(@"tfName for device: %ld Value: %@", (long) tfName.tag, tfName.text);
    self.currentChangedName = tfName.text;
    [tfName resignFirstResponder];
}

- (void)sensorLocationTextFieldFinished:(UITextField *)tfLocation {
    DLog(@"tfLocation for device: %ld Value: %@", (long) tfLocation.tag, tfLocation.text);
    self.currentChangedLocation = tfLocation.text;
    [tfLocation resignFirstResponder];
}

#pragma mark - Cloud Commands and Handlers

- (void)sendDeviceValueCommand {
    [[SecurifiToolkit sharedInstance] asyncRequestDeviceValueList:self.currentMAC];
}

- (void)sendMobileCommand {
    DLog(@"%s: sendMobileCommand", __PRETTY_FUNCTION__);

    //Generate internal index between 1 to 100
    self.currentInternalIndex = (arc4random() % 100) + 1;

    MobileCommandRequest *mobileCommand = [[MobileCommandRequest alloc] init];
    mobileCommand.almondMAC = self.currentMAC;
    mobileCommand.deviceID = self.currentDeviceID;
    mobileCommand.indexID = [NSString stringWithFormat:@"%d", self.currentIndexID];
    mobileCommand.changedValue = self.currentValue;
    mobileCommand.internalIndex = [NSString stringWithFormat:@"%d", self.currentInternalIndex];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = MOBILE_COMMAND;
    cloudCommand.command = mobileCommand;

    [self asyncSendCommand:cloudCommand];

    //todo decide what to do about this
    //PY 311013 - Timeout for Mobile Command
    [self.mobileCommandTimer invalidate];
    self.mobileCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                               target:self
                                                             selector:@selector(onSendMobileCommandTimeout:)
                                                             userInfo:nil
                                                              repeats:NO];
    self.isMobileCommandSuccessful = FALSE;
}

//PY 311013 - Timeout for Mobile Command
- (void)onSendMobileCommandTimeout:(id)sender {
    if (self.disposed) {
        return;
    }

    [self.mobileCommandTimer invalidate];

    if (!self.isMobileCommandSuccessful) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (self.disposed) {
                return;
            }

            //Cancel the mobile event - Revert back
            self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
            [self initializeDevices];
            [self.tableView reloadData];
            [self.HUD hide:YES];
        });
    }
}

- (void)onMobileCommandResponseCallback:(id)sender {
    if (!self) {
        return;
    }
    if (self.disposed) {
        return;
    }

    // Timeout the commander timer
    [self.mobileCommandTimer invalidate];
    self.isMobileCommandSuccessful = TRUE;

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    int deviceValueID = (int) [self.currentDeviceID integerValue];
    NSString *mac = self.currentMAC;

    NSArray *currentDeviceValues = [self currentKnownValuesForDevice:deviceValueID];
    NSArray *storedValues = [SFIOfflineDataManager readDeviceValueList:mac];

    if (storedValues == nil) {
        storedValues = @[];
    }
    else {
        MobileCommandResponse *obj = (MobileCommandResponse *) [data valueForKey:@"data"];
        BOOL isSuccessful = obj.isSuccessful;

        for (SFIDeviceValue *storedValue in storedValues) {
            if (storedValue.deviceID == deviceValueID) {
                NSMutableArray *storedKnownDeviceValues = storedValue.knownValues;

                for (SFIDeviceKnownValues *storedKnownValues in storedKnownDeviceValues) {
                    for (SFIDeviceKnownValues *currentKnownValues in currentDeviceValues) {
                        if (storedKnownValues.index == currentKnownValues.index) {
                            storedKnownValues.value = isSuccessful ? currentKnownValues.value : nil;
                            storedKnownValues.isUpdating = false;
                            break;
                        }
                    }
                }

                storedValue.knownValues = storedKnownDeviceValues;
            }
        }

        [[SecurifiToolkit sharedInstance] writeDeviceValueList:storedValues currentMAC:mac];
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        if (self.disposed) {
            return;
        }

        if ([self isNoAlmondMAC]) {
            return;
        }

        if (![self isSameAsCurrentMAC:mac]) {
            return;
        }

        if (self.isViewLoaded) {
            self.deviceValueList = storedValues;
            [self initializeDevices];
            [self.tableView reloadData];
            [self.HUD hide:YES];
        }
    });
}

- (void)onDeviceListDidChange:(id)sender {
    NSLog(@"Sensors: did receive device list change");
    if (!self) {
        return;
    }
    if (self.disposed) {
        return;
    }

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NSString *cloudMAC = [data valueForKey:@"data"];
    if (![self isSameAsCurrentMAC:cloudMAC]) {
        // An Almond not currently being views was changed
        return;
    }

    NSArray *newDeviceList = [SFIOfflineDataManager readDeviceList:cloudMAC];
    if (newDeviceList == nil) {
        newDeviceList = @[];
    }

    NSArray *newDeviceValueList = [SFIOfflineDataManager readDeviceValueList:cloudMAC];
//    if ([newDeviceList count] < [self.deviceValueList count]) {
//        // Reload Device Value List which was updated by Offline Data Manager
//        newDeviceValueList = [SFIOfflineDataManager readDeviceValueList:cloudMAC];
//    }

    // Restore isExpanded state
    NSArray *oldDeviceList = self.deviceList;
    for (SFIDevice *newDevice in newDeviceList) {
        for (SFIDevice *oldDevice in oldDeviceList) {
            if (newDevice.deviceID == oldDevice.deviceID) {
                newDevice.isExpanded = oldDevice.isExpanded;
            }
        }
    }

    // Push changes to the UI
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }
        if ([self isSameAsCurrentMAC:cloudMAC]) {
            self.deviceList = newDeviceList;
            if (newDeviceValueList) {
                self.deviceValueList = newDeviceValueList;
            }
            [self initializeDevices];
            [self.tableView reloadData];
        }

        [self.HUD hide:YES afterDelay:1.5];
    });
}

- (void)onDeviceValueListDidChange:(id)sender {
    NSLog(@"Sensors: did receive device values list change");

    if (!self) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        if (self.disposed) {
            return;
        }
        [self.HUD hide:YES];
    });

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    NSString *cloudMAC = [data valueForKey:@"data"];
    if (![self isSameAsCurrentMAC:cloudMAC]) {
        NSLog(@"Sensors: ignore device values list change, c:%@, m:%@", self.currentMAC, cloudMAC);
        // An Almond not currently being views was changed
        return;
    }

    NSArray *newDeviceList = [SFIOfflineDataManager readDeviceList:cloudMAC];
    if (newDeviceList == nil) {
        NSLog(@"Device list is empty: %@", cloudMAC);
        newDeviceList = @[];
    }

    NSArray *newDeviceValueList = [SFIOfflineDataManager readDeviceValueList:cloudMAC];
    if (newDeviceValueList == nil) {
        newDeviceValueList = @[];
    }

    if (newDeviceList.count != newDeviceValueList.count) {
        NSLog(@"Warning: device list and values lists are incongruent, d:%ld, v:%ld", newDeviceList.count, newDeviceValueList.count);
    }

    DLog(@"Changing device value list: %@", newDeviceValueList);

    // Restore isExpanded state
    NSArray *oldDeviceList = self.deviceList;
    for (SFIDevice *newDevice in newDeviceList) {
        for (SFIDevice *oldDevice in oldDeviceList) {
            if (newDevice.deviceID == oldDevice.deviceID) {
                newDevice.isExpanded = oldDevice.isExpanded;
            }
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        if (self.disposed) {
            return;
        }

        if (![self isSameAsCurrentMAC:cloudMAC]) {
            return;
        }

        [self.refreshControl endRefreshing];

        self.deviceList = newDeviceList;
        self.deviceValueList = newDeviceValueList;
        [self initializeDevices];
        [self.tableView reloadData];
    });
}

- (void)onAlmondListDidChange:(id)sender {
    NSLog(@"Sensors: did receive ALmond List change");

    if (!self) {
        return;
    }

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    SFIAlmondPlus *plus = [data valueForKey:@"data"];

    if (plus != nil && [self isSameAsCurrentMAC:plus.almondplusMAC]) {
        // No reason to alert user
        return;
    }

    // If plus is nil, then there are no almonds attached, and the UI needs to deal with it.

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        if (!self.isViewLoaded) {
            return;
        }
        if (self.disposed) {
            return;
        }

        [self.HUD show:YES];

        [self initializeAlmondData];
        [self.tableView reloadData];

        [self.HUD hide:YES afterDelay:1.5];
    });
}

- (IBAction)onRefreshSensorData:(id)sender {
    if (!self) {
        return;
    }
    if ([self isNoAlmondMAC]) {
        return;
    }

//    SensorForcedUpdateRequest *cmd = [[SensorForcedUpdateRequest alloc] init];
//    cmd.almondMAC = self.currentMAC;
//
//    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
//    cloudCommand.commandType = DEVICE_DATA_FORCED_UPDATE_REQUEST;
//    cloudCommand.command = cmd;
//
//    [self asyncSendCommand:cloudCommand];


    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit asyncRequestDeviceValueList:self.currentMAC];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.refreshControl endRefreshing];
    });
}

- (void)onSaveSensorData:(id)sender {
    if (!self) {
        return;
    }
    if ([self isNoAlmondMAC]) {
        return;
    }

    [[[iToast makeText:@"Saving..."] setGravity:iToastGravityCenter] show];

    UIButton *button = (UIButton *) sender;
    SFIDevice *currentSensor = [self tryGetDevice:button.tag];
    if (currentSensor == nil) {
        return;
    }

    SensorChangeRequest *sensorChangeCommand = [[SensorChangeRequest alloc] init];
    sensorChangeCommand.almondMAC = self.currentMAC;
    sensorChangeCommand.deviceID = [NSString stringWithFormat:@"%d", currentSensor.deviceID];
    if (self.currentChangedName == nil && self.currentChangedLocation == nil) {
        return;
    }
    if (self.currentChangedName != nil) {
        DLog(@"Name changed!");
        sensorChangeCommand.changedName = self.currentChangedName;
        currentSensor.deviceName = self.currentChangedName;
    }
    if (self.currentChangedLocation != nil) {
        DLog(@"Location changed!");
        sensorChangeCommand.changedLocation = self.currentChangedLocation;
        currentSensor.location = self.currentChangedLocation;
    }
    sensorChangeCommand.mobileInternalIndex = [NSString stringWithFormat:@"%d", (arc4random() % 10000) + 1];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = SENSOR_CHANGE_REQUEST;
    cloudCommand.command = sensorChangeCommand;

    [self asyncSendCommand:cloudCommand];

    //todo sinclair - push timeout into the SDK and invoke timeout action using a closure??

    //PY 230114 - Timeout for Sensor Change Command
    self.sensorChangeCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                     target:self
                                                                   selector:@selector(onSensorChangeCommandTimeout:)
                                                                   userInfo:nil
                                                                    repeats:NO];
    self.isSensorChangeCommandSuccessful = FALSE;

    self.currentChangedName = nil;
    self.currentChangedLocation = nil;
}

- (void)onSensorChangeCommandTimeout:(id)sender {
    [self.sensorChangeCommandTimer invalidate];

    if (!self.isSensorChangeCommandSuccessful) {
        [self resetDeviceListFromSaved];
    }
}

- (void)onSensorChangeCallback:(id)sender {
    if (!self) {
        return;
    }

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    self.isSensorChangeCommandSuccessful = TRUE;
    [SNLog Log:@"%s: Received SensorChangeCallback", __PRETTY_FUNCTION__];

    SensorChangeResponse *obj = (SensorChangeResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {
        [SNLog Log:@"%s: Could not update data, Revert to old value", __PRETTY_FUNCTION__];
        [self resetDeviceListFromSaved];
    }
}

- (void)onAlmondNameDidChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        if (self.disposed) {
            return;
        }

        SFIAlmondPlus *obj = (SFIAlmondPlus *) [data valueForKey:@"data"];
        if ([self isSameAsCurrentMAC:obj.almondplusMAC]) {
            self.navigationItem.title = obj.almondplusName;
        }
    });
}

- (void)resetDeviceListFromSaved {
    NSArray *list = [SFIOfflineDataManager readDeviceList:self.currentMAC];
    if (list == nil) {
        list = @[];
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }
        self.deviceList = list;
        [self initializeDevices];
        //To remove text fields keyboard. It was throwing error when it was being called from the background thread
        [self.tableView reloadData];
        [self.HUD hide:YES];
    });
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

@end
