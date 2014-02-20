//
//  SFIConnectedDevicesListViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 30/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIRouterDevicesListViewController.h"
#import "SFIConnectedDevice.h"
#import "SFIBlockedDevice.h"
#import "SFIBlockedContent.h"
#import "SFIWirelessSetting.h"
#import "SFIWirelessViewController.h"
#import "SFIWirelessTableViewController.h"
#import "AlmondPlusConstants.h"
#import "SFIOfflineDataManager.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SNLog.h"

@interface SFIRouterDevicesListViewController ()

@end

@implementation SFIRouterDevicesListViewController
@synthesize deviceList;
@synthesize deviceListType;
@synthesize listAvailableColors, currentColor, currentColorIndex;

static NSString *simpleTableIdentifier = @"DeviceCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Device List: %d", [self.deviceList count]);
    NSLog(@"Device List Type: %d", self.deviceListType);
    
    //    //TODO : Remove Later - For testing
//    SFIConnectedDevice *device1 = [[SFIConnectedDevice alloc]init];
//    device1.name = @"ashutosh";
//    device1.deviceIP = @"1678379540";
//    device1.deviceMAC = @"10:60:4b:d9:60:84";
//
//    SFIConnectedDevice *device2 = [[SFIConnectedDevice alloc]init];
//    device2.name = @"android-c95b260";
//    device2.deviceIP = @"1728711188";
//    device2.deviceMAC = @"3c:43:8e:b2:1a:9b";
//
//    self.deviceList  = [NSArray arrayWithObjects:device1, device2,nil];
//    self.deviceListType = 2;
    
//    SFIWirelessSetting *device1 = [[SFIWirelessSetting alloc]init];
//    device1.ssid = @"AlmondNetwork";
//    device1.password = @"1234567890";
//    device1.channel = @"1";
//    device1.encryptionType = @"AES";
//    device1.security = @"WPA2PSK";
//    
//    SFIWirelessSetting *device2 = [[SFIWirelessSetting alloc]init];
//    device2.ssid = @"Guest";
//    device2.password = @"1111222200";
//    device2.channel = @"1";
//    device2.encryptionType = @"AES";
//    device2.security = @"WPA2PSK";
//    
//    self.deviceList  = [NSArray arrayWithObjects:device1, device2,nil];
    
    //    SFIBlockedDevice *device1 = [[SFIBlockedDevice alloc]init];
    //    device1.deviceMAC = @"10:60:4b:d9:60:84";
    //
    //    SFIBlockedDevice *device2 = [[SFIBlockedDevice alloc]init];
    //    device2.deviceMAC = @"3c:43:8e:b2:1a:9b";
    //
    //    self.deviceList  = [NSArray arrayWithObjects:device1, device2,nil];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if(deviceListType == 2){
        self.navigationItem.title = @"Connected Devices";
    }else if (deviceListType == 3){
        self.navigationItem.title = @"Blocked Devices";
    }else if (deviceListType == 5){
        self.navigationItem.title = @"Blocked Content";
    }else if (deviceListType == 7){
        self.navigationItem.title = @"Settings";
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    //NSString *colorCode = [prefs stringForKey:COLORCODE];
    
//    if(colorCode!=nil){
//        currentColor = [listAvailableColors objectAtIndex:[colorCode integerValue]];
//    }else{
//        currentColor = [listAvailableColors objectAtIndex:self.currentColorIndex];
//    }

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DynamicAlmondListDeleteCallback:)
                                                    name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                  object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
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
    // Return the number of rows in the section.
    return [self.deviceList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(deviceListType == 2){
        return 90;
    }else if (deviceListType == 7){
        return 230;
    }
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    
    if(deviceListType == 2){
        cell = [self createConnectedListCell:cell listRow:indexPath.row];
    }else if (deviceListType == 3){
        cell = [self createBlockedListCell:cell listRow:indexPath.row];
    }else if (deviceListType == 5){
        cell = [self createBlockedContentListCell:cell listRow:indexPath.row];
    }else if (deviceListType == 7){
        cell = [self createSettingsListCell:cell listRow:indexPath.row];
    }
    
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    //    SFIConnectedDevice *currentDevice = [self.connectedDevices objectAtIndex:indexPath.row];
    //    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", currentDevice.name, currentDevice.deviceIP];
    //    cell.detailTextLabel.text = currentDevice.deviceMAC;
    
    return cell;
}

#pragma mark - Table cell creation

