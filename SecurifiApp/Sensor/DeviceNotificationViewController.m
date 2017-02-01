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

static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;

@interface DeviceNotificationViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UITableView *notifyMeTable;

@end

@implementation DeviceNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
@end
