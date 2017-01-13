//
//  ParentalControlsViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/08/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ParentalControlsViewController.h"
#import "ParentControlCell.h"
#import "BrowsingHistoryViewController.h"
#import "ClientPayload.h"
#import "CategoryView.h"
#import "GenericIndexUtil.h"
#import "UIFont+Securifi.h"
#import "Analytics.h"
#import "CommonMethods.h"
#import "DetailsPeriodViewController.h"
#import "BrowsingHistoryDataBase.h"
#import "AlmondManagement.h"
#import "MBProgressHUD.h"
#import "HTTPRequest.h"

@interface ParentalControlsViewController ()<ParentControlCellDelegate,CategoryViewDelegate,HTTPDelegate,DetailsPeriodViewControllerDelegate,UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,MBProgressHUDDelegate>
@property (nonatomic) NSMutableArray *parentsControlArr;
@property (nonatomic) CategoryView *cat_view_more;
@property (weak, nonatomic) IBOutlet UIView *dataLogView;
@property (nonatomic) Client *client;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (weak, nonatomic) IBOutlet UILabel *lastSeen;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewOneTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTwoTop;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;

@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UISwitch *switchView1;
@property (weak, nonatomic) IBOutlet UISwitch *switchView3;
@property (weak, nonatomic) IBOutlet UIButton *backGrayButton;
@property BOOL isPressed;
@property (weak, nonatomic) IBOutlet UIButton *clrBW;
@property (weak, nonatomic) IBOutlet UIButton *clrHis;

@property (weak, nonatomic) IBOutlet UILabel *blockClientTxt;
@property (nonatomic) BOOL isLocal;
@property (nonatomic) NSString *routerMode;
@property (weak, nonatomic) IBOutlet UILabel *BWUpload;
@property (weak, nonatomic) IBOutlet UILabel *MbupTxt;

@property (weak, nonatomic) IBOutlet UILabel *BWDownload;
@property (weak, nonatomic) IBOutlet UILabel *MbDownTxt;
@property (weak, nonatomic) IBOutlet UILabel *NosDayLabel;

@property (nonatomic) NSString *cmac;
@property (nonatomic) NSString *amac;

@property (nonatomic) NSString *resetBWDate;
@property(nonatomic, readonly) MBProgressHUD *HUD;

@property (nonatomic) NSString *DaysValuenew;
@property (nonatomic) NSString *Datenew;
@property (nonatomic) NSString *label;

@property (nonatomic) HTTPRequest *httpReq;



@property BOOL isSendBWReq;
@end

