//
//  SensorsViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar
//  Copyright (c) 2013 Securifi-Mac2. All rights reserved.
//

#import "SensorsViewController.h"
#import "SFIConstants.h"
#import "AlmondPlusConstants.h"
#import "SNLog.h"
#import "SFIColors.h"
#import "MBProgressHUD.h"
#import "ECSlidingViewController.h"
#import "SFICloudStatusBarButtonItem.h"
#import "SFIHighlightedButton.h"

@interface SensorsViewController () <ReorderTableViewDelegate>
@property(nonatomic, weak, readonly) BVReorderTableView *sensorTable;
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *statusBarButton;
@property(nonatomic, readonly) MBProgressHUD *HUD;

@property NSTimer *mobileCommandTimer;
@property NSTimer *sensorChangeCommandTimer;
@property NSTimer *sensorDataCommandTimer;

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
@property(nonatomic) NSString *offlineHash;

@property NSString *currentDeviceID;
@property unsigned int currentIndexID;
@property NSString *currentValue;
@property unsigned int currentInternalIndex;

@property BOOL isSliderExpanded;

@property(nonatomic, retain) NSString *currentChangedName;
@property(nonatomic, retain) NSString *currentChangedLocation;

@end

@implementation SensorsViewController

#pragma mark - View Related

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center removeObserver:self
                      name:NETWORK_CONNECTING_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:NETWORK_UP_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:NETWORK_DOWN_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:kSFIReachabilityChangedNotification
                    object:nil];

    [center removeObserver:self
                      name:HASH_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:DEVICE_DATA_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:DEVICE_VALUE_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:MOBILE_COMMAND_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:DEVICE_DATA_CLOUD_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:DEVICE_VALUE_CLOUD_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:kSFIDidUpdateAlmondList
                    object:nil];

    [center removeObserver:self
                      name:SENSOR_CHANGE_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:kSFIDidChangeAlmondName
                    object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };

    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;

    _statusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithStandard];
    self.navigationItem.rightBarButtonItem = _statusBarButton;

    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];

    _sensorTable = (BVReorderTableView *) self.tableView;
    _sensorTable.delegate = self;
    _sensorTable.canReorder = NO;

    // Attach the HUD to the parent, not to the table view, so that user cannot scroll the table while it is presenting.
    _HUD = [[MBProgressHUD alloc] initWithView:self.parentViewController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.labelText = @"Loading sensor data.";
    _HUD.dimBackground = YES;
    [self.parentViewController.view addSubview:_HUD];

    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tableView.autoresizesSubviews = YES;
    //self.tableView.backgroundColor = [UIColor blackColor];

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    //Display Drawer Gesture
    UISwipeGestureRecognizer *showMenuSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealTab:)];
    showMenuSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:showMenuSwipe];

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];

    SFIAlmondPlus *plus = [toolkit currentAlmond];
    self.currentMAC = plus.almondplusMAC;

    NSArray *almondList = [toolkit almondList];
    if (self.currentMAC == nil) {
        if ([almondList count] != 0) {
            SFIAlmondPlus *currentAlmond = almondList[0];
            [[SecurifiToolkit sharedInstance] setCurrentAlmond:currentAlmond colorCodeIndex:0];
            self.currentMAC = currentAlmond.almondplusMAC;

            NSString *currentMACName = currentAlmond.almondplusName;
            if (currentMACName != nil) {
                self.navigationItem.title = currentMACName;
            }
        }
        else {
            self.currentMAC = NO_ALMOND;
            self.navigationItem.title = @"Get Started";
        }
    }
    else {
        if ([almondList count] == 0) {
            self.currentMAC = NO_ALMOND;
            self.navigationItem.title = @"Get Started";
        }
    }

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
               selector:@selector(onHashResponseCallback:)
                   name:HASH_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onDeviceListResponseCallback:)
                   name:DEVICE_DATA_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onDeviceValueListResponseCallback:)
                   name:DEVICE_VALUE_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onMobileCommandResponseCallback:)
                   name:MOBILE_COMMAND_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onDeviceDataCloudResponseCallback:)
                   name:DEVICE_DATA_CLOUD_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onDeviceCloudValueListResponseCallback:)
                   name:DEVICE_VALUE_CLOUD_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
                 object:nil];

    [center addObserver:self
               selector:@selector(onSensorChangeCallback:)
                   name:SENSOR_CHANGE_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onAlmondNameDidChange:)
                   name:kSFIDidChangeAlmondName
                 object:nil];

    [self markCloudStatusIcon];

    [self initAlmondList];
}

- (void) initAlmondList {
    NSArray *almondList = [[SecurifiToolkit sharedInstance] almondList];
    if ([almondList count] == 0) {
        self.currentMAC = NO_ALMOND;
        self.navigationItem.title = @"Get Started";
        self.deviceList = @[];
        self.deviceValueList = @[];

        [self.tableView reloadData];
    }
    else {
        SFIAlmondPlus *plus = [[SecurifiToolkit sharedInstance] currentAlmond];
        self.currentMAC = plus.almondplusMAC;
        self.navigationItem.title = plus.almondplusName;

        self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
        self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
        self.offlineHash = [SFIOfflineDataManager readHashList:self.currentMAC];

        [self initializeImages];

        if (![self isNoAlmondMAC]) {
            [self.HUD show:YES];
            [self sendDeviceHashCommand];

            [self.sensorDataCommandTimer invalidate];
            self.sensorDataCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                           target:self
                                                                         selector:@selector(onLoadSensorDataCommandTimeout:)
                                                                         userInfo:nil
                                                                          repeats:NO];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // NSLog(@"Rotation %d", fromInterfaceOrientation);
    [self asyncReloadTable];
}

#pragma mark - State

- (BOOL)isDeviceListEmpty {
    return self.deviceList.count == 0;
}

- (BOOL)isNoAlmondMAC {
    return [self.currentMAC isEqualToString:NO_ALMOND];
}

#pragma mark - Reconnection

- (void)onNetworkUpNotifier:(id)sender {
    DLog(@"%s: Sensor controller :In networkUP notifier", __PRETTY_FUNCTION__);
    [self asyncReloadTable];
    [self markCloudStatusIcon];
}

- (void)onNetworkDownNotifier:(id)sender {
    DLog(@"%s: Sensor controller :In network down notifier", __PRETTY_FUNCTION__);
    [self markCloudStatusIcon];
    [self asyncReloadTable];
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:NO]; // make sure it is hidden
    });
}

- (void)onNetworkConnectingNotifier:(id)notification {
    [self markCloudStatusIcon];
}

- (void)onReachabilityDidChange:(NSNotification *)notification {
    [self markCloudStatusIcon];
    [self asyncReloadTable];
    dispatch_async(dispatch_get_main_queue(), ^() {
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

    SFIDevice *sensor = self.deviceList[(NSUInteger) indexPath.row];
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
    static NSString *sensor_cell_id = @"SensorCell";

    SFIDevice *currentSensor = self.deviceList[(NSUInteger) indexPathRow];
    int currentDeviceType = currentSensor.deviceType;

    NSUInteger height = [self computeSensorRowHeight:currentSensor];
    NSString *id = currentSensor.isExpanded ? [NSString stringWithFormat:@"SensorExpanded_%ld", (unsigned long)height] : sensor_cell_id;

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //PY 070114
    //START: HACK FOR MEMORY LEAKS
    for (UIView *currentView in cell.contentView.subviews) {
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS

    UIImageView *imgDevice;
    UILabel *lblDeviceValue;
    UILabel *lblDecimalValue;
    UILabel *lblDegree;
    UILabel *lblDeviceName;
    UILabel *lblDeviceStatus;

    UIImageView *imgSettings;
    UIButton *btnDevice;
    UIButton *btnDeviceImg;
    UIButton *btnSettings;
    UILabel *leftBackgroundLabel;
    UILabel *rightBackgroundLabel;
    UIButton *btnSettingsCell;

//    UIColor *standard_blue = [self makeStandardBlue];
    UIFont *heavy_font = [UIFont fontWithName:@"Avenir-Heavy" size:14];

    int positionIndex = indexPathRow % 15;
    if (positionIndex < 7) {
        self.changeBrightness = self.baseBrightness - (positionIndex * 10);
    }
    else {
        self.changeBrightness = (self.baseBrightness - 70) + ((positionIndex - 7) * 10);
    }

    //Left Square - Creation
    leftBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,5,LEFT_LABEL_WIDTH,SENSOR_ROW_HEIGHT-10)];
    leftBackgroundLabel.userInteractionEnabled = YES;
    leftBackgroundLabel.backgroundColor = [self makeStandardBlue];
    [cell addSubview:leftBackgroundLabel];

    btnDeviceImg = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDeviceImg.backgroundColor = [UIColor clearColor];
    [btnDeviceImg addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];

    if (currentDeviceType == 7) {
        //In case of thermostat show value instead of image
        //For Integer Value
        lblDeviceValue = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 5, 12, 60, 70)];
        lblDeviceValue.backgroundColor = [UIColor clearColor];
        lblDeviceValue.textColor = [UIColor whiteColor];
        lblDeviceValue.textAlignment = NSTextAlignmentCenter;
        lblDeviceValue.font = [UIFont fontWithName:@"Avenir-Heavy" size:45];
        [lblDeviceValue addSubview:btnDeviceImg];

        //For Decimal Value
        lblDecimalValue = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 10, 40, 20, 30)];
        lblDecimalValue.backgroundColor = [UIColor clearColor];
        lblDecimalValue.textColor = [UIColor whiteColor];
        lblDecimalValue.textAlignment = NSTextAlignmentCenter;
        lblDecimalValue.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];

        //For Degree
        lblDegree = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH - 10, 25, 20, 20)];
        lblDegree.backgroundColor = [UIColor clearColor];
        lblDegree.textColor = [UIColor whiteColor];
        lblDegree.textAlignment = NSTextAlignmentCenter;
        lblDegree.font = [UIFont fontWithName:@"Avenir-Heavy" size:18];
        lblDegree.text = @"°";

        [cell addSubview:lblDeviceValue];
        [cell addSubview:lblDecimalValue];
        [cell addSubview:lblDegree];
    }
    else {
        imgDevice = [[UIImageView alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH / 3, 12, 53, 70)];
        imgDevice.userInteractionEnabled = YES;
        [imgDevice addSubview:btnDeviceImg];
        btnDeviceImg.frame = imgDevice.bounds;
        [cell addSubview:imgDevice];
    }

    btnDevice = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDevice.frame = leftBackgroundLabel.bounds;
    btnDevice.backgroundColor = [UIColor clearColor];
    [btnDevice addTarget:self action:@selector(onDeviceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [leftBackgroundLabel addSubview:btnDevice];

    //Right Rectangle - Creation
    rightBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_LABEL_WIDTH + 11, 5, self.tableView.frame.size.width - LEFT_LABEL_WIDTH - 25, SENSOR_ROW_HEIGHT - 10)];
    rightBackgroundLabel.backgroundColor = [self makeStandardBlue];
    [cell addSubview:rightBackgroundLabel];

    lblDeviceName = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, (self.tableView.frame.size.width - LEFT_LABEL_WIDTH - 90), 30)];
    lblDeviceName.backgroundColor = [UIColor clearColor];
    lblDeviceName.textColor = [UIColor whiteColor];
    lblDeviceStatus.font = [UIFont fontWithName:@"Avenir-Heavy" size:16];
    [rightBackgroundLabel addSubview:lblDeviceName];

    lblDeviceStatus = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, 180, 60)];
    lblDeviceStatus.backgroundColor = [UIColor clearColor];
    lblDeviceStatus.textColor = [UIColor whiteColor];
    lblDeviceStatus.numberOfLines = 2;
    lblDeviceStatus.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
    [rightBackgroundLabel addSubview:lblDeviceStatus];

    imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 60, 37, 23, 23)];
    imgSettings.image = [UIImage imageNamed:@"icon_config.png"];
    imgSettings.alpha = 0.5;
    imgSettings.userInteractionEnabled = YES;

    btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.frame = imgSettings.bounds;
    btnSettings.backgroundColor = [UIColor clearColor];
    [btnSettings addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgSettings addSubview:btnSettings];

    btnSettingsCell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettingsCell.frame = CGRectMake(self.tableView.frame.size.width - 80, 5, 60, 80);
    btnSettingsCell.backgroundColor = [UIColor clearColor];
    [btnSettingsCell addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnSettingsCell];

    //Fill values
    lblDeviceName.text = currentSensor.deviceName;

    //Set values according to device type
    int currentDeviceId = currentSensor.deviceID;


    //Get the value to be displayed on right rectangle
    NSString *currentValue;
    NSString *currentStateValue;

    SFIDeviceKnownValues *currentDeviceValue;
    switch (currentDeviceType) {
        case 1:
            //Switch
            //Only one value
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:0];
            currentValue = currentDeviceValue.value;

            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else if (currentValue == nil) {
                lblDeviceStatus.text = @"Could not update sensor\ndata.";
            }
            else {
                lblDeviceStatus.text = [currentDeviceValue choiceForBoolValueTrueValue:@"ON" falseValue:@"OFF" nilValue:currentValue];
            }

            break;

        case 2: {
            //Multilevel switch

//            //Get State
//            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
//            currentStateValue = currentDeviceValue.value;

            //Get Percentage
            SFIDeviceKnownValues *currentLevelKnownValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.mostImpValueIndex];
            NSString *currentLevel = currentLevelKnownValue.value;

            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            //PY 291113
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if (currentSensor.imageName == nil) {
                imgDevice.image = [UIImage imageNamed:DT2_MULTILEVEL_SWITCH_TRUE];
            }

            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else {
                lblDeviceStatus.text = [currentLevelKnownValue choiceForLevelValueZeroValue:@"OFF"
                                                                               nonZeroValue:[NSString stringWithFormat:@"Dimmable, %@%%", currentLevel]
                                                                                   nilValue:@"Could not update sensor\ndata."];

/*
                if (![currentLevel isEqualToString:@""]) {
                    if ([currentLevel isEqualToString:@"0"]) {
                        lblDeviceStatus.text = @"OFF";
                    }
                    else {
                        lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %@%%", currentLevel];
                    }
                }
                else {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
*/
            }
            break;
        }
        case 3: {
            //Binary Sensor
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
//            currentStateValue = currentDeviceValue.value;

            lblDeviceStatus.text = [currentDeviceValue choiceForBoolValueTrueValue:@"OPEN"
                                                                        falseValue:@"CLOSED"
                                                                          nilValue:@"Could not update sensor\ndata."
                                                                       nonNilValue:currentValue];

            NSString *imageName = [currentDeviceValue choiceForBoolValueTrueValue:DT3_BINARY_SENSOR_TRUE
                                                                       falseValue:DT3_BINARY_SENSOR_FALSE
                                                                         nilValue:currentSensor.imageName];
            imgDevice.image = [UIImage imageNamed:imageName];
        }

