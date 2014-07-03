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
#import "SNLog.h"
#import "SFIGenericRouterCommand.h"
#import "SFIParser.h"
#import "SFIRouterDevicesListViewController.h"
#import "ECSlidingViewController.h"
#import "MBProgressHUD.h"
#import "SFICloudStatusBarButtonItem.h"


@interface SFIRouterTableViewController () <UIActionSheetDelegate>
@property(nonatomic, readonly) SFICloudStatusBarButtonItem *statusBarButton;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property(nonatomic, readonly) NSArray *listAvailableColors;
@property(nonatomic, strong) UIImageView *splashImg;

@property NSString *currentMAC;
@property(nonatomic, strong) SFIRouterSummary *routerSummary;

@property BOOL isRebooting;
@property unsigned int mobileInternalIndex;
@end

@implementation SFIRouterTableViewController

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center removeObserver:self
                      name:NETWORK_UP_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:NETWORK_CONNECTING_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:NETWORK_DOWN_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:kSFIReachabilityChangedNotification
                    object:nil];

    [center removeObserver:self
                      name:GENERIC_COMMAND_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                    object:nil];

    [center removeObserver:self
                      name:GENERIC_COMMAND_CLOUD_NOTIFIER
                    object:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    _statusBarButton = [[SFICloudStatusBarButtonItem alloc] initWithStandard];
    self.navigationItem.rightBarButtonItem = _statusBarButton;

    _HUD = [[MBProgressHUD alloc] initWithView:self.parentViewController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    [self.parentViewController.view addSubview:_HUD];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];

    _listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    //Set title
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.currentMAC = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC];
    NSString *currentMACName = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC_NAME];

    NSArray *almondList = [[SecurifiToolkit sharedInstance] almondList];
    if (self.currentMAC == nil) {
        if ([almondList count] != 0) {
            SFIAlmondPlus *currentAlmond = almondList[0];
            self.currentMAC = currentAlmond.almondplusMAC;
            currentMACName = currentAlmond.almondplusName;
            [standardUserDefaults setObject:self.currentMAC forKey:CURRENT_ALMOND_MAC];
            [standardUserDefaults setObject:currentMACName forKey:CURRENT_ALMOND_MAC_NAME];
            if (currentMACName != nil) {
                self.navigationItem.title = currentMACName; //[NSString stringWithFormat:@"Sensors at %@", self.currentMAC];
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
        else {
            if (currentMACName != nil) {
                self.navigationItem.title = currentMACName;
            }
        }
    }

    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    //Display Drawer Gesture
    UISwipeGestureRecognizer *showMenuSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onRevealMenuAction:)];
    showMenuSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:showMenuSwipe];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(onNetworkChange:)
                   name:NETWORK_DOWN_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onNetworkConnectingNotifier:)
                   name:NETWORK_CONNECTING_NOTIFIER
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
               selector:@selector(onDynamicAlmondListAddCallback:)
                   name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER
                 object:nil];

    [center addObserver:self
               selector:@selector(onDynamicAlmondListDeleteCallback:)
                   name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                 object:nil];

    [self markCloudStatusIcon];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isRebooting = FALSE;

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.currentMAC = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC];

    //If Almond is there or not
    NSArray *almondList = [[SecurifiToolkit sharedInstance] almondList];
    if ([almondList count] == 0) {
        self.currentMAC = NO_ALMOND;
        self.navigationItem.title = @"Get Started";
        [self.tableView reloadData];
    }

    if (![self isNoAlmondLoaded]) {
        [self sendGenericCommandRequest:GET_WIRELESS_SUMMARY_COMMAND];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //NSLog(@"Rotation %d", fromInterfaceOrientation);
    [self.tableView reloadData];
}

- (BOOL)isNoAlmondLoaded {
    return [self.currentMAC isEqualToString:NO_ALMOND];
}

- (BOOL)isCloudOnline {
    return [[SecurifiToolkit sharedInstance] isCloudOnline];
}

- (void)markCloudStatusIcon {
    if (self.isCloudOnline) {
        [self.statusBarButton markState:SFICloudStatusStateConnected];
    }
    else {
        [self.statusBarButton markState:SFICloudStatusStateAlmondOffline];
    }
}

#pragma mark - Network and cloud events

