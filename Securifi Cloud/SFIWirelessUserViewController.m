//
//  SFIWirelessUserViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 03/01/14.
//  Copyright (c) 2014 Securifi. All rights reserved.
//

#import "SFIWirelessUserViewController.h"
#import "AlmondPlusConstants.h"
#import "SNLog.h"
#import "SFIGenericRouterCommand.h"
#import "SFIParser.h"
#import "SFIWirelessUsers.h"
#import "SFIConstants.h"
#import "SFIOfflineDataManager.h"

@implementation SFIWirelessUserViewController
@synthesize currentMAC, actionType, addBlockedDeviceList, blockedDeviceList, blockedDevices, combinedList, connectedDevices;
@synthesize currentColor, currentColorIndex, currentInternalIndex, genericData, genericString, isMobileCommandSuccessful;
@synthesize listAvailableColors, mobileCommandTimer;
@synthesize expectedGenericDataLength, command, mobileInternalIndex, totalGenericDataReceivedLength;

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
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.combinedList = [[NSMutableArray alloc]init];
    self.navigationItem.title = @"Users";
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:COLORS];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.currentMAC = [prefs objectForKey:CURRENT_ALMOND_MAC];
    listAvailableColors = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    NSString *colorCode = [prefs stringForKey:COLORCODE];
    
    if(colorCode!=nil){
        currentColor = [listAvailableColors objectAtIndex:(NSUInteger) [colorCode integerValue]];
    }else{
        currentColor = [listAvailableColors objectAtIndex:(NSUInteger) self.currentColorIndex];
    }
    
    //Navigation bar button
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Apply"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                    action:@selector(sendBlockedDevices:)];
    self.navigationItem.rightBarButtonItem = applyButton;
    
    actionType = @"";
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.dimBackground = YES;
    HUD.labelText = @"Loading user data.";
    [self loadConnectedUsers];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [ self.combinedList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return WIRELESS_USER_ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [self createColoredListCell:cell listRow:(int)indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFIWirelessUsers *currentUser = [combinedList objectAtIndex:(NSUInteger) indexPath.row];
    if(currentUser.isSelected){
        if(currentUser.isBlocked){
            actionType = @"set";
        }else{
            actionType = @"add";
        }
        currentUser.isSelected = FALSE;
    }else{
        if(currentUser.isBlocked){
            actionType = @"set";
        }else{
            actionType = @"add";
        }
        currentUser.isSelected = TRUE;
        
    }
    
    [tableView reloadData];
}

#pragma mark - Table View Cell Creation
-(UITableViewCell*) createColoredListCell: (UITableViewCell*)cell listRow:(int)indexPathRow{
    //PY 070114
    //START: HACK FOR MEMORY LEAKS
    for(UIView *currentView in cell.contentView.subviews){
        [currentView removeFromSuperview];
    }
    [cell removeFromSuperview];
    //END: HACK FOR MEMORY LEAKS
    
    UIImageView *imgStatus;
    UILabel *lblStatus;
    UILabel *lblDeviceName;
    UILabel *lblDeviceMAC;
    UILabel *lblDeviceIP;
    UILabel *lblDeviceManufacturer;
    
    //Get current user from the list
    SFIWirelessUsers *currentUser = [combinedList objectAtIndex:(NSUInteger) indexPathRow];

    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    UILabel *leftBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,5,LEFT_LABEL_WIDTH,WIRELESS_USER_ROW_HEIGHT-10)];
    [cell addSubview:leftBackgroundLabel];
    
    //Device Status Image and Label creation
    imgStatus = [[UIImageView alloc]initWithFrame:CGRectMake(LEFT_LABEL_WIDTH/4, 15, 40,40)];
    lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(0,60,LEFT_LABEL_WIDTH, 20)];
    lblStatus.backgroundColor = [UIColor clearColor];
    lblStatus.textColor = [UIColor whiteColor];
    [lblStatus setFont:[UIFont fontWithName:@"Avenir-Light" size:12]];
    lblStatus.textAlignment = NSTextAlignmentCenter;
    [leftBackgroundLabel addSubview:imgStatus];
    [leftBackgroundLabel addSubview:lblStatus];
    
    UILabel *rightBackgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake((LEFT_LABEL_WIDTH)+11,5,self.tableView.frame.size.width - LEFT_LABEL_WIDTH - 25,WIRELESS_USER_ROW_HEIGHT-10)];
    
    [cell addSubview:rightBackgroundLabel];
    
    //Details of User
    lblDeviceName = [[UILabel alloc]init];
    lblDeviceName.backgroundColor = [UIColor clearColor];
    lblDeviceName.textColor = [UIColor whiteColor];
    [lblDeviceName setFont:[UIFont fontWithName:@"Avenir-Heavy" size:16]];
    
    lblDeviceMAC = [[UILabel alloc]init];
    lblDeviceMAC.backgroundColor = [UIColor clearColor];
    lblDeviceMAC.textColor = [UIColor whiteColor];
    [lblDeviceMAC setFont:[UIFont fontWithName:@"Avenir-Light" size:12]];
    
    lblDeviceIP = [[UILabel alloc]init];
    lblDeviceIP.backgroundColor = [UIColor clearColor];
    lblDeviceIP.textColor = [UIColor whiteColor];
    [lblDeviceIP setFont:[UIFont fontWithName:@"Avenir-Light" size:12]];
    
    lblDeviceManufacturer = [[UILabel alloc]init];
    lblDeviceManufacturer.backgroundColor = [UIColor clearColor];
    lblDeviceManufacturer.textColor = [UIColor whiteColor];
    [lblDeviceManufacturer setFont:[UIFont fontWithName:@"Avenir-Light" size:12]];
    
   
    
    //Set Image
    if(currentUser.isBlocked){
        if(currentUser.isSelected){
            //Unblocked User
            imgStatus.image = [UIImage imageNamed:@"connected_user.png"];
            lblStatus.text = @"Unblocked";
            leftBackgroundLabel.backgroundColor = [UIColor colorWithHue:(CGFloat) (currentColor.hue / 360.0) saturation:(CGFloat) (currentColor.saturation / 100.0) brightness:(CGFloat) (currentColor.brightness / 100.0) alpha:1];
            rightBackgroundLabel.backgroundColor = [UIColor colorWithHue:(CGFloat) (currentColor.hue / 360.0) saturation:(CGFloat) (currentColor.saturation / 100.0) brightness:(CGFloat) (currentColor.brightness / 100.0) alpha:1];
        }else{
            //Blocked User
            imgStatus.image = [UIImage imageNamed:@"blocked_user.png"];
            lblStatus.text = @"Blocked";
            leftBackgroundLabel.backgroundColor = [UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (67 / 100.0) alpha:1];
            rightBackgroundLabel.backgroundColor = [UIColor colorWithHue:(CGFloat) (0 / 360.0) saturation:(CGFloat) (0 / 100.0) brightness:(CGFloat) (67.0 / 100.0) alpha:1];
        }
    }else{
         if(currentUser.isSelected){
             //Blocked User
             imgStatus.image = [UIImage imageNamed:@"blocked_user.png"];
             lblStatus.text = @"Blocked";
             leftBackgroundLabel.backgroundColor = [UIColor colorWithHue:(CGFloat) (currentColor.hue / 360.0) saturation:(CGFloat) (currentColor.saturation / 100.0) brightness:(CGFloat) (currentColor.brightness / 100.0) alpha:1];
             rightBackgroundLabel.backgroundColor = [UIColor colorWithHue:(CGFloat) (currentColor.hue / 360.0) saturation:(CGFloat) (currentColor.saturation / 100.0) brightness:(CGFloat) (currentColor.brightness / 100.0) alpha:1];
         }else{
             imgStatus.image = [UIImage imageNamed:@"connected_user.png"];
             lblStatus.text = @"Connected";
             leftBackgroundLabel.backgroundColor = [UIColor colorWithHue:(CGFloat) (currentColor.hue / 360.0) saturation:(CGFloat) (currentColor.saturation / 100.0) brightness:(CGFloat) (currentColor.brightness / 100.0) alpha:1];
             rightBackgroundLabel.backgroundColor = [UIColor colorWithHue:(CGFloat) (currentColor.hue / 360.0) saturation:(CGFloat) (currentColor.saturation / 100.0) brightness:(CGFloat) (currentColor.brightness / 100.0) alpha:1];
         }
    }

    //Set Name
    float baseYCordinate = -10;
    if(currentUser.manufacturer!=nil){
        baseYCordinate = -20;
    }
    
    if(currentUser.name!=nil){
        baseYCordinate = baseYCordinate+20;
        lblDeviceName.frame = CGRectMake(10,baseYCordinate,150,30);
        lblDeviceName.text = currentUser.name;
         [rightBackgroundLabel addSubview:lblDeviceName];
    }
    
    //Set MAC
    if(currentUser.deviceMAC!=nil){
        baseYCordinate = baseYCordinate+20;
        lblDeviceMAC.frame = CGRectMake(10,baseYCordinate,150,30);
        lblDeviceMAC.text = [NSString stringWithFormat:@"MAC: %@",currentUser.deviceMAC];
        [rightBackgroundLabel addSubview:lblDeviceMAC];
    }
    
    //Set IP
    if(currentUser.deviceIP!=nil){
        baseYCordinate = baseYCordinate+20;
        lblDeviceIP.frame = CGRectMake(10,baseYCordinate,150,30);
        //lblDeviceIP.text = [NSString stringWithFormat:@"IP: %@",currentUser.deviceIP];
        
        //Get IP address
        //Step 1: Conversion from decimal to hexadecimal
        NSString *hexIP = [NSString stringWithFormat:@"%lX", (long)[currentUser.deviceIP integerValue]];
        //NSLog(@"%@", hexIP);
        
        NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:([hexIP length]/2)];
        //Step 2: Divide in pairs of 2 hex
        for (int i=0; i < [hexIP length]; i=i+2) {
            NSString *ichar  = [NSString stringWithFormat:@"%c%c", [hexIP characterAtIndex:i], [hexIP characterAtIndex:i+1]];
            unsigned result = 0;
            //Step 3: Convert to decimal
            NSScanner *scanner = [NSScanner scannerWithString:ichar];
            [scanner scanHexInt:&result];
            [characters addObject:[NSString stringWithFormat:@"%d", result]];
        }
        
        //Step 4: Reverse and display
        lblDeviceIP.text = [NSString stringWithFormat:@"IP: %@.%@.%@.%@", [characters objectAtIndex:3],[characters objectAtIndex:2],[characters objectAtIndex:1],[characters objectAtIndex:0]];

        [rightBackgroundLabel addSubview:lblDeviceIP];
    }
    
    //Set Manufacturer
    if(currentUser.manufacturer!=nil){
        baseYCordinate = baseYCordinate+20;
        lblDeviceManufacturer.frame = CGRectMake(10,baseYCordinate,150,30);
        lblDeviceManufacturer.text = @"DEFAULT"; //currentUser.manufacturer;
        [rightBackgroundLabel addSubview:lblDeviceManufacturer];
    }
    

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}


