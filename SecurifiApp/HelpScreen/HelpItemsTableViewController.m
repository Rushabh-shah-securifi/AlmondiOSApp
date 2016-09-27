//
//  HelpItemsTableViewController.m
//  SecurifiApp
//
//  Created by Masood on 7/20/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HelpItemsTableViewController.h"
#import "HelpCenterTableViewCell.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "HelpViewController.h"
#import "Analytics.h"

@interface HelpItemsTableViewController ()
@property(nonatomic) NSArray *items;
@end

@implementation HelpItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"title name: %@", self.helpItem[@"name"]);
    self.navigationItem.title = NSLocalizedString(self.helpItem[@"name"], @"");
    self.items = self.helpItem[ITEMS];
}

- (void)viewWillAppear:(BOOL)animated{
    if(self.isHelpTopic){
        [[Analytics sharedInstance] markHelpTopicsScreen];
    }else{
        [[Analytics sharedInstance] markQuickTipsScreen];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *items = self.helpItem[ITEMS];
    return items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HelpCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"helpcentercell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[HelpCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"helpcentercell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSLog(@"help item : %@", self.helpItem);
    [cell setUpHelpItemCell:self.helpItem row:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"HelpScreenStoryboard" bundle:nil];
    HelpViewController *ctrl = [storyBoard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    if(self.isHelpTopic){
        ctrl.helpTopic = [self getHelpTopic:indexPath.row]; //this is based on json
        ctrl.isHelpTopic = YES;
    }else{
        ctrl.startScreen = [self.items objectAtIndex:indexPath.row];
        ctrl.isHelpTopic = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:ctrl animated:YES completion:nil];
    });
    
    
}

-(HelpTopic)getHelpTopic:(NSInteger)row{
    if(row == 0)
        return HelpTopic_Dashboard;
    else if(row == 1)
        return HelpTopic_Scene;
    else
        return HelpTopic_Securiti;
}

@end
