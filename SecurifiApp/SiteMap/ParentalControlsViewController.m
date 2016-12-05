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
#import "ViewController.h"
#import "SubscriptionPlansViewController.h"

@interface ParentalControlsViewController ()<ParentControlCellDelegate,CategoryViewDelegate,NSURLConnectionDelegate,DetailsPeriodViewControllerDelegate,UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
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

@end

@implementation ParentalControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[Analytics sharedInstance] markParentalPage];
    self.parentsControlArr = [[NSMutableArray alloc]init];
    self.cat_view_more = [[CategoryView alloc]initParentalControlMoreClickView:CGRectMake(0, self.view.frame.size.height - 180, 188 , 320)];
    self.cat_view_more.delegate = self;
    int deviceID = _genericParams.headerGenericIndexValue.deviceID;
    self.client = [Client findClientByID:@(deviceID).stringValue];//dont put in viewDid load
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    self.amac = almond.almondplusMAC;
    self.cmac = [CommonMethods hexToString:self.client.deviceMAC];
    NSString *todayDate = [CommonMethods getTodayDate];
    [self createRequest:@"Bandwidth" value:@"7" date:todayDate];
    self.routerMode = toolkit.routerMode;
    
    self.isLocal = [toolkit useLocalNetwork:almond.almondplusMAC];
    
    NSLog(@"viewDidLoad ParentalControlsViewController");
    //    [self createArr];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear ParentalControlsViewController");
    [self.navigationController setNavigationBarHidden:YES];
    
    [super viewWillAppear:YES];
    self.isPressed = YES;
    [self initializeNotifications];
    self.switchView1.transform = CGAffineTransformMakeScale(0.70, 0.70);
    self.switchView3.transform = CGAffineTransformMakeScale(0.70, 0.70);
    
    
    NSArray  *arr = [GenericIndexUtil getClientDetailGenericIndexValuesListForClientID:self.client.deviceID];
    
    NSString *connection;
    
    
    if(self.client.webHistoryEnable == NO){
        self.switchView1.on = NO;
        self.view2.hidden = YES;
        self.clrHis.hidden = YES;
        self.viewTwoTop.constant = -40;
    }
    else{
        self.switchView1.on = YES;
        self.view2.hidden = NO;
        self.clrHis.hidden = NO;
        self.viewTwoTop.constant = 1;
    }
    if(self.client.bW_Enable == NO){
        self.switchView3.on = NO;
        self.dataLogView.hidden = YES;
        self.clrBW.hidden = YES;
    }
    else{
        self.switchView3.on = YES;
        self.dataLogView.hidden = NO;
        self.clrBW.hidden = NO;
    }
    
    
    for (GenericIndexValue *genericIndexValue in arr) {
        
        if([genericIndexValue.genericIndex.ID isEqualToString:@"-16"]){
            connection = genericIndexValue.genericValue.value;
            
            //self.dataLogView.hidden = YES;
        }
        else {
            
        }
        
        if([genericIndexValue.genericIndex.ID isEqualToString:@"-19"] && [genericIndexValue.genericValue.value isEqualToString:@"1"]){
            NSLog(@"blocked ");
            
            self.switchView3.on = NO;
            self.switchView3.hidden = YES;
            self.switchView1.hidden = YES;
            self.blockClientTxt.hidden = NO;
            self.blockClientTxt.text = @"Web history and Data usage are disabled for blocked devices. You can still see records from when the device was last active.";
            self.dataLogView.hidden = YES;
            self.clrBW.hidden = YES;
            
        }
    }
    
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
    NSLog(@"client connection = %@ & router mode  = %@ ",connection,self.routerMode);
    
    if([self.routerMode isEqualToString:@"ap"] || [self.routerMode isEqualToString:@"re"] ||[self.routerMode isEqualToString:@"WirelessSlave"] || [self.routerMode isEqualToString:@"WiredSlave"]){
        if([connection isEqualToString:@"wireless"]){
            self.switchView3.on = NO;
            self.dataLogView.hidden = YES;
            self.blockClientTxt.hidden = NO;
            self.blockClientTxt.text = @"For checking Data usage, Almond must be in Router Mode.";
             self.view3.hidden = YES;
        }
        else{
            self.switchView3.on = NO;
            self.switchView1.on = NO;
            self.view3.hidden = YES;
            self.view2.hidden = YES;
            self.view1.hidden = YES;
            self.dataLogView.hidden = YES;
            self.blockClientTxt.hidden = NO;
            self.blockClientTxt.text = @"This device is in wired connection. Web history requires wireless connection in RE/AP Mode. For checking Data usage, Almond must be in Router Mode.";
        }
    }
    self.icon.image = [UIImage imageNamed:self.genericParams.headerGenericIndexValue.genericValue.icon];
    self.clientName.text = self.client.name;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[self.client.deviceLastActiveTime integerValue]];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];//Accessed on matt's iPhone on Wed 29 June 11:00.
    [dateformate setDateFormat:@"EEEE dd MMMM HH:mm"]; // Date formater
    NSString *str = [dateformate stringFromDate:date];
    self.lastSeen.text = [NSString stringWithFormat:@"last activated time %@",str];
}

