//
//  SFIRouterTopTableViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 27/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIRouterTableViewController.h"
#import "SFIColors.h"
#import "AlmondPlusConstants.h"
#import "SFIGenericRouterCommand.h"
#import "SFIParser.h"
#import "SFIRouterDevicesListViewController.h"
#import "MBProgressHUD.h"
#import "Analytics.h"
#import "UIFont+Securifi.h"


@interface SFIRouterTableViewController () <UIActionSheetDelegate>
@property NSTimer *hudTimer;
@property(nonatomic, readonly) NSArray *listAvailableColors;

@property NSString *currentMAC;
@property(nonatomic, strong) SFIRouterSummary *routerSummary;

@property BOOL isRebooting;
@property BOOL isAlmondUnavailable;
@property BOOL shownHudOnce;
@property BOOL disposed;

@property unsigned int mobileInternalIndex;
@end

@implementation SFIRouterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];

    _listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    //Set title
    SFIAlmondPlus *plus = [[SecurifiToolkit sharedInstance] currentAlmond];
    self.currentMAC = plus.almondplusMAC;

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Pull down to refresh device values
    UIRefreshControl *refresh = [UIRefreshControl new];
    NSDictionary *attributes = self.navigationController.navigationBar.titleTextAttributes;
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Force router data refresh" attributes:attributes];
    [refresh addTarget:self action:@selector(onRefreshRouter:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    [self initializeNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initializeAlmondData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if ([self isBeingDismissed] || [self isMovingFromParentViewController]) {
        self.disposed = YES;

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self];

        [self.hudTimer invalidate];
    }
}

- (void)initializeNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(onNetworkChange:)
                   name:NETWORK_DOWN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkChange:)
                   name:NETWORK_UP_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkChange:)
                   name:kSFIReachabilityChangedNotification object:nil];

    [center addObserver:self
               selector:@selector(onGenericResponseCallback:)
                   name:GENERIC_COMMAND_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onGenericNotificationCallback:)
                   name:GENERIC_COMMAND_CLOUD_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onCurrentAlmondChanged:)
                   name:kSFIDidChangeCurrentAlmond
                 object:nil];

    [center addObserver:self
               selector:@selector(onAlmondListDidChange:)
                   name:kSFIDidUpdateAlmondList
                 object:nil];
}

- (void)initializeAlmondData {
    self.isRebooting = FALSE;

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];

    if (plus == nil) {
        self.navigationItem.title = @"Get Started";
        self.currentMAC = NO_ALMOND;
        [self.tableView reloadData];
    }
    else {
        self.currentMAC = plus.almondplusMAC;
        self.navigationItem.title = plus.almondplusName;
        [self.tableView reloadData];
    }

    if (!self.shownHudOnce) {
        self.shownHudOnce = YES;
        [self showHudOnTimeout];
    }
    [self sendWirelessSummaryCommand];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //DLog(@"Rotation %d", fromInterfaceOrientation);
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"%s, Did receive memory warning", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}

- (void)onCurrentAlmondChanged:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.shownHudOnce = NO;
        if (self.isViewLoaded && self.view.window) {
            // View is visible; reload now; otherwise, viewWillAppear will invoke it for us
            [self initializeAlmondData];
        }
    });
}

- (void)onRefreshRouter:(id)sender {
    if ([self isNoAlmondLoaded]) {
        return;
    }

    [self sendWirelessSummaryCommand];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [self.refreshControl endRefreshing];
    });
}

- (void)sendWirelessSummaryCommand {
    if (![self isNoAlmondLoaded]) {
        [self sendGenericCommandRequest:GET_WIRELESS_SUMMARY_COMMAND];
    }
}

- (BOOL)isNoAlmondLoaded {
    return [self.currentMAC isEqualToString:NO_ALMOND];
}

- (BOOL)isCloudOnline {
    return [[SecurifiToolkit sharedInstance] isCloudOnline];
}

#pragma mark HUD mgt

- (void)showHudOnTimeout {
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.hudTimer invalidate];
        self.hudTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onHudTimeout:) userInfo:nil repeats:NO];
        [self.HUD show:YES];
    });
}

- (void)onHudTimeout:(id)sender {
    [self.hudTimer invalidate];
    self.hudTimer = nil;

    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

#pragma mark - Network and cloud events

- (void)onNetworkChange:(id)notice {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isNoAlmondLoaded]) {
        return 1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    if ([self isNoAlmondLoaded]) {
        return 400;
    }
    if (self.isRebooting) {
        return 100;
    }

    if (![self isCloudOnline]) {
        return 400;
    }

    return 85;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondLoaded]) {
        tableView.scrollEnabled = NO;
        return [self createNoAlmondCell:tableView];
    }

    if (self.isAlmondUnavailable) {
        tableView.scrollEnabled = NO;
        return [self createAlmondNoConnectCell:tableView];
    }

    tableView.scrollEnabled = YES;
    return [self createAlmondCell:tableView];
}