- (void)onNetworkConnectingNotifier:(id)notification {
    [self.statusBarButton markState:SFICloudStatusStateConnecting];
}

- (void)onNetworkChange:(id)notice {
    [self markCloudStatusIcon];
    [self displayNoCloudConnectionImage];
}

- (void)displayNoCloudConnectionImage {
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (!self.isCloudOnline) {
            UIImage *image;

            //Set the splash image differently for 3.5 inch and 4 inch screen
            CGRect screenBounds = [[UIScreen mainScreen] bounds];
            if (screenBounds.size.height == 568) {
                // code for 4-inch screen
                image = [UIImage imageNamed:@"no_cloud_640x1136"];
            }
            else {
                // code for 3.5-inch screen
                image = [UIImage imageNamed:@"no_cloud_640x960"];
            }

            if (!self.splashImg) {
                self.splashImg = [[UIImageView alloc] initWithFrame:self.tableView.frame];
                [self.view addSubview:self.splashImg];
            }

            self.splashImg.image = image;
            self.tableView.scrollEnabled = NO;
        }
        else if (self.splashImg) {
            [self.splashImg removeFromSuperview];
            self.splashImg = nil;
            self.tableView.scrollEnabled = YES;
        }
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
    return 85;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isNoAlmondLoaded]) {
        return [self createNoAlmondCell:tableView];
    }

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

- (UITableViewCell *)createAlmondCell:(UITableView *)tableView {
    static NSString *CellIdentifier = @"Cell";

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

    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.tableView.frame.size.width - 20, 130)];

    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, self.tableView.frame.size.width, 30)];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    [lblTitle setFont:[UIFont fontWithName:@"Avenir-Light" size:25]];

    UILabel *lblSummary = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, self.tableView.frame.size.width, 30)];
    lblSummary.backgroundColor = [UIColor clearColor];
    lblSummary.textColor = [UIColor whiteColor];
    [lblSummary setFont:[UIFont fontWithName:@"Avenir-Heavy" size:13]];

    SFIColors *currentColor;

    //PY 270114 - Remove other options as for now Router Summary returns value only for reboot for Almond+
    //Router Reboot
    currentColor = self.listAvailableColors[3];
    lblTitle.text = @"Router Reboot";

    if (self.routerSummary == nil) {
        lblSummary.text = [NSString stringWithFormat:@"Last reboot %@", @""];
    }
    else {
        if (self.isRebooting) {
            lblSummary.numberOfLines = 3;
            lblSummary.frame = CGRectMake(10, 35, self.tableView.frame.size.width - 20, 60);
            lblSummary.text = @"Router is rebooting. It will take at least \n2 minutes for the router to boot.\nPlease refresh after sometime.";
        }
        else {
            lblSummary.text = [NSString stringWithFormat:@"Last reboot %@ ago", self.routerSummary.routerUptime];
        }
    }
    [backgroundLabel addSubview:lblTitle];
    [backgroundLabel addSubview:lblSummary];
    backgroundLabel.backgroundColor = [UIColor colorWithHue:(CGFloat) (currentColor.hue / 360.0) saturation:(CGFloat) (currentColor.saturation / 100.0) brightness:(CGFloat) (currentColor.brightness / 100.0) alpha:1];

    [cell addSubview:backgroundLabel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
            initWithTitle:nil
                 delegate:self
        cancelButtonTitle:@"No"
   destructiveButtonTitle:@"Yes"
        otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Class Methods

- (void)refreshDataForAlmond {
    [self sendGenericCommandRequest:GET_WIRELESS_SUMMARY_COMMAND];
}


- (IBAction)onRevealMenuAction:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)onRebootButtonAction:(id)sender {
    //Send Generic Command
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
            initWithTitle:@"Reboot the router?"
                 delegate:self
        cancelButtonTitle:@"No"
   destructiveButtonTitle:@"Yes"
        otherButtonTitles:nil];
    [actionSheet showInView:self.view];

}

- (void)onAddAlmondAction:(id)sender {
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
        case 0:
            NSLog(@"Clicked on yes");

            self.HUD.labelText = @"Router is rebooting.";
            [self.HUD hide:YES afterDelay:1];

            self.isRebooting = TRUE;
            [self sendGenericCommandRequest:REBOOT_COMMAND];
            [self.tableView reloadData];
            break;

        case 1:
            NSLog(@"Clicked on no");
            break;

        default:
            break;
    }
}

