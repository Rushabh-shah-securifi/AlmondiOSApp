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
#import "MBProgressHUD.h"
#import "SFISensorTableViewCell.h"
#import "SFISensorDetailView.h"
#import "UIFont+Securifi.h"
#import "UIViewController+Securifi.h"

@interface SFISensorsViewController () <SFISensorTableViewCellDelegate>
@property(nonatomic, readonly) SFIAlmondPlus *almond;
@property(nonatomic, readonly) NSString *almondMac;
@property(nonatomic, readonly) SFIColors *almondColor;

@property(nonatomic, readonly) NSArray *deviceList;
@property(nonatomic, readonly) NSDictionary *deviceIndexTable; // device ID :: table cell row
@property(nonatomic, readonly) NSDictionary *deviceValueTable;

// tracks requests sent to update a device; cleared on receipt of the 
// devices whose cells are "expanded" to show settings
@property(nonatomic, readonly) NSSet *expandedDeviceIds;

// devices which are in the state of being updated have special status
// messages shown. devices whose updating failed also have special messages.
// these structures track those devices.
@property(nonatomic, readonly) NSDictionary *updatingDevices;           // 1. sfi_id :: SFIDevice 2. SFIDevice :: sfi_id
@property(nonatomic, readonly) NSDictionary *deviceStatusMessages;      // SFIDevice :: NSString status message
@property(nonatomic, readonly) NSObject *deviceStatusMessages_locker;   // sync locker for mutating the dictionary

// Table view cells can call back to the controller to store state information that later can be retrieved to restore
// the cell. This is useful when a cell is told to reload itself; a picker view might want to scroll to a certain position.
// This dictionary stores those values. Key is device ID, value is a dictionary.
@property(nonatomic, readonly) NSDictionary *deviceCellStateValues;
@property(nonatomic, readonly) NSObject *deviceCellStateValues_locker;   // sync locker for mutating the dictionary

// when YES, we defer showing sensor updates; basically, prevents first responder from being relinquished while editing
@property BOOL isUpdatingDeviceSettings;

@property(nonatomic) NSTimer *mobileCommandTimer;
@property(nonatomic) NSTimer *sensorChangeCommandTimer;

@property(nonatomic) BOOL isSensorChangeCommandSuccessful;

@property BOOL isViewControllerDisposed;
@property BOOL isAccountActivatedNotification;
@end

@implementation SFISensorsViewController

#pragma mark - View Related

- (void)viewDidLoad {
    [super viewDidLoad];

    _deviceStatusMessages_locker = [NSObject new];
    [self clearAllDeviceUpdatingState];

    _deviceCellStateValues_locker = [NSObject new];
    [self clearAllDeviceCellStateValues];

    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Pull down to refresh device values
    UIRefreshControl *refresh = [UIRefreshControl new];
    NSDictionary *attributes = self.navigationController.navigationBar.titleTextAttributes;
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Force sensor data refresh" attributes:attributes];
    [refresh addTarget:self action:@selector(onRefreshSensorData:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    // Ensure values have at least an empty list
    self.deviceList = @[];
    [self setDeviceValues:@[]];

    [self initializeNotifications];
    [self initializeAlmondData];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.isAccountActivatedNotification = [defaults boolForKey:ACCOUNT_ACTIVATION_NOTIFICATION];
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
    
    [center addObserver:self
            selector:@selector(validateResponseCallback:)
            name:VALIDATE_RESPONSE_NOTIFIER
            object:nil];
    
    [center addObserver:self
            selector:@selector(onNotificationPrefDidChange:)
            name:kSFIDidChangeNotificationList
            object:nil];
    
    [center addObserver:self
               selector:@selector(onNotificationPrefResponse:)
                   name:NOTIFICATION_PREFERENCE_CHANGE_RESPONSE_NOTIFIER
                 object:nil];
}

- (void)initializeAlmondData {
    // 2014-11-08 sinclair added due to late reports from QA noticing keyboard can be still up over layed over sensors.
    // I think this is caused by bug in new Accounts code that has been fixed, but am adding this anyway
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

    [self clearAllDeviceUpdatingState];
    [self clearAllDeviceCellStateValues];

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    SFIAlmondPlus *plus = [toolkit currentAlmond];
    _almond = plus;

    NSString *const mac = (plus == nil) ? NO_ALMOND : plus.almondplusMAC;
    _almondMac = mac;

    self.isUpdatingDeviceSettings = NO;

    if ([self isNoAlmondMAC]) {
        self.navigationItem.title = @"Get Started";
        self.deviceList = @[];
        [self setDeviceValues:@[]];
    }
    else {
        self.navigationItem.title = plus.almondplusName;
        self.deviceList = [toolkit deviceList:mac];
        [self setDeviceValues:[toolkit deviceValuesList:mac]];

        if (self.deviceList.count == 0) {
            NSLog(@"Sensors: requesting device list on empty list");
            [self showHudWithTimeout];
            [toolkit asyncRequestDeviceList:mac];
        }
        else if (self.deviceValueTable.count == 0) {
            NSLog(@"Sensors: requesting device values on empty list");
            [self showHudWithTimeout];
            [toolkit tryRequestDeviceValueList:mac];
        }
        else if ([toolkit tryRequestDeviceValueList:mac]) {
            [self showHudWithTimeout];
            NSLog(@"Sensors: requesting device values on new connection");
        }

        [toolkit asyncRequestNotificationPreferenceList:mac];
        [self initializeColors:plus];
    }

    self.enableDrawer = YES;
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

#pragma mark - HUD and Toast mgt

- (void)showHudWithTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:5];
    });
}

