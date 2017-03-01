//
//  MeshSetupViewController.m
//  SecurifiApp
//
//  Created by Masood on 7/27/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MeshSetupViewController.h"
#import "MeshView.h"
#import "MBProgressHUD.h"
#import "MeshStatusCell.h"
#import "CommonMethods.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "MeshPayload.h"
#import "UIViewController+Securifi.h"
#import "Analytics.h"
#import "MeshEditViewController.h"
#import "ConnectionStatus.h"
#import "UICommonMethods.h"
#import "AlmondManagement.h"

#define REMOVE 1
#define FORCE_REMOVE 2
#define NETWORK_OFFLINE 3

@interface MeshSetupViewController ()<MeshViewDelegate, MBProgressHUDDelegate, UIAlertViewDelegate, MeshEditViewControllerDelegate>
@property (nonatomic) MeshView *meshView;
@property (nonatomic) MBProgressHUD *HUD;

@property (weak, nonatomic) IBOutlet UIView *masterConnectionView;
@property (weak, nonatomic) IBOutlet UIImageView *cloudToMasterAlm;

@property (weak, nonatomic) IBOutlet UIView *slaveConnectionView;
@property (weak, nonatomic) IBOutlet UIImageView *cloudToMstrAlmSlv;
@property (weak, nonatomic) IBOutlet UIImageView *MstrAlmToSlv;
@property (weak, nonatomic) IBOutlet UIImageView *slvSignalStrength;


@property (weak, nonatomic) IBOutlet UILabel *almondName;
@property (weak, nonatomic) IBOutlet UILabel *statusTxt;
@property (weak, nonatomic) IBOutlet UIButton *removeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomContraint;

@property (weak, nonatomic) IBOutlet UITableView *meshTableView;

@property (nonatomic) NSTimer *removeAlmondTimer;
@property (nonatomic) NSTimer *nonRepeatingTimer;


@end

@implementation MeshSetupViewController
int mii;
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Meshset up controller");
    if(self.isStatusView){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setUpAlmondStatus];
        });
        
        if(self.almondStatObj.isMaster)
            [[Analytics sharedInstance] markMasterScreen];
        else
            [[Analytics sharedInstance] markSlaveScreen];
        
        [self createKeyVals:self.almondStatObj];
    }else{
        [self setupMeshView];
        [[Analytics sharedInstance] markAddAlmondScreen];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    mii = arc4random() % 10000;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.removeAlmondTimer invalidate];
    
    if(self.meshView){
        [self.meshView removeNotificationObserver];
        self.meshView = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onMeshCommandResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil];
    
    [center addObserver:self
               selector:@selector(onConnectionStatusChanged:)
                   name:CONNECTION_STATUS_CHANGE_NOTIFIER
                 object:nil];
}

-(void)createKeyVals:(AlmondStatus *)stat{
    NSMutableArray *keyVals = [NSMutableArray new];
    NSString *location = self.hasLocationTag?stat.location:stat.name;
    [keyVals addObject:@{NSLocalizedString(@"location", @""):location?:@""}];
    [keyVals addObject:@{NSLocalizedString(@"connected_via", @""):stat.connecteVia?:@""}];
    [keyVals addObject:@{NSLocalizedString(@"interface", @""):stat.interface?:@""}];
    
    NSString *internetStatText = stat.isActive? NSLocalizedString(@"active", @""):NSLocalizedString(@"inactive", @"");
    [keyVals addObject:@{NSLocalizedString(@"connection_stat", @""):internetStatText.capitalizedString}];
    if(!stat.isMaster && [stat.interface isEqualToString:@"Wireless"])
        [keyVals addObject:@{NSLocalizedString(@"connection_str", @""):[self getSignalStrength:stat.signalStrength.integerValue]}];
    
    NSString *connectionStatText = stat.internetStat? NSLocalizedString(@"online", @""):NSLocalizedString(@"offline", @"");
    [keyVals addObject:@{NSLocalizedString(@"internet_stat", @""):connectionStatText.capitalizedString}];
    if(stat.ssid2)
        [keyVals addObject:@{@"5 GHz SSID":stat.ssid2?:@""}];
    [keyVals addObject:@{@"2.4 GHz SSID":stat.ssid1?:@""}];
    stat.keyVals = keyVals;
}

