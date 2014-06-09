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
#import "SFIOfflineDataManager.h"


@implementation SFIRouterTableViewController

@synthesize mobileInternalIndex;
@synthesize currentMAC;
@synthesize listAvailableColors;
@synthesize expectedGenericDataLength;
@synthesize command;
@synthesize totalGenericDataReceivedLength;
@synthesize routerSummary;
@synthesize isRebooting;

- (void)awakeFromNib
{
    [super awakeFromNib];

    NSDictionary *titleAttributes = @{
            NSForegroundColorAttributeName : [UIColor colorWithRed:(CGFloat) (51.0 / 255.0) green:(CGFloat) (51.0 / 255.0) blue:(CGFloat) (51.0 / 255.0) alpha:1.0],
            NSFontAttributeName : [UIFont fontWithName:@"Avenir-Roman" size:18.0]
    };

    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];

    listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];

    //Set title
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.currentMAC = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC];
    NSString *currentMACName = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC_NAME];
    NSMutableArray *almondList = [SFIOfflineDataManager readAlmondList];
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
    UISwipeGestureRecognizer *showMenuSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(revealMenu:)];
    showMenuSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.tableView addGestureRecognizer:showMenuSwipe];


}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isRebooting = FALSE;

    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.currentMAC = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC];

    //If Almond is there or not
    NSMutableArray *almondList = [SFIOfflineDataManager readAlmondList];
   if([almondList count] == 0){
        self.currentMAC = NO_ALMOND;
        self.navigationItem.title = @"Get Started";
       [self.tableView reloadData];
    }


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GenericResponseCallback:)
                                                 name:GENERIC_COMMAND_NOTIFIER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GenericNotificationCallback:)
                                                 name:GENERIC_COMMAND_CLOUD_NOTIFIER
                                               object:nil];

    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DynamicAlmondListAddCallback:)
                                                    name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DynamicAlmondListDeleteCallback:)
                                                    name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                  object:nil];

    if(![self.currentMAC isEqualToString:NO_ALMOND]){
        [self sendGenericCommandRequest:GET_WIRELESS_SUMMARY_COMMAND];
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GENERIC_COMMAND_NOTIFIER
                                                  object:nil];

    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DYNAMIC_ALMOND_LIST_ADD_NOTIFIER
                                                     object:nil];

    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                     object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GENERIC_COMMAND_CLOUD_NOTIFIER
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    //NSLog(@"Rotation %d", fromInterfaceOrientation);
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([currentMAC isEqualToString:NO_ALMOND]){
        return 1;
    }
    // Return the number of rows in the section.
    //return 4;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if([currentMAC isEqualToString:NO_ALMOND]){
        return 400;
    }
    if(isRebooting){
        return 100;
    }
    return 85;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    //todo sinclair investigate this
    //PY 070114
    //START: HACK FOR MEMORY LEAKS
    for (UIView *currentView in cell.contentView.subviews) {
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS

    //if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //}

    if ([self.currentMAC isEqualToString:NO_ALMOND]) {
        cell = [self createNoAlmondCell:cell];
        return cell;
    }

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
    currentColor = listAvailableColors[3];
    lblTitle.text = @"Router Reboot";

    if (routerSummary == nil) {
        lblSummary.text = [NSString stringWithFormat:@"Last reboot %@", @""];
    }
    else {
        if (isRebooting) {
            lblSummary.numberOfLines = 3;
            lblSummary.frame = CGRectMake(10, 35, self.tableView.frame.size.width - 20, 60);
            lblSummary.text = @"Router is rebooting. It will take at least \n2 minutes for the router to boot.\nPlease refresh after sometime.";
        }
        else {
            lblSummary.text = [NSString stringWithFormat:@"Last reboot %@ ago", routerSummary.routerUptime];
        }
    }

//    switch(indexPath.row){
//        case 0:
//        {
//            //Wireless Settings
//            currentColor = [listAvailableColors objectAtIndex:0];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            lblTitle.text = @"Wireless Settings";
//            lblSummary.frame = CGRectMake(10,25,self.tableView.frame.size.width,60);
//            lblSummary.numberOfLines = 2;
//            NSString *strWirelessSummary = @"";
//            for(SFIWirelessSummary *currentWireless in routerSummary.wirelessSettings){
//                strWirelessSummary = [strWirelessSummary stringByAppendingString:[NSString stringWithFormat:@"%@ %@\n", currentWireless.ssid, currentWireless.enabledStatus]];
//            }
//            if ( [strWirelessSummary length] > 0)
//                strWirelessSummary = [strWirelessSummary substringToIndex:[strWirelessSummary length] - 1];
//            lblSummary.text = strWirelessSummary;
//        }
//            break;
//        case 1:
//            //Device and User
//        {
//            currentColor = [listAvailableColors objectAtIndex:1];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            lblTitle.text = @"Devices & Users";
//            
//            //PY 291113 - Coming soon
////            UILabel *lblComingSoon = [[UILabel alloc] initWithFrame:CGRectMake(190,5,100,30)];
////            lblComingSoon.backgroundColor = [UIColor clearColor];
////            lblComingSoon.textColor = [UIColor whiteColor];
////            [lblComingSoon setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
////            lblComingSoon.text = @"(Coming Soon)";
////            [backgroundLabel addSubview:lblComingSoon];
//
//            
//            lblSummary.text=[NSString stringWithFormat:@"%d connected, %d blocked", routerSummary.connectedDeviceCount, routerSummary.blockedMACCount];
//        }
//            break;
//        case 2:
//            //Filter
//            currentColor = [listAvailableColors objectAtIndex:6];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            lblTitle.text = @"Filtered Content";
//            lblSummary.text=[NSString stringWithFormat:@"%d filters", routerSummary.blockedContentCount];
//            break;
//        case 3:
//            //Router Reboot
//            currentColor = [listAvailableColors objectAtIndex:3];
//            lblTitle.text = @"Router Reboot";
//            
//            if(routerSummary == nil){
//                lblSummary.text=[NSString stringWithFormat:@"Last reboot %@", @""];
//            }else{
//                if(isRebooting){
//                    lblSummary.numberOfLines = 2;
//                    lblSummary.frame = CGRectMake(10,25,self.tableView.frame.size.width,60);
//                    lblSummary.text= @"Router is rebooting. It will take at least \n2 minutes for the router to boot.";
//                }else{
//                    lblSummary.text=[NSString stringWithFormat:@"Last reboot %@ ago", routerSummary.routerUptime];
//                }
//            }
//            
//            break;
//    }

    [backgroundLabel addSubview:lblTitle];
    [backgroundLabel addSubview:lblSummary];
    backgroundLabel.backgroundColor = [UIColor colorWithHue:(CGFloat) (currentColor.hue / 360.0) saturation:(CGFloat) (currentColor.saturation / 100.0) brightness:(CGFloat) (currentColor.brightness / 100.0) alpha:1];

    [cell addSubview:backgroundLabel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row Clicked %d", indexPath.row);

    //PY 270114 - Remove other options as for now Router Summary returns value only for reboot for Almond+
    //Router Reboot
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"No"
                                      destructiveButtonTitle:@"Yes"
                                      otherButtonTitles:nil];
        [actionSheet showInView:self.view];
    }