#pragma mark - State

- (BOOL)isDeviceListEmpty {
    // don't show any tiles until there are values for the devices; no values == no way to fetch from almond
    return self.deviceList.count == 0 || self.deviceValueTable.count == 0;
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

#pragma mark - Expanded Cell State

- (BOOL)isExpandedCell:(SFIDevice*)device {
    return [self.expandedDeviceIds containsObject:@(device.deviceID)];
}

- (void)markExpandedCell:(SFIDevice*)device  {
    _expandedDeviceIds = [NSSet setWithObject:@(device.deviceID)];
}

- (void)clearExpandedCell {
    _expandedDeviceIds = [NSSet set];
}

- (BOOL)hasExpandedCell {
    return [self.expandedDeviceIds count] > 0;
}

- (void)removeExpandedCellForMissingDevices:(NSArray*)devices {
    if (![self hasExpandedCell]) {
        return;
    }

    NSMutableSet *new_ids = [NSMutableSet set];
    for (SFIDevice *device in devices) {
        [new_ids addObject:@(device.deviceID)];
    }

    [new_ids intersectSet:self.expandedDeviceIds];
    _expandedDeviceIds = [NSSet setWithSet:new_ids];
}

-(NSArray*)expandedDevices {
    return [self.expandedDeviceIds allObjects];
}

#pragma mark - Table View

- (void)asyncReloadTable {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.tableView reloadData];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    BOOL isAccountActivated = [[SecurifiToolkit sharedInstance] isAccountActivated];
    if(!isAccountActivated && self.isAccountActivatedNotification){
        return  85;
    }
    return 0;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //TODO: Check if activated or not
    BOOL isAccountActivated = [[SecurifiToolkit sharedInstance] isAccountActivated];
    if(!isAccountActivated && self.isAccountActivatedNotification){
        return [self createActivationNotificationHeader];
    }
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

    SFIDevice *device = [self tryGetDevice:indexPath.row];
    SFIDeviceValue *deviceValue = [self tryCurrentDeviceValues:device.deviceID];
    return (CGFloat) [self computeSensorRowHeight:device deviceValue:deviceValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondMAC]) {
        return [self createNoAlmondCell:tableView];
    }

    if ([self isDeviceListEmpty]) {
        return [self createEmptyCell:tableView];
    }

    return [self createSensorCell:tableView listRow:(NSUInteger) indexPath.row];
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
        [lblNoSensor setFont:[UIFont securifiLightFont:20]];
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
        [lblAddSensor setFont:[UIFont standardUILabelFont]];
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

- (UITableViewCell *)createSensorCell:(UITableView *)tableView listRow:(NSUInteger)indexPathRow {
    SFIDevice *device = [self tryGetDevice:indexPathRow];
    SFIDeviceValue *deviceValue = [self tryCurrentDeviceValues:device.deviceID];

    SFIDeviceType currentDeviceType = device.deviceType;
    NSUInteger height = [self computeSensorRowHeight:device deviceValue:deviceValue];
    BOOL expanded = [self isExpandedCell:device];
    
    NSString *cell_id = [NSString stringWithFormat:@"s_t:%d_h:%ld_e:%d,", currentDeviceType, (unsigned long) height, expanded];

    //todo fix me: this attribute should be removed or managed in the toolkit
    //PY 201114- Set device almond mac
    device.almondMAC = self.almondMac;

    SFISensorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[SFISensorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
    }
    cell.tag = indexPathRow;
    cell.device = device;
    cell.cellColor = [self.almondColor makeGradatedColorForPositionIndex:indexPathRow];
    cell.delegate = self;
    cell.expandedView = expanded;

    cell.deviceValue = deviceValue;

    NSString *status = [self tryDeviceStatusMessage:device];
    if (status) {
        [cell markStatusMessage:status];
        [cell markWillReuseCell:YES];
    }
    else {
        [cell markWillReuseCell:NO];
    }

    return cell;
}

