//
//  SFIDeviceDetailViewController.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 19/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIDeviceDetailViewController.h"
#import "AlmondPlusConstants.h"
#import "SFIOfflineDataManager.h"
#import "SNLog.h"

@interface SFIDeviceDetailViewController ()

@end

@implementation SFIDeviceDetailViewController
@synthesize doRefreshView;

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
//    SNFileLogger *logger = [[SNFileLogger alloc] init];
//    [[SNLog logManager] addLogStrategy:logger];
    
    self.doRefreshView = FALSE;
    [SNLog Log:@"Method Name: %s Selected Device ID is @%d Value Count: %d Device Type: %d", __PRETTY_FUNCTION__,self.deviceValue.deviceID, self.deviceValue.valueCount, self.currentDeviceType ];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.currentMAC  = [prefs objectForKey:CURRENT_ALMOND_MAC];
    
    self.currentDeviceID = [NSString stringWithFormat:@"%d",self.deviceValue.deviceID];
    
    self.deviceKnownValues = self.deviceValue.knownValues;
    [self displayActivity];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MobileCommandResponseCallback:)
                                                 name:MOBILE_COMMAND_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]    addObserver:self
                                                selector:@selector(DeviceValueListResponseCallback:)
                                                    name:DEVICE_VALUE_CLOUD_NOTIFIER
                                                  object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MOBILE_COMMAND_NOTIFIER
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter]    removeObserver:self
                                                       name:DEVICE_VALUE_CLOUD_NOTIFIER
                                                     object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark View Creation
-(void) displayActivity
{
    if(self.doRefreshView){
        NSArray *viewsToRemove = [self.view subviews];
        for (UIView *v in viewsToRemove) {
            [v removeFromSuperview];
            self.doRefreshView = FALSE;
        }
    }
    
    self.lblDeviceName = [[UILabel alloc] initWithFrame: CGRectMake(0, 10.0f, self.view.frame.size.width, 0)];
    self.lblDeviceName.backgroundColor=[UIColor clearColor];
    self.lblDeviceName.text = self.currentDeviceName;
    [self.lblDeviceName setFont:[UIFont systemFontOfSize:28] ];
    [self.lblDeviceName sizeToFit];
    [self.lblDeviceName setCenter: CGPointMake(self.view.center.x, self.lblDeviceName.center.y)];
    [self.view addSubview:self.lblDeviceName];
    
    //Create view based on device type
    switch(self.currentDeviceType){
        case 1:
        {
            
            
            //Switch
            UILabel *lblStatus = [[UILabel alloc]initWithFrame:CGRectMake(10.0f, 50.0f, 60.0f, 30.0f)];
            lblStatus.backgroundColor = [UIColor clearColor];
            [lblStatus setFont:[UIFont systemFontOfSize:15]];
            [lblStatus setText: @"Status: "];
            [self.view addSubview:lblStatus];
            
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectMake(70.0f, 50.0f, 100.0f, 20.0f)];
            [switchview addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            //Get Values
            for(SFIDeviceKnownValues *currentKnownValue in self.deviceKnownValues){
                self.currentIndexID = currentKnownValue.index;
                if([currentKnownValue.value isEqualToString:@"true"]){
                    [switchview setOn:YES];
                }else{
                    [switchview setOn:NO];
                }
            }
            
            [self.view addSubview:switchview];
            break;
        }
        case 3:
        {
            //Sensor
            for(SFIDeviceKnownValues *currentKnownValue in self.deviceKnownValues){
                switch(currentKnownValue.index){
                    case 1:
                    {
                        //Index="1" Name="STATE" - Toggle - Non Clickable
                        UILabel *lblStatus = [[UILabel alloc]initWithFrame:CGRectMake(10.0f, 50.0f, 100.0f, 30.0f)];
                        lblStatus.backgroundColor = [UIColor clearColor];
                        [lblStatus setFont:[UIFont systemFontOfSize:15]];
                        [lblStatus setText: [NSString stringWithFormat: @"%@ : ",currentKnownValue.valueName]];
                        [self.view addSubview:lblStatus];
                        
                        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectMake(110.0f, 50.0f, 100.0f, 20.0f)];
                        [switchview addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                        if([currentKnownValue.value isEqualToString:@"true"]){
                            [switchview setOn:YES];
                        }else{
                            [switchview setOn:NO];
                        }
                        switchview.enabled = NO;
                        [self.view addSubview:switchview];
                        break;
                    }
                    case 2:
                    {
                        //Index="2" Name="LOW BATTERY" - Info
                        UILabel *lblStatus = [[UILabel alloc]initWithFrame:CGRectMake(10.0f, 90.0f, 100.0f, 30.0f)];
                        lblStatus.backgroundColor = [UIColor clearColor];
                        [lblStatus setFont:[UIFont systemFontOfSize:15]];
                        [lblStatus setText: [NSString stringWithFormat: @"%@ : %@", currentKnownValue.valueName, currentKnownValue.value]];
                        [lblStatus sizeToFit];
                        [self.view addSubview:lblStatus];
                        break;
                    }
                    case 3:
                    {
                        //Index="3" Name="TAMPER" - Toggle
						//User can toggle Tamper if it is not, else non clickable
                        UILabel *lblStatus = [[UILabel alloc]initWithFrame:CGRectMake(10.0f, 130.0f, 100.0f, 30.0f)];
                        lblStatus.backgroundColor = [UIColor clearColor];
                        [lblStatus setFont:[UIFont systemFontOfSize:15]];
                        [lblStatus setText: [NSString stringWithFormat: @"%@ : ",currentKnownValue.valueName]];
                        [self.view addSubview:lblStatus];
                        
                        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectMake(110.0f, 130.0f, 100.0f, 20.0f)];
                        
                        if([currentKnownValue.value isEqualToString:@"true"]){
                            self.currentIndexID = currentKnownValue.index;
                            [switchview setOn:YES];
                            [switchview addTarget:self action:@selector(switchTamperChanged:) forControlEvents:UIControlEventValueChanged];
                            switchview.enabled = YES;
                        }else{
                            [switchview setOn:NO];
                            switchview.enabled = NO;
                        }
                        
                        [self.view addSubview:switchview];
                        break;
                    }
                }
                
                
            }
            break;
        }
            
    }
    //  [self.view setNeedsDisplay];
}

