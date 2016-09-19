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
#import "CommonMethods.h"
#import "SearchTableViewController.h"
#import "BrowsingHistoryDataBase.h"
#import "UIFont+Securifi.h"



typedef NS_ENUM(NSInteger, SearchPatten) {
    DefaultSearch,
    RecentSearch,
    TodaySearch,
    LastHourSearch,
    WeekDaySearch,
    DateSearch,
    WeekSearch,
    CategorySearch
};

@interface SearchTableViewController ()<UISearchResultsUpdating, UISearchBarDelegate,UITextFieldDelegate,BrowsingHistoryDelegate>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic) UITableView *searchTableView;
@property (nonatomic) NSArray *suggSearchArr;
@property (nonatomic) BrowsingHistory *browsingHistory;

@property (nonatomic) NSMutableArray *recentSearch;
@property (nonatomic) NSMutableArray *recentSearchObj;
@property (nonatomic) NSArray *categorySearch;

@property (nonatomic) SearchPatten searchPatten;
@property (nonatomic) NSMutableArray *dayArr;
@property (nonatomic) dispatch_queue_t imageDownloadQueue;
@property BOOL isManuelSearch ;
@property (nonatomic) NSDictionary *historyDict;
@property (nonatomic)  UILabel *NoresultFound;
@property (nonatomic) NSString *cmac;
@property (nonatomic) NSString *amac;
@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cmac = [CommonMethods hexToString:self.client.deviceMAC];
    self.amac = @"251176220100366";
    self.dayArr = [[NSMutableArray alloc]init];
        self.browsingHistory =[[BrowsingHistory alloc]init];
        self.browsingHistory.delegate = self;
    self.imageDownloadQueue = dispatch_queue_create("img_download", DISPATCH_QUEUE_SERIAL);
    self.navigationController.navigationBar.clipsToBounds = YES;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [SFIColors ruleBlueColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancleButton)];
    
    NSArray *actionButtonItems = @[search];
    self.navigationItem.rightBarButtonItems = actionButtonItems;

    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"abc"];
    self.recentSearch = [[NSMutableArray alloc]init];
    [self addSuggestionSearchObj];
    [self initializeSearchController ];
    
    self.isManuelSearch = YES;
    }
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear searchPage");
    self.isManuelSearch = YES;
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
     NSLog(@"self.dayArr.count %ld and searchtabel frame %@",self.dayArr.count,NSStringFromCGRect(self.searchTableView.frame));
    
    if(tableView == self.tableView){
       
        self.NoresultFound.hidden = YES;
        return 3;
    }
    else
        if(self.dayArr.count == 0)
            self.NoresultFound.hidden = NO;
        return self.dayArr.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tableView){
        if(section == 0)
            return self.suggSearchArr.count;
        else if(section == 1)
            return self.categorySearch.count;
        else
            return  self.recentSearchObj.count;
    }
    else{
        
            NSArray *browsHist = self.dayArr[section];
            return browsHist.count;
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
    NSString *headerDate;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, tableView.frame.size.width, 18)];
    [label setFont:[UIFont securifiBoldFont:13]];
    
    if(tableView == self.tableView){
        if(section == 0)
            headerDate =  @"Suggested Searches";
        else if(section == 1)
            headerDate =  @"Categories";
        else
            headerDate =  @"Recent Searches";
       
        
        label.text = headerDate;
    }
    else{
        NSLog(@"[self.historyDict allKeys] %@",[self.historyDict[@"Data"] allKeys]);
        NSString *str;
        if([self.historyDict[@"Data"] allKeys].count >0 )
        str = [[self.historyDict[@"Data"] allKeys] objectAtIndex:section];
        NSLog(@"str date string %@",str);
        NSDate *date = [NSDate convertStirngToDate:str];
        NSString *headerDate = [date getDayMonthFormat];
//        headerDate = @"today";
        label.text = section == 0? [NSString stringWithFormat:@"Today, %@",headerDate]: headerDate;
    }
    
    label.textColor = [UIColor grayColor];
    [view addSubview:label];

    return view;
}

