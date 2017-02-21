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
#import "UIFont+Securifi.h"

static const int defHeaderHeight = 25;
static const float defRowHeight = 44;
static const int defHeaderLableHt = 20;

@interface DeviceNotificationViewController ()<GridViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UITableView *notifyMeTable;
@property (nonatomic )NSArray *staticList;

@property (weak, nonatomic) IBOutlet UIButton *doneButtoon;
@property (nonatomic)NSString *location;

@end

@implementation DeviceNotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.staticList = @[@"Attic",@"Basement",@"Bedroom",@"Kitchen",@"Living Room",@"Office",@"Entryway",@"Default Location"];
    _location = @"Office";
    self.notifyMeTable.hidden = YES;
    NSString *schedule = [Client getScheduleById:@(_genericIndexValue.deviceID).stringValue];
    if([self.genericIndexValue.genericIndex.ID isEqualToString:@"-3"]){
    NotificationView *notificationView = [[NotificationView alloc]initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, 250)];
    
    [self.view addSubview:notificationView];
    }
    if([self.genericIndexValue.genericIndex.ID isEqualToString:@"-2"]){
        self.notifyMeTable.hidden = NO;
        GenericIndexValue *gval = self.genericIndexValue;
        [self.doneButtoon setTitle:@"+" forState:UIControlStateNormal];
        [self.doneButtoon addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.notifyMeTable reloadData];
    }
    if([self.genericIndexValue.genericIndex.ID isEqualToString:@"-19"]){
        GridView *gridView = [[GridView alloc]initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height - 70) color:[SFIColors clientGreenColor] genericIndexValue:_genericIndexValue onSchedule:(NSString*)schedule];
        gridView.delegate = self;
        gridView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:gridView];
    }
   
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
    return self.staticList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  45;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 30;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *view;
//    int viewHt;
//            viewHt = defHeaderHeight + defHeaderLableHt;
//        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), viewHt)];
//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, defHeaderHeight-8, CGRectGetWidth(view.frame), defHeaderLableHt)];
//        [UICommonMethods setLableProperties:label text:@"NOTIFY ME" textColor:[UIColor grayColor] fontName:@"Avenir-Roman" fontSize:14 alignment:NSTextAlignmentLeft];
//        [view addSubview:label];
//    return view;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier= @"NotificationCellTableViewCell";
    NotificationCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[NotificationCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [self.staticList objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont securifiFont:14]];
    
    if([_location isEqualToString:[self.staticList objectAtIndex:indexPath.row]]){
        cell.chekButton.hidden = NO;
        [cell.textLabel setTextColor:[SFIColors ruleBlueColor]];
    }
    else{
        cell.chekButton.hidden = YES;
         [cell.textLabel setTextColor:[UIColor blackColor]];
    }
    
    return cell;
}
- (void )tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    NSString *location = [self.staticList objectAtIndex:indexPath.row];
    //send request
    [self.notifyMeTable reloadData];
    
    
}
- (IBAction)doneButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)plusButtonClicked:(id)sender{
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Location" message:@"Please enter Location" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].delegate = self;
    [av show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"1 %@", [alertView textFieldAtIndex:0].text);
    NSString *locationName =  [alertView textFieldAtIndex:0].text;
    self.staticList = [self.staticList arrayByAddingObject:locationName];
    [self.notifyMeTable reloadData];
    
   
}

@end
