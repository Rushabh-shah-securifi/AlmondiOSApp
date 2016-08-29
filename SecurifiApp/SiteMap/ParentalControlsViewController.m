//
//  ParentalControlsViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 26/08/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ParentalControlsViewController.h"
#import "ParentControlCell.h"
#import "BrowsingHistoryViewController.h"

@interface ParentalControlsViewController ()
@property (nonatomic) NSDictionary *parentsControlDict;
@end

@implementation ParentalControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.parentsControlDict = @{@"0":@{@"img":@"icon1",
                                       @"text":@"Moniter this Device",
                                       @"Button":@"YES"},
                                @"1":@{@"img":@"icon2",
                                       @"text":@"Log Browsing History",
                                       @"Button":@"YES"},
                                @"2":@{@"img":@"icon3",
                                       @"text":@"View Browsing History",
                                       @"Button":@"YES"}
                                };
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParentControlCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"ParentControlCell" forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [[ParentControlCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ParentControlCell"];
    }
    NSDictionary *dict = [self.parentsControlDict valueForKey:@(indexPath.row).stringValue];
    [cell setUpCell:dict[@"text"] andImage:[UIImage imageNamed:dict[@"img"]] isHideSwich:indexPath.row == 2?YES:NO];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 2){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
        BrowsingHistoryViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"BrowsingHistoryViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    }

}
@end