//-(void) viewWillDisappear:(BOOL) animated
//{
//    [super viewWillDisappear:animated];
//    if ([self isMovingFromParentViewController])
//    {
//        if (self.navigationController.delegate== self)
//        {
//            self.navigationController.delegate = nil;
//            NSLog(@"removing dlegate");
//        }
//    }
//}
-(void)viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // Navigation back button was pressed. Do some stuff
        [self.navigationController setNavigationBarHidden:NO];
    }
    [super viewWillDisappear:YES];
    self.blockClientTxt.hidden = YES;
    
}

- (IBAction)onLaunchPayment:(id)sender {
    NSLog(@"onLaunchPayment");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
//        nav.navigationBarHidden = YES;
        [self presentViewController:viewController animated:YES completion:nil];
    });
    
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
    NSLog(@"device edit - onUpdateDeviceIndexResponse");
    //    NSDictionary *payload;
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *payload = [notifier userInfo];
    NSLog(@"payload mobile command: %@", payload);
    //    if (dataInfo==nil || [dataInfo valueForKey:@"data"]==nil ) {
    //        return;
    //    }
    
    if (payload[@"MobileInternalIndex"] == nil) {
        return;
    }
    
    NSLog(@"payload mobile command: %@", payload);
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    if (isSuccessful) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSLog(@"not able to update....");
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

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
- (IBAction)switch1Action:(id)sender {
    UISwitch *actionSwitch = (UISwitch *)sender;
        BOOL state = [actionSwitch isOn];
        if(state == NO){
            self.view2.hidden = YES;
            self.clrHis.hidden = YES;
            self.viewTwoTop.constant = -40;
            self.client.webHistoryEnable = NO;
            [self saveNewValue:@"NO" forIndex:-23];
//            UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                             message:@"Disabling Web history will delete all your previous history records. Are you sure,you want to disable web history?"
//                                                            delegate:self
//                                                   cancelButtonTitle:@"Cancel"
//                                                   otherButtonTitles:@"Done",nil];
//            [alert setDelegate:self];
//            alert.tag = 1;
//            alert.alertViewStyle = UIAlertViewStyleDefault;
//            [alert show];
            
          
            
        }
        else{
            
            self.view2.hidden = NO;
            self.clrHis.hidden = NO;
            self.viewTwoTop.constant = 1;
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
//            UIAlertView  *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                             message:@"Disabling Web history will delete all your previous history records. Are you sure,you want to disable web history?"
//                                                            delegate:self
//                                                   cancelButtonTitle:@"Cancel"
//                                                   otherButtonTitles:@"Done",nil];
//            [alert setDelegate:self];
//            alert.tag = 2;
//            alert.alertViewStyle = UIAlertViewStyleDefault;
//            [alert show];
            }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Usage cycle reset date" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
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
         if(alertView.tag == 1){
             self.switchView1.on = YES;
         }
         else if(alertView.tag == 2){
             self.switchView3.on = YES;
         }
         else if(alertView.tag == 3){
             self.switchView3.on = NO;
             self.dataLogView.hidden = YES;
         }
         else if (alertView.tag == 5){
             
         }
         else if (alertView.tag == 6){
             
         }

    }
    else{
        if(alertView.tag == 1){
            self.view2.hidden = YES;
            self.clrHis.hidden = YES;
            self.viewTwoTop.constant = -40;
            self.client.webHistoryEnable = NO;
            [self saveNewValue:@"NO" forIndex:-23];
            [self createRequest:@"ClearHistory" value:@"ClearHistory" date:[CommonMethods getTodayDate]];
            
        }
        else if(alertView.tag == 2){
            self.dataLogView.hidden = YES;
            self.clrBW.hidden = YES;
            self.client.bW_Enable = NO;
            [self saveNewValue:@"NO" forIndex:-25];
            [self createRequest:@"ClearBandwidth" value:@"ClearBandwidth" date:[CommonMethods getTodayDate]];
        }
        else if(alertView.tag == 3){
            
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
        NSLog(@"instantiateViewControllerWithIdentifier IF");
        newWindow.client = self.client;
        [self.navigationController pushViewController:newWindow animated:YES];
        //        }
        //        else
        //        {   controller.client = self.client;
        //             NSLog(@"instantiateViewControllerWithIdentifier else");
        //            [self.navigationController pushViewController:controller animated:YES];
        //        }
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
            self.view2.hidden = YES;
            self.clrHis.hidden = YES;
            self.viewTwoTop.constant = -40;
            self.client.webHistoryEnable = NO;
            
        }
        else{
            self.view2.hidden = NO;
            self.clrHis.hidden = NO;
            self.viewTwoTop.constant = 1;
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
//    [self.cat_view_more setTranslatesAutoresizingMaskIntoConstraints:YES];
   // [self activateConstraintsForView:self.cat_view_more respectToParentView:self.view];
    self.cat_view_more.backgroundColor = [UIColor whiteColor];
//    [self stretchToSuperView:self.cat_view_more];
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
    
    [self sendHttpRequest:req];
    
}
-(void)sendHttpRequest:(NSString *)post {// make it paramater CMAC AMAC StartTag EndTag
    //NSString *post = [NSString stringWithFormat: @"userName=%@&password=%@", self.userName, self.password];
    dispatch_queue_t sendReqQueue = dispatch_queue_create("send_req", DISPATCH_QUEUE_SERIAL);
    dispatch_async(sendReqQueue,^(){
        
        NSLog(@"post req = %@",post);
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        [request setURL:[NSURL URLWithString:@"http://sitemonitoring.securifi.com:8081"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; [request setTimeoutInterval:20.0];
        [request setHTTPBody:postData];
        NSURLResponse *res= Nil;
        //[NSURLConnection connectionWithRequest:request delegate:self];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:nil];
        if(data == nil)
            return ;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"dict BW respose %@",dict);
        if([dict[@"search"] isEqualToString:@"ClearHistory"]){
            NSLog(@"clear history success");
            [BrowsingHistoryDataBase deleteDB:self.amac clientMac:self.cmac];
            return;
        }
        if([dict[@"search"] isEqualToString:@"ClearBandwidth"]){
            return;
        }
        
        [self InsertInDB:dict[@"Data"]];
    });
    
    
    //www.sundoginteractive.com/blog/ios-programmatically-posting-to-http-and-webview#sthash.tkwg2Vjg.dpuf
}
-(void)InsertInDB:(NSDictionary *)dict{
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
    
    NSString *readable;
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
    [self.navigationController pushViewController:newWindow animated:YES];
}

-(void)updateDetailPeriod:(NSString *)value date:(NSString*)date lavelText:(NSString*)labelText{
    NSLog(@"updateDetailPeriod");
    [self createRequest:@"Bandwidth" value:value date:date];
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
@end
