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
#import "Analytics.h"

@interface BrowsingHistoryViewController ()<UITableViewDelegate,UITableViewDataSource,BrowsingHistoryDelegate,NSURLConnectionDelegate,MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITableView *browsingTable;
@property (nonatomic) NSMutableArray *dayArr;
@property (nonatomic) dispatch_queue_t imageDownloadQueue;
@property (nonatomic) dispatch_queue_t sendReqQueue;
@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) BrowsingHistory *browsingHistory;
@property(nonatomic, readonly) MBProgressHUD *HUD;
@property BOOL sendReq;
@property BOOL reload;
@property int count;
@property NSString *oldDate;

@property (nonatomic) NSString *cmac;
@property (nonatomic) NSString *amac;
@property (nonatomic) NSString *ps;
@property (nonatomic)  UILabel *NoresultFound;
@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (nonatomic) NSDictionary *incompleteDB;

@property BOOL isTapped;


@end

@implementation BrowsingHistoryViewController
typedef void(^InsertMethod)(BOOL);
- (void)viewDidLoad {
    NSLog(@" client name %@",self.client.name);
    self.count = 0;
    
    
    [[Analytics sharedInstance]markWebHistoryPage];
    self.NoresultFound = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 140, 15)];
    [self.NoresultFound setCenter:self.navigationController.view.center];
    self.NoresultFound.text = @"No results found";
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
    [self setUpHUD];
    _responseData = [[NSMutableData alloc] init];
    self.sendReq = YES;
    self.reload = YES;
    self.imageDownloadQueue = dispatch_queue_create("img_download", DISPATCH_QUEUE_SERIAL);
    
    
    //    if([BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac] == 0){
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self showHudWithTimeoutMsg:@"Loading..." withDelay:5];
    //        });
    //    }
    [self sendHttpRequest:[NSString stringWithFormat:@"AMAC=%@&CMAC=%@",self.amac,self.cmac]];
    
    
    self.dayArr = [[NSMutableArray alloc]init];
    [self.browsingTable registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"HistorytableCell"];
    self.browsingHistory = [[BrowsingHistory alloc]init];
    self.browsingHistory.delegate = self;

    [super viewDidLoad];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.NoresultFound.hidden = YES;
    NSDictionary * recordDict = [BrowsingHistoryDataBase insertAndGetHistoryRecord:nil readlimit:100 amac:self.amac cmac:self.cmac];
    [self.browsingHistory getBrowserHistoryImages:recordDict dispatchQueue:self.imageDownloadQueue dayArr:self.dayArr];
    
    
    
    
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
    [BrowsingHistoryDataBase closeDB];
    //[BrowsingHistoryDataBase deleteOldEntries:self.amac clientMac:self.cmac];
    NSLog(@"count otiDB %d",[BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac]);
    [BrowsingHistoryDataBase getLastDate:self.amac clientMac:self.cmac];
    NSLog(@"count otiDB %d",[BrowsingHistoryDataBase GetHistoryDatabaseCount:self.amac clientMac:self.cmac]);
    NSLog(@"complete db lastdate %@ ",[CompleteDB getLastDate:self.amac clientMac:self.cmac]);
     NSLog(@"complete db max %@ ",[CompleteDB getMaxDate:self.amac clientMac:self.cmac]);
    
    
    
}
-(void)updateNavi:(UIColor *)backGroundColor title:(NSString *)title tintColor:(UIColor *)tintColor tintBarColor:(UIColor *)tintBarColor{
    self.navigationController.view.backgroundColor =  backGroundColor;
    self.navigationController.navigationBar.topItem.title = title;
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.barTintColor = tintBarColor;
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    
    if(self.dayArr != nil)
        [self.dayArr removeAllObjects];
    
    
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
    NSLog(@"In sendHttpRequest %d",self.sendReq);
    
    if(self.sendReq == NO)
        return;
    
    self.reload = YES;
    self.sendReq = NO;
    
    dispatch_queue_t sendReqQueue = dispatch_queue_create("send_req", DISPATCH_QUEUE_SERIAL);
    [self showHudWithTimeoutMsg:@"Loading..." withDelay:5];
    dispatch_async(sendReqQueue,^(){
        
        NSLog(@"post req = %@",post);
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        [request setURL:[NSURL URLWithString:@"http://sitemonitoring.securifi.com:8081"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; [request setTimeoutInterval:20.0];
        [request setHTTPBody:postData];
        NSURLResponse *res= Nil;
        //[NSURLConnection connectionWithRequest:request delegate:self];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:nil];
        if(data == nil)
            return ;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        [self InsertInDB:dict];
    });
    
    
    //www.sundoginteractive.com/blog/ios-programmatically-posting-to-http-and-webview#sthash.tkwg2Vjg.dpuf
}
-(void)InsertInDB:(NSDictionary *)dict{
    NSLog(@"In InsertDB %d %d",self.reload,self.sendReq);

    NSLog(@"response dict =%@",dict);
    if(dict == NULL)
        return;
    NSArray *allObj = dict[@"Data"];
    NSLog(@"response obj count %ld",(unsigned long)allObj.count);
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
    int recordCount =0;
    if(self.reload){
        self.count+= 100;
        recordCount = self.count;
    }
    
    NSDictionary * recordDict = [BrowsingHistoryDataBase insertAndGetHistoryRecord:dict readlimit:recordCount amac:self.amac cmac:self.cmac];
    if(self.reload){
        [self.dayArr removeAllObjects];
        [self.browsingHistory getBrowserHistoryImages:recordDict dispatchQueue:self.imageDownloadQueue dayArr:self.dayArr];
        [self reloadTable];
    }
    self.sendReq = YES;
    self.reload = NO;
    
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
        NSLog(@"no results found");
        self.NoresultFound.hidden = NO;
    }
    else{
        NSLog(@"results found");
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
        if(browsHist.count > indexPath.row){
            if(browsHist[indexPath.row] != NULL)
            [cell setCell:browsHist[indexPath.row] hideItem:NO isCategory:NO showTime:YES count:indexPath.row+1];
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"willDisplayCell section %ld row %ld",indexPath.section,indexPath.row);
    
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    
    
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex)) {
        NSString *str;
        //    //NSLog(@"self.dayArr Count = %ld",self.dayArr.count);
        NSArray *browsHist;
        
        
        if(self.dayArr.count > indexPath.section)
            browsHist = self.dayArr[lastSectionIndex];
        NSDictionary *dict2 = browsHist[0];
        //    //NSLog(@"dict2 date %@",dict2);
        str = dict2[@"date"];
        NSLog(@"str last Date On scroll End %@",str);
        BOOL isTodayDate = [str isEqualToString:[BrowsingHistoryDataBase getTodayDate]];
        BOOL isPresentInCompleteDB = [CompleteDB searchDatePresentOrNot:self.amac clientMac:self.cmac andDate:str];
        
        NSLog(@"Is Today Date %d %@",isTodayDate,self.incompleteDB[@"PS"]);
        NSLog(@"Is Present In Complete DB %d",isPresentInCompleteDB);
        
        if(isTodayDate && self.incompleteDB[@"PS"] != NULL){
            NSLog(@"Sending Request in first IF");
            [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&pageState=%@",_amac,_cmac,self.incompleteDB[@"PS"]]];
            
        }
        else if(!isTodayDate && !isPresentInCompleteDB){
            NSLog(@"Sending Request in Second IF");
            NSString *ps= self.incompleteDB[@"PS"] ;
            NSLog(@"self.oldDate = %@ == str = %@",self.oldDate,str);
            if((self.oldDate != nil && [self.oldDate isEqualToString:str]) && ps != NULL)
                [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&dateyear=%@&pageState=%@",_amac,_cmac,str,ps]];
            else
                [self sendHttpRequest:[NSString stringWithFormat: @"AMAC=%@&CMAC=%@&dateyear=%@",_amac,_cmac,str]];

            self.oldDate = str;
        }
        else {
            NSLog(@"Reload from Table ELSE");
            self.count+=100;
            [self.dayArr removeAllObjects];
            NSDictionary * recordDict = [BrowsingHistoryDataBase insertAndGetHistoryRecord:nil readlimit:self.count amac:self.amac cmac:self.cmac];
            [self.browsingHistory getBrowserHistoryImages:recordDict dispatchQueue:self.imageDownloadQueue dayArr:self.dayArr];
            [self reloadTable];
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
        [self.HUD hide:YES];
    });
}
- (void)showHudWithTimeoutMsg:(NSString*)hudMsg withDelay:(int)second {
    NSLog(@"showHudWithTimeoutMsg");
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self showHUD:hudMsg];
        [self.HUD hide:YES afterDelay:second];
        //[self reloadTable];
    });
}
- (void)showHUD:(NSString *)text {
    self.HUD.labelText = text;
    [self.HUD show:YES];
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    // [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)searchBurronClicked:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
    SearchTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SearchTableViewController"];
    
    
    viewController.client = self.client;
    [self.navigationController pushViewController:viewController animated:YES];
    
}
@end
