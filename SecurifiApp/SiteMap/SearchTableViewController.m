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
#import "BrowsingHistory.h"
#import "NSDate+Convenience.h"
#import "CommonMethods.h"
#import "SearchTableViewController.h"
#import "BrowsingHistoryDataBase.h"
#import "UIFont+Securifi.h"
#import "RecentSearchDB.h"
#import "ChangeCategoryViewController.h"
#import "MBProgressHUD.h"
#import "BrowsingHistoryUtil.h"
#import "AlmondManagement.h"
#import "HTTPRequest.h"


#define CATEORY @"Category"
#define LASTHOUR @"LastHour"
#define PRESENTHOUR @"PresentHour"
#define DOMAINNAME @"Domain"
#define DATE @"Date"
#define LASTWEEK @"LastWeek"
#define WEEKDAY @"WeekDay"
#define FROMTHISDATE @"FromThisDate"
#define UNKNOWN @"Unknown"

#define  RESTRICTED @"Restricted"
#define  NC17 @"NC-17"
#define  PG13 @"PG-13"
#define  PG @"PG"
#define  G @"G"





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

@interface SearchTableViewController ()<UISearchResultsUpdating, UISearchBarDelegate,UITextFieldDelegate,MBProgressHUDDelegate,BrowsingHistoryDelegate,HTTPDelegate>
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
@property (nonatomic)  UILabel *NoresultFound;
@property (nonatomic) NSString *cmac;
@property (nonatomic) NSString *amac;
@property (nonatomic) NSString *searchString;
@property (nonatomic) NSMutableArray *searchStrArr;
@property BOOL isSearchBegin;
@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) MBProgressHUD *HUD;
@property (nonatomic) NSDictionary *incompleteDB;
@property (nonatomic) NSString *searchStr;
@property (nonatomic) NSString *value;
@property BOOL isSendReq;
@property (nonatomic) NSMutableArray *allUri;
@property (nonatomic) HTTPRequest *httpReq;


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
    self.amac = [AlmondManagement currentAlmond].almondplusMAC;
    self.dayArr = [[NSMutableArray alloc]init];
    self.imageDownloadQueue = dispatch_queue_create("img_download", DISPATCH_QUEUE_SERIAL);
    self.navigationController.navigationBar.clipsToBounds = YES;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [SFIColors ruleBlueColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self setUpHUD];
   
    [self.tableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"abc"];
    
    self.allUri = [NSMutableArray new];
    self.isManuelSearch = YES;
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear searchPage");
    self.httpReq = [[HTTPRequest alloc]init];
    self.httpReq.delegate = self;
    self.incompleteDB = @{
                          @"PS" : [NSNull null]
                          };
    [self addSuggestionSearchObj];
    
    [self initializeSearchController];
    
    
    self.isManuelSearch = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    self.NoresultFound.hidden = YES;
    [super viewWillDisappear:YES];
     [self.httpReq cancleConnection];
    
    
    
}
-(void)viewDidDisappear:(BOOL)animated{
    self.NoresultFound.hidden = YES;
    [super viewDidDisappear:YES];
    // [self.searchTableView removeFromSuperview];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.  [searchController.view removeFromSuperview];
}
-(BOOL)search{
    return YES;
}
-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.view addSubview:_HUD];
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
    if(tableView == self.tableView)
        return 40;
    else
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
            headerDate =  @"Ratings";
        
        
        label.text = headerDate;
    }
    else{
        NSString *str;
        NSArray *browsHist;
        if(self.dayArr.count > section)
            browsHist = self.dayArr[section];
        NSDictionary *dict2 = browsHist[0];
        str = dict2[@"date"];
        NSDate *date = [NSDate convertStirngToDate:str];
        
        NSString *headerDate = [date getDayMonthFormat];
        if([str isEqualToString:[BrowsingHistoryDataBase getTodayDate]])
            label.text = @"Today";
        else
            label.text = headerDate;
        NSLog(@"Header date = %@ days %ld",headerDate,(unsigned long)self.dayArr.count);
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
        if(indexPath.section == 0)
            [cell setCell:[self.recentSearchObj objectAtIndex:indexPath.row] hideItem:YES isCategory:NO showTime:NO count:indexPath.row+1 hideCheckMarkIMg:YES];
        else if(indexPath.section == 1)
            [cell setCell:[self.suggSearchArr objectAtIndex:indexPath.row]hideItem:YES isCategory:NO showTime:NO count:indexPath.row+1 hideCheckMarkIMg:YES];
        else if(indexPath.section == 2)
            [cell setCell:[self.categorySearch objectAtIndex:indexPath.row]hideItem:YES isCategory:YES showTime:NO count:indexPath.row+1 hideCheckMarkIMg:YES];
        
    }
    else {
        if(self.dayArr.count > indexPath.section){
            self.NoresultFound.hidden = YES;
            NSArray *browsHist = self.dayArr[indexPath.section];
            if(browsHist.count>indexPath.row)
                [cell setCell:browsHist[indexPath.row] hideItem:NO isCategory:NO showTime:YES count:indexPath.row+1 hideCheckMarkIMg:YES];
        }
    }
    
    return cell;
}
-(void)createRequest:(NSString *)search value:(NSString*)value{
    NSString *todayDate = [CommonMethods getTodayDate];
    NSString *req ;
    self.searchStr = search;
    self.value = value;
    if([self.incompleteDB[@"PS"] isKindOfClass:[NSNull class]])
        req = [NSString stringWithFormat:@"search=%@&value=%@&today=%@&AMAC=%@&CMAC=%@",search,value,todayDate,self.amac,self.cmac];
    
    else
        req = [NSString stringWithFormat:@"search=%@&value=%@&today=%@&pageState=%@&AMAC=%@&CMAC=%@",search,value,todayDate,self.incompleteDB[@"PS"],self.amac,self.cmac];
        
    self.isSendReq = YES;
    
    [self.httpReq sendHttpRequest:req];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == self.tableView){
        if(indexPath.section == 0){
            [self setSearchpattenMethod:RecentSearch indexPath:indexPath];
            [self createRequest:DOMAINNAME value:[self.searchStrArr objectAtIndex:indexPath.row]];
        }
        else if(indexPath.section == 1 && indexPath.row == 0){
            [self setSearchpattenMethod:LastHourSearch withString:@"Last hour"];
            [self createRequest:PRESENTHOUR value:[CommonMethods getPresentTime24Format]];
        }
        else if(indexPath.section == 1 && indexPath.row == 1){
            [self createRequest:DATE value:[CommonMethods getYestardayDate]];
            [self setSearchpattenMethod:TodaySearch withString:@"Last Day"];
        }
        else if(indexPath.section == 1 && indexPath.row == 2){
            [self createRequest:LASTWEEK value:[CommonMethods getTodayDate]];
            [self setSearchpattenMethod:WeekSearch withString:@"Last Week"];
        }
        else if (indexPath.section == 2 && indexPath.row == 0){
            [self createRequest:CATEORY value:@"0"];
            
            [self categorySearch:UNKNOWN andDisplayText:UNKNOWN];
        }
        else if (indexPath.section == 2 && indexPath.row == 1){
            [self createRequest:CATEORY value:@"4"];
            
            
            [self categorySearch:NC17 andDisplayText:@"Adults Only"];
        }
        else if (indexPath.section == 2 && indexPath.row == 2){
            [self createRequest:CATEORY value:@"5"];
            
            [self categorySearch:RESTRICTED andDisplayText:@"Restricted"];
        }
        else if (indexPath.section == 2 && indexPath.row == 3){
            [self createRequest:CATEORY value:@"3"];
            
            [self categorySearch:PG13 andDisplayText:@"Parents Strongly Cautioned"
             ];
        }
        else if (indexPath.section == 2 && indexPath.row == 4){
            [self createRequest:CATEORY value:@"2"];
            
            [self categorySearch:PG andDisplayText:
             @"Parental Guidance Suggested"];
        }
        else if (indexPath.section == 2 && indexPath.row == 5){
            [self createRequest:CATEORY value:@"1"];
            [self categorySearch:G andDisplayText:@"General Audiences"];
        }
    }
    else{
        if(self.dayArr.count > indexPath.section){
            NSArray *browsHist = self.dayArr[indexPath.section];
            if(browsHist.count < indexPath.row)
                return;
            NSDictionary *uriDict = browsHist[indexPath.row];
            //    //NSLog(@"uriDict = %@",uriDict);
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
            ChangeCategoryViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ChangeCategoryViewController"];
            viewController.uriDict = uriDict;
            viewController.client = self.client;
            [self.navigationController pushViewController:viewController animated:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                // [self.HUD hide:YES];
                
            });
            
        }
    }
    
}

