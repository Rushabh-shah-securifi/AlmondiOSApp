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

@interface BrowsingHistoryViewController ()<UITableViewDelegate,UITableViewDataSource,BrowsingHistoryDelegate,NSURLConnectionDelegate>
@property (weak, nonatomic) IBOutlet UITableView *browsingTable;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic) NSArray *UriDataOneDay ;
@property (nonatomic)NSMutableArray *dayArr;
@property (nonatomic) dispatch_queue_t imageDownloadQueue;
@property (nonatomic) NSMutableDictionary *urlToImageDict;
@property (nonatomic) NSMutableData *responseData;
@property BOOL sendReq;
@property BOOL reqStartTag;


@end

@implementation BrowsingHistoryViewController

- (void)viewDidLoad {
    self.imageDownloadQueue = dispatch_queue_create("img_download", DISPATCH_QUEUE_SERIAL);
    
//    [BrowsingHistoryDataBase insertRecordFromFile:@"responseMain"];
//    [self getBrowserHistoryImages:[BrowsingHistoryDataBase getAllBrowsingHistory]];
    self.dayArr = [[NSMutableArray alloc]init];
    [self sendRequest:@""];
    [self.browsingTable registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"HistorytableCell"];
    self.urlToImageDict = [NSMutableDictionary new];
    [super viewDidLoad];
   
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadNavigationBar];
    [self initializeNotification];


}
-(void)loadNavigationBar{
    self.headerView.backgroundColor = [SFIColors clientGreenColor];
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
    self.navigationController.navigationBar.topItem.title = @"Browsing history";
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self updateNavi:[UIColor whiteColor] title:@"" tintColor:[UIColor blueColor] tintBarColor:[UIColor whiteColor]];
    [BrowsingHistoryDataBase deleteDB];

}
-(void)updateNavi:(UIColor *)backGroundColor title:(NSString *)title tintColor:(UIColor *)tintColor tintBarColor:(UIColor *)tintBarColor{
    self.navigationController.view.backgroundColor =  backGroundColor;
    self.navigationController.navigationBar.topItem.title = title;
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.barTintColor = tintBarColor;

}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)initializeNotification{
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    
    [notification addObserver:self selector:@selector(onImageFetch:) name:NOTIFICATION_IMAGE_FETCH object:nil];
}
-(void)sendHttpRequest:(NSString *)startTag endTag:(NSString *)endTag{// make it paramater CMAC AMAC StartTag EndTag
    //NSString *post = [NSString stringWithFormat: @"userName=%@&password=%@", self.userName, self.password];
    
   NSString *post = [NSString stringWithFormat: @"AMAC=%@&CMAC=%@&EndTag=%@&StartTag=%@",@"e4:71:85:20:0b:c4",@"10:60:4b:d9:60:84",endTag,startTag];
    NSLog(@"post req = %@",post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://sitemonitoring-abhilashsecurifi.c9users.io:8081"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; [request setTimeoutInterval:20.0];
    [request setHTTPBody:postData];
    [NSURLConnection connectionWithRequest:request delegate:self];
    //www.sundoginteractive.com/blog/ios-programmatically-posting-to-http-and-webview#sthash.tkwg2Vjg.dpuf
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response { _responseData = [[NSMutableData alloc] init];
    NSLog(@"didReceiveResponse");
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
    NSLog(@"didReceiveData");
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    NSLog(@"willCacheResponse");
    return nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //Now you can do what you want with the response string from the data
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    
    /*note get endidentifier from db */
    NSLog(@"response dict =%@",dict);
    NSString *endTag = [BrowsingHistoryDataBase insertHistoryRecord:dict];
    
    if(endTag == NULL)
        self.sendReq = NO;
    else
        self.sendReq = YES;

//    /*post notification for read database history and */
//    /*after insert again send request untill response is not null*/
//    [self upateBrowsingTable];
    [self getBrowserHistoryImages:[BrowsingHistoryDataBase getAllBrowsingHistory]];
    NSLog(@"end tag = %@",endTag);
    
    [self sendRequest:endTag];
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { //Do something if there is an error in the connection } - See more at: https://www.sundoginteractive.com/blog/ios-programmatically-posting-to-http-and-webview#sthash.tkwg2Vjg.dpuf
    NSLog(@"didFailWithError %@",error);
}

-(void)sendRequest:(NSString *)endTag{
    int DBCount = [BrowsingHistoryDataBase GetHistoryDatabaseCount];
    NSString *startTag = [BrowsingHistoryDataBase getStartTag];
    NSLog(@"DBCount %d, start tag %@, end tag %@",DBCount,startTag,endTag);
    
    if(DBCount != 0){
        if(self.sendReq == YES){
            [self sendHttpRequest:@"" endTag:endTag];
            self.reqStartTag = YES;
        }
        else if(self.reqStartTag == NO){
            NSLog(@"sending request with startTag only one time...............................................");
            [self sendHttpRequest:startTag endTag:@""];
            self.reqStartTag = YES;
        }
    }
    else
    {
        [self sendHttpRequest:@"" endTag:@""];
        NSLog(@"sending http req");
    }
}
-(void)upateBrowsingTable{
    BrowsingHistory *Bhistory =[[BrowsingHistory alloc]init];
    
    Bhistory.delegate = self;
    NSLog(@"dbDict %@",[BrowsingHistoryDataBase getAllBrowsingHistory]);
    [Bhistory getBrowserHistoryImages:[BrowsingHistoryDataBase getAllBrowsingHistory] dispatchQueue:self.imageDownloadQueue dayArr:self.dayArr];
}
#pragma mark parser methods
#pragma mark table and search delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *browsHist = self.dayArr[section];
    return browsHist.count;
//    self.UriDataOneDay = [self.browsingHistoryObj.allDateRecord valueForKey:self.browsingHistoryDayWise[section]];
//    
//    return self.UriDataOneDay.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dayArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self deviceHeader:section tableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cell for row");
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistorytableCell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HistorytableCell"];
    }
    
//    self.UriDataOneDay = [self.browsingHistoryObj.allDateRecord valueForKey: self.browsingHistoryDayWise[indexPath.section]];
    NSArray *browsHist = self.dayArr[indexPath.section];
    [cell setCell:browsHist[indexPath.row] hideItem:NO];
    return cell;
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
    [label setFont:[UIFont securifiBoldFont:13]];
    NSDictionary * dict = [BrowsingHistoryDataBase getAllBrowsingHistory];
//    NSLog(@"dict == %@",dict);
    NSString *str = [[dict[@"Data"] allKeys] objectAtIndex:section];
//    NSLog(@"str date string %@",str);
    NSDate *date = [NSDate convertStirngToDate:str];
    /*
     historyDict[@"Data"]);
     NSDictionary *dict1 = historyDict[@"Data"];
     for (NSString *dates in [dict1 allKeys]
                                                                */
    NSString *headerDate = [date getDayMonthFormat];
    label.text = section == 0? [NSString stringWithFormat:@"Today, %@",headerDate]: headerDate;
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

#pragma mark click handler
- (void)onSearchButton1{
    dispatch_async(dispatch_get_global_queue(0,0), ^{
//        [self requestForNextHistoryEdit];
    });
}
- (void)onSearchButton{
  NSLog(@" dict count = = %d",[BrowsingHistoryDataBase GetHistoryDatabaseCount]);
//
//    [BrowsingHistoryDataBase GetHistoryDatabaseCount];
    SearchTableViewController *ctrl = [[SearchTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav_ctrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
    ctrl.urlToImageDict = self.urlToImageDict;
    [self presentViewController:nav_ctrl animated:YES completion:nil];
}
- (void)onBackButton{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)reloadTable{
    NSLog(@"reload called");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.browsingTable reloadData];
    });
}

#pragma mark notification call backs
-(void)onImageFetch:(id)sender{
    NSLog(@"onImageFetch");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.browsingTable reloadData];
    });
}