/*


            if([currentStateValue isEqualToString:@"true"]){
                imgDevice.image = [UIImage imageNamed:DT3_BINARY_SENSOR_TRUE];
                lblDeviceStatus.text = @"OPEN";
            }else if([currentStateValue isEqualToString:@"false"]){
                imgDevice.image = [UIImage imageNamed:DT3_BINARY_SENSOR_FALSE];
                lblDeviceStatus.text = @"CLOSED";
            }else{
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if(currentStateValue==nil){
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }else{
                    lblDeviceStatus.text = currentValue;
                }
            }
*/


            //            if([currentSensor.mostImpValueName isEqualToString:TAMPER]){
            //                // imgDevice.frame = CGRectMake(25, 15, 53,60);
            //                lblDeviceStatus.text = @"TAMPERED";
            //                if([currentStateValue isEqualToString:@"false"]){
            //                    imgDevice.image = [UIImage imageNamed:@"door_off_tamper.png"];
            //                }else if([currentStateValue isEqualToString:@"true"]){
            //                    imgDevice.image = [UIImage imageNamed:@"door_on_tamper.png"];
            //                }
            //            }else if([currentSensor.mostImpValueName isEqualToString:@"LOW BATTERY"]){
            //                //imgDevice.frame = CGRectMake(25, 15, 53,60);
            //                lblDeviceStatus.text = @"LOW BATTERY";
            //                if([currentStateValue isEqualToString:@"false"]){
            //                    imgDevice.image = [UIImage imageNamed:@"door_off_battery.png"];
            //                }
            //            }else{
            //                //Check OPEN CLOSE State
            //                currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.mostImpValueIndex];
            //                currentValue = currentDeviceValue.value;
            //                if([currentValue isEqualToString:@"true"]){
            //                    // imgDevice.frame = CGRectMake(30, 20, 40.5,60);
            //                    lblDeviceStatus.text = @"OPEN";
            //                }else if([currentValue isEqualToString:@"false"]){
            //                    //imgDevice.frame = CGRectMake(30, 15, 40.5,60);
            //                    lblDeviceStatus.text = @"CLOSED";
            //                }else{
            //                    if(currentValue==nil){
            //                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
            //                    }else{
            //                        lblDeviceStatus.text = currentValue;
            //                    }
            //                }
            //            }



            //            currentDeviceValue = [currentKnownValues objectAtIndex:0];
            //            currentValue = currentDeviceValue.value;
            //            if([currentValue isEqualToString:@"true"]){
            //                imgDevice.frame = CGRectMake(30, 20, 40.5,60);
            //                lblDeviceStatus.text = @"OPEN";
            //            }else{
            //                imgDevice.frame = CGRectMake(30, 15, 40.5,60);
            //                lblDeviceStatus.text = @"CLOSED";
            //            }
            //            imgDevice.image = [UIImage imageNamed:@"door_on.png"];
            break;

        case 4:
