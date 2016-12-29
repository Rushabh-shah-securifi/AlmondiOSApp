//
//  IoTLearnMoreViewController.m
//  SecurifiApp
//
//  Created by Masood on 12/28/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "IoTLearnMoreViewController.h"
#import "IoTLearnMoreTableViewCell.h"
#import "IoTWebViewController.h"

#define IOT_LEARN_MORE @"iotlearnmore"
#define IOT_LEARN_TOPIC @"iotlearntopic"

@interface IoTLearnMoreViewController ()
@property (nonatomic) NSArray *helpsArray;
@end

@implementation IoTLearnMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.issueTypes = @[@"1", @"2", @"3"]; //test
    [self makeHelpDictionary];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark helper methods
- (void)makeHelpDictionary{
    self.helpsArray = @[NSLocalizedString(@"what_is_port", @""),
                        NSLocalizedString(@"what_is_telnet", @""),
                        NSLocalizedString(@"what_is_port_forwarding", @""),
                        NSLocalizedString(@"what_is_upnp", @""),
                        NSLocalizedString(@"what_is_botnet", @""),
                        NSLocalizedString(@"what_is_local_ws", @""),
                        NSLocalizedString(@"what_is_dns", @""),
                        NSLocalizedString(@"what_is_an_open_port", @""),
                        NSLocalizedString(@"what_to_do", @""),
                        NSLocalizedString(@"best_practices", @"")];
}

#pragma mark tableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0? self.issueTypes.count: self.helpsArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0? 250.0: 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0? UITableViewAutomaticDimension: 50;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 5)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    if(indexPath.section == 0)
        identifier = IOT_LEARN_MORE;
    else
        identifier = IOT_LEARN_TOPIC;
    
    IoTLearnMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[IoTLearnMoreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if(indexPath.section == 0){
        NSLog(@"self.issueTypes[indexPath.row] %@",self.issueTypes[indexPath.row]);
        [cell setIssueCell:self.issueTypes[indexPath.row]];
    }
    else
        [cell setHelpCell:self.helpsArray[indexPath.row]];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainDashboard" bundle:nil];
        IoTWebViewController *ctrl = [storyBoard instantiateViewControllerWithIdentifier:@"IoTWebViewController"];
        ctrl.row = indexPath.row;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:ctrl animated:YES];
        });
    }
}

#pragma mark button tap
- (IBAction)onBackBtnTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
