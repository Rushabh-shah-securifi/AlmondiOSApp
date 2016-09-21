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

@interface ParentalControlsViewController ()<ParentControlCellDelegate>
@property (nonatomic) NSMutableArray *parentsControlArr;

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




@end

@implementation ParentalControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.parentsControlArr = [[NSMutableArray alloc]init];
//    [self createArr];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
     [self initializeNotifications];
     self.switchView1.transform = CGAffineTransformMakeScale(0.70, 0.70);
     self.switchView3.transform = CGAffineTransformMakeScale(0.70, 0.70);
    int deviceID = _genericParams.headerGenericIndexValue.deviceID;
    self.client = [Client findClientByID:@(deviceID).stringValue];
    self.icon.image = [UIImage imageNamed:self.genericParams.headerGenericIndexValue.genericValue.icon];
    self.clientName.text = self.client.name;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[self.client.deviceLastActiveTime integerValue]];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];//Accessed on matt's iPhone on Wed 29 June 11:00.
    [dateformate setDateFormat:@"EEEE dd MMMM HH:mm"]; // Date formater
    NSString *str = [dateformate stringFromDate:date];
    self.lastSeen.text = [NSString stringWithFormat:@"last activated time %@",str];
    
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
    
    [self.navigationController setNavigationBarHidden:YES];
}
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
    NSLog(@"client BW_enable %d and webEnable %d",client.bW_Enable,client.webHistoryEnable);
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
}
- (IBAction)switch3Action:(id)sender {
    UISwitch *actionSwitch = (UISwitch *)sender;
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
}
- (IBAction)browsingHistoryBtn:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
    BrowsingHistoryViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"BrowsingHistoryViewController"];
    viewController.client = self.client;
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
