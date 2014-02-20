//
//  SFIRouterViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIRouterViewController.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SNLog.h"
#import "AlmondPlusConstants.h"
#import "SFIParser.h"
#import "SFIRouterReboot.h"
#import "SFIGenericRouterCommand.h"
#import "SFIRouterDevicesListViewController.h"
#import "SFIBlockedContentViewController.h"

@interface SFIRouterViewController ()

@end

@implementation SFIRouterViewController
@synthesize mobileInternalIndex;
@synthesize totalGenericDataReceivedLength, expectedGenericDataLength, command;
@synthesize isPartial;
@synthesize currentMAC;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                     [UIFont fontWithName:@"Avenir-Roman" size:18.0], NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.currentMAC = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC];
    NSString *currentMACName  = [standardUserDefaults objectForKey:CURRENT_ALMOND_MAC_NAME];
    if(currentMACName!=nil){
        self.navigationItem.title = currentMACName;
    }
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GenericResponseCallback:)
                                                 name:GENERIC_COMMAND_NOTIFIER
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GenericNotificationCallback:)
                                                 name:GENERIC_COMMAND_CLOUD_NOTIFIER
                                               object:nil];

}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GENERIC_COMMAND_NOTIFIER
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

#pragma mark - Class Methods
- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}


- (IBAction)rebootButtonHandler:(id)sender{
    //Send Generic Command
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"No"
                                  destructiveButtonTitle:@"Yes"
                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    //[self sendGenericCommandRequest:REBOOT_COMMAND];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            NSLog(@"Clicked on yes");
            [self sendGenericCommandRequest:REBOOT_COMMAND];
            break;
        case 1:
           NSLog(@"Clicked on no");
           break;
    }
}
- (IBAction)getConnectedDeviceHandler:(id)sender{
//    //TODO: Remove later
//    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//    [self.navigationController pushViewController:viewController animated:YES];
//    //TODO: Removed for testing
   [self sendGenericCommandRequest:GET_CONNECTED_DEVICE_COMMAND];
}

-(IBAction)getBlockedDeviceHandler:(id)sender{
   // NSLog(@"Blocked Devices");
//    //TODO: Remove Later - For testing
//    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//    viewController.deviceListType = 3;
//    [self.navigationController pushViewController:viewController animated:YES];
    [self sendGenericCommandRequest:GET_BLOCKED_DEVICE_COMMAND];
}

- (IBAction)getBlockedContentHandler:(id)sender{
     [self sendGenericCommandRequest:GET_BLOCKED_CONTENT_COMMAND];
}

- (IBAction)getWirelessSettingsHandler:(id)sender{
    //TODO: Remove Later - For testing
//    NSString *decodedString = @"<root><AlmondWirelessSettings count=\"2\">    <WirelessSetting index=\"1\">    <SSID>AlmondNetwork</SSID>    <Password>1234567890</Password>    <Channel>14</Channel>    <EncryptionType>AES</EncryptionType>    <Security>WPA2PSK</Security> <WirelessMode>802.11bgn</WirelessMode>    <CountryRegion>4</CountryRegion>   </WirelessSetting >    <WirelessSetting index=\"2\">    <SSID>Guest</SSID>    <Password>1111222200</Password>    <Channel>6</Channel>    <EncryptionType>AES</EncryptionType>    <Security>WPA2PSK</Security> <WirelessMode>802.11bgn</WirelessMode>    <CountryRegion>6</CountryRegion>   </WirelessSetting>    </AlmondWirelessSettings >    </root>";
//    SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:decodedString];
//    SFIDevicesList *routerSettings = (SFIDevicesList*)genericRouterCommand.command;
//    NSLog(@"Wifi settings Reply: %d", [routerSettings.deviceList count]);
//    //Display list
//    SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
//    viewController.deviceList = routerSettings.deviceList;
//    viewController.deviceListType = genericRouterCommand.commandType;
//    [self.navigationController pushViewController:viewController animated:YES];
    
   [self sendGenericCommandRequest:GET_WIRELESS_SETTINGS_COMMAND];
}


