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
#import "AlmondManagement.h"

#define MY_SUBSCIRIPTION_1 @"my_subscriptions_cell_1"
#define MY_SUBSCIRIPTION_2 @"my_subscriptions_cell_2"
#define TITLE @"title"
#define IS_EXPANDED @"is_expanded"

@interface MySubscriptionsViewController ()<MySubscriptionsTableViewCellDelegate, AlmondSelectionTableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *almondLabel;

@property (nonatomic) NSMutableArray *mySubscriptionsArray;
@property(nonatomic) UIButton *buttonMaskView;
@end

@implementation MySubscriptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.almondLabel.text = [AlmondManagement currentAlmond].almondplusName;
    [self initializeMySubscriptionsArray];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // Navigation back button was pressed. Do some stuff
        [self.navigationController setNavigationBarHidden:NO];
    }
    [super viewWillDisappear:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [cell setSubscriptionTitle:routerFeature[TITLE]];
    
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

#pragma mark cell delegate methods
- (void)onChangePlanDelegate{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SiteMapStoryBoard" bundle:nil];
        SubscriptionPlansViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"SubscriptionPlansViewController"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
        nav.navigationBarHidden = YES;
        [self presentViewController:nav animated:YES completion:nil];
    });
}

- (void)onRenewPlanDelegate{
    
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
    self.almondLabel.text = selectedAlmond.almondplusName;
    [AlmondManagement setCurrentAlmond:selectedAlmond];
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

@end