//            //Level Control
//            currentDeviceValue = [currentKnownValues objectAtIndex:currentSensor.stateIndex];
//            currentStateValue = currentDeviceValue.value;
//            //PY - Show only State
//            if([currentStateValue isEqualToString:@"true"]){
//                imgDevice.image = [UIImage imageNamed:DT4_LEVEL_CONTROL_TRUE];
//                lblDeviceStatus.text = @"ON";
//            }else if([currentStateValue isEqualToString:@"false"]){
//                imgDevice.image = [UIImage imageNamed:DT4_LEVEL_CONTROL_FALSE];
//                lblDeviceStatus.text = @"OFF";
//            }else{
//                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
//                if(currentStateValue==nil){
//                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
//                }else{
//                    lblDeviceStatus.text = currentValue;
//                }
//            }
        {

            //Get State
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];

            //Get Percentage
            SFIDeviceKnownValues *currentLevelKnownValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.mostImpValueIndex];

            NSString *image_name = (currentSensor.imageName == nil) ? DT4_LEVEL_CONTROL_TRUE : currentSensor.imageName;
            imgDevice.image = [UIImage imageNamed:image_name];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else {
                float intLevel = [currentLevelKnownValue floatValue];
                intLevel = (intLevel / 256) * 100;

                // Set soem defaults
                NSString *status_str;

                if (!currentDeviceValue.hasValue) {
                    if (currentDeviceValue == nil) {
                        status_str = @"Could not update sensor\ndata.";
                    }
                    else if (currentLevelKnownValue.hasValue) {
                        status_str = [NSString stringWithFormat:@"Dimmable, %.0f%%", intLevel];
                    }
                    else {
                        status_str = @"Dimmable";
                    }
                }
                else if (currentDeviceValue.boolValue == true) {
                    if ([currentLevelKnownValue hasValue]) {
                        status_str = [NSString stringWithFormat:@"ON, %.0f%%", intLevel];
                    }
                    else {
                        status_str = @"ON";
                    }
                }
                else {
                    if ([currentLevelKnownValue hasValue]) {
                        status_str = [NSString stringWithFormat:@"OFF, %.0f%%", intLevel];
                    }
                    else {
                        status_str = @"OFF";
                    }
                }

                lblDeviceStatus.text = status_str;

/*
                if ([currentStateValue isEqualToString:@"true"]) {
                    if (![currentLevel isEqualToString:@""]) {
                        lblDeviceStatus.text = [NSString stringWithFormat:@"ON, %.0f%%", intLevel];
                    }
                    else {
                        lblDeviceStatus.text = @"ON";
                    }
                }
                else if ([currentStateValue isEqualToString:@"false"]) {
                    if (![currentLevel isEqualToString:@""]) {
                        lblDeviceStatus.text = [NSString stringWithFormat:@"OFF, %.0f%%", intLevel];
                    }
                    else {
                        lblDeviceStatus.text = @"OFF";
                    }
                }
                else if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                    if (currentDeviceValue == nil) {
                        if (![currentLevel isEqualToString:@""]) {
                            lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %.0f%%", intLevel];
                        }
                        else {
                            lblDeviceStatus.text = @"Dimmable";
                        }
                    }
                }
                else {
                    if (![currentLevel isEqualToString:@""]) {
                        lblDeviceStatus.text = [NSString stringWithFormat:@"Dimmable, %.0f%%", intLevel];
                    }
                    else {
                        lblDeviceStatus.text = @"Dimmable";
                    }
                }
*/

                //TODO: Remove later - For testing
//                lblDeviceStatus.numberOfLines = 2;
//                lblDeviceStatus.text =  [NSString stringWithFormat:@"ON, %.0f%%\nLOW BATTERY", intLevel];

            }

            break;
        }
        case 5:
            //Door Lock
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT5_DOOR_LOCK_TRUE];
                lblDeviceStatus.text = @"LOCKED";
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT5_DOOR_LOCK_FALSE];
                lblDeviceStatus.text = @"UNLOCKED";
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }
            break;
        case 6:
            //Alarm
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - TODO: Change later
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT6_ALARM_TRUE];
                lblDeviceStatus.text = @"ON";
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT6_ALARM_FALSE];
                lblDeviceStatus.text = @"OFF";
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }
            break;
        case 7: {
            //Thermostat
            NSString *strValue = @"";

            NSString *strStatus;
            NSString *strOperatingMode;
            NSString *heatingSetpoint;
            NSString *coolingSetpoint;

            NSArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];
            for (SFIDeviceKnownValues *currentKnownValue in currentKnownValues) {
                if ([currentKnownValue.valueName isEqualToString:@"SENSOR MULTILEVEL"]) {
                    strValue = currentKnownValue.value;
                    //lblDeviceValue.text = [NSString stringWithFormat:@"%@°",currentKnownValue.value] ;
                }
                else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT SETPOINT HEATING"]) {
                    heatingSetpoint = [NSString stringWithFormat:@" HI %@°", currentKnownValue.value];
                }
                else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT SETPOINT COOLING"]) {
                    coolingSetpoint = [NSString stringWithFormat:@" LO %@°", currentKnownValue.value];
                }
                else if ([currentKnownValue.valueName isEqualToString:@"THERMOSTAT OPERATING STATE"]) {
                    strOperatingMode = currentKnownValue.value;
                }
            }

            strStatus = [NSString stringWithFormat:@"%@, %@, %@", strOperatingMode, coolingSetpoint, heatingSetpoint];

            //Calculate values
            NSArray *thermostatValues = [strValue componentsSeparatedByString:@"."];

            NSString *strIntegerValue = thermostatValues[0];
            if ([thermostatValues count] == 2) {
                NSString *strDecimalValue = thermostatValues[1];
                lblDecimalValue.text = [NSString stringWithFormat:@".%@", strDecimalValue];
            }

            lblDeviceValue.text = strIntegerValue;
            if ([strIntegerValue length] == 1) {
                lblDecimalValue.frame = CGRectMake((self.tableView.frame.size.width / 4) - 25, 40, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 25, 20, 20);
            }
            else if ([strIntegerValue length] == 3) {
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:30]];
                [lblDecimalValue setFont:heavy_font];
                [lblDegree setFont:heavy_font];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 38, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 30, 20, 20);
            }
            else if ([strIntegerValue length] == 4) {
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:22]];
                [lblDecimalValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                [lblDegree setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 35, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 30, 20, 20);
            }


            lblDeviceStatus.text = strStatus;
            break;
        }
        case 11: {
            //Motion Sensor
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.25), 12, 53, 70);
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT11_MOTION_SENSOR_TRUE];
                [strStatus appendString:@"MOTION DETECTED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT11_MOTION_SENSOR_FALSE];
                [strStatus appendString:@"NO MOTION"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }
            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 12: {
            //ContactSwitch
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
//                imgDevice.image = [UIImage imageNamed:DT12_CONTACT_SWITCH_TRUE];
                [strStatus appendString:@"OPEN"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
//                imgDevice.image = [UIImage imageNamed:DT12_CONTACT_SWITCH_FALSE];
                [strStatus appendString:@"CLOSED"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 13: {
            //Fire Sensor
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY - Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT13_FIRE_SENSOR_TRUE];
                [strStatus appendString:@"ALARM: FIRE DETECTED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT13_FIRE_SENSOR_FALSE];
                [strStatus appendString:@"OK"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 14: {
            //Water Sensor
//            NSString *text = @"89";
//            UIGraphicsBeginImageContext(CGSizeMake(53, 70));
//            [text drawAtPoint:CGPointMake(0, 0)
//                     withFont:[UIFont fontWithName:@"Avenir-Heavy" size:36]];
//            UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            imgDevice.image = result;

            NSMutableString *strStatus = [[NSMutableString alloc] init];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);

            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT14_WATER_SENSOR_TRUE];
                [strStatus appendString:@"FLOODED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT14_WATER_SENSOR_FALSE];
                [strStatus appendString:@"OK"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }

            break;
        }
        case 15: {
            //Gas Sensor
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT15_GAS_SENSOR_TRUE];
                [strStatus appendString:@"ALARM: GAS DETECTED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT15_GAS_SENSOR_FALSE];
                [strStatus appendString:@"OK"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 17: {
            //Vibration Sensor
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT17_VIBRATION_SENSOR_TRUE];
                [strStatus appendString:@"VIBRATION DETECTED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT17_VIBRATION_SENSOR_FALSE];
                [strStatus appendString:@"NO VIBRATION"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 19: {
            //Keyfob
            NSMutableString *strStatus = [[NSMutableString alloc] init];
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT19_KEYFOB_TRUE];
                [strStatus appendString:@"LOCKED"];
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT19_KEYFOB_FALSE];
                [strStatus appendString:@"UNLOCKED"];
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }

            if (currentSensor.isBatteryLow) {
                [strStatus appendString:@"\nLOW BATTERY"];
                lblDeviceStatus.numberOfLines = 2;
                lblDeviceStatus.text = strStatus;
            }
            else {
                lblDeviceStatus.text = strStatus;
            }
            break;
        }
        case 22:
            //Electric Measurement Switch - AC
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 10, 53, 70);
            //PY 291113 - Show only State
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else {
                if ([currentStateValue isEqualToString:@"true"]) {
                    lblDeviceStatus.text = @"ON";
                }
                else if ([currentStateValue isEqualToString:@"false"]) {
                    lblDeviceStatus.text = @"OFF";
                }
                else {
                    if (currentStateValue == nil) {
                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
                    }
                    else {
                        lblDeviceStatus.text = currentValue;
                    }
                }
                break;
            }
            // pass through!
        case 23: {
            //Electric Measurement Switch - DC
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
            //PY 291113 - Show only State
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            if (currentDeviceValue.isUpdating) {
                lblDeviceStatus.text = @"Updating sensor data.\nPlease wait.";
            }
            else {
                if ([currentStateValue isEqualToString:@"true"]) {
                    lblDeviceStatus.text = @"ON";
                }
                else if ([currentStateValue isEqualToString:@"false"]) {
                    lblDeviceStatus.text = @"OFF";
                }
                else {
                    if (currentStateValue == nil) {
                        lblDeviceStatus.text = @"Could not update sensor\ndata.";
                    }
                    else {
                        lblDeviceStatus.text = currentValue;
                    }
                }
            }
            break;
        }
        case 27: {
            //Temperature Sensor
            NSString *strValue = @"";

            NSArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];
            for (SFIDeviceKnownValues *currentKnownValue in currentKnownValues) {
                if ([currentKnownValue.valueName isEqualToString:@"MEASURED_VALUE"]) {
                    strValue = currentKnownValue.value;
                }
                else if ([currentKnownValue.valueName isEqualToString:@"TOLERANCE"]) {
                    lblDeviceStatus.text = [NSString stringWithFormat:@"Tolerance: %@", currentKnownValue.value];
                }
            }

            //Calculate values
            NSArray *temperatureValues = [strValue componentsSeparatedByString:@"."];


            NSString *strIntegerValue = temperatureValues[0];

            if ([temperatureValues count] == 2) {
                NSString *strDecimalValue = temperatureValues[1];
                lblDecimalValue.text = [NSString stringWithFormat:@".%@", strDecimalValue];
            }

            lblDeviceValue.text = strIntegerValue;
            if ([strIntegerValue length] == 1) {
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 40, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 25, 25, 20, 20);
            }
            else if ([strIntegerValue length] == 3) {
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:30]];
                [lblDecimalValue setFont:heavy_font];
                [lblDegree setFont:heavy_font];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 38, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 10, 30, 20, 20);
            }
            else if ([strIntegerValue length] == 4) {
                [lblDeviceValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:22]];
                [lblDecimalValue setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                [lblDegree setFont:[UIFont fontWithName:@"Avenir-Heavy" size:10]];
                lblDecimalValue.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 35, 20, 30);
                lblDegree.frame = CGRectMake(LEFT_LABEL_WIDTH - 12, 30, 20, 20);
            }

            break;
        }
        case 34: {
            //Keyfob
            currentDeviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valuesIndex:currentSensor.stateIndex];
            currentStateValue = currentDeviceValue.value;
            //PY Show only State
            if ([currentStateValue isEqualToString:@"true"]) {
                imgDevice.image = [UIImage imageNamed:DT34_SHADE_TRUE];
                lblDeviceStatus.text = @"OPEN";
            }
            else if ([currentStateValue isEqualToString:@"false"]) {
                imgDevice.image = [UIImage imageNamed:DT34_SHADE_FALSE];
                lblDeviceStatus.text = @"CLOSED";
            }
            else {
                imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
                if (currentStateValue == nil) {
                    lblDeviceStatus.text = @"Could not update sensor\ndata.";
                }
                else {
                    lblDeviceStatus.text = currentValue;
                }
            }
            break;
        }
        default: {
            imgDevice.frame = CGRectMake((CGFloat) (LEFT_LABEL_WIDTH / 3.5), 12, 53, 70);
            imgDevice.image = [UIImage imageNamed:currentSensor.imageName];
            break;
        }
    }

    btnDevice.tag = indexPathRow;
    btnDeviceImg.tag = indexPathRow;
    btnSettings.tag = indexPathRow;
    btnSettingsCell.tag = indexPathRow;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //Expanded View
    if(currentSensor.isExpanded){
        //Settings icon - white
        imgSettings.alpha = 1.0;

        //Show values also
        UILabel *belowBackgroundLabel = [[UILabel alloc] init];
        belowBackgroundLabel.userInteractionEnabled = YES;
        belowBackgroundLabel.backgroundColor = [self makeStandardBlue];

        UILabel *expandedLblText;
        float baseYCordinate = -20;
        //expandedLblText.backgroundColor = [UIColor greenColor];
        switch (currentDeviceType) {
            case 1:
                baseYCordinate = baseYCordinate+25;
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //               currentDeviceValue = [currentKnownValues objectAtIndex:0];
//                //                expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
//                //Display Location - PY 291113
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            case 2:
            {
                baseYCordinate+=35;
                UIImageView *minImage = [[UIImageView alloc]initWithFrame:CGRectMake(10.0, baseYCordinate-5, 24,24)];
                [minImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
                [belowBackgroundLabel addSubview:minImage];

                //Display slider
                UISlider *slider = [[UISlider alloc] init];
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate, self.tableView.frame.size.width - 110, 10.0);
                } else {
                    // code for 3.5-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate-10, (self.tableView.frame.size.width - 110), 10.0);
                }

//                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40.0, baseYCordinate-10, (self.tableView.frame.size.width - 110), 10.0)];
                slider.tag = indexPathRow;
                slider.minimumValue = 0;
                slider.maximumValue = 99;
                [slider addTarget:self action:@selector(sliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];

//                UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)] ;
//                [slider addGestureRecognizer:tapSlider];

                //Set slider value
                float currentSliderValue = 0.0;

                NSArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];
                for (currentDeviceValue in currentKnownValues) {
                    if ([currentDeviceValue.valueName isEqualToString:@"SWITCH MULTILEVEL"]) {
                        currentSliderValue = [currentDeviceValue.value floatValue];
                        break;
                    }
                }

                [slider setValue:currentSliderValue animated:YES];

                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateNormal];
                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateHighlighted];
                [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"] forState:UIControlStateNormal];
                [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"] forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:slider];

                UIImageView *maxImage = [[UIImageView alloc]initWithFrame:CGRectMake((self.tableView.frame.size.width - 110) + 50, baseYCordinate-5, 24,24)];
                [maxImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
                [belowBackgroundLabel addSubview:maxImage];

                baseYCordinate+=25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];

                baseYCordinate = baseYCordinate+5;

//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 70, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //Display Location
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 3:
            {
                NSArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];
                for (currentDeviceValue in currentKnownValues) {
                    //Display only battery - PY 291113
                    NSString *batteryStatus;
                    if ([currentDeviceValue.valueName isEqualToString:@"BATTERY"]) {
                        expandedLblText = [[UILabel alloc] init];
                        expandedLblText.backgroundColor = [UIColor clearColor];
                        //Check the status of value
                        if ([currentValue isEqualToString:@"1"]) {
                            //Battery Low
                            batteryStatus = @"Low Battery";
                        }
                        else {
                            //Battery OK
                            batteryStatus = @"Battery OK";
                        }
                        expandedLblText.text = batteryStatus;
                        expandedLblText.textColor = [UIColor whiteColor];
                        expandedLblText.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];

                        baseYCordinate = baseYCordinate + 25;
                        expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                        [belowBackgroundLabel addSubview:expandedLblText];
                    }
                }

                baseYCordinate+=25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];

                baseYCordinate = baseYCordinate+5;

//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                //Display Location - PY 291113
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 4: {
                //Level Control
                baseYCordinate += 35;
                UIImageView *minImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 24, 24)];
                [minImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
                [belowBackgroundLabel addSubview:minImage];

                //Display slider
                UISlider *slider = [[UISlider alloc] init];
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate, self.tableView.frame.size.width - 110, 10.0);
                }
                else {
                    // code for 3.5-inch screen
                    slider.frame = CGRectMake(40.0, baseYCordinate - 10, (self.tableView.frame.size.width - 110), 10.0);
                }