- (NSUInteger)computeSensorRowHeight:(SFIDevice *)currentSensor deviceValue:(SFIDeviceValue*)deviceValue {
    BOOL expanded = [self isExpandedCell:currentSensor];
    BOOL tampered = [currentSensor isTampered:deviceValue];
    return [SFISensorDetailView computeSensorRowHeight:currentSensor tamperedDevice:tampered expandedCell:expanded];
}

- (UIView *)createActivationNotificationHeader{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(5, 0, self.tableView.frame.size.width, 100)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, self.tableView.frame.size.width-35, 1)];
    imgLine1.image = [UIImage imageNamed:@"grey_line.png"];

    
    UIImageView *imgCross = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-20, 12, 10, 10)];
    imgCross.image = [UIImage imageNamed:@"cross_icon.png"];

    [view addSubview:imgCross];
    
    UIButton *btnCloseNotification = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCloseNotification.frame =  CGRectMake(self.tableView.frame.size.width-40, 12, 50, 30);
    btnCloseNotification.backgroundColor = [UIColor clearColor];
    [btnCloseNotification addTarget:self action:@selector(onCloseNotificationClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnCloseNotification];
    
    UILabel *lblConfirm = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.tableView.frame.size.width-15, 20)];
    lblConfirm.font = [UIFont securifiBoldFont:13];
    lblConfirm.textColor = [UIColor colorWithRed:(CGFloat) (119 / 255.0) green:(CGFloat) (119 / 255.0) blue:(CGFloat) (119 / 255.0) alpha:1.0];
    lblConfirm.textAlignment = NSTextAlignmentCenter;
    int minsRemainingForUnactivatedAccount = [[SecurifiToolkit sharedInstance] minsRemainingForUnactivatedAccount];
    
    if(minsRemainingForUnactivatedAccount <= 1440){
        lblConfirm.text = @"Please confirm your account (less than a day left).";
    }else{
        int daysRemaining = minsRemainingForUnactivatedAccount/1440;
        lblConfirm.text =  [NSString stringWithFormat:@"Please confirm your account (%d days left).",daysRemaining];
    }
    
    UILabel *lblInstructions = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, self.tableView.frame.size.width-20, 20)];
    lblInstructions.font = [UIFont securifiBoldFont:13];
    lblInstructions.textColor = [UIColor colorWithRed:(CGFloat) (119 / 255.0) green:(CGFloat) (119 / 255.0) blue:(CGFloat) (119 / 255.0) alpha:1.0];
    lblInstructions.textAlignment = NSTextAlignmentCenter;
    lblInstructions.text = @"Check activation email for instructions.";
    
    
    UIImageView *imgMail = [[UIImageView alloc] initWithFrame:CGRectMake(80, 65, 22, 16)];
    imgMail.image = [UIImage imageNamed:@"Mail_icon.png"];
    [view addSubview:imgMail];
    
    UIButton *btnResendActivationMail = [UIButton buttonWithType:UIButtonTypeCustom];
    btnResendActivationMail.frame =  CGRectMake(50, 45, self.tableView.frame.size.width-90, 40);
    btnResendActivationMail.backgroundColor = [UIColor clearColor];
    [btnResendActivationMail addTarget:self action:@selector(onResendActivationClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnResendActivationMail];
    
    UILabel *lblResend = [[UILabel alloc] initWithFrame:CGRectMake(32, 65, self.tableView.frame.size.width-20, 20)];
    lblResend.font = [UIFont securifiBoldFont:13];
    lblResend.textColor = [UIColor colorWithRed:(CGFloat) (0 / 255.0) green:(CGFloat) (173 / 255.0) blue:(CGFloat) (226 / 255.0) alpha:1.0];
    lblResend.textAlignment = NSTextAlignmentCenter;
    lblResend.text = @"Resend activation email";
    
    UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 85, self.tableView.frame.size.width-35, 1)];
    imgLine2.image = [UIImage imageNamed:@"grey_line.png"];
    
    [view  addSubview:imgLine1];
    [view addSubview:lblConfirm];
    [view addSubview:lblInstructions];
    [view addSubview:lblResend];
    [view  addSubview:imgLine2];
    
    return view;
}