//    switch(indexPath.row){
//        case 0:
//            //Get wireless settings
//            [self sendGenericCommandRequest:GET_WIRELESS_SETTINGS_COMMAND];
//            break;
//        case 1:
//        {
//            SFIWirelessUserViewController *viewController =[[SFIWirelessUserViewController alloc] init];
//            [self.navigationController pushViewController:viewController animated:YES];
//            //Device and User
//            //[self sendGenericCommandRequest:GET_CONNECTED_DEVICE_COMMAND];
//            break;
//        }
//        case 2:
//             //Filter
//        {
//            SFIBlockedContentViewController *viewController =[[SFIBlockedContentViewController alloc] init];
//            [self.navigationController pushViewController:viewController animated:YES];
//        }
//            break;
//        case 3:
//            //Router Reboot
//        {
//            UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                          initWithTitle:nil
//                                          delegate:self
//                                          cancelButtonTitle:@"No"
//                                          destructiveButtonTitle:@"Yes"
//                                          otherButtonTitles:nil];
//            [actionSheet showInView:self.view];
//        }
//            break;
//    }
}

#pragma mark - Table cell creation
-(UITableViewCell*) createNoAlmondCell: (UITableViewCell*)cell{
    //PY 070114
    //START: HACK FOR MEMORY LEAKS
    for(UIView *currentView in cell.contentView.subviews){
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    //    cell.textLabel.text = @"No almond is linked to your account";
    //    cell.textLabel.numberOfLines = 2;
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView *imgGettingStarted;
    UIButton *btnAddAlmond;

    imgGettingStarted = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width,400)];
    imgGettingStarted.userInteractionEnabled = YES;
    [imgGettingStarted setImage:[UIImage imageNamed:@"getting_started.png"]];
    imgGettingStarted.contentMode = UIViewContentModeScaleAspectFit;

    btnAddAlmond = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddAlmond.frame = imgGettingStarted.bounds;
    btnAddAlmond.backgroundColor = [UIColor clearColor];
    [btnAddAlmond addTarget:self action:@selector(onAddAlmondClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgGettingStarted addSubview:btnAddAlmond];

    [cell addSubview:imgGettingStarted];

    return cell;
}