- (UITableViewCell *)createNoAlmondCell:(UITableView*)tableView {
    static NSString *id = @"NoAlmondCell";

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

    UIImageView *imgGettingStarted = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 400)];
    imgGettingStarted.userInteractionEnabled = YES;
    imgGettingStarted.image = [UIImage imageNamed:@"getting_started.png"];
    imgGettingStarted.contentMode = UIViewContentModeScaleAspectFit;

    UIButton *btnAddAlmond = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddAlmond.frame = imgGettingStarted.bounds;
    btnAddAlmond.backgroundColor = [UIColor clearColor];
    [btnAddAlmond addTarget:self action:@selector(onAddAlmondAction:) forControlEvents:UIControlEventTouchUpInside];

    [imgGettingStarted addSubview:btnAddAlmond];
    [cell addSubview:imgGettingStarted];

    return cell;
}

- (UITableViewCell *)createAlmondNoConnectCell:(UITableView *)tableView {
    static NSString *cell_id = @"NoAlmondConnect";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        CGFloat width = self.tableView.frame.size.width;

        UILabel *lblNoSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, width, 50)];
        lblNoSensor.textAlignment = NSTextAlignmentCenter;
        [lblNoSensor setFont:[UIFont securifiLightFont:35]];
        lblNoSensor.text = @"Almond is Offline.";
        lblNoSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblNoSensor];

        UIImageView *imgRouter = [[UIImageView alloc] initWithFrame:CGRectMake(width / 2 - 50, 150, 100, 100)];
        imgRouter.userInteractionEnabled = NO;
        [imgRouter setImage:[UIImage imageNamed:@"offline_150x150.png"]];
        imgRouter.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:imgRouter];

        UILabel *lblAddSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 280, width, 40)];
        lblAddSensor.textAlignment = NSTextAlignmentCenter;
        [lblAddSensor setFont:[UIFont securifiBoldFont:20]];
        lblAddSensor.text = @"Please check the router.";
        lblAddSensor.textColor = [UIColor grayColor];
        [cell addSubview:lblAddSensor];
    }

    return cell;
}

- (UITableViewCell *)createAlmondCell:(UITableView *)tableView {
    NSLog(@"createAlmondCell");

    static NSString *CellIdentifier = @"AlmondCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    //todo sinclair - because the subviews are always being regenerated below....
    //PY 070114
    //START: HACK FOR MEMORY LEAKS
    for (UIView *currentView in cell.contentView.subviews) {
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS

    //PY 270114 - Remove other options as for now Router Summary returns value only for reboot for Almond+
    //Router Reboot
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.tableView.frame.size.width, 30)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont securifiBoldFont:25];
    titleLabel.text = @"Router Reboot";

    UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, self.tableView.frame.size.width, 30)];
    summaryLabel.backgroundColor = [UIColor clearColor];
    summaryLabel.textColor = [UIColor whiteColor];
    summaryLabel.font = [UIFont securifiBoldFont:13];
    //
    if (self.routerSummary == nil) {
        summaryLabel.text = [NSString stringWithFormat:@"Last reboot %@", @""];
    }
    else {
        if (self.isRebooting) {
            summaryLabel.numberOfLines = 3;
            summaryLabel.frame = CGRectMake(10, 35, self.tableView.frame.size.width - 20, 60);
            summaryLabel.text = @"Router is rebooting. It will take at least \n2 minutes for the router to boot.\nPlease refresh after sometime.";
        }
        else {
            summaryLabel.text = [NSString stringWithFormat:@"Last reboot %@ ago", self.routerSummary.routerUptime];
        }
    }

    SFIColors *currentColor = self.listAvailableColors[3]; //todo this is brittle; fix me
    UIColor *color = [UIColor colorWithHue:(CGFloat) (currentColor.hue / 360.0) saturation:(CGFloat) (currentColor.saturation / 100.0) brightness:(CGFloat) (currentColor.brightness / 100.0) alpha:1];

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(10, 5, self.tableView.frame.size.width - 20, 130)];
    container.backgroundColor = color;
    [container addSubview:titleLabel];
    [container addSubview:summaryLabel];

    [cell.contentView addSubview:container];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondLoaded]) {
        return;
    }

    if (self.isAlmondUnavailable) {
        return;
    }

    UIActionSheet *actionSheet = [[UIActionSheet alloc]
            initWithTitle:@"Reboot the router?"
                 delegate:self
        cancelButtonTitle:@"No"
   destructiveButtonTitle:@"Yes"
        otherButtonTitles:nil];

    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - Class Methods