-(void)switchChanged:(UISwitch *)swithInCell{
    [SNLog Log:@"Method Name: %s Selected Device ID is @%@ Value: %@ Index: %d", __PRETTY_FUNCTION__,self.currentDeviceID, self.currentValue, self.currentIndexID ];
    
    if(swithInCell.on) {
        self.currentValue = @"true";
    }
    else {
        self.currentValue = @"false";
    }
    
    [SNLog Log:@"Method Name: %s Currrent Value %@",__PRETTY_FUNCTION__,self.currentValue];
    //Send mobile command
  
    [self sendMobileCommand];
}

-(void)switchTamperChanged:(UISwitch *)swithInCell{
   [SNLog Log:@"Method Name: %s Selected Device ID is @%@ Value: %@ Index: %d", __PRETTY_FUNCTION__,self.currentDeviceID, self.currentValue, self.currentIndexID];
    if(swithInCell.on) {
        self.currentValue = @"true";
    }
    else {
        self.currentValue = @"false";
    }
    
    [SNLog Log:@"Method Name: %s Currrent Value %@",__PRETTY_FUNCTION__,self.currentValue];
    //Send mobile command
    [self sendMobileCommand];
}

#pragma -mark Cloud Commands
-(void)cancelMobileCommand{
    [SNLog Log:@"Method Name: %s stopMobileCommand", __PRETTY_FUNCTION__];
    [HUD hide:YES];
}
-(void)sendMobileCommand{
    [SNLog Log:@"Method Name: %s sendMobileCommand", __PRETTY_FUNCTION__];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.dimBackground = YES;
    HUD.labelText=@"Sending command";
 
    [NSTimer scheduledTimerWithTimeInterval:60.0
                                     target:self
                                   selector:@selector(cancelMobileCommand)
                                   userInfo:nil
                                    repeats:NO];
    
    
    //Generate internal index between 1 to 100
    self.currentInternalIndex = (arc4random() % 100) + 1;
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    MobileCommandRequest *mobileCommand = [[MobileCommandRequest alloc] init];
    mobileCommand.almondMAC = self.currentMAC;
    mobileCommand.deviceID = self.currentDeviceID;
    mobileCommand.indexID = [NSString stringWithFormat:@"%d",self.currentIndexID];
    mobileCommand.changedValue = self.currentValue;
    mobileCommand.internalIndex = [NSString stringWithFormat:@"%d",self.currentInternalIndex];
    
    cloudCommand.commandType=MOBILE_COMMAND;
    cloudCommand.command=mobileCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- MobileCommandRequest Command", __PRETTY_FUNCTION__];
        
        NSError *error=nil;
        id ret = [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s Main APP Error %@",__PRETTY_FUNCTION__,[error localizedDescription]];
        }
        
        [SNLog Log:@"Method Name: %s After Writing to socket -- MobileCommandRequest Command",__PRETTY_FUNCTION__];
    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    cloudCommand=nil;
    mobileCommand=nil;
    
}