//                UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40.0, baseYCordinate-10, self.tableView.frame.size.width - 110, 10.0)];
                slider.tag = indexPathRow;
                slider.minimumValue = 0;
                slider.maximumValue = 255;
                [slider addTarget:self action:@selector(sliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];

//                UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTapped:)];
//                [slider addGestureRecognizer:tapSlider];


                //Set slider value
                float currentSliderValue = 0.0;

                NSArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];
                for (currentDeviceValue in currentKnownValues) {
                    if ([currentDeviceValue.valueName isEqualToString:@"SWITCH MULTILEVEL"]) {
                        currentSliderValue = [currentDeviceValue.value floatValue];
                        break;
                    }
                }

                [slider setValue:currentSliderValue animated:YES];

                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateNormal];
                [slider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                             forState:UIControlStateHighlighted];
                [slider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"]
                                    forState:UIControlStateNormal];
                [slider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"]
                                    forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:slider];

                UIImageView *maxImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.tableView.frame.size.width - 110) + 50, baseYCordinate - 5, 24, 24)];
                [maxImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
                [belowBackgroundLabel addSubview:maxImage];

                baseYCordinate += 25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];

                baseYCordinate = baseYCordinate + 5;
                break;
            }
            case 5:{
                //Door Lock
                baseYCordinate = baseYCordinate+25;
                break;
            }
            case 6:{
                //Alarm
                baseYCordinate = baseYCordinate+25;
                break;
            }
            case 7: {
                //Thermostat
                baseYCordinate += 40;

                //Heating Setpoint
                UILabel *lblHeating = [[UILabel alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 60, 30)];
                lblHeating.textColor = [UIColor whiteColor];
                [lblHeating setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblHeating.text = @"Heating";
                [belowBackgroundLabel addSubview:lblHeating];

//                UIImageView *minHeatImage = [[UIImageView alloc]initWithFrame:CGRectMake(80.0, baseYCordinate-3, 24,24)];
//                [minHeatImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
//                [belowBackgroundLabel addSubview:minHeatImage];
                UILabel *lblMinHeat = [[UILabel alloc] initWithFrame:CGRectMake(70.0, baseYCordinate - 3, 30, 24)];
                [lblMinHeat setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMinHeat.text = @"35°";
                lblMinHeat.textColor = [UIColor whiteColor];
                lblMinHeat.textAlignment = NSTextAlignmentCenter;
                lblMinHeat.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMinHeat];

                //Display heating slider
                UISlider *heatSlider = [[UISlider alloc] init];
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    heatSlider.frame = CGRectMake(100.0, baseYCordinate, self.tableView.frame.size.width - 160, 10.0);
                }
                else {
                    // code for 3.5-inch screen
                    heatSlider.frame = CGRectMake(100.0, baseYCordinate - 10, self.tableView.frame.size.width - 160, 10.0);
                }
//                UISlider *heatSlider = [[UISlider alloc] initWithFrame:CGRectMake(100.0, baseYCordinate-10, self.tableView.frame.size.width - 160, 10.0)];
                heatSlider.tag = indexPathRow;
                heatSlider.minimumValue = 35;
                heatSlider.maximumValue = 95;
                [heatSlider addTarget:self action:@selector(heatingSliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                UITapGestureRecognizer *tapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(heatingSliderTapped:)];
                [heatSlider addGestureRecognizer:tapSlider];

                [heatSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                                 forState:UIControlStateNormal];
                [heatSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"]
                                 forState:UIControlStateHighlighted];
                [heatSlider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"]
                                        forState:UIControlStateNormal];
                [heatSlider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"]
                                        forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:heatSlider];

                UILabel *lblMaxHeat = [[UILabel alloc] initWithFrame:CGRectMake(100 + (self.tableView.frame.size.width - 160), baseYCordinate - 3, 30, 24)];
                [lblMaxHeat setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMaxHeat.text = @"95°";
                lblMaxHeat.textColor = [UIColor whiteColor];
                lblMaxHeat.textAlignment = NSTextAlignmentCenter;
                lblMaxHeat.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMaxHeat];

//                UIImageView *maxHeatImage = [[UIImageView alloc]initWithFrame:CGRectMake(100 + (self.tableView.frame.size.width - 160), baseYCordinate-3, 24,24)];
//                [maxHeatImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
//                [belowBackgroundLabel addSubview:maxHeatImage];

                baseYCordinate += 40;
                //PY 170114
//                UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                imgLine1.image = [UIImage imageNamed:@"line.png"];
//                imgLine1.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine1];
//                
//                baseYCordinate = baseYCordinate+10;

                //Cooling Setpoint
                UILabel *lblCooling = [[UILabel alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 60, 30)];
                lblCooling.textColor = [UIColor whiteColor];
                [lblCooling setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblCooling.text = @"Cooling";
                [belowBackgroundLabel addSubview:lblCooling];

//                UIImageView *minCoolingImage = [[UIImageView alloc]initWithFrame:CGRectMake(80.0, baseYCordinate-3, 24,24)];
//                [minCoolingImage setImage:[UIImage imageNamed:@"dimmer_min.png"]];
//                [belowBackgroundLabel addSubview:minCoolingImage];

                UILabel *lblMinCool = [[UILabel alloc] initWithFrame:CGRectMake(70.0, baseYCordinate - 3, 30, 24)];
                [lblMinCool setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMinCool.text = @"35°";
                lblMinCool.textColor = [UIColor whiteColor];
                lblMinCool.textAlignment = NSTextAlignmentCenter;
                lblMinCool.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMinCool];

                //Display Cooling slider
                UISlider *coolSlider = [[UISlider alloc] init];
                //CGRect screenBounds = [[UIScreen mainScreen] bounds];
                if (screenBounds.size.height == 568) {
                    // code for 4-inch screen
                    coolSlider.frame = CGRectMake(100.0, baseYCordinate, self.tableView.frame.size.width - 160, 10.0);
                }
                else {
                    // code for 3.5-inch screen
                    coolSlider.frame = CGRectMake(100.0, baseYCordinate - 10, self.tableView.frame.size.width - 160, 10.0);
                }
//                UISlider *coolSlider = [[UISlider alloc] initWithFrame:CGRectMake(100.0, baseYCordinate-10, self.tableView.frame.size.width - 160, 10.0)];
                coolSlider.tag = indexPathRow;
                coolSlider.minimumValue = 35;
                coolSlider.maximumValue = 95;
                [coolSlider addTarget:self action:@selector(coolingSliderDidEndSliding:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
                UITapGestureRecognizer *coolTapSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coolingSliderTapped:)];
                [coolSlider addGestureRecognizer:coolTapSlider];

                [coolSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateNormal];
                [coolSlider setThumbImage:[UIImage imageNamed:@"seekbar_thumb 2.png"] forState:UIControlStateHighlighted];
                [coolSlider setMinimumTrackImage:[UIImage imageNamed:@"seekbar_dark_patch 2.png"] forState:UIControlStateNormal];
                [coolSlider setMaximumTrackImage:[UIImage imageNamed:@"seekbar_background 2.png"] forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:coolSlider];

//                UIImageView *maxCoolImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 160 + 100, baseYCordinate-3, 24,24)];
//                [maxCoolImage setImage:[UIImage imageNamed:@"dimmer_max.png"]];
//                [belowBackgroundLabel addSubview:maxCoolImage];

                UILabel *lblMaxCool = [[UILabel alloc] initWithFrame:CGRectMake(100 + (self.tableView.frame.size.width - 160), baseYCordinate - 3, 30, 24)];
                [lblMaxCool setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMaxCool.text = @"95°";
                lblMaxCool.textColor = [UIColor whiteColor];
                lblMaxCool.textAlignment = NSTextAlignmentCenter;
                lblMaxCool.backgroundColor = [UIColor clearColor];
                [belowBackgroundLabel addSubview:lblMaxCool];

                baseYCordinate += 30;
                UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                imgLine2.image = [UIImage imageNamed:@"line.png"];
                imgLine2.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine2];

                baseYCordinate = baseYCordinate + 10;

                //Mode
                UILabel *lblMode = [[UILabel alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 100, 30)];
                lblMode.textColor = [UIColor whiteColor];
                [lblMode setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblMode.text = @"Thermostat";
                [belowBackgroundLabel addSubview:lblMode];

                //Font for segment control
                UIFont *font = [UIFont fontWithName:@"Avenir-Heavy" size:12];
                NSDictionary *attributes = @{NSFontAttributeName : font};

                UISegmentedControl *scMode = [[UISegmentedControl alloc] initWithItems:@[@"Auto", @"Heat", @"Cool", @"Off"]];
                scMode.frame = CGRectMake(self.tableView.frame.size.width - 220, baseYCordinate, 180, 20);
                scMode.tag = indexPathRow;
                scMode.tintColor = [UIColor whiteColor];
                [scMode addTarget:self action:@selector(modeSelected:) forControlEvents:UIControlEventValueChanged];
                [scMode setTitleTextAttributes:attributes forState:UIControlStateNormal];
                [belowBackgroundLabel addSubview:scMode];

                baseYCordinate += 30;
                UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                imgLine3.image = [UIImage imageNamed:@"line.png"];
                imgLine3.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine3];

                baseYCordinate = baseYCordinate + 10;

                //Fan Mode
                UILabel *lblFanMode = [[UILabel alloc] initWithFrame:CGRectMake(10.0, baseYCordinate - 5, 60, 30)];
                lblFanMode.textColor = [UIColor whiteColor];
                [lblFanMode setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblFanMode.text = @"Fan";
                [belowBackgroundLabel addSubview:lblFanMode];

                UISegmentedControl *scFanMode = [[UISegmentedControl alloc] initWithItems:@[@"Auto Low", @"On Low"]];
                scFanMode.frame = CGRectMake(self.tableView.frame.size.width - 190, baseYCordinate, 150, 20);
                scFanMode.tag = indexPathRow;

                [scFanMode setTitleTextAttributes:attributes forState:UIControlStateNormal];
                [scFanMode addTarget:self action:@selector(fanModeSelected:) forControlEvents:UIControlEventValueChanged];
                scFanMode.tintColor = [UIColor whiteColor];
                [belowBackgroundLabel addSubview:scFanMode];

                baseYCordinate += 30;
                UIImageView *imgLine4 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                imgLine4.image = [UIImage imageNamed:@"line.png"];
                imgLine4.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine4];

                baseYCordinate = baseYCordinate + 5;


                //Status
                UILabel *lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(10.0, baseYCordinate, 60, 30)];
                lblStatus.textColor = [UIColor whiteColor];
                [lblStatus setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblStatus.text = @"Status";

                [belowBackgroundLabel addSubview:lblStatus];

                //baseYCordinate+=25;

                //Operating state
                UILabel *lblOperatingState = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 250, baseYCordinate, 220, 30)];
                lblOperatingState.textColor = [UIColor whiteColor];
                lblOperatingState.backgroundColor = [UIColor clearColor];
                [lblOperatingState setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                lblOperatingState.textAlignment = NSTextAlignmentRight;
                [belowBackgroundLabel addSubview:lblOperatingState];

                baseYCordinate += 25;
//                UIImageView *imgLine5 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                imgLine5.image = [UIImage imageNamed:@"line.png"];
//                imgLine5.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine5];
//                
//                baseYCordinate = baseYCordinate+10;

//                //Fan State
//                UILabel *lblFanState = [[UILabel alloc]initWithFrame:CGRectMake(10.0, baseYCordinate-5, 200, 30)];
//                lblFanState.textColor = [UIColor whiteColor];
//                [lblFanState setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:lblFanState];
//                
//                baseYCordinate+=25;
//                UIImageView *imgLine6 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                imgLine6.image = [UIImage imageNamed:@"line.png"];
//                imgLine6.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine6];
//                
//                baseYCordinate = baseYCordinate+10;

                //Battery
                UILabel *lblBattery = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 250, baseYCordinate - 5, 220, 30)];
                lblBattery.textColor = [UIColor whiteColor];
                [lblBattery setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                [lblBattery setBackgroundColor:[UIColor clearColor]];
                lblBattery.textAlignment = NSTextAlignmentRight;
                [belowBackgroundLabel addSubview:lblBattery];

                baseYCordinate += 25;
                UIImageView *imgLine7 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                imgLine7.image = [UIImage imageNamed:@"line.png"];
                imgLine7.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine7];

                baseYCordinate = baseYCordinate + 5;

                //Set slider value
                float currentHeatingSliderValue = 0.0;
                float currentCoolingSliderValue = 0.0;

                NSMutableString *strState = [[NSMutableString alloc] init];

                NSArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];
                for (currentDeviceValue in currentKnownValues) {
                    //Get slider value
                    if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT SETPOINT HEATING"]) {
                        currentHeatingSliderValue = [currentDeviceValue.value floatValue];
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT SETPOINT COOLING"]) {
                        currentCoolingSliderValue = [currentDeviceValue.value floatValue];
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT MODE"]) {
                        if ([currentDeviceValue.value isEqualToString:@"Auto"]) {
                            scMode.selectedSegmentIndex = 0;
                        }
                        else if ([currentDeviceValue.value isEqualToString:@"Heat"]) {
                            scMode.selectedSegmentIndex = 1;
                        }
                        else if ([currentDeviceValue.value isEqualToString:@"Cool"]) {
                            scMode.selectedSegmentIndex = 2;
                        }
                        else if ([currentDeviceValue.value isEqualToString:@"Off"]) {
                            scMode.selectedSegmentIndex = 3;
                        }
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT OPERATING STATE"]) {
//                        lblOperatingState.text = [NSString stringWithFormat:@"Operating State is %@", currentDeviceValue.value];
                        [strState appendString:[NSString stringWithFormat:@"Thermostat is %@. ", currentDeviceValue.value]];
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT FAN MODE"]) {
                        if ([currentDeviceValue.value isEqualToString:@"Auto Low"]) {
                            scFanMode.selectedSegmentIndex = 0;
                        }
                        else {
                            scFanMode.selectedSegmentIndex = 1;
                        }
//                        lblFanMode.text = [NSString stringWithFormat:@"Fan Mode %@", currentDeviceValue.value];
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"THERMOSTAT FAN STATE"]) {
//                        lblFanState.text = [NSString stringWithFormat:@"Fan State is %@", currentDeviceValue.value];
                        [strState appendString:[NSString stringWithFormat:@"Fan is %@.", currentDeviceValue.value]];
                    }
                    else if ([currentDeviceValue.valueName isEqualToString:@"BATTERY"]) {
                        lblBattery.text = [NSString stringWithFormat:@"Battery is at %@%%.", currentDeviceValue.value];
                    }

                }

                lblOperatingState.text = strState;

                [heatSlider setValue:currentHeatingSliderValue animated:YES];
                [coolSlider setValue:currentCoolingSliderValue animated:YES];

                break;
            }
            case 11:{
                //Motion Sensor
                if(currentSensor.isTampered){
                    baseYCordinate = baseYCordinate+25;
                    expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc]init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self action:@selector(onDismissTamper:) forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal ];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate+6, 65,20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate+=35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate+5;

