//
//  SFISensorsViewController.h
//
//  Created by sinclair on 8/25/14.
//
#import "SFISensorsViewController.h"
#import "AlmondPlusConstants.h"
#import "SFIConstants.h"
#import "SNLog.h"
#import "SFIColors.h"
#import "SFICloudStatusBarButtonItem.h"
#import "iToast.h"
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import "SFISensorTableViewCell.h"

@interface SFISensorsViewController () <SFISensorTableViewCellDelegate>
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *statusBarButton;
@property(nonatomic, readonly) MBProgressHUD *HUD;

@property(nonatomic, readonly) NSString *almondMac;
@property(nonatomic, readonly) SFIColors *almondColor;
@property(nonatomic) NSArray *deviceList;
@property(nonatomic) NSArray *deviceValueList;

@property(nonatomic) NSTimer *mobileCommandTimer;
@property(nonatomic) NSTimer *sensorChangeCommandTimer;

//todo review: do not seem foolproof in face of many back-to-back commands
@property(nonatomic) BOOL isMobileCommandSuccessful;
@property(nonatomic) BOOL isSensorChangeCommandSuccessful;

@property BOOL isViewControllerDisposed;
@end

@implementation SFISensorsViewController

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
        self.isViewControllerDisposed = YES;

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
    _almondMac = mac;

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

#pragma mark - HUD mgt

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
    return [self.almondMac isEqualToString:NO_ALMOND];
}

- (BOOL)isSameAsCurrentMAC:(NSString *)aMac {
    if (aMac == nil) {
        return NO;
    }

    NSString *current = self.almondMac;
    if (current == nil) {
        return NO;
    }

    return [current isEqualToString:aMac];
}

#pragma mark - Network status

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

    return [self createSensorCell:tableView listRow:(int) indexPath.row];
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

- (UITableViewCell *)createSensorCell:(UITableView *)tableView listRow:(int)indexPathRow {
    SFIDevice *device = [self tryGetDevice:indexPathRow];
    int currentDeviceType = device.deviceType;

    NSUInteger height = [self computeSensorRowHeight:device];
    NSString *id = device.isExpanded ?
            [NSString stringWithFormat:@"SensorExpanded_%d_%ld", currentDeviceType, (unsigned long) height] :
            @"SensorSmall";

    SFISensorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell == nil) {
        cell = [[SFISensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
    }
    cell.tag = indexPathRow;
    cell.device = device;
    cell.deviceColor = self.almondColor;
    cell.delegate = self;

    unsigned int deviceId = device.deviceID;
    for (SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        if (deviceId == currentDeviceValue.deviceID) {
            cell.deviceValue = currentDeviceValue;
            break;
        }
    }

    [cell markWillReuse];
    return cell;
}

- (NSUInteger)computeSensorRowHeight:(SFIDevice *)currentSensor {
    if (!currentSensor.isExpanded) {
        return SENSOR_ROW_HEIGHT;
    }

    switch (currentSensor.deviceType) {
        case 1:
            //Switch - 2 values
            return EXPANDED_ROW_HEIGHT;

        case 2:
            //Multilevel switch - 3 values
            return 270;

        case 3:
            //Sensor - 3 values
            return 260;

        case 4:
            return 270;

        case 7:
            return 455;

        case 11:
            if (currentSensor.isTampered) {
                return EXPANDED_ROW_HEIGHT + 50;
            }
            else {
                return EXPANDED_ROW_HEIGHT;
            }
        case 12:
            if (currentSensor.isTampered) {
                return 270;
            }
            else {
                return 230;
            }

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

        case 22:
            //Multilevel switch - 5 values
            return 320;

        default:
            return EXPANDED_ROW_HEIGHT;

    }
}

#pragma mark - Add Almond actions

- (void)onAddAlmondClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"AffiliationNavigationTop"];
    [self presentViewController:mainView animated:YES completion:nil];
}

#pragma mark - SFISensorTableViewCellDelegate methods

