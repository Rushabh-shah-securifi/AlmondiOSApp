//
//  InitialSlidingViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/25/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "InitialSlidingViewController.h"
#import <SecurifiToolkit/SecurifiToolkit.h>
#import "SNLog.h"
#import "AlmondPlusConstants.h"
#import "SFIReachabilityManager.h"
#import "Reachability.h"
#import "SFIOfflineDataManager.h"
#import "SFIDatabaseUpdateService.h"

@implementation InitialSlidingViewController
@synthesize state;
@synthesize isCloudConnectionBroken;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStoryboard *storyboard;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
    }
    
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"TabTop"];
    
    
    
    //[self.tabBarController.tabBar.items objectAtIndex:1].title = @"string";
    //  [[self.topViewController.tabBarController.tabBar.items objectAtIndex:1]title] = @"string";
}

-(void)viewDidAppear:(BOOL)animated{
    //PY 170913 Add observers
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, state];

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
                                             selector:@selector(LogoutAllResponseCallback:)
                                                 name:LOGOUT_ALL_NOTIFIER
                                               object:nil];
    
    isCloudConnectionBroken = FALSE;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LoginResponseCallback:)
                                                 name:LOGIN_NOTIFIER
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(becomesActive:)
//                                                 name:UIApplicationDidBecomeActiveNotification
//                                               object:nil];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, state];
    
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
                                                 name:LOGOUT_ALL_NOTIFIER
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LOGIN_NOTIFIER
                                                  object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIApplicationDidBecomeActiveNotification
//                                                  object:nil];
    
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


-(void)networkUpNotifier:(id)sender
{
    [SNLog Log:@"Method Name: %s In networkUP notifier", __PRETTY_FUNCTION__];
    state= [SecurifiToolkit getConnectionState];
    [SNLog Log:@"Method Name: %s State : %d", __PRETTY_FUNCTION__, state];
    
    if(state == SDK_UNINITIALIZED){
        [SecurifiToolkit initSDK];
    }
    else if (state == NOT_LOGGED_IN){
        [SNLog Log:@"Method Name: %s Logout Initialiaze SDK", __PRETTY_FUNCTION__];
        [SNLog Log:@"Method Name: %s Display login screen", __PRETTY_FUNCTION__];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
        [self presentViewController:mainView animated:YES completion:nil];
    }
}


-(void)networkDownNotifier:(id)sender
{
    self.state=[SecurifiToolkit getConnectionState];
    [SNLog Log:@"Method Name: %s State : %d ", __PRETTY_FUNCTION__, state];
//    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    HUD.dimBackground = YES;
//    HUD.labelText=@"Network Down";
//    [HUD hide:YES afterDelay:1];
//    if ([SFIReachabilityManager isReachable]) {
//        NSLog(@"Reachable: Reconnect to SDK");
//
//        [SecurifiToolkit initSDK];
//        //Reconnection times
//        
//    }
//    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        dispatch_async( dispatch_get_main_queue(), ^{
//            NSLog(@"Reconnection Done!!");
//        });
//    });

  
//
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//    UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
//    [self presentViewController:mainView animated:YES completion:nil];
    
    if(state == CLOUD_CONNECTION_BROKEN){
        //Try to login and check
        NSLog(@"Try to reconnect! Cloud ended connection");
        isCloudConnectionBroken = TRUE;
        [SecurifiToolkit initSDK];
    }
    
}


- (void)reachabilityDidChange:(NSNotification *)notification {
    //Reachability *reachability = (Reachability *)[notification object];
    if ([SFIReachabilityManager isReachable]) {
        NSLog(@"Reachable - SLIDE");
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        HUD.dimBackground = YES;
        HUD.labelText=@"Reconnecting...";
        [SecurifiToolkit initSDK];
        [HUD hide:YES afterDelay:1];
    } else {
        NSLog(@"Unreachable");
    }
}

-(void)LogoutAllResponseCallback:(id)sender
{
    [SNLog Log:@"In Method Name: %s", __PRETTY_FUNCTION__];
 
        [SNLog Log:@"Method Name: %s Logout All successful - All connections closed!", __PRETTY_FUNCTION__];
        dispatch_queue_t queue = dispatch_queue_create("com.securifi.almondplus", NULL);
        dispatch_async(queue, ^{
            [SFIDatabaseUpdateService stopDatabaseUpdateService];
        });
        
        //PY 170913 - Use navigation controller
        //[self.navigationController popViewControllerAnimated:YES];
        //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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

-(void)LoginResponseCallback:(id)sender{
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = (NSDictionary *)[notifier userInfo];
    //Login failed
    if(isCloudConnectionBroken){
        [SNLog Log:@"In Method Name: %s Cloud broken connection response", __PRETTY_FUNCTION__];
  
        isCloudConnectionBroken = FALSE;
    if ([notifier userInfo] == nil)
    {
        [SNLog Log:@"In Method Name: %s TEMP Pass failed", __PRETTY_FUNCTION__];
        //Logout
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs removeObjectForKey:EMAIL];
        [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
        [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
        [prefs removeObjectForKey:COLORCODE];
        [prefs synchronize];
        
        //Delete files
        [SFIOfflineDataManager deleteFile:ALMONDLIST_FILENAME];
        [SFIOfflineDataManager deleteFile:HASH_FILENAME];
        [SFIOfflineDataManager deleteFile:DEVICELIST_FILENAME];
        [SFIOfflineDataManager deleteFile:DEVICEVALUE_FILENAME];
        
        dispatch_queue_t queue = dispatch_queue_create("com.securifi.almondplus", NULL);
        dispatch_async(queue, ^{
            [SFIDatabaseUpdateService stopDatabaseUpdateService];
        });
  
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        UIViewController *mainView = [storyboard instantiateViewControllerWithIdentifier:@"Navigation"];
        [self presentViewController:mainView animated:YES completion:nil];
        
    }
    else
    {
        [SNLog Log:@"In Method Name: %s Received login response", __PRETTY_FUNCTION__];
        
        LoginResponse *obj = [[LoginResponse alloc] init];
        obj = (LoginResponse *)[data valueForKey:@"data"];
        
        //Login unsuccessful
        if (obj.isSuccessful == 0)
        {
            [SNLog Log:@"In Method Name: %s Logout because of reason: %@ Reason Code: %d ", __PRETTY_FUNCTION__, obj.reason, obj.reasonCode];
            //Logout
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs removeObjectForKey:EMAIL];
            [prefs removeObjectForKey:CURRENT_ALMOND_MAC];
            [prefs removeObjectForKey:CURRENT_ALMOND_MAC_NAME];
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
    }
        }
}


//void runOnMainQueueWithoutDeadlocking(void (^block)(void))
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


@end
