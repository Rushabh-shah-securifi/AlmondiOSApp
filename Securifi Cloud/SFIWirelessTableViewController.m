//
//  SFIWirelessTableViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 14/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIWirelessTableViewController.h"
#import "SNLog.h"
#import "SFIGenericRouterCommand.h"
#import "AlmondPlusConstants.h"
#import "SFIParser.h"
#import "SFIDevicesList.h"
#import "SFIOptionViewController.h"
#import "SFIOfflineDataManager.h"

@interface SFIWirelessTableViewController ()

@end

@implementation SFIWirelessTableViewController
@synthesize mobileInternalIndex, currentSetting;
@synthesize selectedValueDelegate;
@synthesize ssid, password, wirelessMode;
@synthesize lblChannel, lblEncryption, lblSecurity, lblWirelessMode;
@synthesize optionType, countryChannelMap, encryptionSecurityMap, wirelessModeIntergerMap;

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
    self.navigationItem.title = @"Edit Settings";
    //Mapping for Country code channel
    //    WPAPSKWPA2PSK - TKIPAES
    //    WPA2PSK - AES
    //    WPAPSK - TKIP
    //    WEPAUTO - WEP
    //    OPEN - None
    encryptionSecurityMap = [[NSMutableDictionary alloc]init];
    [encryptionSecurityMap setObject:@"TKIPAES" forKey:@"WPAPSKWPA2PSK"];
    [encryptionSecurityMap setObject:@"AES" forKey:@"WPA2PSK"];
    [encryptionSecurityMap setObject:@"TKIP" forKey:@"WPAPSK"];
    [encryptionSecurityMap setObject:@"WEP" forKey:@"WEPAUTO"];
    [encryptionSecurityMap setObject:@"None" forKey:@"OPEN"];
    
    
    //Wireless Mode - Integer
    wirelessModeIntergerMap = [[NSMutableDictionary alloc]init];
    [wirelessModeIntergerMap setObject:@"0" forKey:@"Legacy 802.11b/g"];
    [wirelessModeIntergerMap setObject:@"1" forKey:@"Legacy 802.11b"];
    [wirelessModeIntergerMap setObject:@"2" forKey:@"Legacy 802.11a"];
    [wirelessModeIntergerMap setObject:@"3" forKey:@"Legacy 802.11a/b/g"];
    [wirelessModeIntergerMap setObject:@"4" forKey:@"Legacy 802.11g"];
    [wirelessModeIntergerMap setObject:@"5" forKey:@"802.11a/b/g/n"];
    [wirelessModeIntergerMap setObject:@"6" forKey:@"802.11n"];
    [wirelessModeIntergerMap setObject:@"7" forKey:@"802.11g/n"];
    [wirelessModeIntergerMap setObject:@"8" forKey:@"802.11a/n"];
    [wirelessModeIntergerMap setObject:@"9" forKey:@"802.11b/g/n"];
    [wirelessModeIntergerMap setObject:@"10" forKey:@"802.11a/g/n"];
    
    
    //Encryption According to Security
    //    CountryRegion     | Allowed	Channels	|
    //    ============================|
    //    | 0			  | 	 1 ~ 11              |
    //    | 1			  | 	 1 ~ 12              |
    //    | 2			  | 	 10, 11              |
    //    | 3			  | 	 10 ~ 13            |
    //    | 4			  | 	 14                    |
    //    | 5			  | 	 1 ~ 14              |
    //    | 6			  | 	 3 ~ 9                |
    //    | 7			  | 	 5 ~ 13              |
    //    ============================|
    countryChannelMap = [[NSMutableDictionary alloc]init];
    NSArray *countryRegion0 = [NSArray arrayWithObjects: @"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11", nil];
    
    NSArray *countryRegion1 = [NSArray arrayWithObjects: @"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11", @"12", nil];
    NSArray *countryRegion2 = [NSArray arrayWithObjects: @"10",@"11", nil];
    NSArray *countryRegion3 = [NSArray arrayWithObjects: @"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11", @"12", @"13", nil];
    NSArray *countryRegion4 = [NSArray arrayWithObjects: @"14", nil];
    NSArray *countryRegion5 = [NSArray arrayWithObjects: @"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14", nil];
    NSArray *countryRegion6 = [NSArray arrayWithObjects: @"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    NSArray *countryRegion7 = [NSArray arrayWithObjects: @"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13", nil];
    
    [countryChannelMap setObject:countryRegion0 forKey:@"0"];
    [countryChannelMap setObject:countryRegion1 forKey:@"1"];
    [countryChannelMap setObject:countryRegion2 forKey:@"2"];
    [countryChannelMap setObject:countryRegion3 forKey:@"3"];
    [countryChannelMap setObject:countryRegion4 forKey:@"4"];
    [countryChannelMap setObject:countryRegion5 forKey:@"5"];
    [countryChannelMap setObject:countryRegion6 forKey:@"6"];
    [countryChannelMap setObject:countryRegion7 forKey:@"7"];
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(setWirelessSettingHandler:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    //self.tableView.separatorColor = [UIColor clearColor];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GenericResponseCallback:)
                                                 name:GENERIC_COMMAND_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DynamicAlmondListDeleteCallback:)
                                                    name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                  object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GENERIC_COMMAND_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                    name:DYNAMIC_ALMOND_LIST_DELETE_NOTIFIER
                                                  object:nil];
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
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,1,self.tableView.frame.size.width-20,40)];
    backgroundLabel.userInteractionEnabled = YES;
    //backgroundLabel.backgroundColor = [UIColor colorWithHue:196.0/360.0 saturation:100/100.0 brightness:100/100.0 alpha:1];
    backgroundLabel.backgroundColor = [UIColor clearColor];
    
    UILabel *lblSettingName = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, 120, 20)];
    lblSettingName.backgroundColor = [UIColor clearColor];
    //lblSettingName.textColor = [UIColor whiteColor];
    [lblSettingName setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch(indexPath.row){
        case 0:
        {
            lblSettingName.text = @"SSID";
            ssid = [[UITextField alloc]initWithFrame:CGRectMake(125, 10, self.tableView.frame.size.width - 175, 31)];
            ssid.textColor = [UIColor blackColor];
            ssid.delegate =self;
            ssid.text = currentSetting.ssid;
            [ssid setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
            [ssid setTextAlignment:NSTextAlignmentRight];
            ssid.textColor = [UIColor grayColor];
            [backgroundLabel addSubview:ssid];
        }
            break;
        case 1:
        {
            lblSettingName.text = @"Password";
            password = [[UITextField alloc]initWithFrame:CGRectMake(125, 10, self.tableView.frame.size.width - 175, 31)];
            password.textColor = [UIColor blackColor];
            password.delegate =self;
            password.text = currentSetting.password;
            password.textColor = [UIColor grayColor];
            [password setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
              [password setTextAlignment:NSTextAlignmentRight];
            [backgroundLabel addSubview:password];
        }
            break;
        case 2:{
            //Label and Textfield
            lblSettingName.text = @"Wireless Mode";
            lblWirelessMode = [[UILabel alloc]initWithFrame:CGRectMake(125, 10, self.tableView.frame.size.width - 175, 20)];
            lblWirelessMode.backgroundColor = [UIColor clearColor];
            lblWirelessMode.textColor = [UIColor grayColor];
            [lblWirelessMode setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
            lblWirelessMode.text = currentSetting.wirelessMode;
            [lblWirelessMode setTextAlignment:NSTextAlignmentRight];
            [backgroundLabel addSubview:lblWirelessMode];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 3:
        {
            lblSettingName.text = @"Channel";
            lblChannel = [[UILabel alloc]initWithFrame:CGRectMake(125, 10, self.tableView.frame.size.width - 175, 20)];
            lblChannel.backgroundColor = [UIColor clearColor];
            [lblChannel setTextAlignment:NSTextAlignmentRight];
            lblChannel.textColor = [UIColor grayColor];
            [lblChannel setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
            lblChannel.text = [NSString stringWithFormat:@"%d", currentSetting.channel];
            [backgroundLabel addSubview:lblChannel];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 4:
        {
            lblSettingName.text = @"Security";
            lblSecurity = [[UILabel alloc]initWithFrame:CGRectMake(125, 10, self.tableView.frame.size.width - 175, 20)];
            lblSecurity.backgroundColor = [UIColor clearColor];
            lblSecurity.textColor = [UIColor grayColor];
            [lblSecurity setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
            lblSecurity.text = currentSetting.security;
              [lblSecurity setTextAlignment:NSTextAlignmentRight];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [backgroundLabel addSubview:lblSecurity];
        }
            break;
        case 5:
        {
            lblSettingName.text = @"Encryption Type";
            lblSettingName.textColor = [UIColor grayColor];
            lblEncryption = [[UILabel alloc]initWithFrame:CGRectMake(125, 10, self.tableView.frame.size.width - 175, 20)];
            lblEncryption.backgroundColor = [UIColor clearColor];
            lblEncryption.textColor = [UIColor grayColor];
            [lblEncryption setFont:[UIFont fontWithName:@"Avenir-Light" size:15]];
              [lblEncryption setTextAlignment:NSTextAlignmentRight];
            lblEncryption.text = currentSetting.encryptionType;
            [backgroundLabel addSubview:lblEncryption];
            
        }
            break;
    }
    
    [backgroundLabel addSubview:lblSettingName];
    [cell addSubview:backgroundLabel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    currentSetting.ssid = self.ssid.text;
    currentSetting.password = self.password.text;
    
    NSLog(@"Row Clicked %d", indexPath.row);
    NSArray *optionList = [[NSArray alloc]init];
    SFIOptionViewController *viewController =[[SFIOptionViewController alloc] init];
    if(indexPath.row == 2){
        //Wireless Mode
        self.optionType = 2;
        optionList  = [NSArray arrayWithObjects:@"Legacy 802.11b/g",@"Legacy 802.11b",@"Legacy 802.11a",@"Legacy 802.11a/b/g",@"Legacy 802.11g",@"802.11a/b/g/n",@"802.11n",@"802.11g/n",@"802.11a/n",@"802.11b/g/n",@"802.11a/g/n",nil];
        //Display list
        viewController.optionList = optionList;
        viewController.optionTitle = @"Wireless Mode";
        viewController.optionType = self.optionType;
        viewController.currentOption = lblWirelessMode.text;
        viewController.selectedOptionDelegate=self;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }else if(indexPath.row == 3){
        //Channel
        self.optionType = 3;
        switch(currentSetting.countryRegion){
            case 0:
                optionList = [countryChannelMap objectForKey:@"0"];
                break;
            case 1:
                optionList = [countryChannelMap objectForKey:@"1"];
                break;
            case 2:
                optionList = [countryChannelMap objectForKey:@"2"];
                break;
            case 3:
                optionList = [countryChannelMap objectForKey:@"3"];
                break;
            case 4:
                optionList = [countryChannelMap objectForKey:@"4"];
                break;
            case 5:
                optionList = [countryChannelMap objectForKey:@"5"];
                break;
            case 6:
                optionList = [countryChannelMap objectForKey:@"6"];
                break;
            case 7:
                optionList = [countryChannelMap objectForKey:@"7"];
                break;
            default:
                optionList = nil;
        }
        //Display list
        viewController.optionList = optionList;
        viewController.optionType = self.optionType;
        viewController.selectedOptionDelegate=self;
        viewController.optionTitle = @"Channel";
        viewController.currentOption = lblChannel.text;
        [self.navigationController pushViewController:viewController animated:YES];
        
        
    }else if(indexPath.row == 4){
        //Security
        self.optionType = 4;
        optionList  = [NSArray arrayWithObjects:@"WPAPSKWPA2PSK", @"WPA2PSK", @"WPAPSK",@"WEPAUTO",@"OPEN", nil];
        //Display list
        viewController.optionList = optionList;
        viewController.optionType = self.optionType;
        viewController.selectedOptionDelegate=self;
        viewController.optionTitle = @"Security";
        viewController.currentOption = lblSecurity.text;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    //NSLog(@"Option List count: %d", [optionList count]);
    
    
    
    
}



#pragma mark - Cloud commands and handlers
- (IBAction)setWirelessSettingHandler:(id)sender{
    //Option to set wireless settings
    NSLog(@"Set settings");
    
    if ([currentSetting.security isEqualToString:@"WPAPSKWPA2PSK"]){
        if ([self.password.text length]  < WPAWPA2_MIN_CHAR_COUNT){
            [self showAlertBox:currentSetting.security currentPassword:self.password.text];
            NSLog(@"1 Password not valid");
            return;
        }
    }else if ([currentSetting.security isEqualToString:@"WPA2PSK"]){
        if ([self.password.text length]  < WPA2_MIN_CHAR_COUNT){
            [self showAlertBox:currentSetting.security currentPassword:self.password.text];
            NSLog(@"2 Password not valid");
            return;
        }
    }else if ([currentSetting.security isEqualToString:@"WPAPSK"]){
        if ([self.password.text length]  < WPA_MIN_CHAR_COUNT){
            [self showAlertBox:currentSetting.security currentPassword:self.password.text];
            NSLog(@"3 Password not valid");
            return;
        }
    }else if ([currentSetting.security isEqualToString:@"WEPAUTO"]){
        BOOL isPwdValid = [self checkWEPPasswordConstraints:self.password.text];
        if(!isPwdValid){
            NSLog(@"4 Password not valid");
            return;
        }
    }
    
    
    
    
    
    //<root><AlmondWirelessSettings action=\"set\" count=\"%d\"><WirelessSetting index=\"%d\"><SSID>%@</SSID><Password>%@</Password><Channel>%d</Channel><EncryptionType>%@</EncryptionType><Security>%@</Security><WirelessMode>%@</WirelessMode></WirelessSetting></AlmondWirelessSettings></root>"
    NSString *payload = [NSString stringWithFormat:SET_WIRELESS_SETTINGS_COMMAND, 1,currentSetting.index, self.ssid.text, self.password.text, currentSetting.channel,  currentSetting.encryptionType,  currentSetting.security, currentSetting.wirelessModeCode];
    NSLog(@"PAYLOAD: %@",payload);
    //
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
    //    NSArray *deviceList  = [NSArray arrayWithObjects:device1, device2,nil];
    //
    //    [[self  selectedValueDelegate]refreshedList:deviceList] ;
    //    [self.navigationController popViewControllerAnimated:YES];
    [self sendGenericCommandRequest:payload];
}

-(void) sendGenericCommandRequest:(NSString*)data{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSString *currentMAC  = [prefs objectForKey:CURRENT_ALMOND_MAC];
    
    //Generate internal index between 1 to 100
    self.mobileInternalIndex = (arc4random() % 1000) + 1;
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentMAC = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC];
    
    
    GenericCommandRequest *setWirelessSettingGenericCommand = [[GenericCommandRequest alloc] init];
    setWirelessSettingGenericCommand.almondMAC = currentMAC;
    setWirelessSettingGenericCommand.applicationID = APPLICATION_ID;
    setWirelessSettingGenericCommand.mobileInternalIndex = [NSString stringWithFormat:@"%d",self.mobileInternalIndex];
    setWirelessSettingGenericCommand.data = data;
    cloudCommand.commandType=GENERIC_COMMAND_REQUEST;
    cloudCommand.command=setWirelessSettingGenericCommand;
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
    
    cloudCommand=nil;
    setWirelessSettingGenericCommand=nil;
}


-(void)GenericResponseCallback:(id)sender
{
    [SNLog Log:@"Method Name: %s ", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received GenericCommandResponse",__PRETTY_FUNCTION__];
        
        GenericCommandResponse *obj = [[GenericCommandResponse alloc] init];
        obj = (GenericCommandResponse *)[data valueForKey:@"data"];
        
        BOOL isSuccessful = obj.isSuccessful;
        if(isSuccessful){
            NSMutableData *genericData = [[NSMutableData alloc] init];
            int expectedGenericDataLength, command;
           // NSLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
           // NSLog(@"Response Data: %@", obj.genericData);
           // NSLog(@"Decoded Data: %@", obj.decodedData);
            NSData* data =  [obj.decodedData mutableCopy];  //[obj.genericData dataUsingEncoding:NSUTF8StringEncoding];
            //NSLog(@"Data: %@", data);
            
            [genericData appendData:data];
            
            [genericData getBytes:&expectedGenericDataLength range:NSMakeRange(0, 4)];
            [SNLog Log:@"Method Name: %s Expected Length: %d", __PRETTY_FUNCTION__,expectedGenericDataLength];
            [genericData getBytes:&command range:NSMakeRange(4,4)];
            [SNLog Log:@"Method Name: %s Command: %d", __PRETTY_FUNCTION__,command];
            
            //Remove 8 bytes from received command
            [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
            
            NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
            SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:decodedString];
            NSLog(@"Command Type %d", genericRouterCommand.commandType);
            
            //Get Wireless Settings
            SFIDevicesList *routerSettings = (SFIDevicesList*)genericRouterCommand.command;
            NSLog(@"Wifi settings Reply: %d", [routerSettings.deviceList count]);
            [[self  selectedValueDelegate]refreshedList:routerSettings.deviceList] ;
            [self.navigationController popViewControllerAnimated:YES];
            //TODO: GO back to previous page and refresh the list
            //                    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
            //                    viewController.deviceList = routerSettings.deviceList;
            //                    viewController.deviceListType = genericRouterCommand.commandType;
            //                    [self.navigationController pushViewController:viewController animated:YES];
            
        }else{
            NSLog(@"Reason: %@", obj.reason);
        }
    }
}

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


-(void)optionSelected:(NSString *)optionValue forOptionType:(unsigned int)selectedOptionType{
    NSLog(@"option Value: %@ Option Type: %d", optionValue, selectedOptionType);
    if(selectedOptionType == 2){
        //Set wireless mode
        currentSetting.wirelessMode = optionValue;
        currentSetting.wirelessModeCode = [[wirelessModeIntergerMap objectForKey:optionValue] integerValue];
    }
    else if(selectedOptionType == 3){
        //Set channel
        currentSetting.channel = [optionValue integerValue];
    }else if(selectedOptionType == 4){
        //Set encryption accordingly
        currentSetting.encryptionType = [encryptionSecurityMap objectForKey:optionValue];
        currentSetting.security = optionValue;
    }
    [self.tableView reloadData];
}

#pragma mark - Keyboard Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.ssid) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        [textField resignFirstResponder];
        if ([currentSetting.security isEqualToString:@"WPAPSKWPA2PSK"]){
            if ([textField.text length]  < WPAWPA2_MIN_CHAR_COUNT){
                [self showAlertBox:currentSetting.security currentPassword:textField.text];
            }
        }else if ([currentSetting.security isEqualToString:@"WPA2PSK"]){
            if ([textField.text length]  < WPA2_MIN_CHAR_COUNT){
               [self showAlertBox:currentSetting.security currentPassword:textField.text];
            }
        }else if ([currentSetting.security isEqualToString:@"WPAPSK"]){
            if ([textField.text length]  < WPA_MIN_CHAR_COUNT){
               [self showAlertBox:currentSetting.security currentPassword:textField.text];
            }
        }else if ([currentSetting.security isEqualToString:@"WEPAUTO"]){
            [self checkWEPPasswordConstraints:textField.text];
        }
    }
    //        else if (textField == self.encryptionType){
    //            [textField resignFirstResponder];
    //            [self.security becomeFirstResponder];
    //        }else if (textField == self.security){
    //            [textField resignFirstResponder];
    //            [self.wirelessMode becomeFirstResponder];    }
    //        else if (textField == self.wirelessMode){
    //            [textField resignFirstResponder];
    //            [self setWirelessSettingsHandler:nil];
    //        }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if (textField == self.ssid) {
        return (newLength > SSID_CHAR_COUNT) ? NO : YES;
    }else if (textField == self.password){
        if ([currentSetting.security isEqualToString:@"WPAPSKWPA2PSK"]){
            return (newLength > WPAWPA2_MAX_CHAR_COUNT) ? NO : YES;
        }else if ([currentSetting.security isEqualToString:@"WPA2PSK"]){
            return (newLength > WPA2_MAX_CHAR_COUNT) ? NO : YES;
        }else if ([currentSetting.security isEqualToString:@"WPAPSK"]){
            return (newLength > WPA_MAX_CHAR_COUNT) ? NO : YES;
        }else if ([currentSetting.security isEqualToString:@"WEPAUTO"]){
            return [string canBeConvertedToEncoding:NSASCIIStringEncoding];
        }
    }
    return YES;
}


#pragma mark - Class methods

-(void)showAlertBox:(NSString*)securityType currentPassword:(NSString*)currentPassword{
    int pwdLength = 0;
    if ([securityType isEqualToString:@"WPAPSKWPA2PSK"]){
        pwdLength = WPAWPA2_MIN_CHAR_COUNT;
        securityType = @"WPA2/WPA";
    }else if ([securityType isEqualToString:@"WPA2PSK"]){
        pwdLength =  WPA2_MIN_CHAR_COUNT;
        securityType = @"WPA2";
    }else if ([securityType isEqualToString:@"WPAPSK"]){
        pwdLength = WPA_MIN_CHAR_COUNT;
        securityType = @"WPA";
    }
    NSString *alertMsg = [NSString stringWithFormat:@"%@ Password Length must be %d characters or more. Your password \"%@\" is only %d characters long", securityType, pwdLength, currentPassword, [currentPassword length]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password Length"
                                                    message:alertMsg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(BOOL) checkWEPPasswordConstraints:(NSString*)currentPassword{
    if([currentPassword length] == 5 || [currentPassword length] == 13){
        return TRUE;
    }else if([currentPassword length] == 10 || [currentPassword length] == 26){
        //Check if HEX value or not
        NSCharacterSet* nonHex = [[NSCharacterSet
                                   characterSetWithCharactersInString: @"0123456789ABCDEFabcdef"]
                                  invertedSet];
        NSRange nonHexRange = [currentPassword rangeOfCharacterFromSet: nonHex];
        BOOL isHex = (nonHexRange.location == NSNotFound);
        
        if(isHex){
            NSLog(@"Hex Value");
            return TRUE;
        }
        
//        if([[NSScanner scannerWithString:currentPassword] scanHexInt:NULL]){
//            NSLog(@"Hex Value");
//        }else{
//             NSLog(@"Non-Hex Value");
//        }
    }
    NSString *alertMsg = @"WEP ASCII Key length must be 5 or 13 characters. \n Enter 10 or 26 characters to use a HEX key.";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password Length"
                                                    message:alertMsg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    return FALSE;
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
