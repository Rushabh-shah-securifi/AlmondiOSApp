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
#import "URIData.h"
#import "BrowsingHistory.h"
#import "NSDate+Convenience.h"
#import "SearchTableViewController.h"
#import "DataBaseManager.h"
#import "BrowsingHistoryDataBase.h"
#import "BrowsingHistory.h"
#import "ChangeCategoryViewController.h"
#import "ParentalControlsViewController.h"
#import "CompleteDB.h"
#import "MBProgressHUD.h"

@interface BrowsingHistoryViewController ()<UITableViewDelegate,UITableViewDataSource,BrowsingHistoryDelegate,NSURLConnectionDelegate,MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITableView *browsingTable;
@property (nonatomic) NSMutableArray *dayArr;
@property (nonatomic) dispatch_queue_t imageDownloadQueue;
@property (nonatomic) dispatch_queue_t sendReqQueue;
@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) BrowsingHistory *browsingHistory;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property BOOL sendReq;
@property int count;
@property int targetCount;
@property int dbcount ;
@property BOOL isEmptyDb;
@property (nonatomic) NSString *cmac;
@property (nonatomic) NSString *amac;
@property (nonatomic) NSString *ps;
@property (nonatomic)  UILabel *NoresultFound;
@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (nonatomic) NSDictionary *incompleteDB;
@property BOOL isScrollEndReq;
@property BOOL isTapped;


@end

@implementation BrowsingHistoryViewController
typedef void(^InsertMethod)(BOOL);
- (void)viewDidLoad {
    _isScrollEndReq = NO;
    self.count = 10;
    self.NoresultFound = [[UILabel alloc]initWithFrame:self
                          .browsingTable.frame];
    self.NoresultFound.text = @"No result found";
    self.NoresultFound.backgroundColor = [UIColor clearColor];
    self.NoresultFound.textAlignment = NSTextAlignmentCenter;
    self.NoresultFound.font = [UIFont securifiFont:16];
    self.NoresultFound.textColor = [UIColor grayColor];
    [self.navigationController.view  addSubview:self.NoresultFound];
    self.NoresultFound.hidden = YES;
    
    self.cmac = [CommonMethods hexToString:self.client.deviceMAC];
    self.incompleteDB = [[NSDictionary alloc]init];
    self.clientName.text = self.client.name;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    self.amac = toolkit.currentAlmond.almondplusMAC;
    [self sendHttpRequest:[NSString stringWithFormat:@"AMAC=%@&CMAC=%@",self.amac,self.cmac]];
    self.imageDownloadQueue = dispatch_queue_create("img_download", DISPATCH_QUEUE_SERIAL);
    self.sendReqQueue = dispatch_queue_create("send_req", DISPATCH_QUEUE_SERIAL);

    self.dayArr = [[NSMutableArray alloc]init];
    [self.browsingTable registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"HistorytableCell"];
    self.browsingHistory = [[BrowsingHistory alloc]init];
    self.browsingHistory.delegate = self;
    [self setUpHUD];
    
    
    [super viewDidLoad];
   
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    //[self loadNavigationBar];
    [self.navigationController setNavigationBarHidden:YES];
    
    //dispatch_async(self.sendReqQueue,^(){
    if([BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac] == 0)
        [self showHudWithTimeoutMsg:@"Loading..." withDelay:5];
    
    [self.browsingHistory getBrowserHistoryImages:[BrowsingHistoryDataBase getAllBrowsingHistorywithLimit:20 almonsMac:self.amac clientMac:self.cmac] dispatchQueue:self.imageDownloadQueue dayArr:self.dayArr];
    
         //[self reloadTable];
   // });
   
    self.isEmptyDb = YES;


}
-(void)loadNavigationBar{
    /*self.headerView.backgroundColor = [SFIColors clientGreenColor];
    self.navigationController.navigationBar.clipsToBounds = YES;
    [self updateNavi:[SFIColors clientGreenColor] title:nil tintColor:[UIColor whiteColor] tintBarColor:[SFIColors clientGreenColor]];
   
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
    self.navigationController.navigationBar.topItem.title = @"Browsing history";*/
}

