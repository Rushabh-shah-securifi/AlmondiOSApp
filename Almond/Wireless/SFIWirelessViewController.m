//
//  SFIWirelessViewController.m
//  Securifi Cloud
//
//  Created by Securifi-Mac2 on 14/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIWirelessViewController.h"
#import "GenericCommandRequest.h"
#import "SNLog.h"
#import "SFIGenericRouterCommand.h"
#import "AlmondPlusConstants.h"
#import "SFIParser.h"

@interface SFIWirelessViewController ()

@end





@implementation SFIWirelessViewController
@synthesize security, encryptionType, channel, password, ssid, currentSetting, wirelessMode;
@synthesize mobileInternalIndex;
@synthesize selectedValueDelegate;

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
	NSLog(@"Settings page");
    
    //Display information for wireless settings
    self.ssid.text = currentSetting.ssid;
    self.password.text = currentSetting.password;
    self.channel.text = [NSString stringWithFormat:@"%d",currentSetting.channel];
    self.encryptionType.text = currentSetting.encryptionType;
    self.security.text = currentSetting.security;
    self.wirelessMode.text = currentSetting.wirelessMode;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GenericResponseCallback:)
                                                 name:GENERIC_COMMAND_NOTIFIER
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GENERIC_COMMAND_NOTIFIER
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Cloud commands and handlers
- (IBAction)setWirelessSettingsHandler:(id)sender{
    //TODO: Option to set wireless settings
    NSLog(@"Set settings");
    //<root><AlmondWirelessSettings action=\"set\" count=\"%d\"><WirelessSetting index=\"%d\"><SSID>%@</SSID><Password>%@</Password><Channel>%d</Channel><EncryptionType>%@</EncryptionType><Security>%@</Security><WirelessMode>%@</WirelessMode></WirelessSetting></AlmondWirelessSettings></root>"
    NSString *payload = [NSString stringWithFormat:SET_WIRELESS_SETTINGS_COMMAND, 1,currentSetting.index, self.ssid.text, self.password.text, self.channel.text, currentSetting.encryptionType, self.security.text, self.wirelessMode.text];
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

- (void)sendGenericCommandRequest:(NSString *)data {
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSString *currentMAC  = [prefs objectForKey:CURRENT_ALMOND_MAC];

    //Generate internal index between 1 to 100
    self.mobileInternalIndex = (arc4random() % 1000) + 1;

    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [toolkit currentAlmond];
    NSString *currentMAC = plus.almondplusMAC;

    GenericCommandRequest *setWirelessSettingGenericCommand = [[GenericCommandRequest alloc] init];
    setWirelessSettingGenericCommand.almondMAC = currentMAC;
    setWirelessSettingGenericCommand.applicationID = APPLICATION_ID;
    setWirelessSettingGenericCommand.mobileInternalIndex = [NSString stringWithFormat:@"%d", self.mobileInternalIndex];
    setWirelessSettingGenericCommand.data = data;

    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    cloudCommand.commandType = GENERIC_COMMAND_REQUEST;
    cloudCommand.command = setWirelessSettingGenericCommand;

    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- Generic Command Request", __PRETTY_FUNCTION__];

        NSError *error = nil;
        id ret = [[SecurifiToolkit sharedInstance] sendtoCloud:cloudCommand error:&error];

        if (ret == nil) {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__, [error localizedDescription]];
        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- Generic Command Request", __PRETTY_FUNCTION__];

    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__, exception.reason];
    }

    cloudCommand = nil;
    setWirelessSettingGenericCommand = nil;
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
            NSLog(@"Local Mobile Internal Index: %d Cloud Mobile Internal Index: %d", self.mobileInternalIndex, obj.mobileInternalIndex);
            NSLog(@"Response Data: %@", obj.genericData);
            NSLog(@"Decoded Data: %@", obj.decodedData);
            NSData* data =  [obj.decodedData mutableCopy];  //[obj.genericData dataUsingEncoding:NSUTF8StringEncoding];
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
            
            //Get Wireless Settings - GO back to previous page and refresh the list
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


#pragma mark - Keyboard Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.ssid) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        [textField resignFirstResponder];
        [self.channel becomeFirstResponder];
    }else if (textField == self.channel){
        [textField resignFirstResponder];
        [self.encryptionType becomeFirstResponder];
    }else if (textField == self.encryptionType){
        [textField resignFirstResponder];
        [self.security becomeFirstResponder];
    }else if (textField == self.security){
        [textField resignFirstResponder];
        [self.wirelessMode becomeFirstResponder];    }
    else if (textField == self.wirelessMode){
        [textField resignFirstResponder];
        [self setWirelessSettingsHandler:nil];
    }
    return YES;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    //Assign new frame to your view
    [self.view setFrame:CGRectMake(0,-20,self.view.frame.size.width,self.view.frame.size.height)]; //here taken -20 for example i.e. your view will be scrolled to -20. change its value according to your requirement.
    
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.view setFrame:CGRectMake(0,60,self.view.frame.size.width,self.view.frame.size.height)];
}



@end