//- (NSString*)getHeaderDate:(NSInteger)section{
//    BrowsingHistory *browsHistory = self.browsingHistoryDayWise[section];
//    return [browsHistory.date getDayMonthFormat];
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"abc" forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abc"];
    }
    
    if(tableView == self.tableView){

        if(indexPath.section == 0)
            [cell setCell:[self.suggSearchArr objectAtIndex:indexPath.row]hideItem:YES];
        else if(indexPath.section == 1)
            [cell setCell:[self.categorySearch objectAtIndex:indexPath.row]hideItem:YES];
        else
            [cell setCell:[self.recentSearchObj objectAtIndex:indexPath.row]hideItem:YES];
    }
    else {
        NSLog(@"self.dayArr count = %ld",self.dayArr.count);
//        if(self.dayArr.count == 0)
//        {
//            [cell.contentView addSubview:[self emptyCellLabel]];
//            return cell;
//        }
        if(self.dayArr.count > indexPath.section){
            self.NoresultFound.hidden = YES;
        NSArray *browsHist = self.dayArr[indexPath.section];
            NSLog(@"browsing hist %@, count %ld,row = %ld",browsHist,browsHist.count,indexPath.row);
            if(browsHist.count>indexPath.row)
        [cell setCell:browsHist[indexPath.row] hideItem:NO];
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == self.tableView){
        if(indexPath.section == 2){
             [self setSearchpattenMethod:RecentSearch indexPath:indexPath];
        }
        else if(indexPath.section == 0 && indexPath.row == 0){
             [self setSearchpattenMethod:LastHourSearch];
        }
        else if(indexPath.section == 0 && indexPath.row == 1){
             [self setSearchpattenMethod:TodaySearch];
        }
        else if(indexPath.section == 0 && indexPath.row == 2){
            [self setSearchpattenMethod:WeekSearch];
        }
        else if (indexPath.section == 1 && indexPath.row == 0){
            [self categorySearch:@"NC-17"];
        }
        else if (indexPath.section == 1 && indexPath.row == 1){
            [self categorySearch:@"R"];
        }
        else if (indexPath.section == 1 && indexPath.row == 2){
            [self categorySearch:@"PG-13"];
        }
        else if (indexPath.section == 1 && indexPath.row == 3){
            [self categorySearch:@"PG"];
        }
        else if (indexPath.section == 1 && indexPath.row == 4){
            [self categorySearch:@"G"];
        }
    }
}
//
-(UILabel*)emptyCellLabel{
    UILabel *noResultCell = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.searchTableView.frame.size.width, 40)];
    noResultCell.text = @"No result found";
    noResultCell.textAlignment = NSTextAlignmentCenter;
    return noResultCell;

}
#pragma mark searchDelegate methods
-(void)setSearchpattenMethod:(SearchPatten)searchpatten{
    self.searchPatten = searchpatten;
    self.searchController.searchBar.text = @" ";
    self.isManuelSearch = NO;
    [self.searchController.searchBar becomeFirstResponder];

}

-(void)categorySearch:(NSString *)searchstr{
    self.searchPatten = CategorySearch;
    self.searchController.searchBar.text = searchstr;
    self.isManuelSearch = NO;
    [self.searchController.searchBar becomeFirstResponder];

}
-(void)setSearchpattenMethod:(SearchPatten)searchpatten indexPath:(NSIndexPath *)indexPath{
    self.searchPatten = searchpatten;
    self.searchController.searchBar.text = [self.recentSearch objectAtIndex:indexPath.row];
    self.isManuelSearch = YES;
    [self.searchController.searchBar becomeFirstResponder];
 
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchString = self.searchController.searchBar.text;
    NSLog(@"searching string on search = %@",searchString);
    URIData *recent = [[URIData alloc]init];
    recent.hostName = searchString;
    
    if(![searchString isEqualToString:@" "] && ![self.recentSearch containsObject:searchString] && ![CommonMethods isContainCategory:searchString])
    [self.recentSearch addObject:searchString];
    
    NSLog(@"self.recentSearch count = %ld",self.recentSearch.count);
    
    [[NSUserDefaults standardUserDefaults] setObject:self.recentSearch forKey:@"recentSearch"];
//    [self addSuggestionSearchObj];
    

}
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchController];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.NoresultFound.hidden = YES;
    NSLog(@"searchBarCancelButtonClicked");
    [self.tableView reloadData];
}
-(void)onCancleButton{
    self.isManuelSearch = YES;
    self.NoresultFound.hidden = YES;
     NSLog(@"onCancleButton");
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.NoresultFound.hidden = YES;
    NSLog(@"searchBarTextDidBeginEditing");
    
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    [self performFilteringBySearchText: searchText]; // or whatever
    NSLog(@"textDidChange: searchBar");
    self.isManuelSearch = YES;
    // The user clicked the [X] button or otherwise cleared the text.
    if([searchText length] == 0) {
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0.1];
    }
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
    NSString *searchString = self.searchController.searchBar.text;
        NSLog(@"abpve searching string self.searchPatten %ld = %@",(long)self.searchPatten,searchString );
    
    if([CommonMethods isContainMonth:searchString] ){
            self.searchPatten = DateSearch;
        NSLog(@"month search String %@",searchString);
    }
    else if ([CommonMethods isContainCategory:searchString])
        self.searchPatten = CategorySearch;
    else if([CommonMethods isContainWeeKday:searchString])
        self.searchPatten = WeekDaySearch;
    else if(self.isManuelSearch)
        self.searchPatten = RecentSearch;
        
    NSLog(@"searching string self.searchPatten %ld = %@",(long)self.searchPatten,searchString );
    
    [self getHistoryFromDB:searchString];
    NSLog(@"self.historyDict search %@",self.historyDict);

    [self.dayArr removeAllObjects];
    [self.browsingHistory getBrowserHistoryImages:self.historyDict dispatchQueue:self.imageDownloadQueue dayArr:self.dayArr imageDict:self.urlToImageDict];
    
    [self reloadTable];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma  mark customCell for suggestion search
