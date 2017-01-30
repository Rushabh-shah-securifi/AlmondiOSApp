//
//  DevicePropertiesViewController.m
//  SecurifiApp
//
//  Created by Masood on 1/30/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "DevicePropertiesViewController.h"
#import "DeviceHeaderView.h"
#import "CommonMethods.h"
#import "UICommonMethods.h"
#import "DevicePropertyTableViewCell.h"
#import "UICommonMethods.h"

#define DEVICE_PROPERTY_CELL @"devicepropertycell"

static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;

@interface DevicePropertiesViewController () <DeviceHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLbl;

@property (weak, nonatomic) IBOutlet UIView *headerBgView;
@property (weak, nonatomic) IBOutlet DeviceHeaderView *deviceHeaderView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DevicePropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpDevicePropertyEditHeaderView];
}


-(void)setUpDevicePropertyEditHeaderView{
    if(self.genericParams.isSensor){
        [self.deviceHeaderView initialize:self.genericParams cellType:SensorEdit_Cell isSiteMap:NO];
    }
    else{
        [self.deviceHeaderView initialize:self.genericParams cellType:ClientEditProperties_cell isSiteMap:NO];
    }
    self.deviceHeaderView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;
    else if (section == 1)
        return 1;
    else
        return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return defRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 2)
        return defHeaderHeight + defHeaderLableHt;
    
    return defHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    int viewHt;
    if(section == 2){
        viewHt = defHeaderHeight + defHeaderLableHt;
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), viewHt)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, defHeaderHeight-8, CGRectGetWidth(view.frame), defHeaderLableHt)];
        [UICommonMethods setLableProperties:label text:@"TEMPERATURE" textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:14 alignment:NSTextAlignmentLeft];
        [view addSubview:label];
    }
    
    else{
        viewHt = defHeaderLableHt;
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), defHeaderHeight)];
    }
    
    
    view.backgroundColor = [UIColor whiteColor];
    [UICommonMethods addLineSeperator:view yPos:viewHt-1];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 1)];
    [UICommonMethods addLineSeperator:view yPos:0];
    return view;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= DEVICE_PROPERTY_CELL;
    
    DevicePropertyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DevicePropertyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell setUpCell:nil indexPath:indexPath];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark action
- (IBAction)onDoneBtnTap:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
