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
#import "HelpScreens.h"
#import "CommonMethods.h"

@interface HelpItemsTableViewController ()<HelpScreensDelegate>
@property(nonatomic) HelpScreens *helpScreens;
@property(nonatomic) NSArray *items;
@end

@implementation HelpItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"title name: %@", self.helpItem[@"name"]);
    self.navigationItem.title = self.helpItem[@"name"];
    [self initializeHelpScreens];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark help screens
-(void)initializeHelpScreens{
    self.items = self.helpItem[ITEMS];
    
    self.helpScreens = [[HelpScreens alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height)];
    self.helpScreens.delegate = self;
    [self.helpScreens expandView];
    
    self.helpScreens.backgroundColor = [UIColor grayColor];
    [self.helpScreens addHelpItem:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-20)];
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
    [self.tabBarController.tabBar setHidden:YES];
    self.helpScreens.startScreen = [self.items objectAtIndex:indexPath.row];
    [self.helpScreens initailizeFirstScreen];
    [self.navigationController.view addSubview:self.helpScreens];
}

#pragma mark helpscreen delegate methods
- (void)resetViewDelegate{
    [self.helpScreens removeFromSuperview];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)onSkipTapDelegate{
    
}

@end
