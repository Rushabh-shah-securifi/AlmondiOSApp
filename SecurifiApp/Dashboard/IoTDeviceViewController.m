//
//  IoTDeviceViewController.m
//  
//
//  Created by Securifi-Mac2 on 07/12/16.
//
//

#import "IoTDeviceViewController.h"
#import "BrowsingHistoryViewController.h"
#import "CommonMethods.h"
#import "UICommonMethods.h"
#import "Client.h"
#import "ClientPayload.h"
#import "UIColor+Securifi.h"
#import "SFIColors.h"

#import "Colours.h"
#import "UIFont+Securifi.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "MySubscriptionsViewController.h"
#import "GenericIndexUtil.h"
#import "AlmondManagement.h"
#import "MBProgressHUD.h"
#import "IoTLearnMoreViewController.h"
#import "HTTPRequest.h"
#import "DetailsPeriodViewController.h"
#import "CommonMethods.h"

@interface IoTDeviceViewController ()<UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate,HTTPDelegate,DetailsPeriodViewControllerDelegate,UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UISwitch *iotSwitch;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *blockButton;
@property (weak, nonatomic) IBOutlet UIView *middleView;

@property (weak, nonatomic) IBOutlet UIImageView *clientImg;
@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (weak, nonatomic) IBOutlet UILabel *blockLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *learnMore;
@property (nonatomic )NSMutableArray *warningLables;
@property (nonatomic) Client *client;
@property BOOL isDNSScan;
@property(nonatomic, readonly) MBProgressHUD *HUD;

@property (weak, nonatomic) IBOutlet UILabel *iotSecurity_label;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic) HTTPRequest *httpReq;

@property (weak, nonatomic) IBOutlet UIView *DataUsageView;
@property (weak, nonatomic) IBOutlet UILabel *MBUpLbl;
@property (weak, nonatomic) IBOutlet UILabel *MBLblUP;
@property (weak, nonatomic) IBOutlet UILabel *MbDownLbl;
@property (weak, nonatomic) IBOutlet UILabel *MbLblDown;
@property (weak, nonatomic) IBOutlet UISwitch *DataUsageEnable;
@property (weak, nonatomic) IBOutlet UIView *dataUsage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BlockButtonTop;
@property NSInteger buttonTop;
@property (weak, nonatomic) IBOutlet UILabel *NosDayLabel;
@property (nonatomic) NSString *resetBWDate;
@property (nonatomic) NSString *label;


@property BOOL isEcho_Nest;
@end

@implementation IoTDeviceViewController
 int mii;