-(void)getBrowserHistoryImages:(NSDictionary *)historyDict{
    self.dayArr = [[NSMutableArray alloc]init];
    //    dayArr = [historyDict[@"Data"] all]
    NSLog(@"historyDict %@",historyDict[@"Data"]);
    NSDictionary *dict1 = historyDict[@"Data"];
    for (NSString *dates in [dict1 allKeys]) {
        NSArray *alldayArr = dict1[dates];
        NSLog(@"\n alldayArr alldayDict %@",alldayArr);
        NSMutableArray *oneDayUri = [[NSMutableArray alloc]init];
        for (NSMutableDictionary *uriDict in alldayArr) {
            
            URIData *uriInfo = [URIData new];
            uriInfo.hostName = uriDict[@"hostName"];
            uriInfo.count = [uriDict[@"count"] intValue];
            
            uriInfo.lastActiveTime = [NSDate getDateFromEpoch:uriDict[@"Epoc"]];
            dispatch_async(self.imageDownloadQueue,^(){
                //            [uriDict setObject:@"sddddd" forKey:@"image"];
                //            uriDict[@"image"] = [self getImage:uriDict[@"hostName"]];
                uriInfo.image = [self getImage:uriDict[@"hostName"]];
            });
            
            [oneDayUri addObject:uriInfo];
        }
//        {
//            NSMutableDictionary *uriInfoDict = [NSMutableDictionary new];
//            
//            //            [uriDict setObject:@"sddddd" forKey:@"image"];
//            [uriInfoDict setObject:uriDict[@"hostName"] forKey:@"hostName"];
//            [uriInfoDict setObject:uriDict[@"count"] forKey:@"count"];
//            [uriInfoDict setObject:[NSDate getDateFromEpoch:uriDict[@"Epoc"]] forKey:@"TimeEpoc"];
//            dispatch_async(self.imageDownloadQueue,^(){
//                [uriInfoDict setObject:[self getImage:uriDict[@"hostName"]] forKey:@"image"];
//            });
//            [oneDayUri addObject:uriInfoDict];
//        }
        [self.dayArr addObject:oneDayUri];
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self.browsingTable reloadData];
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
            img = [UIImage imageNamed:@"help-icon"];
        }
        NSLog(@"five");
        self.urlToImageDict[hostName] = img;
        
        return img;
    }
}


@end