#pragma mark - Class Methods
-(void) refreshDataForAlmond{
    [self sendGenericCommandRequest:GET_WIRELESS_SUMMARY_COMMAND];
}


- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)rebootButtonHandler:(id)sender{
    //Send Generic Command
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Reboot the router?"
                                  delegate:self
                                  cancelButtonTitle:@"No"
                                  destructiveButtonTitle:@"Yes"
                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];

}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Clicked on yes");
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.dimBackground = YES;
            HUD.labelText = @"Router is rebooting.";
            [HUD hide:YES afterDelay:1];
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



-(void) onAddAlmondClicked:(id) sender{
    if([self.currentMAC isEqualToString:NO_ALMOND]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"AffiliationNavigationTop"];
        [self presentViewController:mainView animated:YES completion:nil];
    }else{
        //Get wireless settings
        [self sendGenericCommandRequest:GET_WIRELESS_SETTINGS_COMMAND];
    }
}

#pragma mark - Cloud command senders and handlers

-(void) sendGenericCommandRequest:(NSString*)data{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSString *currentMAC  = [prefs objectForKey:CURRENT_ALMOND_MAC];

    //Generate internal index between 1 to 100
    self.mobileInternalIndex = (arc4random() % 1000) + 1;

    GenericCommandRequest *rebootGenericCommand = [[GenericCommandRequest alloc] init];
    rebootGenericCommand.almondMAC = self.currentMAC;
    rebootGenericCommand.applicationID = APPLICATION_ID;
    rebootGenericCommand.mobileInternalIndex = [NSString stringWithFormat:@"%d",self.mobileInternalIndex];
    rebootGenericCommand.data = data;
    cloudCommand.commandType=GENERIC_COMMAND_REQUEST;
    cloudCommand.command=rebootGenericCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- Generic Command Request", __PRETTY_FUNCTION__];

        NSError *error=nil;
        id ret = [[SecurifiToolkit sharedInstance] sendToCloud:cloudCommand error:&error];

        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- Generic Command Request", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
}

