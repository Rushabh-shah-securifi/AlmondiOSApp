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
#import "Analytics.h"
#import "HelpSearchTableViewController.h"

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
    [[Analytics sharedInstance] markHelpCenterScreen];
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
    NSLog(@"section count: %lu", (unsigned long)self.helpItems.count);
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
    NSLog(@"section: %ld", (long)indexPath.section);
    NSInteger section = indexPath.section;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(section == 0 || section ==1){//guide, helptopics
            HelpItemsTableViewController *viewController = [self getStoryBoardController:@"HelpScreenStoryboard" ctrlID:@"HelpItemsTableViewController"];
            viewController.helpItem = [self.helpItems objectAtIndex:indexPath.section]; //based on json
            viewController.isHelpTopic = section == 0? NO: YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:viewController animated:YES];
            });
        }
        else if(section == 2){ //support
            SupportViewController *supportContorller = [self getStoryBoardController:@"HelpScreenStoryboard" ctrlID:@"SupportViewController"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:supportContorller animated:YES];
            });
        }
    });
}

- (id)getStoryBoardController:(NSString *)StoryBoardName ctrlID:(NSString*)ctrlID{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:StoryBoardName bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:ctrlID];
}

#pragma button taps
- (IBAction)onBackBtnTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (IBAction)onSearchBtnTap:(id)sender {
    NSLog(@"onSearchBtnTap");
    HelpSearchTableViewController *viewController = [self getStoryBoardController:@"HelpScreenStoryboard" ctrlID:@"HelpSearchTableViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)onProductsButtonTap:(id)sender {
    [self openUrl:@"https://www.securifi.com/rg/products"];
    [[Analytics sharedInstance] markTapproducts];
}

- (IBAction)onWifiButtonTap:(id)sender {
    [self openUrl:@"https://www.securifi.com/rg/wifi"];
    [[Analytics sharedInstance] markTapWiFi];
}

- (IBAction)onSmartHomeButtonTap:(id)sender {
    [self openUrl:@"https://www.securifi.com/rg/smart-home"];
    [[Analytics sharedInstance] markTapSmartHome];
}

-(void)openUrl:(NSString *)urlStr{
    NSURL *url = [NSURL URLWithString:urlStr];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:url];
    });
}
@end