@implementation ParentalControlsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [[Analytics sharedInstance] markParentalPage];
    [self initUIStart];
    [self setUpHUD];
   
}
-(void)initUIStart{
    self.DaysValuenew = @"7";
    self.label = @"Past week";
    self.Datenew = [CommonMethods getTodayDate];
    self.isSendBWReq = YES;
    
    self.parentsControlArr = [[NSMutableArray alloc]init];
    self.cat_view_more = [[CategoryView alloc]initParentalControlMoreClickView:CGRectMake(0, self.view.frame.size.height - 180, 188 , 320)];
    self.cat_view_more.delegate = self;
    int deviceID = _genericParams.headerGenericIndexValue.deviceID;
    
    self.client = [Client findClientByID:@(deviceID).stringValue];//dont put in viewDid load
}
-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
   
    self.httpReq = [[HTTPRequest alloc]init];
    self.httpReq.delegate = self;
    self.switchView1.transform = CGAffineTransformMakeScale(0.70, 0.70);
    self.switchView3.transform = CGAffineTransformMakeScale(0.70, 0.70);
    [self initMethodToolkit];
    
    [super viewWillAppear:YES];
    self.isPressed = YES;
    [self initializeNotifications];
    [self checkForClientProperty];
    [self checkForBlock];
    [self checkForLocal];
    [self iconTextUpdate];
    if(self.isSendBWReq){
        [self createRequest:@"Bandwidth" value:self.DaysValuenew date:self.Datenew];
        self.NosDayLabel.text = self.label;
    }
}
-(void)iconTextUpdate{
    self.icon.image = [UIImage imageNamed:self.genericParams.headerGenericIndexValue.genericValue.icon];
    self.clientName.text = self.client.name;
    
    self.lastSeen.text = [NSString stringWithFormat:@"last activated time %@",[self getLastSeenTime]];
}
-(void)initMethodToolkit{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
     self.amac = almond.almondplusMAC;
     self.cmac = [CommonMethods hexToString:self.client.deviceMAC];
    self.routerMode = toolkit.routerMode;
    self.isLocal = [toolkit useLocalNetwork:almond.almondplusMAC];

}
-(NSString *)getLastSeenTime{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[self.client.deviceLastActiveTime integerValue]];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];//Accessed on matt's iPhone on Wed 29 June 11:00.
    [dateformate setDateFormat:@"EEEE dd MMMM HH:mm"]; // Date formater
    NSString *str = [dateformate stringFromDate:date];
    return str;
}
-(void)switchOne:(BOOL)s1 switchThree:(BOOL)s3 viewTwo:(BOOL)v2 viewConstrin:(int)constrain viewOne:(BOOL)v1 viewThree:(BOOL)v3 dataLogView:(BOOL)d1{
    self.switchView1.hidden = s1;
    self.switchView3.hidden = s3;
    self.view2.hidden = v2;
    self.view1.hidden = v1;
    self.view3.hidden = v3;
    self.dataLogView.hidden = d1;
    self.viewTwoTop.constant = constrain;
    
}
-(void)checkForLocal{
    if(self.isLocal){
        
        BOOL isinternet = [[SecurifiToolkit sharedInstance]isCloudReachable];
        if(!isinternet){
            self.blockClientTxt.hidden = NO;
            self.blockClientTxt.text = @"You are in Local connection right now. Web history and data usage require active cloud connection to function.";
            self.dataLogView.hidden = YES;
            self.clrBW.hidden = YES;
        }
        else{
            self.blockClientTxt.hidden = YES;
            self.dataLogView.hidden = NO;
            self.clrBW.hidden = NO;
        }
        
    }
    
}
-(void)checkForBlock{
    NSArray  *arr = [GenericIndexUtil getClientDetailGenericIndexValuesListForClientID:self.client.deviceID];
    
    NSString *connection;
    for (GenericIndexValue *genericIndexValue in arr) {
        
        if([genericIndexValue.genericIndex.ID isEqualToString:@"-16"]){
            connection = genericIndexValue.genericValue.value;
        }
        
        if([genericIndexValue.genericIndex.ID isEqualToString:@"-19"] && [genericIndexValue.genericValue.value isEqualToString:@"1"]){
            self.switchView3.on = NO;
//            self.switchView1.hidden = YES;
//            self.switchView3.hidden = YES;
            self.clrHis.hidden = YES;
            self.blockClientTxt.hidden = NO;
            self.blockClientTxt.text = NSLocalizedString(@"Web_history_and_Data_usage", @"");
            self.clrBW.hidden = YES;
            [self switchOne:YES switchThree:YES viewTwo:NO viewConstrin:1 viewOne:NO viewThree:YES dataLogView:YES];
            
        }
    }
    
    if([self.routerMode isEqualToString:@"ap"] || [self.routerMode isEqualToString:@"re"] ||[self.routerMode isEqualToString:@"WirelessSlave"] || [self.routerMode isEqualToString:@"WiredSlave"]){
        if([connection isEqualToString:@"wireless"]){
            self.switchView3.on = NO;
            self.dataLogView.hidden = YES;
            self.blockClientTxt.hidden = NO;
            self.blockClientTxt.text = NSLocalizedString(@"For_checking_Data_usage", @"");
            self.view3.hidden = YES;
        }
        else{
            self.switchView3.on = NO;
            self.switchView1.on = NO;
            [self switchOne:NO switchThree:NO viewTwo:YES viewConstrin:1 viewOne:YES viewThree:YES dataLogView:YES];
            self.blockClientTxt.hidden = NO;
            self.blockClientTxt.text = NSLocalizedString(@"This_device_is_in_wired", @"");
        }
    }
}
-(void)checkForClientProperty{
    
    if(self.client.webHistoryEnable == NO){
        [self webHistoryOFf];
    }
    else{
        [self webHistoryON];
    }
    if(self.client.bW_Enable == NO){
        [self bwOFf];
    }
    else{
        [self bwON];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // Navigation back button was pressed. Do some stuff
        [self.navigationController setNavigationBarHidden:NO];
    }
    [super viewWillDisappear:YES];
    self.blockClientTxt.hidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initializeNotifications{
    NSLog(@"initialize notifications sensor table");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self //indexupdate or name/location change both
               selector:@selector(onCommandResponse:)
                   name:NOTIFICATION_COMMAND_RESPONSE_NOTIFIER
                 object:nil];
    [center addObserver:self
               selector:@selector(onWiFiClientsListResAndDynamicCallbacks:)
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER
                 object:nil];
}
-(void)onCommandResponse:(id)sender{ //mobile command sensor and client 1064
        NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *payload = [notifier userInfo];
        if (payload[@"MobileInternalIndex"] == nil) {
        return;
    }
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    if (isSuccessful) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"not able to update....");
    }
}
-(void)webHistoryON{
    self.switchView1.on = YES;
    self.view2.hidden = NO;
    self.clrHis.hidden = NO;
    self.viewTwoTop.constant = 1;

}
-(void)webHistoryOFf{
    self.switchView1.on = NO;
    self.view2.hidden = YES;
    self.clrHis.hidden = YES;
    self.viewTwoTop.constant = -40;
}
-(void)bwON{
    self.switchView3.on = YES;
    self.dataLogView.hidden = NO;
    self.clrBW.hidden = NO;
}
-(void)bwOFf{
    self.switchView3.on = NO;
    self.dataLogView.hidden = YES;
    self.clrBW.hidden = YES;
}

- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveNewValue:(NSString *)newValue forIndex:(int)index{
    Client *client = [Client findClientByID:@(self.genericParams.headerGenericIndexValue.deviceID).stringValue];
    // considering only web history
    int mii = arc4random() % 1000;
    client = self.client;
    
    [Client getOrSetValueForClient:client genericIndex:index newValue:newValue ifGet:NO];
    [ClientPayload getUpdateClientPayloadForClient:client mobileInternalIndex:mii];
}
-(void)setClientHistory{
    int deviceID = self.genericParams.headerGenericIndexValue.deviceID;
    Client *client = [Client findClientByID:@(deviceID).stringValue];
    client.webHistoryEnable = NO;
    
}
-(void)createArr{
    NSArray *Arr = @[@{@"img":@"parental_controls_icon",
                       @"text":@"Log Date Usage",
                       @"Switch":@"YES",
                       @"Tag":@"0"},
                     @{@"img":@"view_browsing_history_icon",
                       @"text":@"View Browsing History",
                       @"Switch":@"NO",
                       @"Tag":@"1"},
                     @{@"img":@"log_browsing_history_icon",
                       @"text":@"Log Browsing History",
                       @"Switch":@"YES",
                       @"Tag":@"2"}
                     ];
    [self.parentsControlArr removeAllObjects];
    self.parentsControlArr = [NSMutableArray arrayWithArray:Arr];
    
}
-(void)switchOneActionUI:(BOOL)hidden constarin:(int)constrain{
    self.view2.hidden = hidden;
    self.clrHis.hidden = hidden;
    self.viewTwoTop.constant = constrain;
}

