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
@property (nonatomic) NSString *name;
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
    
    [center addObserver:self selector:@selector(onKeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [center addObserver:self selector:@selector(onKeyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [center addObserver:self
               selector:@selector(onConnectionStatusChanged:)
                   name:CONNECTION_STATUS_CHANGE_NOTIFIER
                 object:nil];
    
    [center addObserver:self
               selector:@selector(almondNameChangeResponseCallback:)
                   name:kSFIDidChangeAlmondName
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onDynamicAlmondLocationChange:)
                   name:DYNAMIC_ALMOND_LOCATION_CHANIGE_NOTIFIER
                 object:nil];
    
    [center addObserver:self selector:@selector(onAlmondLocationChange:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil];
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
    if(newName.length <= 2){
        //show toast
        [self showToast:@"Please Enter a name of atleast 3 characters."];
        return;
    }
    else if (newName.length > 32) {
         [self showToast:NSLocalizedString(@"accounts.itoast.almondNameMax32Characters", @"Almond Name cannot be more than 32 characters.")];
        return;
    }
    if(self.isMaster){
        [[SecurifiToolkit sharedInstance] asyncSendToNetwork:[GenericCommand requestAlmondLocationChange:_mii location:newName]];
            ;
    }else{
        //this will actually change location
        [MeshPayload requestSetSlaveName:self.mii uniqueSlaveName:self.uniqueName newName:newName];
    }

    self.name = newName;
    [self showHudWithTimeoutMsgDelegate:@"Loading..." time:10];
}

/*
-(void)localAlmondNameChange:(int)mii name:(NSString*)name{
    NSDictionary *payload = @{
                              @"CommandType":@"SetAlmondName",
                              @"Name" : name,
                              @"MobileInternalIndex":@(mii).stringValue
                              };
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_ALMOND_NAME_CHANGE_REQUEST];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
}
*/
- (void)onAlmondLocationChange:(id)sender{
    NSDictionary *payload;
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    
    if (dataInfo==nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    
    if([SecurifiToolkit sharedInstance].currentConnectionMode == SFIAlmondConnectionMode_local){
        payload = dataInfo[@"data"];
    }else{
        payload = [dataInfo[@"data"] objectFromJSONData];
    }
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    if(isSuccessful == NO){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showToast:NSLocalizedString(@"sorry_could_not_update", @"")];
        });
    }
    
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
        [self.delegate slaveNameDidChangeDelegate:_name];
        [self showToast:@"Successfully updated!"];
        
    }
    else{//failed
        [self showToast:@"Sorry! Could not update."];
    }
    [self dismissControllerDelegate];
}

- (void)onDynamicAlmondLocationChange:(id)sender{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    SFIAlmondConnectionMode connectionMode = [toolkit currentConnectionMode];
    
    NSDictionary *payload = [dataInfo valueForKey:@"data"];
    NSString *almondMAC = payload[ALMONDMAC];
    //{"CommandType":"DynamicAlmondLocationChange","AlmondLocation":"Den","AlmondMAC":"251176216952836"}
    if(connectionMode == SFIAlmondConnectionMode_cloud && ![almondMAC isEqualToString:toolkit.currentAlmond.almondplusMAC]){
        return;
    }
    
    if (almondMAC.length != 0) {
        //Change Owned Almond Name
        [self.delegate slaveNameDidChangeDelegate:payload[@"AlmondLocation"]];
        [self showToast:@"Successfully updated!"];
    }
    else {
        NSLog(@"almondNameChangeResponseCallback ");
        [self showToast:@"Sorry! We were unable to change Almond's Location"];
    }
    [self hideHUDDelegate];
    [self dismissControllerDelegate];
}

- (void)almondNameChangeResponseCallback:(id)sender {
    NSLog(@"almondNameChangeResponseCallback");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    SFIAlmondConnectionMode connectionMode = [toolkit currentConnectionMode];
    
    DynamicAlmondNameChangeResponse *obj = [dataInfo valueForKey:@"data"];
    if(connectionMode == SFIAlmondConnectionMode_cloud && ![obj.almondplusMAC isEqualToString:toolkit.currentAlmond.almondplusMAC]){
        return;
    }

    if (obj.almondplusMAC.length != 0) {
        //Change Owned Almond Name
        [self.delegate slaveNameDidChangeDelegate:_name];
        [self showToast:@"Successfully updated!"];
    }
    else {
        NSLog(@"almondNameChangeResponseCallback ");
        [self showToast:NSLocalizedString(@"accounts.itoast.unableToChangeAlmondName", @"Sorry! We were unable to change Almond's name2222")];
    }
    [self hideHUDDelegate];
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


-(void)onConnectionStatusChanged:(id)sender {
    NSNumber* status = [sender object];
    int statusIntValue = [status intValue];
    
    if(statusIntValue == NO_NETWORK_CONNECTION){
        NSLog(@"on network down");
        if([self.nonRepeatingTimer isValid]){
            return;
        }
        
        [self hideHUDDelegate];
        
        [self showAlert:@"" msg:@"Make sure your almond 3 has working internet connection to continue setup." cancel:@"Ok" other:nil tag:NETWORK_OFFLINE];

    }
    else if(statusIntValue == (int)(ConnectionStatusType*)AUTHENTICATED){
        if([[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_local){
            [[SecurifiToolkit sharedInstance] connectMesh];
        }
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
        SFIAlmondConnectionStatus status = [toolkit connectionStatusFromNetworkState:[ConnectionStatus getConnectionStatus]];
        if(status == SFIAlmondConnectionStatus_disconnected){
            NSLog(@"ok 1");
            [self showAlert:@"" msg:@"Make sure your almond 3 has working internet connection to continue setup." cancel:@"Ok" other:nil tag:NETWORK_OFFLINE];
        }else{
            
        }
    }
    [self.nonRepeatingTimer invalidate];
}
@end
