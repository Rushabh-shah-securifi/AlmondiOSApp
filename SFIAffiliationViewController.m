//
//  SFIAffiliationViewController.m
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/29/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIAffiliationViewController.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SNLog.h"
#import "SFIOfflineDataManager.h"
#import "AlmondPlusConstants.h"

@interface SFIAffiliationViewController ()

@end

@implementation SFIAffiliationViewController
@synthesize btnAffiliationCode,txtAffiliationCode, lblMessage;
@synthesize lblHooray, lblMAC, lblName, lblPassword, lblSSID;
@synthesize lblMACTitle, lblNameTitle, lblPasswordTitle, lblSSIDTitle, lblEnterMsg;
@synthesize imgLine1, imgLine2, imgLine3, imgLine4, imgLine5;

//@synthesize counter;
//@synthesize timerLabel;
//@synthesize codeTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    NSDictionary *titleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                     [UIFont fontWithName:@"Avenir-Roman" size:18.0], NSFontAttributeName, nil];
    
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    SNFileLogger *logger = [[SNFileLogger alloc] init];
    //    [[SNLog logManager] addLogStrategy:logger];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(AffiliationUserResponseNotifier:)
    //                                                 name:AFFILIATION_CODE_NOTIFIER
    //                                               object:nil];
    
    
    
	// Do any additional setup after loading the view.
    //self.affiliationCode.enabled=NO;
    
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneHandler)];
    
    //    UIToolbar *toolbar = [[UIToolbar alloc] init];
    //    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    //    toolbar.tintColor=[UIColor blackColor];
    //
    //    NSMutableArray *items = [[NSMutableArray alloc] init];
    //
    //    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    //
    //    [items addObject:flexibleSpace];
    //    [items addObject:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneHandler)]];
    //
    //    [toolbar setItems:items animated:NO];
    //    [self.view addSubview:toolbar];
    
    
    //UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    
    //self.navigationItem.rightBarButtonItem = anotherButton;
    
    self.navigationItem.title = @"Link Almond";
    
    
    //NSLog(@"Return Testing %@", [self convertDecimalToMAC:@"251176230573596"]);
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    txtAffiliationCode.hidden = NO;
    btnAffiliationCode.hidden = NO;
    lblEnterMsg.hidden = NO;
    //Invisible Affiliation Complete Elements
    self.lblHooray.hidden = TRUE;
    self.lblMessage.hidden = TRUE;
    self.lblName.hidden = TRUE;
    self.lblPassword.hidden = TRUE;
    self.lblSSID.hidden = TRUE;
    self.lblMAC.hidden = TRUE;
    self.lblSSIDTitle.hidden = TRUE;
    self.lblPasswordTitle.hidden = TRUE;
    self.lblMACTitle.hidden = TRUE;
    self.lblNameTitle.hidden = TRUE;
    self.imgLine1.hidden = TRUE;
    self.imgLine2.hidden = TRUE;
    self.imgLine3.hidden = TRUE;
    self.imgLine4.hidden = TRUE;
    self.imgLine5.hidden = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AffiliationUserCompleteNotifier:)
                                                 name:AFFILIATION_COMPLETE_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AlmondListResponseCallback:)
                                                 name:ALMOND_LIST_NOTIFIER
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALMOND_LIST_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AFFILIATION_COMPLETE_NOTIFIER
                                                  object:nil];
}
//
//-(void) updateCountDown:(NSTimer *) theTimer{
//    NSInteger mins,secs;
//    counter--;
//    if (counter>=0) {
//    	mins=counter/60;
//    	secs=counter%60;
//    	timerLabel.text=[NSString stringWithFormat:@"%02d : %02d",mins,secs];
//    } else {
//    	[theTimer invalidate];
//        timerLabel.text=[NSString stringWithFormat:@"-- : --"];
//        affiliationCode.text= [NSString stringWithFormat:@"------"];
//        [SNLog Log:@"Method Name: %s Code Timeout", __PRETTY_FUNCTION__];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Keyboard Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtAffiliationCode) {
        [textField resignFirstResponder];
        //Send Affiliation Command
        [self sendAffiliationCode:nil];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > AFFILIATION_CODE_CHAR_COUNT) ? NO : YES;
}

#pragma mark - Class Methods

-(NSString*)convertDecimalToMAC:(NSString*)decimalString{
    //Step 1: Conversion from decimal to hexadecimal
    NSLog(@"%llu", (unsigned long long)[decimalString longLongValue]);
    NSString *hexIP = [NSString stringWithFormat:@"%llX", (unsigned long long)[decimalString longLongValue]];
    
    NSMutableString *wifiMAC = [[NSMutableString alloc]init];
    //Step 2: Divide in pairs of 2 hex
    for (int i=0; i < [hexIP length]; i=i+2) {
        NSString *ichar  = [NSString stringWithFormat:@"%c%c:", [hexIP characterAtIndex:i], [hexIP characterAtIndex:i+1]];
        [wifiMAC appendString:ichar];
    }
    
    [wifiMAC deleteCharactersInRange:NSMakeRange([wifiMAC length]-1, 1)];
    NSLog(@"WifiMAC: %@", wifiMAC);
    return wifiMAC;
}