#pragma mark - Class methods
-(void) loadConnectedUsers{
    
    [self sendGenericCommandRequest:GET_CONNECTED_DEVICE_COMMAND];
}

-(void) loadBlockedUsers{
     [self sendGenericCommandRequest:GET_BLOCKED_DEVICE_COMMAND];
}

-(void) processResult{
    //Combine both the results and display list
    
    for(SFIConnectedDevice *currentConnectedDevice in connectedDevices){
        SFIWirelessUsers *newUser = [[SFIWirelessUsers alloc]init];
        newUser.name = currentConnectedDevice.name;
        newUser.deviceMAC = currentConnectedDevice.deviceMAC;
        newUser.deviceIP= currentConnectedDevice.deviceIP;
        newUser.isBlocked = FALSE;
        newUser.isSelected =  FALSE;
        [combinedList addObject:newUser];
    }
    
    for(SFIBlockedDevice *currentBlockedDevice in blockedDevices){
        BOOL wasConnected = false;
        //Check if it is in the connected list
        for(SFIWirelessUsers *currentConnectedDevice in combinedList){
            if([currentBlockedDevice.deviceMAC isEqualToString:currentConnectedDevice.deviceMAC]){
                //Set it as blocked
                wasConnected = true;
                currentConnectedDevice.isBlocked = TRUE;
                break;
            }
        }
        
        if(!wasConnected){
            SFIWirelessUsers *newUser = [[SFIWirelessUsers alloc]init];
            newUser.name = nil;
            newUser.deviceMAC = currentBlockedDevice.deviceMAC;
            newUser.deviceIP= nil;
            newUser.isBlocked = TRUE;
            newUser.isSelected =  FALSE;
            [combinedList addObject:newUser];
        }
    }
    
    [HUD hide:YES];
    [self.tableView reloadData];
    
}

