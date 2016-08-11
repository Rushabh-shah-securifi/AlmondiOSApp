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

typedef NS_ENUM(NSInteger, SearchPatten) {
    DefaultSearch,
    RecentSearch,
    TodaySearch,
    LastHourSearch,
    WeekDaySearch,
    DateSearch,
    WeekSearch
};

@interface SearchTableViewController ()<UISearchResultsUpdating, UISearchBarDelegate,UITextFieldDelegate>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic) UITableView *searchTableView;
@property (nonatomic) NSArray *suggSearchArr;
@property (nonatomic) NSMutableArray *recentSearch;
@property (nonatomic) NSMutableArray *recentSearchObj;

@property (nonatomic) SearchPatten searchPatten;
@property (nonatomic) NSMutableArray *dayArr;
@property (nonatomic) dispatch_queue_t imageDownloadQueue;
@property BOOL isManuelSearch ;
@property (nonatomic) NSDictionary *historyDict;
@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    if(tableView == self.tableView){
        return 2;
    }
    else
       return self.dayArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tableView){
        if(section == 0)
            return self.suggSearchArr.count;
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
        headerDate = (section == 0) ? @"Suggested Searches":@"Recent Searches";
        label.text = headerDate;
    }
    else{
        NSString *str = [[self.historyDict[@"Data"] allKeys] objectAtIndex:section];
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
        else
            [cell setCell:[self.recentSearchObj objectAtIndex:indexPath.row]hideItem:YES];
    }
    else {
        NSArray *browsHist = self.dayArr[indexPath.section];
        [cell setCell:browsHist[indexPath.row] hideItem:NO];

    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.tableView){
        if(indexPath.section == 1){
             [self setSearchpattenMethod:RecentSearch];
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
    }
}
-(void)setSearchpattenMethod:(SearchPatten)searchpatten{
    self.searchPatten = searchpatten;
    self.searchController.searchBar.text = @" ";
    self.isManuelSearch = NO;
    [self.searchController.searchBar becomeFirstResponder];
    //            [self.searchController.searchBar resignFirstResponder];
    //            [self.view endEditing:TRUE];

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
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchString = self.searchController.searchBar.text;
    NSLog(@"searching string on search = %@",searchString);
    URIData *recent = [[URIData alloc]init];
    recent.hostName = searchString;
    
    if(![searchString isEqualToString:@" "] && ![self.recentSearch containsObject:searchString])
    [self.recentSearch addObject:searchString];
    
    NSLog(@"self.recentSearch count = %ld",self.recentSearch.count);
    [[NSUserDefaults standardUserDefaults] setObject:self.recentSearch forKey:@"recentSearch"];
    [self addSuggestionSearchObj];
    

}
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchController];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}
-(void)onCancleButton{
    self.isManuelSearch = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"searchBarTextDidBeginEditing");
    
    
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSString *searchString = self.searchController.searchBar.text;
        
        if([CommonMethods isContainMonth:searchString] && self.isManuelSearch)
            self.searchPatten = DateSearch;
        if([CommonMethods isContainWeeKday:searchString] && self.isManuelSearch)
            self.searchPatten = WeekDaySearch;
        else if(self.isManuelSearch)
            self.searchPatten = RecentSearch;
        
        NSLog(@"searching string self.searchPatten %ld = %@",(long)self.searchPatten,searchString );
    
    [self getHistoryFromDB:searchString];
    
    [self getBrowserHistoryImages:self.historyDict];
