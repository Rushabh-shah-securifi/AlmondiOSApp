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

@interface MeshSetupViewController ()<MeshViewDelegate, MBProgressHUDDelegate>
@property (nonatomic) MeshView *meshView;
@property (nonatomic) MBProgressHUD *HUD;

@property (weak, nonatomic) IBOutlet UIImageView *meshWeakImg;
@property (weak, nonatomic) IBOutlet UIImageView *meshOnlineImg;

@property (weak, nonatomic) IBOutlet UILabel *almondName;
@property (weak, nonatomic) IBOutlet UILabel *statusTxt;
@property (weak, nonatomic) IBOutlet UIButton *removeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomContraint;

@end

@implementation MeshSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"Meshset up controller");
    if(self.isStatusView){
        [self setUpAlmondStatus];
    }else{
        [self setupMeshView];
    }

    [self setUpHUD];
}

-(void)setUpAlmondStatus{
    [self setupNavBar];
    self.almondName.text = self.almondStatObj.name;
    if(self.almondStatObj.isMaster){//check if master or slave
        //more to be done depending upon connection status images need to be updated
        //will put set of images in a view and hide/unhide the view.
        self.removeBtn.hidden = YES;
        self.tableBottomContraint.constant = 0; //to hide remove button.
        [self toggleImages:NO weakImg:YES text:self.almondStatObj.internetStat? @"Online":@"Offline"];
    }else{
        [self toggleImages:YES weakImg:NO text:@"Text should be shown based on signal strength"];
    }
}

-(void)toggleImages:(BOOL)onlineHidden weakImg:(BOOL)weakHidden text:(NSString*)text{
    self.meshOnlineImg.hidden = onlineHidden;
    self.meshWeakImg.hidden = weakHidden;
    self.statusTxt.text = text;
}

-(void)setupNavBar{
    self.title = @"Almond Status";
//    self.navigationController.title = @"Almond Status";
    self.navigationController.navigationBar.backIndicatorImage = nil;
}

-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark meshsetup

- (void)setupMeshView{
    self.meshView = [[MeshView alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.navigationController.view.frame.size.height-20)];
    NSLog(@"nav viewheight: %f", CGRectGetHeight(self.navigationController.view.frame));
    self.meshView.delegate = self;
    
    
    [self.meshView addInterfaceView:CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height-20)];
    [self.navigationController.view addSubview:self.meshView];
    self.meshView.backgroundColor = [UIColor grayColor];
    //    [self.tabBarController.tabBar setHidden:YES];
}

#pragma mark mesh status
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
//    return self.isMaster? 3: 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0? (self.almondStatObj.isMaster? 5: 6): (section == 1? 4: 2);
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
    [CommonMethods setLableProperties:label text:headerTitle textColor:[SFIColors ruleGraycolor] fontName:@"Avenir-Roman" fontSize:16 alignment:NSTextAlignmentLeft];
    [view addSubview:label];
    
    [CommonMethods addLineSeperator:view yPos:32];
    return view;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"self.almond mac: %@", self.almondMac);
    NSString *CELL_IDENTIFIER = @"statuscell";
    
    MeshStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    //    cell.delegate = self;
    UITableViewCellAccessoryType accType = UITableViewCellAccessoryNone;
    
    NSDictionary *keyVal = self.almondStatObj.keyVals[indexPath.row];
    [cell setupCell:[keyVal allKeys].firstObject value:[keyVal allValues].firstObject accType:accType];
    
    return cell;
}

#pragma mark meshview delegates
-(void)dismissControllerDelegate{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showHudWithTimeoutMsgDelegate:(NSString*)hudMsg time:(NSTimeInterval)sec{
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:5];
    });
}

- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}

- (void)hideHUDDelegate{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.HUD hide:YES];
    });
}

#pragma mark button tap
- (IBAction)onRemoveThisAlmondTap:(id)sender {
    
}

@end