//                    if (currentSensor.isBatteryLow){
//                        //baseYCordinate = baseYCordinate+25;
//                        self.expandedRowHeight = self.expandedRowHeight + 20;
//                        expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate-5, 200, 30)];
//                        expandedLblText.text = BATTERY_IS_LOW;
//                        expandedLblText.textColor = [UIColor whiteColor];
//                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                        [belowBackgroundLabel addSubview:expandedLblText];
//                        
//                        baseYCordinate+=25;
//                        UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                        imgLine.image = [UIImage imageNamed:@"line.png"];
//                        imgLine.alpha = 0.5;
//                        [belowBackgroundLabel addSubview:imgLine];
//                        
//                        baseYCordinate = baseYCordinate+5;
//                    }
                }
                else{
                    baseYCordinate = baseYCordinate+25;
//                    if (currentSensor.isBatteryLow){
//                        //baseYCordinate = baseYCordinate+25;
//                       self.expandedRowHeight =self.expandedRowHeight + 40;
//                        expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, baseYCordinate-5, 200, 30)];
//                        expandedLblText.text = BATTERY_IS_LOW;
//                        expandedLblText.textColor = [UIColor whiteColor];
//                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                        [belowBackgroundLabel addSubview:expandedLblText];
//                        
//                        baseYCordinate+=25;
//                        UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                        imgLine.image = [UIImage imageNamed:@"line.png"];
//                        imgLine.alpha = 0.5;
//                        [belowBackgroundLabel addSubview:imgLine];
//                        
//                        baseYCordinate = baseYCordinate+5;
//                    }
                }
                break;
            }
            case 12: {
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self action:@selector(onDismissTamper:) forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                //Do not display the most important one
//                for(int i =0; i < [currentKnownValues count]; i++){
//                    // if(i!= currentSensor.mostImpValueIndex ){
//                    
//                    currentDeviceValue = [currentKnownValues objectAtIndex:i];
//                    //Display only battery - PY 291113
//                    NSString *batteryStatus;
//                    if([currentDeviceValue.valueName isEqualToString:@"LOW BATTERY"]){
//                        expandedLblText = [[UILabel alloc]init];
//                        [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                        //Check the status of value
//                        if([currentValue isEqualToString:@"1"]){
//                            //Battery Low
//                            batteryStatus = @"Low Battery";
//                        }else{
//                            //Battery OK
//                            batteryStatus = @"Battery OK";
//                        }
//                        expandedLblText.text = batteryStatus;
//                        expandedLblText.textColor = [UIColor whiteColor];
//                        [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                        
//                        //// NSLog(@"Y Cordinate %f", baseYCordinate);
//                        expandedLblText.frame = CGRectMake(10,baseYCordinate-5,299,30);
//                        [belowBackgroundLabel addSubview:expandedLblText];
//                    }
//                    
//                    
//                    //                    expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
//                    
//                    // }
//                }

//                baseYCordinate+=25;
//                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
//                imgLine.image = [UIImage imageNamed:@"line.png"];
//                imgLine.alpha = 0.5;
//                [belowBackgroundLabel addSubview:imgLine];
//                
//                baseYCordinate = baseYCordinate+5;

//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                //Display Location - PY 291113
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 13: {
                //Fire Sensor
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self action:@selector(onDismissTamper:) forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                break;
            }
            case 14: {
                //Water Sensor
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self action:@selector(onDismissTamper:) forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
//                    [[btnDismiss layer] setBorderWidth:1.0f];
//                    [[btnDismiss layer] setBorderColor:[UIColor colorWithHue:0/360.0 saturation:0/100.0 brightness:100/100.0 alpha:0.6].CGColor];

                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                break;
            }
            case 15: {
                //Gas Sensor
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self action:@selector(onDismissTamper:) forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                break;
            }
            case 17: {
                //Vibration Sensor
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self action:@selector(onDismissTamper:) forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                break;
            }
            case 19: {
                //KeyFob
                if (currentSensor.isTampered) {
                    baseYCordinate = baseYCordinate + 25;
                    expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 200, 30)];
                    expandedLblText.text = DEVICE_TAMPERED;
                    expandedLblText.textColor = [UIColor whiteColor];
                    [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    [belowBackgroundLabel addSubview:expandedLblText];

                    UIButton *btnDismiss = [[UIButton alloc] init];
                    btnDismiss.backgroundColor = [UIColor clearColor];
                    [btnDismiss addTarget:self action:@selector(onDismissTamper:) forControlEvents:UIControlEventTouchDown];
                    [btnDismiss setTitle:@"Dismiss" forState:UIControlStateNormal];
//                    [btnDismiss setTitleColor:[UIColor colorWithHue:changeHue/360.0 saturation:changeSaturation/100.0 brightness:changeBrightness/100.0 alpha:1] forState:UIControlStateNormal ];
                    [btnDismiss setTitleColor:[UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (100 / 100.0) alpha:0.6] forState:UIControlStateNormal];
                    [btnDismiss.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                    btnDismiss.frame = CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate + 6, 65, 20);
                    btnDismiss.tag = indexPathRow;
                    [belowBackgroundLabel addSubview:btnDismiss];

                    baseYCordinate += 35;
                    UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                    imgLine.image = [UIImage imageNamed:@"line.png"];
                    imgLine.alpha = 0.5;
                    [belowBackgroundLabel addSubview:imgLine];

                    baseYCordinate = baseYCordinate + 5;
                }
                else {
                    baseYCordinate = baseYCordinate + 25;
                }
                break;
            }
            case 22: {
                //Show values and calculations
                //Calculate values
                unsigned int activePower = 0;
                unsigned int acPowerMultiplier = 0;
                unsigned int acPowerDivisor = 0;
                unsigned int rmsVoltage = 0;
                unsigned int acVoltageMultipier = 0;
                unsigned int acVoltageDivisor = 0;
                unsigned int rmsCurrent = 0;
                unsigned int acCurrentMultipier = 0;
                unsigned int acCurrentDivisor = 0;

                NSString *currentDeviceTypeName;
                NSString *hexString;

                NSArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];
                for (currentDeviceValue in currentKnownValues) {
                    currentDeviceTypeName = currentDeviceValue.valueName;
                    hexString = currentDeviceValue.value;
                    //                          NSString *hexIP = [NSString stringWithFormat:@"%lX", (long)[currentDevice.deviceIP integerValue]];
                    //							hexString = hexString.substring(2);
                    // NSLog(@"HEX STRING: %@", hexString);
                    NSScanner *scanner = [NSScanner scannerWithString:hexString];

                    if ([currentDeviceTypeName isEqualToString:@"ACTIVE_POWER"]) {
                        [scanner scanHexInt:&activePower];
                        //activePower = Integer.parseInt(hexString, 16);
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"AC_POWERMULTIPLIER"]) {
                        [scanner scanHexInt:&acPowerMultiplier];
                        //acPowerMultiplier = Integer.parseInt(hexString, 16);
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"AC_POWERDIVISOR"]) {
                        [scanner scanHexInt:&acPowerDivisor];
                        //acPowerDivisor = Integer.parseInt(hexString, 16);
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"RMS_VOLTAGE"]) {
                        [scanner scanHexInt:&rmsVoltage];
                        //rmsVoltage = Integer.parseInt(hexString, 16);
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"AC_VOLTAGEMULTIPLIER"]) {
                        [scanner scanHexInt:&acVoltageMultipier];
                        //acVoltageMultipier = Integer.parseInt(hexString, 16);
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"AC_VOLTAGEDIVISOR"]) {
                        [scanner scanHexInt:&acVoltageDivisor];
                        //acVoltageDivisor = Integer.parseInt(hexString, 16);
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"RMS_CURRENT"]) {
                        [scanner scanHexInt:&rmsCurrent];
                        //rmsCurrent = Integer.parseInt(hexString, 16);
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"AC_CURRENTMULTIPLIER"]) {
                        [scanner scanHexInt:&acCurrentMultipier];
                        //acCurrentMultipier = Integer.parseInt(hexString, 16);
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"AC_CURRENTDIVISOR"]) {
                        [scanner scanHexInt:&acCurrentDivisor];
                        //acCurrentDivisor = Integer.parseInt(hexString, 16);
                    }
                }

                float power = (float) activePower * acPowerMultiplier / acPowerDivisor;
                float voltage = (float) rmsVoltage * acVoltageMultipier / acVoltageDivisor;
                float current = (float) rmsCurrent * acCurrentMultipier / acCurrentDivisor;

                // NSLog(@"Power %f Voltage %f Current %f", power, voltage, current);

                expandedLblText = [[UILabel alloc] init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];

                //Display Power
                expandedLblText.text = [NSString stringWithFormat:@"Power is %.3fW", power];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate + 25;
                expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                [belowBackgroundLabel addSubview:expandedLblText];

                expandedLblText = [[UILabel alloc] init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];

                //Display Voltage
                expandedLblText.text = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate + 25;
                expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                [belowBackgroundLabel addSubview:expandedLblText];


                expandedLblText = [[UILabel alloc] init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];

                //Display Current
                expandedLblText.text = [NSString stringWithFormat:@"Current is %.3fA", current];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate + 25;
                expandedLblText.frame = CGRectMake(10, baseYCordinate, 299, 30);
                [belowBackgroundLabel addSubview:expandedLblText];

                baseYCordinate += 25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];

                baseYCordinate = baseYCordinate + 5;

//                expandedLblText =[[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                expandedLblText = [[UILabel alloc]init];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //Display Location
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                baseYCordinate = baseYCordinate+25;
//                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
            }
            case 23:
            {
                //Electric Measure - DC
                //Show values and calculations
                //Calculate values
                unsigned int dcPower = 0;
                unsigned int dcPowerMultiplier = 0;
                unsigned int dcPowerDivisor  = 0;
                unsigned int dcVoltage = 0;
                unsigned int dcVoltageMultipier = 0;
                unsigned int dcVoltageDivisor = 0;
                unsigned int dcCurrent = 0;
                unsigned int dcCurrentMultipier = 0;
                unsigned int dcCurrentDivisor = 0;

                NSString *currentDeviceTypeName;
                NSString *hexString;

                NSArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];
                for (currentDeviceValue in currentKnownValues) {
                    currentDeviceTypeName = currentDeviceValue.valueName;
                    hexString = currentDeviceValue.value;

                    NSScanner *scanner = [NSScanner scannerWithString:hexString];

                    if ([currentDeviceTypeName isEqualToString:@"DC_POWER"]) {
                        [scanner scanHexInt:&dcPower];
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"DC_POWERMULTIPLIER"]) {
                        [scanner scanHexInt:&dcPowerMultiplier];
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"DC_POWERDIVISOR"]) {
                        [scanner scanHexInt:&dcPowerDivisor];
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"DC_VOLTAGE"]) {
                        [scanner scanHexInt:&dcVoltage];
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"DC_VOLTAGEMULTIPLIER"]) {
                        [scanner scanHexInt:&dcVoltageMultipier];
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"DC_VOLTAGEDIVISOR"]) {
                        [scanner scanHexInt:&dcVoltageDivisor];
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"DC_CURRENT"]) {
                        [scanner scanHexInt:&dcCurrent];
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"DC_CURRENTMULTIPLIER"]) {
                        [scanner scanHexInt:&dcCurrentMultipier];
                    }
                    else if ([currentDeviceTypeName isEqualToString:@"DC_CURRENTDIVISOR"]) {
                        [scanner scanHexInt:&dcCurrentDivisor];
                    }
                }

                float power = (float)dcPower * dcPowerMultiplier/dcPowerDivisor;
                float voltage = (float)dcVoltage * dcVoltageMultipier / dcVoltageDivisor;
                float current = (float)dcCurrent * dcCurrentMultipier / dcCurrentDivisor;

                // NSLog(@"Power %f Voltage %f Current %f", power, voltage, current);

                expandedLblText = [[UILabel alloc]init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];

                //Display Power
                expandedLblText.text = [NSString stringWithFormat:@"Power is %.3fW", power];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate+25;
                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                [belowBackgroundLabel addSubview:expandedLblText];

                expandedLblText = [[UILabel alloc]init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];

                //Display Voltage
                expandedLblText.text = [NSString stringWithFormat:@"Voltage is %.3fV", voltage];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate+25;
                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                [belowBackgroundLabel addSubview:expandedLblText];


                expandedLblText = [[UILabel alloc]init];
                [expandedLblText setBackgroundColor:[UIColor clearColor]];

                //Display Current
                expandedLblText.text = [NSString stringWithFormat:@"Current is %.3fA", current];
                expandedLblText.textColor = [UIColor whiteColor];
                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
                baseYCordinate = baseYCordinate+25;
                expandedLblText.frame = CGRectMake(10,baseYCordinate,299,30);
                [belowBackgroundLabel addSubview:expandedLblText];

                baseYCordinate+=25;
                UIImageView *imgLine = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width-35, 1)];
                imgLine.image = [UIImage imageNamed:@"line.png"];
                imgLine.alpha = 0.5;
                [belowBackgroundLabel addSubview:imgLine];

                baseYCordinate = baseYCordinate+5;

                break;
            }
            case 26:{
                //Window Covering
                baseYCordinate = baseYCordinate+25;
                break;
            }
            case 27:{
                //Temperature Sensor
                baseYCordinate = baseYCordinate+25;
                break;
            }
            case 34:{
                //Shade
                baseYCordinate = baseYCordinate+25;
                break;
            }
            default:
                baseYCordinate+=25;
//                self.expandedRowHeight = 160;
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                
//                //Display Name
//                expandedLblText.text = [NSString stringWithFormat:@"Name: %@", currentSensor.deviceName];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
//                
//                
//                expandedLblText = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 299, 30)];
//                [expandedLblText setBackgroundColor:[UIColor clearColor]];
//                //               currentDeviceValue = [currentKnownValues objectAtIndex:0];
//                //                expandedLblText.text = [NSString stringWithFormat:@"%@:  %@", currentDeviceValue.valueName, currentDeviceValue.value];
//                //Display Location - PY 291113
//                expandedLblText.text = [NSString stringWithFormat:@"Location: %@", currentSensor.location];
//                expandedLblText.textColor = [UIColor whiteColor];
//                [expandedLblText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
//                [belowBackgroundLabel addSubview:expandedLblText];
                break;
        }

        //Settings for all the sensors
        expandedLblText = [[UILabel alloc] init];
        expandedLblText.backgroundColor = [UIColor clearColor];
        expandedLblText.textColor = [UIColor whiteColor];
        expandedLblText.font = [UIFont fontWithName:@"Avenir-Heavy" size:12];

        expandedLblText.frame = CGRectMake(10, baseYCordinate - 5, 299, 30);
        expandedLblText.text = [NSString stringWithFormat:@"SENSOR SETTINGS"];
        [belowBackgroundLabel addSubview:expandedLblText];

        baseYCordinate = baseYCordinate + 25;

        UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine1.image = [UIImage imageNamed:@"line.png"];
        imgLine1.alpha = 0.5;
        [belowBackgroundLabel addSubview:imgLine1];

        //Display Name
        baseYCordinate = baseYCordinate + 5;
        expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 100, 30)];
        expandedLblText.text = @"Name";
        expandedLblText.backgroundColor = [UIColor clearColor];
        expandedLblText.textColor = [UIColor whiteColor];
        expandedLblText.font = heavy_font;
        [belowBackgroundLabel addSubview:expandedLblText];