#pragma mark sendReq methods

-(void)sendReq:(SearchPatten)searchpatten withString:(NSString *)string{
    [self showHudWithTimeoutMsg:@"Loading..." withDelay:5];
    if(searchpatten == WeekSearch){
        [self.httpReq sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&week%@",_amac,_cmac,[BrowsingHistoryDataBase getTodayDate]]];
    }
    else if(searchpatten == TodaySearch){
        [self.httpReq sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&today%@",_amac,_cmac,[BrowsingHistoryDataBase getTodayDate]]];
    }
}

- (void)responseDict:(NSDictionary*)responseDict {
    
    if(![responseDict[@"AMAC"] isEqualToString:self.amac] || ![responseDict[@"CMAC"] isEqualToString:self.cmac])
        return;
    NSInteger changedHourTag = responseDict[@"ChangeHour"]!=NULL?[responseDict[@"ChangeHour"] integerValue]:0;
    if(changedHourTag == 1)
        [self createRequest:@"LastHour" value:self.value];
    
    NSMutableDictionary *clientBrowsingHistory = [[NSMutableDictionary alloc]init];
    NSString *searchLastHour = responseDict[@"search"]!=NULL?responseDict[@"search"]:@"";
    NSArray *allObj = responseDict[@"Data"];
    NSDictionary *last_uriDict = [allObj lastObject];
    NSString *last_date = last_uriDict[@"Date"];
    if(responseDict[@"pageState"]==NULL){
        NSLog(@"PSS %@",responseDict[@"pageState"]);
    }
    if(last_date != NULL)
        self.incompleteDB = @{
                              @"lastDate" : last_date,
                              @"PS" : responseDict[@"pageState"]? : [NSNull null]
                              };
    
    for(NSDictionary *uriDict in allObj)
    {
        [self.allUri addObject:uriDict];
    }
    NSLog(@"self.allUri count = %ld",(unsigned long)self.allUri.count);
    NSDictionary *dayDict =[CommonMethods createSearchDictObj:self.allUri search:searchLastHour];
    [clientBrowsingHistory setObject:dayDict forKey:@"Data"];
    NSArray *sortedDate = [self sortedDateArr:[dayDict allKeys]];
        [self.dayArr removeAllObjects];
    NSLog(@"self.dayarr count %ld",(unsigned long)self.dayArr.count);
    
    for (NSString *dates in sortedDate){
        NSLog(@"dates == %@",dates);
        NSArray *oneDayUris = dayDict[dates];
        [self.dayArr addObject:oneDayUris];
    }
    [self reloadSearchTable];
    NSLog(@"pageStat = %@",_incompleteDB[@"PS"]);
  
    if(![self.incompleteDB[@"PS"] isKindOfClass:[NSNull class]]){
        
        [self createRequest:self.searchStr value:self.value];
        self.incompleteDB = @{
                              @"PS" : [NSNull null]
                              };
        }
    
}
-(NSArray *)sortedDateArr:(NSArray *)dayDicArr{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSMutableArray *dateArr = [NSMutableArray new];
    for (NSString *dates in dayDicArr){
        NSDate *date = [dateFormat dateFromString:dates];
        [dateArr addObject:date];
    }
    NSArray *sortedArray = [dateArr sortedArrayUsingComparator: ^(NSDate *d1, NSDate *d2) {
        return [d2 compare:d1];
    }];
    [dateArr removeAllObjects];
    for(NSDate *date in sortedArray){
        NSString *string = [dateFormat stringFromDate:date];
        [dateArr addObject:string];
    }
    return dateArr;
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
    self.isManuelSearch = NO;
    [self.searchController.searchBar resignFirstResponder];
    [self searchBarTextDidEndEditing:self.searchController.searchBar];
    self.searchController.active = YES;
    self.searchDisplayController.active = YES;
    
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchString = self.searchString;
    NSLog(@"searching string on search = %@",searchString);
    if(![searchString isEqualToString:@" "] && ![CommonMethods isContainCategory:searchString] && ![CommonMethods isContainMonth:searchString] && ![CommonMethods isContainWeeKday:searchString]){
        long int currentTime = [NSDate date].timeIntervalSince1970;
        [self.recentSearchDict setValue:searchString forKey:@(currentTime).stringValue];
    }
    
    //[RecentSearchDB insertInRecentDB:searchString cmac:self.cmac amac:self.amac];
    if([self.recentSearchDict allKeys].count > 0)
        [self.recentSearchDictObj setObject:self.recentSearchDict forKey:[NSString stringWithFormat:@"%@%@",self.amac,self.cmac]];
    NSLog(@"self.recentSearchDictObj insert %@",self.recentSearchDictObj);
    [[NSUserDefaults standardUserDefaults] setObject:self.recentSearchDictObj forKey:@"recentSearch"];
        [self addSuggestionSearchObj];
    
}
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchController];
    NSLog(@"selectedScopeButtonIndexDidChange");
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.httpReq cancleConnection];
    [searchBar resignFirstResponder];
    [self.dayArr removeAllObjects];
    [self.allUri removeAllObjects];
    NSLog(@"searchBarCancelButtonClicked self.dayArr %ld",(unsigned long)self.dayArr.count);
     self.incompleteDB = @{
                                               @"PS" : [NSNull null]
                                               };
    self.isSearchBegin = YES;
    [self reloadSearchTable];
    [self reloadTable];
    self.NoresultFound.hidden = YES;
    
    
    
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView;
{
    NSLog(@"didLoadSearchResultsTableView");
    self.searchTableView.hidden = YES;
}
-(void)onCancleButton{
    self.isManuelSearch = YES;
    [self.httpReq cancleConnection];
    [self.dayArr removeAllObjects];// making sure ermovinf all obj from self .day arr
    NSLog(@"onCancleButton");
    [self.allUri removeAllObjects];
    // [self dismissViewControllerAnimated:YES completion:nil];
    self.NoresultFound.hidden = YES;
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    NSLog(@"searchBarTextDidBeginEditing %@",searchBar.text);
    self.isSearchBegin = YES;
    self.searchTableView.hidden = YES;
    [self.searchTableView reloadData];
    self.searchTableView.hidden = YES;
    
    
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
    [self.dayArr removeAllObjects];
    [self.allUri removeAllObjects];
    if([searchString isEqualToString:@""] || [searchBar.text isEqualToString:@""]){
        [self.dayArr removeAllObjects];
        [self.allUri removeAllObjects];
        self.incompleteDB = @{
                              @"PS" : [NSNull null]
                              };
        [self searchBarCancelButtonClicked:self.searchController.searchBar];
        return;
    }
    //
    NSLog(@"searchString == %@",searchString);
    if([CommonMethods isContainMonth:searchString] ){
        NSString *str = [BrowsingHistoryUtil getFormateOfDate:searchString];//dd-mm-yyyy
        [self createRequest:DATE value:str];
        
        NSLog(@"month search String %@",searchString);
    }
    else if([CommonMethods isContainWeeKday:searchString]){
        NSString *LastweekDay = [CommonMethods getLastWeekDayDate:searchString];
        [self createRequest:DATE value:LastweekDay];
        
    }
    else if(self.isManuelSearch){
         [self createRequest:DOMAINNAME value:[searchString lowercaseString]];
    }
    
    if(self.dayArr.count == 0)
        self.NoresultFound.hidden = YES;
    [searchBar setShowsCancelButton:YES animated:YES];
}

