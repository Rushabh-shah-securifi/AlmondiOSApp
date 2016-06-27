//
//  BrowsingHistoryViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "BrowsingHistoryViewController.h"
#import "HistoryCell.h"
#import "CommonMethods.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"

@interface BrowsingHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *browsingTable;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic) NSArray *httpArr;
@end

@implementation BrowsingHistoryViewController

- (void)viewDidLoad {
    _httpArr = @[@"https://www.apple.com/favicon.ico",
                 @"https://www.facebook.com/favicon.ico",
                 @"https://www.google.com/favicon.ico",
                 @"https://www.securifi.com/favicon.ico",
                 @"https://en.wikipedia.org/favicon.ico"];
    /*,
     @"https://www.snapdeal.com/favicon.ico",
     @"https://www.lg.com/favicon.ico",
     @"https://www.whatsapp.com/favicon.ico",
     @"https://www.hdfcbank.com/favicon.ico",
     @"https://www.gujarattourism.com/favicon.ico",
     @"https://www.narendramodi.in/favicon.ico",
     @"https://www.bcci.tv/favicon.ico"*/
    self.headerView.backgroundColor = [SFIColors clientGreenColor];
    self.navigationController.navigationBar.clipsToBounds = YES;
    self.navigationController.view.backgroundColor = [SFIColors clientGreenColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [SFIColors clientGreenColor];
    
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(onSearchButton)];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButton)];
    NSArray *leftAction = @[back];
    self.navigationItem.leftBarButtonItems = leftAction;
    NSArray *actionButtonItems = @[search];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor],
       NSFontAttributeName:[UIFont securifiBoldFont:14]}];
    self.title = @"Browsing history";
    [self.browsingTable registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"HistorytableCell"];
    NSLog(@"_httpArr = %@",_httpArr);
    [self.browsingTable reloadData];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.topItem.title = nil;
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark tabledelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _httpArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return [self deviceHeader:section tableView:tableView];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
     HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistorytableCell" forIndexPath:indexPath];
    if (cell == nil){
         cell.httpString = [_httpArr objectAtIndex:indexPath.row];
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HistorytableCell"];
    }
    [cell setCell:[_httpArr objectAtIndex:indexPath.row]];
    return cell;
}
- (BOOL)allowsHeaderViewsToFloat{
    return NO;
}
- (BOOL)allowsFooterViewToFloat{
    return NO;
}
-(UIView*)deviceHeader:(NSInteger)section tableView:(UITableView*)tableView{
    NSString *header = @"Thu 23 June";
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 25)];
    if (section >0) {
        UITableViewHeaderFooterView *foot = (UITableViewHeaderFooterView *)view;
        CGRect sepFrame = CGRectMake(0, 0, tableView.frame.size.width, 1);
        UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame];
        seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:0.5];
        [foot addSubview:seperatorView];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, tableView.frame.size.width, 18)];
    [label setFont:[UIFont securifiBoldFont:12]];
    label.text = header;
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    CGRect sepFrame = CGRectMake(0, 32, tableView.frame.size.width, 1);
    UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame];
    seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:0.5];
    [view addSubview:seperatorView];
    return view;
}
#pragma mark click handler
- (void)onSearchButton{
    
}
- (void)onBackButton{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
