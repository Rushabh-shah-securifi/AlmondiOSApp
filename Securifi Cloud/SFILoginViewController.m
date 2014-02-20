//
//  SFILoginViewController.m
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import "SFILoginViewController.h"
#import "SFIViewController.h"
#import "CustomAlertView.h"
#import "MBProgressHUD.h"
#import "SNLog.h"
#import "SFIOfflineDataManager.h"
#import "SFIDatabaseUpdateService.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "AlmondPlusConstants.h"
#import "SFIReachabilityManager.h"
#import "Reachability.h"

@interface SFILoginViewController ()

@end

@implementation SFILoginViewController
@synthesize userName;
@synthesize password;
@synthesize state;


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
//    SNFileLogger *logger = [[SNFileLogger alloc] init];
//    [[SNLog logManager] addLogStrategy:logger];
    
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    //self.title = @"Login";
    
    /*
     userName.hidden=true;
     password.hidden=true;
     loginButton.hidden=true;
     */
    
    //self.loginButton.hidden = true;
    
    //MIGRATE TO APP DELEGATE
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(networkHandlerUP:)
//                                                 name:NETWORK_UP_NOTIFIER
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(networkHandlerDOWN:)
//                                                 name:NETWORK_DOWN_NOTIFIER
//                                               object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loginResponse:)
//                                                 name:LOGIN_NOTIFIER
//                                               object:nil];
    
    [super viewDidLoad];
    
    //PY 170913 - To stop the view from going below tab bar
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
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
    
    // Do any additional setup after loading the view.
//    if (keyboardToolbar == nil)
//    {
//        keyboardToolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 44)];
//        
//        UIBarButtonItem *previousButton = [[UIBarButtonItem alloc]
//                                           initWithTitle:@"Previous"
//                                           style:UIBarButtonItemStyleBordered
//                                           target:self action:@selector(previousField:)];
//        
//        UIBarButtonItem *nextButton = [[UIBarButtonItem alloc]
//                                       initWithTitle:@"Next"
//                                       style:UIBarButtonItemStyleBordered
//                                       target:self action:@selector(nextField:)];
//        
//        UIBarButtonItem *extra  =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        
//        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resignKeyboard:)];
//        
//        [keyboardToolbar setItems:[[NSArray alloc] initWithObjects:previousButton, nextButton, extra, doneButton, nil]];
//        [keyboardToolbar setBarStyle:UIBarStyleBlackTranslucent];
        //[keyboardToolbar setTintColor:[UIColor blackColor]];
        
//        userName.inputAccessoryView = keyboardToolbar;
//        password.inputAccessoryView = keyboardToolbar;
//        deviceID.inputAccessoryView = keyboardToolbar;
        
        //change text user and pass field
//        password.borderStyle = UITextBorderStyleRoundedRect;
//        userName.borderStyle = UITextBorderStyleRoundedRect;
//        deviceID.borderStyle = UITextBorderStyleRoundedRect;
        
        //Activity Indicator
        //ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        /*
         ai.center = self.view.center;
         [self.view addSubview:ai];
         [ai startAnimating];
         */
   // }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponse:)
                                                 name:LOGIN_NOTIFIER
                                               object:nil];
    
    //PY 311013 Reconnection Logic
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkDownNotifier:)
                                                 name:NETWORK_DOWN_NOTIFIER
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkUpNotifier:)
                                                 name:NETWORK_UP_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityDidChange:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetPasswordResponseCallback:)
                                                 name:RESET_PWD_RESPONSE_NOTIFIER
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LOGIN_NOTIFIER
                                                  object:nil];
    
    //PY 311013 Reconnection Logic
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_UP_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NETWORK_DOWN_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RESET_PWD_RESPONSE_NOTIFIER
                                                  object:nil];

}

#pragma mark - Orientation Handling
-(BOOL) shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Class Methods
- (void)doneHandler
{
    //PY 170913 - Use navigation controller
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)networkHandlerUP:(id)sender
{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
}

-(void)networkHandlerDOWN:(id)sender
{
    //[SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    self.userName.hidden = false;
    self.password.hidden = false;
    //self.loginButton.hidden = false;
}

- (void) resignKeyboard:(id)sender {
    
    if ([userName isFirstResponder])
        [userName resignFirstResponder];
    
    else if ([password isFirstResponder]){
        NSLog(@"Login");
        [password resignFirstResponder];
    }
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userName) {
        [textField resignFirstResponder];
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        NSLog(@"Login Action!!");
        [textField resignFirstResponder];
        [self loginClick:nil];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)signupButton:(id)sender{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFISignupViewController"];
    //[self.navigationController pushViewController:mainView animated:YES];
    [self presentViewController:mainView animated:YES completion:nil];
}

