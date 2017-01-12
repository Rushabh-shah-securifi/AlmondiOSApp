//
//  ChangeCategoryViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 23/08/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ChangeCategoryViewController.h"
#import "UIViewController+Securifi.h"
#import "SFIColors.h"
#import "UIFont+Securifi.h"
#import "Colours.h"
#import "NSDate+Convenience.h"
#import "CategoryView.h"
#import "UIFont+Securifi.h"
#import "Analytics.h"
#import "HistoryCell.h"
#import "CommonMethods.h"
#import "AlmondManagement.h"
#import "HTTPRequest.h"

@interface ChangeCategoryViewController ()<CategoryViewDelegate,UITableViewDelegate,UITableViewDelegate,HTTPDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *catogeryTag;
@property (weak, nonatomic) IBOutlet UILabel *catogeryFuncLbl;
@property (weak, nonatomic) IBOutlet UILabel *CatogeryStatusLbl;

@property (weak, nonatomic) IBOutlet UILabel *LblCatogeryTag;
@property (weak, nonatomic) IBOutlet UILabel *LblUri;
@property (weak, nonatomic) IBOutlet UIButton *backGroundButton;
@property (weak, nonatomic) IBOutlet UILabel *LblCatogeryType;
@property (weak, nonatomic) IBOutlet UILabel *LblClientLastVicited;
@property (nonatomic) UIColor *globalColor;
@property (nonatomic) CategoryView *cat_view;
@property (nonatomic) CategoryView *cat_view_more;

@property (nonatomic) NSString *catTag;
@property (weak, nonatomic) IBOutlet UILabel *clientName;
@property (weak, nonatomic) IBOutlet UILabel *ThanksLabel;
@property (weak, nonatomic) IBOutlet UITableView *epocTable;
@property (weak, nonatomic) IBOutlet UIImageView *iconMore;

@property(nonatomic)NSArray *epocsArr;
@property (nonatomic) HTTPRequest *httpReq;
@end