- (IBAction)switch1Action:(id)sender {
    UISwitch *actionSwitch = (UISwitch *)sender;
        BOOL state = [actionSwitch isOn];
        if(state == NO){
            [self switchOneActionUI:YES constarin:-40];
            self.client.webHistoryEnable = NO;
            [self saveNewValue:@"NO" forIndex:-23];
    
        }
        else{
           
            [self switchOneActionUI:NO constarin:1];
            self.client.webHistoryEnable = YES;
            [self saveNewValue:@"YES" forIndex:-23];
            [[Analytics sharedInstance] markLogWebHistory];
            

        }
}
- (IBAction)switch3Action:(id)sender {
    UISwitch *actionSwitch = (UISwitch *)sender;
        BOOL state = [actionSwitch isOn];
        if(state == NO){
            self.dataLogView.hidden = YES;
            self.clrBW.hidden = YES;
            self.client.bW_Enable = NO;
            [self saveNewValue:@"NO" forIndex:-25];
            }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Usage cycle reset date" message:@"set date of the month" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alert.tag = 3;
            UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 0, 320, 216)];
            picker.delegate = self;
            picker.dataSource = self;
            picker.showsSelectionIndicator = YES;
            [alert addSubview:picker];
            alert.bounds = CGRectMake(0, 0, 320 + 20, alert.bounds.size.height + 216 + 20);
            [alert setValue:picker forKey:@"accessoryView"];
            [alert show];
            }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        if(alertView.tag == 3){
             self.switchView3.on = NO;
             self.dataLogView.hidden = YES;
         }
         else if (alertView.tag == 5){
             
         }
         else if (alertView.tag == 6){
             
         }
    }
    else{
         if(alertView.tag == 3){
            self.dataLogView.hidden = NO;
            self.clrBW.hidden = NO;
            self.client.bW_Enable = YES;
            [self saveNewValue:@"YES" forIndex:-25];
            [self createRequest:@"DataUsageReset" value:self.resetBWDate date:[CommonMethods getTodayDate]];
            [[Analytics sharedInstance] markALogDataUsage];
        }
        else if(alertView.tag == 5){
            [self createRequest:@"ClearBandwidth" value:@"ClearBandwidth" date:[CommonMethods getTodayDate]];
           
        }
        else if(alertView.tag == 6){
             [self createRequest:@"ClearHistory" value:@"ClearHistory" date:[CommonMethods getTodayDate]];
        }
        }
}
- (BrowsingHistoryViewController *)classExistsInNavigationController:(Class)class
{
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:class])
        {
            NSLog(@"BrowsingHistoryViewController class");
            return (BrowsingHistoryViewController*)controller;
        }
    }
    return nil;
}
- (IBAction)browsingHistoryBtn:(id)sender {
    
    if(self.isPressed == YES){
        //        BrowsingHistoryViewController *controller = [self classExistsInNavigationController:[BrowsingHistoryViewController class]];
        //
        //        if (!controller)
        //        {
        BrowsingHistoryViewController *newWindow = [self.storyboard   instantiateViewControllerWithIdentifier:@"BrowsingHistoryViewController"];
        newWindow.is_IotType = NO;
        NSLog(@"instantiateViewControllerWithIdentifier IF");
        newWindow.client = self.client;
        self.isSendBWReq = YES;
        [self.navigationController pushViewController:newWindow animated:YES];
        self.isPressed = NO;
        
    }
}
-(void)onWiFiClientsListResAndDynamicCallbacks:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if(dataInfo == NULL)
        return;
    NSDictionary *mainDict = [dataInfo valueForKey:@"data"];
    if(mainDict == NULL)
        return;
    NSDictionary * dict = mainDict[@"Clients"];
    
    if(dict == NULL || [dict allKeys].count == 0)
        return;
    
    NSString *ID = [[dict allKeys] objectAtIndex:0]; // Assumes payload always has one device.
    if(ID == NULL)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.client.deviceID isEqualToString:ID]){
            NSLog(@"switching the connection");
            self.switchView1.on = [[dict[ID] valueForKey:@"SMEnable"]boolValue];
            [self switch1ActionDynamic:[[dict[ID] valueForKey:@"SMEnable"]boolValue]];
            self.switchView3.on = [[dict[ID] valueForKey:@"BWEnable"]boolValue];
            [self switch3ActionDynamic:[[dict[ID] valueForKey:@"BWEnable"]boolValue]];
            
        }
    });
    
}
-(void)switch1ActionDynamic:(BOOL)isOn{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(isOn == NO){
            [self switchOneActionUI:YES constarin:-40];
            self.client.webHistoryEnable = NO;
            
        }
        else{
            [self switchOneActionUI:NO constarin:1];
            self.client.webHistoryEnable = YES;
            
        }
    });
}
-(void)switch3ActionDynamic:(BOOL)isOn{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(isOn == NO){
            self.dataLogView.hidden = YES;
            self.clrBW.hidden = YES;
            self.client.bW_Enable = NO;
            
        }
        else{

            self.dataLogView.hidden = NO;
            self.client.bW_Enable = YES;
            self.clrBW.hidden = NO;
        }
        
    });
}
-(void)onPreciselyDatePickerValueChanged:(id)sender{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSLog(@"date picker date %@",datePicker.date);
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 31;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld",row+1];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.resetBWDate = [NSString stringWithFormat:@"%ld",row+1];
    NSLog(@"self.resetBWDate %@",self.resetBWDate);
    return ;
}
- (IBAction)iconOutletClicked:(id)sender {
    self.cat_view_more.frame = CGRectMake(0, self.view.frame.size.height - 180, self.navigationController.view.bounds.size.width , 320);
    self.cat_view_more.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.cat_view_more];
    self.backGrayButton.hidden = NO;
}

-(void)closeMoreView{
    [self.cat_view_more removeFromSuperview];
    self.backGrayButton.hidden = YES;
}
- (IBAction)grayBackButtonClicked:(id)sender {
    [self closeMoreView];
}

