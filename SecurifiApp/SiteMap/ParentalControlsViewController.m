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

@interface ParentalControlsViewController ()<ParentControlCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *parentsControlArr;

@property (weak, nonatomic) IBOutlet UIView *dataLogView;

@end

@implementation ParentalControlsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.parentsControlArr = [[NSMutableArray alloc]init];
    [self createArr];
    
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
    return self.parentsControlArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParentControlCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"ParentControlCell" forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [[ParentControlCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ParentControlCell"];
    }
    cell.delegate = self;
    NSDictionary *dict = [self.parentsControlArr objectAtIndex:indexPath.row];
    NSLog(@"dict button = %@",dict[@"Switch"]);
    [cell setUpCell:dict[@"text"] andImage:[UIImage imageNamed:dict[@"img"]] isHideSwich:[dict[@"Switch"] boolValue] indexPath:[dict[@"Tag"] integerValue]];//"Button"
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 1 && self.parentsControlArr.count == 3){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
        BrowsingHistoryViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"BrowsingHistoryViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
    }

}
- (IBAction)backButton:(id)sender {

        [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)switchPressed:(BOOL)isOn andTag:(NSInteger)tag{
    if(tag == 0){
        if(isOn == NO){
           [self.parentsControlArr removeObjectAtIndex:1];
            [self.tableView reloadData];
        }
        else{
            [self createArr];
        }
    }
    if(tag == 2){
        if(isOn == NO){
            self.dataLogView.hidden = YES;
        }
        else{
            self.dataLogView.hidden = NO;
        }
 
    }
}
-(void)createArr{
    NSArray *Arr = @[@{@"img":@"parental_controls_icon",
                       @"text":@"Log Date Usage",
                       @"Switch":@"YES",
                       @"Tag":@"0"},
                     @{@"img":@"view_browsing_history_icon",
                       @"text":@"View Browsing History",
                       @"Switch":@"NO",
                       @"Tag":@"1"},
                     @{@"img":@"log_browsing_history_icon",
                       @"text":@"Log Browsing History",
                       @"Switch":@"YES",
                       @"Tag":@"2"}
                     ];
    [self.parentsControlArr removeAllObjects];
    self.parentsControlArr = [NSMutableArray arrayWithArray:Arr];
    [self.tableView reloadData];
    
}
@end