- (void)reloadDeviceTableCellForDevice:(SFIDevice *)device {
    NSUInteger cellRow = (NSUInteger) [self deviceCellRow:device.deviceID];
    NSIndexPath *path = [NSIndexPath indexPathForRow:cellRow inSection:0];

    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Add Almond actions

- (void)onAddAlmondClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"AffiliationNavigationTop"];
    [self presentViewController:mainView animated:YES completion:nil];
}

#pragma mark - SFISensorTableViewCellDelegate methods

- (void)tableViewCellDidClickDevice:(SFISensorTableViewCell *)cell {
    if (self.isViewControllerDisposed) {
        return;
    }

    SFIDevice *device = cell.device;
    if (![device isBinaryStateSwitchable]) {
        return;
    }

    SFIDeviceValue *value = [self tryCurrentDeviceValues:device.deviceID];

    SFIDeviceKnownValues *deviceValues = [device switchBinaryState:value];
    if (!deviceValues) {
        return;
    }

    // Send update to the cloud
    [self sendMobileCommandForDevice:device deviceValue:deviceValues deviceCell:cell];
}

- (void)tableViewCellDidPressSettings:(SFISensorTableViewCell *)cell {
    if (self.isViewControllerDisposed) {
        return;
    }

    SFIDevice *sensor = cell.device;
    const int clicked_row = (int) [self deviceCellRow:sensor.deviceID];

    // Toggle expansion
    NSMutableArray *paths = [NSMutableArray array];
    [paths addObject:[NSIndexPath indexPathForRow:clicked_row inSection:0]];

    for (NSNumber *deviceId in self.expandedDevices) {
        int device_id = [deviceId intValue];
        if (device_id != sensor.deviceID) {
            const int row = (int) [self deviceCellRow:device_id];
            [paths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
        }
    }

    BOOL expanded = [self isExpandedCell:sensor];
    if (expanded) {
        [self clearExpandedCell];
    }
    else {
        [self markExpandedCell:sensor];
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

- (void)tableViewCellWillStartMakingChanges:(SFISensorTableViewCell *)cell {
    if (self.isViewControllerDisposed) {
        return;
    }

    self.isUpdatingDeviceSettings = YES;
    self.enableDrawer = NO;
}

- (void)tableViewCellWillCancelMakingChanges:(SFISensorTableViewCell *)cell {
    if (self.isViewControllerDisposed) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^() {
        self.isUpdatingDeviceSettings = NO;
        self.enableDrawer = YES;
        [self.tableView reloadData];
    });
}

- (void)tableViewCellDidSaveChanges:(SFISensorTableViewCell *)cell {
    if (self.isViewControllerDisposed) {
        return;
    }

    [self showToast:@"Saving..."];
    
    SFIDevice *device = cell.device;

    SensorChangeRequest *cmd = [[SensorChangeRequest alloc] init];
    cmd.almondMAC = self.almondMac;
    cmd.deviceID = [NSString stringWithFormat:@"%d", device.deviceID];
    cmd.changedName = cell.deviceName;
    cmd.changedLocation = cell.deviceLocation;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_MOBILE_COMMAND;
    cloudCommand.command = cmd;

    [self asyncSendCommand:cloudCommand];

    //todo sinclair - push timeout into the SDK and invoke timeout action using a closure??

    self.sensorChangeCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                     target:self
                                                                   selector:@selector(onSensorChangeCommandTimeout:)
                                                                   userInfo:nil
                                                                    repeats:NO];

    self.isSensorChangeCommandSuccessful = FALSE;
    self.isUpdatingDeviceSettings = NO;
    self.enableDrawer = YES;
}

- (void)tableViewCellDidDismissTamper:(SFISensorTableViewCell *)cell {
    if (self.isViewControllerDisposed) {
        return;
    }

    SFIDevice *device = cell.device;

    SFIDeviceKnownValues *deviceValues  = [cell.deviceValue knownValuesForProperty:SFIDevicePropertyType_TAMPER];
    [deviceValues setBoolValue:NO];

    [self sendMobileCommandForDevice:device deviceValue:deviceValues deviceCell:cell];
}

- (void)tableViewCellDidChangeValue:(SFISensorTableViewCell *)cell propertyType:(SFIDevicePropertyType)propertyType newValue:(NSString *)newValue {
    if (self.isViewControllerDisposed) {
        return;
    }

    SFIDevice *device = cell.device;

    SFIDeviceKnownValues *deviceValues  = [cell.deviceValue knownValuesForProperty:propertyType];
    deviceValues.value = newValue;

    // provisionally update; on mobile cmd response, the actual new values will be set
    cell.deviceValue = [cell.deviceValue setKnownValues:deviceValues forProperty:propertyType];

    [self sendMobileCommandForDevice:device deviceValue:deviceValues deviceCell:cell];
}

- (void)tableViewCellDidChangeValue:(SFISensorTableViewCell *)cell propertyName:(NSString *)propertyName newValue:(NSString *)newValue {
    if (self.isViewControllerDisposed) {
        return;
    }

    SFIDevice *device = cell.device;

    SFIDeviceKnownValues *deviceValues  = [cell.deviceValue knownValuesForPropertyName:propertyName];
    deviceValues.value = newValue;

    // provisionally update; on mobile cmd response, the actual new values will be set
    cell.deviceValue = [cell.deviceValue setKnownValues:deviceValues forPropertyName:propertyName];

    [self sendMobileCommandForDevice:device deviceValue:deviceValues deviceCell:cell];
}

- (void)tableViewCellDidDidFailValidation:(SFISensorTableViewCell *)cell validationToast:(NSString *)toastMsg {
    [self showToast:toastMsg];
}

- (void)tableViewCell:(SFISensorTableViewCell *)cell setValue:(id)value forKey:(NSString *)key {
    [self setDeviceCellValue:value forKey:key forDevice:cell.device];
}

- (id)tableViewCell:(SFISensorTableViewCell *)cell valueForKey:(NSString *)key {
    return [self getDeviceCellValueForKey:key forDevice:cell.device];
}

- (void)tableViewCellDidChangeNotificationSetting:(SFISensorTableViewCell*)cell notificationSettingValue:(BOOL)value{
    //Send command to set notification
    if (self.isViewControllerDisposed) {
        return;
    }
    
    SFIDevice *device = cell.device;
    NSArray *deviceValuesList  = [cell.deviceValue knownDevicesValues];
    
    //Create list of indexes for device values for that particular device
    //Notification will be sent for all the devices known values
    NSMutableArray *notificationPrefDeviceList = [[NSMutableArray alloc]init];
    for (SFIDeviceKnownValues *currentDeviceValue in deviceValuesList){
        SFINotificationDevice *notificationDevice = [[SFINotificationDevice alloc]init];
        notificationDevice.deviceID = device.deviceID;
        notificationDevice.valueIndex = currentDeviceValue.index;
        [notificationPrefDeviceList addObject:notificationDevice];
    }
    
    NSString *action = value?@"add":@"delete";
    
    [[SecurifiToolkit sharedInstance] asyncRequestNotificationPreferenceChange:self.almondMac deviceList:notificationPrefDeviceList forAction:action];
}

#pragma mark - Class Methods

- (void)initializeColors:(SFIAlmondPlus *)almond {
    NSUInteger colorCode = (NSUInteger) almond.colorCodeIndex;
    _almondColor = [SFIColors colorForIndex:colorCode];
}

#pragma mark - Sensor Values

- (SFIDeviceValue *)tryCurrentDeviceValues:(int)deviceId {
    return self.deviceValueTable[@(deviceId)];
}

- (SFIDevice *)tryGetDevice:(NSInteger)index {
    NSUInteger uIndex = (NSUInteger) index;

    NSArray *list = self.deviceList;
    if (uIndex < list.count) {
        return list[uIndex];
    }
    return nil;
}

// calls should be coordinated on the main queue
- (void)setDeviceList:(NSArray *)devices {
    NSMutableDictionary *table = [NSMutableDictionary dictionary];

    int row = 0;
    for (SFIDevice *device in devices) {
        NSNumber *key = @(device.deviceID);
        table[key] = @(row);
        row++;
    }

    _deviceList = devices;
    _deviceIndexTable = [NSDictionary dictionaryWithDictionary:table];
}

- (NSInteger)deviceCellRow:(int)deviceId {
    NSNumber *key = @(deviceId);
    NSNumber *row = self.deviceIndexTable[key];
    return [row integerValue];
}

// calls should be coordinated on the main queue
- (void)setDeviceValues:(NSArray *)values {
    NSMutableDictionary *table = [NSMutableDictionary dictionary];
    for (SFIDeviceValue *value in values) {
        NSNumber *key = @(value.deviceID);
        table[key] = value;
    }
    _deviceValueTable = [NSDictionary dictionaryWithDictionary:table];
}

#pragma mark - Cloud callbacks and timeouts

- (void)onSendMobileCommandTimeout:(id)sender {
    if (self.isViewControllerDisposed) {
        return;
    }

    [self.mobileCommandTimer invalidate];

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.isViewControllerDisposed) {
            return;
        }

        //Cancel the mobile event - Revert back
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        [self setDeviceValues:[toolkit deviceValuesList:self.almondMac]];
        [self.tableView reloadData];
        [self.HUD hide:YES];

        [self clearAllDeviceUpdatingState];
    });
}

