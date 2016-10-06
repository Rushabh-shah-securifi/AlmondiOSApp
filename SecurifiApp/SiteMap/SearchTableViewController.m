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
#import "RecentSearchDB.h"




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

@interface SearchTableViewController ()<UISearchResultsUpdating, UISearchBarDelegate,UITextFieldDelegate,BrowsingHistoryDelegate,NSURLConnectionDelegate>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic) UITableView *searchTableView;
@property (nonatomic) NSArray *suggSearchArr;
@property (nonatomic) BrowsingHistory *browsingHistory;

@property (nonatomic) NSMutableDictionary *recentSearchDict;
@property (nonatomic) NSMutableDictionary *recentSearchDictObj;
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
@property (nonatomic) NSString *searchString;
@property (nonatomic) NSMutableArray *searchStrArr;
@property BOOL isSearchBegin;
@property (nonatomic) NSMutableData *responseData;
;
@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recentSearchDict = [NSMutableDictionary new];
    self.recentSearchDictObj = [NSMutableDictionary new];
    self.searchStrArr = [NSMutableArray new];
    
    self.cmac = [CommonMethods hexToString:self.client.deviceMAC];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.amac = toolkit.currentAlmond.almondplusMAC;
    self.dayArr = [[NSMutableArray alloc]init];
        self.browsingHistory =[[BrowsingHistory alloc]init];
        self.browsingHistory.delegate = self;
    self.imageDownloadQueue = dispatch_queue_create("img_download", DISPATCH_QUEUE_SERIAL);
    self.navigationController.navigationBar.clipsToBounds = YES;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [SFIColors ruleBlueColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
//    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancleButton)];
//    
//    NSArray *actionButtonItems = @[search];
//    self.navigationItem.rightBarButtonItems = actionButtonItems;

    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"abc"];
    
    [self addSuggestionSearchObj];
    [self initializeSearchController ];
    
    self.isManuelSearch = YES;
    }
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear searchPage");
    self.isManuelSearch = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:YES];
    
    [self.searchTableView removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.  [searchController.view removeFromSuperview];
}
-(BOOL)search{
    return YES;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if(tableView == self.tableView){
       
        self.NoresultFound.hidden = YES;
        return 3;
    }
    else{
        if(self.dayArr.count == 0 && self.isSearchBegin == NO){
            NSLog(@"self.dayArr.count %ld",(unsigned long)self.dayArr.count);
            self.NoresultFound.hidden = NO;
        }

        return self.dayArr.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.tableView){
        if(section == 0)
            return self.recentSearchObj.count;
        else if(section == 1)
            return self.suggSearchArr.count;
        else
            return  self.categorySearch.count;
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
    [label setFont:[UIFont securifiBoldFont:15]];
    
    if(tableView == self.tableView){
        if(section == 0)
            headerDate =  @"Recent Searches";
        else if(section == 1)
            headerDate =  @"Suggested Searches";
        else
            headerDate =  @"Categories";
        
        
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
        if([str isEqualToString:[BrowsingHistoryDataBase getTodayDate]])
            label.text = [NSString stringWithFormat:@"Today, %@",headerDate];
        else
            label.text = headerDate;
    }
    
    label.textColor = [UIColor grayColor];
    [view addSubview:label];

    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"abc" forIndexPath:indexPath];
    
    if (cell == nil){
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abc"];
    }
    
    if(tableView == self.tableView){

        if(indexPath.section == 1)
            [cell setCell:[self.suggSearchArr objectAtIndex:indexPath.row]hideItem:YES isCategory:NO count:indexPath.row+1];
        else if(indexPath.section == 2)
            [cell setCell:[self.categorySearch objectAtIndex:indexPath.row]hideItem:YES isCategory:YES count:indexPath.row+1];
        else if(indexPath.section == 0)
            [cell setCell:[self.recentSearchObj objectAtIndex:indexPath.row] hideItem:YES isCategory:NO count:indexPath.row+1];
    }
    else {
        if(self.dayArr.count > indexPath.section){
            self.NoresultFound.hidden = YES;
        NSArray *browsHist = self.dayArr[indexPath.section];
            if(browsHist.count>indexPath.row)
        [cell setCell:browsHist[indexPath.row] hideItem:YES isCategory:YES count:indexPath.row+1];
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == self.tableView){
        if(indexPath.section == 0){
             [self setSearchpattenMethod:RecentSearch indexPath:indexPath];
        }
        else if(indexPath.section == 1 && indexPath.row == 0){
             [self setSearchpattenMethod:LastHourSearch withString:@"Last hour"];
        }
        else if(indexPath.section == 1 && indexPath.row == 1){
             [self setSearchpattenMethod:TodaySearch withString:@"TodaySearch"];
        }
        else if(indexPath.section == 1 && indexPath.row == 2){
            [self setSearchpattenMethod:WeekSearch withString:@"Past Week"];
        }
        else if (indexPath.section == 2 && indexPath.row == 0){
            [self categorySearch:@"NC-17" andDisplayText:@"Adults Only"];
        }
        else if (indexPath.section == 2 && indexPath.row == 1){
            [self categorySearch:@"R" andDisplayText:@"Restricted"];
        }
        else if (indexPath.section == 2 && indexPath.row == 2){
            [self categorySearch:@"PG-13" andDisplayText:@"Parents Strongly Cautioned"
             ];
        }
        else if (indexPath.section == 2 && indexPath.row == 3){
            [self categorySearch:@"PG" andDisplayText:
             @"Parental Guidance Suggested"];
        }
        else if (indexPath.section == 2 && indexPath.row == 4){
            [self categorySearch:@"G" andDisplayText:@"General Audiences"];
        }
    }
    
}
#pragma mark sendReq methods
-(void)sendReq:(SearchPatten)searchpatten withString:(NSString *)string{
    if(searchpatten == WeekSearch){
        [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&week",_amac,_cmac]];
    }
    else if(searchpatten == WeekSearch){
        [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&week",_amac,_cmac]];
    }
}
-(void)sendHttpRequest:(NSString *)post {// make it paramater CMAC AMAC StartTag EndTag
    //NSString *post = [NSString stringWithFormat: @"userName=%@&password=%@", self.userName, self.password];
    
    // dispatch_async(self.sendReqQueue,^(){
    NSLog(@"post req = %@",post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"http://sitemonitoring.securifi.com:8081"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; [request setTimeoutInterval:20.0];
    [request setHTTPBody:postData];
    [NSURLConnection connectionWithRequest:request delegate:self];
    //});
    
    
    
    //www.sundoginteractive.com/blog/ios-programmatically-posting-to-http-and-webview#sthash.tkwg2Vjg.dpuf
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response { _responseData = [[NSMutableData alloc] init];
    //NSLog(@"didReceiveResponse");
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
    //NSLog(@"didReceiveData");
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    //NSLog(@"willCacheResponse");
    return nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //Now you can do what you want with the response string from the data
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    _responseData = nil;
    /*note get endidentifier from db */
    //dispatch_async(self.sendReqQueue,^(){
    NSLog(@"response dict =%@",dict);
}
#pragma mark searchDelegate methods
-(void)setSearchpattenMethod:(SearchPatten)searchpatten withString:(NSString *)string{
    self.searchPatten = searchpatten;
    self.searchController.searchBar.text = string;
    self.searchString = @" ";
    self.isManuelSearch = NO;
    [self.searchController.searchBar resignFirstResponder];
    [self searchBarTextDidEndEditing:self.searchController.searchBar];
    self.searchController.active = YES;
    self.searchDisplayController.active = YES;

}

-(void)categorySearch:(NSString *)searchstr andDisplayText:(NSString*)text{
    self.searchPatten = CategorySearch;
    self.searchController.searchBar.text = text;
    self.isManuelSearch = NO;
    self.searchString = searchstr;
    [self.searchController.searchBar resignFirstResponder];
    [self searchBarTextDidEndEditing:self.searchController.searchBar];
    self.searchController.active = YES;
    self.searchDisplayController.active = YES;
    

}
-(void)setSearchpattenMethod:(SearchPatten)searchpatten indexPath:(NSIndexPath *)indexPath{
    self.searchPatten = searchpatten;
    self.searchController.searchBar.text = [self.searchStrArr objectAtIndex:indexPath.row];
    self.searchString = [self.searchStrArr objectAtIndex:indexPath.row];
    self.isManuelSearch = YES;
    [self.searchController.searchBar resignFirstResponder];
    [self searchBarTextDidEndEditing:self.searchController.searchBar];
    self.searchController.active = YES;
    self.searchDisplayController.active = YES;
 
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchString = self.searchString;
    NSLog(@"searching string on search = %@",searchString);
    if(![searchString isEqualToString:@" "] && ![CommonMethods isContainCategory:searchString]){
         long int currentTime = [NSDate date].timeIntervalSince1970;
    [self.recentSearchDict setValue:searchString forKey:@(currentTime).stringValue];
    }
    
    [RecentSearchDB insertInRecentDB:searchString cmac:self.cmac amac:self.amac];
    if([self.recentSearchDict allKeys].count > 0)
    [self.recentSearchDictObj setObject:self.recentSearchDict forKey:[NSString stringWithFormat:@"%@%@",self.amac,self.cmac]];
    NSLog(@"self.recentSearchDictObj insert %@",self.recentSearchDictObj);
    [[NSUserDefaults standardUserDefaults] setObject:self.recentSearchDictObj forKey:@"recentSearch"];
//    [self addSuggestionSearchObj];
    
}
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchController];
    NSLog(@"selectedScopeButtonIndexDidChange");
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSLog(@"searchBarCancelButtonClicked");
    [self reloadTable];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.NoresultFound.hidden = YES;
    });
    
    
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView;
{
    NSLog(@"didLoadSearchResultsTableView");
    self.searchTableView.hidden = YES;
}
-(void)onCancleButton{
    self.isManuelSearch = YES;
    self.NoresultFound.hidden = YES;
     NSLog(@"onCancleButton");
   // [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    NSLog(@"searchBarTextDidBeginEditing %@",searchBar.text);
    self.isSearchBegin = YES;
    self.searchTableView.hidden = YES;
   // [self.searchTableView reloadData];
    
    
    
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"shouldReloadTableForSearchString");
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSLog(@"shouldReloadTableForSearchScope");
    return NO;
}
-(BOOL)textFieldShouldClear:(UITextField *)textField {
   
    NSLog(@"textFieldShouldClear");
    return NO;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    [self performFilteringBySearchText: searchText]; // or whatever
    NSLog(@"textDidChange: searchBar");
    self.isSearchBegin = YES;
    self.searchTableView.hidden = YES;
    [self reloadTable];
     self.searchTableView.hidden = YES;
    self.NoresultFound.hidden = YES;
    self.isManuelSearch = YES;
    self.searchString = searchBar.text;
    // The user clicked the [X] button or otherwise cleared the text.
    if([searchText length] == 0) {
        self.searchString = @"";
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0.1];
        
    }
    if(self.dayArr.count == 0)
        self.NoresultFound.hidden = YES;
}
-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.isSearchBegin = NO;
    self.searchTableView.hidden = NO;
    NSString *searchString = self.searchString;
    if([searchString isEqualToString:@""] || [searchBar.text isEqualToString:@""]){
        [self.dayArr removeAllObjects];
        [self searchBarCancelButtonClicked:self.searchController.searchBar];
        return;
    }
    
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

    [self.dayArr removeAllObjects];
    [self.browsingHistory getBrowserHistoryImages:self.historyDict dispatchQueue:self.imageDownloadQueue dayArr:self.dayArr];
    
    [self reloadSearchTable];
    if(self.dayArr.count == 0)
        self.NoresultFound.hidden = YES;
    [searchBar setShowsCancelButton:YES animated:YES];
}

