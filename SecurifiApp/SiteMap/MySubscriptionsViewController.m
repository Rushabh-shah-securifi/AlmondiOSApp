//
//  MySubscriptionsViewController.m
//  SecurifiApp
//
//  Created by Masood on 12/5/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MySubscriptionsViewController.h"
#import "MySubscriptionsTableViewCell.h"
#import "SubscriptionPlansViewController.h"
#import "AlmondSelectionTableView.h"
#import "SFIColors.h"
#import "CommonMethods.h"
#import "AlmondManagement.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "UIViewController+Securifi.h"

#define MY_SUBSCIRIPTION_1 @"my_subscriptions_cell_1"
#define MY_SUBSCIRIPTION_2 @"my_subscriptions_cell_2"

#define INTERNET_SECURITY 1

@interface MySubscriptionsViewController ()<MySubscriptionsTableViewCellDelegate, AlmondSelectionTableViewDelegate, UIAlertViewDelegate>
@property (nonatomic) UILabel *almondLabel;
@property (nonatomic) UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *almSelectionBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *mySubscriptionsArray;
@property (nonatomic) UIButton *buttonMaskView;
@property (nonatomic)AlmondPlan *almondPlan;
@end

@implementation MySubscriptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.almondLabel.text = [AlmondManagement currentAlmond].almondplusName;
    self.almondPlan = [AlmondPlan getAlmondPlan];
    NSLog(@"almond plan %d", self.almondPlan.planType);
    [self initializeMySubscriptionsArray];
    // Do any additional setup after loading the view.
}

- (void)viewDidLayoutSubviews{
    [self makeAlmondSelectionBtn];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self initializeNotification];
}

-(void)viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // Navigation back button was pressed. Do some stuff
        [self.navigationController setNavigationBarHidden:NO];
    }
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializeNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(onSubscribeMeCommandResponse:) name:SUBSCRIBE_ME_NOTIFIER object:nil];
}

- (void)initializeMySubscriptionsArray{
    //This was coded for expansion of sections on tap. Now with new changes it is not needed, but anyways I am keeping the code for possible changes in future.
    NSArray *titles = @[@"IoT Security"];
    self.mySubscriptionsArray = [NSMutableArray new];
    for(NSString *title in titles){
        NSMutableDictionary *muDict = [NSMutableDictionary new];
        [muDict setObject:title forKey:TITLE];
        [muDict setObject:[NSNumber numberWithBool:NO] forKey:IS_EXPANDED];
        [self.mySubscriptionsArray addObject:muDict];
    }
}

#pragma mark ui mehtods
- (void)makeAlmondSelectionBtn{
    NSString *currentAlmName = [AlmondManagement currentAlmond].almondplusName;
    _almondLabel = [[UILabel alloc]init];
    _imgView = [[UIImageView alloc]init];
    [self setFrames:currentAlmName];
    
    //almond name label
    [CommonMethods setLableProperties:_almondLabel text:currentAlmName textColor:[SFIColors paymentColor] fontName:@"Avenir-Roman" fontSize:18 alignment:NSTextAlignmentCenter];
    _almondLabel.center = CGPointMake(CGRectGetWidth(_almSelectionBtn.bounds)/2-10, CGRectGetHeight(_almSelectionBtn.bounds)/2);
    [self.almSelectionBtn addSubview:_almondLabel];
    
    //drop arrow image
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.image = [[UIImage imageNamed:@"arrow_drop_down_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_imgView setTintColor:[SFIColors paymentColor]];
    [self.almSelectionBtn addSubview:_imgView];
}

- (void)setFrames:(NSString *)currentAlmName{
    CGFloat titleWidth;
    CGSize textSize;
    textSize = [currentAlmName sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Avenir-Roman" size:18]}];
    titleWidth = textSize.width + 10;
    if(titleWidth > 150){
        titleWidth = 150;
    }
    
    _almondLabel.frame = CGRectMake(0, 0, titleWidth, 30);
    _almondLabel.center = CGPointMake(CGRectGetWidth(_almSelectionBtn.bounds)/2-10, CGRectGetHeight(_almSelectionBtn.bounds)/2);
    
    _imgView.frame = CGRectMake(CGRectGetMaxX(_almondLabel.frame)+1, CGRectGetMinY(_almondLabel.frame), 30, 30);
}

#pragma mark button tap methods
- (IBAction)onBackBtnTap:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}
- (IBAction)onAlmondSelectionTap:(id)sender {
    [self showAlmondSelection];
}

#pragma mark table and search delegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == 0? 80: 105;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"help rows");
    NSDictionary *routerFeature  = self.mySubscriptionsArray[section];
    return [routerFeature[IS_EXPANDED] boolValue]? 2: 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.mySubscriptionsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier;
    if(indexPath.row == 0){
        identifier = MY_SUBSCIRIPTION_1;
    }else{
        identifier = MY_SUBSCIRIPTION_2;
    }
    
    MySubscriptionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (cell == nil){
        cell = [[MySubscriptionsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *routerFeature  = self.mySubscriptionsArray[indexPath.section];
    [cell setUpCell:routerFeature almondPlan:self.almondPlan];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"section: %ld", (long)indexPath.section);
    NSMutableDictionary *subscriptionType  = self.mySubscriptionsArray[indexPath.section];
    if(indexPath.row == 0){
        NSNumber *isExpandedInvert = [NSNumber numberWithBool:![subscriptionType[IS_EXPANDED] boolValue]];
        NSLog(@"invert: %@, did select router array: %@", isExpandedInvert, self.mySubscriptionsArray);
        
        [subscriptionType setObject:isExpandedInvert forKey:IS_EXPANDED];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    }
    
}

#pragma mark almond selection
- (void)showAlmondSelection{
    self.buttonMaskView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.navigationController.view.frame.size.height)];
    self.buttonMaskView.backgroundColor = [SFIColors maskColor];
    [self.buttonMaskView addTarget:self action:@selector(onBtnMskTap:) forControlEvents:UIControlEventTouchUpInside];
    
    AlmondSelectionTableView *view = [AlmondSelectionTableView new];
    view.methodsDelegate = self;
    view.needsAddAlmond = NO;
    [view initializeView:self.buttonMaskView.frame];
    [self.buttonMaskView addSubview:view];
    
    [self slideAnimation];
}

-(void)slideAnimation{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionReveal;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.buttonMaskView.layer addAnimation:transition forKey:nil];
    [self.tabBarController.view addSubview:self.buttonMaskView];
}