- (void)onMobileCommandResponseCallback:(id)sender {
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

        if (self.isViewLoaded) {
            [self.HUD hide:YES];
        }

        // Timeout the commander timer
        [self.mobileCommandTimer invalidate];

        NSNotification *notifier = (NSNotification *) sender;
        NSDictionary *data = [notifier userInfo];
        if (data == nil) {
            return;
        }

        MobileCommandResponse *res = data[@"data"];
        sfi_id c_id = res.mobileInternalIndex;

        SFIDevice *device = [self tryDeviceForCorrelationId:c_id];
        if (!device) {
            // give up: c_id is no longer valid
            return;
        }

        if (res.isSuccessful) {
            // command succeeded; clear "status" state; new device values should be transmitted
            // via different callback and handled there.
            [self clearDeviceUpdatingState:device];
        }
        else {
            NSString *status = res.reason;
            if (status.length > 0) {
                [self markDeviceUpdatingState:device correlationId:c_id statusMessage:status];
                [self showToast:status];
            }
            else {
                // it failed but we did not receive a reason; clear the updating state and pretend nothing happened.
                [self clearDeviceUpdatingState:device];
                [self showToast:@"Unable to update sensor"];
            }

            [self reloadDeviceTableCellForDevice:device];
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

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    NSArray *newDeviceList = [toolkit deviceList:cloudMAC];
    if (newDeviceList == nil) {
        newDeviceList = @[];
    }
    [self removeExpandedCellForMissingDevices:newDeviceList];

    NSArray *newDeviceValueList = [toolkit deviceValuesList:cloudMAC];

    // Restore isExpanded state and clear 'updating' state
    NSArray *oldDeviceList = self.deviceList;
    for (SFIDevice *newDevice in newDeviceList) {
        for (SFIDevice *oldDevice in oldDeviceList) {
            if (newDevice.deviceID == oldDevice.deviceID) {
                [self clearDeviceUpdatingState:oldDevice];
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
                [self setDeviceValues:newDeviceValueList];
            }
            [self.tableView reloadData];
        }

        [self.HUD hide:YES afterDelay:1.5];
    });
}