- (NSString *)getSignalStrength:(NSInteger)sig{
    // RSSI levels range from -50dBm (100%) to -100dBm (0%)
    // Signal Quality Levels : Highest 5. Lowest 0
    NSLog(@"sig value 1: %d", sig);
    if(sig == SLAVE_OFFLINE.intValue)
        return @"N/A";
    else if(sig == 0)
        return @"N/A";
    else if(sig >= -50)
        return NSLocalizedString(@"excellent", @"");
    else if(sig < -50 && sig >=-74)
        return NSLocalizedString(@"good", @"");
    else if(sig < -74 && sig >= -80)
        return NSLocalizedString(@"poor", @"");
    else
        return NSLocalizedString(@"extremely_poor", @"");
}

#define network events
-(void)onConnectionStatusChanged:(id)sender {
    NSNumber* status = [sender object];
    int statusIntValue = [status intValue];
 
    if(statusIntValue == NO_NETWORK_CONNECTION){
        if([self.nonRepeatingTimer isValid]){
            return;
        }
        
        NSLog(@"meshsetupcontrolle n/w down");
        [self.removeAlmondTimer invalidate];
        [self hideHUDDelegate];
        
        [self showAlert:@"" msg:NSLocalizedString(@"no_internet_alert", @"") cancel:@"Ok" other:nil tag:NETWORK_OFFLINE];
    }
    else if(statusIntValue == (int)(ConnectionStatusType*)AUTHENTICATED){
         if([[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_local){
             [[SecurifiToolkit sharedInstance] connectMesh];
         }
     }
}

-(void)setUpAlmondStatus{
    [self initializeNotification];
    self.almondName.text =  self.hasLocationTag?self.almondStatObj.location:self.almondStatObj.name;
    if(self.almondStatObj.isMaster){//check if master or slave
        //more to be done depending upon connection status images need to be updated
        //will put set of images in a view and hide/unhide the view.
        self.removeBtn.hidden = YES;
        self.tableBottomContraint.constant = 0; //to hide remove button.
        self.cloudToMasterAlm.image = [self getConnectionImage];
        NSString *statText = self.almondStatObj.internetStat? NSLocalizedString(@"online", @""):NSLocalizedString(@"offline", @"");
        
        [self toggleImages:NO weakImg:YES text:statText.capitalizedString];
    }else{
        self.cloudToMstrAlmSlv.image = [self getConnectionImage];
        self.MstrAlmToSlv.image = [self getMsterToSlaveImg];
        
        if([self.almondStatObj.interface isEqualToString:@"Wireless"]){
            self.slvSignalStrength.hidden = NO;
            self.slvSignalStrength.image = [self getSignalStrengthIcon];
        }
        else
            self.slvSignalStrength.hidden = YES;
        
        [self toggleImages:YES weakImg:NO text:[self getSignalStrengthText]];
    }
    [self setUpHUD];
}

-(UIImage *)getConnectionImage{
    return [UIImage imageNamed:@"green-connectivity-icon"];
}

-(UIImage *)getMsterToSlaveImg{
    if(self.almondStatObj.internetStat == NO)
        return [UIImage imageNamed:@"red-connectivity-icon"];
    
    return self.almondStatObj.signalStrength.integerValue < -80? [UIImage imageNamed:@"yellow-connectivity-icon"]: [UIImage imageNamed:@"green-connectivity-icon"];
}

-(NSString *)getSignalStrengthText{
    NSInteger sig = self.almondStatObj.signalStrength.integerValue;
    if(self.almondStatObj.internetStat == NO)
        return NSLocalizedString(@"offline", @"").capitalizedString;
    else if(sig < -80){
        return NSLocalizedString(@"weak_signal_strength", @"");
    }else{
        return NSLocalizedString(@"online", @"").capitalizedString;
    }
}


-(UIImage *)getSignalStrengthIcon{
    // RSSI levels range from -50dBm (100%) to -100dBm (0%)
    // Signal Quality Levels : Highest 5. Lowest 0
    NSInteger sig = self.almondStatObj.signalStrength.integerValue;
    if(sig >= -50)
        return [UIImage imageNamed:@"wifi-signal-strength4-icon"];
    else if(sig < -50 && sig >=-74)
        return [UIImage imageNamed:@"wifi-signal-strength3-icon"];
    else if(sig < -74 && sig >= -80)
        return [UIImage imageNamed:@"wifi-signal-strength2-icon"];
    else
        return [UIImage imageNamed:@"wifi-signal-strength1-icon"];
}

- (void)setupMeshView{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.meshView = [[MeshView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
        NSLog(@"nav viewheight: %f", CGRectGetHeight(self.view.frame));
        self.meshView.delegate = self;
        self.meshView.maxHopCount = self.maxHopCount;
        self.meshView.routerSummary = self.routerSummary;
        
        [self.meshView initializeFirstScreen:[CommonMethods getMeshDict:@"Interface"]];
        [self.meshView addInfoScreen:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-20)];
        
        [self.view addSubview:self.meshView];
        [self setUpHUD];
        //        self.meshView.backgroundColor = [UIColor grayColor];
    });
}

-(void)toggleImages:(BOOL)onlineHidden weakImg:(BOOL)weakHidden text:(NSString*)text{
    self.masterConnectionView.hidden = onlineHidden;
    self.slaveConnectionView.hidden = weakHidden;
    self.statusTxt.text = text;
}

-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.view addSubview:_HUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark table delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    //    return self.isMaster? 3: 1; for later use, as per design
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0? (self.almondStatObj.keyVals.count): (section == 1? 4: 2);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, tableView.frame.size.width, 20)];
    NSString *headerTitle = section == 0? @"NETWORK": (section == 1? @"PREFERENCES": @"NOTIFICATIONS");
    [UICommonMethods setLableProperties:label text:headerTitle textColor:[SFIColors ruleGraycolor] fontName:@"Avenir-Roman" fontSize:16 alignment:NSTextAlignmentLeft];
    [view addSubview:label];
    
    [UICommonMethods addLineSeperator:view yPos:32];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"self.almond mac: %@", self.almondMac);
    NSString *CELL_IDENTIFIER = @"statuscell";
    
    MeshStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    //    cell.delegate = self;
    UITableViewCellAccessoryType accType;
    if(indexPath.row == 0 ){
        if(self.almondStatObj.isMaster && !self.hasLocationTag){
            accType = UITableViewCellAccessoryNone;
        }else if(!self.almondStatObj.isMaster && (!self.almondStatObj.isActive || !self.almondStatObj.internetStat)){
            accType = UITableViewCellAccessoryNone;
        }else{
            accType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else
        accType = UITableViewCellAccessoryNone;
    
    NSDictionary *keyVal = self.almondStatObj.keyVals[indexPath.row];
    [cell setupCell:[keyVal allKeys].firstObject value:[keyVal allValues].firstObject accType:accType];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0 ){
        if(self.almondStatObj.isMaster && !self.hasLocationTag){
            
        }else if(!self.almondStatObj.isMaster && (!self.almondStatObj.isActive || !self.almondStatObj.internetStat)){
        
        }
        else{
            [self presentMeshController];
        }
    }
}