-(UITableViewCell*) createConnectedListCell: (UITableViewCell*)cell listRow:(int)indexPathRow{
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    SFIConnectedDevice *currentDevice = [self.deviceList objectAtIndex:indexPathRow];
    
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,1,self.tableView.frame.size.width-20,80)];
    backgroundLabel.userInteractionEnabled = YES;
    
    backgroundLabel.backgroundColor = [UIColor colorWithHue:196.0/360.0 saturation:100/100.0 brightness:100/100.0 alpha:1];
    
    
    
    UILabel *lblDeviceName = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 280, 20)];
    lblDeviceName.backgroundColor = [UIColor clearColor];
    lblDeviceName.textColor = [UIColor whiteColor];
    [lblDeviceName setFont:[UIFont fontWithName:@"Avenir-Heavy" size:16]];
    lblDeviceName.text = currentDevice.name;
    [backgroundLabel addSubview:lblDeviceName];
    
    UILabel *lblDeviceIP = [[UILabel alloc]initWithFrame:CGRectMake(15, 30, 280, 30)];
    lblDeviceIP.backgroundColor = [UIColor clearColor];
    lblDeviceIP.textColor = [UIColor whiteColor];
    [lblDeviceIP setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    
    
    //Get IP address
    //Step 1: Conversion from decimal to hexadecimal
    NSString *hexIP = [NSString stringWithFormat:@"%lX", (long)[currentDevice.deviceIP integerValue]];
    //NSLog(@"%@", hexIP);
    
    NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:([hexIP length]/2)];
    //Step 2: Divide in pairs of 2 hex
    for (int i=0; i < [hexIP length]; i=i+2) {
        NSString *ichar  = [NSString stringWithFormat:@"%c%c", [hexIP characterAtIndex:i], [hexIP characterAtIndex:i+1]];
        //NSLog(@"Character spilt : %@", ichar);
        unsigned result = 0;
        //Step 3: Convert to decimal
        NSScanner *scanner = [NSScanner scannerWithString:ichar];
        [scanner scanHexInt:&result];
        [characters addObject:[NSString stringWithFormat:@"%d", result]];
    }
    
    //Step 4: Reverse and display
    lblDeviceIP.text = [NSString stringWithFormat:@"Device IP:      %@.%@.%@.%@", [characters objectAtIndex:3],[characters objectAtIndex:2],[characters objectAtIndex:1],[characters objectAtIndex:0]];
    
    //  lblDeviceIP.text = [NSString stringWithFormat:@"Device IP:      %@", currentDevice.deviceIP];
    
    [backgroundLabel addSubview:lblDeviceIP];
    
    UILabel *lblDeviceMAC = [[UILabel alloc]initWithFrame:CGRectMake(15, 50, 280, 30)];
    lblDeviceMAC.backgroundColor = [UIColor clearColor];
    lblDeviceMAC.textColor = [UIColor whiteColor];
    [lblDeviceMAC setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    lblDeviceMAC.text = [NSString stringWithFormat:@"Device MAC: %@",  [currentDevice.deviceMAC uppercaseString]];
    [backgroundLabel addSubview:lblDeviceMAC];
    
    [cell addSubview:backgroundLabel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(UITableViewCell*) createBlockedListCell: (UITableViewCell*)cell listRow:(int)indexPathRow{
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    SFIBlockedDevice *currentDevice = [self.deviceList objectAtIndex:indexPathRow];
    
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,1,self.tableView.frame.size.width-20,50)];
    backgroundLabel.userInteractionEnabled = YES;
    
    backgroundLabel.backgroundColor = [UIColor colorWithHue:196.0/360.0 saturation:100/100.0 brightness:100/100.0 alpha:1];
    
    UILabel *lblDeviceMAC = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 280, 20)];
    lblDeviceMAC.backgroundColor = [UIColor clearColor];
    lblDeviceMAC.textColor = [UIColor whiteColor];
    [lblDeviceMAC setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
    lblDeviceMAC.text = [NSString stringWithFormat:@"Device MAC: %@",  [currentDevice.deviceMAC uppercaseString]];
    [backgroundLabel addSubview:lblDeviceMAC];
    
    [cell addSubview:backgroundLabel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(UITableViewCell*) createBlockedContentListCell: (UITableViewCell*)cell listRow:(int)indexPathRow{
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    SFIBlockedContent *currentDevice = [self.deviceList objectAtIndex:indexPathRow];
    
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,1,self.tableView.frame.size.width-20,50)];
    backgroundLabel.userInteractionEnabled = YES;
    
    backgroundLabel.backgroundColor = [UIColor colorWithHue:196.0/360.0 saturation:100/100.0 brightness:100/100.0 alpha:1];
    
    UILabel *lblBlockedText = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 280, 20)];
    lblBlockedText.backgroundColor = [UIColor clearColor];
    lblBlockedText.textColor = [UIColor whiteColor];
    [lblBlockedText setFont:[UIFont fontWithName:@"Avenir-Heavy" size:14]];
    lblBlockedText.text = [NSString stringWithFormat:@"Blocked Text: %@",  currentDevice.blockedText];
    [backgroundLabel addSubview:lblBlockedText];
    
    [cell addSubview:backgroundLabel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(UITableViewCell*) createSettingsListCell: (UITableViewCell*)cell listRow:(int)indexPathRow{
    //PY 070114
    //START: HACK FOR MEMORY LEAKS
    for(UIView *currentView in cell.contentView.subviews){
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    SFIWirelessSetting *currentDevice = [self.deviceList objectAtIndex:indexPathRow];
    

    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,1,self.tableView.frame.size.width-20,220)];
    backgroundLabel.userInteractionEnabled = YES;
    
    switch(indexPathRow){
		case 0:
		{
			currentColor = [listAvailableColors objectAtIndex:3]; //Pink
			break;
		}
		case 1:
		{
			currentColor = [listAvailableColors objectAtIndex:0]; //Blue
			break;
		}
		default:
			currentColor  = [listAvailableColors objectAtIndex:1];  //Green
    }
    
    backgroundLabel.backgroundColor = [UIColor colorWithHue:currentColor.hue/360.0 saturation:currentColor.saturation/100.0 brightness:currentColor.brightness/100.0 alpha:1];
    
    
    
    UILabel *lblSSID = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 220, 20)];
    lblSSID.backgroundColor = [UIColor clearColor];
    lblSSID.textColor = [UIColor whiteColor];
    [lblSSID setFont:[UIFont fontWithName:@"Avenir-Light" size:20]];
    lblSSID.text = currentDevice.ssid; //[NSString stringWithFormat:@"SSID: %@",  currentDevice.ssid];
    [backgroundLabel addSubview:lblSSID];
    
    UIImageView *imgLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 35, self.tableView.frame.size.width-30, 1)];
    imgLine1.image = [UIImage imageNamed:@"line.png"];
    imgLine1.alpha = 0.5;
    [backgroundLabel addSubview:imgLine1];


    
    UILabel *lblPassword = [[UILabel alloc]initWithFrame:CGRectMake(15, 32, 100, 30)];
    lblPassword.backgroundColor = [UIColor clearColor];
    lblPassword.textColor = [UIColor whiteColor];
    [lblPassword setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    lblPassword.text = @"Password";
    [backgroundLabel addSubview:lblPassword];
    
    UILabel *txtPassword = [[UILabel alloc]initWithFrame:CGRectMake(115, 32, self.tableView.frame.size.width-155, 30)];
    txtPassword.backgroundColor = [UIColor clearColor];
    txtPassword.textColor = [UIColor whiteColor];
    [txtPassword setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    txtPassword.text = currentDevice.password;
    txtPassword.textAlignment = NSTextAlignmentRight;
    [backgroundLabel addSubview:txtPassword];
    
    UIImageView *imgLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 60, self.tableView.frame.size.width-30, 1)];
    imgLine2.image = [UIImage imageNamed:@"line.png"];
    imgLine2.alpha = 0.5;
    [backgroundLabel addSubview:imgLine2];
    
    UILabel *lblChannel = [[UILabel alloc]initWithFrame:CGRectMake(15, 62, 100, 30)];
    lblChannel.backgroundColor = [UIColor clearColor];
    lblChannel.textColor = [UIColor whiteColor];
    [lblChannel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    lblChannel.text = @"Channel";
    [backgroundLabel addSubview:lblChannel];
    
    
    UILabel *txtChannel = [[UILabel alloc]initWithFrame:CGRectMake(115, 62, self.tableView.frame.size.width-155, 30)];
    txtChannel.backgroundColor = [UIColor clearColor];
    txtChannel.textColor = [UIColor whiteColor];
    [txtChannel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    txtChannel.text = [NSString stringWithFormat:@"%d",  currentDevice.channel];
    txtChannel.textAlignment = NSTextAlignmentRight;
    [backgroundLabel addSubview:txtChannel];
    
    UIImageView *imgLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 90, self.tableView.frame.size.width-30, 1)];
    imgLine3.image = [UIImage imageNamed:@"line.png"];
    imgLine3.alpha = 0.5;
    [backgroundLabel addSubview:imgLine3];

    UILabel *lblEncryptionType = [[UILabel alloc]initWithFrame:CGRectMake(15, 92, 280, 30)];
    lblEncryptionType.backgroundColor = [UIColor clearColor];
    lblEncryptionType.textColor = [UIColor whiteColor];
    [lblEncryptionType setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    lblEncryptionType.text = @"Encryption Type";
    [backgroundLabel addSubview:lblEncryptionType];
    
    UILabel *txtEncryptionType = [[UILabel alloc]initWithFrame:CGRectMake(115, 92, self.tableView.frame.size.width-155, 30)];
    txtEncryptionType.backgroundColor = [UIColor clearColor];
    txtEncryptionType.textColor = [UIColor whiteColor];
    [txtEncryptionType setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    txtEncryptionType.text = currentDevice.encryptionType;
    txtEncryptionType.textAlignment = NSTextAlignmentRight;
    [backgroundLabel addSubview:txtEncryptionType];
    
    UIImageView *imgLine4 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 120, self.tableView.frame.size.width-30, 1)];
    imgLine4.image = [UIImage imageNamed:@"line.png"];
    imgLine4.alpha = 0.5;
    [backgroundLabel addSubview:imgLine4];
    
    
    UILabel *lblSecurity = [[UILabel alloc]initWithFrame:CGRectMake(15, 122, 280, 30)];
    lblSecurity.backgroundColor = [UIColor clearColor];
    lblSecurity.textColor = [UIColor whiteColor];
    [lblSecurity setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    lblSecurity.text = @"Security";
    [backgroundLabel addSubview:lblSecurity];
    
    UILabel *txtSecurity = [[UILabel alloc]initWithFrame:CGRectMake(115, 122, self.tableView.frame.size.width-155, 30)];
    txtSecurity.backgroundColor = [UIColor clearColor];
    txtSecurity.textColor = [UIColor whiteColor];
    [txtSecurity setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    txtSecurity.text = currentDevice.security;
    txtSecurity.textAlignment = NSTextAlignmentRight;
    [backgroundLabel addSubview:txtSecurity];
    
    UIImageView *imgLine5 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 150, self.tableView.frame.size.width-30, 1)];
    imgLine5.image = [UIImage imageNamed:@"line.png"];
    imgLine5.alpha = 0.5;
    [backgroundLabel addSubview:imgLine5];
    
    
    UILabel *lblWirelessMode = [[UILabel alloc]initWithFrame:CGRectMake(15, 152, 280, 30)];
    lblWirelessMode.backgroundColor = [UIColor clearColor];
    lblWirelessMode.textColor = [UIColor whiteColor];
    [lblWirelessMode setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    lblWirelessMode.text = @"Wireless Mode";
    [backgroundLabel addSubview:lblWirelessMode];
    
    UILabel *txtWirelessMode = [[UILabel alloc]initWithFrame:CGRectMake(115, 152, self.tableView.frame.size.width-155, 30)];
    txtWirelessMode.backgroundColor = [UIColor clearColor];
    txtWirelessMode.textColor = [UIColor whiteColor];
    [txtWirelessMode setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    txtWirelessMode.text = currentDevice.wirelessMode;
    txtWirelessMode.textAlignment = NSTextAlignmentRight;
    [backgroundLabel addSubview:txtWirelessMode];
    
    
    UIImageView *imgLine6 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 180, self.tableView.frame.size.width-30, 1)];
    imgLine6.image = [UIImage imageNamed:@"line.png"];
    imgLine6.alpha = 0.5;
    [backgroundLabel addSubview:imgLine6];
    
    UILabel *lblCountryRegion = [[UILabel alloc]initWithFrame:CGRectMake(15, 182, 280, 30)];
    lblCountryRegion.backgroundColor = [UIColor clearColor];
    lblCountryRegion.textColor = [UIColor whiteColor];
    [lblCountryRegion setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    lblCountryRegion.text = @"Country Region";
    [backgroundLabel addSubview:lblCountryRegion];
    
    UILabel *txtCountryRegion = [[UILabel alloc]initWithFrame:CGRectMake(115, 182, self.tableView.frame.size.width-155, 30)];
    txtCountryRegion.backgroundColor = [UIColor clearColor];
    txtCountryRegion.textColor = [UIColor whiteColor];
    [txtCountryRegion setFont:[UIFont fontWithName:@"Avenir-Heavy" size:12]];
    txtCountryRegion.text =  [NSString stringWithFormat:@"%d",  currentDevice.countryRegion];
    txtCountryRegion.textAlignment = NSTextAlignmentRight;
    [backgroundLabel addSubview:txtCountryRegion];
    
    UIImageView *imgLine7 = [[UIImageView alloc] initWithFrame:CGRectMake(5, 210, self.tableView.frame.size.width-30, 1)];
    imgLine7.image = [UIImage imageNamed:@"line.png"];
    imgLine7.alpha = 0.5;
    [backgroundLabel addSubview:imgLine7];
    
    [cell addSubview:backgroundLabel];

    
    UIImageView *imgSettings = [[UIImageView alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width-50, 7, 23, 23)];
    imgSettings.image = [UIImage imageNamed:@"icon_config.png"];
    imgSettings.alpha = 0.5;
    imgSettings.userInteractionEnabled = YES;
    
    
    UIButton *btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.frame = imgSettings.bounds;
    btnSettings.backgroundColor = [UIColor clearColor];
    [btnSettings addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [imgSettings addSubview:btnSettings];
    
    UIButton *btnSettingsCell = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettingsCell.frame = CGRectMake(self.tableView.frame.size.width-70, 0, 60, 40);
    btnSettingsCell.backgroundColor = [UIColor clearColor];
    [btnSettingsCell addTarget:self action:@selector(onSettingClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btnSettingsCell];
    
    
    btnSettingsCell.tag = indexPathRow;
    btnSettings.tag = indexPathRow;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addSubview:imgSettings];
    return cell;
}

#pragma mark - Class methods
-(void)onSettingClicked:(id)sender {
    UIButton *btn = (UIButton*) sender;
    NSLog(@"Settings Index Clicked: %ld", (long)btn.tag);
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIWirelessViewController"];
//    SFIWirelessViewController *viewController = (SFIWirelessViewController*)mainView;
//    SFIWirelessSetting *currentSetting = [self.deviceList objectAtIndex:(long)btn.tag];
//    viewController.currentSetting = currentSetting;
//    viewController.selectedValueDelegate=self;
    
    //viewController.currentSetting = [self.deviceList objectAtIndex:(long)btn.tag];
    
    SFIWirelessTableViewController *viewController = [[SFIWirelessTableViewController alloc]init];
    SFIWirelessSetting *currentSetting = [self.deviceList objectAtIndex:(long)btn.tag];
    viewController.currentSetting = currentSetting;
    viewController.selectedValueDelegate=self;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)refreshedList:(NSArray *)refreshedDeviceList{
    NSLog(@"device list count: %d", [refreshedDeviceList count]);
    self.deviceList = refreshedDeviceList;
    [self.tableView reloadData];
}

#pragma mark - Cloud command handlers

-(void)DynamicAlmondListDeleteCallback:(id)sender{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received DynamicAlmondListCallback", __PRETTY_FUNCTION__];
        
        AlmondListResponse *obj = [[AlmondListResponse alloc] init];
        obj = (AlmondListResponse *)[data valueForKey:@"data"];
        
        
        if(obj.isSuccessful){
            
            [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__,[obj.almondPlusMACList count]];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *currentMAC = [prefs objectForKey:CURRENT_ALMOND_MAC];
            
            SFIAlmondPlus *deletedAlmond = [obj.almondPlusMACList objectAtIndex:0];
            if([currentMAC isEqualToString:deletedAlmond.almondplusMAC]){
                [SNLog Log:@"Method Name: %s Remove this view", __PRETTY_FUNCTION__];
                NSMutableArray *almondList = [SFIOfflineDataManager readAlmondList];
                NSString *currentMACName;
                
                if([almondList count]!=0){
                    SFIAlmondPlus *currentAlmond = [almondList objectAtIndex:0];
                    currentMAC = currentAlmond.almondplusMAC;
                    currentMACName = currentAlmond.almondplusName;
                    [prefs setObject:currentMAC forKey:CURRENT_ALMOND_MAC];
                    [prefs setObject:currentMACName forKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs synchronize];
                    self.navigationItem.title = currentMACName;
                }else{
                    currentMAC = NO_ALMOND;
                    self.navigationItem.title = @"Get Started";
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
                    [prefs synchronize];
                }
                
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        }
        
    }
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
