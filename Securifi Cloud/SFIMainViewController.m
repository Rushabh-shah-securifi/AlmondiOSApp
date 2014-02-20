//
//  SFIMainViewController.m
//  Securifi Cloud
//
//  Created by Nirav Uchat on 7/30/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIMainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SFIMainViewTile.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SFIAlmondListViewController.h"
#import "SFILoginViewController.h"
#import "SFIAffiliationViewController.h"
#import "SFISignupViewController.h"
#import "SFILogoutAllViewController.h"
#import "SFIDatabaseUpdateService.h"
#import "SNLog.h"
#import "AlmondPlusConstants.h"
#import "SFICollectionHeaderView.h"
#import "SFIOfflineDataManager.h"
#import "SFIReachabilityManager.h"
#import "Reachability.h"


@interface SFIMainViewController ()

@end

@implementation SFIMainViewController
@synthesize viewData;
@synthesize state;
@synthesize imgSplash;
@synthesize isConnectedToCloud;
@synthesize displayNoCloudTimer;

#pragma mark - View Lifecycle
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
    state= [SecurifiToolkit getConnectionState];
    
    //self.lblUserEmail.text = @"HELLO!!!";
    //    SNFileLogger *logger = [[SNFileLogger alloc] init];
    //    [[SNLog logManager] addLogStrategy:logger];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, state];
    
    //Set the splash image differently for 3.5 inch and 4 inch screen
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 568) {
        // code for 4-inch screen
        imgSplash.image = [UIImage imageNamed:@"launch-image-640x1136"];
    } else {
        // code for 3.5-inch screen
        imgSplash.image = [UIImage imageNamed:@"launch-image-640x960"];
    }
    
    
    displayNoCloudTimer = [NSTimer scheduledTimerWithTimeInterval:CLOUD_CONNECTION_TIMEOUT
                                                              target:self
                                                            selector:@selector(displayNoCloudConnectionImage)
                                                            userInfo:nil
                                                             repeats:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    //PY 170913 Add observers
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginResponseNotifier:)
                                                 name:LOGIN_NOTIFIER
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomesActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AlmondListResponseCallback:)
                                                 name:ALMOND_LIST_NOTIFIER
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
    
    
    //PY 160913 - To restore connection after Logout
    [super viewDidAppear:animated];
    state= [SecurifiToolkit getConnectionState];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, state];
    
    if (state == NETWORK_DOWN || state == SDK_UNINITIALIZED)
    {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.dimBackground = YES;
        HUD.labelText = @"Connecting. Please wait!";
        [SNLog Log:@"Method Name: %s Initialiaze SDK", __PRETTY_FUNCTION__];
        state = 5;
        [SecurifiToolkit initSDK];
        
    }else if (state == LOGGED_IN){
        
        //Reload collection view
        [SNLog Log:@"Method Name: %s Display main screen", __PRETTY_FUNCTION__];

    }else if (state == NOT_LOGGED_IN){
        [SNLog Log:@"Method Name: %s Logout Initialiaze SDK", __PRETTY_FUNCTION__];
        //Just establish connection
        
        
        [SecurifiToolkit initSDKCloud];
        [SNLog Log:@"Method Name: %s Display login screen", __PRETTY_FUNCTION__];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, state];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LOGIN_NOTIFIER
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALMOND_LIST_NOTIFIER
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
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - Class methods
- (IBAction)LogsButtonHandler:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"SFILogViewController"];
    [self.navigationController pushViewController:mainView animated:YES];
}

-(void)displayNoCloudConnectionImage{
    if(!isConnectedToCloud){
        //Set the splash image differently for 3.5 inch and 4 inch screen
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            // code for 4-inch screen
            imgSplash.image = [UIImage imageNamed:@"no_cloud_640x1136"];
        } else {
            // code for 3.5-inch screen
            imgSplash.image = [UIImage imageNamed:@"no_cloud_640x960"];
        }
    }
}

#pragma mark - Reconnection

-(void)networkUpNotifier:(id)sender
{
    [SNLog Log:@"Method Name: %s MainView controller :In networkUP notifier", __PRETTY_FUNCTION__];
    state= [SecurifiToolkit getConnectionState];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, state];
    //PY 311013 Reconnection Logic
    if(state == SDK_UNINITIALIZED){
        [SecurifiToolkit initSDK];
        [HUD hide:YES];
    }
    else if (state == NOT_LOGGED_IN){
        isConnectedToCloud = TRUE;
        [displayNoCloudTimer invalidate];
        [SNLog Log:@"Method Name: %s Logout Initialiaze SDK", __PRETTY_FUNCTION__];
        [SNLog Log:@"Method Name: %s Display login screen", __PRETTY_FUNCTION__];
        [HUD hide:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
        [self presentViewController:mainView animated:YES completion:nil];
    }
}

void runOnMainQueueWithoutDeadLocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