- (void)onCloseBtnTapDelegate{
    [self removeAlmondSelectionView];
}

-(void)onBtnMskTap:(id)sender{
    [self removeAlmondSelectionView];
}

- (void)onAddAlmondTapDelegate{
    NSLog(@"on add almond tap delegate");
}

-(void)onAlmondSelectedDelegate:(SFIAlmondPlus *)selectedAlmond{
    [self removeAlmondSelectionView];
    NSLog(@"onAlmondSelectedDelegate i am called");
    [self setFrames:selectedAlmond.almondplusName];
    _almondLabel.text = selectedAlmond.almondplusName;
    [AlmondManagement setCurrentAlmond:selectedAlmond];
    
    self.almondPlan = [AlmondPlan getAlmondPlan];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

-(void)removeAlmondSelectionView{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.buttonMaskView.alpha = 0;
                     }completion:^(BOOL finished){
                         [self.buttonMaskView removeFromSuperview];
                     }];
    self.buttonMaskView = nil;
}

#pragma mark alert methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == [alertView cancelButtonIndex]){
        //cancel clicked ...do your action
        if(alertView.tag == INTERNET_SECURITY){
            [self sendDeleteSubscriptionCommand];
        }
    }else{
    }
}

- (void)showAlert:(NSString *)title msg:(NSString *)msg cancel:(NSString*)cncl other:(NSString *)other tag:(int)tag{
    NSLog(@"controller show alert tag: %d", tag);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:cncl otherButtonTitles:other, nil];
    alert.tag = tag;
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert show];
    });
}
#pragma mark cell delegate methods
- (void)onLeftBtnTapDelegate:(NSString *)btnTitle{
    [self LaunchSubscriptionsPlanController];
}

- (void)onRightBtnTapDelegate:(NSString *)btnTitle{
    if([btnTitle isEqualToString:CANCEL_SUBSCRIPTION]){
        NSString *msg = [NSString stringWithFormat:@"By cancelling your subscription you will no longer have access to Internet Security on %@.", [AlmondManagement currentAlmond].almondplusName];
        [self showAlert:@"" msg:msg cancel:@"Cancel Subscription" other:@"Nevermind" tag:INTERNET_SECURITY];
    }
    else{
        [self LaunchSubscriptionsPlanController];
    }
}

- (void)LaunchSubscriptionsPlanController{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
        SubscriptionPlansViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SubscriptionPlansViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        nav.navigationBarHidden = YES;
        [self presentViewController:nav animated:YES completion:nil];
    });
}

#pragma mark payload/command
- (void)sendDeleteSubscriptionCommand{
    NSLog(@"sendDeleteSubscriptionCommand");
    NSString *almondMac = [AlmondManagement currentAlmond].almondplusMAC;
    NSDictionary *payload;
    payload = @{
                @"CommandType": @"DeleteSubscription",
                @"AlmondMAC": almondMac?: @"",
                @"AlmondName": [AlmondManagement currentAlmond].almondplusName
                };
    GenericCommand *genericCmd =  [GenericCommand jsonStringPayloadCommand:payload commandType:CommandType_SUBSCRIBE_ME];
    [[SecurifiToolkit sharedInstance] asyncSendToNetwork:genericCmd];
}

- (void)onSubscribeMeCommandResponse:(id)sender{
    NSLog(@"onSubscribeMeCommandResponse");
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *dataInfo = [notifier userInfo];
    if (dataInfo == nil || [dataInfo valueForKey:@"data"]==nil ) {
        return;
    }
    BOOL local = [toolkit useLocalNetwork:[AlmondManagement currentAlmond].almondplusMAC];
    NSDictionary *payload;
    if(local){
        payload = [dataInfo valueForKey:@"data"];
    }else{
        payload = [[dataInfo valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"meshcontroller mesh payload: %@", payload);
    
    BOOL isSuccessful = [payload[@"Success"] boolValue];
    NSString *cmdType = payload[COMMAND_TYPE];
    if(isSuccessful){
        [self showToast:@"Your subscription has been successfully cancelled."];
        //need to check on this if/else
        [AlmondPlan updateAlmondPlan:PlanTypeFreeExpired];    
    }else{
        [self showToast:@"Sorry! Unable to cancel subscription. Please try later."];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
@end
