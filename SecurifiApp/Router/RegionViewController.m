//
//  RegionViewController.m
//  SecurifiApp
//
//  Created by Masood on 3/6/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "RegionViewController.h"
#import "RegionTableViewCell.h"

@interface RegionViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTxtFld;
@property (weak, nonatomic) IBOutlet UILabel *locationLbl;

@property (weak, nonatomic) IBOutlet UIImageView *upArrow;
@property (weak, nonatomic) IBOutlet UIImageView *downArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherTopConstraint;


@property (weak, nonatomic) IBOutlet UIImageView *upperTick;
@property (weak, nonatomic) IBOutlet UIImageView *lowerTick;

@property (weak, nonatomic) IBOutlet UIView *otherView;
@property (weak, nonatomic) IBOutlet UIView *americaView;
@property (weak, nonatomic) IBOutlet UIView *expandView;


@end

@implementation RegionViewController
int mii;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialSetUp];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    mii = arc4random() % 10000;
    
//    [self initializeNotification];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialSetUp{
    self.locationLbl.text = @"to be set";
    self.upperTick.hidden = NO;
    self.lowerTick.hidden = YES;
    self.expandView.hidden = YES;
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
//    return self.timeZoneList.count/2;
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
    NSString *identifier= @"region";
    
    RegionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[RegionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
//    NSString *country = self.timeZoneList[indexPath.row*2];
//    NSString *time = self.timeZoneList[indexPath.row*2+1];
    [cell setupCell];
    //    cell.delegate = self;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*v{"MobileInternalIndex":6747656,"AlmondMAC":"251176220100060","CommandType":"ChangeAlmondProperties","TimeZone":"WAT-1"}*/
//    [self showHudWithTimeoutMsg:@"Please Wait!" time:10];
//    NSString *value = self.timeZoneList[indexPath.row*2+1];
//    [RouterPayload requestAlmondPropertyChange:mii action:@"TimeZone" value:value uptime:nil];
}

#pragma mark action methods
- (IBAction)onSelectLocationTap:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if(btn.selected){
        self.upArrow.hidden = NO;
        self.downArrow.hidden = YES;
        self.expandView.hidden = NO;
        
        self.topConstraint.constant = 108;
        self.otherTopConstraint.constant = 100;
    }else{
        self.upArrow.hidden = YES;
        self.downArrow.hidden = NO;
        
        self.expandView.hidden = YES;
        self.topConstraint.constant = 1;
        self.otherTopConstraint.constant = 2;
    }
}

- (IBAction)onBckBtnTap:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAmericaTap:(id)sender {
    self.americaView.hidden = NO;
    self.otherView.hidden = YES;
    
    self.upperTick.hidden = NO;
    self.lowerTick.hidden = YES;
}

- (IBAction)onOtherTap:(id)sender {
    self.americaView.hidden = YES;
    self.otherView.hidden = NO;
    
    self.upperTick.hidden = YES;
    self.lowerTick.hidden = NO;
}

- (IBAction)onOtherTickTap:(id)sender {
    
}

@end