- (void)presentMeshController{
    MeshEditViewController *ctrl = [MeshEditViewController new];
    ctrl.delegate = self;
    ctrl.almondStatObj = self.almondStatObj;
    ctrl.routerSummary = self.routerSummary;
    [self presentViewController:ctrl animated:YES completion:nil];
}

#pragma mark mesh edit delegate
-(void)slaveNameDidChangeDelegate:(NSString *)name{
    [self.almondStatObj.keyVals replaceObjectAtIndex:0 withObject:@{@"Location":name?:@""}];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.almondName.text = name;
        [self.meshTableView reloadData];
    });
}

#pragma mark meshview delegates
-(void)dismissControllerDelegate{
    if([[SecurifiToolkit sharedInstance] currentConnectionMode] == SFIAlmondConnectionMode_cloud)
        [[SecurifiToolkit sharedInstance] asyncSendToNetwork:[GenericCommand requestRai2DownMobile:[AlmondManagement currentAlmond].almondplusMAC]];
    else
        [[SecurifiToolkit sharedInstance] shutDownMesh];
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

- (void)showToastDelegate:(NSString *)msg{
    NSLog(@"toast: %@", msg);
    [self showToast:msg];
}
#pragma mark button tap
- (IBAction)onRemoveThisAlmondTap:(id)sender { //this button is only enabled for slave
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"remove_almond_alert", @""), self.hasLocationTag?self.almondStatObj.location:self.almondStatObj.name];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"remove_almond", @"") message:msg delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = REMOVE;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
}