//    [self.searchTableView reloadData];
    
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma  mark customCell for suggestion search
-(void)addSuggestionSearchObj{
    URIData *lasthour = [[URIData alloc]init];
    lasthour.hostName = @"Last Hour";
    lasthour.image = [UIImage imageNamed:@"schedule_icon"];
    
    URIData *today = [[URIData alloc]init];
    today.hostName = @"Today";
    today.image = [UIImage imageNamed:@"schedule_icon"];
    
    URIData *thisWeek = [[URIData alloc]init];
    thisWeek.hostName = @"This Week";
    thisWeek.image = [UIImage imageNamed:@"event_icon"];
    
    self.suggSearchArr = [[NSArray alloc]initWithObjects:lasthour,today,thisWeek, nil];
    
    
    NSSet *set = [NSSet setWithArray:[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"recentSearch"]]];
    
    self.recentSearch =  [NSMutableArray arrayWithArray:[set allObjects]];
    
    self.recentSearchObj = [[NSMutableArray alloc]init];
    for (NSString *str in set) {
        URIData *recent = [[URIData alloc]init];
        recent.hostName = str;
        recent.image = [UIImage imageNamed:@"search_icon"];
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
    if(self.searchPatten == RecentSearch){
        self.historyDict = [BrowsingHistoryDataBase getSearchString:@"All" andSearchSting:searchString];
    }
    else if (self.searchPatten == WeekDaySearch){
        self.historyDict = [BrowsingHistoryDataBase getManualString:@"weekDay" andSearchSting:searchString];
    }
    else if(self.searchPatten == TodaySearch){
        self.historyDict = [BrowsingHistoryDataBase getManualString:@"Today" andSearchSting:searchString];
    }
    else if(self.searchPatten == DateSearch){
        self.historyDict = [BrowsingHistoryDataBase getManualString:@"monthDay" andSearchSting:searchString];
    }
    else if(self.searchPatten == LastHourSearch){
        self.historyDict = [BrowsingHistoryDataBase getManualString:@"lastHour" andSearchSting:searchString];
    }
    else if(self.searchPatten == WeekSearch){
        self.historyDict = [BrowsingHistoryDataBase getManualString:@"lastWeek" andSearchSting:searchString];
    }
}

#pragma mark parser methods
-(void)getBrowserHistoryImages:(NSDictionary *)historyDict{
    self.dayArr = [[NSMutableArray alloc]init];
    //    dayArr = [historyDict[@"Data"] all]
    NSLog(@"historyDict %@",historyDict[@"Data"]);
    NSDictionary *dict1 = historyDict[@"Data"];
    for (NSString *dates in [dict1 allKeys]) {
        NSArray *alldayArr = dict1[dates];
        NSLog(@"\n alldayArr alldayDict %@",alldayArr);
        NSMutableArray *oneDayUri = [[NSMutableArray alloc]init];
        for (NSDictionary *uriDict in alldayArr) {
            URIData *uriInfo = [URIData new];
            uriInfo.hostName = uriDict[@"hostName"];
            uriInfo.count = [uriDict[@"count"] intValue];
            uriInfo.lastActiveTime = [NSDate getDateFromEpoch:uriDict[@"Epoc"]];
            dispatch_async(self.imageDownloadQueue,^(){
                uriInfo.image = [self getImage:uriDict[@"hostName"]];
            });
            
            [oneDayUri addObject:uriInfo];
        }
        [self.dayArr addObject:oneDayUri];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.searchTableView reloadData];
        });//
    }
}
//
-(UIImage*)getImage:(NSString*)hostName{
    NSLog(@"getImage");
    
    __block UIImage *img;
    if(self.urlToImageDict[hostName]){
        NSLog(@"one");
        return self.urlToImageDict[hostName]; //todo: fetch locally upto 100 images.
    }else{
        
        //        img = [UIImage imageNamed:@"Mail_icon"];
        
        NSLog(@"two");
        __block NSString *iconUrl = [NSString stringWithFormat:@"http://%@/favicon.ico", hostName];
        NSLog(@"iconUrl %@",iconUrl);
        img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
        if(!img){
            NSLog(@"three");
                iconUrl = [NSString stringWithFormat:@"https://%@/favicon.ico", hostName];
                img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]];
            
        }
        if(!img){
            NSLog(@"four");
            img = [UIImage imageNamed:@"Mail_icon"];
        }
        NSLog(@"five");
        self.urlToImageDict[hostName] = img;
        
        return img;
    }
}


@end