-(void)networkDownNotifier:(id)sender
{
    
    self.state=[SecurifiToolkit getConnectionState];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, state];
    
    if(state == SDK_INITIALIZING || state == SDK_UNINITIALIZED){
        [SecurifiToolkit initSDK];
    }else{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //HUD.dimBackground = YES;
    HUD.labelText=@"Network Down";
    [HUD hide:YES afterDelay:1];
    isConnectedToCloud = FALSE;
    }
}


- (void)reachabilityDidChange:(NSNotification *)notification {
    //Reachability *reachability = (Reachability *)[notification object];
    [SNLog Log:@"Method Name: %s Reachability State : %d", __PRETTY_FUNCTION__, state];
    if (state == NETWORK_DOWN || state == SDK_UNINITIALIZED || state == SDK_INITIALIZING)
    {
        if ([SFIReachabilityManager isReachable]) {
            NSLog(@"Reachable - MAIN");
            //        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            //        HUD.dimBackground = YES;
            //        HUD.labelText=@"Reconnecting...";
            [SecurifiToolkit initSDK];
            //        [HUD hide:YES afterDelay:1];
        } else {
            NSLog(@"Unreachable");
            isConnectedToCloud = FALSE;
        }
    }
}


-(void)becomesActive:(id)sender
{
    state= [SecurifiToolkit getConnectionState];
    [SNLog Log:@"Method Name: %s BECOME ACTIVE State : %d", __PRETTY_FUNCTION__, state];
    
    if (state == NETWORK_DOWN || state == SDK_UNINITIALIZED)
    {
        //Start HUD till networkUP/DOWN or Login response notification comes
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //HUD.delegate = self;
        HUD.dimBackground = YES;
        
        
        [SecurifiToolkit initSDK];
    }
}

#pragma mark - Cloud Command : Sender and Receivers
-(void)loginResponseNotifier:(id)sender
{
    [SNLog Log:@"In Method Name: %s ", __PRETTY_FUNCTION__];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    
    //Always run UI code on main thread from Notification callback
    
    runOnMainQueueWithoutDeadLocking(^{
        state=[SecurifiToolkit getConnectionState];
        //[self.collectionView reloadData];
        [HUD hide:YES];
        
        //HUD.labelText=@"Connected to Server";
        //Disable HUD after successful login
        //[HUD hide:YES afterDelay:1];
    });
    
    //Login failed
    if ([notifier userInfo] == nil)
    {
        [SNLog Log:@"In Method Name: %s Temppass not found", __PRETTY_FUNCTION__];
//        //PY081113 - Delete personal data
//        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//        [prefs removeObjectForKey:EMAIL];
//        [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
//        [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
//        [prefs removeObjectForKey:USERID];
//        [prefs removeObjectForKey:PASSWORD];
//        [prefs synchronize];
//        
//        //Delete files
//        [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
//        [SFIOfflineDataManager deleteFile:HASH_FILENAME];
//        [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
//        [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
//        [self presentViewController:mainView animated:YES completion:nil];
        //[HUD hide:YES ];
        /*
         state = NOT_LOGGED_IN;
         
         runOnMainQueueWithoutDeadlocking(^{
         HUD.labelText=@"Temppass not found";
         [HUD hide:YES afterDelay:3];
         HUD = nil;
         });
         */
        
        
    }
    else
    {
        [SNLog Log:@"In Method Name: %s Received login response", __PRETTY_FUNCTION__];
        LoginResponse *obj = [[LoginResponse alloc] init];
        obj = (LoginResponse *)[data valueForKey:@"data"];
        
        //        NSLog(@"UserID %@",obj.userID);
        //        NSLog(@"TempPass %@",obj.tempPass);
        //        NSLog(@"isSuccessful : %d",obj.isSuccessful);
        //        NSLog(@"Reason : %@",obj.reason);
        
        isConnectedToCloud = TRUE;
        [displayNoCloudTimer invalidate];
        
        if (obj.isSuccessful == 1)
        {
            [SNLog Log:@"Method Name: %s Login Successful -- Load different view", __PRETTY_FUNCTION__];
            
            //Almond List
            HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            HUD.dimBackground = YES;
            HUD.labelText = @"Loading your personal data.";
            
            //Start update service
            dispatch_queue_t queue = dispatch_queue_create("com.securifi.almondplus", NULL);
            dispatch_async(queue, ^{
                [SFIDatabaseUpdateService stopDatabaseUpdateService];
                [SFIDatabaseUpdateService startDatabaseUpdateService];
            });
            
            //Retrieve Almond List, Device List and Device Value - Before displaying the screen
            [self loadAlmondList];
            
        }else{
            //PY081113 - Delete personal data
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs removeObjectForKey:EMAIL];
            [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
            [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
            [prefs removeObjectForKey:USERID];
            [prefs removeObjectForKey:PASSWORD];
            [prefs removeObjectForKey:COLORCODE];
            [prefs synchronize];
            
            //Delete files
            [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
            [SFIOfflineDataManager deleteFile:HASH_FILENAME];
            [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
            [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
            UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
            [self presentViewController:mainView animated:YES completion:nil];
        }
        obj=nil;
    }
    
    //Reload to reflect current view
    
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



@end