- (void)refreshDataForAlmond {
    [self sendGenericCommandRequest:GET_WIRELESS_SUMMARY_COMMAND];
}

//- (IBAction)onRebootButtonAction:(id)sender {
//    //Send Generic Command
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//            initWithTitle:@"Reboot the router?"
//                 delegate:self
//        cancelButtonTitle:@"No"
//   destructiveButtonTitle:@"Yes"
//        otherButtonTitles:nil];
//
//    [actionSheet showInView:self.view];
//}

- (void)onAddAlmondAction:(id)sender {
    if (self.disposed) {
        return;
    }
    if ([self isNoAlmondLoaded]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"AffiliationNavigationTop"];
        [self presentViewController:mainView animated:YES completion:nil];
    }
    else {
        //Get wireless settings
        [self sendGenericCommandRequest:GET_WIRELESS_SETTINGS_COMMAND];
    }
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            DLog(@"Clicked on yes");

            dispatch_async(dispatch_get_main_queue(), ^() {
                if (self.disposed) {
                    return;
                }
                self.HUD.labelText = @"Router is rebooting.";
                [self.HUD hide:YES afterDelay:1];

                self.isRebooting = TRUE;
                [self sendGenericCommandRequest:REBOOT_COMMAND];
                [self.tableView reloadData];

                [[Analytics sharedInstance] markRouterReboot];
            });

            break;
        }

        case 1: {
            DLog(@"Clicked on no");
            break;
        }

        default: {
            break;
        }
    }
}

#pragma mark - Cloud command senders and handlers

- (void)sendGenericCommandRequest:(NSString *)data {
    self.mobileInternalIndex = (arc4random() % 1000) + 1;

    GenericCommandRequest *rebootGenericCommand = [[GenericCommandRequest alloc] init];
    rebootGenericCommand.almondMAC = self.currentMAC;
    rebootGenericCommand.applicationID = APPLICATION_ID;
    rebootGenericCommand.mobileInternalIndex = [NSString stringWithFormat:@"%d", self.mobileInternalIndex];
    rebootGenericCommand.data = data;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = CommandType_GENERIC_COMMAND_REQUEST;
    cloudCommand.command = rebootGenericCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)onGenericResponseCallback:(id)sender {
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

    GenericCommandResponse *obj = (GenericCommandResponse *) [data valueForKey:@"data"];

    BOOL isSuccessful = obj.isSuccessful;
    if (!isSuccessful) {
        DLog(@"Reason: %@", obj.reason);

        dispatch_async(dispatch_get_main_queue(), ^() {
            if (self.disposed) {
                return;
            }
            self.isAlmondUnavailable = YES;
            [self.tableView reloadData];
            [self.HUD hide:YES];
            [self.refreshControl endRefreshing];
        });

        return;
    }
    self.isAlmondUnavailable = NO;

    //Display proper message
    DLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
    DLog(@"Response Data: %@", obj.genericData);
    DLog(@"Decoded Data: %@", obj.decodedData);

    NSData *decoded_data = [obj.decodedData copy];
    DLog(@"Data: %@", decoded_data);

    NSMutableData *genericData = [[NSMutableData alloc] init];
    [genericData appendData:decoded_data];

    unsigned int expectedDataLength;
    unsigned int commandData;

    [genericData getBytes:&expectedDataLength range:NSMakeRange(0, 4)];
    [genericData getBytes:&commandData range:NSMakeRange(4, 4)];

    //Remove 8 bytes from received command
    [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

    NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
    SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:decodedString];
    DLog(@"Command Type %d", genericRouterCommand.commandType);

    switch (genericRouterCommand.commandType) {
        case 1: {
            //Reboot
            SFIRouterReboot *routerReboot = (SFIRouterReboot *) genericRouterCommand.command;
            NSLog(@"Reboot Reply: %d", routerReboot.reboot);
            break;
        }
//                case 2:
//                {
//                    //Get Connected Device List
//                    SFIDevicesList *routerConnectedDevices = (SFIDevicesList*)genericRouterCommand.command;
//                    DLog(@"Connected Devices Reply: %d", [routerConnectedDevices.deviceList count]);
//                    //Display list
//                    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//                    viewController.deviceList = routerConnectedDevices.deviceList;
//                    viewController.deviceListType = genericRouterCommand.commandType;
//                    [self.navigationController pushViewController:viewController animated:YES];
//                }
//                    break;
//                case 3:
//                {
//                    //Get Blocked Device List
//                    SFIDevicesList *routerBlockedDevices = (SFIDevicesList*)genericRouterCommand.command;
//                    DLog(@"Blocked Devices Reply: %d", [routerBlockedDevices.deviceList count]);
//                    //Display list
//                    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//                    viewController.deviceList = routerBlockedDevices.deviceList;
//                    viewController.deviceListType = genericRouterCommand.commandType;
//                    [self.navigationController pushViewController:viewController animated:YES];
//
//                }
//                    break;
//                    //TODO: Case 4: Set blocked device
//                case 5:
//                {
//                    //Get Blocked Device Content
//                    SFIDevicesList *routerBlockedContent = (SFIDevicesList*)genericRouterCommand.command;
//                    DLog(@"Blocked content Reply: %d", [routerBlockedContent.deviceList count]);
//                    //Display list
//                    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//                    viewController.deviceList = routerBlockedContent.deviceList;
//                    viewController.deviceListType = genericRouterCommand.commandType;
//                    [self.navigationController pushViewController:viewController animated:YES];
//               }
//                    break;
        case 7: {
            //Get Wireless Settings
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (self.disposed) {
                    return;
                }

                SFIDevicesList *routerSettings = (SFIDevicesList *) genericRouterCommand.command;
                DLog(@"Wifi settings Reply: %ld", (long) [routerSettings.deviceList count]);

                SFIRouterDevicesListViewController *viewController = [[SFIRouterDevicesListViewController alloc] init];
                viewController.deviceList = routerSettings.deviceList;
                viewController.deviceListType = genericRouterCommand.commandType;

                [self.navigationController pushViewController:viewController animated:YES];
            });
            break;
        }
        case 9: {
            // Get Wireless Summary
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (self.disposed) {
                    return;
                }

                self.routerSummary = (SFIRouterSummary *) genericRouterCommand.command;
                [self.tableView reloadData];
            });

            break;
        }

        default:
            break;
    } // end switch

    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }
        [self.HUD hide:YES];
        [self.refreshControl endRefreshing];
    });
}