#pragma  mark customCell for suggestion search
-(void)addSuggestionSearchObj{
    NSDictionary *lasthour = @{@"hostName":@"Last Hour",
                               @"image" : [UIImage imageNamed:@"schedule_icon"]
                               };
    
    NSDictionary *today = @{@"hostName":@"Last Day",
                            @"image" : [UIImage imageNamed:@"schedule_icon"]
                            };
    NSDictionary *thisWeek = @{@"hostName":@"Last Week",
                               @"image" : [UIImage imageNamed:@"schedule_icon"]
                               };
    
    self.suggSearchArr = [[NSArray alloc]initWithObjects:lasthour,today,thisWeek, nil];
    NSDictionary *unknown = @{@"hostName":@"Unknown Rating",
                              @"image" : [UIImage imageNamed:@"unknown_category"]
                              };
    
    NSDictionary *adults = @{@"hostName":@"Adults Only",
                             @"image" : [UIImage imageNamed:@"Adults_Only"]
                             };
    
    NSDictionary *restricted = @{@"hostName":@"Restricted",
                                 @"image" : [UIImage imageNamed:@"Restricted"]
                                 };
    NSDictionary *PG_13 = @{@"hostName":@"Parents Strongly Cautioned",
                            @"image" : [UIImage imageNamed:@"Parents_Strongly_Cautioned"]
                            };
    NSDictionary *PG2 = @{@"hostName":@"Parential Guidence Suggested",
                         @"image" : [UIImage imageNamed:@"Parental_Guidance"]
                         };
    
    NSDictionary *General = @{@"hostName":@"General Audiences",
                              @"image" : [UIImage imageNamed:@"General_Audiences"]
                              };
    
    self.categorySearch = [NSArray arrayWithObjects:unknown,adults,restricted,PG_13,PG2,General, nil];
    self.recentSearchDictObj = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"recentSearch"]];
    self.recentSearchDict = [NSMutableDictionary dictionaryWithDictionary:[self.recentSearchDictObj valueForKey:[NSString stringWithFormat:@"%@%@",self.amac,self.cmac]]];
    self.recentSearchObj = [[NSMutableArray alloc]init];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
    NSArray* sortedArray = [[self.recentSearchDict allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.recentSearchObj removeAllObjects];
    [self.searchStrArr removeAllObjects];
    for (int i = 0;i<sortedArray.count;i++) {
        NSDictionary *recent = @{@"hostName":[self.recentSearchDict valueForKey:[sortedArray objectAtIndex:i]],
                                 @"image" : [UIImage imageNamed:@"search_icon"]
                                 };
        if(i>1)
            break;
        [self.recentSearchObj addObject:recent];
        [self.searchStrArr addObject:[self.recentSearchDict valueForKey:[sortedArray objectAtIndex:i]]];
    }
    NSLog(@"recent obj222 %@",[self.recentSearchDict allKeys]);
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
        [self.HUD hide:YES];
    });
    self.NoresultFound.hidden = YES;
}
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg withDelay:(int)second {
    NSLog(@"showHudWithTimeoutMsg");
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:second];
    });
}
- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
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
    self.NoresultFound.text = @"No results found";
    self.NoresultFound.backgroundColor = [UIColor clearColor];
    self.NoresultFound.textAlignment = NSTextAlignmentCenter;
    self.NoresultFound.font = [UIFont securifiFont:16];
    self.NoresultFound.textColor = [UIColor grayColor];
    [self.navigationController.view  addSubview:self.NoresultFound];
    self.NoresultFound.hidden = YES;
    
}

@end