-(void)addSuggestionSearchObj{
    NSDictionary *lasthour = @{@"hostName":@"Last Hour",
                               @"image" : [UIImage imageNamed:@"schedule_icon"]
                               };
   
    NSDictionary *today = @{@"hostName":@"Today",
                               @"image" : [UIImage imageNamed:@"schedule_icon"]
                               };
    NSDictionary *thisWeek = @{@"hostName":@"this Week",
                            @"image" : [UIImage imageNamed:@"schedule_icon"]
                            };
    

    self.suggSearchArr = [[NSArray alloc]initWithObjects:lasthour,today,thisWeek, nil];
    NSDictionary *adults = @{@"hostName":@"Adults Only",
                               @"image" : [UIImage imageNamed:@"Adults_Only"]
                               };
    
    NSDictionary *restricted = @{@"hostName":@"Restricted",
                            @"image" : [UIImage imageNamed:@"Restricted"]
                            };
    NSDictionary *PG_13 = @{@"hostName":@"Parents Strongly Cautioned",
                               @"image" : [UIImage imageNamed:@"Parents_Strongly_Cautioned"]
                               };
    NSDictionary *PG = @{@"hostName":@"Parential Guidence Suggested",
                               @"image" : [UIImage imageNamed:@"Parental_Guidance"]
                               };
    
    NSDictionary *General = @{@"hostName":@"General Audiences",
                            @"image" : [UIImage imageNamed:@"General_Audiences"]
                            };
   
    self.categorySearch = [NSArray arrayWithObjects:adults,restricted,PG_13,PG,General, nil];
    
    NSSet *set = [NSSet setWithArray:[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"recentSearch"]]];
    
    self.recentSearch =  [NSMutableArray arrayWithArray:[set allObjects]];
    
    self.recentSearchObj = [[NSMutableArray alloc]init];
    for (NSString *str in set) {
        NSDictionary *recent = @{@"hostName":str,
                                   @"image" : [UIImage imageNamed:@"search_icon"]
                                   };
       
        [self.recentSearchObj addObject:recent];
    }
    NSLog(@"self.recentSearch count  %@ = %ld",self.recentSearch,self.recentSearch.count);
    
}
- (NSDictionary*)parseJson:(NSString*)fileName{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName
                                                         ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:dataFromFile
                                                         options:kNilOptions
                                                           error:&error];
    
    if (error != nil) {
        NSLog(@"Error: was not able to load json file: %@.",fileName);
    }
    return data;
}

-(void)getHistoryFromDB:(NSString *)searchString{
    NSLog(@"self.searchPatten %ld..%@",(long)self.searchPatten,searchString);
    if(self.searchPatten == CategorySearch){
        self.historyDict = [BrowsingHistoryDataBase searchBYCategoty:searchString almonsMac:self.amac clientMac:self.cmac];
        NSLog(@"CategorySearch reached");
    }
    if(self.searchPatten == RecentSearch){
        self.historyDict = [BrowsingHistoryDataBase getSearchString:searchString almonsMac:self.amac clientMac:self.cmac];
    }
    else if (self.searchPatten == WeekDaySearch){
        self.historyDict = [BrowsingHistoryDataBase weekDaySearch:searchString almonsMac:self.amac clientMac:self.cmac];
    }
    else if(self.searchPatten == TodaySearch){
        self.historyDict = [BrowsingHistoryDataBase todaySearch:self.amac clientMac:self.cmac];
    }
    else if(self.searchPatten == DateSearch){
        self.historyDict = [BrowsingHistoryDataBase DaySearch:searchString almonsMac:self.amac clientMac:self.cmac];
    }
    else if(self.searchPatten == LastHourSearch){
        self.historyDict = [BrowsingHistoryDataBase LastHourSearch:self.amac clientMac:self.cmac];
    }
    else if(self.searchPatten == WeekSearch){
        self.historyDict = [BrowsingHistoryDataBase ThisWeekSearch:self.amac clientMac:self.cmac];
    }
}
#pragma mark parser methods
-(void)reloadTable{
    NSLog(@"reload called");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchTableView reloadData];
    });
}

- (void)initializeSearchController {
    

    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    searchResultsController.tableView.dataSource = self;
    
    searchResultsController.tableView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    
    self.definesPresentationContext = YES;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.delegate = self;
    self.searchTableView = ((UITableViewController *)self.searchController.searchResultsController).tableView;
    self.searchController.searchBar.tintColor = [SFIColors ruleBlueColor];
    [self.searchTableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"abc"];
    self.NoresultFound = [[UILabel alloc]initWithFrame:self
                          .searchTableView.frame];
    self.NoresultFound.text = @"No result found";
    self.NoresultFound.textAlignment = NSTextAlignmentCenter;
    self.NoresultFound.font = [UIFont securifiFont:16];
    self.NoresultFound.textColor = [UIColor grayColor];
    [self.navigationController.view  addSubview:self.NoresultFound];
    self.NoresultFound.hidden = YES;
    
    
}

@end