-(void)sendBlockedDevices:(id)sender{
    blockedDeviceList = [[NSMutableArray alloc]init];
    actionType = @"add";
    for(SFIWirelessUsers *currentDevice in combinedList){
        if(currentDevice.isSelected){
            if(currentDevice.isBlocked){
                actionType = @"set";
            }else{
                SFIBlockedDevice *newBlockedMAC = [[SFIBlockedDevice alloc]init];
                newBlockedMAC.deviceMAC = currentDevice.deviceMAC;
                [blockedDeviceList addObject:newBlockedMAC];
            }
        }
        
    }
    
	
    if([actionType isEqualToString:@"set"]){
        NSLog(@"Adding non selected blocked devices");
        //Add the non selected blocked devices also in the list to be sent
        for(SFIWirelessUsers *currentDevice in combinedList){
            if(!currentDevice.isSelected){
                if(currentDevice.isBlocked){
                    SFIBlockedDevice *newBlockedMAC = [[SFIBlockedDevice alloc]init];
                    newBlockedMAC.deviceMAC = currentDevice.deviceMAC;
                    [blockedDeviceList addObject:newBlockedMAC];
                }
            }
            
        }
    }
    
    //Create xml
    //<root>
    //<AlmondBlockedMACs action="set|add" count="2">
    //  <BlockedMAC index=”1”>10:60:4b:d9:60:84</BlockedMAC>
    // <BlockedMAC index=”2”>00:07:ab:c2:57:98</BlockedMAC>
    //</AlmondBlockedMACs>
    //</root>
    
    //Send SET/ADD Command
    NSMutableString *payload = [[NSMutableString alloc]init];
    NSString *xmlString = [NSString stringWithFormat:@"<root><AlmondBlockedMACs action=\"%@\" count=\"%lu\">", actionType, (unsigned long)[blockedDeviceList count]];
    [payload appendString:xmlString];
    int i = 1;
    for(SFIWirelessUsers *currentDevice in blockedDeviceList){
        NSString *newString = [NSString stringWithFormat:@"<BlockedMAC index=\"%d\">%@</BlockedMAC>", i, currentDevice.deviceMAC] ;
        [payload appendString:newString];
        i++;    
    }
    
    [payload appendString:@"</AlmondBlockedMACs></root>"];
    
    NSLog(@"Payload = %@", payload);
    actionType = @"";
    [self sendGenericCommandRequest:payload];
    [combinedList removeAllObjects];
}

