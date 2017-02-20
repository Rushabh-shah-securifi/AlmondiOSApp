//
//  DeviceNotificationViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 01/02/17.
//  Copyright © 2017 Securifi Ltd. All rights reserved.
//

#import "DeviceNotificationViewController.h"
#import "UICommonMethods.h"
#import "NotificationCellTableViewCell.h"
#import "GridView.h"
#import "SFIColors.h"
#import "NotificationView.h"

static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;

@interface DeviceNotificationViewController ()<GridViewDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UITableView *notifyMeTable;

@end

@implementation DeviceNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.notifyMeTable.hidden = YES;
    NSString *schedule = [Client getScheduleById:@(_genericIndexValue.deviceID).stringValue];
    NotificationView *notificationView = [[NotificationView alloc]initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, 250)];
    
    [self.view addSubview:notificationView];
    
//    GridView *gridView = [[GridView alloc]initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height - 70) color:[SFIColors clientGreenColor] genericIndexValue:_genericIndexValue onSchedule:(NSString*)schedule];
//    gridView.delegate = self;
//    gridView.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:gridView];
//    
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    int viewHt;
            viewHt = defHeaderHeight + defHeaderLableHt;
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), viewHt)];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, defHeaderHeight-8, CGRectGetWidth(view.frame), defHeaderLableHt)];
        [UICommonMethods setLableProperties:label text:@"NOTIFY ME" textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:14 alignment:NSTextAlignmentLeft];
        [view addSubview:label];
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= @"NotificationCellTableViewCell";
    NotificationCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[NotificationCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