- (IBAction)forgotPwdButtonHandler:(id)sender{
    NSLog(@"Forgot Button Handler");
    [self sendResetPasswordRequest];
}

-(IBAction)loginClick:(id)sender
{
    if ([userName isFirstResponder])
        [userName resignFirstResponder];
    
    else if ([password isFirstResponder])
        [password resignFirstResponder];
    
    if([[userName text] isEqualToString:@""] || [[password text] isEqualToString:@""]) {
        self.headingLabel.text = @"Oops";
        self.subHeadingLabel.text = @"Please enter Username and Password";
    }else{
        GenericCommand *cloudCommand = [[GenericCommand alloc] init];
        
        Login *loginCommand = [[Login alloc] init];
        loginCommand.UserID = [NSString stringWithString:userName.text];
        loginCommand.Password = [NSString stringWithString:password.text];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:loginCommand.UserID  forKey:EMAIL];
        [prefs synchronize];
        
        cloudCommand.commandType=LOGIN_COMMAND;
        cloudCommand.command=loginCommand;
        @try {
            [SNLog Log:@"Method Name: %s Before Writing to socket -- LoginCommand", __PRETTY_FUNCTION__];
            
            NSError *error=nil;
            id ret = [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
            
            if (ret == nil)
            {
                [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
            }
            
            [SNLog Log:@"Method Name: %s Before Writing to socket -- LoginCommand", __PRETTY_FUNCTION__];
        }
        @catch (NSException *exception) {
            [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__,exception.reason];
        }
        
        cloudCommand=nil;
        loginCommand=nil;

    }
    
}

-(void)loginResponse:(id)sender{
    //Invalidate timer
    //[ai stopAnimating];
    
    //[timeout invalidate];
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    //Login failed
    if ([notifier userInfo] == nil)
    {
        [SNLog Log:@"In Method Name: %s TEMP Pass failed", __PRETTY_FUNCTION__];
        /*
         self.loginButton.hidden = false;
         self.userName.hidden = false;
         self.password.hidden = false;
         */
    }
    else
    {
        [SNLog Log:@"In Method Name: %s Received login response", __PRETTY_FUNCTION__];
        
        LoginResponse *obj = [[LoginResponse alloc] init];
        obj = (LoginResponse *)[data valueForKey:@"data"];
        
        [SNLog Log:@"In Method Name: %s UserID %@", __PRETTY_FUNCTION__,obj.userID];
        [SNLog Log:@"In Method Name: %s TempPass %@", __PRETTY_FUNCTION__,obj.tempPass];
        [SNLog Log:@"In Method Name: %s isSuccessful : %d", __PRETTY_FUNCTION__,obj.isSuccessful];
        [SNLog Log:@"In Method Name: %s Reason : %@", __PRETTY_FUNCTION__,obj.reason];
        //[SNLog Log:@"In Method Name: %s Reason : %d", __PRETTY_FUNCTION__,obj.reasonCode];
        NSLog(@"Reason Code: %d", obj.reasonCode);
        
        if (obj.isSuccessful == 0)
        {
            //Enable User/Pass field
            /*
             self.loginButton.hidden = false;
             self.userName.hidden = false;
             self.password.hidden = false;
             */
           // logMessage.text=@"Invalid Credentials";
            
            NSString *failureReason;
            self.headingLabel.text = @"Oops";
            UIStoryboard *storyboard;
            UIViewController *mainView;
            switch(obj.reasonCode){
                case 1:
                    failureReason = @"The email was not found.";
                    break;
                case 2:
                    failureReason = @"The password is incorrect.";
                    break;
                case 3:
                    //Display Activation Screen
                    self.headingLabel.text = @"Almost there.";
                    failureReason = @"You need to activate your account.";
                    storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                    mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIActivationViewController"];
                    [self presentViewController:mainView animated:YES completion:nil];
                    break;
                case 4:
                    failureReason = @"The email or password is incorrect";
                    break;
                default:
                    failureReason = @"Sorry! Login was unsuccessful.";
            }
            
            self.subHeadingLabel.text = failureReason;
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!"
//                                                            message:failureReason
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//            [alert show];
        }
        else if (obj.isSuccessful == 1)
        {
            [SNLog Log:@"In Method Name: %s Login Successful -- Load different view", __PRETTY_FUNCTION__];
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.dimBackground = YES;
            HUD.labelText = @"Loading your personal data.";
            //Retrieve Almond List, Device List and Device Value - Before displaying the screen
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(AlmondListResponseCallback:)
                                                         name:ALMOND_LIST_NOTIFIER
                                                       object:nil];
            dispatch_queue_t queue = dispatch_queue_create("com.securifi.almondplus", NULL);
            dispatch_async(queue, ^{
                [SFIDatabaseUpdateService stopDatabaseUpdateService];
                [SFIDatabaseUpdateService startDatabaseUpdateService];
            });
            
            [self loadAlmondList];
            
            //Load CollectionView
            
            //Load Main View
            //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"bundle:nil];
            //        UINavigationController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SFIMainViewController"];
            //        [self presentViewController:viewController animated:YES completion:NULL];
            //PY 170913 - Use navigation controller
            //[self.navigationController popViewControllerAnimated:YES];
            
        }
        obj=nil;
    }

    
}