#pragma  mark customCell for suggestion search
-(void)addSuggestionSearchObj{
    NSDictionary *lasthour = @{@"hostName":@"Last Hour",
                               @"image" : [UIImage imageNamed:@"schedule_icon"]
                               };
   
    NSDictionary *today = @{@"hostName":@"Today",
                               @"image" : [UIImage imageNamed:@"schedule_icon"]
                               };
    NSDictionary *thisWeek = @{@"hostName":@"Past Week",
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
//    
//    NSSet *set = [NSSet setWithArray:[NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"recentSearch"]]];
    self.recentSearchDictObj = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"recentSearch"]];
    self.recentSearchDict = [NSMutableDictionary dictionaryWithDictionary:[self.recentSearchDictObj valueForKey:[NSString stringWithFormat:@"%@%@",self.amac,self.cmac]]];
    NSLog(@"recent search after %@ = ",self.recentSearchDict);
    
    
    self.recentSearchObj = [[NSMutableArray alloc]init];
    //NSLog(@"recent seaech count = %d",[RecentSearchDB GetHistoryDatabaseCount:self.amac clientMac:_cmac]);
    NSLog(@"self.recentSearchDictObj %@",self.recentSearchDictObj);
    //self.recentSearchObj = [RecentSearchDB getAllRecentwithLimit:1 almonsMac:self.amac clientMac:self.cmac];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
    NSArray* sortedArray = [[self.recentSearchDict allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.recentSearchObj removeAllObjects];
    [self.searchStrArr removeAllObjects];
    for (int i = 0;i<sortedArray.count;i++) {
        NSDictionary *recent = @{@"hostName":[self.recentSearchDict valueForKey:[sortedArray objectAtIndex:i]],
                                   @"image" : [UIImage imageNamed:@"search_icon"]
                                   };
        if(i>2)
            break;
        [self.recentSearchObj addObject:recent];
        [self.searchStrArr addObject:[self.recentSearchDict valueForKey:[sortedArray objectAtIndex:i]]];
        
        
    }
    NSLog(@"recent obj222 %@",[self.recentSearchDict allKeys]);
    
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
        
        [self.tableView reloadData];
    });
    self.NoresultFound.hidden = YES;
}
-(void)reloadSearchTable{
    NSLog(@"reload called");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.searchTableView reloadData];
    });
    self.NoresultFound.hidden = YES;
}
- (void)initializeSearchController {
    

    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    searchResultsController.tableView.dataSource = self;
    
    searchResultsController.tableView.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.navigationController.view.backgroundColor = [UIColor clearColor];
    self.definesPresentationContext = YES;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y , self.searchController.searchBar.frame.size.width, 44.0);
    
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = false;
    self.searchController.searchBar.delegate = self;

    self.searchController.hidesNavigationBarDuringPresentation = false;
    
    self.searchTableView = ((UITableViewController *)self.searchController.searchResultsController).tableView;
    
    self.searchController.searchBar.tintColor = [SFIColors ruleBlueColor];
    [self.searchTableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"abc"];
    self.NoresultFound = [[UILabel alloc]initWithFrame:self
                          .searchTableView.frame];
    self.NoresultFound.text = @"No result found";
    self.NoresultFound.backgroundColor = [UIColor clearColor];
    self.NoresultFound.textAlignment = NSTextAlignmentCenter;
    self.NoresultFound.font = [UIFont securifiFont:16];
    self.NoresultFound.textColor = [UIColor grayColor];
    [self.navigationController.view  addSubview:self.NoresultFound];
    self.NoresultFound.hidden = YES;
    
}

@end