- (void)tableViewCellDidClickDevice:(SFISensorTableViewCell *)cell {
    const NSInteger clicked_row = cell.tag;

    SFIDevice *device = [self tryGetDevice:clicked_row];
    if (device == nil) {
        return;
    }

    const int device_id = device.deviceID;

    SFIDeviceKnownValues *deviceValues;

    switch (device.deviceType) {
        case 1: {
            // Switch
            deviceValues = [self tryGetCurrentKnownValuesForDevice:device_id valuesIndex:0];
            if (!deviceValues.hasValue) {
                return; // nothing to do
            }
            [deviceValues setBoolValue:!deviceValues.boolValue];
            break;
        }

        case 2: {
            // Multilevel switch
            deviceValues = [self tryGetCurrentKnownValuesForDevice:device_id valuesIndex:device.mostImpValueIndex];

            int newValue = (deviceValues.intValue == 0) ? 99 : 0;
            [deviceValues setIntValue:newValue];
            break;
        }

        case 3: {
            if (![device isTamperMostImportantValue]) {
                return; // nothing to do
            }
            deviceValues = [self tryGetCurrentKnownValuesForDevice:device_id valuesIndex:device.mostImpValueIndex];
            [deviceValues setBoolValue:NO];
            break;
        }

        case 4:
        case 22: {
            /* Level Control */
            deviceValues = [self tryGetCurrentKnownValuesForDevice:device_id valuesIndex:device.stateIndex];
            if (!deviceValues.hasValue) {
                return; // nothing to do
            }
            [deviceValues setBoolValue:!deviceValues.boolValue];
            break;
        }
        default: {
            return; // nothing to do
        }
    }

    // Mark value state
    deviceValues.isUpdating = true;

    // Send update to the cloud
    [self sendMobileCommandForDevice:device deviceValue:deviceValues];

    // Reload the affected row
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (clicked_row >= self.deviceList.count) {
            return;
        }
        NSIndexPath *path = [NSIndexPath indexPathForRow:clicked_row inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (void)tableViewCellDidPressSettings:(SFISensorTableViewCell *)cell {
    const int clicked_row = cell.tag;

    //Get the sensor for which setting was clicked
    NSArray *devices = self.deviceList;
    if (clicked_row >= devices.count) {
        return;
    }

    // Toggle expansion
    SFIDevice *sensor = [self tryGetDevice:clicked_row];
    sensor.isExpanded = !sensor.isExpanded;

    NSMutableArray *paths = [NSMutableArray array];
    [paths addObject:[NSIndexPath indexPathForRow:clicked_row inSection:0]];

    // Ensure other rows are not expanded
    for (NSUInteger index = 0; index < devices.count; index++) {
        if (index != clicked_row) {
            SFIDevice *s = devices[index];
            if (s.isExpanded) {
                s.isExpanded = NO;
                [paths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            }
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (clicked_row >= self.deviceList.count) {
            // Just in case something gets changed out from underneath
            [self.tableView reloadData];
        }
        else {
            [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
        }
    });
}

- (void)tableViewCellDidSaveChanges:(SFISensorTableViewCell *)cell {
    if (!self) {
        return;
    }
    if ([self isNoAlmondMAC]) {
        return;
    }

    [[[iToast makeText:@"Saving..."] setGravity:iToastGravityCenter] show];

    SFIDevice *device = [self tryGetDevice:cell.tag];
    if (device == nil) {
        return;
    }

    SensorChangeRequest *cmd = [[SensorChangeRequest alloc] init];
    cmd.almondMAC = self.almondMac;
    cmd.deviceID = [NSString stringWithFormat:@"%d", device.deviceID];
    cmd.changedName = cell.deviceName;
    cmd.changedLocation = cell.deviceLocation;
    cmd.mobileInternalIndex = [NSString stringWithFormat:@"%d", (arc4random() % 10000) + 1];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = SENSOR_CHANGE_REQUEST;
    cloudCommand.command = cmd;

    [self asyncSendCommand:cloudCommand];

    //todo sinclair - push timeout into the SDK and invoke timeout action using a closure??

    self.sensorChangeCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                     target:self
                                                                   selector:@selector(onSensorChangeCommandTimeout:)
                                                                   userInfo:nil
                                                                    repeats:NO];
    self.isSensorChangeCommandSuccessful = FALSE;
}

- (void)tableViewCellDidDismissTamper:(SFISensorTableViewCell *)cell {
    if (!self) {
        return;
    }
    if ([self isNoAlmondMAC]) {
        return;
    }

    SFIDevice *device = [self tryGetDevice:cell.tag];
    if (device == nil) {
        return;
    }

    NSArray *currentKnownValues = [self tryCurrentKnownValuesForDevice:device.deviceID];

    SFIDeviceKnownValues *deviceValues = currentKnownValues[(NSUInteger) device.tamperValueIndex];
    [deviceValues setBoolValue:NO];

    [self sendMobileCommandForDevice:device deviceValue:deviceValues];
}

- (void)tableViewCellDidChangeValue:(SFISensorTableViewCell *)cell valueName:(NSString *)valueName newValue:(NSString *)newValue {
    if (self.isViewControllerDisposed) {
        return;
    }

    SFIDevice *device = cell.device;
    int currentDeviceId = device.deviceID;

    SFIDeviceKnownValues *deviceValues = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valueName:valueName];
    deviceValues.value = newValue;

    [self sendMobileCommandForDevice:device deviceValue:deviceValues];
}

#pragma mark - Class Methods

- (void)initializeDevices {
    for (SFIDevice *currentSensor in self.deviceList) {
        SFIDeviceValue *value = [self tryCurrentDeviceValues:currentSensor.deviceID];
        [currentSensor initializeFromValues:value];
    }
}

- (void)initializeColors:(SFIAlmondPlus *)almond {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];

    NSArray *colors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    NSUInteger colorCode = (NSUInteger) almond.colorCodeIndex;
    _almondColor = colors[colorCode];
}

#pragma mark - Sensor Values

- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDevice:(int)deviceId valueName:(NSString *)aValueName {
    NSArray *currentKnownValues = [self tryCurrentKnownValuesForDevice:deviceId];
    for (SFIDeviceKnownValues *value in currentKnownValues) {
        if ([value.valueName isEqualToString:aValueName]) {
            return value;
        }
    }
    return nil;
}

- (SFIDeviceKnownValues *)tryGetCurrentKnownValuesForDevice:(int)deviceId valuesIndex:(NSInteger)index {
    NSArray *values = [self tryCurrentKnownValuesForDevice:deviceId];
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

- (NSArray *)tryCurrentKnownValuesForDevice:(int)deviceId {
    SFIDeviceValue *value = [self tryCurrentDeviceValues:deviceId];
    if (value) {
        return value.knownValues;
    }
    return nil;
}

- (SFIDevice *)tryGetDevice:(NSInteger)index {
    NSUInteger uIndex = (NSUInteger) index;

    NSArray *list = self.deviceList;
    if (uIndex < list.count) {
        return list[uIndex];
    }
    return nil;
}

#pragma mark - Cloud callbacks and timeouts

- (void)onSendMobileCommandTimeout:(id)sender {
    if (self.isViewControllerDisposed) {
        return;
    }

    [self.mobileCommandTimer invalidate];

    if (!self.isMobileCommandSuccessful) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (self.isViewControllerDisposed) {
                return;
            }

            //Cancel the mobile event - Revert back
            self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.almondMac];
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
    if (self.isViewControllerDisposed) {
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

    NSString *mac = self.almondMac;

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self) {
            return;
        }
        if (self.isViewControllerDisposed) {
            return;
        }

        if ([self isNoAlmondMAC]) {
            return;
        }

        if (![self isSameAsCurrentMAC:mac]) {
            return;
        }

        if (self.isViewLoaded) {
            [self.HUD hide:YES];
        }
    });
}