#pragma mark - Cloud command senders and handlers

-(void) sendGenericCommandRequest:(NSString*)commandData{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSString *currentMAC  = [prefs objectForKey:CURRENT_ALMOND_MAC];
    
    //Generate internal index between 1 to 1000
    self.mobileInternalIndex = (arc4random() % 1000) + 1;
    
    GenericCommandRequest *genericCommand = [[GenericCommandRequest alloc] init];
    genericCommand.almondMAC = self.currentMAC;
    genericCommand.applicationID = APPLICATION_ID;
    genericCommand.mobileInternalIndex = [NSString stringWithFormat:@"%d",self.mobileInternalIndex];
    genericCommand.data = commandData;
    cloudCommand.commandType=GENERIC_COMMAND_REQUEST;
    cloudCommand.command=genericCommand;
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
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received GenericCommandResponse",__PRETTY_FUNCTION__];
        
        GenericCommandResponse *obj = (GenericCommandResponse *)[data valueForKey:@"data"];
        
        BOOL isSuccessful = obj.isSuccessful;
        if(isSuccessful){
            genericData = [[NSMutableData alloc] init];
            genericString = [[NSString alloc]init];
            
            //Display proper message
            NSLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
            NSLog(@"Response Data: %@", obj.genericData);
            NSLog(@"Decoded Data: %@", obj.decodedData);
            NSData* data =  [obj.decodedData mutableCopy];
            NSLog(@"Data: %@", data);
            
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
            
            switch(genericRouterCommand.commandType){
                case 2:
                {
                    //Get Connected Device List
                    SFIDevicesList *routerConnectedDevices = (SFIDevicesList*)genericRouterCommand.command;
                    NSLog(@"Connected Devices Reply: %d", [routerConnectedDevices.deviceList count]);
                    self.connectedDevices = routerConnectedDevices.deviceList;
                    [self loadBlockedUsers];
                    //Display list
//                    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//                    viewController.deviceList = routerConnectedDevices.deviceList;
//                    viewController.deviceListType = genericRouterCommand.commandType;
//                    [self.navigationController pushViewController:viewController animated:YES];
                }
                    break;
                case 3:
                {
                    //Get Blocked Device List
                    SFIDevicesList *routerBlockedDevices = (SFIDevicesList*)genericRouterCommand.command;
                    NSLog(@"Blocked Devices Reply: %d", [routerBlockedDevices.deviceList count]);
                    self.blockedDevices = routerBlockedDevices.deviceList;
                    [self processResult];
                    //Display list
//                    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//                    viewController.deviceList = routerBlockedDevices.deviceList;
//                    viewController.deviceListType = genericRouterCommand.commandType;
//                    [self.navigationController pushViewController:viewController animated:YES];
                    
                }
                    break;

             }
        }else{
            NSLog(@"Reason: %@", obj.reason);
        }
    }
}