#pragma mark - Cloud command senders and handlers

- (void)sendGenericCommandRequest:(NSString *)data {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];

    self.mobileInternalIndex = (arc4random() % 1000) + 1;

    GenericCommandRequest *rebootGenericCommand = [[GenericCommandRequest alloc] init];
    rebootGenericCommand.almondMAC = self.currentMAC;
    rebootGenericCommand.applicationID = APPLICATION_ID;
    rebootGenericCommand.mobileInternalIndex = [NSString stringWithFormat:@"%d", self.mobileInternalIndex];
    rebootGenericCommand.data = data;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = GENERIC_COMMAND_REQUEST;
    cloudCommand.command = rebootGenericCommand;

    [self asyncSendCommand:cloudCommand];
}

- (void)onGenericResponseCallback:(id)sender {
    [SNLog Log:@"%s: ", __PRETTY_FUNCTION__];

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"%s: Received GenericCommandResponse", __PRETTY_FUNCTION__];

        GenericCommandResponse *obj = (GenericCommandResponse *) [data valueForKey:@"data"];

        BOOL isSuccessful = obj.isSuccessful;
        if (isSuccessful) {
            //Display proper message
            NSLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
            NSLog(@"Response Data: %@", obj.genericData);
            NSLog(@"Decoded Data: %@", obj.decodedData);

            NSData *decoded_data = [obj.decodedData mutableCopy];
            NSLog(@"Data: %@", decoded_data);

            NSMutableData *genericData = [[NSMutableData alloc] init];
            [genericData appendData:decoded_data];

            unsigned int expectedDataLength;
            unsigned int commandData;

            [genericData getBytes:&expectedDataLength range:NSMakeRange(0, 4)];
            [SNLog Log:@"%s: Expected Length: %d", __PRETTY_FUNCTION__, expectedDataLength];
            [genericData getBytes:&commandData range:NSMakeRange(4, 4)];
            [SNLog Log:@"%s: Command: %d", __PRETTY_FUNCTION__, commandData];

            //Remove 8 bytes from received command
            [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

            NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
            SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:decodedString];
            NSLog(@"Command Type %d", genericRouterCommand.commandType);

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
//                    NSLog(@"Connected Devices Reply: %d", [routerConnectedDevices.deviceList count]);
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
//                    NSLog(@"Blocked Devices Reply: %d", [routerBlockedDevices.deviceList count]);
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
//                    NSLog(@"Blocked content Reply: %d", [routerBlockedContent.deviceList count]);
//                    //Display list
//                    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//                    viewController.deviceList = routerBlockedContent.deviceList;
//                    viewController.deviceListType = genericRouterCommand.commandType;
//                    [self.navigationController pushViewController:viewController animated:YES];
//               }
//                    break;
                case 7: {
                    //Get Wireless Settings
                    SFIDevicesList *routerSettings = (SFIDevicesList *) genericRouterCommand.command;
                    NSLog(@"Wifi settings Reply: %d", [routerSettings.deviceList count]);
                    //Display list
                    SFIRouterDevicesListViewController *viewController = [[SFIRouterDevicesListViewController alloc] init];
                    viewController.deviceList = routerSettings.deviceList;
                    viewController.deviceListType = genericRouterCommand.commandType;
                    [self.navigationController pushViewController:viewController animated:YES];
                    break;
                }
                case 9: {
                    //Get Wireless Summary
                    self.routerSummary = (SFIRouterSummary *) genericRouterCommand.command;
                    [self.tableView reloadData];

                    break;
                }

                default:
                    break;

            }
            // }
        }
        else {
            NSLog(@"Reason: %@", obj.reason);
        }
    }
}