- (IBAction)setBlockedDeviceHandler:(id)sender{
    //TODO: Display list of connected and blocked device
    
}

- (IBAction)setBlockedContentHandler:(id)sender{
    //TODO: Display list of blocked content
    //Open view to display the current blocked content
    SFIBlockedContentViewController *viewController =[[SFIBlockedContentViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
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
        id ret = [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
        
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
    rebootGenericCommand=nil;
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
//            if (!genericData)
//            {
                genericData = [[NSMutableData alloc] init];
                genericString = [[NSString alloc]init];
//            }
            
            //TODO: Display proper message
            NSLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
            NSLog(@"Response Data: %@", obj.genericData);
            NSLog(@"Decoded Data: %@", obj.decodedData);
            NSData* data =  [obj.decodedData mutableCopy];  //[obj.genericData dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"Data: %@", data);
            
            [genericData appendData:data];
            //Reconstruction Logic - Get length
            
            
//            NSString *endTagString = @"</root>";
//            NSData *endTag = [endTagString dataUsingEncoding:NSUTF8StringEncoding];
//            
//            NSString *startTagString = @"<root>";
//            NSData *startTag = [startTagString dataUsingEncoding:NSUTF8StringEncoding];
            //Remove 8 bytes of length
            
            [genericData getBytes:&expectedGenericDataLength range:NSMakeRange(0, 4)];
            [SNLog Log:@"Method Name: %s Expected Length: %d", __PRETTY_FUNCTION__,expectedGenericDataLength];
            [genericData getBytes:&command range:NSMakeRange(4,4)];
            [SNLog Log:@"Method Name: %s Command: %d", __PRETTY_FUNCTION__,command];
            
            //Remove 8 bytes from received command
            [genericData replaceBytesInRange:NSMakeRange(0, 8) withBytes:NULL length:0];
            
            
//            if(expectedGenericDataLength > 1024){
//                
//                //Reconstruction needed - Look for 205
//                self.mobileInternalIndex = obj.mobileInternalIndex;
//                self.isPartial = TRUE;
//                NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
//                if(decodedString!=nil){
//                    totalGenericDataReceivedLength = [decodedString length];
//                    [genericString stringByAppendingString:decodedString];
//                }
//                NSLog(@"Partial Data Received Length %d", totalGenericDataReceivedLength);
//            }else{
                //Process the command normally
                //self.isPartial = FALSE;
                 NSLog(@"Complete Data");
                 NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
                SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:decodedString];
                NSLog(@"Command Type %d", genericRouterCommand.commandType);
                
                switch(genericRouterCommand.commandType){
                        
                    case 1:
                    {
                        //Reboot
                        SFIRouterReboot *routerReboot = (SFIRouterReboot*)genericRouterCommand.command;
                        NSLog(@"Reboot Reply: %d", routerReboot.reboot);
                    }
                        break;
                    case 2:
                    {
                        //Get Connected Device List
                        SFIDevicesList *routerConnectedDevices = (SFIDevicesList*)genericRouterCommand.command;
                        NSLog(@"Connected Devices Reply: %d", [routerConnectedDevices.deviceList count]);
                        //Display list
                        SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
                        viewController.deviceList = routerConnectedDevices.deviceList;
                        viewController.deviceListType = genericRouterCommand.commandType;
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                        break;
                    case 3:
                    {
                        //Get Blocked Device List
                         SFIDevicesList *routerBlockedDevices = (SFIDevicesList*)genericRouterCommand.command;
                         NSLog(@"Blocked Devices Reply: %d", [routerBlockedDevices.deviceList count]);
                         //Display list
                        SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
                        viewController.deviceList = routerBlockedDevices.deviceList;
                        viewController.deviceListType = genericRouterCommand.commandType;
                        [self.navigationController pushViewController:viewController animated:YES];
                        
                    }
                        break;
                        //TODO: Case 4: Set blocked device
                    case 5:
                    {
                        //Get Blocked Device Content
                        SFIDevicesList *routerBlockedContent = (SFIDevicesList*)genericRouterCommand.command;
                        NSLog(@"Blocked content Reply: %d", [routerBlockedContent.deviceList count]);
                        //Display list
                        SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
                        viewController.deviceList = routerBlockedContent.deviceList;
                        viewController.deviceListType = genericRouterCommand.commandType;
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                        break;
                        //TODO: Case 6: Set blocked content
                    case 7:
                    {
                        //Get Wireless Settings
                        SFIDevicesList *routerSettings = (SFIDevicesList*)genericRouterCommand.command;
                        NSLog(@"Wifi settings Reply: %d", [routerSettings.deviceList count]);
                        //Display list
                        SFIRouterDevicesListViewController *viewController =[[SFIRouterDevicesListViewController alloc] init];
                        viewController.deviceList = routerSettings.deviceList;
                        viewController.deviceListType = genericRouterCommand.commandType;
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                        break;
                        
                }
           // }
        }else{
            NSLog(@"Reason: %@", obj.reason);
        }
    }
}

-(void)GenericNotificationCallback:(id)sender
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
            NSLog(@"Response Data: %@", obj.genericData);
            NSLog(@"Decoded Data: %@", obj.decodedData);
            NSData* data =  [obj.decodedData mutableCopy];  //[obj.genericData dataUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"Data: %@", data);
            

            //Reconstruction Logic
//            if(isPartial){
//                 NSLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
//                //NSLog(@"Response Data: %@", obj.genericData);
//                if(self.mobileInternalIndex == obj.mobileInternalIndex){
//                    [genericData appendData:data];
//                    NSString *decodedString = [[NSString alloc] initWithData:genericData encoding:NSUTF8StringEncoding];
//                    totalGenericDataReceivedLength = [decodedString length];
//                   // [partialGenericString stringByAppendingString:decodedString];
//                    totalGenericDataReceivedLength = [decodedString length];
//                    NSLog(@"Partial Data Received Length %d", totalGenericDataReceivedLength);
//                    NSLog(@"Partial Data Expected Length %d", expectedGenericDataLength);
//                    if(expectedGenericDataLength == totalGenericDataReceivedLength){
//                        //TODO: Process the command
//                        NSLog(@"Process command");
//                        obj.genericData = genericString ; //[[NSString alloc]initWithData:partialGenericData encoding:NSUTF8StringEncoding];
//                         NSLog(@"Generic Data %@", obj.genericData);
//                        self.isPartial = FALSE;
//                        NSLog(@"Complete Data");
//                        SFIGenericRouterCommand *genericRouterCommand = [[SFIParser alloc] loadDataFromString:obj.genericData];
//                        NSLog(@"Command Type %d", genericRouterCommand.commandType);
//                        switch(genericRouterCommand.commandType){
//                                //Reboot
//                            case 1:
//                            {
//                                SFIRouterReboot *routerReboot = (SFIRouterReboot*)genericRouterCommand.command;
//                                NSLog(@"Reboot Reply: %d", routerReboot.reboot);
//                            }
//                                break;
//                            case 2:
//                            {
//                                SFIConnectedDevices *routerConnectedDevices = (SFIConnectedDevices*)genericRouterCommand.command;
//                                NSLog(@"Connected Devices Reply: %d", [routerConnectedDevices.connectedDevice count]);
//                                //TODO: Display list
//                                SFIConnectedDevicesListViewController *viewController =[[SFIConnectedDevicesListViewController alloc] init];
//                                viewController.connectedDevices = routerConnectedDevices.connectedDevice;
//                                [self.navigationController pushViewController:viewController animated:YES];
//                            }
//                                break;
//                        }
//                    }
//
//                }
//            }else{
                //Normal processing
                //TODO: Save it???
                 NSLog(@"Response Data: %@", obj.genericData);
            //}
//            if (!partialGenericData)
//            {
//                partialGenericData = [[NSMutableData alloc] init];
//            }
            //[partialGenericData appendData:data];
        }
    }
}

@end