//        baseYCordinate = baseYCordinate+25;
        UITextField *tfName = [[UITextField alloc] initWithFrame:CGRectMake(110, baseYCordinate, self.tableView.frame.size.width - 150, 30)];
        tfName.text = currentSensor.deviceName;
        tfName.textAlignment = NSTextAlignmentRight;
        tfName.textColor = [UIColor whiteColor];
        tfName.font = heavy_font;
        tfName.tag = indexPathRow;
        [tfName setReturnKeyType:UIReturnKeyDone];
        [tfName addTarget:self action:@selector(sensorNameTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfName addTarget:self action:@selector(sensorNameTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [belowBackgroundLabel addSubview:tfName];

        baseYCordinate = baseYCordinate + 25;
        UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine2.image = [UIImage imageNamed:@"line.png"];
        imgLine2.alpha = 0.5;
        [belowBackgroundLabel addSubview:imgLine2];

        //Display Location - PY 291113
        baseYCordinate = baseYCordinate + 5;
        expandedLblText = [[UILabel alloc] initWithFrame:CGRectMake(10, baseYCordinate, 100, 30)];
        expandedLblText.backgroundColor = [UIColor clearColor];
        expandedLblText.text = @"Located at";
        expandedLblText.textColor = [UIColor whiteColor];
        expandedLblText.font = heavy_font;
        [belowBackgroundLabel addSubview:expandedLblText];

        //baseYCordinate = baseYCordinate+25;
        UITextField *tfLocation = [[UITextField alloc] initWithFrame:CGRectMake(110, baseYCordinate, self.tableView.frame.size.width - 150, 30)];
        tfLocation.text = currentSensor.location;
        tfLocation.textAlignment = NSTextAlignmentRight;
        tfLocation.textColor = [UIColor whiteColor];
        tfLocation.delegate = self;
        tfLocation.font = heavy_font;
        tfLocation.tag = indexPathRow;
        tfLocation.returnKeyType = UIReturnKeyDone;
        [tfLocation addTarget:self action:@selector(sensorLocationTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [tfLocation addTarget:self action:@selector(sensorLocationTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [belowBackgroundLabel addSubview:tfLocation];

        baseYCordinate = baseYCordinate + 25;
        UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, baseYCordinate, self.tableView.frame.size.width - 35, 1)];
        imgLine3.image = [UIImage imageNamed:@"line.png"];
        imgLine3.alpha = 0.5;
        [belowBackgroundLabel addSubview:imgLine3];

        baseYCordinate = baseYCordinate + 10;
        UIButton *btnSave = [[SFIHighlightedButton alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 100, baseYCordinate, 65, 30)];
        btnSave.backgroundColor = [UIColor whiteColor];
        btnSave.titleLabel.font = heavy_font;
        btnSave.tag = indexPathRow;
        [btnSave addTarget:self action:@selector(onSaveSensorData:) forControlEvents:UIControlEventTouchUpInside];
        [btnSave setTitle:@"Save" forState:UIControlStateNormal];
        [btnSave setTitleColor:[self makeStandardBlue] forState:UIControlStateNormal];
        [belowBackgroundLabel addSubview:btnSave];

        NSUInteger rowHeight = [self computeSensorRowHeight:currentSensor];

        belowBackgroundLabel.frame = CGRectMake(10, 86, (LEFT_LABEL_WIDTH) + (self.tableView.frame.size.width - LEFT_LABEL_WIDTH - 25) + 1, rowHeight - SENSOR_ROW_HEIGHT);
        [cell addSubview:belowBackgroundLabel];
    }

    [cell addSubview:imgSettings];

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
    return [self.deviceList objectAtIndex:row];
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSUInteger row = (NSUInteger) fromIndexPath.row;

    id object = [self.deviceList objectAtIndex:row];

    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.deviceList];
    [temp removeObjectAtIndex:row];
    [temp insertObject:object atIndex:(NSUInteger) toIndexPath.row];

    self.deviceList = [NSArray arrayWithArray:temp];
}


// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.
- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath; {
    // do nothing
}

#pragma mark - Class Methods

- (IBAction)revealMenu:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)revealTab:(id)sender {
    if (!self.isSliderExpanded) {
        [self.slidingViewController anchorTopViewTo:ECRight];
    }
}

- (void)initializeImages {
    int currentDeviceType;
    SFIDeviceKnownValues *currentDeviceValue;
    NSString *currentValue;
    NSString *currentDeviceTypeName;

    int currentDeviceId;

    for (SFIDevice *currentSensor in self.deviceList) {
        currentDeviceType = currentSensor.deviceType;
        currentDeviceId = currentSensor.deviceID;
        // NSLog(@"Device Type: %d", currentDeviceType);

        NSMutableArray *currentKnownValues = [self currentKnownValuesForDevice:currentDeviceId];

        switch (currentDeviceType) {
            case 1: {
                currentDeviceValue = currentKnownValues[0];
                currentValue = currentDeviceValue.value;
                // NSLog(@"Case1 : Device Value: %@", currentValue);
                if ([currentValue isEqualToString:@"true"]) {
                    currentSensor.imageName = DT1_BINARY_SWITCH_TRUE;
                }
                else if ([currentValue isEqualToString:@"false"]) {
                    currentSensor.imageName = DT1_BINARY_SWITCH_FALSE;
                }
                else {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                break;
            }

            case 2: {
                //Multilevel switch
                // NSLog(@"Case2 : Device Value Count %d", [currentKnownValues count]);

                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (int i = 0; i < [currentKnownValues count]; i++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;

                    if ([currentDeviceTypeName isEqualToString:@"SWITCH MULTILEVEL"]) {
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        currentSensor.imageName = [currentValue isEqualToString:@"0"] ? DT4_LEVEL_CONTROL_FALSE : DT4_LEVEL_CONTROL_TRUE;
                    }
                    break;
                }
                break;
            }

            case 3: {
                // NSLog(@"Case3 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }

                for (int i = 0; i < [currentKnownValues count]; i++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    if ([currentDeviceTypeName isEqualToString:@"SENSOR BINARY"]) {
                        currentSensor.stateIndex = i;

                        // // NSLog(@"State %@", currentValue);
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        currentSensor.imageName = [curDeviceValues.value boolValue] ? DT3_BINARY_SENSOR_TRUE : DT3_BINARY_SENSOR_FALSE;
                    }
                }

                break;
            }

            case 4: {
                //Level Control
                // NSLog(@"Case4 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (int i = 0; i < [currentKnownValues count]; i++) {
                    SFIDeviceKnownValues *curDeviceValues;
                    curDeviceValues = [currentKnownValues objectAtIndex:(NSUInteger) i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case4 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if ([currentDeviceTypeName isEqualToString:@"SWITCH BINARY"]) {
                        currentSensor.stateIndex = i;

                        if ([currentValue isEqualToString:@"true"]) {
                            currentSensor.imageName = DT2_MULTILEVEL_SWITCH_TRUE;
                        }
                        else if ([currentValue isEqualToString:@"false"]) {
                            currentSensor.imageName = DT2_MULTILEVEL_SWITCH_FALSE;
                        }
                        else {
                            currentSensor.imageName = @"Reload_icon.png";
                        }

                    }
                    else if ([currentDeviceTypeName isEqualToString:@"SWITCH MULTILEVEL"]) {
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                    }
                }
                break;
            }

            case 5: {
                //Door Lock
                // NSLog(@"Case5 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }

                for (int i = 0; i < [currentKnownValues count]; i++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case5 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if ([currentDeviceTypeName isEqualToString:@"DOOR LOCK "]) {
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;

                        if ([currentValue isEqualToString:@"true"]) {
                            currentSensor.imageName = DT5_DOOR_LOCK_TRUE;
                        }
                        else if ([currentValue isEqualToString:@"false"]) {
                            currentSensor.imageName = DT5_DOOR_LOCK_FALSE;
                        }
                        else {
                            currentSensor.imageName = @"Reload_icon.png";
                        }
                    }
                }
                break;
            }
            case 6: {
                //Alarm : TODO Later
                // NSLog(@"Case6 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (int i = 0; i < [currentKnownValues count]; i++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) i];
                    currentDeviceTypeName = curDeviceValues.valueName;

                    // NSLog(@"Case6 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if ([currentDeviceTypeName isEqualToString:@"LOCK_STATE"]) {
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        currentSensor.imageName = [curDeviceValues.value boolValue] ? DT6_ALARM_TRUE : DT6_ALARM_FALSE;
                    }
                }
                break;
            }

            case 11: {
                //Motion Sensor
                // NSLog(@"Case11 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (
                        int index = 0; index < [currentKnownValues count]; index++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) index];
                    currentDeviceTypeName = curDeviceValues.valueName;

                    // NSLog(@"Case11 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if ([currentDeviceTypeName isEqualToString:STATE]) {
                        currentSensor.stateIndex = index;
                        currentSensor.mostImpValueIndex = index;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        currentSensor.imageName = [curDeviceValues.value boolValue] ? DT11_MOTION_SENSOR_TRUE : DT11_MOTION_SENSOR_FALSE;
                    }
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]) {
                        currentSensor.isTampered = [curDeviceValues.value boolValue];
                        currentSensor.tamperValueIndex = index;
                    }
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]) {
                        currentSensor.isBatteryLow = [curDeviceValues.value boolValue];
                    }
                }
                break;
            }

            case 12: {
                NSLog(@"Contact switch sensor: %@", currentSensor);
                //Contact Switch
                // NSLog(@"Case12 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }

                for (int index = 0; index < [currentKnownValues count]; index++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) index];

                    currentDeviceTypeName = curDeviceValues.valueName;
