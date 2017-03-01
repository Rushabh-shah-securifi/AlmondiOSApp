//
//  TimeZoneViewController.m
//  SecurifiApp
//
//  Created by Masood on 2/27/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "TimeZoneViewController.h"
#import "TimeZoneTableViewCell.h"
#import "MBProgressHUD.h"
#import "RouterPayload.h"
#import "UIViewController+Securifi.h"
#import "AlmondJsonCommandKeyConstants.h"

#define SLAVE_OFFLINE_TAG 1

@interface TimeZoneViewController ()<MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *timeZoneList;
@property (nonatomic) MBProgressHUD *HUD;
@end

@implementation TimeZoneViewController
int mii;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getTimeZones];
    [self setUpHUD];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    mii = arc4random() % 10000;
    
    [self initializeNotification];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getTimeZones{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TimeZones" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.timeZoneList = [content componentsSeparatedByString:@"?"];
}

-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = NO;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}
-(void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onAlmondPropertyResponse:) name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER object:nil]; //1064 response
    
    [center addObserver:self selector:@selector(onDynamicAlmondPropertyResponse:) name:NOTIFICATION_ALMOND_PROPERTIES_PARSED object:nil]; //list and each property change
}
#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timeZoneList.count/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectZero];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 5)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= @"timezone";
    
    TimeZoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[TimeZoneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *country = self.timeZoneList[indexPath.row*2];
    NSString *time = self.timeZoneList[indexPath.row*2+1];
    [cell setupCell:country time:time];
//    cell.delegate = self;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*v{"MobileInternalIndex":6747656,"AlmondMAC":"251176220100060","CommandType":"ChangeAlmondProperties","TimeZone":"WAT-1"}*/
    [self showHudWithTimeoutMsg:@"Please Wait!" time:10];
    NSString *value = self.timeZoneList[indexPath.row*2+1];
    [RouterPayload requestAlmondPropertyChange:mii action:@"TimeZone" value:value uptime:nil];
}

#pragma mark command response
-(void)onAlmondPropertyResponse:(id)sender{
    NSLog(@"onAlmondPropertyResponse");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    NSDictionary *payload;
    if([toolkit currentConnectionMode]==SFIAlmondConnectionMode_local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"payload: %@", payload);
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    /* {"CommandType":"ChangeAlmondProperties","Success":"false","OfflineSlaves":"Downstairs","Reason":"Slave in offline","MobileInternalIndex":"-1442706141"}
     */
    if(isSuccessful){
        //        [self showToast:@"Successfully Updated!"];
    }else{
        if([[payload[REASON] lowercaseString] hasSuffix:@"offline"]){
            NSArray *slaves = [payload[OFFLINE_SLAVES] componentsSeparatedByString:@","];
            NSString *subMsg = slaves.count == 1? @"Almond is": @"Almonds are";
            
            NSString *msg = [NSString stringWithFormat:@"Unable to change settings. Check if \"%@\" %@ active and with in range of other \nAlmond 3 units in your Home WiFi network.", payload[OFFLINE_SLAVES], subMsg];
            [self showAlert:@"" msg:msg cancel:@"OK" other:nil tag:SLAVE_OFFLINE_TAG];
            
        }
        else{
            [self showToast:@"Sorry! Could not update"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD hide:YES];
        });
    }
}

-(void)onDynamicAlmondPropertyResponse:(id)sender{
    NSLog(@"onDynamicAlmondPropertyResponse");
    //don't reload the dictionary will have old values
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
        [self showToast:@"Successfully Updated!"];
        
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark actions
- (IBAction)onBckBtnTap:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark hud methods
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg time:(NSTimeInterval)sec{
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

#pragma mark alert methods
- (void)showAlert:(NSString *)title msg:(NSString *)msg cancel:(NSString*)cncl other:(NSString *)other tag:(int)tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cncl otherButtonTitles:other, nil];
    alert.tag = tag;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        if(alertView.tag == SLAVE_OFFLINE_TAG){
            
        }
    }
    else{
        
    }
}
@end
