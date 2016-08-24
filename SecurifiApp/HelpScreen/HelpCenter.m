//
//  HelpCenter.m
//  SecurifiApp
//
//  Created by Masood on 7/15/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "HelpCenter.h"
#import "CommonMethods.h"
#import "HelpCenterTableViewCell.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "HelpItemsTableViewController.h"
#import "SupportViewController.h"

@interface HelpCenter ()
@property NSArray *helpItems;
//@property (weak, nonatomic) IBOutlet UITableView *helpTableView;
@end

@implementation HelpCenter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initializeData{
    self.helpItems = [[CommonMethods parseJson:@"helpCenterJson"] valueForKey:@"HelpItems"];
    NSLog(@"help items array: %@", self.helpItems);
}


#pragma mark table and search delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"help rows");
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"section count: %d", self.helpItems.count);
    return self.helpItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HelpCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"helpcentercell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[HelpCenterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"helpcentercell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSLog(@"help dict: %@", [self.helpItems objectAtIndex:indexPath.section]);
    [cell setUpHelpCell:[self.helpItems objectAtIndex:indexPath.section]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"section: %d", indexPath.section);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(indexPath.section == 0 || indexPath.section ==1){//guide, helptopics
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HelpScreenStoryboard" bundle:nil];
            HelpItemsTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HelpItemsTableViewController"];
            viewController.helpItem = [self.helpItems objectAtIndex:indexPath.section];

//            [self presentViewController:navController animated:YES completion:nil];
            [self.navigationController pushViewController:viewController animated:YES];
            
        }
        else if(indexPath.section == 2){ //support
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HelpScreenStoryboard" bundle:nil];
            SupportViewController *supportContorller = [storyboard instantiateViewControllerWithIdentifier:@"SupportViewController"];
            [self.navigationController pushViewController:supportContorller animated:YES];
        }
    });
}


#pragma button taps
- (IBAction)onBackBtnTap:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSearchBtnTap:(id)sender {
    
}

- (IBAction)onProductsButtonTap:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://www.securifi.com/rg/products"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)onWifiButtonTap:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://www.securifi.com/rg/wifi"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)onSmartHomeButtonTap:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://www.securifi.com/rg/smart-home"];
    [[UIApplication sharedApplication] openURL:url];
}

@end