- (IBAction)backClick:(id)sender {
    if ([userName isFirstResponder])
        [userName resignFirstResponder];
    
    else if ([password isFirstResponder])
        [password resignFirstResponder];
}



- (void) alertStatus:(NSString *)msg :(NSString *)title
{
    
    CustomAlertView *alertView = [[CustomAlertView alloc]initWithTitle:title
                                                               message:msg
                                                              delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil,nil];
    [alertView show];
}


#pragma mark - Reconnection

-(void)networkUpNotifier:(id)sender
{
    [SNLog Log:@"Method Name: %s Login controller :In networkUP notifier", __PRETTY_FUNCTION__];
    state= [SecurifiToolkit getConnectionState];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, state];
    //PY 311013 Reconnection Logic
    [HUD hide:YES];
    if(state == SDK_UNINITIALIZED){
        [SecurifiToolkit initSDKCloud];
        [HUD hide:YES];
    }
    [SNLog Log:@"Method Name: %s State Again : %d", __PRETTY_FUNCTION__, state];
//    else if (state == NOT_LOGGED_IN){
//        [SNLog Log:@"Method Name: %s Logout Initialiaze SDK", __PRETTY_FUNCTION__];
//        [SNLog Log:@"Method Name: %s Display login screen", __PRETTY_FUNCTION__];
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
//        [self presentViewController:mainView animated:YES completion:nil];
//    }
}

//void runOnMainQueueWithoutDeadLocking(void (^block)(void))
//{
//    if ([NSThread isMainThread])
//    {
//        block();
//    }
//    else
//    {
//        dispatch_sync(dispatch_get_main_queue(), block);
//    }
//}

-(void)networkDownNotifier:(id)sender
{
    self.state=[SecurifiToolkit getConnectionState];
    [SNLog Log:@"Method Name: %s DOWN State : %d", __PRETTY_FUNCTION__, state];
    if(self.state == NETWORK_DOWN){
        //state = SDK_UNINITIALIZED;
        [HUD hide:YES];
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.dimBackground = YES;
        HUD.labelText=@"Network Down";
        [HUD hide:YES afterDelay:1];
    }else if(self.state ==SDK_UNINITIALIZED){
        [SecurifiToolkit initSDKCloud];
    }
}


- (void)reachabilityDidChange:(NSNotification *)notification {
    //Reachability *reachability = (Reachability *)[notification object];
    if ([SFIReachabilityManager isReachable]) {
        NSLog(@"Reachable");
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.dimBackground = YES;
        HUD.labelText=@"Reconnecting...";
        [SecurifiToolkit initSDK];
        [HUD hide:YES afterDelay:1];
    } else {
        NSLog(@"Unreachable");
    }
}

#pragma mark - Cloud Command : Sender and Receivers
-(void)sendResetPasswordRequest{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *email = [prefs objectForKey:EMAIL];
    NSLog(@"Email : %@", email);
    
    GenericCommand *cloudCommand = [[GenericCommand alloc] init];
    
    ResetPasswordRequest *resetCommand = [[ResetPasswordRequest alloc] init];
    resetCommand.email = userName.text;
    
    cloudCommand.commandType=RESET_PASSWORD_REQUEST;
    cloudCommand.command=resetCommand;
    @try {
        [SNLog Log:@"Method Name: %s Before Writing to socket -- SignupCommand", __PRETTY_FUNCTION__];
        
        
        NSError *error=nil;
        id ret = [SecurifiToolkit sendtoCloud:cloudCommand error:&error];
        
        if (ret == nil)
        {
            [SNLog Log:@"Method Name: %s Main APP Error %@", __PRETTY_FUNCTION__,[error localizedDescription]];
            
        }
        [SNLog Log:@"Method Name: %s After Writing to socket -- SignupCommand", __PRETTY_FUNCTION__];
        
    }
    @catch (NSException *exception) {
        [SNLog Log:@"Method Name: %s Exception : %@", __PRETTY_FUNCTION__, exception.reason];
    }
    
    cloudCommand=nil;
    resetCommand=nil;
}

