//
//  MeshEditViewController.m
//  SecurifiApp
//
//  Created by Masood on 10/10/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MeshEditViewController.h"
#import "MeshView.h"
#import "MBProgressHUD.h"
#import "UIViewController+Securifi.h"
#import "MeshPayload.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "ConnectionStatus.h"

#define NETWORK_OFFLINE -1

@interface MeshEditViewController ()<MeshViewDelegate, MBProgressHUDDelegate>
@property (nonatomic) MeshView *meshView;
@property (nonatomic) MBProgressHUD *HUD;
@property (nonatomic) int mii;
@property (nonatomic) NSString *slaveName;
@property (nonatomic) NSTimer *nonRepeatingTimer;

@end

@implementation MeshEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mii = arc4random() % 10000;
    [self setupMeshNamingView];
    [self initializeNotification];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onMeshCommandResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onNetworkDownNotifier:) name:NETWORK_DOWN_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onNetworkUpNotifier:) name:NETWORK_UP_NOTIFIER object:nil];
    
    [center addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [center addObserver:self selector:@selector(onKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)setupMeshNamingView{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.meshView = [[MeshView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
        [self.meshView removeNotificationObserver];
        
        self.meshView.isMeshEditView = YES;
        NSLog(@"nav viewheight: %f", CGRectGetHeight(self.view.frame));
        self.meshView.delegate = self;
        
        [self.meshView addNamingScreen:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-20)];
        
        [self.view addSubview:self.meshView];
        [self setUpHUD];
        //        self.meshView.backgroundColor = [UIColor grayColor];
    });
}

-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.view addSubview:_HUD];
}
#pragma mark meshview delegates
-(void)dismissControllerDelegate{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)showHudWithTimeoutMsgDelegate:(NSString*)hudMsg time:(NSTimeInterval)sec{
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:sec];
    });
}

- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

- (void)hideHUDDelegate{
    NSLog(@"hide HUD delegate called");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

#pragma mark command methods
-(void)requestSetSlaveNameDelegate:(NSString *)newName{
    if(newName.length == 0){
        [MeshPayload requestSetSlaveName:self.mii uniqueSlaveName:self.uniqueName newName:newName];
    }else{
        if(newName.length <= 2){
            //show toast
            [self showToast:@"Please Enter a name of atleast 3 characters."];
            return;
        }
        [MeshPayload requestSetSlaveName:self.mii uniqueSlaveName:self.uniqueName newName:newName];
    }
    self.slaveName = newName;
    [self showHudWithTimeoutMsgDelegate:@"Loading..." time:10];
}

-(void)onMeshCommandResponse:(id)sender{
    NSLog(@"mesh edit onmeshcommandresponse");
    //load next view
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    BOOL local = [toolkit useLocalNetwork:toolkit.currentAlmond.almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    
    NSLog(@"meshview mesh payload: %@", payload);
    NSString *commandType = payload[COMMAND_TYPE];
    if(![commandType isEqualToString:@"SetSlaveNameMobile"])
        return;
    [self hideHUDDelegate];
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    if(isSuccessful){
        [self.delegate slaveNameDidChangeDelegate:_slaveName];
        [self showToast:@"Successfully updated!"];
        
    }
    else{//failed
        [self showToast:@"Sorry! cound not update."];
    }
    [self dismissControllerDelegate];
}

- (void)onKeyboardDidShow:(id)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.meshView.frame;
        CGFloat y = -keyboardSize.height ;
        f.origin.y =  y ;
        self.meshView.frame = f;
    }];
    [self.meshView toggleTick1:YES tick2:NO];
}

-(void)onKeyboardDidHide:(id)notice{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.meshView.frame;
        f.origin.y = 20;
        self.meshView.frame = f;
    }];
}

- (void)onNetworkDownNotifier:(id)sender{
    NSLog(@"on network down");
    if([self.nonRepeatingTimer isValid]){
        return;
    }
    
    [self hideHUDDelegate];
    
    [self showAlert:@"" msg:@"Make sure your almond 3 has working internet connection to continue setup." cancel:@"Ok" other:nil tag:NETWORK_OFFLINE];
    
}

- (void)onNetworkUpNotifier:(id)sender{
    NSLog(@"mesh view network up");
    if([[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_local){
        [[SecurifiToolkit sharedInstance] connectMesh];
    }else{
        //we wait for login response in case of cloud
    }
}

#pragma mark alert methods

- (void)showAlert:(NSString *)title msg:(NSString *)msg cancel:(NSString*)cncl other:(NSString *)other tag:(int)tag{
    NSLog(@"mesh view show alert tag: %d", tag);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cncl otherButtonTitles:nil];
    alert.tag = tag;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
}

//delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
        if(alertView.tag == NETWORK_OFFLINE){
            NSLog(@"on alert ok");
            SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
            [toolkit asyncInitNetwork];
            int connectionTO = 5;
            self.nonRepeatingTimer = [NSTimer scheduledTimerWithTimeInterval:connectionTO target:self selector:@selector(onNonRepeatingTimeout:) userInfo:@(NETWORK_OFFLINE).stringValue repeats:NO];
            [self showHudWithTimeoutMsgDelegate:@"Trying to reconnect..." time:connectionTO];
        }
    }else{
        
    }
}
#pragma mark timer methods
-(void)onNonRepeatingTimeout:(id)sender{
    [self hideHUDDelegate];
    NSLog(@"self.nonRepeatingTimer.userInfo: %@", self.nonRepeatingTimer.userInfo);
    int tag = [(NSString *)self.nonRepeatingTimer.userInfo intValue];
    
    if(tag == NETWORK_OFFLINE){
        SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
        enum SFIAlmondConnectionStatus status = [toolkit connectionStatusFromNetworkState:[ConnectionStatus getConnectionStatus]];
        if(status == SFIAlmondConnectionStatus_disconnected){
            NSLog(@"ok 1");
            [self showAlert:@"" msg:@"Make sure your almond 3 has working internet connection to continue setup." cancel:@"Ok" other:nil tag:NETWORK_OFFLINE];
        }else{
            
        }
    }
    [self.nonRepeatingTimer invalidate];
}
@end