-(void)onMeshCommandResponse:(id)sender{
    NSLog(@"onmeshcommandresponse");
    //load next view
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    BOOL local = [toolkit useLocalNetwork:[AlmondManagement currentAlmond].almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"meshcontroller mesh payload: %@", payload);
    //    NSString *commandType = payload[COMMAND_TYPE];
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    NSString *cmdType = payload[COMMAND_TYPE];
    if(![cmdType isEqualToString:@"RemoveSlaveMobile"] && ![cmdType isEqualToString:@"ForceRemoveSlaveMobile"])
        return;
    [self hideHUDDelegate];
    
    [self.removeAlmondTimer invalidate];
    self.removeAlmondTimer = nil;
    
    if(isSuccessful){
        [self showToast:@"Successfully Removed!"];
        [self dismissControllerDelegate];
    }else{
        if([cmdType isEqualToString:@"RemoveSlaveMobile"]){
            NSLog(@"force remove 1");
            [self showForceRemoveAlert];
        }
        else if([cmdType isEqualToString:@"ForceRemoveSlaveMobile"]){
            [self showToast:NSLocalizedString(@"sorry_could_not_remove", @"")];
            [self dismissControllerDelegate];
        }
    }
}

-(void)showForceRemoveAlert{
    NSString *desc = NSLocalizedString(@"force_remove_almond", @"");
    //not using showalert because this has other button title.
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:desc delegate:self cancelButtonTitle:@"ForceRemove" otherButtonTitles:@"Cancel", nil];
    alert.tag = FORCE_REMOVE;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
}

#pragma mark button tap methods
- (IBAction)onCrossButtonTap:(id)sender {
    [self dismissControllerDelegate];
}

#pragma mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"meshsetupcontroller clicked index");
    if(self.isStatusView == NO)
        return;
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
        if(alertView.tag == NETWORK_OFFLINE){
            SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
            [toolkit asyncInitNetwork];
            int connectionTO = 5;
            self.nonRepeatingTimer = [NSTimer scheduledTimerWithTimeInterval:connectionTO target:self selector:@selector(onNonRepeatingTimeout:) userInfo:@(NETWORK_OFFLINE).stringValue repeats:NO];
            [self showHudWithTimeoutMsgDelegate:@"Trying to reconnect..." time:connectionTO];
        }
        else if(alertView.tag == FORCE_REMOVE){
            [self showHudWithTimeoutMsgDelegate:NSLocalizedString(@"removing_wait", @"") time:5];
            [MeshPayload requestForceRemoveSlave:mii uniqueName:self.almondStatObj.slaveUniqueName];
        }
    }else{
        if(alertView.tag == REMOVE){
            [self showHudWithTimeoutMsgDelegate:NSLocalizedString(@"removing_wait", @"") time:40];
            self.removeAlmondTimer = [NSTimer scheduledTimerWithTimeInterval:40 target:self selector:@selector(onRemoveAlmTimeout:) userInfo:nil repeats:NO];
            [MeshPayload requestRemoveSlave:mii uniqueName:self.almondStatObj.slaveUniqueName];
        }
    }
}

- (void)showAlert:(NSString *)title msg:(NSString *)msg cancel:(NSString*)cncl other:(NSString *)other tag:(int)tag{
    NSLog(@"controller show alert tag: %d", tag);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cncl otherButtonTitles:nil];
    alert.tag = tag;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
}

#pragma mark timer
-(void)onRemoveAlmTimeout:(id)sender{
    NSLog(@"onRemoveAlmTimeout called");
    if([self isDisconnected])
        return;
    
    [self.removeAlmondTimer invalidate];
    self.removeAlmondTimer = nil;
    NSLog(@"force remove 2");
    [self showForceRemoveAlert];
    
}

-(void)onNonRepeatingTimeout:(id)sender{
    [self hideHUDDelegate];
    NSLog(@"self.nonRepeatingTimer.userInfo: %@", self.nonRepeatingTimer.userInfo);
    int tag = [(NSString *)self.nonRepeatingTimer.userInfo intValue];
    
    if(tag == NETWORK_OFFLINE){
        if([self isDisconnected]){
            NSLog(@"ok 1");
            [self showAlert:@"" msg:NSLocalizedString(@"no_internet_alert", @"") cancel:@"Ok" other:nil tag:NETWORK_OFFLINE];
        }else{
            
        }
    }
    self.nonRepeatingTimer = nil;
}

-(BOOL)isDisconnected{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    return [toolkit connectionStatusFromNetworkState:[ConnectionStatus getConnectionStatus]] ==SFIAlmondConnectionStatus_disconnected;
}



@end