- (void)viewDidLoad {
    [super viewDidLoad];
     self.buttonTop = self.BlockButtonTop.constant;
    [self setUpHUD];

}
-(void)viewWillAppear:(BOOL)animated{
    self.middleView.hidden = _hideMiddleView;
    
    self.httpReq = [HTTPRequest new];
    _httpReq.delegate = self;
    self.tableView.hidden = _hideTable;
    self.isDNSScan = !_hideMiddleView;
    self.iotSwitch.transform = CGAffineTransformMakeScale(0.70, 0.70);
    self.DataUsageEnable.transform = CGAffineTransformMakeScale(0.70, 0.70);
    
    if(_hideMiddleView == YES){
        self.iotSecurity_label.text = @"IoT Scan";
        self.middleView.hidden = _hideMiddleView;
        self.dataUsage.hidden  = _hideMiddleView;
        self.BlockButtonTop.constant = self.buttonTop - 90;
    }
    else{
        self.iotSecurity_label.text = @"IoT Security";
        self.middleView.hidden = _hideMiddleView;
        self.dataUsage.hidden  = _hideMiddleView;
        self.BlockButtonTop.constant = self.buttonTop ;
    }
    
    
    self.learnMore.hidden = NO;
    [self setcientNameImg];
    [self getDescriptionLables:self.iotDevice];
    [self setAllowAndBlock];
    [self initializeNotifications];
    [super viewWillAppear:YES];
    
    
    
    [self.navigationController setNavigationBarHidden:YES];
    if(self.hideMiddleView == NO){
        [self createRequest:@"Bandwidth" value:@"7" date:[CommonMethods getTodayDate]];
        self.label = @"Past week";
    }
    self.DataUsageView.hidden = self.hideMiddleView;
    [self forRouterModetest];
//    self.NosDayLabel.text = self.label;
}
-(void)createRequest:(NSString *)search value:(NSString*)value date:(NSString *)date{
    NSString *req ;
    NSString *almMAC = [AlmondManagement currentAlmond].almondplusMAC;
    NSString *cmac = [CommonMethods hexToString:self.client.deviceMAC];
    req = [NSString stringWithFormat:@"search=%@&value=%@&today=%@&AMAC=%@&CMAC=%@",search,value,date,almMAC,cmac];
    [self showHudWithTimeoutMsg:@"Loading..." withDelay:1];
    [self.httpReq sendHttpRequest:req];
    
}
-(void)responseDict:(NSDictionary *)responseDict{
    if([responseDict[@"search"] isEqualToString:@"ClearBandwidth"])
        return;
    
    NSDictionary *dict = responseDict[@"Data"];
    
    if(dict[@"RX"] == NULL || dict[@"TX"] == NULL)
        return ;
    dispatch_async(dispatch_get_main_queue(), ^() {
        
        NSArray *downArr = [CommonMethods readableValueWithBytes:dict[@"RX"]];
        self.MbDownLbl.text = [downArr objectAtIndex:0];
        self.MbLblDown.text = [NSString stringWithFormat:@"%@ Download",[downArr objectAtIndex:1]];
        
        NSArray *upArr = [CommonMethods readableValueWithBytes:dict[@"TX"]];
        self.MBUpLbl.text = [upArr objectAtIndex:0];
        self.MBLblUP.text = [NSString stringWithFormat:@"%@ Upload",[upArr objectAtIndex:1]];
        
    });
}
-(void)setcientNameImg{
    self.client = [Client getClientByMAC:self.iotDevice[@"MAC"]];
    NSString *TypeImg = [self.client iconName];
    self.clientImg.image = [UIImage imageNamed:TypeImg];
    self.clientName.text = self.client.name;
}
-(void)blockUnblockCheck{
    if (self.client.deviceAllowedType == DeviceAllowed_Blocked) {
        self.iotSwitch.hidden = YES;
        self.DataUsageEnable.hidden = YES;
    }
    else{
        self.iotSwitch.hidden = NO;
        self.DataUsageEnable.hidden = NO;
    }
}
-(void)forRouterModetest{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSString *routerMode = toolkit.routerMode;
//    NSLog(@"client connection = %@ & router mode  = %@ ",routerMode);
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    BOOL isLocal = [toolkit useLocalNetwork:almond.almondplusMAC];
    NSArray  *arr = [GenericIndexUtil getClientDetailGenericIndexValuesListForClientID:self.client.deviceID];
    NSString *connection;
    
    for (GenericIndexValue *genericIndexValue in arr) {
        
        if([genericIndexValue.genericIndex.ID isEqualToString:@"-16"]){
            connection = genericIndexValue.genericValue.value;
        }
    }
    
    if(isLocal){
        self.iotSwitch.hidden = YES;
        self.DataUsageEnable.hidden = YES;
    }
    
    if([routerMode isEqualToString:@"ap"] || [routerMode isEqualToString:@"re"] ||[routerMode isEqualToString:@"WirelessSlave"] || [routerMode isEqualToString:@"WiredSlave"]){
        if(![connection isEqualToString:@"wireless"]){
            self.iotSwitch.hidden = YES;
            self.DataUsageEnable.hidden = YES;
            self.infoLabel.hidden = NO;
            self.dataUsage.hidden = YES;
            self.DataUsageView.hidden = YES;
            self.infoLabel.text = NSLocalizedString(@"ap_re_wired_iot", @"Add Almond");
        }
        else{
            self.iotSwitch.hidden = NO;
            self.DataUsageEnable.hidden = NO;
            if(self.hideMiddleView == NO)
                self.DataUsageView.hidden = NO;
        }
    }
}
-(void)initializeNotifications{
    NSLog(@"initialize notifications sensor table");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
 
    [center addObserver:self //common dynamic reponse handler for sensor and clients
               selector:@selector(onDeviceListAndDynamicResponseParsed:)
                   name:NOTIFICATION_DEVICE_LIST_AND_DYNAMIC_RESPONSES_CONTROLLER_NOTIFIER
                 object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)getDescripTionText:(NSDictionary*)returnDict{
    NSString *displayText;
    for(NSString *key in returnDict.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        NSDictionary *dict = returnDict[key];
        if([dict[@"P"]isEqualToString:@"1"])
            displayText = [CommonMethods type:dict[@"Tag"]];
    }
    return displayText;
}
-(void)clientInActiveUI{
    self.blockLabel.text = @"InActive";
    [self.blockButton setTitle:@"Block Device" forState:UIControlStateNormal];
    self.topView.backgroundColor = [UIColor lightGrayColor];
    self.blockButton.backgroundColor = [UIColor darkGrayColor];
}
-(void)clientActiveUI{
    self.blockLabel.text = @"Active";
    [self.blockButton setTitle:@"Block Device" forState:UIControlStateNormal];
    if(_isDNSScan)
        self.topView.backgroundColor = [UIColor securifiScreenGreen];
    else
        self.topView.backgroundColor = [self getColor:self.iotDevice];
    self.blockButton.backgroundColor = [UIColor darkGrayColor];
}
-(void)amazoneNestUI{
    self.topView.backgroundColor = [UIColor redColor];
    self.infoLabel.hidden= NO;
    self.infoLabel.text = @"This device is behaving suspiciously.Try resetting the device or remove it from your network.";
    if(self.hideMiddleView == NO)
        self.DataUsageView.hidden = YES;
    self.isEcho_Nest = YES;
}
-(void)setAllowAndBlock{
    self.infoLabel.hidden= YES;
    NSLog(@"client.deviceAllowedType %d",self.client.deviceAllowedType);
    dispatch_async(dispatch_get_main_queue(), ^() {
        if(!self.isDNSScan)
            self.iotSwitch.on = self.client.iot_serviceEnable;
        else
            self.iotSwitch.on = self.client.iot_dnsEnable;
    self.DataUsageEnable.on = self.client.bW_Enable;
        
    if(!self.client.isActive){
        [self clientInActiveUI];
    }
    else{
        [self clientActiveUI];
    }
        if(self.client.deviceAllowedType == 1){
            self.blockLabel.text = @"Blocked";
            [self.blockButton setTitle:@"Allow Device" forState:UIControlStateNormal];
            self.topView.backgroundColor = [UIColor darkGrayColor];
            self.blockButton.backgroundColor = [UIColor securifiScreenGreen];
            self.infoLabel.hidden= NO;
            if(self.hideMiddleView == NO)
                self.DataUsageView.hidden = YES;
            self.infoLabel.text = NSLocalizedString(@"blocked_client_iot", @"");
        }
        else{
            if(self.hideMiddleView == NO)
                self.DataUsageView.hidden = NO;
            if(!self.client.isActive){
                [self clientInActiveUI];
            }
            else{
                [self clientActiveUI];
            }
        }
        if(self.sectionType == vulnerable_section){
            self.topView.backgroundColor = [self getColor:self.iotDevice];
        }
        if(_hideMiddleView == NO){
//            if([self.client.deviceType isEqualToString:@"amazon_echo"] && [self.client.previousType isEqualToString:@"nest"]){
//                [self amazoneNestUI];
//            }
//            else if([self.client.deviceType isEqualToString:@"nest"] && [self.client.previousType isEqualToString:@"amazon_echo"]){
//                [self amazoneNestUI];
//            }
        }
    if(self.hideMiddleView == NO)
            self.DataUsageView.hidden = !self.client.bW_Enable;

        [self blockUnblockCheck];
        [self forRouterModetest];
    });
    
}

-(void)getDescriptionLables:(NSDictionary*)returnDict{
    self.warningLables = [[NSMutableArray alloc]init];
    for(NSString *key in returnDict.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        NSDictionary *dict = returnDict[key];
        if([dict[@"P"]isEqualToString:@"1"]){
            NSArray *ports = dict[@"Value"];
            NSString *portsDetail = [self getPortsStrings:ports];
            NSDictionary *LabelsDict = @{@"Label":[CommonMethods type:dict[@"Tag"]],
                                         @"Tag":dict[@"Tag"],
                                         @"Value":portsDetail
                                   };
            [self.warningLables addObject: LabelsDict];
            NSDictionary *LabelsDictNew;
            if([dict[@"Tag"] isEqualToString:@"1"]){
                for(NSString *port in ports){
                    if(port.intValue < 1024){
                        LabelsDictNew = @{@"Label":[CommonMethods type:dict[@"Tag"]],
                                                     @"Tag":dict[@"Tag"],
                                                     @"Value":portsDetail
                                                     };
                    }
                }
            }
        }
    }
}
-(NSString *)getPortsStrings:(NSArray *)ports{
    if(ports.count == 0)
        return @"";
    NSString *portsDetail = [ports componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"Ports: [%@]",portsDetail];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)handleTapOnLabel:(id)sender{
//    NSLog(@"hyper link pressed");NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", self.uriDict[@"hostName"]]];
//    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark tableDelege
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.sectionType == healthy_section)
    {
        return 1;
    }
        return self.warningLables.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier ];
    }
    if(self.sectionType == healthy_section)
    {
        cell = [self everyThingsFineLabel:cell];
        NSDictionary *dict;
        if(self.warningLables.count > 0)
        {
            dict = [self.warningLables objectAtIndex:indexPath.row];
        NSLog(@"self.warningLables %@",self.warningLables);
        if([dict[@"Tag"] isEqualToString:@"6"]){
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.text = dict[@"Label"];
            NSString *iconName = @"tamper";
            cell.imageView.image = [UICommonMethods imageNamed:iconName withColor:[SFIColors clientGreenColor]];
             cell.detailTextLabel.text = dict[@"Value"];
            cell = [self cellProperties:cell];
            return cell;
        }
        }
        return cell;
    }
    NSDictionary *dict = [self.warningLables objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.text = dict[@"Label"];
    NSString *iconName = @"tamper";
    UIColor *color;
NSLog(@"dict tag %@ ",dict[@"Tag"]);
    if([dict[@"Tag"] isEqualToString:@"1"]||[dict[@"Tag"] isEqualToString:@"3"])
        color = [UIColor redColor];
    else
        color = [UIColor orangeColor];
    cell.imageView.image = [UICommonMethods imageNamed:iconName withColor:color];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont securifiFont:14];
    cell.detailTextLabel.text = dict[@"Value"];
    cell.detailTextLabel.font = [UIFont securifiFont:12];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    CGSize itemSize = CGSizeMake(30,30);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0,0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 60;
}
- (IBAction)blockClientRequest:(id)sender {
     mii = arc4random()%10000;
     [self showHudWithTimeoutMsg:@"Loading..." withDelay:1];
    if(self.client.deviceAllowedType == 0){
        self.client.deviceAllowedType = 1;
    }
    else {
        self.client.deviceAllowedType = 0;
    }
    [ClientPayload getUpdateClientPayloadForClient:self.client mobileInternalIndex:mii];
}


