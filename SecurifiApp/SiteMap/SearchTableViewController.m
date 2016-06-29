//
//  SearchTableViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 27/06/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SearchTableViewController.h"
#import "HistoryCell.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "URIData.h"
#import "BrowsingHistory.h"
#import "NSDate+Convenience.h"
#import "SearchTableViewController.h"

@interface SearchTableViewController ()<UISearchResultsUpdating, UISearchBarDelegate>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic) NSArray *searchResultsArray;
@property (nonatomic) UITableView *searchTableView;
@property (nonatomic) NSMutableArray *localSearchDayWiseHist;
@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.clipsToBounds = YES;
    self.navigationController.view.backgroundColor = [SFIColors clientGreenColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [SFIColors clientGreenColor];
    
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancleButton)];
    
    NSArray *actionButtonItems = @[search];
    self.navigationItem.rightBarButtonItems = actionButtonItems;

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"abc"];
    [self initializeSearchController ];
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)search{
    return YES;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.browsingHistoryDayWise.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tableView){
        BrowsingHistory *browsHist = self.browsingHistoryDayWise[section];
        return browsHist.URIs.count;
    }
    else{
        BrowsingHistory *browsHist = self.localSearchDayWiseHist[section];
        return browsHist.URIs.count;

    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.000001;
   
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return [self deviceHeader:section tableView:tableView];
}
-(UIView*)deviceHeader:(NSInteger)section tableView:(UITableView*)tableView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
//    if (section > 0) {
//        UITableViewHeaderFooterView *foot = (UITableViewHeaderFooterView *)view;
//        CGRect sepFrame = CGRectMake(0, 0, tableView.frame.size.width, 1);
//        UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame];
//        seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:0.5];
//        [foot addSubview:seperatorView];
//    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, tableView.frame.size.width, 18)];
    [label setFont:[UIFont securifiBoldFont:13]];
    NSString *headerDate = [self getHeaderDate:section];
    label.text = section == 0? [NSString stringWithFormat:@"Today, %@",headerDate]: headerDate;
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    
//    CGRect sepFrame = CGRectMake(0, 32, tableView.frame.size.width, 1);
//    UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame];
//    seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:0.5];
//    [view addSubview:seperatorView];
    return view;
}
- (NSString*)getHeaderDate:(NSInteger)section{
    BrowsingHistory *browsHistory = self.browsingHistoryDayWise[section];
    return [browsHistory.date getDayMonthFormat];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCell *cell;
    if(tableView == self.tableView)
        cell = [tableView dequeueReusableCellWithIdentifier:@"abc" forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"abc" forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abc"];
    }
    if(tableView == self.tableView){
        BrowsingHistory *browsHist = [self.browsingHistoryDayWise objectAtIndex:indexPath.section];
        NSArray *URIs = browsHist.URIs;
        [cell setCell:[URIs objectAtIndex:indexPath.row]];
    }
    else {
       NSLog(@"searchArr inside table cell %@",self.searchResultsArray);
//        cell.siteName.text = [self.searchResultsArray objectAtIndex:indexPath.row];
        BrowsingHistory *browsHist = [self.localSearchDayWiseHist objectAtIndex:indexPath.section];
        NSArray *URIs = browsHist.URIs;
        [cell setCell:URIs[indexPath.row]];

    }
    
    return cell;
}

- (void)initializeSearchController {
    
    //instantiate a search results controller for presenting the search/filter results (will be presented on top of the parent table view)
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    searchResultsController.tableView.dataSource = self;
    
    searchResultsController.tableView.delegate = self;
    
    //instantiate a UISearchController - passing in the search results controller table
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    
    //this view controller can be covered by theUISearchController's view (i.e. search/filter table)
    self.definesPresentationContext = YES;
    
    
    //define the frame for the UISearchController's search bar and tint
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    
    //add the UISearchController's search bar to the header of this table
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    
    //this ViewController will be responsible for implementing UISearchResultsDialog protocol method(s) - so handling what happens when user types into the search bar
    self.searchController.searchResultsUpdater = self;
    
    
    //this ViewController will be responsisble for implementing UISearchBarDelegate protocol methods(s)
    self.searchController.searchBar.delegate = self;
    self.searchTableView = ((UITableViewController *)self.searchController.searchResultsController).tableView;
    [self.searchTableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"abc"];
    
}
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = self.searchController.searchBar.text;
    NSPredicate *resultPredicate;
    NSLog(@"searching string = %@",searchString);
    self.localSearchDayWiseHist = [NSMutableArray new];
    
    for(BrowsingHistory *browsHistory in self.browsingHistoryDayWise){
        BrowsingHistory *newBrowsHistory = [BrowsingHistory new];
        
        NSArray *URIs = browsHistory.URIs;
         resultPredicate = [NSPredicate predicateWithFormat:@"hostName CONTAINS[c] %@",searchString];
        NSArray *arr = [URIs filteredArrayUsingPredicate:resultPredicate];
        
        newBrowsHistory.URIs = arr;
        [self.localSearchDayWiseHist addObject:newBrowsHistory];
    }
//    NSArray *URIs = browsHist.URIs;
//    NSInteger scope = self.searchController.searchBar.selectedScopeButtonIndex;
//    resultPredicate = [NSPredicate predicateWithFormat:@"lastName CONTAINS[c]",searchString];
//    
//    self.searchResultsArray = [self.httpArr filteredArrayUsingPredicate:resultPredicate];
    
    [self.searchTableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchController];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}
-(void)onCancleButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