@implementation ChangeCategoryViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.clientName.text = self.client.name;
    [self.epocTable registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"epocCell"];
    self.httpReq = [[HTTPRequest alloc]init];
    self.httpReq.delegate = self;

}
-(void)updateNavi:(UIColor *)backGroundColor title:(NSString *)title tintColor:(UIColor *)tintColor tintBarColor:(UIColor *)tintBarColor{
    self.navigationController.view.backgroundColor =  backGroundColor;
    self.navigationController.navigationBar.topItem.title = title;
    self.navigationController.navigationBar.tintColor = tintColor;
    self.navigationController.navigationBar.barTintColor = tintBarColor;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[self.uriDict[@"Epoc"] integerValue]];
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];//Accessed on matt's iPhone on Wed 29 June 11:00.
    [dateformate setDateFormat:@"EEEE dd MMMM HH:mm"]; // Date formater
    NSString *str = [dateformate stringFromDate:date];
    [self categoryMap:self.uriDict[@"categoryObj"]];
    [self createRequest:@"Epoch" value:self.uriDict[@"hostName"] suggestValue:@""];
    
}
- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSAttributedString *)getAttributeText:(NSString *)urlStr{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:urlStr attributes:nil];
    NSRange linkRange = NSMakeRange(0, urlStr.length); // for the word "link" in the string above
    
    NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.05 green:0.4 blue:0.65 alpha:1.0],
                                      NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) };
    [attributedString setAttributes:linkAttributes range:linkRange];
    return attributedString;
}
-(void)globalColor:(NSString *)colorHex catogeryTag:(NSString *)catogeryTagTxt catogeryFuncLbl:(NSString *)catogeryFuncLblTxt LblClientLastVicited:(NSString *)LblClientLastVicitedTxt{
    self.globalColor = [UIColor colorFromHexString:colorHex];
    self.catogeryTag.text =catogeryTagTxt;
    self.catogeryFuncLbl.text = catogeryFuncLblTxt;
    self.LblClientLastVicited.text = LblClientLastVicitedTxt;
}
-(void)categoryMap:(NSDictionary *)uriDict{
    NSString *urlStr = self.uriDict[@"hostName"];
    
    self.LblUri.userInteractionEnabled = YES;
    [self.LblUri addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)]];
    self.LblUri.attributedText = [self getAttributeText:urlStr];

    if([[uriDict valueForKey:@"categoty"] isEqualToString:@"NC-17"]){
        [self globalColor:@"000000" catogeryTag:@"Adults Only" catogeryFuncLbl:NSLocalizedString(@"NO_ONE_17", @"") LblClientLastVicited:[NSString stringWithFormat:@"%@ site accessed on %@",@"NC-17",self.client.name]];
       
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"R"]){
      [self globalColor:@"f44336" catogeryTag:@"Restricted" catogeryFuncLbl:NSLocalizedString(@"Under_17_requires", @"") LblClientLastVicited:[NSString stringWithFormat:@"%@ site accessed on %@",@"R",self.client.name]];
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"PG-13"]){
        
        [self globalColor:@"ff9800" catogeryTag:@"Parents Strongly Cautioned" catogeryFuncLbl:NSLocalizedString(@"Some_material_may", @"") LblClientLastVicited:[NSString stringWithFormat:@"%@ Accessed on %@",@"PG-13",self.client.name]];
      
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"U"]){
        
         [self globalColor:@"825CC2" catogeryTag:@"Unknown rating" catogeryFuncLbl:NSLocalizedString(@"We_currently_have_no_information", @"") LblClientLastVicited:[NSString stringWithFormat:@"%@ Accessed on %@",@"U",self.client.name]];
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"PG"]){
       
        [self globalColor:@"ffc107" catogeryTag:@"Parential Guidence Suggested" catogeryFuncLbl:NSLocalizedString(@"Some_material_may_not", @"") LblClientLastVicited:[NSString stringWithFormat:@"%@ Accessed on %@",@"PG",self.client.name]];
        
    }
    else if ([[uriDict valueForKey:@"categoty"] isEqualToString:@"G"]){
    
        self.catogeryFuncLbl.font = [UIFont securifiFont:16];
        [self globalColor:@"4caf50" catogeryTag:@"General Audiences" catogeryFuncLbl:NSLocalizedString(@"All_ages_admitted", @"") LblClientLastVicited:[NSString stringWithFormat:@"%@ Accessed on %@",@"G",self.client.name]];
    }
    
    self.iconMore.image = [CommonMethods imageNamed:@"iconMore" withColor:self.globalColor];
    self.bottomView.backgroundColor = self.globalColor;
    _LblCatogeryTag.backgroundColor = self.globalColor;
    self.LblCatogeryTag.text =[uriDict valueForKey:@"categoty"];
    self.LblCatogeryType.text = [NSString stringWithFormat:@" Category : %@",[uriDict valueForKey:@"subCategory"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)changedCatogeryButtonPrssed:(id)sender {
    NSLog(@"changedCatogeryButtonPrssed");
            self.cat_view = [[CategoryView alloc]init];
        self.cat_view.delegate = self;
        self.cat_view.frame = CGRectMake(0, self.view.frame.size.height - 250, self.view.frame.size.width, 250);
        [self.view addSubview:self.cat_view];
    
    self.backGroundButton.hidden = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)afterCategoryChange{
    self.backGroundButton.hidden = NO;
    self.ThanksLabel.hidden = NO;
    self.bottomView.hidden = YES;
    [[Analytics sharedInstance] markCategoryChange];
}

-(void )didChangeCategoryWithTag:(NSInteger)tag{
//    NSDictionary *updatedUriDict;
    switch (tag) {
        case 1:{
            [self createRequest:@"SuggestRating" value:self.uriDict[@"hostName"] suggestValue:@"1"];
            [self afterCategoryChange];
            break;
        }
        case 2:{
            [self createRequest:@"SuggestRating" value:self.uriDict[@"hostName"] suggestValue:@"2"];
            [self afterCategoryChange];
            break;
        }
        case 3:{
            [self createRequest:@"SuggestRating" value:self.uriDict[@"hostName"] suggestValue:@"3"];
            [self afterCategoryChange];
            break;
        }
        case 4:{
            [self createRequest:@"SuggestRating" value:self.uriDict[@"hostName"] suggestValue:@"4"];
            [self afterCategoryChange];
            break;
        }
        case 5:{
            [self createRequest:@"SuggestRating" value:self.uriDict[@"hostName"] suggestValue:@"5"];
            [self afterCategoryChange];
            break;
        }
            break;
        default:
            break;
        
    }
   [self.cat_view removeFromSuperview];
}
-(void)handleTapOnLabel:(id)sender{
    NSLog(@"hyper link pressed");NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", self.uriDict[@"hostName"]]];
    [[UIApplication sharedApplication] openURL:url];
}
- (IBAction)moreOnCategoryClicked:(id)sender {
    NSLog(@"moreOnCategoryClicked");
    self.cat_view_more = [[CategoryView alloc]initMoreClickView:CGRectMake(0, self.view.frame.size.height - 200, self.navigationController.view.frame.size.width, 420)];
    self.cat_view_more.delegate = self;
    self.cat_view.delegate = self;
    self.cat_view_more.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.cat_view_more];
    self.backGroundButton.hidden = NO;
}