- (void)onDeviceListDidChange:(id)sender {
    NSLog(@"Sensors: did receive device list change");
    if (!self) {
        return;
    }
    if (self.isViewControllerDisposed) {
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
        if (self.isViewControllerDisposed) {
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
        if (self.isViewControllerDisposed) {
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
        NSLog(@"Sensors: ignore device values list change, c:%@, m:%@", self.almondMac, cloudMAC);
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
        if (self.isViewControllerDisposed) {
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

- (void)onCurrentAlmondChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self initializeAlmondData];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        if (self.isViewControllerDisposed) {
            return;
        }

        [self.HUD show:YES];

        [self initializeAlmondData];
        [self.tableView reloadData];

        [self.HUD hide:YES afterDelay:1.5];
    });
}

- (void)onRefreshSensorData:(id)sender {
    if (!self) {
        return;
    }
    if ([self isNoAlmondMAC]) {
        return;
    }

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit asyncRequestDeviceValueList:self.almondMac];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.refreshControl endRefreshing];
    });
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
        if (self.isViewControllerDisposed) {
            return;
        }

        SFIAlmondPlus *obj = (SFIAlmondPlus *) [data valueForKey:@"data"];
        if ([self isSameAsCurrentMAC:obj.almondplusMAC]) {
            self.navigationItem.title = obj.almondplusName;
        }
    });
}

#pragma mark - Helpers

- (void)sendMobileCommandForDevice:(SFIDevice *)device deviceValue:(SFIDeviceKnownValues *)deviceValues {
    // Generate internal index between 1 to 100
    unsigned int internalIndex = (arc4random() % 100) + 1;

    MobileCommandRequest *mobileCommand = [[MobileCommandRequest alloc] init];
    mobileCommand.almondMAC = self.almondMac;
    mobileCommand.deviceID = [NSString stringWithFormat:@"%d", device.deviceID];
    mobileCommand.indexID = [NSString stringWithFormat:@"%d", deviceValues.index];
    mobileCommand.changedValue = deviceValues.value;
    mobileCommand.internalIndex = [NSString stringWithFormat:@"%d", internalIndex];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = MOBILE_COMMAND;
    cloudCommand.command = mobileCommand;

    [self asyncSendCommand:cloudCommand];

    //todo decide what to do about this
    [self.mobileCommandTimer invalidate];
    self.mobileCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                               target:self
                                                             selector:@selector(onSendMobileCommandTimeout:)
                                                             userInfo:nil
                                                              repeats:NO];
    self.isMobileCommandSuccessful = FALSE;
}

- (void)resetDeviceListFromSaved {
    NSArray *list = [SFIOfflineDataManager readDeviceList:self.almondMac];
    if (list == nil) {
        list = @[];
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.isViewControllerDisposed) {
            return;
        }
        self.deviceList = list;
        [self initializeDevices];
        [self.tableView reloadData];
        [self.HUD hide:YES];
    });
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

@end