//                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case12 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);

                    if ([currentDeviceTypeName isEqualToString:STATE]) {
                        currentSensor.stateIndex = index;
                        currentSensor.mostImpValueIndex = index;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        currentSensor.imageName = [curDeviceValues.value boolValue] ? DT12_CONTACT_SWITCH_TRUE : DT12_CONTACT_SWITCH_FALSE;
                    }
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]) {
                        currentSensor.isTampered = [curDeviceValues.value boolValue];
                        currentSensor.tamperValueIndex = index;
                    }
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]) {
                        currentSensor.isBatteryLow = [curDeviceValues.value boolValue];
                    }
                }
                break;
            }

            case 13: {
                //Fire Sensor
                // NSLog(@"Case13 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (int index = 0; index < [currentKnownValues count]; index++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) index];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    // NSLog(@"Case13 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if ([currentDeviceTypeName isEqualToString:STATE]) {
                        currentSensor.stateIndex = index;
                        currentSensor.mostImpValueIndex = index;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        currentSensor.imageName = [curDeviceValues.value boolValue] ? DT13_FIRE_SENSOR_TRUE : DT13_FIRE_SENSOR_FALSE;
                    }
                        //PY 170214 - Tamper Handling
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]) {
                        currentSensor.isTampered = [curDeviceValues.value boolValue];
                        currentSensor.tamperValueIndex = index;
                    }
                        //PY 180214 - Low Battery Handling
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]) {
                        currentSensor.isBatteryLow = [curDeviceValues.value boolValue];
                    }
                }
                break;
            }

            case 14: {
                //Water Sensor
                // NSLog(@"Case14 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (int index = 0; index < [currentKnownValues count]; index++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) index];
                    currentDeviceTypeName = curDeviceValues.valueName;

                    if ([currentDeviceTypeName isEqualToString:STATE]) {
                        currentSensor.stateIndex = index;
                        currentSensor.mostImpValueIndex = index;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        currentSensor.imageName = [curDeviceValues.value boolValue] ? DT14_WATER_SENSOR_TRUE : DT14_WATER_SENSOR_FALSE;
                    }
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]) {
                        currentSensor.isTampered = [curDeviceValues.value boolValue];
                        currentSensor.tamperValueIndex = index;
                    }
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]) {
                        currentSensor.isBatteryLow = [curDeviceValues.value boolValue];
                    }
                }
                break;
            }

            case 15: {
                //Gas Sensor
                // NSLog(@"Case15 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (int index = 0; index < [currentKnownValues count]; index++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) index];
                    currentDeviceTypeName = curDeviceValues.valueName;

                    if ([currentDeviceTypeName isEqualToString:STATE]) {
                        currentSensor.stateIndex = index;
                        currentSensor.mostImpValueIndex = index;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        currentSensor.imageName = [curDeviceValues.value boolValue] ? DT15_GAS_SENSOR_TRUE : DT15_GAS_SENSOR_FALSE;
                    }
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]) {
                        currentSensor.isTampered = [curDeviceValues.value boolValue];
                        currentSensor.tamperValueIndex = index;
                    }
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]) {
                        currentSensor.isBatteryLow = [curDeviceValues.value boolValue];
                    }
                }
                break;
            }

            case 17: {
                //Vibration Sensor
                // NSLog(@"Case17 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (int index = 0; index < [currentKnownValues count]; index++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) index];
                    currentDeviceTypeName = curDeviceValues.valueName;

                    // NSLog(@"Case17 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if ([currentDeviceTypeName isEqualToString:STATE]) {
                        currentSensor.stateIndex = index;
                        currentSensor.mostImpValueIndex = index;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        currentSensor.imageName = [curDeviceValues.value boolValue] ? DT17_VIBRATION_SENSOR_TRUE : DT17_VIBRATION_SENSOR_FALSE;
                    }
                        //PY 170214 - Tamper Handling
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]) {
                        currentSensor.isTampered = [curDeviceValues.value boolValue];
                        currentSensor.tamperValueIndex = index;
                    }
                        //PY 180214 - Low Battery Handling
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]) {
                        currentSensor.isBatteryLow = [curDeviceValues.value boolValue];
                    }
                }
                break;
            }

            case 19: {
                //Keyfob
                // NSLog(@"Case19 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (int index = 0; index < [currentKnownValues count]; index++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) index];
                    currentDeviceTypeName = curDeviceValues.valueName;

                    if ([currentDeviceTypeName isEqualToString:STATE]) {
                        currentSensor.stateIndex = index;
                        currentSensor.mostImpValueIndex = index;
                        currentSensor.mostImpValueName = currentDeviceTypeName;
                        currentSensor.imageName = [curDeviceValues.value boolValue] ? DT19_KEYFOB_TRUE : DT19_KEYFOB_FALSE;
                    }
                    else if ([currentDeviceTypeName isEqualToString:TAMPER]) {
                        currentSensor.isTampered = [curDeviceValues.value boolValue];
                        currentSensor.tamperValueIndex = index;
                    }
                    else if ([currentDeviceTypeName isEqualToString:LOW_BATTERY]) {
                        currentSensor.isBatteryLow = [curDeviceValues.value boolValue];
                    }
                }

                break;
            }

            case 22: {
                //Electric Measurement switch - AC
                // NSLog(@"Case22 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (int i = 0; i < [currentKnownValues count]; i++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case22 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if ([currentDeviceTypeName isEqualToString:@"SWITCH BINARY"]) {
                        currentSensor.stateIndex = i;

                        // // NSLog(@"State %@", currentValue);
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;

                        if ([currentValue isEqualToString:@"true"]) {
                            currentSensor.imageName = DT22_AC_SWITCH_TRUE;
                        }
                        else if ([currentValue isEqualToString:@"false"]) {
                            currentSensor.imageName = DT22_AC_SWITCH_FALSE;
                        }
                        else {
                            currentSensor.imageName = @"Reload_icon.png";
                        }

                    }
                }
                break;
            }

            case 23: {
                //Electric Measurement switch - DC
                // NSLog(@"Case23 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (
                        int i = 0; i < [currentKnownValues count]; i++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case23 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if ([currentDeviceTypeName isEqualToString:@"SWITCH BINARY"]) {
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;

                        if ([currentValue isEqualToString:@"true"]) {
                            currentSensor.imageName = DT23_DC_SWITCH_TRUE;
                        }
                        else if ([currentValue isEqualToString:@"false"]) {
                            currentSensor.imageName = DT23_DC_SWITCH_FALSE;
                        }
                        else {
                            currentSensor.imageName = @"Reload_icon.png";
                        }

                    }
                }
                break;
            }

            case 34: {
                //Shade
                // NSLog(@"Case34 : Device Value Count %d", [currentKnownValues count]);
                if ([currentKnownValues count] == 0) {
                    currentSensor.imageName = @"Reload_icon.png";
                }
                for (int i = 0; i < [currentKnownValues count]; i++) {
                    SFIDeviceKnownValues *curDeviceValues = currentKnownValues[(NSUInteger) i];
                    currentDeviceTypeName = curDeviceValues.valueName;
                    currentValue = curDeviceValues.value;
                    // NSLog(@"Case34 : Device Value: %@ => %@", currentDeviceTypeName, currentValue);
                    if ([currentDeviceTypeName isEqualToString:@"SWITCH BINARY"]) {
                        currentSensor.stateIndex = i;
                        currentSensor.mostImpValueIndex = i;
                        currentSensor.mostImpValueName = currentDeviceTypeName;

                        if ([currentValue isEqualToString:@"true"]) {
                            currentSensor.imageName = DT34_SHADE_TRUE;
                        }
                        else if ([currentValue isEqualToString:@"false"]) {
                            currentSensor.imageName = DT34_SHADE_FALSE;
                        }
                        else {
                            currentSensor.imageName = @"Reload_icon.png";
                        }

                    }
                }
                break;
            }

            default: {
                currentSensor.imageName = @"default_device.png";
                break;
            }
        }
    }
}

- (void)onSettingClicked:(id)sender {
    UIButton *btn = (UIButton *) sender;
    NSUInteger clicked_row = (NSUInteger) btn.tag;

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
                self.sensorTable.canReorder = FALSE;
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
                self.sensorTable.canReorder = FALSE;
                break;

            default:
                break;
        }
        sensor.isExpanded = FALSE;
    }

    NSMutableArray *pathes = [NSMutableArray array];
    [pathes addObject:[NSIndexPath indexPathForRow:clicked_row inSection:0]];

    // Ensure other rows are not expanded
    for (NSUInteger index=0; index < devices.count; index++) {
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
    NSUInteger sensor_pos = (NSUInteger) button.tag;

    SFIDevice *sensor = self.deviceList[sensor_pos];
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

    SFIDevice *currentSensor = self.deviceList[(NSUInteger) btn.tag];
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
                // NSLog(@"Change to OFF");
                currentDeviceValue.value = @"false";
                //currentSensor.imageName = @"switch_off.png";
                //imgDevice.image = [UIImage imageNamed:@"bulb_on.png"];
                self.currentValue = @"false";
            }
            else if ([currentValue isEqualToString:@"false"]) {
                // NSLog(@"Change to ON");
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
                // NSLog(@"Change to ON - Set value as 99");
                currentDeviceValue.value = @"99";
                self.currentValue = @"99";
            }
            else {
                // NSLog(@"Change to OFF - Set value as 0");
                currentDeviceValue.value = @"0";
                self.currentValue = @"0";
            }
//            }else if([currentValue isEqualToString:@"false"]){
//                // NSLog(@"Change to ON");
//                currentDeviceValue.value = @"true";
//                self.currentValue = @"true";
//            }
//            else{
//                return;
//            }

            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            // NSLog(@"Index ID %d", self.currentIndexID);
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
                [self initializeImages];
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
                // NSLog(@"Change to OFF");
                currentDeviceValue.value = @"false";
                self.currentValue = @"false";
            }
            else if ([currentValue isEqualToString:@"false"]) {
                // NSLog(@"Change to ON");
                currentDeviceValue.value = @"true";
                self.currentValue = @"true";
            }
            else {
                return;
            }

            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            // NSLog(@"Index ID %d", self.currentIndexID);
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
                // NSLog(@"Change to OFF");
                currentDeviceValue.value = @"false";
                self.currentValue = @"false";
            }
            else if ([currentValue isEqualToString:@"false"]) {
                // NSLog(@"Change to ON");
                currentDeviceValue.value = @"true";
                self.currentValue = @"true";
            }
            else {
                return;
            }

            currentSensor.imageName = @"Wait_Icon.png";
            self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
            self.currentIndexID = currentDeviceValue.index;
            // NSLog(@"Index ID %d", self.currentIndexID);
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

- (void)refreshDataForAlmond {
    if ([self isNoAlmondMAC]) {
        return;
    }

    self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
    self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
    self.offlineHash = [SFIOfflineDataManager readHashList:self.currentMAC];

    //Call command : Get HASH - Command 74 - Match if list is up to date
    [self.HUD show:YES];
    [self sendDeviceHashCommand];

    //PY 311013 - Timeout for Sensor Command
    self.sensorDataCommandTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                                   target:self
                                                                 selector:@selector(onLoadSensorDataCommandTimeout:)
                                                                 userInfo:nil
                                                                  repeats:NO];

    [self initializeImages];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];

    self.listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    self.currentColor = self.listAvailableColors[0];

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

- (NSMutableArray *)currentKnownValuesForDevice:(int)deviceId {
    for (SFIDeviceValue *currentDeviceValue in self.deviceValueList) {
        if (deviceId == currentDeviceValue.deviceID) {
            //[SNLog Log:@"%s: ID Match: Selected Device ID is @%d", __PRETTY_FUNCTION__,deviceValueID];
            return currentDeviceValue.knownValues;
        }
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
    UISlider *slider = (UISlider *) gestureRecognizer.view;
    if (slider.highlighted) {
        return;
    } // tap on thumb, let slider deal with it

    CGPoint pt = [gestureRecognizer locationInView:slider];
    CGFloat percentage = pt.x / slider.bounds.size.width;
    CGFloat delta = percentage * (slider.maximumValue - slider.minimumValue);
    CGFloat value = slider.minimumValue + delta;
    [slider setValue:value animated:YES];

    SFIDevice *currentSensor = self.deviceList[(NSUInteger) slider.tag];
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

    [self initializeImages];
    [self asyncReloadTable];
}

- (void)onSensorSliderDidEndSliding:(id)sender valueName:(NSString *)valueName {
    UISlider *slider = (UISlider *) sender;

    SFIDevice *currentSensor = self.deviceList[(NSUInteger) slider.tag];
    int currentDeviceId = currentSensor.deviceID;

    SFIDeviceKnownValues *deviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valueName:valueName];
    deviceValue.value = [NSString stringWithFormat:@"%d", (int) (slider.value)]; //Do not wait for response from Cloud

    self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
    self.currentIndexID = deviceValue.index;
    self.currentValue = deviceValue.value;

    [self sendMobileCommand];

    [self initializeImages];
    [self asyncReloadTable];
}

#pragma mark - Segment Control Method

- (void)modeSelected:(id)sender {
    [self onUpdateSegmentedControlValue:sender valueName:@"THERMOSTAT MODE"];
}

- (void)fanModeSelected:(id)sender {
    [self onUpdateSegmentedControlValue:sender valueName:@"THERMOSTAT FAN MODE"];
}

- (void)onUpdateSegmentedControlValue:(id)sender valueName:(NSString *)valueName {
    UISegmentedControl *ctrl = (UISegmentedControl *) sender;
    NSString *strModeValue = [ctrl titleForSegmentAtIndex:(NSUInteger) ctrl.selectedSegmentIndex];

    SFIDevice *currentSensor = self.deviceList[(NSUInteger) ctrl.tag];
    int currentDeviceId = currentSensor.deviceID;

    SFIDeviceKnownValues *deviceValue = [self tryGetCurrentKnownValuesForDevice:currentDeviceId valueName:valueName];
    deviceValue.value = strModeValue;

    self.currentDeviceID = [NSString stringWithFormat:@"%d", currentDeviceId];
    self.currentIndexID = deviceValue.index;
    self.currentValue = deviceValue.value;

    [self sendMobileCommand];

    [self initializeImages];
    [self asyncReloadTable];
}

#pragma mark - Keyboard methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[[self view] endEditing:YES];
    // NSLog(@"textFieldShouldReturn");
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

- (void)sendDeviceHashCommand {
    DeviceDataHashRequest *deviceHashCommand = [[DeviceDataHashRequest alloc] init];
    deviceHashCommand.almondMAC = self.currentMAC;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = DEVICEDATA_HASH;
    cloudCommand.command = deviceHashCommand;

    [self asyncSendCommand:cloudCommand];
}

