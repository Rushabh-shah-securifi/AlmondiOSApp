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

@interface HelpCenter ()
@property NSArray *helpItems;
@property (weak, nonatomic) IBOutlet UITableView *helpTableView;
@end

@implementation HelpCenter

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Help Center";
    [self initializeData];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"HelpScreenStoryboard" bundle:nil];
        HelpItemsTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"HelpItemsTableViewController"];
        viewController.helpItem = [self.helpItems objectAtIndex:indexPath.section];
        
//        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
//                                       initWithTitle:@"Back"
//                                       style:UIBarButtonItemStylePlain
//                                       target:nil
//                                       action:nil];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
        [self.navigationController pushViewController:viewController animated:YES];
    });
}

- (void)setCustomNavigationBackButton
{
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [CommonMethods imageNamed:@"back_icon" withColor:[UIColor grayColor]];
    [backBtn setBackgroundImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goback) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 54, 30);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn] ;
    self.navigationItem.leftBarButtonItem = backButton;
    
    /*
    UIImage *backBtn = [UIImage imageNamed:@"back_icon"];
    backBtn = [backBtn imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.navigationItem.backBarButtonItem.title=@"";
    self.navigationController.navigationBar.backIndicatorImage = backBtn;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backBtn;
     */
}

@end