-(void)MobileCommandResponseCallback:(id)sender
{
    [SNLog Log:@"Method Name: %s ", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received MobileCommandResponse",__PRETTY_FUNCTION__];
        
        MobileCommandResponse *obj = [[MobileCommandResponse alloc] init];
        obj = (MobileCommandResponse *)[data valueForKey:@"data"];
        
        BOOL isSuccessful = obj.isSuccessful;
        if(isSuccessful){
            //Command updated values
            //update offline storage
            NSMutableArray *mobileDeviceValueList;
            mobileDeviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
            
            //For UI Update and Local data structure update
            if(self.deviceKnownValues==nil){
                [SNLog Log:@"Method Name: %s deviceKnownValues null: Read from file",__PRETTY_FUNCTION__];
                if(mobileDeviceValueList!=nil)
                {
                    for (SFIDeviceValue *currentMobileValue in mobileDeviceValueList){
                        if(currentMobileValue.deviceID == [self.currentDeviceID integerValue]){
                            [SNLog Log:@"Method Name: %s Device found in list: %@" , __PRETTY_FUNCTION__,self.currentDeviceID];
                            self.deviceKnownValues = currentMobileValue.knownValues;
                        }
                    }
                }
                
            }
            for(SFIDeviceKnownValues *currentValue in self.deviceKnownValues){
                if(currentValue.index == self.currentIndexID){
                    if(isSuccessful){
                        if(self.currentValue!=nil){
                            [SNLog Log:@"Method Name: %s Device Type: %d" , __PRETTY_FUNCTION__,self.currentDeviceType];
                            switch(self.currentDeviceType){
                                    
                                case 1:
                                    if([self.currentValue isEqualToString:@"true"]){
                                        currentValue.value = @"true";
                                    }else{
                                        currentValue.value = @"false";
                                    }
                                    
                                    break;
                                    
                            }
                        }
                    }
                }
            }
            
            //To save on the offline list
            [SNLog Log:@"Method Name: %s Update Offline List before 82 triggers", __PRETTY_FUNCTION__];
            NSMutableArray * mobileDeviceKnownValues;
            if(mobileDeviceValueList!=nil)
            {
                for (SFIDeviceValue *currentMobileValue in mobileDeviceValueList){
                    [SNLog Log:@"Method Name: %s Mobile DeviceID: %d" , __PRETTY_FUNCTION__,currentMobileValue.deviceID];
                    if(currentMobileValue.deviceID == [self.currentDeviceID integerValue]){
                        [SNLog Log:@"Method Name: %s Device found in list: %@" , __PRETTY_FUNCTION__,self.currentDeviceID];
                        mobileDeviceKnownValues = currentMobileValue.knownValues;
                        for(SFIDeviceKnownValues *currentMobileKnownValue in mobileDeviceKnownValues){
                            [SNLog Log:@"Method Name: %s Mobile Device Known Value Index: %d" , __PRETTY_FUNCTION__,currentMobileKnownValue.index];
                            for(SFIDeviceKnownValues *currentLocalKnownValue in self.deviceKnownValues){
                                [SNLog Log:@"Method Name: %s Activity Local Device Known Value Index: %d " , __PRETTY_FUNCTION__,currentLocalKnownValue.index];
                                if(currentMobileKnownValue.index == currentLocalKnownValue.index){
                                    //Update Value
                                    [SNLog Log:@"Method Name: %s BEFORE update => Cloud: %@ Mobile: %@" , __PRETTY_FUNCTION__,currentLocalKnownValue.value , currentMobileKnownValue.value];
                                    [currentMobileKnownValue setValue:currentLocalKnownValue.value];
                                    [SNLog Log:@"Method Name: %s AFTER update => Cloud: %@ Mobile: %@" , __PRETTY_FUNCTION__,currentLocalKnownValue.value , currentMobileKnownValue.value];
                                    break;
                                }
                            }
                        }
                        [currentMobileValue setKnownValues:mobileDeviceKnownValues];
                    }
                    
                }
                //Write to local database
                [SFIOfflineDataManager writeDeviceValueList:mobileDeviceValueList currentMAC:self.currentMAC];
            }else{
                [SNLog Log:@"Method Name: %s Error in retreiving device list", __PRETTY_FUNCTION__];
            }
            
        }else{
            //TODO: Display message
        }
        [HUD hide:YES];
        
    }
    
    
}