-(void)onHashResponseCallback:(id)sender
{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if(data !=nil){
        //[SNLog Log:@"%s: Received Device Hash response", __PRETTY_FUNCTION__];

        NSString *currentHash;

        DeviceDataHashResponse *obj = (DeviceDataHashResponse *)[data valueForKey:@"data"];

        if(obj.isSuccessful){
            //Hash Present
            currentHash = obj.almondHash;
            //[SNLog Log:@"%s: Current Hash ==> @%@ Offline Hash ==> @%@",__PRETTY_FUNCTION__,currentHash, self.offlineHash];
            if(![currentHash isEqualToString:@""] && currentHash!=nil){
                if(![currentHash isEqualToString:@"null"]){
                    if([currentHash isEqualToString:self.offlineHash]){
                        //[SNLog Log:@"%s: Hash Match: Get Device Values", __PRETTY_FUNCTION__];
                        //Get Device Values
                        [self sendDeviceValueCommand];


                    }else{
                        //[SNLog Log:@"%s: Hash MisMatch: Get Device Values", __PRETTY_FUNCTION__];
                        //Save hash in file for each almond
                        [SFIOfflineDataManager writeHashList:currentHash currentMAC:self.currentMAC];
                        //Get Device List
                        [self sendDeviceListCommand];

                    }
                }
                else{

                    //Hash sent by cloud as null - No Device
                    [self.HUD hide:YES];

                    //Open next activity with blank view
                    //                    [HUD hide:YES];
                    //                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                    //                    SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*) [storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceListViewController"];
                    //                    //Remove later - when stored in file
                    //                    // SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*)mainView;
                    //                    //                    deviceListView.deviceList = self.deviceList;
                    //                    //                    deviceListView.deviceValueList = self.deviceValueList;
                    //                    [self.navigationController pushViewController:deviceListView animated:YES];
                }
            }
            else{
                //No Hash from cloud
                self.HUD.hidden = YES;
                //Open next activity with blank view
                //                [HUD hide:YES];
                //                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                //                SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*) [storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceListViewController"];
                //                //Remove later - when stored in file
                //                // SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*)mainView;
                //                //                deviceListView.deviceList = self.deviceList;
                //                //                deviceListView.deviceValueList = self.deviceValueList;
                //                [self.navigationController pushViewController:deviceListView animated:YES];
            }
        }else{
            //success = false
            NSString *reason = obj.reason;
            [SNLog Log:@"%s: Hash Not Found Reason: @%@", __PRETTY_FUNCTION__,reason];
        }

    }
}

- (void)sendDeviceListCommand {
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    DeviceListRequest *deviceListCommand = [[DeviceListRequest alloc] init];
    deviceListCommand.almondMAC = self.currentMAC;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = DEVICEDATA;
    cloudCommand.command = deviceListCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)onDeviceListResponseCallback:(id)sender {
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        //[SNLog Log:@"%s: Received Device List response", __PRETTY_FUNCTION__];

        DeviceListResponse *obj = (DeviceListResponse *) [data valueForKey:@"data"];

        self.deviceList = [[NSMutableArray alloc] init];
        //[SNLog Log:@"%s: List size : %d",__PRETTY_FUNCTION__,[obj.deviceList count]];
        self.deviceList = obj.deviceList;

        //Write offline
        [SFIOfflineDataManager writeDeviceList:self.deviceList currentMAC:self.currentMAC];
        //If count of devicelist is == 0, donot get device value
        //HUD.hidden = YES;
        if ([self isDeviceListEmpty]) {
            return;
        }
        //Get Device Value
        [self sendDeviceValueCommand];
    }

}

- (void)sendDeviceValueCommand {
    DeviceValueRequest *command = [[DeviceValueRequest alloc] init];
    command.almondMAC = self.currentMAC;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = DEVICE_VALUE;
    cloudCommand.command = command;

    [self asyncSendCommand:cloudCommand];
}

- (void)onDeviceValueListResponseCallback:(id)sender {
    self.HUD.hidden = YES;

    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        //[SNLog Log:@"%s: Received Device Value List response", __PRETTY_FUNCTION__];

        DeviceValueResponse *obj = (DeviceValueResponse *) [data valueForKey:@"data"];

        self.deviceValueList = [[NSMutableArray alloc] init];
        //[SNLog Log:@"%s: List size : %d",__PRETTY_FUNCTION__,[obj.deviceValueList count]];
        self.deviceValueList = obj.deviceValueList;

        //Write offline
        [[SecurifiToolkit sharedInstance] writeDeviceValueList:self.deviceValueList currentMAC:self.currentMAC];

        //Reload table
        [self initializeImages];
        // [[self view] endEditing:YES];
        //To remove text fields keyboard. It was throwing error when it was being called from the background thread

        [self asyncReloadTable];

        //TODO: If count of devicevaluelist is < 0, display a message

        //        //Display next screen
        //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        //        SFIDeviceListViewController *deviceListView = (SFIDeviceListViewController*) [storyboard instantiateViewControllerWithIdentifier:@"SFIDeviceListViewController"];
        //        [self.navigationController pushViewController:deviceListView animated:YES];
    }

}

- (void)sendMobileCommand {
    [SNLog Log:@"%s: sendMobileCommand", __PRETTY_FUNCTION__];

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
    [self.mobileCommandTimer invalidate];
    //// NSLog(@"cancelMobileCommand %@", isMobileCommandSuccessful);
    if (!self.isMobileCommandSuccessful) {
        //Cancel the mobile event - Revert back
        self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
        [self initializeImages];

        [self asyncReloadTable];
    }
}

//PY 311013 - Timeout for loading sensor data Command
- (void)onLoadSensorDataCommandTimeout:(id)sender {
    [self.sensorDataCommandTimer invalidate];
    [self.HUD hide:YES];
}

- (void)onMobileCommandResponseCallback:(id)sender {
    // Timeout the commander timer
    [self.mobileCommandTimer invalidate];
    self.isMobileCommandSuccessful = TRUE;

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        MobileCommandResponse *obj = (MobileCommandResponse *) [data valueForKey:@"data"];

        BOOL isSuccessful = obj.isSuccessful;
        if (isSuccessful) {
            int deviceValueID = (int) [self.currentDeviceID integerValue];

            NSArray *currentKnownValues = [self currentKnownValuesForDevice:deviceValueID];
            NSArray *mobileDeviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];

            //To save on the offline list
            NSMutableArray *mobileDeviceKnownValues;
            if (mobileDeviceValueList != nil) {
                for (SFIDeviceValue *currentMobileValue in mobileDeviceValueList) {
                    if (currentMobileValue.deviceID == [self.currentDeviceID integerValue]) {
                        mobileDeviceKnownValues = currentMobileValue.knownValues;
                        for (SFIDeviceKnownValues *currentMobileKnownValue in mobileDeviceKnownValues) {
                            for (SFIDeviceKnownValues *currentLocalKnownValue in currentKnownValues) {
                                if (currentMobileKnownValue.index == currentLocalKnownValue.index) {
                                    [currentMobileKnownValue setValue:currentLocalKnownValue.value];
                                    currentMobileKnownValue.isUpdating = false;
                                    break;
                                }
                            }
                        }
                        [currentMobileValue setKnownValues:mobileDeviceKnownValues];
                    }
                }

                [[SecurifiToolkit sharedInstance] writeDeviceValueList:mobileDeviceValueList currentMAC:self.currentMAC];
            }
        }
    }

    self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
    [self initializeImages];
    [self asyncReloadTable];

}

- (void)onDeviceDataCloudResponseCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        DeviceListResponse *obj = (DeviceListResponse *) [data valueForKey:@"data"];

        BOOL isCurrentMAC = FALSE;
        NSString *cloudMAC = obj.almondMAC;
        [SNLog Log:@"%s: Current MAC ==> @%@ Cloud MAC ==> @%@ DEVICE DATA LIST SIZE: ", __PRETTY_FUNCTION__, self.currentMAC, cloudMAC, [obj.deviceList count]];
        if ([cloudMAC isEqualToString:self.currentMAC]) {
            //Save isExpanded
            for (SFIDevice *currentCloudDevice in obj.deviceList) {
                //[SNLog Log:@"%s: Cloud DeviceID: %d" , __PRETTY_FUNCTION__,currentCloudDevice.deviceID];
                for (SFIDevice *currentMobileDevice in self.deviceList) {
                    //[SNLog Log:@"%s: Mobile DeviceID: %d" , __PRETTY_FUNCTION__,currentMobileDevice.deviceID];
                    if (currentCloudDevice.deviceID == currentMobileDevice.deviceID) {
                        //[SNLog Log:@"%s: Device ID Match - Update isExpanded" , __PRETTY_FUNCTION__];
                        currentCloudDevice.isExpanded = currentMobileDevice.isExpanded;
                    }
                }
            }

            //self.deviceList = obj.deviceList;
            //            if([self isDeviceListEmpty]){
            //                self.isEmpty = TRUE;
            //            }else{
            //                self.isEmpty = FALSE;
            //            }
            isCurrentMAC = TRUE;
            [SFIOfflineDataManager writeDeviceList:obj.deviceList currentMAC:self.currentMAC];

        }

        //TODO: get only hash and update it
        //[self getDeviceHash];

        //Run in background
        //        dispatch_queue_t queue = dispatch_queue_create("com.securifi.almondplus", NULL);
        //        dispatch_async(queue, ^{
        //            [self getDeviceHash];
        //        });

        //Update UI
        if (isCurrentMAC) {
            self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];

            //Compare the list with device value list size and correct the list accordingly if any device was deleted
            //Compare the size
            if ([self.deviceList count] < [self.deviceValueList count]) {
                // NSLog(@"Sensor View: Some device was deleted!");
                //Reload Device Value List which was updated by Offline Data Manager
                self.deviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
            }

            [self initializeImages];
            [self asyncReloadTable];
        }
    }
}

- (void)onDeviceCloudValueListResponseCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    DeviceValueResponse *obj = (DeviceValueResponse *) [data valueForKey:@"data"];
    NSString *cloudMAC = obj.almondMAC;
    if (![cloudMAC isEqualToString:self.currentMAC]) {
        return;
    }

    //Match values and update the exact known value for the device
    NSMutableArray *currentValues = [NSMutableArray arrayWithArray:[SFIOfflineDataManager readDeviceValueList:self.currentMAC]];

    if (currentValues != nil) {
        NSMutableArray *cloudValues = obj.deviceValueList;

        for (SFIDeviceValue *deviceValue in currentValues) {
            for (SFIDeviceValue *cloudValue in cloudValues) {
                if (deviceValue.deviceID == cloudValue.deviceID) {
                    cloudValue.isPresent = TRUE;

                    for (SFIDeviceKnownValues *deviceKnowValues in deviceValue.knownValues) {
                        for (SFIDeviceKnownValues *cloudKNowValues in cloudValue.knownValues) {
                            if (deviceKnowValues.index == cloudKNowValues.index) {
                                //Update Value
                                [deviceKnowValues setValue:cloudKNowValues.value];
                                break;
                            }
                        }
                    }
                }
            }
        }

        self.deviceValueList = currentValues;
    }

    [self initializeImages];
    [self asyncReloadTable];
}

- (void)onAlmondListDidChange:(id)sender {
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];

    if (plus == nil) {
        self.currentMAC = NO_ALMOND;
        self.navigationItem.title = @"Get Started";
        self.deviceList = @[];
        self.deviceValueList = @[];
    }
    else {
        self.currentMAC = plus.almondplusMAC;
        self.navigationItem.title = plus.almondplusName;
        [self refreshDataForAlmond];
    }

    [self asyncReloadTable];
}

- (IBAction)onRefreshSensorData:(id)sender {
    if ([self isNoAlmondMAC]) {
        return;
    }

    SensorForcedUpdateRequest *forcedUpdateCommand = [[SensorForcedUpdateRequest alloc] init];
    forcedUpdateCommand.almondMAC = self.currentMAC;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = DEVICE_DATA_FORCED_UPDATE_REQUEST;
    cloudCommand.command = forcedUpdateCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)onSaveSensorData:(id)sender {
    if ([self isNoAlmondMAC]) {
        return;
    }

    UIButton *btnObj = (UIButton *) sender;
    SFIDevice *currentSensor = self.deviceList[(NSUInteger) btnObj.tag];

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
        //Cancel the event - Revert back
        //// NSLog(@"Change the state back");
        self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
        [self initializeImages];
        // [[self view] endEditing:YES];

        [self asyncReloadTable];
    }
}

- (void)onSensorChangeCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        self.isSensorChangeCommandSuccessful = TRUE;
        [SNLog Log:@"%s: Received SensorChangeCallback", __PRETTY_FUNCTION__];

        SensorChangeResponse *obj = (SensorChangeResponse *) [data valueForKey:@"data"];

        if (obj.isSuccessful) {
            [SNLog Log:@"%s: Sensor Data Changed Successfully", __PRETTY_FUNCTION__];
        }
        else {
            //TODO: Later
            [SNLog Log:@"%s: Could not update data, Revert to old value", __PRETTY_FUNCTION__];
            self.deviceList = [SFIOfflineDataManager readDeviceList:self.currentMAC];
            [self initializeImages];
            //To remove text fields keyboard. It was throwing error when it was being called from the background thread

            [self asyncReloadTable];
        }
    }
}

- (void)onAlmondNameDidChange:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    SFIAlmondPlus *obj = (SFIAlmondPlus *) [data valueForKey:@"data"];
    if ([self.currentMAC isEqualToString:obj.almondplusMAC]) {
        self.navigationItem.title = obj.almondplusName;
    }
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

@end