-(void)DynamicAlmondListDeleteCallback:(id)sender{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received DynamicAlmondListCallback", __PRETTY_FUNCTION__];
        
        AlmondListResponse *obj = (AlmondListResponse *)[data valueForKey:@"data"];

        if(obj.isSuccessful){
            
            [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__,[obj.almondPlusMACList count]];
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            //NSString *currentMAC = [prefs objectForKey:CURRENT_ALMOND_MAC];
            
            SFIAlmondPlus *deletedAlmond = [obj.almondPlusMACList objectAtIndex:0];
            if([self.currentMAC isEqualToString:deletedAlmond.almondplusMAC]){
                [SNLog Log:@"Method Name: %s Remove this view", __PRETTY_FUNCTION__];
                NSMutableArray *almondList = [SFIOfflineDataManager readAlmondList];
                NSString *currentMACName;
                
                if([almondList count]!=0){
                    SFIAlmondPlus *currentAlmond = [almondList objectAtIndex:0];
                    self.currentMAC = currentAlmond.almondplusMAC;
                    currentMACName = currentAlmond.almondplusName;
                    [prefs setObject:self.currentMAC forKey:CURRENT_ALMOND_MAC];
                    [prefs setObject:currentMACName forKey:CURRENT_ALMOND_MAC_NAME];
                    [prefs synchronize];
                    self.navigationItem.title = currentMACName;
                }else{
                    self.currentMAC = NO_ALMOND;
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