-(void)DeviceValueListResponseCallback:(id)sender
{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received DeviceValueListResponse",__PRETTY_FUNCTION__];
        
        DeviceValueResponse *obj = [[DeviceValueResponse alloc] init];
        obj = (DeviceValueResponse *)[data valueForKey:@"data"];
        
        
        BOOL isCurrentMAC = FALSE;
        BOOL isDeviceValueChanged = FALSE;
        NSString *cloudMAC = obj.almondMAC;
        [SNLog Log:@"Method Name: %s Update Offline Storage - Service",__PRETTY_FUNCTION__];
        
        if([cloudMAC isEqualToString:self.currentMAC]){
            
            isCurrentMAC = TRUE;
            //Match values and update the exact known value for the device
            
            NSMutableArray *cloudDeviceValueList;
            NSMutableArray *mobileDeviceValueList;
          //  NSMutableArray *mobileDeviceKnownValues;
            NSMutableArray *cloudDeviceKnownValues;
            
            cloudDeviceValueList = obj.deviceValueList;
            mobileDeviceValueList = [SFIOfflineDataManager readDeviceValueList:self.currentMAC];
            
            if(mobileDeviceValueList!=nil)
            {
                for (SFIDeviceValue *currentMobileValue in mobileDeviceValueList){
                   [SNLog Log:@"Method Name: %s Mobile DeviceID: %d ", __PRETTY_FUNCTION__,currentMobileValue.deviceID];
                    for(SFIDeviceValue *currentCloudValue in cloudDeviceValueList){
                        [SNLog Log:@"Method Name: %s Cloud DeviceID:  %d ", __PRETTY_FUNCTION__, currentCloudValue.deviceID];
                        if([self.currentDeviceID integerValue] == currentCloudValue.deviceID){
                            [SNLog Log:@"Method Name: %s Current Device Value Changed - Update", __PRETTY_FUNCTION__];
                            //mobileDeviceKnownValues = currentMobileValue.knownValues;
                            cloudDeviceKnownValues = currentCloudValue.knownValues;
                            for(SFIDeviceKnownValues *currentMobileKnownValue in self.deviceKnownValues){
                                [SNLog Log:@"Method Name: %s Mobile Device Known Value Index: %d " , __PRETTY_FUNCTION__,currentMobileKnownValue.index];
                                for(SFIDeviceKnownValues *currentCloudKnownValue in cloudDeviceKnownValues){
                                    [SNLog Log:@"Method Name: %s Cloud Device Known Value Index: %d " , __PRETTY_FUNCTION__,currentCloudKnownValue.index];
                                    if(currentMobileKnownValue.index == currentCloudKnownValue.index){
                                        //Update Value
                                        [SNLog Log:@"Method Name: %s BEFORE update => Cloud: %@  Mobile: %@" , __PRETTY_FUNCTION__,currentCloudKnownValue.value , currentMobileKnownValue.value];
                                        [currentMobileKnownValue setValue:currentCloudKnownValue.value];
                                        [SNLog Log:@"Method Name: %s AFTER update => Cloud: %@  Mobile: %@" ,__PRETTY_FUNCTION__, currentCloudKnownValue.value , currentMobileKnownValue.value];
                                        break;
                                    }
                                }
                                //self.deviceKnownValues = mobileDeviceKnownValues;
                            }
                            isDeviceValueChanged = TRUE;
                        }
                    }
                }
            }
            
            if(isCurrentMAC && isDeviceValueChanged){
                [SNLog Log:@"Method Name: %s Value Changed - Refresh",__PRETTY_FUNCTION__];
                self.doRefreshView = TRUE;
                //[self.view setNeedsDisplay];
                [self displayActivity];
            }
        }
        
        
    }
}

@end