- (void)onDeviceValueListDidChange:(id)sender {
    DLog(@"Sensors: did receive device values list change");

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
        DLog(@"Sensors: ignore device values list change, c:%@, m:%@", self.almondMac, cloudMAC);
        // An Almond not currently being viewed was changed
        return;
    }

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    NSArray *newDeviceList = [toolkit deviceList:cloudMAC];
    if (newDeviceList == nil) {
        DLog(@"Device list is empty: %@", cloudMAC);
        newDeviceList = @[];
        [self clearAllDeviceUpdatingState];
    }
    [self removeExpandedCellForMissingDevices:newDeviceList];

    NSArray *newDeviceValueList = [toolkit deviceValuesList:cloudMAC];
    if (newDeviceValueList == nil) {
        newDeviceValueList = @[];
    }

    if (newDeviceList.count != newDeviceValueList.count) {
        ELog(@"Warning: device list and values lists are incongruent, d:%ld, v:%ld", (unsigned long)newDeviceList.count, (unsigned long)newDeviceValueList.count);
    }

    DLog(@"Changing device value list: %@", newDeviceValueList);

    // Restore isExpanded state and clear 'updating' state
    NSArray *oldDeviceList = self.deviceList;
    for (SFIDevice *newDevice in newDeviceList) {
        for (SFIDevice *oldDevice in oldDeviceList) {
            if (newDevice.deviceID == oldDevice.deviceID) {
                [self clearDeviceUpdatingState:oldDevice];
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

        [self setDeviceList:newDeviceList];
        [self setDeviceValues:newDeviceValueList];

        // defer showing changes when a sensor is being edited (name, location, etc.)
        if (!self.isUpdatingDeviceSettings) {
            [self.tableView reloadData];
        }
    });
}