- (void)onGenericNotificationCallback:(id)sender {
    if (self.disposed) {
        return;
    }

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    if (data == nil) {
        return;
    }

    GenericCommandResponse *obj = (GenericCommandResponse *) [data valueForKey:@"data"];
    if (!obj.isSuccessful) {
        DLog(@"Reason: %@", obj.reason);

        dispatch_async(dispatch_get_main_queue(), ^() {
            if (self.disposed) {
                return;
            }

            self.isAlmondUnavailable = YES;
            [self.tableView reloadData];
        });

        return;
    }
    self.isAlmondUnavailable = NO;

    NSMutableData *genericData = [[NSMutableData alloc] init];

    //Display proper message
    DLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
    DLog(@"Response Data: %@", obj.genericData);
    DLog(@"Decoded Data: %@", obj.decodedData);
    NSData *data_decoded = [obj.decodedData mutableCopy];
    DLog(@"Data: %@", data_decoded);

    [genericData appendData:data_decoded];

    unsigned int expectedDataLength;
    unsigned int commandData;

    [genericData getBytes:&expectedDataLength range:NSMakeRange(0, 4)];
    [genericData getBytes:&commandData range:NSMakeRange(4, 4)];

    //Remove 8 bytes from received command
    [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

    NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
    SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:decodedString];
    DLog(@"Command Type %d", genericRouterCommand.commandType);

    switch (genericRouterCommand.commandType) {
        case 1: {
            dispatch_async(dispatch_get_main_queue(), ^() {
                if (self.disposed) {
                    return;
                }

                //Reboot
                SFIRouterReboot *routerReboot = (SFIRouterReboot *) genericRouterCommand.command;
                NSLog(@"Reboot Reply: %d", routerReboot.reboot);

                self.HUD.labelText = @"Router is now online.";
                [self.HUD hide:YES afterDelay:1];

                self.isRebooting = FALSE;
                [self sendGenericCommandRequest:GET_WIRELESS_SUMMARY_COMMAND];
            });
            break;
        }
        default:
            break;
    }
}

- (void)onAlmondListDidChange:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (self.disposed) {
            return;
        }

        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        SFIAlmondPlus *plus = [toolkit currentAlmond];

        if (plus == nil) {
            self.currentMAC = NO_ALMOND;
            self.navigationItem.title = @"Get Started";
        }
        else {
            self.currentMAC = plus.almondplusMAC;
            self.navigationItem.title = plus.almondplusName;
            [self refreshDataForAlmond];
        }

        [self.tableView reloadData];
    });
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

@end