-(void)GenericResponseCallback:(id)sender
{
    [SNLog Log:@"Method Name: %s ", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %s Received GenericCommandResponse", __PRETTY_FUNCTION__];

        GenericCommandResponse *obj = (GenericCommandResponse *) [data valueForKey:@"data"];

        BOOL isSuccessful = obj.isSuccessful;
        if (isSuccessful) {
            genericData = [[NSMutableData alloc] init];
            genericString = [[NSString alloc] init];

            //Display proper message
            NSLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
            NSLog(@"Response Data: %@", obj.genericData);
            NSLog(@"Decoded Data: %@", obj.decodedData);

            NSData *decoded_data = [obj.decodedData mutableCopy];
            NSLog(@"Data: %@", decoded_data);

            [genericData appendData:decoded_data];

            [genericData getBytes:&expectedGenericDataLength range:NSMakeRange(0, 4)];
            [SNLog Log:@"Method Name: %s Expected Length: %d", __PRETTY_FUNCTION__, expectedGenericDataLength];
            [genericData getBytes:&command range:NSMakeRange(4, 4)];
            [SNLog Log:@"Method Name: %s Command: %d", __PRETTY_FUNCTION__, command];

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
                    routerSummary = (SFIRouterSummary *) genericRouterCommand.command;
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

- (void)GenericNotificationCallback:(id)sender {
    [SNLog Log:@"Method Name: %s ", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %s Received GenericNotification", __PRETTY_FUNCTION__];

        GenericCommandResponse *obj = (GenericCommandResponse *) [data valueForKey:@"data"];

        BOOL isSuccessful = obj.isSuccessful;
        if (isSuccessful) {
            genericData = [[NSMutableData alloc] init];
            genericString = [[NSString alloc] init];

            //Display proper message
            NSLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
            NSLog(@"Response Data: %@", obj.genericData);
            NSLog(@"Decoded Data: %@", obj.decodedData);
            NSData *data_decoded = [obj.decodedData mutableCopy];
            NSLog(@"Data: %@", data_decoded);

            [genericData appendData:data_decoded];

            [genericData getBytes:&expectedGenericDataLength range:NSMakeRange(0, 4)];
            [genericData getBytes:&command range:NSMakeRange(4, 4)];

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
                    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    HUD.dimBackground = YES;
                    HUD.labelText = @"Router is now online.";
                    [HUD hide:YES afterDelay:1];
                    self.isRebooting = FALSE;
                    //Get router summary
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

- (void)DynamicAlmondListAddCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %s Received DynamicAlmondListAddCallback", __PRETTY_FUNCTION__];

        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];

        if (obj.isSuccessful) {
            [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__, [obj.almondPlusMACList count]];
            //When previously no almonds were there
            [SNLog Log:@"Method Name: %s Current MAC : %@", __PRETTY_FUNCTION__, self.currentMAC];
            if ([self.currentMAC isEqualToString:NO_ALMOND]) {
                [SNLog Log:@"Method Name: %s Previously no almond", __PRETTY_FUNCTION__];
                NSMutableArray *almondList = [SFIOfflineDataManager readAlmondList];
                NSString *currentMACName;
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

                if ([almondList count] != 0) {
                    SFIAlmondPlus *currentAlmond = almondList[0];
                    self.currentMAC = currentAlmond.almondplusMAC;
                    currentMACName = currentAlmond.almondplusName;
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

- (void)DynamicAlmondListDeleteCallback:(id)sender {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];

    if (data != nil) {
        [SNLog Log:@"Method Name: %s Received DynamicAlmondListCallback", __PRETTY_FUNCTION__];

        AlmondListResponse *obj = (AlmondListResponse *) [data valueForKey:@"data"];

        if (obj.isSuccessful) {
            [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__, [obj.almondPlusMACList count]];

            SFIAlmondPlus *deletedAlmond = obj.almondPlusMACList[0];
            if ([self.currentMAC isEqualToString:deletedAlmond.almondplusMAC]) {
                [SNLog Log:@"Method Name: %s Remove this view", __PRETTY_FUNCTION__];
                NSMutableArray *almondList = [SFIOfflineDataManager readAlmondList];
                NSString *currentMACName;
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

                if ([almondList count] != 0) {
                    SFIAlmondPlus *currentAlmond = almondList[0];
                    self.currentMAC = currentAlmond.almondplusMAC;
                    currentMACName = currentAlmond.almondplusName;
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


@end