-(void)viewWillDisappear:(BOOL)animated{
     [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    self.NoresultFound.hidden = YES;
    self.isTapped = NO;
    
   // [self updateNavi:[UIColor whiteColor] title:@"" tintColor:[UIColor blueColor] tintBarColor:[UIColor whiteColor]];
    NSLog(@"before delete %d",[BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac]);
    
    int record = [BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac] - 500;
    if(record>0)
    [BrowsingHistoryDataBase deleteOldEntries:self.amac clientMac:self.cmac nosRecord:record];
    NSLog(@"after delete %d",[BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac]);
    

}
-(void)updateNavi:(UIColor *)backGroundColor title:(NSString *)title tintColor:(UIColor *)tintColor tintBarColor:(UIColor *)tintBarColor{
    self.navigationController.view.backgroundColor =  backGroundColor;
    self.navigationController.navigationBar.topItem.title = title;
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.barTintColor = tintBarColor;

}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    //NSLog(@"dbCount1 = %d",[BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac]);
//    [BrowsingHistoryDataBase deleteOldEntries:self.amac clientMac:self.cmac];
    //NSLog(@"dbCount2 = %d",[BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac]);
    if(self.dayArr != nil)
        [self.dayArr removeAllObjects];
    //self.dayArr = nil;
    //if(self.imageDownloadQueue)
      // dispatch_suspend(self.imageDownloadQueue);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setUpHUD{
    _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.removeFromSuperViewOnHide = NO;
    _HUD.dimBackground = YES;
    _HUD.delegate = self;
    [self.navigationController.view addSubview:_HUD];
}
#pragma mark HttpReqDelegateMethods
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
     [self.HUD hide:YES];
    //Now you can do what you want with the response string from the data
    if(_responseData == NULL)
        return;
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    _responseData = nil;
    /*note get endidentifier from db */
     //dispatch_async(self.sendReqQueue,^(){
    
    NSLog(@"response dict =%@",dict);
    if(dict == NULL)
        return;
    NSArray *allObj = dict[@"Data"];
    if(allObj == NULL)
        return;
    NSDictionary *last_uriDict = [allObj lastObject];
    NSString *last_date = last_uriDict[@"Date"];
    if(last_date != NULL)
    self.incompleteDB = @{
                          @"lastDate" : last_date,
                          @"PS" : dict[@"pageState"]? : [NSNull null]
                          };
    NSLog(@"incomplete db %@",self.incompleteDB);
    // put last_date and & ps in incomplete DB
        
     [BrowsingHistoryDataBase insertHistoryRecord:dict];// return last date
    dict = nil;
   
    //check last date <= max date of completeDB stop req
    if(self.incompleteDB[@"PS"] == NULL){
        self.sendReq = NO;
    }
    else{
        NSString *maxCompleteDBDate = [CompleteDB getMaxDate:self.amac clientMac:self.cmac];
        NSLog(@"maxCompleteDBDate %@",maxCompleteDBDate);
        
        if(self.isScrollEndReq == NO && [maxCompleteDBDate isEqualToString:@"1970-01-01"]){
            if([BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac] < 500)
            {
                self.isScrollEndReq = NO;
                NSLog(@"sendHttpRequest HTTP 0");
                NSLog(@"databse count %d",[BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac]);
                [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&pageState=%@",_amac,_cmac,self.incompleteDB[@"PS"]]];
            }

        }else if(self.isScrollEndReq == NO) {
            NSComparisonResult result;
            result = [self.incompleteDB[@"lastDate"] compare:maxCompleteDBDate];
            if((result == 1 || result == 0)){
                self.sendReq = NO;
            }
            else{
                if([BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac] > 500){
                    
                    NSString *lastDateODb = [BrowsingHistoryDataBase getLastDate:self.amac clientMac:self.cmac];
                   
                    [BrowsingHistoryDataBase deleteOldEntries:self.amac clientMac:self.cmac date:lastDateODb];
                    [CompleteDB deleteDateEntries:self.amac clientMac:self.cmac date:lastDateODb];
                }
                    //NSLog(@"requested after delete ");
                self.isScrollEndReq = NO;
                NSLog(@"sendHttpRequest HTTp -1");
                    [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&pageState=%@",_amac,_cmac,self.incompleteDB[@"PS"]]];
            }
           
        }
        else if(self.isScrollEndReq == YES){
            if(self.targetCount != 0 && [BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self
                                         .cmac] < _targetCount ){
                self.isScrollEndReq = YES;
                 NSLog(@"sendHttpRequest HTTp -2");
                [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&pageState=%@",_amac,_cmac,self.incompleteDB[@"PS"]]];
            }
        }
    }
    // result = -1 (NSOrderedAscending)
    
    //count DB if count<500 ..send req with PS of incompleteDB
    //else
    // get min date from HistoryDB
    //remove that Min date from completeDB
    
    //ifEnd of db last date from db and send req
//    /*post notification for read database history and */
//    /*after insert again send request untill response is not null*/

    if(self.isEmptyDb == YES){
    
        
    [self.dayArr removeAllObjects];
        //dispatch_async(self.sendReqQueue,^(){
    [self.browsingHistory getBrowserHistoryImages:[BrowsingHistoryDataBase getAllBrowsingHistorywithLimit:300 almonsMac:self.amac clientMac:self.cmac] dispatchQueue:self.imageDownloadQueue dayArr:self.dayArr];
       
        [self reloadTable];
       // });
        self.isEmptyDb = NO;
    }
    
//    if(self.sendReq == YES){
//        //NSLog(@"incomplete sending req db %@",self.incompleteDB);
//     [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&pageState=%@",_amac,_cmac,self.incompleteDB[@"PS"]]];
//    }
    //});
    [self reloadTable];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { //Do something if there is an error in the connection } - See more at: https://www.sundoginteractive.com/blog/ios-programmatically-posting-to-http-and-webview#sthash.tkwg2Vjg.dpuf
    //NSLog(@"didFailWithError %@",error);
}

-(void)sendRequest:(NSString *)pageState{
    int DBCount = [BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac];
    NSString *startTag = [BrowsingHistoryDataBase getStartTag:self.amac clientMac:self.cmac];
//    //NSLog(@"DBCount %d, start tag %@, end tag %@",DBCount,startTag,pageState);

    if(self.sendReq == YES){
         self.isScrollEndReq = NO;
         NSLog(@"sendHttpRequest HTTp -3");
        [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&pageState=%@",_amac,_cmac,pageState]];
    }
    else
    {
        //NSLog(@"sending http req");
    }
}
#pragma mark table and search delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *browsHist = self.dayArr[section];
    return browsHist.count;
//    self.UriDataOneDay = [self.browsingHistoryObj.allDateRecord valueForKey:self.browsingHistoryDayWise[section]];
//    
//    return self.UriDataOneDay.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.dayArr.count == 0){
        self.NoresultFound.hidden = NO;
    }
    else{
      self.NoresultFound.hidden = YES;
    }
    return self.dayArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self deviceHeader:section tableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistorytableCell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HistorytableCell"];
    }
    
//    self.UriDataOneDay = [self.browsingHistoryObj.allDateRecord valueForKey: self.browsingHistoryDayWise[indexPath.section]];
    if(self.dayArr.count > indexPath.section){
        NSArray *browsHist = self.dayArr[indexPath.section];
        if(browsHist.count>indexPath.row)
            [cell setCell:browsHist[indexPath.row] hideItem:NO isCategory:NO count:indexPath.row+1];
    }
    

    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"willDisplayCell section %ld row %ld",indexPath.section,indexPath.row);
    
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        NSLog(@"willDisplayCell Inside if");
        // This is the last cell
        //NSLog(@"reached to last db count = %d",[BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac]);
        
        if([BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac] > self.count)
        {
        self.count+=300;
            //NSLog(@"asking the req from DB  %d self.dayArr.count %ld",self.count,self.dayArr.count);
            [self.dayArr removeAllObjects];
            
            //dispatch_async(self.sendReqQueue,^(){
        [self.browsingHistory getBrowserHistoryImages:[BrowsingHistoryDataBase getAllBrowsingHistorywithLimit:self.count almonsMac:self.amac clientMac:self.cmac] dispatchQueue:self.imageDownloadQueue dayArr:self.dayArr];
            //NSLog(@"self.dayArr.count %ld",self.dayArr.count);
            [self reloadTable];
            //});
        }
        else{
            NSString *MinDateOrgDB = [BrowsingHistoryDataBase getLastDate:self.amac clientMac:self.cmac];
            NSString *minDateCompDB = [CompleteDB getLastDate:self.amac clientMac:self.cmac];
            NSLog(@"MinDateOrgDB %@,minDateCompDB %@",MinDateOrgDB,minDateCompDB);
            NSDateFormatter *f = [[NSDateFormatter alloc] init];
            [f setDateFormat:@"yyyy-MM-dd"];
            NSString *todayDate = [f stringFromDate:[NSDate date]];
            if([MinDateOrgDB isEqualToString: todayDate]){
                _targetCount = 0;
                 self.isScrollEndReq = YES;
                NSLog(@"sending HTTP 1");
                [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&pageState=%@",_amac,_cmac,self.incompleteDB[@"PS"]]];
            }
            else if(![MinDateOrgDB isEqualToString: todayDate] && [minDateCompDB isEqualToString:@"1970-01-01"]){
                _targetCount = 0;
                
                //NSLog(@"sending incomplete db %@",self.incompleteDB);
                 self.isScrollEndReq = YES;
                NSLog(@"sending HTTP 2");
                [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&pageState=%@",_amac,_cmac,self.incompleteDB[@"PS"]]];
                //[self showHudWithTimeoutMsg:@"Loading..." withDelay:2];
            }
            else{
                //set target count
                self.incompleteDB = @{};
                _targetCount = [BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac] + 100;
                 self.isScrollEndReq = YES;
                NSLog(@"sending HTTP 3");
                [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&lastDate=%@",_amac,_cmac,MinDateOrgDB]];
            }
        }
    }
}




-(UIView*)deviceHeader:(NSInteger)section tableView:(UITableView*)tableView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    
    view.backgroundColor = [UIColor whiteColor];
    if (section > 0) {
        UITableViewHeaderFooterView *foot = (UITableViewHeaderFooterView *)view;
        CGRect sepFrame = CGRectMake(0, 0, tableView.frame.size.width, 1);
        UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame];
        seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:0.5];
        [foot addSubview:seperatorView];
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, tableView.frame.size.width, 18)];
    [label setFont:[UIFont securifiBoldFont:15]];
    
    //    NSMutableArray *myMutableArray = [NSMutableArray arrayWithArray:[dict[@"Data"] allKeys]];
    //
    //    NSArray *aUnsorted = [dict[@"Data"] allKeys];
    //    NSArray *arrKeys = [aUnsorted sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    //        NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //        [df setDateFormat:@"dd-MM-yyyy"];
    //        NSDate *d1 = [df dateFromString:(NSString*) obj1];
    //        NSDate *d2 = [df dateFromString:(NSString*) obj2];
    //        return [d1 compare: d2];
    //    }];
    
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Date" ascending:FALSE];
    //    [myMutableArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSString *str;
    //    //NSLog(@"self.dayArr Count = %ld",self.dayArr.count);
    NSArray *browsHist;
    if(self.dayArr.count > section)
    browsHist = self.dayArr[section];
    NSDictionary *dict2 = browsHist[0];
    //    //NSLog(@"dict2 date %@",dict2);
    str = dict2[@"date"];
    NSDate *date = [NSDate convertStirngToDate:str];
    //     //NSLog(@"date = %@",date);
    
    NSString *headerDate = [date getDayMonthFormat];
    //    //NSLog(@"today date %@ == %@",[BrowsingHistoryDataBase getTodayDate],@"10-8-2016");
    if([str isEqualToString:[BrowsingHistoryDataBase getTodayDate]])
        label.text = [NSString stringWithFormat:@"Today, %@",headerDate];
    else
        label.text = headerDate;
    label.textColor = [UIColor grayColor];
    [view addSubview:label];
    
    CGRect sepFrame = CGRectMake(0, 32, tableView.frame.size.width, 1);
    UIView *seperatorView =[[UIView alloc] initWithFrame:sepFrame];
    seperatorView.backgroundColor = [UIColor colorWithWhite:224.0/255.0 alpha:0.5];
    [view addSubview:seperatorView];
    return view;
}

-(NSString*)getHeaderDate:(NSInteger)section{
    BrowsingHistory *browsHistory = self.browsingHistoryDayWise[section];
    return [browsHistory.date getDayMonthFormat];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isTapped == NO)
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
        self.isTapped = YES;
        [self.navigationController pushViewController:viewController animated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            // [self.HUD hide:YES];
            
        });

      }


}
#pragma mark click handler
- (void)onSearchButton{

    SearchTableViewController *ctrl = [[SearchTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    ctrl.client = self.client;
    [self presentViewController:nav_ctrl animated:YES completion:nil];
}

-(void)reloadTable{
    //NSLog(@"reload called");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.browsingTable reloadData];
    });
}
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg withDelay:(int)second {
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:second];
        [self reloadTable];
    });
}
- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)searchBurronClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
    SearchTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchTableViewController"];
   
    
    viewController.client = self.client;
     [self.navigationController pushViewController:viewController animated:YES];
    
}
@end