- (void)onCurrentAlmondChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self clearExpandedCell];
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

    [self clearAllDeviceUpdatingState];

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    [toolkit asyncRequestDeviceValueList:self.almondMac];
    [toolkit asyncRequestNotificationPreferenceList:self.almondMac];

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
    DLog(@"%s: Received SensorChangeCallback", __PRETTY_FUNCTION__);

    SensorChangeResponse *obj = (SensorChangeResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {
        NSLog(@"%s: Could not update data, Revert to old value", __PRETTY_FUNCTION__);
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


- (void)onNotificationPrefDidChange:(id)sender {
    DLog(@"Sensors: did receive notification preference list change");
    
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
        DLog(@"Sensors: ignore notification preference list change, c:%@, m:%@", self.almondMac, cloudMAC);
        // An Almond not currently being viewed was changed
        return;
    }
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    
    NSArray *newNotificationList = [toolkit notificationPrefList:cloudMAC];
    if (newNotificationList == nil) {
        DLog(@"Notification Preference list is empty: %@", cloudMAC);
        newNotificationList = @[];
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
        [self.tableView reloadData];
        
    });
}

//PY 271114 - Notification on/off
- (void)onNotificationPrefResponse:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    NotificationPreferenceResponse *obj = (NotificationPreferenceResponse *) [data valueForKey:@"data"];
    
    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    DLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);
    
    if (!obj.isSuccessful) {
        NSLog(@"Reason Code %d", obj.reasonCode);
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (self.isViewControllerDisposed) {
                return;
            }
            [self.tableView reloadData];
        });

    }

    
}

#pragma mark - Helpers

- (void)sendMobileCommandForDevice:(SFIDevice *)device deviceValue:(SFIDeviceKnownValues *)deviceValues deviceCell:(SFISensorTableViewCell *)cell {
    if (device == nil) {
        return;
    }
    if (deviceValues == nil) {
        return;
    }

    // Tell the cell to show 'updating' type message to user
    [cell showUpdatingMessage];

    dispatch_async(dispatch_get_main_queue(), ^() {
        //todo decide what to do about this
        [self.mobileCommandTimer invalidate];

        self.mobileCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                   target:self
                                                                 selector:@selector(onSendMobileCommandTimeout:)
                                                                 userInfo:nil
                                                                  repeats:NO];

        // dispatch request and keep track of its correlation ID so we can process the response
        //todo for future: note potential race condition: if we do not process command response on main queue it's possible response is processed before we have completed marking updating state.
        sfi_id c_id = [[SecurifiToolkit sharedInstance] asyncChangeAlmond:self.almond device:device value:deviceValues];
        [self markDeviceUpdatingState:device correlationId:c_id statusMessage:nil];
    });
}

- (void)resetDeviceListFromSaved {
    NSArray *list = [[SecurifiToolkit sharedInstance] deviceList:self.almondMac];
    if (list == nil) {
        list = @[];
    }

    [self clearAllDeviceUpdatingState];

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.isViewControllerDisposed) {
            return;
        }
        [self setDeviceList:list];
        [self.tableView reloadData];
        [self.HUD hide:YES];
    });
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

#pragma mark - Device table view cell state values

- (void)clearAllDeviceCellStateValues {
    @synchronized (self.deviceCellStateValues_locker) {
        _deviceCellStateValues = [NSMutableDictionary dictionary];
    };
}

- (void)setDeviceCellValue:(id)value forKey:(NSString *)key forDevice:(SFIDevice *)device {
    if (key == nil) {
        return;
    }
    if (device == nil) {
        return;
    }

    @synchronized (self.deviceCellStateValues_locker) {
        NSNumber *device_key = @(device.deviceID);
        NSMutableDictionary *all = (NSMutableDictionary *) self.deviceCellStateValues;

        NSMutableDictionary *dict = all[device_key];
        if (dict == nil) {
            dict = [NSMutableDictionary dictionary];
            all[device_key] = dict;
        }
        dict[key] = value;
    };
}

- (id)getDeviceCellValueForKey:(NSString *)key forDevice:(SFIDevice *)device {
    if (key == nil) {
        return nil;
    }
    if (device == nil) {
        return nil;
    }

    @synchronized (self.deviceCellStateValues_locker) {
        NSNumber *device_key = @(device.deviceID);
        NSMutableDictionary *all = (NSMutableDictionary *) self.deviceCellStateValues;
        NSMutableDictionary *dict = all[device_key];
        return dict[key];
    };
}

#pragma mark - Device updating state and status messages

- (NSString*)deviceLookupKey:(SFIDevice*)device {
    return [NSString stringWithFormat:@"d-%d", device.deviceID];
}