- (IBAction)cancelButtonHandler:(id)sender
{
    
    //[codeTimer invalidate];
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    //    //UIViewController *loginView = [storyboard instantiateViewControllerWithIdentifier:@"SFILoginViewController"];
    //    //[self presentViewController:loginView animated:YES completion:NULL];
    //
    //    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIMainViewController"];
    //    [self presentViewController:mainView animated:YES completion:NULL];
    //PY 170913 - Use navigation controller
    //[self.navigationController popViewControllerAnimated:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)logoutUser{
    //Logout Action
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    cloudCommand.commandType=LOGOUT_COMMAND;
    cloudCommand.command=nil;
    [SNLog Log:@"Method Name: %s Before Writing to socket -- LogoutCommand", __PRETTY_FUNCTION__];
    
    NSError *error=nil;
    [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:EMAIL];
    [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
    [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
    [prefs synchronize];
    
    //Delete files
    [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
    [SFIOfflineDataManager deleteFile:HASH_FILENAME];
    [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
    [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];
    
    //[self dismissViewControllerAnimated:NO completion:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
    //[self presentViewController:mainView animated:YES completion:nil];
    [self presentViewController:mainView animated:YES completion:nil];
}

//- (IBAction)doneButtonHandler:(id)sender{
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//}

//-(void) AffiliationUserResponseNotifier:(id)sender
//{
//    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
//
//    NSNotification *notifier = (NSNotification *) sender;
//    NSDictionary *data = (NSDictionary *)[notifier userInfo];
//
//
//    AffiliationUserRequest *obj = [[AffiliationUserRequest alloc] init];
//    obj = (AffiliationUserRequest *)[data valueForKey:@"data"];
//
//    [SNLog Log:@"In Method Name: %s UserID : %@", __PRETTY_FUNCTION__,obj.UserID];
//    [SNLog Log:@"In Method Name: %s Code : %@", __PRETTY_FUNCTION__,obj.Code];
//
//
////    counter=121;
////    codeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCountDown:) userInfo:nil repeats:YES];
//
//    self.txtAffiliationCode.text = obj.Code;
//
//}



#pragma mark - Cloud Command : Sender and Receivers

- (IBAction)sendAffiliationCode:(id)sender {
    [txtAffiliationCode resignFirstResponder];
    NSLog(@"Affiliation Code: %@", self.txtAffiliationCode.text);
    
    if(self.txtAffiliationCode.text.length == 0){
        return;
    }
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    AffiliationUserRequest *affiliationCommand = [[AffiliationUserRequest alloc] init];
    affiliationCommand.Code = self.txtAffiliationCode.text;
    
    cloudCommand.commandType=AFFILIATION_CODE_REQUEST;
    cloudCommand.command=affiliationCommand;
    
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- AffiliationCodeCommand", __PRETTY_FUNCTION__];
        
        
        NSError *error=nil;
        id ret = [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
        }
        
        [SNLog Log:@"Method Name: %s Before Writing to socket -- AffiliationCodeCommand", __PRETTY_FUNCTION__];
    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    //    //Refresh View
    self.lblEnterMsg.text = @"Please wait while your Almond is being linked to cloud.";
    //    txtAffiliationCode.hidden = YES;
    //    btnAffiliationCode.hidden = YES;
    
    cloudCommand=nil;
}

-(void) AffiliationUserCompleteNotifier:(id)sender
{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    
    AffiliationUserComplete *obj = [[AffiliationUserComplete alloc] init];
    obj = (AffiliationUserComplete *)[data valueForKey:@"data"];
    
    
    BOOL isSuccessful = obj.isSuccessful;
    self.lblEnterMsg.hidden = TRUE;
    self.txtAffiliationCode.hidden = TRUE;
    self.btnAffiliationCode.hidden = TRUE;
    if(isSuccessful){
        //        [SNLog Log:@"Method Name: %s AlmondMAC : %@", __PRETTY_FUNCTION__, obj.almondplusMAC];
        //        [SNLog Log:@"Method Name: %s AlmondName : %@", __PRETTY_FUNCTION__, obj.almondplusName];
        
        //Display content
        self.lblHooray.hidden = FALSE;
        self.lblMessage.hidden = FALSE;
        self.lblName.hidden = FALSE;
        self.lblPassword.hidden = FALSE;
        self.lblSSID.hidden = FALSE;
        self.lblMAC.hidden = FALSE;
        self.lblSSIDTitle.hidden = FALSE;
        self.lblPasswordTitle.hidden = FALSE;
        self.lblMACTitle.hidden = FALSE;
        self.lblNameTitle.hidden = FALSE;
        self.imgLine1.hidden = FALSE;
        self.imgLine2.hidden = FALSE;
        self.imgLine3.hidden = FALSE;
        self.imgLine4.hidden = FALSE;
        self.imgLine5.hidden = FALSE;
        
        self.lblName.text = obj.almondplusName;
        
        self.lblSSID.text = obj.wifiSSID;
        self.lblPassword.text = obj.wifiPassword;
        
        //        //Step 1: Conversion from decimal to hexadecimal
        //        NSString *hexIP = [NSString stringWithFormat:@"%lX", (long)[obj.almondplusMAC integerValue]];
        //        NSMutableString *wifiMAC;
        //        //Step 2: Divide in pairs of 2 hex
        //        for (int i=0; i < [hexIP length]; i=i+2) {
        //            NSString *ichar  = [NSString stringWithFormat:@"%c%c:", [hexIP characterAtIndex:i], [hexIP characterAtIndex:i+1]];
        //            [wifiMAC appendString:ichar];
        //        }
        //
        //        [wifiMAC deleteCharactersInRange:NSMakeRange([wifiMAC length]-1, 1)];
        
        self.lblMAC.text = [self convertDecimalToMAC:obj.almondplusMAC];
        
        //Change title
        self.navigationItem.title = @"Almond Linked";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelButtonHandler:)];
        self.navigationItem.leftBarButtonItem = nil;
        
        //        NSString *log = [NSString stringWithFormat:@"Almond named %@ with MAC Address %@  has been successfully affiliated.",obj.almondplusName,obj.almondplusMAC];
        //        [SNLog Log:@"Method Name: %s Wifi SSID : %@ Wifi Password : %@", __PRETTY_FUNCTION__,obj.wifiSSID, obj.wifiPassword];
        
        //self.lblMessage.text = log;
    }else{
        [SNLog Log:@"Method Name: %s AlmondMAC : %@", __PRETTY_FUNCTION__, obj.reason];
        //Display content
        self.lblHooray.hidden = FALSE;
        self.lblMessage.hidden = FALSE;
        self.lblHooray.text = @"Oops!";
        
        //Handle different reason codes
        NSString *failureReason;
        switch(obj.reasonCode){
            case 1:
                failureReason = @"Please try later.";
                break;
            case 2:
            case 3:
                failureReason = @"Please enter a valid code.";
                break;
            case 4:
                failureReason = @"It is already affiliated to your account.";
                break;
            case 5:
            case 6:
            case 7:
                //Logout
                failureReason = @"Please login again and retry.";
                self.lblMessage.text = [NSString stringWithFormat:@"Almond could not be affiliated.\n%@",failureReason];;
                [self logoutUser];
                break;
        }
        
        NSString *log = [NSString stringWithFormat:@"Almond could not be affiliated.\n%@",failureReason];
        self.lblMessage.text = log;
    }
    
    //    //Get new Almond list - Handled by automatic update
    //    [self loadAlmondList];
    
    //
    //
    //    UIAlertView *alert = [[UIAlertView alloc]
    //                          initWithTitle:@"Almond+ Registration"
    //                          message:log
    //                          delegate:self
    //                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
    //                          otherButtonTitles: nil];
    //
    //    [alert
    //     performSelector:@selector(show)
    //     onThread:[NSThread mainThread]
    //     withObject:nil
    //     waitUntilDone:NO];
    
}

-(void)loadAlmondList{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    AlmondListRequest *almondListCommand = [[AlmondListRequest alloc] init];
    
    cloudCommand.commandType=ALMOND_LIST;
    cloudCommand.command=almondListCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- Almond List Command", __PRETTY_FUNCTION__];
        
        NSError *error=nil;
        id ret = [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
            
        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- Almond List Command", __PRETTY_FUNCTION__];
        
    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
    }
    
    cloudCommand=nil;
    almondListCommand=nil;
    
}

-(void)AlmondListResponseCallback:(id)sender
{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    if(data !=nil){
        [SNLog Log:@"Method Name: %s Received Almond List response", __PRETTY_FUNCTION__];
        
        AlmondListResponse *obj = [[AlmondListResponse alloc] init];
        obj = (AlmondListResponse *)[data valueForKey:@"data"];
        [SNLog Log:@"Method Name: %s List size : %d", __PRETTY_FUNCTION__,[obj.almondPlusMACList count]];
        //Write Almond List offline
        [SFIOfflineDataManager writeAlmondList:obj.almondPlusMACList];
    }
    
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    // [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}




//
//- (IBAction)getAffiliationCode:(id)sender {
//
//    //Check old timer and remove it
//    if (codeTimer)
//    {
//        [codeTimer invalidate];
//        timerLabel.text=[NSString stringWithFormat:@"-- : --"];
//        affiliationCode.text= [NSString stringWithFormat:@""];
//        codeTimer=nil;
//    }
//
//    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
//
//    cloudCommand.commandType=AFFILIATION_CODE_REQUEST;
//    cloudCommand.command=nil;
//
//    @try {
//        [SNLog Log:@"Method Name: %s Before Writing to socket -- AffiliationCodeCommand", __PRETTY_FUNCTION__];
//
//
//        NSError *error=nil;
//        id ret = [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
//
//        if (ret == nil)
//        {
//            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
//        }
//
//        [SNLog Log:@"Method Name: %s Before Writing to socket -- AffiliationCodeCommand", __PRETTY_FUNCTION__];
//    }
//    @catch (NSException *exception) {
//        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
//    }
//
//    cloudCommand=nil;
//}


@end