-(UIColor *)getColor:(NSDictionary *)returnDict{
    UIColor *color = nil;
    if(returnDict.allKeys.count == 1){
         return  [UIColor securifiScreenGreen];
    }
    for(NSString *key in returnDict.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        
        NSDictionary *dict = returnDict[key];
        NSLog(@"dict   == %@",dict);

        if([dict[@"P"]isEqualToString:@"1"]){
            if([dict[@"Tag"]isEqualToString:@"1"] || [dict[@"Tag"]isEqualToString:@"3"]){
                color = [UIColor redColor];
                break;
            }
            else
                color = [UIColor orangeColor];
            continue;
        }
        
    }
    if(self.sectionType == healthy_section)
        return [SFIColors clientGreenColor];
        
    return color;
}

-(void)onDeviceListAndDynamicResponseParsed:(id)sender{
    NSLog(@"device edit - onDeviceListAndDynamicResponseParsed");
    [self hideHude];
        SecurifiToolkit *toolkit =[SecurifiToolkit sharedInstance];
        for(Client *client in toolkit.clients){
            if([self.client.deviceID isEqualToString:client.deviceID]){
                self.client = [client copy];
                [self setAllowAndBlock];
                
            }
        }
}

-(UITableViewCell *)cellProperties:(UITableViewCell *)cell{
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont securifiFont:14];
    cell.detailTextLabel.font = [UIFont securifiFont:12];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    CGSize itemSize = CGSizeMake(30,30);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0,0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}