-(void)resetPasswordResponseCallback:(id)sender{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    
    ResetPasswordResponse *obj = [[ResetPasswordResponse alloc] init];
    obj = (ResetPasswordResponse *)[data valueForKey:@"data"];
    
    [SNLog Log:@"Method Name: %s Successful : %d", __PRETTY_FUNCTION__, obj.isSuccessful];
    [SNLog Log:@"Method Name: %s Reason : %@", __PRETTY_FUNCTION__, obj.reason];
    
    
    if (obj.isSuccessful == 0)
    {
        NSLog(@"Reason Code %d", obj.reasonCode);
        NSString *failureReason;
        UIStoryboard *storyboard;
        UIViewController *mainView;
        switch(obj.reasonCode){
            case 1:
                failureReason = @"The username was not found";
                break;
            case 2:
                //Display Activation Screen
                self.headingLabel.text = @"Almost there.";
                failureReason = @"You need to activate your account.";
                storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
                mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFIActivationViewController"];
                [self presentViewController:mainView animated:YES completion:nil];
                break;
            case 3:
                failureReason = @"Sorry! Your password cannot be \nreset at the moment. Try again later.";
                break;
            case 4:
                failureReason = @"The email ID is invalid.";
                break;
            case 5:
                failureReason = @"Sorry! Your password cannot be \nreset at the moment. Try again later.";
                break;
        }
        self.headingLabel.text = @"Oops!";
        self.subHeadingLabel.text = failureReason;
    }else{
        self.headingLabel.text = @"Almost there.";
        self.subHeadingLabel.text = @"Password reset link has been sent to your account.";
    }
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
    HUD.hidden = YES;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"InitialSlide"];
    [self presentViewController:mainView
                       animated:YES
                     completion:nil];
}


/*
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
 if ([segue.identifier isEqualToString:@"loginView"]) {
 NSLog(@"in login saguea");
 // NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
 // NSLog(@"Clicked on %d",indexPath.row);
 
 // SFILoginViewController *destViewController = segue.destinationViewController;
 //destViewController.deviceName = [data objectAtIndex:indexPath.row];
 }
 }
 */

//#if 0
//Working example of populating Detail view with device lists
//
//-(void)dataRequestCompletedWithJsonObject:(id)jsonObject
//{
//    NSLog(@"Delegate Data : %@",jsonObject);
//    NSDictionary *jsonData = (NSDictionary*)jsonObject;
//    NSString *loginRes = (NSString *) [jsonData objectForKey:@"login"];
//    
//    NSLog(@"Login Response: %@",loginRes);
//    if ([loginRes isEqualToString:@"fail"])
//    {
//        [self alertStatus:@"Please check your Username and/or Password" :@"Login Failed"];
//    }
//    else
//    {
//        // NSLog(@"Nirav Data : %@",recipeDictionary);
//        // On Login click control will come here if successful launch navigation controller
//        //NSArray* deviceArray = (NSArray*)[jsonData objectForKey:@"devicelist"];
//        
//        NSString* deviceCount = (NSString *)[jsonData objectForKey:@"deviceCount"];
//        
//        self.deviceList = [[NSMutableArray alloc] init];
//        NSLog(@"Device count %d",[deviceCount integerValue]);
//        int i;
//        
//        for (i=1;i<=[deviceCount integerValue];i++)
//        {
//            NSString *deviceName = [NSString stringWithFormat:@"device%d",i];
//            [deviceList addObject:[jsonData objectForKey:deviceName]];
//        }
//        
//        for (id dic in deviceList) {
//            NSLog(@"value:%@",dic);
//            // NSLog(@"%@\n",[dic string]);
//            /*Recipe *recipe = [[Recipe alloc] init];
//             recipe.name = [dic objectForKey:@"title"];
//             recipe.thumbNail = [dic objectForKey:@"thumb"];
//             recipe.twitterShareCount = [[dic objectForKey:@"twc"] intValue];
//             recipe.macAddr = [dic objectForKey:@"mac"];
//             recipe.status = [[dic objectForKey:@"status"] intValue];
//             [recipes addObject:recipe];
//             */
//        }
//        
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"bundle:nil];
//        UINavigationController *navView = [storyboard instantiateViewControllerWithIdentifier:@"SFINavigationController"];
//        SFIViewController *tableView = (SFIViewController *)navView.topViewController;
//        tableView.data = [deviceList mutableCopy];
//        
//        [self presentViewController:navView animated:NO completion:NULL];
//    }
//}
//#endif

@end
