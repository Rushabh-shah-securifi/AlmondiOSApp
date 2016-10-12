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

@interface ParentalControlsViewController ()<ParentControlCellDelegate,CategoryViewDelegate>
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




@end

@implementation ParentalControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.parentsControlArr = [[NSMutableArray alloc]init];
    self.cat_view_more = [[CategoryView alloc]initParentalControlMoreClickView];
    self.cat_view_more.delegate = self;
    int deviceID = _genericParams.headerGenericIndexValue.deviceID;
    self.client = [Client findClientByID:@(deviceID).stringValue];//dont put in viewDid load
    
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
    for (GenericIndexValue *genericIndexValue in arr) {
        NSLog(@"genericIndexValue.genericIndex.ID %@ value %@",genericIndexValue.genericIndex.ID ,genericIndexValue.genericValue.value);
        
        if([genericIndexValue.genericIndex.ID isEqualToString:@"-16"] && ![genericIndexValue.genericValue.value isEqualToString:@"wireless"]){
            self.dataLogView.hidden = YES;
            self.switchView3.on = NO;
            if(![genericIndexValue.genericValue.value isEqualToString:@"wireless"])
            self.switchView3.userInteractionEnabled = NO;
        }
        if([genericIndexValue.genericIndex.ID isEqualToString:@"-19"] && [genericIndexValue.genericValue.value isEqualToString:@"1"]){
            NSLog(@"blocked ");
            self.dataLogView.hidden = YES;
            self.switchView3.on = NO;
            self.switchView1.on = NO;
            self.switchView3.userInteractionEnabled = NO;
            self.switchView1.userInteractionEnabled = NO;
        }
    }
    self.icon.image = [UIImage imageNamed:self.genericParams.headerGenericIndexValue.genericValue.icon];
    self.clientName.text = self.client.name;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[self.client.deviceLastActiveTime integerValue]];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];//Accessed on matt's iPhone on Wed 29 June 11:00.
    [dateformate setDateFormat:@"EEEE dd MMMM HH:mm"]; // Date formater
    NSString *str = [dateformate stringFromDate:date];
    self.lastSeen.text = [NSString stringWithFormat:@"last activated time %@",str];
    dispatch_async(dispatch_get_main_queue(), ^{
    
    if(self.client.webHistoryEnable == NO){
        self.switchView1.on = NO;
        self.view2.hidden = YES;
        self.viewTwoTop.constant = -40;
    }
    else{
        self.switchView1.on = YES;
        self.view2.hidden = NO;
        self.viewTwoTop.constant = 1;
    }
    if(self.client.bW_Enable == NO){
        self.switchView3.on = NO;
        self.dataLogView.hidden = YES;
    }
    else{
        self.switchView3.on = YES;
        self.dataLogView.hidden = NO;
    }
    });
   
}
//-(void) viewWillDisappear:(BOOL) animated
//{
//    [super viewWillDisappear:animated];
//    if ([self isMovingFromParentViewController])
//    {
//        if (self.navigationController.delegate)
//        {
//            self.navigationController.delegate = nil;
//        }
//    }
//}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
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
-(void)switchPressed:(BOOL)isOn andTag:(NSInteger)tag saveNewValue:(BOOL)isSave{
//    if(tag == 0){
//        if(isOn == NO){
//           [self.parentsControlArr removeObjectAtIndex:1];
//            NSLog(@"removed obj");
////            [self setClientHistory];//send NO req
//            if(isSave)
//            [self saveNewValue:@"NO" forIndex:-23];
//        }
//        else{
//            if(isSave)
//                [self saveNewValue:@"YES" forIndex:-23];
//            [self createArr];//send YES req
//        }
//    }
//    if(tag == 2){
//        if(isOn == NO){
//            [self saveNewValue:@"NO" forIndex:-25];
//            self.dataLogView.hidden = YES;//send NO req
//        }
//        else{
//            [self saveNewValue:@"YES" forIndex:-25];
//            self.dataLogView.hidden = NO;//send YES req
//        }
// 
//    }
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
    dispatch_async(dispatch_get_main_queue(), ^{
    BOOL state = [actionSwitch isOn];
    if(state == NO){
        self.view2.hidden = YES;
        self.viewTwoTop.constant = -40;
        self.client.webHistoryEnable = NO;
         [self saveNewValue:@"NO" forIndex:-23];
        
    }
    else{
        self.view2.hidden = NO;
        self.viewTwoTop.constant = 1;
        self.client.webHistoryEnable = YES;
        [self saveNewValue:@"YES" forIndex:-23];
        
    }
});
}
- (IBAction)switch3Action:(id)sender {
    UISwitch *actionSwitch = (UISwitch *)sender;
    dispatch_async(dispatch_get_main_queue(), ^{
    BOOL state = [actionSwitch isOn];
    if(state == NO){
        self.dataLogView.hidden = YES;
        self.client.bW_Enable = NO;
         [self saveNewValue:@"NO" forIndex:-25];
        
    }
    else{
            self.dataLogView.hidden = NO;
            self.client.bW_Enable = YES;
            [self saveNewValue:@"YES" forIndex:-25];
            }
        
        });
}

- (BOOL)classExistsInNavigationController:(Class)class
{
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:class])
        {
            return YES;
        }
    }
    return NO;
}
- (IBAction)browsingHistoryBtn:(id)sender {
   // UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
   // ViewControllerInfo* infoController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerInfo"];
   // [self.navigationController pushViewController:infoController animated:YES];
    if(self.isPressed == YES){
//        if (![self classExistsInNavigationController:[BrowsingHistoryViewController class]])
//        {
            BrowsingHistoryViewController *viewController = [self.storyboard   instantiateViewControllerWithIdentifier:@"BrowsingHistoryViewController"];
            viewController.client = self.client;
            
            [self.navigationController pushViewController:viewController animated:YES];
       // }
        
        
        
    
    
    
    //[storyboard instantiateViewControllerWithIdentifier:@"BrowsingHistoryViewController"];
    
    self.isPressed = NO;
    
    }
}
-(void)onWiFiClientsListResAndDynamicCallbacks:(id)sender{
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    NSLog(@"dataInfo parental controll %@",dataInfo);
    if(dataInfo == NULL)
        return;
    NSDictionary *mainDict = [dataInfo valueForKey:@"data"];
    if(mainDict == NULL)
        return;
    NSDictionary * dict = mainDict[@"Clients"];
    if(dict == NULL)
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
        self.viewTwoTop.constant = -40;
        self.client.webHistoryEnable = NO;
        
    }
    else{
        self.view2.hidden = NO;
        self.viewTwoTop.constant = 1;
        self.client.webHistoryEnable = YES;
        
    }
    });
}
-(void)switch3ActionDynamic:(BOOL)isOn{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(isOn == NO){
            self.dataLogView.hidden = YES;
            self.client.bW_Enable = NO;
            
        }
        else{
            self.dataLogView.hidden = NO;
            self.client.bW_Enable = YES;
        }
        
    });
}
- (IBAction)iconOutletClicked:(id)sender {
    self.cat_view_more.frame = CGRectMake(0, self.view.frame.size.height - 180, self.view.frame.size.width, 320);
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

@end