-(void)createRequest:(NSString *)search value:(NSString*)value date:(NSString *)date{
    NSString *req ;
    req = [NSString stringWithFormat:@"search=%@&value=%@&today=%@&AMAC=%@&CMAC=%@",search,value,date,_amac,_cmac];
    [self showHudWithTimeoutMsg:@"Loading..." withDelay:1];
    [self.httpReq sendHttpRequest:req];
    
}
-(void)responseDict:(NSDictionary *)responseDict{
    NSDictionary *dict = responseDict[@"Data"];
    if(dict[@"RX"] == NULL || dict[@"TX"] == NULL)
        return ;
    dispatch_async(dispatch_get_main_queue(), ^() {
        
        NSArray *downArr = [self readableValueWithBytes:dict[@"RX"]];
        self.BWDownload.text = [downArr objectAtIndex:0];
        self.MbDownTxt.text = [NSString stringWithFormat:@"%@ Download",[downArr objectAtIndex:1]];
        
        NSArray *upArr = [self readableValueWithBytes:dict[@"TX"]];
        self.BWUpload.text = [upArr objectAtIndex:0];
        self.MbupTxt.text = [NSString stringWithFormat:@"%@ Upload",[upArr objectAtIndex:1]];
        
    });
}
- (NSArray *)readableValueWithBytes:(id)bytes{
    
    NSString *readable = @"0 KB";
    if (([bytes longLongValue] == 0)){
        
        readable = [NSString stringWithFormat:@"0 KB"];
    }
    //round bytes to one kilobyte, if less than 1024 bytes
    if (([bytes longLongValue] < 1024) && ([bytes longLongValue] > 1)){
        
        readable = [NSString stringWithFormat:@"1 KB"];
    }
    
    //kilobytes
    if (([bytes longLongValue]/1024)>=1){
        
        readable = [NSString stringWithFormat:@"%0.1f KB", ([bytes doubleValue]/1024)];
    }
    
    //megabytes
    if (([bytes longLongValue]/1024/1024)>=1){
        
        readable = [NSString stringWithFormat:@"%0.1f MB", ([bytes doubleValue]/1024/1024)];
    }
    
    //gigabytes
    if (([bytes longLongValue]/1024/1024/1024)>=1){
        
        readable = [NSString stringWithFormat:@"%0.1f GB", ([bytes doubleValue]/1024/1024/1024)];
        
    }
    
    //terabytes
    if (([bytes longLongValue]/1024/1024/1024/1024)>=1){
        
        readable = [NSString stringWithFormat:@"%0.1f TB", ([bytes doubleValue]/1024/1024/1024/1024)];
    }
    
    //petabytes
    if (([bytes longLongValue]/1024/1024/1024/1024/1024)>=1){
        
        readable = [NSString stringWithFormat:@"%0.1f PB", ([bytes doubleValue]/1024/1024/1024/1024/1024)];
    }
    
    NSArray* arrayOfStrings = [readable componentsSeparatedByString:@" "];
    return arrayOfStrings;
}
- (IBAction)detailPeriodButtonClicked:(id)sender {
    DetailsPeriodViewController *newWindow = [self.storyboard   instantiateViewControllerWithIdentifier:@"DetailsPeriodViewController"];

    if([self.NosDayLabel.text isEqualToString:@"LastDay"])
        newWindow.str = @"0";
    else if ([self.NosDayLabel.text isEqualToString:@"Past week"])
        newWindow.str = @"1";
    else if([self.NosDayLabel.text isEqualToString:@"Past month"])
        newWindow.str = @"2";
    else
        newWindow.str = @"3";
    
    newWindow.delegate = self;
    NSLog(@"instantiateViewControllerWithIdentifier IF");
    self.isSendBWReq = NO;
    [self.navigationController pushViewController:newWindow animated:YES];
}

-(void)updateDetailPeriod:(NSString *)value date:(NSString*)date lavelText:(NSString*)labelText{
    self.DaysValuenew = value;
    self.Datenew = date;
    [self createRequest:@"Bandwidth" value:self.DaysValuenew   date:self.Datenew];
    self.label = labelText;
    self.NosDayLabel.text = labelText;

}
- (IBAction)deleteDataUsage:(id)sender {
    UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                        message:@"Are you sure,you want to delete data usage?"
                                                                                       delegate:self
                                                                              cancelButtonTitle:@"Cancel"
                                                                              otherButtonTitles:@"Done",nil];
                                       [alert setDelegate:self];
                                       alert.tag = 5;
                                       alert.alertViewStyle = UIAlertViewStyleDefault;
                                       [alert show];
}
- (IBAction)deleteHistory:(id)sender {
                UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:@"Are you sure,you want to delete web history?"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                       otherButtonTitles:@"Done",nil];
                [alert setDelegate:self];
                alert.tag = 6;
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
}
- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg withDelay:(int)second {
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:second];
    });
}
@end