// marks the device as being "updated" and tracks an optional status message that will be shown in the sensor table cell when it is reloaded
// if the message is nil, then no message is shown.
- (void)markDeviceUpdatingState:(SFIDevice *)device correlationId:(sfi_id)c_id statusMessage:(NSString *)optionalStatusMessage {
    if (device == nil) {
        return;
    }

    @synchronized (self.deviceStatusMessages_locker) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.updatingDevices];

        NSNumber *key = @(c_id);
        NSString *device_key = [self deviceLookupKey:device];

        // correlation id to device
        dict[key] = device;
        // create reverse lookup
        dict[device_key] = key;

        _updatingDevices = [NSDictionary dictionaryWithDictionary:dict];

        dict = [NSMutableDictionary dictionaryWithDictionary:self.deviceStatusMessages];
        if (optionalStatusMessage) {
            dict[device_key] = optionalStatusMessage;
        }
        else {
            [dict removeObjectForKey:device_key];
        }
        _deviceStatusMessages = [NSDictionary dictionaryWithDictionary:dict];
    }
}

- (void)clearAllDeviceUpdatingState {
    @synchronized (self.deviceStatusMessages_locker) {
        _updatingDevices = [NSDictionary dictionary];
        _deviceStatusMessages = [NSDictionary dictionary];
    };
}

- (void)clearDeviceUpdatingState:(SFIDevice*)device {
    if (!device) {
        return;
    }

    @synchronized (self.deviceStatusMessages_locker) {
        NSNumber *cid_key = self.updatingDevices[device];
        NSString *device_key = [self deviceLookupKey:device];

        NSMutableDictionary *dict;

        dict = [NSMutableDictionary dictionaryWithDictionary:self.updatingDevices];
        if (cid_key) {
            [dict removeObjectForKey:cid_key];
        }
        [dict removeObjectForKey:device_key];
        _updatingDevices = [NSDictionary dictionaryWithDictionary:dict];

        dict  = [NSMutableDictionary dictionaryWithDictionary:self.deviceStatusMessages];
        [dict removeObjectForKey:device_key];
        _deviceStatusMessages = [NSDictionary dictionaryWithDictionary:dict];
    };
}

- (SFIDevice*)tryDeviceForCorrelationId:(sfi_id)c_id {
    NSNumber *key = @(c_id);
    return self.updatingDevices[key];
}

- (NSString*)tryDeviceStatusMessage:(SFIDevice*)device {
    NSString *device_key = [self deviceLookupKey:device];
    return self.deviceStatusMessages[device_key];
}

#pragma mark - Activation Notification Header

- (void)onCloseNotificationClicked:(id)sender {
    DLog(@"onCloseNotificationClicked");
    self.isAccountActivatedNotification = FALSE;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:ACCOUNT_ACTIVATION_NOTIFICATION];
    [self.tableView reloadData];
}

- (void)onResendActivationClicked:(id)sender {
    //Send activation email command
    DLog(@"onResendActivationClicked");
    [self sendReactivationRequest];
}

- (void)sendReactivationRequest {
    ValidateAccountRequest *validateCommand = [[ValidateAccountRequest alloc] init];
    validateCommand.email = [[SecurifiToolkit sharedInstance] loginEmail];

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_VALIDATE_REQUEST;
    cloudCommand.command = validateCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)validateResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    ValidateAccountResponse *obj = (ValidateAccountResponse *) [data valueForKey:@"data"];

    DLog(@"%s: Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful);
    DLog(@"%s: Reason : %@", __PRETTY_FUNCTION__, obj.reason);

    if (obj.isSuccessful) {
        [self showToast:@"Reactivation link sent to your registerd email ID."];
    }
    else {
        NSLog(@"Reason Code %d", obj.reasonCode);
        //Reason Code
        NSString *failureReason;
        switch (obj.reasonCode) {
            case 1:
                failureReason = @"The username was not found";
                break;
            case 2:
                failureReason = @"The account is already validated";
                break;
            case 3:
                failureReason = @"Sorry! The reactivation link cannot be \nsent at the moment. Try again later.";
                break;
            case 4:
                failureReason = @"The email ID is invalid.";
                break;
            case 5:
                failureReason = @"Sorry! The reactivation link cannot be \nsent at the moment. Try again later.";
                break;
            default:
                failureReason = @"Sorry! The reactivation link cannot be \nsent at the moment. Try again later.";
                break;
        }

        [self showToast:failureReason];
    }
}

@end