- (IBAction)viewHistoryButtonClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
    BrowsingHistoryViewController *newWindow = [storyboard   instantiateViewControllerWithIdentifier:@"BrowsingHistoryViewController"];
    newWindow.is_IotType = YES;
    NSLog(@"instantiateViewControllerWithIdentifier IF");
    newWindow.client = self.client;
    [self.navigationController pushViewController:newWindow animated:YES];
    
}
- (IBAction)dataUsageEnDis:(id)sender {
    UISwitch *actionSwitch = (UISwitch *)sender;
    BOOL state = [actionSwitch isOn];
    if(state == NO){
        self.DataUsageView.hidden = YES;
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
- (IBAction)iotServiceEnableDisable:(id)sender {
    UISwitch *actionSwitch = (UISwitch *)sender;
    BOOL state = [actionSwitch isOn];
    mii = arc4random()%10000;
    
    NSLog(@"state %d",state);
    if(!self.isDNSScan){
        if(state == NO){
            self.client.iot_serviceEnable = NO;
             [self saveNewValue:@"NO" forIndex:-26];
        }
        if(state == YES){
             [self saveNewValue:@"YES" forIndex:-26];
        }
    }
    else{
        if(state == NO){
             [self saveNewValue:@"NO" forIndex:-27];
        }
        if(state == YES){
             [self saveNewValue:@"YES" forIndex:-27];
        }
    }
    NSLog(@"self.client.iot_serviceEnable %d",self.client.iot_serviceEnable);
    [ClientPayload getUpdateClientPayloadForClient:self.client mobileInternalIndex:mii];

}
-(void)saveNewValue:(NSString *)newValue forIndex:(int)index{
    
    // considering only web history
    int mii = arc4random() % 1000;
   Client *client = self.client;
    
    [Client getOrSetValueForClient:client genericIndex:index newValue:newValue ifGet:NO];
    [ClientPayload getUpdateClientPayloadForClient:client mobileInternalIndex:mii];
}
- (IBAction)launchMySubscription:(id)sender {
    MySubscriptionsViewController *ctrl = [self getStoryBoardController:@"SiteMapStoryBoard" ctrlID:@"MySubscriptionsViewController"];
    [self pushViewController:ctrl];
}
-(id)getStoryBoardController:(NSString *)storyBoardName ctrlID:(NSString*)ctrlID{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    id controller = [storyboard instantiateViewControllerWithIdentifier:ctrlID];
    return controller;
}

- (IBAction)onLearnMoreTap:(id)sender {
    IoTLearnMoreViewController *ctrl = [self getStoryBoardController:@"MainDashboard" ctrlID:@"IoTLearnMoreViewController"];
    
    ctrl.issueTypes = [[self getIssueTypes] sortedArrayUsingSelector: @selector(compare:)];
    if(self.isEcho_Nest)
        ctrl.issueTypes = @[@"10"];
    [self pushViewController:ctrl];
}

- (NSArray *)getIssueTypes{
    NSMutableArray *issueTags = [NSMutableArray new];
    for(NSString *key in self.iotDevice.allKeys){
        if([key isEqualToString:@"MAC"])
            continue;
        NSDictionary *issue = self.iotDevice[key];
        if([issue[@"P"] integerValue] == 1)
            [issueTags addObject:issue[@"Tag"]];
    }
    return issueTags;
}

-(void)pushViewController:(UIViewController *)viewCtrl{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:viewCtrl animated:YES];
    });
}
-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.view addSubview:_HUD];
}
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg withDelay:(int)second {
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:second];
    });
}
- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}
-(void)hideHude{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
    
}
-(UITableViewCell *)everyThingsFineLabel:(UITableViewCell *)cell{
    cell.imageView.image = [UIImage imageNamed:@"ic_check_circle_green"];
    cell.textLabel.text = @"Everything looks good";
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [UIFont securifiFont:14];
    CGSize itemSize = CGSizeMake(30,30);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0,0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cell;
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
- (IBAction)changeTpastWeak:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
    DetailsPeriodViewController *newWindow = [storyBoard   instantiateViewControllerWithIdentifier:@"DetailsPeriodViewController"];
    
    if([self.NosDayLabel.text isEqualToString:@"Today"])
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
    [self createRequest:@"Bandwidth" value:value  date:date];
     self.label = labelText;
    self.NosDayLabel.text = labelText;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
         if (alertView.tag == 6){
        }
    }
    else{
        if(alertView.tag == 5){
            [self createRequest:@"ClearBandwidth" value:@"ClearBandwidth" date:[CommonMethods getTodayDate]];
        }
        else if(alertView.tag == 3){
            self.DataUsageView.hidden = NO;
            self.client.bW_Enable = YES;
            [self saveNewValue:@"YES" forIndex:-25];
            [self createRequest:@"DataUsageReset" value:self.resetBWDate date:[CommonMethods getTodayDate]];
            
        }
    }
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

@end