-(void)closeMoreView{
    [self.cat_view removeFromSuperview];
    [self.cat_view_more removeFromSuperview];
}
#pragma mark table and search delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.epocsArr.count;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [self deviceHeader:section tableView:tableView];
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
    
    str = self.uriDict[@"date"];
    NSDate *date = [NSDate convertStirngToDate:str];
    
    NSString *headerDate = [date getDayMonthFormat];
    if([str isEqualToString:[CommonMethods getTodayDate]])
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"epocCell" forIndexPath:indexPath];
    if (cell == nil){
        cell = [[HistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"epocCell"];
    }
    if(self.epocsArr.count > indexPath.row){
    NSDictionary *thisWeek = @{@"hostName":[NSString stringWithFormat:@"  %@",[self.epocsArr objectAtIndex:indexPath.row]],
                               @"image" : [UIImage imageNamed:@"schedule_icon"]
                               };
    
        [cell setCell:thisWeek hideItem:YES isCategory:NO showTime:NO count:indexPath.row+1 hideCheckMarkIMg:YES];
    }
    return cell;
}

#pragma mark sendReq methods
-(void)createRequest:(NSString *)search value:(NSString*)value suggestValue:(NSString *)suggestValue{
    NSString *amac = [AlmondManagement currentAlmond].almondplusMAC;
    NSString *cmac = [CommonMethods hexToString:self.client.deviceMAC];

    NSString *Date = self.uriDict[@"date"];
    NSString *req ;
    if([suggestValue isEqualToString:@""])
    req = [NSString stringWithFormat:@"search=%@&value=%@&today=%@&AMAC=%@&CMAC=%@",search,value,Date,amac,cmac];
    else
    req = [NSString stringWithFormat:@"search=%@&value=%@&today=%@&suggestedValue=%@&AMAC=%@&CMAC=%@",search,value,Date,suggestValue,amac,cmac];
    [self.httpReq sendHttpRequest:req];
    
}

-(void)responseDict:(NSDictionary *)dict{
    if(dict.count==0)
        return;
    NSLog(@"dict = %@",dict);
    
    self.epocsArr = [CommonMethods domainEpocArr:dict[@"Data"]];
    dispatch_async(dispatch_get_main_queue(), ^() {
    [self.epocTable reloadData];
    });
}
- (IBAction)moreButtonTap:(id)sender {
    self.bottomView.hidden = NO;
    self.backGroundButton.hidden = NO;
}
- (IBAction)bottomViewClose:(id)sender {
    self.bottomView.hidden = YES;
    self.backGroundButton.hidden = YES;
}

- (IBAction)dismissCategoryTag:(id)sender {
    [self.cat_view removeFromSuperview];
    [self.cat_view_more removeFromSuperview];
    self.backGroundButton.hidden = YES;
    self.ThanksLabel.hidden = YES;
    if(self.bottomView.hidden == NO)
        self.bottomView.hidden = NO;
    self.ThanksLabel.hidden = YES;
}
@end