- (void)onGenericNotificationCallback:(id)sender {
    [SNLog Log:@"%s: ", __PRETTY_FUNCTION__];

    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"%s: Received GenericNotification", __PRETTY_FUNCTION__];

        GenericCommandResponse *obj = (GenericCommandResponse *) [data valueForKey:@"data"];

        BOOL isSuccessful = obj.isSuccessful;
        if (isSuccessful) {
            NSMutableData *genericData = [[NSMutableData alloc] init];

            //Display proper message
            NSLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
            NSLog(@"Response Data: %@", obj.genericData);
            NSLog(@"Decoded Data: %@", obj.decodedData);
            NSData *data_decoded = [obj.decodedData mutableCopy];
            NSLog(@"Data: %@", data_decoded);

            [genericData appendData:data_decoded];

            unsigned int expectedDataLength;
            unsigned int commandData;

            [genericData getBytes:&expectedDataLength range:NSMakeRange(0, 4)];
            [genericData getBytes:&commandData range:NSMakeRange(4, 4)];

            //Remove 8 bytes from received command
            [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];

            NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
            SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:decodedString];
            NSLog(@"Command Type %d", genericRouterCommand.commandType);

            switch (genericRouterCommand.commandType) {
                case 1: {
                    //Reboot
                    SFIRouterReboot *routerReboot = (SFIRouterReboot *) genericRouterCommand.command;
                    NSLog(@"Reboot Reply: %d", routerReboot.reboot);

                    self.HUD.labelText = @"Router is now online.";
                    [self.HUD hide:YES afterDelay:1];

                    self.isRebooting = FALSE;
                    [self sendGenericCommandRequest:GET_WIRELESS_SUMMARY_COMMAND];
                    break;
                }
                default:
                    break;
            }
        }
        else {
            NSLog(@"Reason: %@", obj.reason);
        }
    }
}

- (void)onDynamicAlmondListAddCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"%s: Received DynamicAlmondListAddCallback", __PRETTY_FUNCTION__];

        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];

        if (obj.isSuccessful) {
            [SNLog Log:@"%s: List size : %d", __PRETTY_FUNCTION__, [obj.almondPlusMACList count]];
            [SNLog Log:@"%s: Current MAC : %@", __PRETTY_FUNCTION__, self.currentMAC];
            if ([self isNoAlmondLoaded]) {
                [SNLog Log:@"%s: Previously no almond", __PRETTY_FUNCTION__];

                NSArray *almondList = [[SecurifiToolkit sharedInstance] almondList];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

                if ([almondList count] != 0) {
                    SFIAlmondPlus *currentAlmond = almondList[0];
                    self.currentMAC = currentAlmond.almondplusMAC;

                    NSString *currentMACName = currentAlmond.almondplusName;
                    [prefs setObject:self.currentMAC forKey:CURRENT_ALMOND_MAC];
                    [prefs setObject:currentMACName forKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs synchronize];

                    self.navigationItem.title = currentMACName;
                    [self refreshDataForAlmond];
                }
                else {
                    self.currentMAC = NO_ALMOND;
                    self.navigationItem.title = @"Get Started";
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
                    [prefs synchronize];
                    [self.tableView reloadData];
                }
            }
        }

    }
}

- (void)onDynamicAlmondListDeleteCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"%s: Received DynamicAlmondListCallback", __PRETTY_FUNCTION__];

        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];

        if (obj.isSuccessful) {
            [SNLog Log:@"%s: List size : %d", __PRETTY_FUNCTION__, [obj.almondPlusMACList count]];

            SFIAlmondPlus *deletedAlmond = obj.almondPlusMACList[0];
            if ([self.currentMAC isEqualToString:deletedAlmond.almondplusMAC]) {
                [SNLog Log:@"%s: Remove this view", __PRETTY_FUNCTION__];

                NSArray *almondList = [[SecurifiToolkit sharedInstance] almondList];
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

                if ([almondList count] != 0) {
                    SFIAlmondPlus *currentAlmond = almondList[0];
                    self.currentMAC = currentAlmond.almondplusMAC;

                    NSString *currentMACName = currentAlmond.almondplusName;
                    [prefs setObject:self.currentMAC forKey:CURRENT_ALMOND_MAC];
                    [prefs setObject:currentMACName forKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs synchronize];

                    self.navigationItem.title = currentMACName;
                    [self refreshDataForAlmond];
                }
                else {
                    self.currentMAC = NO_ALMOND;
                    self.navigationItem.title = @"Get Started";
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
                    [prefs synchronize];
                    [self.tableView reloadData];
                }
            }
        }

    }
}

- (void)asyncSendCommand:(GenericCommand *)cloudCommand {
    [[SecurifiToolkit sharedInstance] asyncSendToCloud:cloudCommand];
}

@end
